#!/usr/bin/env node
import childProcess from "node:child_process";
import crypto from "node:crypto";
import fs from "node:fs";
import https from "node:https";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

import {
  createNpmPackageLockMaterializer, renderPackageLockProbeEnv,
} from "./openclaw-runtime-plugin-package-locks.mjs";
import {
  defaultCatalogVersion,
  resolveRuntimePluginVersion,
} from "./openclaw-runtime-plugin-version.mjs";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(scriptDir, "../..");
const sourceInfoPath = path.join(repoRoot, "nix/sources/openclaw-source.nix");
const outputDir = path.join(repoRoot, "nix/generated/openclaw-runtime-plugins");
const defaultOutputPath = path.join(outputDir, "default.nix");
const reportOutputPath = path.join(outputDir, "report.json");
const prepareNpmScriptPath = path.join(scriptDir, "openclaw-runtime-plugin-prepare-npm.mjs");
const checkMode = process.argv.includes("--check");
const fetchJsonTimeoutMs = 30_000;
let prefetchNpmDepsBin = null;

const catalogFiles = [
  "official-external-channel-catalog.json",
  "official-external-plugin-catalog.json",
  "official-external-provider-catalog.json",
];

function run(command, args, options = {}) {
  const result = childProcess.spawnSync(command, args, {
    encoding: "utf8",
    maxBuffer: 128 * 1024 * 1024,
    stdio: ["ignore", "pipe", "pipe"],
    ...options,
  });
  if (result.status !== 0) {
    throw new Error(`${command} ${args.join(" ")} failed:\n${result.stderr || result.stdout}`);
  }
  return result.stdout;
}

function sleepMs(milliseconds) {
  Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, milliseconds);
}

function runWithRetries(command, args, options = {}) {
  const attempts = options.attempts ?? 3;
  const retryDelayMs = options.retryDelayMs ?? 1000;
  let lastError = null;
  for (let attempt = 1; attempt <= attempts; attempt += 1) {
    try {
      return run(command, args, options.runOptions ?? {});
    } catch (error) {
      lastError = error;
      if (attempt < attempts) {
        sleepMs(retryDelayMs * attempt);
      }
    }
  }
  throw lastError;
}

function fetchJson(url) {
  return new Promise((resolve, reject) => {
    const request = https
      .get(url, { headers: { Accept: "application/json" } }, (response) => {
        if (
          response.statusCode >= 300
          && response.statusCode < 400
          && response.headers.location
        ) {
          response.resume();
          fetchJson(response.headers.location).then(resolve, reject);
          return;
        }
        if (response.statusCode !== 200) {
          reject(new Error(`GET ${url} failed with HTTP ${response.statusCode}`));
          response.resume();
          return;
        }
        let body = "";
        response.setEncoding("utf8");
        response.on("data", (chunk) => {
          body += chunk;
        });
        response.on("end", () => {
          try {
            resolve(JSON.parse(body));
          } catch (error) {
            reject(error);
          }
        });
      })
      .on("error", reject);
    request.setTimeout(fetchJsonTimeoutMs, () => {
      request.destroy(new Error(`GET ${url} timed out after ${fetchJsonTimeoutMs}ms`));
    });
  });
}

async function fetchJsonWithRetries(url, options = {}) {
  const attempts = options.attempts ?? 3;
  const retryDelayMs = options.retryDelayMs ?? 1000;
  let lastError = null;
  for (let attempt = 1; attempt <= attempts; attempt += 1) {
    try {
      return await fetchJson(url);
    } catch (error) {
      lastError = error;
      if (attempt < attempts) {
        sleepMs(retryDelayMs * attempt);
      }
    }
  }
  throw lastError;
}

function readSourceField(field) {
  const sourceInfo = fs.readFileSync(sourceInfoPath, "utf8");
  const match = sourceInfo.match(new RegExp(`${field} = "([^"]+)";`));
  if (!match) {
    throw new Error(`Could not read ${field} from ${sourceInfoPath}`);
  }
  return match[1];
}

function nixString(value) {
  return JSON.stringify(value);
}

