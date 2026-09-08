import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import { spawnSync } from "node:child_process";
import { pathToFileURL } from "node:url";

const script = path.join(import.meta.dirname, "patch-openclaw-npm-dist.mjs");
const checker = path.join(import.meta.dirname, "check-package-contents.sh");
// Reduced executable boundaries from npm 2026.7.1-2 (0790d9f593ad30c940ed93b5872a8cf6d6f3cf8c)
// and 2026.9.3 (1391f7cd2d40ab5bbcf2f5f831d3a64f520e72d7). Policy/env bodies are unchanged.
function fixture(t, ext) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "openclaw-dist-patch-"));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const dist = path.join(root, "dist");
  fs.mkdirSync(dist);
  const put = (name, text) => fs.writeFileSync(path.join(dist, name), text);
  const old = ext === "js";
  const cacheArg = old ? ", realpathCache" : "";
  const paramsCache = old ? ", params.realpathCache" : "";
  const realpath = old ? "safeRealpathSync" : "pluginCacheRealpathSync";
  const dependency = `${old ? "path" : "plugin-cache-files"}-fixture.${ext}`;
  put(
    `paths-fixture.${ext}`,
    `function resolveIsNixMode(env = process.env) {
\treturn env.OPENCLAW_NIX_MODE === "1";
}
export { resolveIsNixMode as p };
`,
  );
  put(
    dependency,
    `import nativeFs from "node:fs";
import path from "node:path";
export const realpaths = new Map(), stats = new Map(), roots = new Map();
const resolve = target => realpaths.has(target) ? realpaths.get(target) : nativeFs.realpathSync(target);
const fs = { realpathSync: Object.assign(resolve, { native: resolve }) };
function getPluginCacheRoot(root) {
\tif (!roots.has(root)) roots.set(root, { paths: new Map() });
\treturn roots.get(root);
}
function pathFacts(targetPath) {
\tconst absolute = path.resolve(targetPath);
\tconst root = getPluginCacheRoot(path.dirname(absolute));
\tconst key = path.basename(absolute);
\tlet facts = root.paths.get(key);
\tif (!facts) {
\t\tfacts = {};
\t\troot.paths.set(key, facts);
\t}
\treturn facts;
}
${
  old
    ? `function safeRealpathSync(targetPath, cache) {
\tconst cached = cache?.get(targetPath);
\tif (cached) return cached;
\ttry {
\t\tconst resolved = fs.realpathSync(targetPath);
\t\tcache?.set(targetPath, resolved);
\t\tcache?.set(resolved, resolved);
\t\treturn resolved;
\t} catch {
\t\treturn null;
\t}
}`
    : `function pluginCacheRealpathSync(targetPath, native = false) {
\tconst facts = pathFacts(targetPath);
\tconst key = native ? "nativeRealpath" : "realpath";
\tif (facts[key] === void 0) try {
\t\tfacts[key] = native ? fs.realpathSync.native(targetPath) : fs.realpathSync(targetPath);
\t\tpathFacts(facts[key])[key] = facts[key];
\t} catch {
\t\tfacts[key] = null;
\t}
\treturn facts[key];
}`
}
function safeStatSync(target) {
\tif (stats.has(target)) return stats.get(target);
\ttry { return nativeFs.statSync(target); } catch { return null; }
}
export { ${realpath} as f, safeStatSync };
`,
  );
  const policy = `hardlink-policy-fixture.${ext}`;
  put(
    policy,
    `import { p as resolveIsNixMode } from "./paths-fixture.${ext}";
import { f as ${realpath} } from "./${dependency}";
import path from "node:path";
const NIX_STORE_ROOT = "/nix/store";
function isNixStorePluginRoot(rootDir${cacheArg}) {
\tconst rootRealPath = ${realpath}(rootDir${cacheArg}) ?? path.resolve(rootDir);
\treturn rootRealPath === NIX_STORE_ROOT || rootRealPath.startsWith(\`\${NIX_STORE_ROOT}/\`);
}
function shouldRejectHardlinkedPluginFiles(params) {
\tif (params.origin === "bundled") return false;
\tif (resolveIsNixMode(params.env) && isNixStorePluginRoot(params.rootDir${paramsCache})) return false;
\treturn true;
}
export { shouldRejectHardlinkedPluginFiles as t };
`,
  );
  const discovery = `discovery-fixture.${ext}`;
  put(
    discovery,
    `import { f as ${realpath}, safeStatSync } from "./${dependency}";
import { t as shouldRejectHardlinkedPluginFiles } from "./${policy}";
import fs from "node:fs";
import path from "node:path";
function checkSourceEscapesRoot(params) {
\tconst sourceRealPath = ${realpath}(params.source${paramsCache});
\tconst rootRealPath = ${realpath}(params.rootDir${paramsCache});
\tif (!sourceRealPath || !rootRealPath) return null;
\tconst relative = path.relative(rootRealPath, sourceRealPath);
\tif (!relative || (!relative.startsWith("..") && !path.isAbsolute(relative))) return null;
\treturn { reason: "source_escapes_root" };
}
function checkPathStatAndPermissions(params) {
\tif (process.platform === "win32") return null;
\tfor (const targetPath of new Set([params.rootDir, params.source])) {
\t\tlet stat = safeStatSync(targetPath);
\t\tif (!stat) return { reason: "path_stat_failed" };
\t\tlet modeBits = stat.mode & 511;
\t\tif ((modeBits & 2) !== 0 && params.origin === "bundled") try {
\t\t\tfs.chmodSync(targetPath, modeBits & -19);
\t\t\tstat = safeStatSync(targetPath);
\t\t\tif (!stat) return { reason: "path_stat_failed" };
\t\t\tmodeBits = stat.mode & 511;
\t\t} catch {}
\t\tif ((modeBits & 2) !== 0) return { reason: "path_world_writable" };
\t\tif (params.origin !== "bundled" && params.uid !== null && typeof stat.uid === "number" && stat.uid !== params.uid && stat.uid !== 0) return { reason: "path_suspicious_ownership" };
\t}
\treturn null;
}
function findCandidateBlockIssue(params) {
\treturn checkSourceEscapesRoot(params) ?? checkPathStatAndPermissions({
\t\tsource: params.source, rootDir: params.rootDir, origin: params.origin, uid: params.ownershipUid
\t});
}
export { checkPathStatAndPermissions, findCandidateBlockIssue };
`,
  );
  const install = `missing-configured-plugin-install-fixture.${ext}`;
  const loop = `\tfor (const candidate of collectDownloadableInstallCandidates({ cfg: params.cfg, env }))`;
  put(
    install,
    `export const effects = [];
const collectDownloadableInstallCandidates = (params) => params.cfg.candidates ?? [];
${
  old
    ? `function collectUpdateDeferredPluginIds(params) {
\tconst env = params.env ?? process.env, ids = [];
${loop} ids.push(candidate.id);
\treturn ids;
}
`
    : ""
}async function detectConfiguredPluginInstallHealthIssues(params) {
\tconst env = params.env ?? process.env, issues = [];
${loop} issues.push(candidate.id);
\treturn issues;
}
async function ${old ? "repairMissingPluginInstalls" : "repairMissingPluginInstallsWithLease"}(params) {
\tconst env = params.env ?? process.env;
\tif (params.recorded) effects.push("recorded-update");
${loop} effects.push(candidate.id);
\treturn 'Failed to install missing configured plugin "';
}
export { detectConfiguredPluginInstallHealthIssues as health, ${old ? "repairMissingPluginInstalls" : "repairMissingPluginInstallsWithLease"} as repair };
`,
  );
  fs.writeFileSync(path.join(root, "package.json"), '{"type":"module"}');
  return { root, dist, put, policy, discovery, install, dependency };
}
const run = (command, args, env) =>
  spawnSync(command, args, {
    encoding: "utf8",
    env: { ...process.env, PATH: `${path.dirname(process.execPath)}:${process.env.PATH}`, ...env },
  });
