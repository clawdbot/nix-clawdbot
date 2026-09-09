import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";

const installer = path.join(import.meta.dirname, "openclaw-gateway-npm-install.sh");
const checker = path.join(import.meta.dirname, "check-package-contents.sh");
const pluginInstaller = path.join(import.meta.dirname, "openclaw-runtime-plugin-install.mjs");
const legacyNames = ["hasown", "combined-stream"];

function put(root, name, text = "") {
  const file = path.join(root, name);
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, text);
  return file;
}

function dependency(modules, name, marker, code) {
  const root = path.join(modules, name);
  put(root, "package.json", JSON.stringify({ name, version: `${marker}.0.0`, type: "commonjs", main: "index.cjs" }));
  put(root, "index.cjs", code ?? `module.exports = { marker: ${marker}, file: __filename };\n`);
  return root;
}

function fixture(t, layout = "mixed") {
  const temp = fs.realpathSync(fs.mkdtempSync(path.join(os.tmpdir(), "openclaw-npm-output-")));
  t.after(() => fs.rmSync(temp, { recursive: true, force: true }));
  const build = path.join(temp, "build");
  const modules = path.join(build, "node_modules");
  const packageRoot = path.join(modules, "openclaw");
  const out = path.join(temp, "out");
  const root = path.join(out, "lib/openclaw");
  const away = path.join(temp, "away");
  const home = path.join(temp, "home");
  const acpx = path.join(temp, "acpx");
  for (const dir of [packageRoot, away, home, acpx]) fs.mkdirSync(dir, { recursive: true });
  const localModules = path.join(packageRoot, "node_modules");
  if (layout !== "hoisted") fs.mkdirSync(localModules);
  const graph = layout === "nested" ? localModules : modules;
  const limit = dependency(graph, "p-limit", 7);
  const locate = dependency(graph, "p-locate", 4, 'module.exports = require("p-limit");\n');
  dependency(path.join(locate, "node_modules"), "p-limit", 2);
  dependency(graph, "@fixture/scoped", 3);
  put(
    packageRoot,
    "package.json",
    JSON.stringify({
      name: "openclaw",
      version: "1.0.0",
      type: "module",
      files: ["dist/", "docs/", "skills/"],
      dependencies: { "p-limit": "^7.0.0", "p-locate": "^4.0.0", "@fixture/scoped": "3.0.0" },
      optionalDependencies: { "omitted-platform-addon": "1.0.0" },
    }),
  );
  put(
    packageRoot,
    "dist/index.js",
    `
import limit from "p-limit";
import locate from "p-locate";
import scoped from "@fixture/scoped";
import { createRequire } from "node:module";
const require = createRequire(import.meta.url);
console.log(JSON.stringify({ direct: limit, nested: locate, scoped,
  cjs: require("p-limit"), locatePath: require.resolve("p-locate"), entry: import.meta.filename }));
`,
  );
  put(packageRoot, "dist/extensions/memory-core/openclaw.plugin.json", '{"id":"memory-core"}');
  for (const name of ["AGENTS", "SOUL", "IDENTITY", "USER", "BOOTSTRAP", "TOOLS"])
    put(packageRoot, `docs/reference/templates/${name}.md`, name);
  put(packageRoot, "skills/fixture/SKILL.md", "# Fixture");
  put(packageRoot, "dist/target.js", "export {};\n");
  put(packageRoot, "dist/runtime-model-auth.runtime.js", 'export * from "./target.js";\n');
  put(
    packageRoot,
    "dist/public-surface-loader-fixture.mjs",
    `
function loadBundledPluginPublicArtifactModuleSync() { return { fixture: true }; }
export { loadBundledPluginPublicArtifactModuleSync };
`,
  );
  for (const name of [
    "openclaw.plugin.json",
    "package.json",
    "index.js",
    "register.runtime.js",
    "runtime-api.js",
    "setup-api.js",
    "skills/acp-router/SKILL.md",
  ])
    put(acpx, name, "fixture");
  put(modules, ".fixture-marker", "retained");
  const bin = put(limit, "bin/marker", "#!/bin/sh\nexit 0\n");
  fs.chmodSync(bin, 0o755);
  fs.mkdirSync(path.join(modules, ".bin"));
  fs.symlinkSync(path.relative(path.join(modules, ".bin"), bin), path.join(modules, ".bin/marker"));
  const setup = put(temp, "setup.sh", 'makeWrapper() { printf "%s\\n" "$@" > "$out/wrapper-args"; }\n');
  const patcher = put(
    temp,
    "patch.mjs",
    `
import fs from "node:fs";
import path from "node:path";
fs.writeFileSync(path.join(process.env.OPENCLAW_PACKAGE_ROOT, "patch-seen"), "patched");
`,
  );
  const env = {
    PATH: `${path.dirname(process.execPath)}:${process.env.PATH ?? ""}`,
    HOME: home,
    TMPDIR: home,
    LANG: "C.UTF-8",
  };
  const run = (command, args, options = {}) =>
    spawnSync(command, args, {
      cwd: away,
      env,
      encoding: "utf8",
      timeout: 15000,
      ...options,
    });
  return {
    temp,
    build,
    modules,
    packageRoot,
    out,
    root,
    acpx,
    env,
    run,
    install: () =>
      run("sh", [installer], {
        cwd: build,
        env: {
          ...env,
          out,
          NODE_BIN: process.execPath,
          STDENV_SETUP: setup,
          OPENCLAW_NPM_PACKAGE_ROOT: "node_modules/openclaw",
          OPENCLAW_PATCH_NPM_DIST_SCRIPT: patcher,
          OPENCLAW_BUNDLED_ACPX: acpx,
        },
      }),
    removeBuild: () => fs.rmSync(build, { recursive: true, force: true }),
    check: () => run("sh", [checker], { env: { ...env, OPENCLAW_GATEWAY: out } }),
  };
}

