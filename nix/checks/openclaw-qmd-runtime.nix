{
  lib,
  stdenvNoCC,
  nodejs_22,
  openclawPackage,
  qmdPackage ? null,
}:

stdenvNoCC.mkDerivation {
  pname = "openclaw-qmd-runtime";
  version = lib.getVersion openclawPackage;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  nativeBuildInputs = [ nodejs_22 ];

  env = {
    OPENCLAW_PACKAGE = openclawPackage;
    QMD_PACKAGE = lib.optionalString (qmdPackage != null) "${qmdPackage}";
    OPENCLAW_QMD_BACKEND_SUPPORTED = lib.boolToString
      (import ../lib/openclaw-config-capabilities.nix { inherit lib; }).supportsQmdBackend;
  };

  doCheck = true;
  checkPhase = "${../scripts/check-openclaw-qmd-runtime.sh} ${../scripts/check-openclaw-qmd-config.mjs}";
  installPhase = "${../scripts/empty-install.sh}";
}
