{
  lib,
  stdenvNoCC,
  fetchurl,
  fetchNpmDeps,
  npmHooks,
  nodejs_24,
  cctools,
  cacert,
  openclawPackage ? null,
  linkOpenClawPeer ? openclawPackage != null,
}:

lock:

let
  runtimeEntries =
    (lock.runtimeExtensions or [ ])
    ++ lib.optional ((lock.runtimeSetupEntry or null) != null) lock.runtimeSetupEntry;
  runtimeEntriesFile = builtins.toFile "openclaw-runtime-plugin-${lock.id}-runtime-entries" (
    (lib.concatStringsSep "\n" runtimeEntries) + "\n"
  );
  bundledPackageRootsFile =
    builtins.toFile "openclaw-runtime-plugin-${lock.id}-bundled-package-roots"
      ((lib.concatStringsSep "\n" (lock.bundledPackageRoots or [ ])) + "\n");
  npmHooksForNode = npmHooks.override { nodejs = nodejs_24; };
  sourceHash = lock.nixHash or lock.hash;
  pluginSrc =
    if (lock.tarballUrl or null) != null then
      fetchurl {
        url = lock.tarballUrl;
        hash = sourceHash;
      }
    else if (lock.sourceUrl or null) != null then
      if lib.hasPrefix "https://" lock.sourceUrl then
        fetchurl {
          name = "${packageName}-source.tgz";
          url = lock.sourceUrl;
          hash = sourceHash;
        }
      else
        throw "runtime plugin ${lock.id} sourceUrl must be an HTTPS npm-pack tarball URL"
    else if (lock.sourceSpec or null) != null then
      stdenvNoCC.mkDerivation {
        name = "${packageName}-source.tgz";
        dontUnpack = true;
        dontConfigure = true;
        dontBuild = true;
        nativeBuildInputs = [
          nodejs_24
          cacert
        ];
        SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
        outputHashMode = "flat";
        outputHashAlgo = "sha256";
        outputHash = sourceHash;
        installPhase = ''
          ${nodejs_24}/bin/node ${../scripts/openclaw-runtime-plugin-fetch-source.mjs} \
            ${lib.escapeShellArg lock.sourceSpec} "$out"
        '';
      }
    else
      throw "runtime plugin ${lock.id} must define tarballUrl, sourceUrl, or sourceSpec";
  dependencyMode =
    lock.dependencyMode or (if (lock.npmDepsHash or null) != null then "shrinkwrap" else "auto");
  isLocked = builtins.elem dependencyMode [ "shrinkwrap" "package-lock" ];
  packageLockEnv = lib.optionalAttrs (dependencyMode == "package-lock") {
    OPENCLAW_RUNTIME_PLUGIN_PACKAGE_LOCK_FILE =
      "${../generated/openclaw-runtime-plugins}/${lock.npmPackageLockFile}";
  };
  hasRuntimeDependencies =
    (lock.dependencies or { }) != { } || (lock.optionalDependencies or { }) != { };
  safeName = lib.replaceStrings [ "@" "/" ":" ] [ "" "-" "-" ] lock.id;
  packageName = "openclaw-runtime-plugin-${safeName}";
  peerLinkIsValid = !linkOpenClawPeer || openclawPackage != null;

  drv = stdenvNoCC.mkDerivation (
    {
      pname = packageName;
      version = lock.version or "locked";

      src = pluginSrc;

      sourceRoot = "package";

      nativeBuildInputs = [
        nodejs_24
      ]
      ++ lib.optionals isLocked [
        nodejs_24.python
        npmHooksForNode.npmConfigHook
      ]
      ++ lib.optionals (isLocked && stdenvNoCC.hostPlatform.isDarwin) [ cctools ];

      npmInstallFlags = lib.optionals isLocked [
        "--omit=dev"
        "--omit=peer"
        "--legacy-peer-deps"
      ];

      npmRebuildFlags = lib.optionals isLocked [ "--ignore-scripts" ];

      dontConfigure = true;
      dontBuild = true;

      postPatch = lib.optionalString isLocked ''
        ${nodejs_24}/bin/node ${../scripts/openclaw-runtime-plugin-prepare-npm.mjs}
      '';

      env = {
        OPENCLAW_RUNTIME_PLUGIN_ID = lock.id;
        OPENCLAW_RUNTIME_PLUGIN_PACKAGE_NAME = lock.packageName or "";
        OPENCLAW_RUNTIME_PLUGIN_VERSION = lock.version or "";
        OPENCLAW_RUNTIME_PLUGIN_RUNTIME_ENTRIES_FILE = runtimeEntriesFile;
        OPENCLAW_RUNTIME_PLUGIN_BUNDLED_PACKAGE_ROOTS_FILE = bundledPackageRootsFile;
        OPENCLAW_RUNTIME_PLUGIN_HAS_RUNTIME_DEPENDENCIES =
          if (lock.dependencies or null) != null || (lock.optionalDependencies or null) != null then
            (if hasRuntimeDependencies then "1" else "0")
          else
            "";
        OPENCLAW_RUNTIME_PLUGIN_DEPENDENCY_MODE = dependencyMode;
        OPENCLAW_RUNTIME_PLUGIN_LINK_PEER_OPENCLAW = if linkOpenClawPeer then "1" else "0";
      }
      // packageLockEnv
      // lib.optionalAttrs linkOpenClawPeer {
        OPENCLAW_GATEWAY_PACKAGE = "${openclawPackage}";
      }
      // lib.optionalAttrs ((lock.openclawCompat or null) != null) {
        OPENCLAW_RUNTIME_PLUGIN_COMPAT = lock.openclawCompat;
      }
      // lib.optionalAttrs ((lock.peerOpenClaw or null) != null) {
        OPENCLAW_RUNTIME_PLUGIN_PEER_OPENCLAW = lock.peerOpenClaw;
      };

      installPhase = "${nodejs_24}/bin/node ${../scripts/openclaw-runtime-plugin-install.mjs}";

      passthru.openclawRuntimePlugin = {
        inherit (lock) id;
        source = lock.selectedSource or "npm";
        loadPath = drv;
      }
      // lib.optionalAttrs ((lock.packageName or null) != null) {
        packageName = lock.packageName;
      }
      // lib.optionalAttrs ((lock.version or null) != null) {
        version = lock.version;
      }
      // lib.optionalAttrs ((lock.npmIntegrity or null) != null) {
        npmIntegrity = lock.npmIntegrity;
      };

      meta = with lib; {
        description = "Nix-packaged OpenClaw runtime plugin ${lock.id}";
        homepage = "https://github.com/openclaw/openclaw";
        license = licenses.mit;
        platforms = platforms.darwin ++ platforms.linux;
      };
    }
    // lib.optionalAttrs isLocked {
      npmDeps = fetchNpmDeps ({
        name = "${packageName}-npm-deps";
        src = pluginSrc;
        sourceRoot = "package";
        hash = lock.npmDepsHash;
        nativeBuildInputs = [ nodejs_24 ];
        OPENCLAW_RUNTIME_PLUGIN_DEPENDENCY_MODE = dependencyMode;
        OPENCLAW_RUNTIME_PLUGIN_PACKAGE_NAME = lock.packageName or "";
        OPENCLAW_RUNTIME_PLUGIN_VERSION = lock.version or "";
        postPatch = ''
          ${nodejs_24}/bin/node ${../scripts/openclaw-runtime-plugin-prepare-npm.mjs}
        '';
      } // packageLockEnv);
    }
  );
in
assert lib.assertMsg peerLinkIsValid
  "openclaw-runtime-plugin ${lock.id} cannot link its OpenClaw peer without openclawPackage";
drv