function nixAttrName(name) {
  return /^[A-Za-z_][A-Za-z0-9_'-]*$/.test(name) ? name : nixString(name);
}

function toNix(value, indent = "") {
  const nextIndent = `${indent}  `;
  if (value === null) {
    return "null";
  }
  if (typeof value === "string") {
    return nixString(value);
  }
  if (typeof value === "number" || typeof value === "boolean") {
    return String(value);
  }
  if (Array.isArray(value)) {
    if (value.length === 0) {
      return "[ ]";
    }
    return `[\n${value.map((item) => `${nextIndent}${toNix(item, nextIndent)}`).join("\n")}\n${indent}]`;
  }
  if (typeof value === "object") {
    const entries = Object.entries(value);
    if (entries.length === 0) {
      return "{ }";
    }
    return `{\n${entries
      .map(([key, item]) => `${nextIndent}${nixAttrName(key)} = ${toNix(item, nextIndent)};`)
      .join("\n")}\n${indent}}`;
  }
  throw new Error(`Unsupported Nix value: ${value}`);
}

function resolveOpenClawSourcePath() {
  const strippedAttrs = [
    "pnpmDepsHash",
    "gatewayNpmDepsHash",
    "pnpmMajor",
    "releaseTag",
    "releaseVersion",
    "runtimePluginVersion",
    "applyPublicSurfaceHardlinksPatch",
    "applySkipPluginAutoEnableNixModePatch",
    "applyNixStorePluginOwnershipPatch",
    "publicSurfaceHardlinksPatch",
    "fsSafeSource",
  ];
  const expr = `
    let
      flake = builtins.getFlake (toString ${repoRoot});
      pkgs = import flake.inputs.nixpkgs { system = builtins.currentSystem; };
      sourceInfo = import ${sourceInfoPath};
      sourceFetch = builtins.removeAttrs sourceInfo ${toNix(strippedAttrs)};
    in
      pkgs.fetchFromGitHub sourceFetch
  `;
  return run("nix", [
    "build",
    "--no-link",
    "--print-out-paths",
    "--impure",
    "--expr",
    expr,
  ]).trim().split(/\r?\n/).pop();
}

function npmRegistryUrl(packageName) {
  return `https://registry.npmjs.org/${encodeURIComponent(packageName)}`;
}

function pickDefined(object) {
  return Object.fromEntries(Object.entries(object).filter(([, value]) => value !== undefined));
}

function sortedObject(object = {}) {
  return Object.fromEntries(Object.entries(object).sort(([a], [b]) => a.localeCompare(b)));
}

function stableJson(value) {
  return `${JSON.stringify(value, null, 2)}\n`;
}

function isRecord(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function optionalString(value) {
  return typeof value === "string" && value.trim() ? value.trim() : undefined;
}

function parseVersion(value) {
  const match = optionalString(value)?.match(/^v?(\d+)\.(\d+)\.(\d+)(?:[-+].*)?$/);
  if (!match) {
    return null;
  }
  return match.slice(1).map((part) => Number.parseInt(part, 10));
}

function compareVersions(left, right) {
  const a = parseVersion(left);
  const b = parseVersion(right);
  if (!a || !b) {
    return null;
  }
  for (let index = 0; index < 3; index += 1) {
    if (a[index] !== b[index]) {
      return a[index] < b[index] ? -1 : 1;
    }
  }
  return 0;
}

function satisfiesVersionRange(version, range) {
  const parts = optionalString(range)?.split(/\s+/).filter(Boolean) ?? [];
  if (parts.length === 0) {
    return true;
  }
  for (const part of parts) {
    const match = part.match(/^(>=|>|<=|<|=)?(.+)$/);
    if (!match) {
      return false;
    }
    const operator = match[1] ?? "=";
    const comparison = compareVersions(version, match[2]);
    if (comparison === null) {
      return false;
    }
    if (operator === ">=" && comparison < 0) return false;
    if (operator === ">" && comparison <= 0) return false;
    if (operator === "<=" && comparison > 0) return false;
    if (operator === "<" && comparison >= 0) return false;
    if (operator === "=" && comparison !== 0) return false;
  }
  return true;
}

function verifyIntegrity(filePath, integrity) {
  const token = optionalString(integrity)
    ?.split(/\s+/)
    .find((entry) => /^(sha512|sha384|sha256)-/.test(entry));
  if (!token) {
    throw new Error(`Missing supported npm integrity for ${filePath}`);
  }
  const [algorithm, expected] = token.split("-", 2);
  const actual = crypto.createHash(algorithm).update(fs.readFileSync(filePath)).digest("base64");
  if (actual !== expected) {
    throw new Error(`Downloaded tarball integrity mismatch for ${filePath}`);
  }
}

function verifyShasum(filePath, shasum) {
  if (!optionalString(shasum)) {
    return;
  }
  const actual = crypto.createHash("sha1").update(fs.readFileSync(filePath)).digest("hex");
  if (actual !== shasum) {
    throw new Error(`Downloaded tarball shasum mismatch for ${filePath}`);
  }
}

function verifySha256Hex(filePath, expectedSha256) {
  const expected = optionalString(expectedSha256)?.replace(/^sha256[:-]?/i, "").toLowerCase();
  if (!expected) {
    throw new Error(`Missing SHA-256 digest for ${filePath}`);
  }
  const actual = crypto.createHash("sha256").update(fs.readFileSync(filePath)).digest("hex");
  if (actual !== expected) {
    throw new Error(`Downloaded tarball SHA-256 mismatch for ${filePath}`);
  }
}

function briefError(error) {
  const lines = String(error?.message ?? error)
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean);
  const interesting = lines.filter((line) =>
    /npm error (?:request|code|Unsupported|Invalid|Missing)|ERROR: npm failed|cache mode is|Unsupported URL Type|No matching version|ERESOLVE|ENOTCACHED|EUNSUPPORTEDPROTOCOL/.test(line),
  );
  return (interesting.length > 0 ? interesting : lines.slice(-12))
    .slice(0, 10)
    .join(" | ")
    .slice(0, 1600);
}

function parseCatalogEntries(raw) {
  if (Array.isArray(raw)) {
    return raw.filter(isRecord);
  }
  if (!isRecord(raw)) {
    return [];
  }
  const list = raw.entries ?? raw.packages ?? raw.plugins;
  return Array.isArray(list) ? list.filter(isRecord) : [];
}

function catalogManifest(entry) {
  return isRecord(entry.openclaw) ? entry.openclaw : {};
}

function catalogPluginId(entry) {
  const manifest = catalogManifest(entry);
  return (
    optionalString(manifest.plugin?.id)
    ?? optionalString(manifest.channel?.id)
    ?? optionalString(manifest.providers?.[0]?.id)
  );
}

function catalogInstall(entry) {
  const manifest = catalogManifest(entry);
  const install = isRecord(manifest.install) ? manifest.install : {};
  const npmSpec = optionalString(install.npmSpec) ?? optionalString(entry.name);
  const clawhubSpec = optionalString(install.clawhubSpec);
  const localPath = optionalString(install.localPath);
  const defaultChoice =
    ["npm", "clawhub", "local"].includes(install.defaultChoice)
      ? install.defaultChoice
      : npmSpec
        ? "npm"
        : clawhubSpec
          ? "clawhub"
          : localPath
            ? "local"
            : undefined;

  if (!npmSpec && !clawhubSpec && !localPath) {
    return null;
  }

  return pickDefined({
    npmSpec,
    clawhubSpec,
    localPath,
    defaultChoice,
    minHostVersion: optionalString(install.minHostVersion),
    expectedIntegrity: optionalString(install.expectedIntegrity),
  });
}

function selectedSource(install) {
  if (!install) {
    return null;
  }
  return install.defaultChoice ?? (install.npmSpec ? "npm" : install.clawhubSpec ? "clawhub" : "local");
}

function parseNpmSpec(spec) {
  const normalized = optionalString(spec)?.replace(/^npm:/, "");
  if (!normalized) {
    return null;
  }

  if (normalized.startsWith("@")) {
    const slashIndex = normalized.indexOf("/");
    if (slashIndex === -1) {
      return null;
    }
    const versionIndex = normalized.indexOf("@", slashIndex + 1);
    if (versionIndex === -1) {
      return { packageName: normalized, version: null };
    }
    return {
      packageName: normalized.slice(0, versionIndex),
      version: normalized.slice(versionIndex + 1) || null,
    };
  }

  const versionIndex = normalized.lastIndexOf("@");
  if (versionIndex <= 0) {
    return { packageName: normalized, version: null };
  }
  return {
    packageName: normalized.slice(0, versionIndex),
    version: normalized.slice(versionIndex + 1) || null,
  };
}

function parseClawHubSpec(spec) {
  const normalized = optionalString(spec)?.replace(/^clawhub:/, "");
  return normalized ? parseNpmSpec(normalized) : null;
}

function clawHubArtifactUrl(packageName, version) {
  return `https://clawhub.ai/api/v1/packages/${encodeURIComponent(packageName)}/versions/${encodeURIComponent(version)}/artifact`;
}

function isExactVersion(version) {
  return /^[0-9]+(?:\.[0-9]+){1,2}(?:-[0-9A-Za-z][0-9A-Za-z.-]*)?$/.test(version);
}

function attrNameForId(id) {
  const attrName = id
    .split(/[^A-Za-z0-9]+/)
    .filter(Boolean)
    .map((part, index) => (index === 0 ? part : `${part.charAt(0).toUpperCase()}${part.slice(1)}`))
    .join("");
  return attrName.replace(/^[0-9]/, "_$&");
}

function collectPackageRoots(nodeModulesDir, baseRel = "node_modules") {
  if (!fs.existsSync(nodeModulesDir)) {
    return [];
  }

  const roots = [];
  for (const entry of fs.readdirSync(nodeModulesDir).sort()) {
    if (entry === ".bin") {
      continue;
    }

    const entryPath = path.join(nodeModulesDir, entry);
    const entryRel = `${baseRel}/${entry}`;
    if (!fs.lstatSync(entryPath).isDirectory()) {
      continue;
    }

    if (entry.startsWith("@")) {
      for (const scopedName of fs.readdirSync(entryPath).sort()) {
        const scopedPath = path.join(entryPath, scopedName);
        const scopedRel = `${entryRel}/${scopedName}`;
        if (fs.lstatSync(scopedPath).isDirectory()) {
          roots.push(scopedRel);
          roots.push(...collectPackageRoots(path.join(scopedPath, "node_modules"), `${scopedRel}/node_modules`));
        }
      }
    } else {
      roots.push(entryRel);
      roots.push(...collectPackageRoots(path.join(entryPath, "node_modules"), `${entryRel}/node_modules`));
    }
  }

  return roots;
}

function packageRootForName(packageName) {
  if (packageName.startsWith("@")) {
    const parts = packageName.split("/");
    if (parts.length !== 2 || !parts[0] || !parts[1]) {
      throw new Error(`invalid scoped package name ${packageName}`);
    }
    const [scope, name] = parts;
    return `node_modules/${scope}/${name}`;
  }
  if (!packageName || packageName.includes("/")) {
    throw new Error(`invalid package name ${packageName}`);
  }
  return `node_modules/${packageName}`;
}

function declaredDependencyRoots(dependencies = {}, optionalDependencies = {}) {
  return [
    ...new Set(
      [
        ...Object.keys(dependencies),
        ...Object.keys(optionalDependencies),
      ].map((dependencyName) => packageRootForName(dependencyName)),
    ),
  ].sort();
}

function listManifestStringField(value, fieldName) {
  if (value === undefined || value === null) {
    return [];
  }
  if (!Array.isArray(value)) {
    throw new Error(`package.json ${fieldName} must be an array`);
  }
  return value.map((entry, index) => {
    const normalized = optionalString(entry);
    if (!normalized) {
      throw new Error(`package.json ${fieldName}[${index}] must be a non-empty string`);
    }
    return normalized;
  });
}

function safePackageEntry(entry, label) {
  const normalized = entry.replace(/\\/g, "/").replace(/^\.\//, "");
  if (!normalized || path.isAbsolute(normalized) || normalized.split("/").includes("..")) {
    throw new Error(`${label} must stay inside the package root: ${entry}`);
  }
  return normalized;
}

function isTypeScriptPackageEntry(entry) {
  return [".ts", ".mts", ".cts"].includes(path.extname(entry).toLowerCase());
}

function listBuiltRuntimeEntryCandidates(entry) {
  if (!isTypeScriptPackageEntry(entry)) {
    return [];
  }
  const normalized = entry.replace(/\\/g, "/");
  const withoutExtension = normalized.replace(/\.[^.]+$/u, "");
  const normalizedRelative = normalized.replace(/^\.\//u, "");
  const distWithoutExtension = normalizedRelative.startsWith("src/")
    ? `./dist/${normalizedRelative.slice("src/".length).replace(/\.[^.]+$/u, "")}`
    : `./dist/${withoutExtension.replace(/^\.\//u, "")}`;
  const withJavaScriptExtensions = (basePath) => [
    `${basePath}.js`,
    `${basePath}.mjs`,
    `${basePath}.cjs`,
  ];
  return [...new Set([
    ...withJavaScriptExtensions(distWithoutExtension),
    ...withJavaScriptExtensions(withoutExtension),
  ])].filter((candidate) => candidate !== normalized);
}

function packageEntryExists(packageRoot, entry, label) {
  const safeEntry = safePackageEntry(entry, label);
  return fs.existsSync(path.join(packageRoot, safeEntry)) ? `./${safeEntry}` : null;
}

function resolveRuntimeEntry(packageRoot, sourceEntry, explicitRuntimeEntry, label) {
  if (explicitRuntimeEntry) {
    const existing = packageEntryExists(packageRoot, explicitRuntimeEntry, `${label} runtime entry`);
    if (!existing) {
      throw new Error(`${label} runtime entry not found: ${explicitRuntimeEntry}`);
    }
    return existing;
  }

  for (const candidate of listBuiltRuntimeEntryCandidates(sourceEntry)) {
    const existing = packageEntryExists(packageRoot, candidate, `${label} inferred runtime entry`);
    if (existing) {
      return existing;
    }
  }

  const source = packageEntryExists(packageRoot, sourceEntry, `${label} source entry`);
  if (source && !isTypeScriptPackageEntry(sourceEntry)) {
    return source;
  }
  if (source && isTypeScriptPackageEntry(sourceEntry)) {
    throw new Error(`${label} requires compiled runtime output for TypeScript entry ${sourceEntry}`);
  }
  throw new Error(`${label} source entry not found: ${sourceEntry}`);
}

function resolveRuntimeEntries(packageRoot, packageJson) {
  const openclaw = isRecord(packageJson.openclaw) ? packageJson.openclaw : {};
  const extensions = listManifestStringField(openclaw.extensions, "openclaw.extensions");
  if (extensions.length === 0) {
    throw new Error("package has no package.json openclaw.extensions entries");
  }
  const explicitRuntimeExtensions = listManifestStringField(
    openclaw.runtimeExtensions,
    "openclaw.runtimeExtensions",
  );
  if (explicitRuntimeExtensions.length > 0 && explicitRuntimeExtensions.length !== extensions.length) {
    throw new Error(
      `package.json openclaw.runtimeExtensions length (${explicitRuntimeExtensions.length}) must match openclaw.extensions length (${extensions.length})`,
    );
  }

  const runtimeExtensions = extensions.map((entry, index) =>
    resolveRuntimeEntry(packageRoot, entry, explicitRuntimeExtensions[index], "extension"),
  );

  const setupEntry = optionalString(openclaw.setupEntry);
  const explicitRuntimeSetupEntry = optionalString(openclaw.runtimeSetupEntry);
  if (explicitRuntimeSetupEntry && !setupEntry) {
    throw new Error("package.json openclaw.runtimeSetupEntry requires openclaw.setupEntry");
  }

  return {
    runtimeExtensions,
    runtimeSetupEntry: setupEntry
      ? resolveRuntimeEntry(packageRoot, setupEntry, explicitRuntimeSetupEntry, "setup")
      : null,
  };
}

function validateTarMembers(tarball) {
  const memberList = run("tar", [
    "-tzf",
    tarball,
  ]);
  for (const member of memberList.split(/\r?\n/).filter(Boolean)) {
    if (path.isAbsolute(member) || member.split("/").includes("..")) {
      throw new Error(`unsafe tar member path in ${tarball}: ${member}`);
    }
    if (!member.startsWith("package/")) {
      throw new Error(`unexpected tar member outside package/ in ${tarball}: ${member}`);
    }
  }
}

function resolvePrefetchNpmDepsBin() {
  if (prefetchNpmDepsBin) {
    return prefetchNpmDepsBin;
  }
  const expr = `
    let
      flake = builtins.getFlake (toString ${repoRoot});
      pkgs = import flake.inputs.nixpkgs { system = builtins.currentSystem; };
    in
      pkgs.prefetch-npm-deps
  `;
  const outPath = run("nix", [
    "build",
    "--no-link",
    "--print-out-paths",
    "--impure",
    "--expr",
    expr,
  ]).trim().split(/\r?\n/).pop();
  prefetchNpmDepsBin = path.join(outPath, "bin/prefetch-npm-deps");
  return prefetchNpmDepsBin;
}

function computeNpmDepsHash(shrinkwrapPath) {
  const output = runWithRetries(
    resolvePrefetchNpmDepsBin(),
    [shrinkwrapPath],
    { attempts: 3, retryDelayMs: 1000 },
  ).trim();
  const hash = output.split(/\r?\n/).findLast((line) => line.startsWith("sha256-"));
  if (!hash) {
    throw new Error(`prefetch-npm-deps did not return an SRI hash for ${shrinkwrapPath}`);
  }
  return hash;
}

function prepareLockedPackage(packageRoot, artifact, dependencyMode = "shrinkwrap", packageLockFile = "") {
  run(process.execPath, [prepareNpmScriptPath], {
    cwd: packageRoot,
    env: {
      ...process.env,
      OPENCLAW_RUNTIME_PLUGIN_DEPENDENCY_MODE: dependencyMode,
      OPENCLAW_RUNTIME_PLUGIN_PACKAGE_LOCK_FILE: packageLockFile,
      OPENCLAW_RUNTIME_PLUGIN_PACKAGE_NAME: artifact.packageName,
      OPENCLAW_RUNTIME_PLUGIN_VERSION: artifact.version,
    },
  });
}

function probeLockMaterialization(row, artifact, npmDepsHash, dependencyMode = "shrinkwrap", packageLockFile = "") {
  const packageLockEnv = renderPackageLockProbeEnv(packageLockFile);
  const safeProbeName = attrNameForId(row.id);
  const expr = `
    let
      flake = builtins.getFlake (toString ${repoRoot});
      pkgs = import flake.inputs.nixpkgs { system = builtins.currentSystem; };
      npmHooksForNode = pkgs.npmHooks.override { nodejs = pkgs.nodejs_24; };
      prepareNpmScript = ${prepareNpmScriptPath};
      pluginSrc = pkgs.fetchurl {
        url = ${nixString(artifact.tarballUrl)};
        hash = ${nixString(artifact.nixHash)};
      };
    in
      pkgs.stdenvNoCC.mkDerivation {
        pname = ${nixString(`openclaw-runtime-plugin-${safeProbeName}-materialization-probe`)};
        version = ${nixString(artifact.version)};
        src = pluginSrc;
        sourceRoot = "package";
        nativeBuildInputs = [
          pkgs.nodejs_24
          pkgs.nodejs_24.python
          npmHooksForNode.npmConfigHook
        ] ++ pkgs.lib.optionals pkgs.stdenvNoCC.hostPlatform.isDarwin [
          pkgs.cctools
        ];
        npmDeps = pkgs.fetchNpmDeps {
          name = ${nixString(`openclaw-runtime-plugin-${safeProbeName}-npm-deps`)};
          src = pluginSrc;
          sourceRoot = "package";
          hash = ${nixString(npmDepsHash)};
          nativeBuildInputs = [ pkgs.nodejs_24 ];
          OPENCLAW_RUNTIME_PLUGIN_DEPENDENCY_MODE = ${nixString(dependencyMode)};
          ${packageLockEnv}
          OPENCLAW_RUNTIME_PLUGIN_PACKAGE_NAME = ${nixString(artifact.packageName)};
          OPENCLAW_RUNTIME_PLUGIN_VERSION = ${nixString(artifact.version)};
          postPatch = ''
            ${"\${pkgs.nodejs_24}"}/bin/node ${"\${prepareNpmScript}"}
          '';
        };
        npmInstallFlags = [
          "--omit=dev"
          "--omit=peer"
          "--legacy-peer-deps"
        ];
        npmRebuildFlags = [ "--ignore-scripts" ];
        dontConfigure = true;
        dontBuild = true;
        env = {
          OPENCLAW_RUNTIME_PLUGIN_ID = ${nixString(row.id)};
          OPENCLAW_RUNTIME_PLUGIN_PACKAGE_NAME = ${nixString(artifact.packageName)};
          OPENCLAW_RUNTIME_PLUGIN_VERSION = ${nixString(artifact.version)};
          OPENCLAW_RUNTIME_PLUGIN_DEPENDENCY_MODE = ${nixString(dependencyMode)};
          ${packageLockEnv}
        };
        postPatch = ''
          ${"\${pkgs.nodejs_24}"}/bin/node ${"\${prepareNpmScript}"}
        '';
        installPhase = ''
          mkdir -p "$out"
          cp package.json ${dependencyMode === "package-lock" ? "package-lock.json" : "npm-shrinkwrap.json"} "$out"/
        '';
      }
  `;
  run("nix", [
    "build",
    "--no-link",
    "--print-out-paths",
    "--impure",
    "--expr",
    expr,
  ]);
}

function renderLock(lock) {
  return `# Generated by nix/scripts/update-openclaw-runtime-plugin-locks.mjs. Do not edit manually.\n${toNix(lock)}\n`;
}

function renderDefault(locks) {
  const entries = locks
    .map((lock) => `  ${nixAttrName(lock.id)} = import ./${lock.attrName}.nix;`)
    .join("\n");
  return `# Generated by nix/scripts/update-openclaw-runtime-plugin-locks.mjs. Do not edit manually.\n{\n${entries}\n}\n`;
}

function desiredGeneratedFiles(locks, report) {
  return new Map([
    ...locks.map((lock) => [
      path.join(outputDir, `${lock.attrName}.nix`),
      renderLock(lock),
    ]),
    ...[...packageLocks.generatedFiles].map(([file, text]) => [path.join(outputDir, file), text]),
    [defaultOutputPath, renderDefault(locks)],
    [reportOutputPath, stableJson(report)],
  ]);
}

function existingGeneratedFiles() {
  if (!fs.existsSync(outputDir)) {
    return [];
  }
  return fs
    .readdirSync(outputDir)
    .filter((entry) => entry === "report.json" || entry.endsWith(".nix") || entry.endsWith(".package-lock.json"))
    .map((entry) => path.join(outputDir, entry));
}

function checkGeneratedFiles(desiredFiles) {
  const staleFiles = existingGeneratedFiles().filter((file) => !desiredFiles.has(file));
  const changedFiles = [];

  for (const [file, content] of desiredFiles) {
    if (!fs.existsSync(file) || fs.readFileSync(file, "utf8") !== content) {
      changedFiles.push(file);
    }
  }

  if (staleFiles.length === 0 && changedFiles.length === 0) {
    return;
  }

  for (const file of changedFiles) {
    console.error(`would update ${path.relative(repoRoot, file)}`);
  }
  for (const file of staleFiles) {
    console.error(`would remove ${path.relative(repoRoot, file)}`);
  }
  process.exit(1);
}

function reportBase(row) {
  return pickDefined({
    id: row.id,
    label: row.label,
    kind: row.kind,
    source: row.source,
    catalogFile: row.catalogFile,
    catalogEntryName: row.catalogEntryName,
    catalogDefaultChoice: row.install?.defaultChoice,
    selectedSource: row.selectedSource,
    npmSpec: row.install?.npmSpec,
    clawhubSpec: row.install?.clawhubSpec,
    localPath: row.install?.localPath,
    minHostVersion: row.install?.minHostVersion,
    expectedIntegrity: row.install?.expectedIntegrity,
  });
}

function skip(row, reason, detail) {
  return {
    ...reportBase(row),
    status: "skipped",
    reason,
    ...(detail ? { detail } : {}),
  };
}

function supportedReport(lock) {
  return pickDefined({
    id: lock.id,
    status: "supported",
    label: lock.label,
    kind: lock.kind,
    source: lock.catalogSource,
    catalogFile: lock.catalogFile,
    catalogEntryName: lock.catalogEntryName,
    catalogDefaultChoice: lock.catalogDefaultChoice,
    selectedSource: lock.selectedSource,
    packageName: lock.packageName,
    version: lock.version,
    dependencyMode: lock.dependencyMode,
    openclawCompat: lock.openclawCompat,
    peerOpenClaw: lock.peerOpenClaw,
  });
}

function readCatalogRows(openclawSourcePath) {
  const rows = [];
  for (const catalogFile of catalogFiles) {
    const catalogPath = path.join(openclawSourcePath, "scripts/lib", catalogFile);
    const raw = JSON.parse(fs.readFileSync(catalogPath, "utf8"));
    for (const entry of parseCatalogEntries(raw)) {
      const manifest = catalogManifest(entry);
      const install = catalogInstall(entry);
      const id = catalogPluginId(entry);
      const label =
        optionalString(manifest.plugin?.label)
        ?? optionalString(manifest.channel?.label)
        ?? optionalString(manifest.providers?.[0]?.name)
        ?? optionalString(entry.name)
        ?? id;

      rows.push({
        entry,
        id,
        label,
        kind: optionalString(entry.kind) ?? "plugin",
        source: optionalString(entry.source),
        catalogFile,
        catalogEntryName: optionalString(entry.name),
        install,
        selectedSource: selectedSource(install),
      });
    }
  }
  return rows;
}

async function resolveNpmArtifact(row, npmPackage) {
  const packageMetadata = await fetchJsonWithRetries(npmRegistryUrl(npmPackage.packageName));
  const versionMetadata = packageMetadata.versions?.[npmPackage.version];
  if (!versionMetadata) {
    return {
      skipped: skip(
        row,
        npmPackage.packageName.startsWith("@openclaw/")
          ? "missing-pinned-artifact"
          : "missing-catalog-pinned-artifact",
        `${npmPackage.packageName}@${npmPackage.version} is not published`,
      ),
    };
  }

  if (row.install?.expectedIntegrity && versionMetadata.dist?.integrity !== row.install.expectedIntegrity) {
    return {
      skipped: skip(
        row,
        "npm-integrity-mismatch",
        `catalog expected ${row.install.expectedIntegrity}; npm returned ${versionMetadata.dist?.integrity ?? "missing"}`,
      ),
    };
  }

  if (!versionMetadata.dist?.tarball) {
    return { skipped: skip(row, "missing-npm-tarball", `${npmPackage.packageName}@${npmPackage.version}`) };
  }
  if (!versionMetadata.dist?.integrity) {
    return { skipped: skip(row, "missing-npm-integrity", `${npmPackage.packageName}@${npmPackage.version}`) };
  }

  const prefetch = JSON.parse(run("nix", ["store", "prefetch-file", "--json", versionMetadata.dist.tarball]));
  verifyIntegrity(prefetch.storePath, versionMetadata.dist.integrity);
  verifyShasum(prefetch.storePath, versionMetadata.dist.shasum);

  return {
    artifact: {
      selectedSource: "npm",
      npmSpec: row.install?.npmSpec,
      packageName: npmPackage.packageName,
      version: npmPackage.version,
      tarballUrl: versionMetadata.dist.tarball,
      npmIntegrity: versionMetadata.dist.integrity,
      npmShasum: versionMetadata.dist.shasum,
      nixHash: prefetch.hash,
      storePath: prefetch.storePath,
      versionMetadata,
      bundleDependencies: [
        ...(versionMetadata.bundleDependencies ?? versionMetadata.bundledDependencies ?? []),
      ].sort(),
    },
  };
}

async function resolveClawHubArtifact(row, clawhubPackage) {
  const artifactUrl = clawHubArtifactUrl(clawhubPackage.packageName, clawhubPackage.version);
  let payload;
  try {
    payload = await fetchJsonWithRetries(artifactUrl);
  } catch (error) {
    if (String(error?.message ?? error).includes("HTTP 404")) {
      return {
        skipped: skip(
          row,
          "missing-clawhub-artifact",
          `${clawhubPackage.packageName}@${clawhubPackage.version} returned HTTP 404`,
        ),
      };
    }
    throw error;
  }
  const artifactMetadata = payload.artifact ?? payload.version?.artifact ?? payload.packageVersion?.artifact;
  if (!isRecord(artifactMetadata)) {
    return {
      skipped: skip(row, "missing-clawhub-artifact", `${clawhubPackage.packageName}@${clawhubPackage.version}`),
    };
  }

  const kind = optionalString(artifactMetadata.kind) ?? optionalString(artifactMetadata.type);
  if (kind !== "npm-pack") {
    return {
      skipped: skip(
        row,
        "unsupported-clawhub-artifact-kind",
        `ClawHub artifact kind is ${kind ?? "missing"}`,
      ),
    };
  }

  const tarballUrl =
    optionalString(artifactMetadata.tarballUrl)
    ?? optionalString(artifactMetadata.url)
    ?? optionalString(artifactMetadata.downloadUrl);
  if (!tarballUrl || !tarballUrl.startsWith("https://")) {
    return { skipped: skip(row, "missing-clawhub-tarball", "ClawHub npm-pack artifact has no HTTPS tarball URL") };
  }

  const sha256 =
    optionalString(artifactMetadata.sha256)
    ?? optionalString(artifactMetadata.digest?.sha256)
    ?? optionalString(artifactMetadata.digest);
  if (!sha256) {
    return { skipped: skip(row, "missing-clawhub-sha256", "ClawHub artifact has no SHA-256 digest") };
  }

  const npmIntegrity =
    optionalString(artifactMetadata.npmIntegrity)
    ?? optionalString(artifactMetadata.integrity)
    ?? optionalString(artifactMetadata.dist?.integrity);
  const npmShasum =
    optionalString(artifactMetadata.npmShasum)
    ?? optionalString(artifactMetadata.shasum)
    ?? optionalString(artifactMetadata.dist?.shasum);

  if (row.install?.expectedIntegrity && row.install.expectedIntegrity !== npmIntegrity) {
    return {
      skipped: skip(
        row,
        "clawhub-integrity-mismatch",
        `catalog expected ${row.install.expectedIntegrity}; ClawHub returned ${npmIntegrity ?? "missing"}`,
      ),
    };
  }

  const prefetch = JSON.parse(run("nix", ["store", "prefetch-file", "--json", tarballUrl]));
  verifySha256Hex(prefetch.storePath, sha256);
  if (npmIntegrity) {
    verifyIntegrity(prefetch.storePath, npmIntegrity);
  }
  verifyShasum(prefetch.storePath, npmShasum);

  return {
    artifact: {
      selectedSource: "clawhub",
      clawhubSpec: row.install?.clawhubSpec,
      packageName: clawhubPackage.packageName,
      version: clawhubPackage.version,
      tarballUrl,
      npmIntegrity: npmIntegrity ?? "",
      npmShasum: npmShasum ?? "",
      nixHash: prefetch.hash,
      storePath: prefetch.storePath,
      bundleDependencies: [],
      clawhubPackageName: clawhubPackage.packageName,
      clawhubVersion: clawhubPackage.version,
      clawhubArtifactKind: kind,
      clawhubArtifactSha256: sha256,
    },
  };
}

function dependencyModeForArtifact(
  row,
  artifact,
  packageRoot,
  dependencies,
  optionalDependencies,
  bundledPackageRoots,
  shrinkwrap,
) {
  const hasRuntimeDependencies =
    Object.keys(dependencies).length > 0 || Object.keys(optionalDependencies).length > 0;

  if (!hasRuntimeDependencies && bundledPackageRoots.length > 0) {
    return {
      skipped: skip(
        row,
        "unexpected-bundled-dependencies",
        "package bundles node_modules but declares no runtime dependencies",
      ),
    };
  }
  if (!hasRuntimeDependencies) {
    return { dependencyMode: "none", npmDepsHash: undefined };
  }

  if (bundledPackageRoots.length > 0) {
    const bundledRootSet = new Set(bundledPackageRoots);
    const missingBundledRoots = declaredDependencyRoots(dependencies, optionalDependencies)
      .filter((dependencyRoot) => !bundledRootSet.has(dependencyRoot));
    if (missingBundledRoots.length > 0) {
      return {
        skipped: skip(
          row,
          "partial-bundled-runtime-dependencies",
          `declared dependency roots missing from bundled node_modules: ${missingBundledRoots.join(", ")}`,
        ),
      };
    }
    return { dependencyMode: "bundled", npmDepsHash: undefined };
  }

  if (!shrinkwrap) {
    const result = packageLocks.materialize({
      artifact, packageRoot, attrName: attrNameForId(row.id),
      probe: (hash, lockFile) => probeLockMaterialization(row, artifact, hash, "package-lock", lockFile),
      onFailure: (reason, error) => ({
        skipped: skip(row, reason,
          reason === "package-lock-evidence-incomplete" ? error.message : briefError(error)),
      }),
    });
    if (result) return result;
    return {
      skipped: skip(
        row,
        "runtime-dependencies-without-shrinkwrap",
        "package has runtime dependencies but no npm-shrinkwrap.json, bundled node_modules, or upstream npm package-lock evidence",
      ),
    };
  }

  const shrinkwrapPath = path.join(packageRoot, "npm-shrinkwrap.json");
  try {
    prepareLockedPackage(packageRoot, artifact);
  } catch (error) {
    return {
      skipped: skip(row, "shrinkwrap-prepare-failed", briefError(error)),
    };
  }

  let npmDepsHash;
  try {
    npmDepsHash = computeNpmDepsHash(shrinkwrapPath);
  } catch (error) {
    return {
      skipped: skip(row, "shrinkwrap-npm-deps-hash-failed", briefError(error)),
    };
  }

  try {
    probeLockMaterialization(row, artifact, npmDepsHash);
  } catch (error) {
    return {
      skipped: skip(row, "shrinkwrap-materialization-failed", briefError(error)),
    };
  }

  return { dependencyMode: "shrinkwrap", npmDepsHash };
}

async function buildArtifactLock(row, artifact) {
  const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), "openclaw-runtime-plugin-lock-"));
  try {
    validateTarMembers(artifact.storePath);
    run("tar", [
      "-xzf",
      artifact.storePath,
      "-C",
      tmpDir,
    ]);

    const packageRoot = path.join(tmpDir, "package");
    const packageJsonPath = path.join(packageRoot, "package.json");
    const manifestPath = path.join(packageRoot, "openclaw.plugin.json");
    if (!fs.existsSync(packageJsonPath) || !fs.existsSync(manifestPath)) {
      return {
        skipped: skip(row, "not-native-runtime-plugin", "package lacks package.json or openclaw.plugin.json"),
      };
    }

    const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, "utf8"));
    const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
    const shrinkwrapPath = path.join(packageRoot, "npm-shrinkwrap.json");
    const shrinkwrap = fs.existsSync(shrinkwrapPath)
      ? JSON.parse(fs.readFileSync(shrinkwrapPath, "utf8"))
      : null;
    const shrinkwrapPackagePaths = new Set(Object.keys(shrinkwrap?.packages ?? {}));
    const bundledPackageRoots = collectPackageRoots(path.join(packageRoot, "node_modules"));

    if (packageJson.name !== artifact.packageName) {
      return { skipped: skip(row, "package-name-mismatch", `package.json name is ${packageJson.name}`) };
    }
    if (packageJson.version !== artifact.version) {
      return { skipped: skip(row, "package-version-mismatch", `package.json version is ${packageJson.version}`) };
    }
    if (manifest.id !== row.id) {
      return { skipped: skip(row, "manifest-id-mismatch", `openclaw.plugin.json id is ${manifest.id}`) };
    }

    const openclawCompat = packageJson.openclaw?.compat?.pluginApi ?? "";
    const peerOpenClaw = packageJson.peerDependencies?.openclaw ?? "";
    const compatibilityRanges = [
      ["catalog minHostVersion", row.install?.minHostVersion ?? ""],
      ["openclaw.compat.pluginApi", openclawCompat],
      ["peerDependencies.openclaw", peerOpenClaw],
    ];
    for (const [name, range] of compatibilityRanges) {
      if (range && !satisfiesVersionRange(releaseVersion, range)) {
        return {
          skipped: skip(row, "host-compatibility-mismatch", `${name} ${range} does not include OpenClaw ${releaseVersion}`),
        };
      }
    }

    let resolvedRuntimeEntries;
    try {
      resolvedRuntimeEntries = resolveRuntimeEntries(packageRoot, packageJson);
    } catch (error) {
      return { skipped: skip(row, "missing-runtime-entry", error.message) };
    }

    const dependencies = sortedObject(packageJson.dependencies ?? artifact.versionMetadata?.dependencies ?? {});
    const optionalDependencies = sortedObject(
      packageJson.optionalDependencies ?? artifact.versionMetadata?.optionalDependencies ?? {},
    );

    if (shrinkwrap) {
      for (const bundledRoot of bundledPackageRoots) {
        if (!shrinkwrapPackagePaths.has(bundledRoot)) {
          return {
            skipped: skip(
              row,
              "bundled-dependency-missing-from-shrinkwrap",
              `bundled dependency ${bundledRoot} is not in npm-shrinkwrap.json`,
            ),
          };
        }
      }
    }

    const dependencyResult = dependencyModeForArtifact(
      row,
      artifact,
      packageRoot,
      dependencies,
      optionalDependencies,
      bundledPackageRoots,
      shrinkwrap,
    );
    if (dependencyResult.skipped) {
      return { skipped: dependencyResult.skipped };
    }

    const lock = pickDefined({
      id: row.id,
      attrName: attrNameForId(row.id),
      label: row.label,
      kind: row.kind,
      catalogSource: row.source,
      catalogFile: row.catalogFile,
      catalogEntryName: row.catalogEntryName,
      catalogDefaultChoice: row.install?.defaultChoice ?? null,
      selectedSource: artifact.selectedSource,
      npmSpec: artifact.npmSpec,
      clawhubSpec: artifact.clawhubSpec,
      minHostVersion: row.install?.minHostVersion ?? "",
      expectedIntegrity: row.install?.expectedIntegrity ?? "",
      packageName: artifact.packageName,
      version: artifact.version,
      tarballUrl: artifact.tarballUrl,
      npmIntegrity: artifact.npmIntegrity,
      npmShasum: artifact.npmShasum,
      nixHash: artifact.nixHash,
      ...dependencyResult,
      manifestId: manifest.id,
      openclawCompat,
      peerOpenClaw,
      runtimeExtensions: resolvedRuntimeEntries.runtimeExtensions,
      runtimeSetupEntry: resolvedRuntimeEntries.runtimeSetupEntry,
      channels: manifest.channels ?? [],
      contracts: manifest.contracts ?? {},
      dependencies,
      optionalDependencies,
      bundleDependencies: dependencyResult.dependencyMode === "bundled" ? artifact.bundleDependencies : [],
      bundledPackageRoots,
      clawhubPackageName: artifact.clawhubPackageName,
      clawhubVersion: artifact.clawhubVersion,
      clawhubArtifactKind: artifact.clawhubArtifactKind,
      clawhubArtifactSha256: artifact.clawhubArtifactSha256,
    });

    return { lock, supported: supportedReport(lock) };
  } finally {
    fs.rmSync(tmpDir, { recursive: true, force: true });
  }
}

