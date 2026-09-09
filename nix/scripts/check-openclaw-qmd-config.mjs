import assert from "node:assert/strict";
import fs from "node:fs";
import { spawnSync } from "node:child_process";

const openclaw = process.argv[2];
const configPath = process.env.OPENCLAW_CONFIG_PATH;
const capability = process.env.OPENCLAW_QMD_BACKEND_SUPPORTED;
assert.ok(openclaw && configPath, "OpenClaw executable and config path are required");
assert.ok(["true", "false"].includes(capability), "QMD capability must come from the generated schema");

function run(args, status) {
  const result = spawnSync(openclaw, ["config", ...args, "--json"], { encoding: "utf8" });
  assert.equal(result.status, status, `${args.join(" ")}: ${result.stderr}\n${result.stdout}`);
  return JSON.parse(result.stdout);
}

function checkConfig(memory, valid, issuePath, key) {
  const authored = `${JSON.stringify({ gateway: { mode: "local" }, memory }, null, 2)}\n`;
  fs.writeFileSync(configPath, authored);
  const validation = run(["validate"], valid ? 0 : 1);
  assert.equal(validation.valid, valid);
  assert.equal(validation.path, configPath);
  if (!valid) {
    assert.ok(Array.isArray(validation.issues) && validation.issues.length > 0,
      "Retired QMD rejection must include structured issues, not a generic exception");
    assert.ok(validation.issues.every((issue) =>
      issue.path === issuePath && (
        issue.message === `Unrecognized key: "${key}"` ||
        issue.message === `must not have additional properties: "${key}"`
      )), `Unexpected QMD rejection: ${JSON.stringify(validation.issues)}`);
  }
  if (valid && memory.backend === "qmd") {
    assert.equal(run(["get", "memory.backend"], 0), "qmd");
  }
  assert.equal(fs.readFileSync(configPath, "utf8"), authored, "Config reads mutated authored JSON");
}

checkConfig({ citations: "off" }, true);
checkConfig({ backend: "qmd" }, capability === "true", "memory", "backend");
if (capability === "false") {
  checkConfig({ qmd: {} }, false, "memory", "qmd");
  checkConfig({ search: { qmd: {} } }, false, "memory.search", "qmd");
}
console.log(`openclaw QMD config: ${capability === "true" ? "legacy opt-in" : "retirement"} ok`);
