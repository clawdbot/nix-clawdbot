{
  description = "nix-openclaw: declarative OpenClaw packaging";

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
    nix-openclaw-tools.url = "github:openclaw/nix-openclaw-tools";
    qmd.url = "github:tobi/qmd/v2.8.3";
    qmd.inputs.flake-utils.follows = "flake-utils";
    qmd.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      home-manager,
      nix-openclaw-tools,
      qmd,
    }:
    let
      openclawToolPkgsFor =
        system:
        if nix-openclaw-tools ? packages && builtins.hasAttr system nix-openclaw-tools.packages then
          nix-openclaw-tools.packages.${system}
        else
          { };
      qmdPkgsFor =
        system:
        if qmd ? packages && builtins.hasAttr system qmd.packages then qmd.packages.${system} else { };
      overlay =
        final: prev:
        import ./nix/overlay.nix {
          openclawToolPkgs = openclawToolPkgsFor prev.stdenv.hostPlatform.system;
          qmdPkgs = qmdPkgsFor prev.stdenv.hostPlatform.system;
        } final prev;
      sourceInfoStable = import ./nix/sources/openclaw-source.nix;
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
    in
    flake-utils.lib.eachSystem systems (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
        openclawToolPkgs = openclawToolPkgsFor system;
        qmdPkgs = qmdPkgsFor system;
        qmdPackage =
          if pkgs.stdenv.hostPlatform.isDarwin then
            openclawToolPkgs.qmd or null
          else
            qmdPkgs.qmd or qmdPkgs.default or null;
        packageSetStable = import ./nix/packages {
          pkgs = pkgs;
          sourceInfo = sourceInfoStable;
          openclawToolPkgs = openclawToolPkgs;
          inherit qmdPackage;
        };
        runtimePluginPackageOutputs = pkgs.lib.mapAttrs' (
          id: package: pkgs.lib.nameValuePair "openclaw-runtime-plugin-${id}" package
        ) packageSetStable.openclawRuntimePlugins;
      in
      {
        formatter = pkgs.nixfmt-tree.override {
          settings = {
            global.excludes = [ "nix/generated/openclaw-config-options.nix" ];
          };
        };

        packages =
          (builtins.removeAttrs packageSetStable [ "openclawRuntimePlugins" ])
          // {
            default = packageSetStable.openclaw;
          }
          // runtimePluginPackageOutputs;

        apps = {
          openclaw = flake-utils.lib.mkApp { drv = packageSetStable.openclaw; };
        };

        checks =
          let
            stableChecks = {
              gateway = packageSetStable.openclaw-gateway;
              overlay = pkgs.callPackage ./nix/checks/openclaw-overlay.nix {
                inherit nixpkgs system overlay;
              };
              bin-surface = pkgs.callPackage ./nix/checks/openclaw-bin-surface.nix {
                openclawPackage = packageSetStable.openclaw;
              };
              package-contents = pkgs.callPackage ./nix/checks/openclaw-package-contents.nix {
                openclawGateway = packageSetStable.openclaw-gateway;
              };
              default-instance = pkgs.callPackage ./nix/checks/openclaw-default-instance.nix {
                includeQmdChecks = false;
              };
              source-override-render = pkgs.callPackage ./nix/checks/openclaw-default-instance.nix {
                includeSourceOverrideChecks = true;
              };
              workspace-materializer = pkgs.callPackage ./nix/checks/openclaw-workspace-materializer.nix { };
              pnpm-runtime = pkgs.callPackage ./nix/checks/openclaw-pnpm-runtime.nix {
                inherit (packageSetStable) pnpm_11 pnpm_12;
              };
              config-validity = pkgs.callPackage ./nix/checks/openclaw-config-validity.nix {
                openclawGateway = packageSetStable.openclaw-gateway;
                includeRuntimePluginSmoke = false;
              };
              gateway-smoke = pkgs.callPackage ./nix/checks/openclaw-gateway-smoke.nix {
                openclawGateway = packageSetStable.openclaw-gateway;
                includeRuntimePluginSmoke = false;
              };
            };
            qmdChecks = {
              qmd-instance = pkgs.callPackage ./nix/checks/openclaw-default-instance.nix {
                includeQmdChecks = true;
              };
              qmd-runtime = pkgs.callPackage ./nix/checks/openclaw-qmd-runtime.nix {
                openclawPackage = packageSetStable.openclaw;
                inherit qmdPackage;
              };
            };
            pluginChecks = {
              plugin-instance = pkgs.callPackage ./nix/checks/openclaw-default-instance.nix {
                includePluginChecks = true;
              };
            };
            runtimePluginChecks = {
              runtime-plugin-config-validity = pkgs.callPackage ./nix/checks/openclaw-config-validity.nix {
                openclawGateway = packageSetStable.openclaw-gateway;
                includeRuntimePluginSmoke = true;
              };
              runtime-plugin-gateway-smoke = pkgs.callPackage ./nix/checks/openclaw-gateway-smoke.nix {
                openclawGateway = packageSetStable.openclaw-gateway;
                includeRuntimePluginSmoke = true;
              };
              runtime-plugin-locks = pkgs.callPackage ./nix/checks/openclaw-runtime-plugin-locks.nix { };
              runtime-plugin-packages = pkgs.symlinkJoin {
                name = "openclaw-runtime-plugin-packages";
                paths = builtins.attrValues packageSetStable.openclawRuntimePlugins;
              };
            };
            linuxOnlyChecks = pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
              hm-activation = import ./nix/checks/openclaw-hm-activation.nix {
                inherit pkgs home-manager;
              };
            };
            darwinOnlyChecks = pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
              hm-activation-macos-package =
                (home-manager.lib.homeManagerConfiguration {
                  inherit pkgs;
                  modules = [
                    self.homeManagerModules.openclaw
                    ./nix/tests/hm-activation-macos/home.nix
                  ];
                }).activationPackage;
            };
            packageArtifactPaths =
              [
                packageSetStable.openclaw
                packageSetStable.openclaw-gateway
                stableChecks.bin-surface
                stableChecks.package-contents
                stableChecks.pnpm-runtime
              ]
              ++ pkgs.lib.optionals (packageSetStable ? openclaw-app && packageSetStable.openclaw-app != null) [
                packageSetStable.openclaw-app
              ];
            proofChecks = {
              # Product artifacts: user-facing package plus component packages
              # and content/surface checks that prove those artifacts are sane.
              package-artifacts = pkgs.symlinkJoin {
                name = "openclaw-package-artifacts";
                paths = packageArtifactPaths;
              };
              # Module render: pure Home Manager/module materialization checks.
              module-render = pkgs.symlinkJoin {
                name = "openclaw-module-render";
                paths = [
                  stableChecks.overlay
                  stableChecks.default-instance
                  stableChecks.source-override-render
                  stableChecks.workspace-materializer
                ];
              };
              # Runtime smoke: gateway/config checks for the default runtime path.
              runtime-smoke = pkgs.symlinkJoin {
                name = "openclaw-runtime-smoke";
                paths = [
                  stableChecks.config-validity
                  stableChecks.gateway-smoke
                ];
              };
              # Runtime plugin host contract: lock consistency plus module/config
              # and gateway behavior when packaged plugin roots are enabled.
              runtime-plugin-host = pkgs.symlinkJoin {
                name = "openclaw-runtime-plugin-host";
                paths = [
                  runtimePluginChecks.runtime-plugin-locks
                  pluginChecks.plugin-instance
                  runtimePluginChecks.runtime-plugin-config-validity
                  runtimePluginChecks.runtime-plugin-gateway-smoke
                ];
              };
              # QMD opt-in: local memory backend only when users enable it.
              qmd-opt-in = pkgs.symlinkJoin {
                name = "openclaw-qmd-opt-in";
                paths = [
                  qmdChecks.qmd-instance
                  qmdChecks.qmd-runtime
                ];
              };
            }
            // pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
              platform-activation = linuxOnlyChecks.hm-activation;
            }
            // pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
              platform-activation = darwinOnlyChecks.hm-activation-macos-package;
            };
          in
          stableChecks
          // qmdChecks
          // pluginChecks
          // runtimePluginChecks
          // linuxOnlyChecks
          // darwinOnlyChecks
          // proofChecks;

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.git
            pkgs.nixfmt-tree
            pkgs.nil
          ];
        };
      }
    )
    // {
      overlays.default = overlay;
      templates.agent-first = {
        path = ./templates/agent-first;
        description = "Agent-first Home Manager setup for OpenClaw through Nix.";
      };
      nixosModules.openclaw-gateway = import ./nix/modules/nixos/openclaw-gateway.nix;
      homeManagerModules.openclaw = import ./nix/modules/home-manager/openclaw.nix;
      darwinModules.openclaw = import ./nix/modules/darwin/openclaw.nix;
    };
}
