{
  lib,
  stdenv,
  buildNpmPackage,
  nodejs_24,
  makeWrapper,
  sourceInfo,
  bundledAcpx,
}:

let
  buildNpmPackageForOpenClaw = buildNpmPackage.override {
    nodejs = nodejs_24;
  };
  wrapperSrc = ../npm/openclaw;
  lock = builtins.fromJSON (builtins.readFile "${wrapperSrc}/package-lock.json");
  lockedVersion = lock.packages."node_modules/openclaw".version or null;
in

assert lib.assertMsg (lockedVersion == sourceInfo.releaseVersion)
  "OpenClaw npm lock version ${toString lockedVersion} does not match OpenClaw ${sourceInfo.releaseVersion}";
assert lib.assertMsg ((bundledAcpx.openclawRuntimePlugin.id or null) == "acpx")
  "bundledAcpx must be the generated ACPX runtime plugin package";
assert lib.assertMsg ((bundledAcpx.openclawRuntimePlugin.version or null) == sourceInfo.runtimePluginVersion)
  "ACPX runtime plugin version ${toString (bundledAcpx.openclawRuntimePlugin.version or null)} does not match OpenClaw runtime plugins ${sourceInfo.runtimePluginVersion}";

buildNpmPackageForOpenClaw {
  pname = "openclaw-gateway";
  version = sourceInfo.releaseVersion;

  src = wrapperSrc;
  npmDepsHash = sourceInfo.gatewayNpmDepsHash;
  dontNpmBuild = true;
  makeCacheWritable = true;

  npmInstallFlags = [
    "--omit=dev"
    "--ignore-scripts"
    "--legacy-peer-deps"
  ];

  nativeBuildInputs = [ makeWrapper ];

  env = {
    NODE_BIN = "${nodejs_24}/bin/node";
    # stdenv unpacks the directory source under its hash-stripped store name;
    # postUnpack runs in the build root before stdenv enters it.
    OPENCLAW_NPM_WRAPPER_DIR = baseNameOf wrapperSrc;
    OPENCLAW_BUNDLED_ACPX = "${bundledAcpx}";
    OPENCLAW_NPM_PACKAGE_ROOT = "node_modules/openclaw";
    OPENCLAW_PATCH_NPM_DIST_SCRIPT = "${../scripts/patch-openclaw-npm-dist.mjs}";
    STDENV_SETUP = "${stdenv}/setup";
  };

  # Validate the wrapper lock before npmConfigHook runs `npm ci` in postPatch,
  # so an incomplete lock fails with the offending edge instead of ENOTCACHED.
  # postUnpack, not prePatch: buildNpmPackage forwards prePatch/postPatch into
  # its fetchNpmDeps derivation, which has no npm on PATH.
  postUnpack = "${../scripts/check-openclaw-npm-wrapper-lock.sh}";
  installPhase = "${../scripts/openclaw-gateway-npm-install.sh}";

  dontFixup = true;
  dontStrip = true;
  dontPatchShebangs = true;

  passthru = {
    inherit sourceInfo;
    pinnedRev = sourceInfo.rev;
    npmWrapperSrc = wrapperSrc;
    inherit bundledAcpx;
  };

  meta = with lib; {
    description = "Telegram-first AI gateway (OpenClaw)";
    homepage = "https://github.com/openclaw/openclaw";
    license = licenses.mit;
    platforms = platforms.darwin ++ platforms.linux;
    mainProgram = "openclaw";
  };
}
