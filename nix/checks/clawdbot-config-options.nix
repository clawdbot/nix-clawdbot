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
, git
, zstd
, sourceInfo
, pnpmDepsHash ? (sourceInfo.pnpmDepsHash or null)
}:

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
  pname = "clawdbot-config-options";
  version = "2026.1.16-2";

  src = fetchFromGitHub sourceFetch;

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
    zstd
  ];

  env = {
    npm_config_arch = pnpmArch;
    npm_config_platform = pnpmPlatform;
    PNPM_CONFIG_MANAGE_PACKAGE_MANAGER_VERSIONS = "false";
    npm_config_nodedir = nodejs_22;
    npm_config_python = python3;
    NODE_PATH = "${nodeAddonApi}/lib/node_modules:${node-gyp}/lib/node_modules";
    PNPM_DEPS = finalAttrs.pnpmDeps;
    NODE_GYP_WRAPPER_SH = "${../scripts/node-gyp-wrapper.sh}";
    GATEWAY_PREBUILD_SH = "${../scripts/gateway-prebuild.sh}";
    PROMOTE_PNPM_INTEGRITY_SH = "${../scripts/promote-pnpm-integrity.sh}";
    REMOVE_PACKAGE_MANAGER_FIELD_SH = "${../scripts/remove-package-manager-field.sh}";
    STDENV_SETUP = "${stdenv}/setup";
    CONFIG_OPTIONS_GENERATOR = "${../scripts/generate-config-options.ts}";
    CONFIG_OPTIONS_GOLDEN = "${../generated/clawdbot-config-options.nix}";
    NODE_ENGINE_CHECK = "${../scripts/check-node-engine.ts}";
  };

  buildPhase = "${../scripts/gateway-tests-build.sh}";
  postPatch = "${../scripts/gateway-postpatch.sh}";

  doCheck = true;
  checkPhase = "${../scripts/config-options-check.sh}";

  installPhase = "${../scripts/empty-install.sh}";
  dontPatchShebangs = true;
})
