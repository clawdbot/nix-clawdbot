{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  nodejs_24,
  pnpm_10,
  pnpm_11,
  pnpm_12,
  fetchPnpmDeps,
  pkg-config,
  jq,
  python3,
  node-gyp,
  git,
  zstd,
}:

# Shared build plumbing for OpenClaw gateway-related derivations.
#
# Goals:
# - one source of truth for pnpm deps fetch + common env
# - keep the individual derivations small/boring

{
  pname,
  sourceInfo,
  pnpmDepsPname ? "openclaw-gateway",
  gatewaySrc ? null,
  src ? null,
  enableSharp ? false,
  extraNativeBuildInputs ? [ ],
  extraBuildInputs ? [ ],
  extraEnv ? { },
  pnpmDepsHash ? (sourceInfo.pnpmDepsHash or null),
}:

let
  sourceFetch = lib.removeAttrs sourceInfo [
    "pnpmDepsHash"
    "gatewayNpmDepsHash"
    "pnpmMajor"
    "releaseTag"
    "releaseVersion"
    "runtimePluginVersion"
    "applyPublicSurfaceHardlinksPatch"
    "applySkipPluginAutoEnableNixModePatch"
    "applyNixStorePluginOwnershipPatch"
    "publicSurfaceHardlinksPatch"
    "fsSafeSource"
  ];

  # Prefer nixpkgs' platform mapping instead of hand-rolled arch/platform.
  pnpmPlatform = stdenv.hostPlatform.node.platform;
  pnpmArch = stdenv.hostPlatform.node.arch;

  revShort = lib.substring 0 8 sourceInfo.rev;
  version = "unstable-${revShort}";

  resolvedSrc =
    if src != null then
      src
    else if gatewaySrc != null then
      gatewaySrc
    else
      fetchFromGitHub sourceFetch;

  fsSafeSource = if sourceInfo ? fsSafeSource then fetchFromGitHub sourceInfo.fsSafeSource else null;
  publicSurfaceHardlinksPatch =
    sourceInfo.publicSurfaceHardlinksPatch or ../patches/allow-package-public-surface-hardlinks.patch;

  nodeAddonApi = import ../packages/node-addon-api.nix { inherit stdenv fetchurl; };
  pnpmMajor = toString (sourceInfo.pnpmMajor or "10");
  pnpmByMajor = {
    "10" = pnpm_10;
    "11" = pnpm_11;
    "12" = pnpm_12;
  };
  selectedPnpm = pnpmByMajor.${pnpmMajor} or (throw "Unsupported OpenClaw pnpm major ${pnpmMajor}");
  pnpmNeedsVerifiedStore = lib.elem pnpmMajor [
    "11"
    "12"
  ];

  pnpmDeps = fetchPnpmDeps {
    pname = pnpmDepsPname;
    inherit version;
    src = resolvedSrc;
    pnpm = selectedPnpm;
    hash = if pnpmDepsHash != null then pnpmDepsHash else lib.fakeHash;
    fetcherVersion = if pnpmNeedsVerifiedStore then 4 else 3;
    preFixup = lib.optionalString pnpmNeedsVerifiedStore ''
      expectedIntegrities="$(mktemp)"
      actualIntegrities="$(mktemp)"
      missingIntegrities="$(mktemp)"
      expectedPackages="$(mktemp)"
      yq -r '.packages | to_entries[] | select(.value.resolution.integrity) | [.key, .value.resolution.integrity] | @tsv' pnpm-lock.yaml > "$expectedPackages"
      cut -f2 "$expectedPackages" | sort -u > "$expectedIntegrities"
      ${nodejs_24}/bin/node --no-warnings ${../scripts/list-pnpm-store-integrities.js} "$storePath" | sort -u > "$actualIntegrities"
      comm -23 "$expectedIntegrities" "$actualIntegrities" > "$missingIntegrities"
      if [ -s "$missingIntegrities" ]; then
        echo "ERROR: pnpm store is missing package tarballs from pnpm-lock.yaml:" >&2
        grep -F -f "$missingIntegrities" "$expectedPackages" >&2
        exit 1
      fi

      ${nodejs_24}/bin/node --no-warnings ${../scripts/normalize-pnpm-store-index.js} "$storePath"
    '';
    postInstall = lib.optionalString pnpmNeedsVerifiedStore ''
      verifiedCache="$(find "$HOME" -path '*/lockfile-verified.jsonl' -type f -print -quit)"
      if [ -n "$verifiedCache" ]; then
        jq -c '
          .lockfile.path = ""
          | .lockfile.size = -1
          | .lockfile.mtimeNs = ""
          | .lockfile.inode = ""
          | .verifiedAt = "1970-01-01T00:00:01.000Z"
        ' "$verifiedCache" | LC_ALL=C sort -u > "$out/pnpm-lockfile-verified.jsonl"
      fi
    '';
    npm_config_arch = pnpmArch;
    npm_config_platform = pnpmPlatform;
    nativeBuildInputs = [
      git
      nodejs_24
    ];
  };

  envBase = {
    npm_config_arch = pnpmArch;
    npm_config_platform = pnpmPlatform;
    PNPM_CONFIG_MANAGE_PACKAGE_MANAGER_VERSIONS = "false";
    npm_config_nodedir = nodejs_24;
    npm_config_python = python3;
    NODE_PATH = "${nodeAddonApi}/lib/node_modules:${node-gyp}/lib/node_modules";
    PNPM_DEPS = pnpmDeps;
    OPENCLAW_BUILD_ROOT_SH = "${../scripts/build-root.sh}";
    NODE_GYP_WRAPPER_SH = "${../scripts/node-gyp-wrapper.sh}";
    GATEWAY_PREBUILD_SH = "${../scripts/gateway-prebuild.sh}";
    PATCH_BUNDLED_RUNTIME_DEPS_SCRIPT = "${../patches/stage-bundled-plugin-runtime-deps.mjs}";
    PATCH_PUBLIC_SURFACE_HARDLINKS =
      if sourceInfo.applyPublicSurfaceHardlinksPatch or true then
        "${publicSurfaceHardlinksPatch}"
      else
        "";
    PATCH_SKIP_PLUGIN_AUTO_ENABLE_NIX_MODE =
      if sourceInfo.applySkipPluginAutoEnableNixModePatch or true then
        "${../patches/skip-plugin-auto-enable-persist-in-nix-mode.patch}"
      else
        "";
    PATCH_NIX_STORE_PLUGIN_OWNERSHIP =
      if sourceInfo.applyNixStorePluginOwnershipPatch or false then
        "${../patches/allow-nix-store-plugin-ownership.patch}"
      else
        "";
    PROMOTE_PNPM_INTEGRITY_SH = "${../scripts/promote-pnpm-integrity.sh}";
    REMOVE_PACKAGE_MANAGER_FIELD_SH = "${../scripts/remove-package-manager-field.sh}";
    STDENV_SETUP = "${stdenv}/setup";
  }
  // lib.optionalAttrs (fsSafeSource != null) {
    OPENCLAW_FS_SAFE_SOURCE = fsSafeSource;
  };

in
{
  inherit
    version
    pnpmDeps
    pnpmMajor
    resolvedSrc
    pnpmPlatform
    pnpmArch
    nodeAddonApi
    selectedPnpm
    ;

  nativeBuildInputs = [
    nodejs_24
    selectedPnpm
    pkg-config
    jq
    python3
    node-gyp
    zstd
  ]
  ++ extraNativeBuildInputs;

  buildInputs = extraBuildInputs;

  env = envBase // (lib.optionalAttrs enableSharp { SHARP_IGNORE_GLOBAL_LIBVIPS = "1"; }) // extraEnv;

  passthru = {
    inherit
      sourceInfo
      pnpmDeps
      pnpmMajor
      selectedPnpm
      ;
    pinnedRev = sourceInfo.rev;
  };
}