async function processRow(row, releaseVersion, runtimePluginVersion) {
  if (!row.id) {
    return { skipped: skip(row, "missing-plugin-id", "catalog row has no plugin, channel, or provider id") };
  }
  if (!row.install) {
    return { skipped: skip(row, "missing-install-metadata", "catalog row has no install metadata") };
  }
  if (row.selectedSource === "local") {
    return { skipped: skip(row, "local-source-unsupported", "catalog-selected local paths are not reproducible Nix artifacts") };
  }
  if (row.selectedSource === "clawhub") {
    const clawhubPackage = parseClawHubSpec(row.install.clawhubSpec);
    if (!clawhubPackage) {
      return { skipped: skip(row, "invalid-clawhub-spec", row.install.clawhubSpec ?? "") };
    }
    if (!clawhubPackage.version) {
      clawhubPackage.version = defaultCatalogVersion(
        row.source,
        releaseVersion,
        runtimePluginVersion,
      );
    }
    if (!isExactVersion(clawhubPackage.version)) {
      return {
        skipped: skip(row, "exact-version-required", `ClawHub version ${clawhubPackage.version} is not an exact version`),
      };
    }
    const resolved = await resolveClawHubArtifact(row, clawhubPackage);
    return resolved.artifact ? buildArtifactLock(row, resolved.artifact) : resolved;
  }
  if (row.selectedSource !== "npm") {
    return { skipped: skip(row, "unsupported-selected-source", `selected source is ${row.selectedSource ?? "missing"}`) };
  }

  const npmPackage = parseNpmSpec(row.install.npmSpec);
  if (!npmPackage) {
    return { skipped: skip(row, "invalid-npm-spec", row.install.npmSpec ?? "") };
  }

  if (!npmPackage.version) {
    npmPackage.version = defaultCatalogVersion(
      row.source,
      releaseVersion,
      runtimePluginVersion,
    );
  }

  if (!isExactVersion(npmPackage.version)) {
    return {
      skipped: skip(row, "exact-version-required", `npm version ${npmPackage.version} is not an exact version`),
    };
  }

  const resolved = await resolveNpmArtifact(row, npmPackage);
  return resolved.artifact ? buildArtifactLock(row, resolved.artifact) : resolved;
}

