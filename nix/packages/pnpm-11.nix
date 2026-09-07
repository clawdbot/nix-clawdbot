{
  lib,
  stdenvNoCC,
  fetchurl,
  nodejs_22,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "pnpm";
  version = "11.26.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/pnpm/-/pnpm-${finalAttrs.version}.tgz";
    hash = "sha256-wzIgfnOPhLfM+V1fIfb98QsNxbEz8KNJg0om/RerrNg=";
  };

  preConfigure = ''
    rm -rf dist/reflink.*node dist/vendor
  '';

  buildInputs = [ nodejs_22 ];
  nativeBuildInputs = [ nodejs_22 ];

  installPhase = ''
    runHook preInstall

    install -d $out/{bin,libexec}
    cp -R . $out/libexec/pnpm
    chmod +x $out/libexec/pnpm/bin/pnpm.cjs $out/libexec/pnpm/bin/pnpx.cjs
    substitute ${../scripts/pnpm-11-wrapper.sh} $out/bin/pnpm \
      --subst-var-by node ${nodejs_22}/bin/node \
      --subst-var-by entrypoint $out/libexec/pnpm/bin/pnpm.cjs
    substitute ${../scripts/pnpm-11-wrapper.sh} $out/bin/pnpx \
      --subst-var-by node ${nodejs_22}/bin/node \
      --subst-var-by entrypoint $out/libexec/pnpm/bin/pnpx.cjs
    chmod +x $out/bin/pnpm $out/bin/pnpx

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    tmp="$(mktemp -d)"
    mkdir -p "$tmp/home" "$tmp/project"
    printf '{"packageManager":"pnpm@11.99.99"}\n' > "$tmp/project/package.json"
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
    nodejs = nodejs_22;
    "nodejs-slim" = nodejs_22;
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