const patch = (f) => run(process.execPath, [script], { OPENCLAW_PACKAGE_ROOT: f.root });
const load = (f, name) => import(pathToFileURL(path.join(f.dist, name)).href);
function snapshot(f) {
  const files = fs.readdirSync(f.dist, { withFileTypes: true }).filter((entry) => entry.isFile());
  return files.map(({ name }) => [name, fs.readFileSync(path.join(f.dist, name), "utf8")]);
}
function change(f, name, from, to) {
  const old = fs.readFileSync(path.join(f.dist, name), "utf8");
  assert.ok(old.includes(from), from);
  f.put(name, old.replace(from, to));
}
const envFor = (mode) => ({ OPENCLAW_NIX_MODE: mode });
const paramsFor = (rootDir) => ({ rootDir, source: rootDir, origin: "config", uid: 100 });
function restoreEnv(t) {
  const previous = process.env.OPENCLAW_NIX_MODE;
  t.after(() => {
    if (previous === undefined) delete process.env.OPENCLAW_NIX_MODE;
    else process.env.OPENCLAW_NIX_MODE = previous;
  });
}
for (const ext of ["js", "mjs"]) {
  test(`${ext}: emitted ownership/policy preserve guards and env boundaries`, async (t) => {
    const f = fixture(t, ext),
      result = patch(f);
    assert.equal(result.status, 0, result.stderr);
    const facts = await load(f, f.dependency),
      policy = (await load(f, f.policy)).t;
    const { checkPathStatAndPermissions: check, findCandidateBlockIssue: discover } = await load(f, f.discovery);
    restoreEnv(t);
    for (const [rootDir, canonical, store] of [
      ["/nix/store", "/nix/store", true],
      ["/nix/store/pkg", "/nix/store/pkg", true],
      ["/nix/store-other/pkg", "/nix/store-other/pkg", false],
      ["/alias", "/nix/store/pkg", true],
      ["/nix/store/escape", "/ordinary", false],
    ]) {
      facts.realpaths.set(rootDir, canonical);
      facts.stats.set(rootDir, { mode: 0o755, uid: 200 });
      for (const ambient of ["0", "1"])
        for (const supplied of [undefined, {}, envFor("1"), envFor("true")]) {
          process.env.OPENCLAW_NIX_MODE = ambient;
          const nix = (supplied ?? process.env).OPENCLAW_NIX_MODE === "1";
          for (const origin of ["config", "global", "bundled"]) {
            const params = { ...paramsFor(rootDir), origin, env: supplied };
            const reject = origin !== "bundled" && !(nix && store);
            assert.equal(policy(params), reject);
            assert.equal(check(params)?.reason ?? null, reject ? "path_suspicious_ownership" : null);
            for (const uid of [null, 200]) assert.equal(check({ ...params, uid }), null);
          }
        }
    }
    process.env.OPENCLAW_NIX_MODE = "0";
    const params = { ...paramsFor("/nix/store/pkg"), ownershipUid: 100, env: envFor("1") };
    assert.equal(check(params), null);
    assert.equal(discover(params).reason, "path_suspicious_ownership"); // Existing caller-env loss is not repaired here.
    facts.stats.set(params.rootDir, { mode: 0o755, uid: 0 });
    assert.equal(check({ ...params, env: {} }), null);
    facts.stats.set(params.rootDir, { mode: 0o777, uid: 0 });
    assert.equal(check(params).reason, "path_world_writable");
    facts.stats.set(params.rootDir, null);
    assert.equal(check(params).reason, "path_stat_failed");
    // Existing lexical fallback is retained when realpath fails.
    assert.equal(policy({ ...params, rootDir: "/nix/store/nonexistent" }), false);
  });
  test(`${ext}: real filesystem escapes, permissions and hardlinks stay independent`, async (t) => {
    const f = fixture(t, ext);
    assert.equal(patch(f).status, 0);
    const dir = path.join(f.root, "plugin"),
      outside = path.join(f.root, "outside");
    fs.mkdirSync(dir);
    fs.writeFileSync(outside, "");
    const source = path.join(dir, "index.js");
    fs.symlinkSync(outside, source);
    const { findCandidateBlockIssue: check } = await load(f, f.discovery);
    const params = { ...paramsFor(dir), source, ownershipUid: process.getuid() };
    assert.equal(check(params).reason, "source_escapes_root");
    fs.unlinkSync(source);
    fs.linkSync(outside, source);
    const facts = await load(f, f.dependency);
    facts.roots.clear();
    assert.equal(check(params), null);
    assert.equal(fs.statSync(source).nlink, 2);
    assert.equal((await load(f, f.policy)).t(params), true);
    fs.chmodSync(source, 0o666);
    assert.equal(check(params).reason, "path_world_writable");
    fs.unlinkSync(source);
    facts.roots.clear();
    assert.equal(check(params).reason, "path_stat_failed");
  });
  test(`${ext}: candidate effects and existing diagnostic/recorded-repair limitations`, async (t) => {
    const f = fixture(t, ext);
    assert.equal(patch(f).status, 0);
    const module = await load(f, f.install),
      cfg = { candidates: [{ id: "candidate-install" }] };
    restoreEnv(t);
    for (const ambient of ["0", "1"])
      for (const mode of ["0", "1"]) {
        process.env.OPENCLAW_NIX_MODE = ambient;
        module.effects.length = 0;
        const params = { cfg, env: envFor(mode), recorded: true };
        await module.repair(params);
        const candidates = mode === "1" ? [] : ["candidate-install"];
        assert.deepEqual(module.effects, ["recorded-update", ...candidates]);
        assert.deepEqual(await module.health(params), candidates);
      }
    const before = snapshot(f),
      second = patch(f);
    assert.ok(second.status === 0 || second.status === 1);
    assert.deepEqual(snapshot(f), before);
  });
  const mutations = {
    "wrong-binding": ["discovery", "{ t as shouldReject", "{ x as shouldReject"],
    "comment-binding": ["discovery", "import { t as shouldReject", "// import { t as shouldReject"],
    "extra-exception": ["policy", "\treturn true;", "\tif (params.extra) return false;\n\treturn true;"],
    "return-newline": ["policy", "\treturn true;", "\treturn\n\ttrue;"],
    "store-prefix": ["policy", "${NIX_STORE_ROOT}/", "${NIX_STORE_ROOT}"],
    "cache-call": ["policy", "?? path.resolve(rootDir)", '?? "/nix/store"'],
    "cache-body": ["dependency", ext === "js" ? "return resolved;" : "return facts[key];", 'return "/nix/store";'],
    "env-contract": ["environment", '=== "1"', '!== "0"'],
    "late-loop": ["install", "HealthIssues", "UnrecognizedHealth"],
    "mixed-patched": ["install", "\tfor (const candidate", "\tif (true) for (const candidate"],
  };
  const missing = ["policy", "discovery", "install"].flatMap((role) => [`missing-${role}`, `duplicate-${role}`]);
  const ownerFaults = [...missing, ...Object.keys(mutations), "co-located"];
  for (const fault of [...ownerFaults, "nested-only", "symlink-only", "directory-only"]) {
    test(`${ext}: rejects ${fault} before any write`, (t) => {
      const f = fixture(t, ext);
      f.environment = `paths-fixture.${ext}`;
      const file = f[fault.split("-")[1]];
      if (fault.startsWith("missing-")) fs.unlinkSync(path.join(f.dist, file));
      else if (fault.startsWith("duplicate-"))
        fs.copyFileSync(path.join(f.dist, file), path.join(f.dist, `duplicate-${file}`));
      else if (fault === "co-located") {
        fs.appendFileSync(path.join(f.dist, f.discovery), fs.readFileSync(path.join(f.dist, f.install)));
        fs.unlinkSync(path.join(f.dist, f.install));
      } else if (mutations[fault]) {
        const [role, from, to] = mutations[fault];
        change(f, f[role], from, to);
      } else {
        const bytes = fs.readFileSync(path.join(f.dist, f.policy));
        fs.unlinkSync(path.join(f.dist, f.policy));
        fs.mkdirSync(path.join(f.dist, "worker"));
        fs.writeFileSync(path.join(f.dist, "worker", "worker.mjs"), bytes);
        if (fault === "symlink-only") fs.symlinkSync(path.join("worker", "worker.mjs"), path.join(f.dist, f.policy));
        if (fault === "directory-only") fs.mkdirSync(path.join(f.dist, f.policy));
      }
      const before = snapshot(f),
        result = patch(f);
      assert.equal(result.status, 1, `${fault}: ${result.stderr}`);
      assert.deepEqual(snapshot(f), before);
    });
  }
}
function packageFixture(t, ext) {
  const f = fixture(t, ext),
    gateway = path.join(f.root, "gateway"),
    root = path.join(gateway, "lib/openclaw");
  const put = (name, text = "") => {
    fs.mkdirSync(path.dirname(path.join(root, name)), { recursive: true });
    fs.writeFileSync(path.join(root, name), text);
  };
  const entrypoints = ["index.js", "register.runtime.js", "runtime-api.js", "setup-api.js"];
  const acpx = ["openclaw.plugin.json", "package.json", ...entrypoints, "skills/acp-router/SKILL.md"];
  const required = [
    "extensions/memory-core/openclaw.plugin.json",
    "dist/extensions/memory-core/openclaw.plugin.json",
    "dist-runtime/extensions/memory-core/openclaw.plugin.json",
    ...acpx.map((name) => `dist-runtime/extensions/acpx/${name}`),
    ...["AGENTS.md", "SOUL.md", "TOOLS.md"].map((name) => `docs/reference/templates/${name}`),
    "src/agents/templates/HEARTBEAT.md",
    "skills/example/SKILL.md",
    "node_modules/placeholder",
    "dist/target.js",
  ];
  for (const name of required) put(name);
  put("package.json", '{"type":"module"}');
  put("dist/runtime-model-auth.runtime.js", 'export * from "./target.js";\n');
  put(
    "dist/provider-policy-api.cjs",
    'require("node:fs").writeFileSync(require("node:path").join(__dirname, "loaded"), "public artifact loaded"); module.exports = {};\n',
  );
  const loader = path.join(root, `dist/public-surface-loader-fixture.${ext}`);
  fs.writeFileSync(
    loader,
    `import { createRequire } from "node:module";
const require = createRequire(import.meta.url);
function loadBundledPluginPublicArtifactModuleSync(params) {
${ext === "mjs" ? '\tfor (const name of params.artifactCandidates) if (name === "provider-policy-api.js") return require("./provider-policy-api.cjs");' : '\tif (params.artifactBasename === "provider-policy-api.js") return require("./provider-policy-api.cjs");'}
}
export { loadBundledPluginPublicArtifactModuleSync as ${ext === "mjs" ? "t" : "loadBundledPluginPublicArtifactModuleSync"} };
`,
  );
  return { root, loader, put, run: () => run("sh", [checker], { OPENCLAW_GATEWAY: gateway }) };
}
const loaderFaults = ["none", "missing", "duplicate", "worker-only", "symlink-only"];
const contentFaults = ["reject-hardlinks", "missing-path", "broken-alias", "empty-artifact"];
for (const ext of ["js", "mjs"])
  for (const fault of [...loaderFaults, ...contentFaults]) {
    test(`package checker ${ext}: ${fault}`, (t) => {
      const f = packageFixture(t, ext);
      if (fault === "missing") fs.unlinkSync(f.loader);
      if (fault === "duplicate") fs.copyFileSync(f.loader, path.join(path.dirname(f.loader), `another.${ext}`));
      if (fault === "worker-only" || fault === "symlink-only") {
        fs.mkdirSync(path.join(f.root, "dist/worker"));
        fs.renameSync(f.loader, path.join(f.root, "dist/worker/worker.mjs"));
        if (fault === "symlink-only") fs.symlinkSync("worker/worker.mjs", f.loader);
      }
      if (fault === "reject-hardlinks") fs.appendFileSync(f.loader, "\n// rejectHardlinks: true\n");
      if (fault === "missing-path") fs.unlinkSync(path.join(f.root, "dist-runtime/extensions/acpx/setup-api.js"));
      if (fault === "broken-alias") fs.unlinkSync(path.join(f.root, "dist/target.js"));
      if (fault === "empty-artifact") f.put("dist/provider-policy-api.cjs", "module.exports = null;\n");
      const result = f.run();
      assert.equal(result.status === 0, fault === "none", result.stderr);
      if (fault === "none")
        assert.equal(fs.readFileSync(path.join(f.root, "dist/loaded"), "utf8"), "public artifact loaded");
    });
  }
