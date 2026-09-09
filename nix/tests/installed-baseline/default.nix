{ system }:

let
  revision = "5f849be411261d4b5d4e06ca0becc4d23526ffda";
  baseline = builtins.getFlake "github:openclaw/nix-openclaw/${revision}";
  pkgs = import baseline.inputs.nixpkgs {
    inherit system;
    overlays = [ baseline.overlays.default ];
  };
  darwin = system == "aarch64-darwin";
  username = if darwin then "runner" else "baseline";
  homeDirectory =
    if darwin then "/tmp/openclaw-installed-baseline" else "/home/baseline/qualification";
  home = baseline.inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      baseline.homeManagerModules.openclaw
      {
        home = {
          inherit username homeDirectory;
          stateVersion = "23.11";
        };
        programs.openclaw = {
          enable = true;
          installApp = false;
          instances.baseline = {
            gatewayPort = 18997;
            logPath = "${homeDirectory}/gateway.log";
            appDefaults.enable = false;
            launchd.label = "org.openclaw.nix.installed-baseline";
            systemd.unitName = "openclaw-installed-baseline";
            config = {
              logging.file = "${homeDirectory}/gateway-runtime.log";
              gateway = {
                mode = "local";
                bind = "loopback";
                auth.token = "installed-baseline-fixture-token";
              };
            };
          };
        };
      }
    ];
  };
  bundle = baseline.packages.${system}.default;
  activation =
    assert home.config.programs.openclaw.instances.baseline.package.outPath == bundle.outPath;
    assert !home.config.submoduleSupport.externalPackageInstall;
    home.activationPackage;
in
assert builtins.elem system [ "x86_64-linux" "aarch64-darwin" ];
{
  inherit activation;
  cacheConfig = (import "${baseline.outPath}/flake.nix").nixConfig;
  evidence = {
    inherit revision system homeDirectory;
    lock = builtins.fromJSON (builtins.readFile "${baseline.outPath}/flake.lock");
    source = import "${baseline.outPath}/nix/sources/openclaw-source.nix";
    appRecipe = builtins.readFile "${baseline.outPath}/nix/packages/openclaw-app.nix";
    bundle = bundle.outPath;
    activation = activation.outPath;
    node = "${pkgs.nodejs_22}/bin/node";
    gateway = baseline.packages.${system}.openclaw-gateway.outPath;
  };
  linux = pkgs.testers.nixosTest {
    name = "openclaw-installed-baseline";
    nodes.machine = {
      users.users.baseline = {
        isNormalUser = true;
        uid = 1000;
        home = homeDirectory;
        createHome = false;
      };
      systemd.tmpfiles.rules = [ "d /home/baseline 0700 baseline users -" ];
      # Standalone HM owns the user profile; no NixOS HM module is imported.
      virtualisation.writableStore = true;
      virtualisation.memorySize = 4096;
      environment.systemPackages = [ pkgs.python3 ];
      environment.etc = {
        "installed-baseline/activation".source = activation;
        "installed-baseline/bundle".source = bundle;
        "installed-baseline/node".source = pkgs.nodejs_22;
        "installed-baseline/probe.py".source = ./probe.py;
      };
    };
    testScript = builtins.readFile ./linux.py;
  };
}
