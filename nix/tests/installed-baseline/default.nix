{ system }:

let
  revision = "5f849be411261d4b5d4e06ca0becc4d23526ffda";
  baseline = builtins.getFlake "github:openclaw/nix-openclaw/${revision}";
  current = builtins.getFlake "git+file://${toString ../../..}";
  darwin = system == "aarch64-darwin";
  username = if darwin then "runner" else "baseline";
  homeDirectory =
    if darwin then "/tmp/openclaw-installed-baseline" else "/home/baseline/qualification";
  mkStage =
    flake: nodeMajor:
    let
      pkgs = import flake.inputs.nixpkgs {
        inherit system;
        overlays = [ flake.overlays.default ];
      };
      home = flake.inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          flake.homeManagerModules.openclaw
          {
            home = {
              inherit username homeDirectory;
              stateVersion = "23.11";
            };
            programs.openclaw = {
              enable = true;
              installApp = false;
              instances.baseline = {
                stateDir = "${homeDirectory}/.openclaw-baseline";
                configPath = "${homeDirectory}/.openclaw-baseline/openclaw.json";
                workspaceDir = "${homeDirectory}/.openclaw-baseline/workspace";
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
                    auth.token = "fixture";
                  };
                };
              };
            };
          }
        ];
      };
      bundle = flake.packages.${system}.default;
      activation =
        assert home.config.programs.openclaw.instances.baseline.package.outPath == bundle.outPath;
        assert !home.config.submoduleSupport.externalPackageInstall;
        home.activationPackage;
      homeManager = flake.inputs.home-manager.packages.${system}.home-manager;
    in
    {
      inherit activation bundle pkgs;
      evidence = {
        revision = flake.rev;
        inherit nodeMajor;
        lock = builtins.fromJSON (builtins.readFile "${flake.outPath}/flake.lock");
        source = import "${flake.outPath}/nix/sources/openclaw-source.nix";
        bundle = bundle.outPath;
        activation = activation.outPath;
        node = "${pkgs."nodejs_${toString nodeMajor}"}/bin/node";
        homeManager = "${homeManager}/bin/home-manager";
        automaticServiceSwitch = if darwin then true else home.config.systemd.user.startServices;
      };
    };
  old = mkStage baseline 22;
  new = mkStage current 24;
  pkgs = old.pkgs;
  evidence = {
    inherit system homeDirectory;
    old = old.evidence;
    current = new.evidence;
  };
  inputs = pkgs.writeText "installed-upgrade-inputs.json" (builtins.toJSON evidence);
in
assert builtins.elem system [ "x86_64-linux" "aarch64-darwin" ];
{
  inherit inputs evidence;
  cacheConfig = map (flake: (import "${flake.outPath}/flake.nix").nixConfig) [
    baseline
    current
  ];
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
        "installed-baseline/inputs.json".source = inputs;
        "installed-baseline/probe".source = ./.;
      };
    };
    testScript = builtins.readFile ./linux.py;
  };
}
