{
  lib,
  stdenv,
  nodejs_24,
  openclawGateway,
}:

stdenv.mkDerivation {
  pname = "openclaw-package-contents";
  version = lib.getVersion openclawGateway;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  env = {
    OPENCLAW_GATEWAY = openclawGateway;
  };

  doCheck = true;
  nativeCheckInputs = [ nodejs_24 ];
  checkPhase = "${../scripts/check-package-contents.sh}";
  installPhase = "${../scripts/empty-install.sh}";
}
