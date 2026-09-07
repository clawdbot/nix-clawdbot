---
written_by: ai
---

# nix-openclaw Plugin Architecture (Maintainer Memo)

Purpose: define nix-openclaw plugins without confusing them with OpenClaw runtime plugins. A nix-openclaw plugin is a Nix-managed bundle of tools, skills, and config requirements.

## What a Plugin Is (and is not)
- **Is:** bundle of binaries/CLIs, skills that teach the agent to use them, optional config/env requirements.
- **Not:** new transports/providers; model plumbing; secrets baked in; inline scripts or ad-hoc package-manager installs; a place for random config outside its scope.
- Why not skills-only: skills without binaries can imply tools that are not installed. Plugins ground skills in real tools and deliver versioned, reproducible functionality.

## Two Plugin Classes

nix-openclaw plugins are the tool/skill/env bundles described below. They do not use OpenClaw's JavaScript plugin loader. They are the right shape for CLIs such as `goplaces`, `gog`, `qmd`, `xuezh`, `camsnap`, and `summarize`.

OpenClaw plugins are runtime plugin directories with `openclaw.plugin.json` plus built JavaScript loaded by the gateway. They include bundled upstream plugins, official external plugins from OpenClaw's inventory, ClawHub packages, third-party npm packages, and channel plugins such as Slack, Discord, Weixin, or WhatsApp. nix-openclaw supports generated OpenClaw inventory locks through `programs.openclaw.runtimePlugins` and arbitrary exact npm/ClawHub package locks through `programs.openclaw.runtimePluginSources` when the artifact can be packaged reproducibly. Raw npm, ClawHub, git, local, marketplace, and third-party source strings are not user-facing `runtimePlugins` inputs.

Current nix-openclaw `customPlugins` supports nix-openclaw plugins: package binaries on the gateway PATH, add skills through OpenClaw skill load paths, create state dirs, validate env files, and render optional tool settings.

PR #81 (`fix: copy plugin manifests into dist/extensions`) was related but not the missing external-plugin feature. It fixed bundled upstream plugin manifests missing from the packaged gateway `dist/extensions/*/openclaw.plugin.json` tree. Current packaging already copies those manifests and checks them in `openclaw-package-contents`.

Supported OpenClaw runtime plugins are fetched as pinned Nix artifacts, validated as OpenClaw runtime plugin roots, and wired through OpenClaw's own `plugins.load.paths` and `plugins.entries` config. Runtime dependencies must be absent, bundled, or materialized from `npmDepsHash` and either package-local shrinkwrap or upstream npm package-lock release evidence during the Nix build. Do not route npm runtime plugins through `customPlugins`; that surface is for nix-openclaw plugin flakes.

## OpenClaw Runtime Install Surfaces

Regular OpenClaw has one mutable lifecycle command, `openclaw plugins install`, with several source forms. In Nix mode, OpenClaw disables plugin install, update, uninstall, enable, and disable mutators. nix-openclaw must therefore package the supported cases ahead of time and render immutable load paths; it must not run the upstream installer during activation.

