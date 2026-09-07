import assert from "node:assert/strict";
import childProcess from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

const scriptPath = path.join(
  path.dirname(fileURLToPath(import.meta.url)),
  "check-openclaw-npm-wrapper-lock.sh",
);

const sri = `sha512-${Buffer.alloc(64).toString("base64")}`;
const locked = (name, version, dependencies) => ({
  version,
  resolved: `https://registry.npmjs.org/${name}/-/${name}-${version}.tgz`,
  integrity: sri,
  ...(dependencies ? { dependencies } : {}),
});

function writeWrapper(packages) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "openclaw-npm-wrapper-lock-"));
  const root = {
    name: "nix-openclaw-openclaw-wrapper",
    version: "0.0.0",
    private: true,
    dependencies: { openclaw: "2.0.0" },
  };
  fs.writeFileSync(path.join(dir, "package.json"), `${JSON.stringify(root, null, 2)}\n`);
  fs.writeFileSync(
    path.join(dir, "package-lock.json"),
    `${JSON.stringify({
      name: root.name,
      version: root.version,
      lockfileVersion: 3,
      requires: true,
      packages: { "": root, ...packages },
    }, null, 2)}\n`,
  );
  return dir;
}

function runCheck(dir) {
  const before = fs.readFileSync(path.join(dir, "package-lock.json"), "utf8");
  const result = childProcess.spawnSync("sh", [scriptPath], {
    encoding: "utf8",
    env: {
      ...process.env,
      // npm ships beside the node binary running this test.
      PATH: `${path.dirname(process.execPath)}${path.delimiter}${process.env.PATH ?? ""}`,
      OPENCLAW_NPM_WRAPPER_DIR: dir,
    },
  });
  const after = fs.readFileSync(path.join(dir, "package-lock.json"), "utf8");
  fs.rmSync(dir, { recursive: true, force: true });
  assert.equal(after, before, "the check must never modify the wrapper lock");
  return result;
}

const openclaw = locked("openclaw", "2.0.0", { "p-limit": "^7.0.0", "p-locate": "^4.0.0" });
const pLocate = locked("p-locate", "4.0.0", { "p-limit": "^2.0.0" });

test("a lock that resolves every runtime dependency edge offline passes", () => {
  const result = runCheck(writeWrapper({
    "node_modules/openclaw": openclaw,
    "node_modules/p-limit": locked("p-limit", "7.3.1"),
    "node_modules/p-locate": pLocate,
    "node_modules/p-locate/node_modules/p-limit": locked("p-limit", "2.3.0"),
  }));
  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /openclaw npm wrapper lock: ok/);
});

test("a stale in-place update that mis-resolves a new direct dependency fails", () => {
  // Shape produced by `npm install --package-lock-only` over the previous
  // release's lock: the old nested transitive p-limit@2 stays under openclaw
  // and the hoisted p-limit@7 that the new release requires never appears, so
  // npm has to ask the registry for p-limit.
  const result = runCheck(writeWrapper({
    "node_modules/openclaw": openclaw,
    "node_modules/openclaw/node_modules/p-limit": locked("p-limit", "2.3.0"),
    "node_modules/p-locate": pLocate,
  }));
  assert.equal(result.status, 1);
  assert.match(result.stderr, /ENOTCACHED/);
  assert.match(result.stderr, /registry\.npmjs\.org\/p-limit/);
  assert.match(result.stderr, /cannot be resolved offline/);
});

test("a lock missing a runtime dependency entirely fails", () => {
  const result = runCheck(writeWrapper({
    "node_modules/openclaw": openclaw,
    "node_modules/p-limit": locked("p-limit", "7.3.1"),
  }));
  assert.equal(result.status, 1);
  assert.match(result.stderr, /ENOTCACHED/);
  assert.match(result.stderr, /registry\.npmjs\.org\/p-locate/);
});

test("a wrapper directory without a lock fails before invoking npm", () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "openclaw-npm-wrapper-lock-"));
  fs.writeFileSync(path.join(dir, "package.json"), "{}\n");
  const result = childProcess.spawnSync("sh", [scriptPath], {
    encoding: "utf8",
    env: { ...process.env, OPENCLAW_NPM_WRAPPER_DIR: dir },
  });
  fs.rmSync(dir, { recursive: true, force: true });
  assert.equal(result.status, 1);
  assert.match(result.stderr, /package-lock\.json missing/);
});
