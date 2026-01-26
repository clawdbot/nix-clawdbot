{
  description = "nix-moltbot: declarative Moltbot packaging";

  nixConfig = {
    extra-substituters = [ "https://cache.garnix.io" ];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-steipete-tools.url = "github:moltbot/nix-steipete-tools";
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, nix-steipete-tools }:
    let
      overlay = import ./nix/overlay.nix;
      sourceInfoStable = import ./nix/sources/moltbot-source.nix;
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
    in
    flake-utils.lib.eachSystem systems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
        steipetePkgs = if nix-steipete-tools ? packages && builtins.hasAttr system nix-steipete-tools.packages
          then nix-steipete-tools.packages.${system}
          else {};
        packageSetStable = import ./nix/packages {
          pkgs = pkgs;
          sourceInfo = sourceInfoStable;
          steipetePkgs = steipetePkgs;
        };
      in
      {
        packages = packageSetStable // {
          default = packageSetStable.moltbot;
        };

        apps = {
          moltbot = flake-utils.lib.mkApp { drv = packageSetStable.moltbot-gateway; };
        };

        checks = {
          gateway = packageSetStable.moltbot-gateway;
        } // (if pkgs.stdenv.hostPlatform.isLinux then {
          gateway-tests = pkgs.callPackage ./nix/checks/moltbot-gateway-tests.nix {
            sourceInfo = sourceInfoStable;
          };
          config-options = pkgs.callPackage ./nix/checks/moltbot-config-options.nix {
            sourceInfo = sourceInfoStable;
          };
        } else {});

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.git
            pkgs.nixfmt-rfc-style
            pkgs.nil
          ];
        };
      }
    ) // {
      overlays.default = overlay;
      homeManagerModules.moltbot = import ./nix/modules/home-manager/moltbot.nix;
      darwinModules.moltbot = import ./nix/modules/darwin/moltbot.nix;
      nixosModules.moltbot = import ./nix/modules/nixos/moltbot.nix;
    };
}