| Regular OpenClaw command | Upstream behavior | nix-openclaw behavior |
| --- | --- | --- |
| `openclaw plugins enable workboard` | Enables a plugin that already ships inside the OpenClaw package. | Set the upstream config entry directly, for example `programs.openclaw.config.plugins.entries.workboard.enabled = true;`. |
| `openclaw plugins install @openclaw/brave-plugin` | Installs an official inventory plugin with no runtime npm dependencies. | If the generated lock contains `brave`, users write `programs.openclaw.runtimePlugins = [ "brave" ];`. |
| `openclaw plugins install @openclaw/slack` | Installs an official inventory plugin. Upstream may use a bundled source, npm, or official inventory metadata. | If generated support exists, users write `programs.openclaw.runtimePlugins = [ "slack" ];`. |
| `openclaw plugins install npm:@openclaw/memory-lancedb` | Installs an npm package and resolves dependencies during install. | The generator writes `dependencyMode = "shrinkwrap"` or `"package-lock"` with `npmDepsHash`; users still write only `runtimePlugins = [ "memory-lancedb" ];`. |
| `openclaw plugins install clawhub:@openclaw/whatsapp` | Resolves ClawHub metadata, verifies the artifact, then installs the package root. | The generator resolves ClawHub at update time and feeds the fixed artifact through the same packageability rule. The current OpenClaw 2026.6.1 lock supports WhatsApp and Matrix this way. |
| `openclaw plugins install @tencent-weixin/openclaw-weixin` | Installs a package whose current artifact lets npm solve dependencies at install time. | No `runtimePlugins` id until upstream publishes `npm-shrinkwrap.json`, bundled `node_modules`, or matching npm package-lock release evidence, then maintainers regenerate the lock. |
| `openclaw plugins install npm:@scope/plugin@1.2.3` | Installs an arbitrary npm package into a mutable per-plugin npm project. | Use `programs.openclaw.runtimePluginSources = [{ id = "..."; spec = "npm:@scope/plugin@1.2.3"; hash = lib.fakeHash; }];`. If the build reports shrinkwrap materialization, add `npmDepsHash = lib.fakeHash;`, rebuild, then replace both hashes. |
| `openclaw plugins install clawhub:@scope/plugin@1.2.3` | Resolves an arbitrary ClawHub package to a plugin artifact. | Use `programs.openclaw.runtimePluginSources = [{ id = "..."; spec = "clawhub:@scope/plugin@1.2.3"; hash = lib.fakeHash; }];`. If the build reports shrinkwrap materialization, add `npmDepsHash = lib.fakeHash;`, rebuild, then replace both hashes. |
| `openclaw plugins install npm-pack:./plugin.tgz` | Installs a local npm-pack tarball through npm install semantics. | `runtimePluginSources.url` accepts a fixed HTTPS tarball URL with a Nix hash. Local dev tarballs remain outside the declarative runtime plugin API. |
| `openclaw plugins install git:github.com/owner/repo@ref` | Clones a repo, checks out the ref, installs the plugin root, and records source metadata. | Not accepted as a raw source string. A declarative version needs a fixed revision, Nix source hash, and plugin-root validation. |
| `openclaw plugins install --link ./my-plugin` | Links a local development checkout into OpenClaw's plugin roots. | Not reproducible. A raw `programs.openclaw.config.plugins.load.paths` escape hatch is user-owned and cannot be mixed with `runtimePlugins`. |
| `openclaw plugins install <plugin> --marketplace <source>` | Installs a compatible bundle from a Claude marketplace source. | Not `runtimePlugins` unless it is first converted into a fixed runtime plugin artifact. `customPlugins` remains the Nix flake tool/skill bundle surface, not a marketplace installer. |

The maintainer rule is: first resolve upstream source details into a package root with fixed identity, then decide whether that root is Nix-packageable. For OpenClaw official inventory rows, expose the generated plugin id. For arbitrary npm or ClawHub packages, require a locked `runtimePluginSources` record. If an official row is not packageable, leave it out of the generated lock and keep the diagnostic in `nix/generated/openclaw-runtime-plugins/report.json`. Do not turn report skip reasons into user-facing product categories.

Generated locks support dependency-free roots, bundled `node_modules`,
package-local shrinkwrap, and `dependencyMode = "package-lock"` for lockless
catalog packages with matching upstream release evidence. OpenClaw 2026.8.1+
plugins that opt out of bundling can use this last mode once upstream ships
`dependency-evidence/npm-package-locks.json` in its dependency evidence ZIP.
The updater selects the exact package name/version, verifies the release tag
and source SHA, and writes `<attrName>.package-lock.json` next to its `.nix`
lock. The generated record includes `npmDepsHash`, `npmPackageLockFile`,
`npmPackageLockSha256`, and `npmPackageLockEvidence` (asset identity, Nix hash,
source, source SHA, generation time). Only build copies are normalized.
Entries must declare an empty `omittedWorkspaceDependencies` array; partial locks are skipped as `package-lock-evidence-incomplete`, with the omitted dependency names in `report.json`.