const releaseVersion = readSourceField("releaseVersion");
const runtimePluginVersion = readSourceField("runtimePluginVersion");
const releaseTag = readSourceField("releaseTag");
const pinnedRev = readSourceField("rev");
const pinnedHash = readSourceField("hash");
const packageLocks = createNpmPackageLockMaterializer({
  releaseTag, releaseVersion, releaseRev: pinnedRev,
  prepare: prepareLockedPackage, computeNpmDepsHash,
});
const openclawSourcePath = resolveOpenClawSourcePath();
const taggedPackageVersion = JSON.parse(
  fs.readFileSync(path.join(openclawSourcePath, "package.json"), "utf8"),
).version;
const expectedRuntimePluginVersion = resolveRuntimePluginVersion(
  releaseVersion,
  taggedPackageVersion,
);
if (runtimePluginVersion !== expectedRuntimePluginVersion) {
  throw new Error(
    `runtimePluginVersion ${runtimePluginVersion} does not match tagged package metadata`
    + ` ${expectedRuntimePluginVersion}`,
  );
}
const rows = readCatalogRows(openclawSourcePath);
const locks = [];
const supported = [];
const skipped = [];
const seenCatalogKeys = new Set();

for (const row of rows) {
  const dedupeKey = row.id ?? row.catalogEntryName ?? "";
  if (seenCatalogKeys.has(dedupeKey)) {
    skipped.push(skip(row, "duplicate-catalog-row", `duplicate catalog key ${dedupeKey}`));
    continue;
  }
  seenCatalogKeys.add(dedupeKey);

  const result = await processRow(row, releaseVersion, runtimePluginVersion);
  if (result.lock) {
    locks.push(result.lock);
    supported.push(result.supported);
  } else if (result.skipped) {
    skipped.push(result.skipped);
  } else {
    throw new Error(`No lock or skip result for ${row.id ?? row.catalogEntryName}`);
  }
}

