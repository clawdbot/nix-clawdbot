{
  lib,
  stdenv,
  stdenvNoCC,
  autoPatchelfHook,
  fetchurl,
  nodejs_24,
}:

let
  platformSource =
    {
      aarch64-darwin = {
        package = "exe.darwin-arm64";
        hash = "sha256-9UrTZ9ikLa+dhIMOS9akXAlX4OMoekXaCMOguNBOx/c=";
      };
      x86_64-linux = {
        package = "exe.linux-x64";
        hash = "sha256-mxyV/EE2AMp1pR6+gzLXAZ3DVo/UGH9aXy30oVbvtlw=";
      };
    }
    .${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported pnpm 12 platform ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "pnpm";
  version = "12.3.4";

  src = fetchurl {
    url = "https://registry.npmjs.org/@pnpm/${platformSource.package}/-/${platformSource.package}-${finalAttrs.version}.tgz";
    hash = platformSource.hash;
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall

    install -d $out/bin $out/libexec/pnpm
    cp pnpm $out/libexec/pnpm/pnpm
    chmod +x $out/libexec/pnpm/pnpm
    substitute ${../scripts/pnpm-exe-wrapper.sh} $out/bin/pnpm \
      --subst-var-by entrypoint $out/libexec/pnpm/pnpm
    substitute ${../scripts/pnpm-exe-wrapper.sh} $out/bin/pnpx \
      --subst-var-by entrypoint $out/libexec/pnpm/pnpm
    chmod +x $out/bin/pnpm $out/bin/pnpx

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    tmp="$(mktemp -d)"
    mkdir -p "$tmp/home" "$tmp/project"
    printf '{"packageManager":"pnpm@12.99.99"}\n' > "$tmp/project/package.json"
    (
      cd "$tmp/project"
      version="$(HOME="$tmp/home" $out/bin/pnpm --version)"
      test "$version" = "${finalAttrs.version}"
    )
    rm -rf "$tmp"

    runHook postInstallCheck
  '';

  passthru = {
    majorVersion = lib.versions.major finalAttrs.version;
    nodejs = nodejs_24;
    "nodejs-slim" = nodejs_24;
  };

  meta = {
    description = "Fast, disk space efficient package manager for JavaScript";
    homepage = "https://pnpm.io/";
    changelog = "https://github.com/pnpm/pnpm/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "pnpm";
  };
})