Verification has two tiers. Pin-time validation in `scripts/update-pins.sh`
sets `OPENCLAW_RUNTIME_PLUGIN_VERIFY_EVIDENCE_ASSET=1`: for every package-lock
record labeled `release`, the checker prefetches the pinned release evidence
asset, checks its Nix hash, and compares the exact selected lock bytes and
SHA-256 with the committed sidecar. Missing assets, missing entries, and
mismatches fail validation. This verification ignores the local ZIP override
for release records. Pure Nix CI keeps the existing structural and hash checks
without network access; it does not enable asset verification. Explicitly
allowed `override` records remain local validation inputs, not release proof.

Rows lacking all three dependency shapes remain skipped as
`runtime-dependencies-without-shrinkwrap`; see `report.json` for the current
supported ids and diagnostics. Regenerate after upstream supplies a supported
shape. No registry range resolution happens during activation or builds.

For maintainer validation before the release asset exists, set
`OPENCLAW_RUNTIME_PLUGIN_DEPENDENCY_EVIDENCE_ZIP=/absolute/path/evidence.zip`
when running `scripts/update-pins.sh apply` or the runtime lock updater directly.
The ZIP must still match `openclaw-source.nix`'s `releaseTag` and `rev`; its asset
name uses `releaseVersion`, while package selection uses the artifact version
(which may be `runtimePluginVersion` on correction releases). Override records
require `OPENCLAW_RUNTIME_PLUGIN_ALLOW_EVIDENCE_OVERRIDE=1` for the lock checker.
Pass that environment variable with `nix build --impure` for local Nix checks;
pure CI rejects override records. Regenerate from the published release asset
before landing generated locks. The updater's `--check` compares sidecar bytes
and detects missing or stale sidecars without modifying generated files.

## Interface Contract
Every nix-openclaw plugin exposes the same fields through the `openclawPlugin` flake output:

```nix
openclawPlugin = {
  name        = "summarize";                # unique; last-wins on collision
  skills      = [ ./skills/summarize ];      # dirs containing SKILL.md
  packages    = [ pkgs.summarize-cli ];      # binaries placed on the OpenClaw runtime PATH
  needs = {
    stateDirs   = [ ".config/summarize" ]; # created under $HOME
    requiredEnv = [ "SUMMARIZE_API_KEY" ];  # must point to files
  };
};
```

Host responsibilities (what the runtime guarantees):
- Resolve plugin source; read contract.
- Install `packages`; prepend to PATH for the gateway wrapper.
- Create `needs.stateDirs` under `$HOME`.
- Fail fast if any `requiredEnv` is unset or points to a missing/empty file.
- Add each `skills` entry to generated `skills.load.extraDirs` for the instance.
- If host config provides `config.settings`, render it to `config.json` in the first `stateDir`.
- Export `config.env` (plus required envs) into the gateway wrapper.
- Reject duplicate skill paths; duplicate plugin names: last entry wins.

### Host-side config shape
When enabling a plugin, the host can supply:

```nix
programs.openclaw.customPlugins = [
  {
    source = "github:owner/repo?rev=<commit>&narHash=<narHash>";
    config = {
      env = { KEY = "/run/agenix/key"; EXTRA = "/path/to/file"; };
      settings = { foo = "bar"; retries = 3; };
    };
  }
];
```

- `config.env`: values for `requiredEnv` (and any extra env to export).
- `config.settings`: JSON-rendered into `config.json` inside the first `stateDir`.
- Invariant: providing `settings` requires at least one `stateDir`.

Do not add raw npm package names to `runtimePlugins`, host config load paths, or `customPlugins`. Supported OpenClaw official inventory ids go through `programs.openclaw.runtimePlugins`; arbitrary exact npm and ClawHub runtime plugins go through locked `programs.openclaw.runtimePluginSources`; `customPlugins.source = "npm:..."` is intentionally unsupported.

