{
  description = "nix-clawdbot: declarative Clawdbot packaging";

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
    nix-steipete-tools.url = "github:clawdbot/nix-steipete-tools";
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, nix-steipete-tools }:
    let
      overlay = import ./nix/overlay.nix;
      sourceInfoStable = import ./nix/sources/clawdbot-source.nix;
      systems = [ "x86_64-linux" "aarch64-darwin" ];
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
          default = packageSetStable.clawdbot;
        };

        apps = {
          clawdbot = flake-utils.lib.mkApp { drv = packageSetStable.clawdbot-gateway; };
        };

        checks = {
          gateway = packageSetStable.clawdbot-gateway;
        } // (if pkgs.stdenv.hostPlatform.isLinux then {
          gateway-tests = pkgs.callPackage ./nix/checks/clawdbot-gateway-tests.nix {
            sourceInfo = sourceInfoStable;
          };
          config-options = pkgs.callPackage ./nix/checks/clawdbot-config-options.nix {
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
      homeManagerModules.clawdbot = import ./nix/modules/home-manager/clawdbot.nix;
      darwinModules.clawdbot = import ./nix/modules/darwin/clawdbot.nix;

      templates = {
        agent-first = {
          path = ./templates/agent-first;
          description = "Agent-first template for clawdbot";
        };
      };
    };
}