locks.sort((a, b) => a.id.localeCompare(b.id));
supported.sort((a, b) => a.id.localeCompare(b.id));
skipped.sort((a, b) =>
  `${a.catalogFile}:${a.id ?? a.catalogEntryName ?? ""}`.localeCompare(
    `${b.catalogFile}:${b.id ?? b.catalogEntryName ?? ""}`,
  ),
);

fs.mkdirSync(outputDir, { recursive: true });

const report = {
  openclawVersion: releaseVersion,
  runtimePluginVersion,
  openclawReleaseTag: releaseTag,
  openclawRev: pinnedRev,
  openclawHash: pinnedHash,
  catalogFiles,
  supported,
  skipped,
};
const desiredFiles = desiredGeneratedFiles(locks, report);

if (checkMode) {
  checkGeneratedFiles(desiredFiles);
  console.log(
    `${path.relative(repoRoot, outputDir)} is up to date for OpenClaw ${releaseVersion}: ${supported.length} supported, ${skipped.length} skipped`,
  );
  process.exit(0);
}

for (const file of existingGeneratedFiles()) {
  if (!desiredFiles.has(file)) {
    fs.rmSync(file);
  }
}

for (const [file, content] of desiredFiles) {
  fs.writeFileSync(file, content);
}

console.log(
  `wrote ${path.relative(repoRoot, outputDir)} for OpenClaw ${releaseVersion}: ${supported.length} supported, ${skipped.length} skipped`,
);