## Dev workflow (fast iteration)
- Worktree: build and test plugins outside the core repo; point OpenClaw at a local path source during impure local dev (e.g., `source = "path:/Users/you/code/my-plugin"`). Committed config uses pinned refs.
- Rebuild loop: change plugin → `home-manager switch` (or host-equivalent) → gateway restarts with new PATH/skills/config; no manual copying.
- Name collisions: use the same plugin `name` to override a pinned version (last entry wins); keep unique names otherwise to avoid surprise overrides.
- Skills placement: immutable Nix/plugin paths remain the inputs. Activation creates per-instance, user-owned runtime copies under `~/.local/share/nix-openclaw/skills` and wires them through `skills.load.extraDirs`, so every agent workspace in that instance can discover them without relaxing upstream hardlink checks.
- Env guardrails: required env vars must point to files (non-empty) or the activation fails—supply temp files during dev to exercise the checks.
- Settings JSON: inspect the rendered `config.json` in the first `stateDir` to confirm schema and defaults before committing.

## Examples

### Minimal nix-openclaw plugin (bundled `summarize`)
Enable (host side):

```nix
programs.openclaw.bundledPlugins.summarize.enable = true;
```

Plugin contract (inside the plugin repo):

```nix
openclawPlugin = {
  name = "summarize";
  skills = [ ./skills/summarize ];
  packages = [ self.packages.${system}.summarize-cli ];
  needs = { stateDirs = []; requiredEnv = []; };
};
```

### Plugin with required config/env (community `xuezh`)
Enable (host side):

```nix
programs.openclaw.customPlugins = [
  {
    source = "github:joshp123/xuezh?rev=<commit>&narHash=<narHash>";
    config = {
      env = {
        # Required envs (guarded as files):
        XUEZH_AZURE_SPEECH_KEY_FILE = "/run/agenix/xuezh-azure-speech-key";
        XUEZH_AZURE_SPEECH_REGION   = "/run/agenix/xuezh-azure-speech-region"; # file containing e.g. "westeurope"
      };
      settings = {
        audio = {
          backend_global        = "azure.speech";
          process_voice_backend = "azure.speech";
          convert_backend       = "ffmpeg";
          tts_backend           = "edge-tts";
          inline_max_bytes      = 200000;
        };
        azure = {
          speech = {
            key_file = "/run/agenix/xuezh-azure-speech-key";
            region   = "westeurope";
          };
        };
      };
    };
  }
];
```

Plugin contract (inside `xuezh`):

```nix
openclawPlugin = {
  name = "xuezh";
  skills = [ ./skills/xuezh ];
  packages = [ self.packages.${system}.default ];
  needs = {
    stateDirs   = [ ".config/xuezh" ];
    requiredEnv = [ "XUEZH_AZURE_SPEECH_KEY_FILE" "XUEZH_AZURE_SPEECH_REGION" ];
  };
};
```

Host behavior: creates `~/.config/xuezh/config.json` from `settings`; exports both envs; fails if the pointed files are missing/empty.

## Bundled Plugin Set (current)
- summarize, discrawl, wacrawl, peekaboo, poltergeist, sag, camsnap, gogcli, goplaces, sonoscli, imsg.
- Source of truth: `nix/modules/home-manager/openclaw/plugin-catalog.nix`.
- Each follows the same contract: packages + skills; env/state declared via `needs`; enabled via config toggle; sources pinned via the bundled plugin catalog.

## Authoring Rules
- Keep CLIs configurable via env; honor XDG paths; no inline scripts.
- Ship `AGENTS.md` in the plugin repo with knobs/paths (no secrets).
- `SKILL.md` should call the CLI by its PATH name (no absolute paths).
- If `config.settings` is expected, declare at least one `stateDir`.
- Add CI to build the plugin and validate `requiredEnv`/`stateDir` invariants.

## Why this approach
- Capability grounding: skills map to real tools, not hypothetical ones.
- Reproducibility: versioned bundle of tool + skill + config schema; easy rollback.
- Clean core: main OpenClaw stays transport/model-focused; plugins carry integrations.
- Operational sanity: one toggle wires tools, env, skills; failure is explicit and early.
- Portability: contract is host-agnostic; Nix just enforces determinism and zero drift.
