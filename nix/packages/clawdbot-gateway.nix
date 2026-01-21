{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, nodejs_22
, pnpm_10
, pkg-config
, jq
, python3
, node-gyp
, makeWrapper
, vips
, git
, zstd
, sourceInfo
, gatewaySrc ? null
, pnpmDepsHash ? (sourceInfo.pnpmDepsHash or null)
}:

assert gatewaySrc == null || pnpmDepsHash != null;

let
  sourceFetch = lib.removeAttrs sourceInfo [ "pnpmDepsHash" ];
  pnpmPlatform = if stdenv.hostPlatform.isDarwin then "darwin" else "linux";
  pnpmArch = if stdenv.hostPlatform.isAarch64 then "arm64" else "x64";
  nodeAddonApi = stdenv.mkDerivation {
    pname = "node-addon-api";
    version = "8.5.0";
    src = fetchurl {
      url = "https://registry.npmjs.org/node-addon-api/-/node-addon-api-8.5.0.tgz";
      hash = "sha256-0S8HyBYig7YhNVGFXx2o2sFiMxN0YpgwteZA8TDweRA=";
    };
    dontConfigure = true;
    dontBuild = true;
    installPhase = "${../scripts/node-addon-api-install.sh}";
  };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "clawdbot-gateway";
  version = "2026.1.16-2";

  src = if gatewaySrc != null then gatewaySrc else fetchFromGitHub sourceFetch;

  pnpmDeps = pnpm_10.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = if pnpmDepsHash != null
      then pnpmDepsHash
      else lib.fakeHash;
    fetcherVersion = 2;
    npm_config_arch = pnpmArch;
    npm_config_platform = pnpmPlatform;
    nativeBuildInputs = [ git ];
  };

  nativeBuildInputs = [
    nodejs_22
    pnpm_10
    pkg-config
    jq
    python3
    node-gyp
    makeWrapper
    zstd
  ];

  buildInputs = [ vips ];

  env = {
    SHARP_IGNORE_GLOBAL_LIBVIPS = "1";
    npm_config_arch = pnpmArch;
    npm_config_platform = pnpmPlatform;
    PNPM_CONFIG_MANAGE_PACKAGE_MANAGER_VERSIONS = "false";
    npm_config_nodedir = nodejs_22;
    npm_config_python = python3;
    NODE_PATH = "${nodeAddonApi}/lib/node_modules:${node-gyp}/lib/node_modules";
    NODE_BIN = "${nodejs_22}/bin/node";
    PNPM_DEPS = finalAttrs.pnpmDeps;
    NODE_GYP_WRAPPER_SH = "${../scripts/node-gyp-wrapper.sh}";
    GATEWAY_PREBUILD_SH = "${../scripts/gateway-prebuild.sh}";
    PROMOTE_PNPM_INTEGRITY_SH = "${../scripts/promote-pnpm-integrity.sh}";
    REMOVE_PACKAGE_MANAGER_FIELD_SH = "${../scripts/remove-package-manager-field.sh}";
    STDENV_SETUP = "${stdenv}/setup";
  };

  postPatch = "${../scripts/gateway-postpatch.sh}";
  buildPhase = "${../scripts/gateway-build.sh}";
  installPhase = "${../scripts/gateway-install.sh}";
  dontStrip = true;
  dontPatchShebangs = true;

  meta = with lib; {
    description = "Telegram-first AI gateway (Clawdbot)";
    homepage = "https://github.com/clawdbot/clawdbot";
    license = licenses.mit;
    platforms = platforms.darwin ++ platforms.linux;
    mainProgram = "clawdbot";
  };
})
