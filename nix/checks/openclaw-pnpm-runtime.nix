{
  stdenvNoCC,
  nodejs_24,
  pnpm_11,
  pnpm_12,
}:

stdenvNoCC.mkDerivation {
  pname = "openclaw-pnpm-runtime";
  version = "1";

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ nodejs_24 ];

  env = {
    PNPM_11_PACKAGE = pnpm_11;
    PNPM_12_PACKAGE = pnpm_12;
  };

  doCheck = true;
  checkPhase = "${../scripts/check-openclaw-pnpm-runtime.sh}";
  installPhase = "${../scripts/empty-install.sh}";
}