function install(f) {
  const result = f.install();
  assert.equal(result.status, 0, result.stdout + result.stderr);
  assert.match(result.stdout, /openclaw npm install: wrap openclaw/);
  f.removeBuild();
  assert.equal(fs.existsSync(f.build), false);
}

function resolveFrom(f, owner, names) {
  return f.run(process.execPath, [
    "--input-type=module",
    "-e",
    `
import { createRequire } from "node:module";
const require = createRequire(process.argv[1]);
console.log(JSON.stringify(JSON.parse(process.argv[2]).map(name => require(name))));
`,
    owner,
    JSON.stringify(names),
  ]);
}

for (const layout of ["mixed", "nested", "hoisted"]) {
  test(`${layout}: output retains ESM and CJS dependency versions after build removal`, (t) => {
    const f = fixture(t, layout);
    install(f);
    t.diagnostic("installer exit=0; build input removed; fresh output-only execution");
    const result = f.run(process.execPath, [path.join(f.root, "dist/index.js")]);
    assert.equal(result.status, 0, result.stderr);
    const loaded = JSON.parse(result.stdout);
    assert.deepEqual(
      [loaded.direct.marker, loaded.nested.marker, loaded.scoped.marker, loaded.cjs.marker],
      [7, 2, 3, 7],
    );
    for (const file of [
      loaded.direct.file,
      loaded.nested.file,
      loaded.scoped.file,
      loaded.cjs.file,
      loaded.locatePath,
      loaded.entry,
    ])
      assert.ok(file.startsWith(`${f.out}/lib/node_modules/`), file);
    assert.equal(fs.readlinkSync(f.root), "node_modules/openclaw");
    assert.equal(fs.realpathSync(f.root), path.join(f.out, "lib/node_modules/openclaw"));
    assert.equal(fs.readFileSync(path.join(f.root, "patch-seen"), "utf8"), "patched");
    assert.equal(fs.readFileSync(path.join(f.out, "lib/node_modules/.fixture-marker"), "utf8"), "retained");
    assert.equal(fs.statSync(path.join(f.out, "lib/node_modules/.bin/marker")).mode & 0o777, 0o755);
    assert.equal(fs.existsSync(path.join(f.out, "lib/node_modules/omitted-platform-addon")), false);
    assert.equal(fs.existsSync(path.join(f.root, "node_modules")), layout !== "hoisted");
    for (const rel of [
      "extensions/memory-core/openclaw.plugin.json",
      "dist-runtime/extensions/memory-core/openclaw.plugin.json",
    ])
      assert.equal(fs.readFileSync(path.join(f.root, rel), "utf8"), '{"id":"memory-core"}');
    assert.equal(fs.readlinkSync(path.join(f.root, "dist-runtime/extensions/acpx")), f.acpx);
    assert.deepEqual(fs.readFileSync(path.join(f.out, "wrapper-args"), "utf8").trim().split("\n"), [
      process.execPath,
      path.join(f.out, "bin/openclaw"),
      "--add-flags",
      path.join(f.root, "dist/index.js"),
      "--prefix",
      "PATH",
      ":",
      path.dirname(process.execPath),
      "--set-default",
      "OPENCLAW_NIX_MODE",
      "1",
      "--set-default",
      "OPENCLAW_DISABLE_PERSISTED_PLUGIN_REGISTRY",
      "1",
    ]);
  });
}

test("dangling hoisted sibling links are rejected before wrapping", (t) => {
  const f = fixture(t);
  fs.symlinkSync("absent", path.join(f.modules, "p-limit/broken"));
  const result = f.install();
  assert.equal(result.status, 1, result.stdout + result.stderr);
  assert.match(result.stderr, /dangling symlinks found/);
  assert.match(result.stderr, /p-limit\/broken/);
  assert.equal(fs.existsSync(path.join(f.out, "wrapper-args")), false);
});

