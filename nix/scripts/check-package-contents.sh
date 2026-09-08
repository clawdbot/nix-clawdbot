#!/bin/sh
set -eu

if [ -z "${OPENCLAW_GATEWAY:-}" ]; then
  echo "OPENCLAW_GATEWAY is not set" >&2
  exit 1
fi

root="${OPENCLAW_GATEWAY}/lib/openclaw"

require_path() {
  if [ ! -e "$1" ]; then
    echo "Missing: $1" >&2
    exit 1
  fi
}

require_path "${root}/extensions"
require_path "${root}/extensions/memory-core"
require_path "${root}/extensions/memory-core/openclaw.plugin.json"
require_path "${root}/dist/extensions/memory-core/openclaw.plugin.json"
require_path "${root}/dist-runtime/extensions"
require_path "${root}/dist-runtime/extensions/memory-core/openclaw.plugin.json"
require_path "${root}/dist-runtime/extensions/acpx/openclaw.plugin.json"
require_path "${root}/dist-runtime/extensions/acpx/package.json"
require_path "${root}/dist-runtime/extensions/acpx/index.js"
require_path "${root}/dist-runtime/extensions/acpx/register.runtime.js"
require_path "${root}/dist-runtime/extensions/acpx/runtime-api.js"
require_path "${root}/dist-runtime/extensions/acpx/setup-api.js"
require_path "${root}/dist-runtime/extensions/acpx/skills/acp-router/SKILL.md"
require_path "${root}/docs/reference/templates"
require_path "${root}/docs/reference/templates/AGENTS.md"
require_path "${root}/docs/reference/templates/SOUL.md"
require_path "${root}/docs/reference/templates/TOOLS.md"
require_path "${root}/src/agents/templates/HEARTBEAT.md"
require_path "${root}/skills"
if find "${root}/node_modules" -path "*/form-data/package.json" -type f -print | grep -q .; then
  require_path "${root}/node_modules/hasown"
  require_path "${root}/node_modules/combined-stream"
fi

node --input-type=module <<'NODE'
import fs from "node:fs";
import path from "node:path";
import { pathToFileURL } from "node:url";

const dist = path.join(process.env.OPENCLAW_GATEWAY, "lib/openclaw/dist");
const loaders = fs.readdirSync(dist, { withFileTypes: true })
  .filter((entry) => entry.isFile() && /\.m?js$/.test(entry.name))
  .map((entry) => path.join(dist, entry.name))
  .filter((file) => fs.readFileSync(file, "utf8").includes("function loadBundledPluginPublicArtifactModuleSync"));
if (loaders.length !== 1) {
  throw new Error(`Expected exactly one root bundled plugin public surface loader, found ${loaders.length}`);
}
const [loaderPath] = loaders;
if (fs.readFileSync(loaderPath, "utf8").includes("rejectHardlinks: true")) {
  throw new Error("Bundled plugin public surface loader still rejects hardlinked package files");
}

const loader = await import(pathToFileURL(loaderPath).href);
const loadBundledPluginPublicArtifactModuleSync =
  loader.loadBundledPluginPublicArtifactModuleSync;
const loadBundledPluginPublicArtifactModuleFromCandidatesSync =
  loader.loadBundledPluginPublicArtifactModuleFromCandidatesSync;
const minifiedLoader = loader.t;

if (
  typeof loadBundledPluginPublicArtifactModuleSync !== "function" &&
  typeof loadBundledPluginPublicArtifactModuleFromCandidatesSync !== "function" &&
  typeof minifiedLoader !== "function"
) {
  throw new Error("Bundled plugin public surface loader export not found");
}

const loadSingleParams = {
  dirName: "openai",
  artifactBasename: "provider-policy-api.js",
};
const loadCandidateParams = {
  dirName: "openai",
  artifactCandidates: ["provider-policy-api.js"],
};

function loadPublicArtifact() {
  if (typeof loadBundledPluginPublicArtifactModuleSync === "function") {
    return loadBundledPluginPublicArtifactModuleSync(loadSingleParams);
  }
  if (typeof loadBundledPluginPublicArtifactModuleFromCandidatesSync === "function") {
    return loadBundledPluginPublicArtifactModuleFromCandidatesSync(loadCandidateParams);
  }
  try {
    return minifiedLoader(loadSingleParams);
  } catch (error) {
    if (
      error instanceof TypeError &&
      String(error.message).includes("artifactCandidates is not iterable")
    ) {
      return minifiedLoader(loadCandidateParams);
    }
    throw error;
  }
}

if (!loadPublicArtifact()) {
  throw new Error("Bundled OpenAI provider policy artifact did not load");
}
NODE

require_js_alias_target() {
  alias="$1"
  alias_path="${root}/dist/${alias}"
  require_path "$alias_path"

  target="$(sed -n 's/^export \* from "\.\/\(.*\)";$/\1/p' "$alias_path" | head -1)"
  if [ -z "$target" ]; then
    echo "Alias has no export target: $alias_path" >&2
    exit 1
  fi
  require_path "${root}/dist/${target}"
}

require_js_alias_target "runtime-model-auth.runtime.js"

if ! find "${root}/skills" -name SKILL.md -type f | grep -q .; then
  echo "Missing bundled SKILL.md files under ${root}/skills" >&2
  exit 1
fi

echo "openclaw package contents: ok"
