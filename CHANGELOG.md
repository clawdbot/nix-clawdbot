---
written_by: ai
---

# Changelog

This changelog starts with the current pre-1.0 nix-openclaw Home Manager module
API transition.
Older repository history is available in git.

## Unreleased

**Highlights:** Nix-managed skills remain discoverable with OpenClaw’s hardlink checks, and documented home-relative paths work consistently across Home Manager activation and gateway services. Changes below cover the package state since `v2026.7.1`.

- Materialize configured user and plugin skills as per-instance runtime copies, preserving all-agent discovery, extra load paths, and cleanup boundaries; thanks @vsumner (#118).
- Resolve leading `~/` in instance state, workspace, and config paths consistently for managed files, runtime profiles, and launchd/systemd services, including paths containing spaces and quotes; thanks @SebTardif (#130).
- Support packaging OpenClaw 2026.8.1+ lockless runtime plugins once upstream ships npm package-lock release evidence, with dependencies bound to the pinned release SHA (2026-09-06).
- Regenerate the gateway npm wrapper lock from scratch on every stable pin refresh and validate it offline before `npm ci`; updating the previous release's lock in place left OpenClaw 2026.9.x without its hoisted `p-limit@7` dependency and failed the Nix gateway build with ENOTCACHED (2026-09-07).
- Use the locked Node.js 24 runtime for OpenClaw builds, launchers, plugin materialization, private pnpm integrations, and bundled tools; Node.js 22 cannot install or run OpenClaw 2026.9.3 (2026-09-08).
- Recognize the root `.js` and `.mjs` packaging contracts in OpenClaw 2026.7.1-2 and 2026.9.3, reusing upstream's hardlink predicate for Nix store ownership and retaining existing candidate-install guard limitations; source overrides and native validation remain separate (2026-09-08).
- Follow the pinned agent roster schema in Home Manager and its multi-agent checks. Keyed rosters use validated, lowercase profile IDs without an extra main agent; missing or empty non-explicit rosters emit `agents.entries.main = {}` even with workspace pinning disabled, without adding a workspace pin. Nonempty rosters, explicit ownership, and old-schema output stay unchanged (2026-09-08).
- Fix Home Manager config symlink activation and systemd environment quoting for paths containing spaces, while preserving home-relative `~/` symlink destinations; thanks @SebTardif (#122).
- Constrain workspace cleanup and replacement to configured roots, preserve stale paths from removed or moved instances with a warning, avoid changing symlink targets or hardlinked file permissions, and create home-relative workspace paths containing spaces correctly; thanks @SebTardif (#119, #120).
- Keep OpenClaw's private pnpm tools out of the consumer Nixpkgs overlay, support pnpm 12 releases, update the private runtimes to pnpm 11.26.0 and 12.3.4, and fix the pnpm 12 Linux executable's loader and runtime libraries; thanks @jerome-benoit (#116, #117, #121).
- Restart the configured launchd labels and systemd user units with `openclaw-reload` instead of the old hardcoded labels.
- Package upstream OpenClaw `2026.7.1-2`, retain runtime plugin version `2026.7.1` for correction releases, and repair the macOS `2026.7.1` app artifact hash; thanks @vincentkoc.
- Preserve canonical scoped npm package encoding and fully escape generated CI table cells; thanks @vincentkoc (#114).
- Document declarative Gmail hook session keys and their allowed prefix to prevent rejected callbacks (#113).
- Refresh Nixpkgs, Home Manager, the packaged OpenClaw tools, and the Linux QMD memory backend to 2.8.3, keeping bundled tool plugin sources aligned with the flake lock.
- Refresh CI checkout to 7.0.1 and the Nix installer to 31.11.1, which fixes a Nix build crash.

## 2026-09-04

### Changed

- Update the private pnpm 11 and 12 tools to 11.25.0 and 12.3.1, with Linux/macOS checks for offline installs and frozen lockfiles. Keep the existing Node.js 22 runtime and Nixpkgs overlay boundary.

### Fixed

- Patch the native pnpm 12 Linux executable to use the Nix loader and runtime libraries, so its public package output runs inside the Nix sandbox.
- Constrain workspace activation cleanup and replacement to configured workspace roots, preserve stale paths from removed or moved instances with a warning, and avoid changing symlink targets or hardlinked file permissions during cleanup. Create home-relative workspace paths containing spaces correctly during activation. Thanks @SebTardif (#119).

## 2026-08-30

### Fixed

- Keep OpenClaw's private pnpm pins under `openclawPackages` so the default overlay no longer replaces Nixpkgs' pnpm for unrelated packages. Thanks @jerome-benoit (#116).
- `openclaw-reload` now restarts the configured Home Manager launchd labels or
  systemd user units instead of the old hardcoded `.nix` and `.nix-test`
  labels.

## 2026-06-06

### Changed

- Changed the stable `openclaw` / `openclaw-gateway` package path to build from
  upstream's published npm package and shrinkwrap by default. Source/pnpm builds
  remain available for explicit source overrides.
- Updated stable pin automation to refresh the npm wrapper lockfile and
  `gatewayNpmDepsHash` with each selected upstream source release.
- Replaced the vague CI aggregate with named supported-surface proofs for
  package artifacts, module render, source-override render, runtime smoke,
  platform activation, runtime plugin catalog/host behavior, and QMD opt-in.
- Removed the temporary dogfood package and check outputs from the public flake
  surface.

### Added

- Added `programs.openclaw.runtimePluginSources` for locked,
  Nix-reproducible npm and ClawHub runtime plugin artifacts. Generated
  supported ids still use `programs.openclaw.runtimePlugins`.
- Added shrinkwrap materialization for runtime plugins with npm dependencies.
  Shrinkwrapped packages use `npmDepsHash`; plugins that bundle `node_modules`
  remain supported.
- Added `runtimePlugins` support for `acpx`, `codex`, `copilot`, `matrix`,
  `memory-lancedb`, `tlon`, and `whatsapp`.

## 2026-06-05

### Highlights

- The nix-openclaw Home Manager module now manages OpenClaw workspace bootstrap
  files explicitly instead of reading a single `programs.openclaw.documents`
  directory.
- Baseline: packaged upstream OpenClaw `v2026.6.1`
  (`2e08f0f4221f522b60423ed6ffd83427942b28de`).
- Scope: this entry describes the nix-openclaw module/API migration only; it
  does not claim later upstream OpenClaw tags or `main`.

### Trace

- nix-openclaw implementation commit:
  `85ac5a06bc00a0bc48c8e9831979e5e8b13184ce`
- Date written: 2026-06-05
- Packaged upstream OpenClaw release:
  `v2026.6.1` (`2e08f0f4221f522b60423ed6ffd83427942b28de`)

### Breaking Changes

#### nix-openclaw Shortcut Config Options Were Removed

nix-openclaw no longer has separate Home Manager shortcut options for provider,
channel, routing, or agent config. Put OpenClaw runtime config under
`programs.openclaw.config` and `programs.openclaw.instances.<name>.config`,
using the upstream OpenClaw config shape.

This is a nix-openclaw module API break, not an upstream OpenClaw runtime parser
change.

This entry is included because this changelog is the migration ledger for
current nix-openclaw Home Manager module breaks. The shortcut-option removal is
not caused by the workspace-file change, but users and agents upgrading
pre-1.0 nix-openclaw need one place to see every required config rewrite.

Before:

```nix
programs.openclaw = {
  providers.telegram = {
    enable = true;
    botTokenFile = "/run/agenix/telegram-bot-token";
    allowFrom = [ 12345678 ];
  };

  providers.anthropic.apiKeyFile = "/run/agenix/anthropic-api-key";
};
```

After:

```nix
programs.openclaw = {
  environment.ANTHROPIC_API_KEY = "/run/agenix/anthropic-api-key";

  config = {
    channels.telegram = {
      tokenFile = "/run/agenix/telegram-bot-token";
      allowFrom = [ 12345678 ];
    };

    models.providers.anthropic.apiKey = {
      source = "env";
      provider = "default";
      id = "ANTHROPIC_API_KEY";
    };
  };
};
```

For named instances, put per-instance OpenClaw config under the instance.
Top-level `programs.openclaw.config` is merged into every instance; instance
config is the boundary for prod/test routing, credentials, and host-specific
runtime settings:

```nix
programs.openclaw.instances.prod.config.channels.telegram = {
  tokenFile = "/run/agenix/telegram-prod";
  allowFrom = [ 12345678 ];
};
```

#### `programs.openclaw.documents` Is Removed

`programs.openclaw.documents` is removed and now fails evaluation. Replace it
with explicit workspace bootstrap files and extra managed workspace files.

The old option hid the ownership contract. One directory mixed upstream
bootstrap context with arbitrary companion files, and other Nix modules could
also write directly into the same workspace-like paths. That made deploy-time
clobbering hard to reason about: the file owner depended on activation order and
on whether a file happened to be copied through `documents` or written somewhere
else. The new API is deliberately explicit so each Nix-managed workspace target
has one declaration.

Before:

```nix
programs.openclaw.documents = ./documents;
```

The old directory commonly looked like this:

```text
documents/
|-- AGENTS.md
|-- SOUL.md
|-- TOOLS.md
|-- IDENTITY.md
|-- USER.md
|-- LORE.md
|-- PROMPTING-EXAMPLES.md
`-- HEARTBEAT.md
```

After:

```nix
programs.openclaw.workspace.bootstrapFiles = {
  agents = ./workspace/AGENTS.md;
  soul = ./workspace/SOUL.md;
  tools = ./workspace/TOOLS.md;
  identity = ./workspace/IDENTITY.md;
  user = ./workspace/USER.md;

  # Set a path only if HEARTBEAT.md should be Nix-managed.
  heartbeat = null;
};

programs.openclaw.workspace.files = {
  "LORE.md" = ./workspace/LORE.md;
  "PROMPTING-EXAMPLES.md" = ./workspace/PROMPTING-EXAMPLES.md;
};
```

File mapping:

| Old file | New declaration |
| --- | --- |
| `AGENTS.md` | `workspace.bootstrapFiles.agents` |
| `SOUL.md` | `workspace.bootstrapFiles.soul` |
| `TOOLS.md` | `workspace.bootstrapFiles.tools` |
| `IDENTITY.md` | `workspace.bootstrapFiles.identity` |
| `USER.md` | `workspace.bootstrapFiles.user` |
| `HEARTBEAT.md` | `workspace.bootstrapFiles.heartbeat` if Nix-managed |
| `LORE.md` | `workspace.files."LORE.md"` if Nix-managed |
| `PROMPTING-EXAMPLES.md` | `workspace.files."PROMPTING-EXAMPLES.md"` if Nix-managed |
| other companion docs | `workspace.files."<target path>"` if Nix-managed |
| `BOOTSTRAP.md` | runtime-owned; do not declare |
| `MEMORY.md` | runtime-owned; do not declare |
| `memory/` | runtime-owned; do not declare |

The old `documents` option required only `AGENTS.md`, `SOUL.md`, and
`TOOLS.md`. The new `workspace.bootstrapFiles` option requires `AGENTS.md`,
`SOUL.md`, `TOOLS.md`, `IDENTITY.md`, and `USER.md` when bootstrap files are
enabled.

Files from the old `documents` directory that are not re-declared under
`workspace.bootstrapFiles` or `workspace.files` intentionally stop being
managed by nix-openclaw.

#### OpenClaw Bootstrap Seeding Is Disabled For Nix-Managed Workspaces

When `workspace.bootstrapFiles` is set, nix-openclaw forces
`agents.defaults.skipBootstrap = true`. Config that tries to set it to `false`
now fails evaluation.

Before:

```nix
programs.openclaw.config.agents.defaults.skipBootstrap = false;
```

After:

```nix
# Omit this setting. nix-openclaw sets it to true when workspace bootstrap files
# are Nix-managed.
```

This prevents upstream OpenClaw from creating missing bootstrap files from
bundled templates in a declarative install. If runtime bootstrap seeding stayed
enabled, OpenClaw could create missing files such as `AGENTS.md`, `SOUL.md`, or
`USER.md` during first run, then a later Nix activation could replace some of
those files while leaving other runtime-created files behind. That recreates the
same unclear ownership model this migration removes.

#### Workspace File Ownership Is Explicit

`workspace.files` manages only extra files below the workspace. It rejects:

- bootstrap file targets such as `AGENTS.md`, `SOUL.md`, `TOOLS.md`,
  `IDENTITY.md`, `USER.md`, and `HEARTBEAT.md`
- runtime-owned targets such as `BOOTSTRAP.md`, `MEMORY.md`, `memory`, and
  `memory/...`
- absolute paths, parent-directory escapes, empty path segments, `.` or `..`
  path segments, trailing slashes, tabs, and newlines

If a deployment had separate `home.file` writers for files inside the same
OpenClaw workspace, migrate those files into `workspace.bootstrapFiles` or
`workspace.files` so there is one declarative owner.

Public and private modules can split ownership field-by-field. This lets a
public nix repo publish reusable default context while a private nix repo adds
`USER.md`, host-specific identity, or private companion files without copying
the public module or leaking private context:

```nix
# Public module.
programs.openclaw.workspace.bootstrapFiles = {
  agents = ./workspace/AGENTS.md;
  soul = ./workspace/SOUL.md;
  tools = ./workspace/TOOLS.md;
  identity = ./workspace/IDENTITY.md;
};

programs.openclaw.workspace.files."LORE.md" = ./workspace/LORE.md;

# Private module.
programs.openclaw.workspace.bootstrapFiles.user = ./workspace/USER.md;
```