for (const placement of ["local", "hoisted", "nested-only"]) {
  test(`legacy dependency aliases preserve ${placement} resolution`, (t) => {
    const f = fixture(t);
    for (const name of legacyNames) {
      dependency(path.join(f.packageRoot, "node_modules/deep/node_modules"), name, 2);
      if (placement !== "nested-only") dependency(f.modules, name, 7);
      if (placement === "local") dependency(path.join(f.packageRoot, "node_modules"), name, 1);
    }
    install(f);
    const result = resolveFrom(f, path.join(fs.realpathSync(f.root), "package.json"), legacyNames);
    assert.equal(result.status, 0, result.stderr);
    const resolved = JSON.parse(result.stdout);
    assert.deepEqual(
      resolved.map((item) => item.marker),
      legacyNames.map(() => ({ local: 1, hoisted: 7, "nested-only": 2 })[placement]),
    );
    for (const item of resolved) assert.ok(item.file.startsWith(`${f.out}/`), item.file);
  });
}

for (const layout of ["npm", "source"])
  for (const missing of [null, ...legacyNames]) {
    test(`${layout} form-data resolves its own dependencies: ${missing ?? "conflicting versions"}`, (t) => {
      const f = fixture(t, layout === "source" ? "nested" : "mixed");
      const local = path.join(f.packageRoot, "node_modules");
      const form = dependency(
        layout === "source" ? local : f.modules,
        "form-data",
        4,
        'module.exports = ["hasown", "combined-stream"].map(name => require(name));\n',
      );
      for (const name of legacyNames) {
        dependency(path.join(form, "node_modules"), name, 2);
        dependency(local, name, 7);
      }
      if (missing) {
        fs.rmSync(path.join(form, "node_modules", missing), { recursive: true });
        if (layout === "source") fs.rmSync(path.join(local, missing), { recursive: true });
      }
      install(f);
      if (layout === "source") {
        const physical = fs.realpathSync(f.root);
        fs.unlinkSync(f.root);
        fs.renameSync(physical, f.root);
        fs.rmSync(path.join(f.out, "lib/node_modules"), { recursive: true });
      }
      const result = f.check();
      assert.equal(result.status, missing ? 1 : 0, result.stdout + result.stderr);
      if (missing) assert.ok(result.stderr.includes(missing), result.stderr);
      else {
        assert.match(result.stdout, /openclaw package contents: ok/);
        const modules = layout === "source" ? path.join(f.root, "node_modules") : path.join(f.out, "lib/node_modules");
        const loaded = resolveFrom(f, path.join(modules, "form-data/package.json"), legacyNames);
        assert.equal(loaded.status, 0, loaded.stderr);
        assert.deepEqual(
          JSON.parse(loaded.stdout).map((item) => item.marker),
          [2, 2],
        );
      }
    });
  }

test("hoisted form-data is checked without package-local node_modules", (t) => {
  const f = fixture(t, "hoisted");
  const form = dependency(f.modules, "form-data", 4);
  dependency(path.join(form, "node_modules"), "combined-stream", 2);
  install(f);
  assert.equal(fs.existsSync(path.join(f.root, "node_modules")), false);
  const result = f.check();
  assert.equal(result.status, 1, result.stdout + result.stderr);
  assert.match(result.stderr, /Cannot find module 'hasown'/);
});

test("runtime plugin peer validation accepts the internal package alias", (t) => {
  const f = fixture(t);
  install(f);
  const plugin = path.join(f.temp, "plugin");
  const peerOut = path.join(f.temp, "plugin-out");
  put(
    plugin,
    "package.json",
    JSON.stringify({
      name: "@fixture/peer",
      version: "1.0.0",
      peerDependencies: { openclaw: "*" },
      openclaw: { runtimeExtensions: ["dist/index.js"] },
    }),
  );
  put(plugin, "openclaw.plugin.json", '{"id":"peer-fixture"}');
  put(plugin, "dist/index.js", "export default {};\n");
  const entries = put(f.temp, "runtime-entries", "dist/index.js\n");
  const bundled = put(f.temp, "bundled-roots");
  const result = f.run(process.execPath, [pluginInstaller], {
    cwd: plugin,
    env: {
      ...f.env,
      out: peerOut,
      OPENCLAW_GATEWAY_PACKAGE: f.out,
      OPENCLAW_RUNTIME_PLUGIN_ID: "peer-fixture",
      OPENCLAW_RUNTIME_PLUGIN_DEPENDENCY_MODE: "none",
      OPENCLAW_RUNTIME_PLUGIN_RUNTIME_ENTRIES_FILE: entries,
      OPENCLAW_RUNTIME_PLUGIN_BUNDLED_PACKAGE_ROOTS_FILE: bundled,
    },
  });
  assert.equal(result.status, 0, result.stdout + result.stderr);
  assert.equal(fs.realpathSync(path.join(peerOut, "node_modules/openclaw")), fs.realpathSync(f.root));
});
