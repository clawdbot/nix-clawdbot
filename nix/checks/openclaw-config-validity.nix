{
  lib,
  pkgs,
  stdenv,
  nodejs_22,
  openclawGateway,
  includeRuntimePluginSmoke ? false,
}:

let
  runtimePluginSmokeId = "slack";
  stubModule =
    { lib, ... }:
    {
      options = {
        assertions = lib.mkOption {
          type = lib.types.listOf lib.types.attrs;
          default = [ ];
        };

        home.homeDirectory = lib.mkOption {
          type = lib.types.str;
          default = "/tmp";
        };

        home.packages = lib.mkOption {
          type = lib.types.listOf lib.types.anything;
          default = [ ];
        };

        home.file = lib.mkOption {
          type = lib.types.attrs;
          default = { };
        };

        home.activation = lib.mkOption {
          type = lib.types.attrs;
          default = { };
        };

        launchd.agents = lib.mkOption {
          type = lib.types.attrs;
          default = { };
        };

        systemd.user.services = lib.mkOption {
          type = lib.types.attrs;
          default = { };
        };

        programs.git.enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };

        lib = lib.mkOption {
          type = lib.types.attrs;
          default = { };
        };
      };
    };

  runtimePluginModuleConfig = lib.optionalAttrs includeRuntimePluginSmoke {
    runtimePlugins = [ runtimePluginSmokeId ];
  };
  runtimePluginOpenClawConfig = lib.optionalAttrs includeRuntimePluginSmoke {
    channels.slack = {
      enabled = true;
      appToken.source = "env";
      appToken.provider = "env";
      appToken.id = "SLACK_APP_TOKEN";
      botToken.source = "env";
      botToken.provider = "env";
      botToken.id = "SLACK_BOT_TOKEN";
    };
  };

  moduleEval = lib.evalModules {
    modules = [
      stubModule
      ../modules/home-manager/openclaw.nix
      (
        { lib, ... }:
        {
          config = {
            home.homeDirectory = "/tmp";
            programs.git.enable = false;
            lib.file.mkOutOfStoreSymlink = path: path;
            programs.openclaw = {
              enable = true;
              launchd.enable = false;
              systemd.enable = false;
              instances.default = {
                workspaceDir = expectedWorkspace;
                config = {
                  channels.telegram = {
                    enabled = true;
                    botToken = "123456:test-token";
                    dmPolicy = "open";
                    groupPolicy = "disabled";
                    allowFrom = [ "*" ];
                  };
                }
                // runtimePluginOpenClawConfig;
              };
            }
            // runtimePluginModuleConfig;
          };
        }
      )
    ];
    specialArgs = { inherit pkgs; };
  };

  configPathKey = ".openclaw/openclaw.json";
  openclawLib = import ../modules/home-manager/openclaw/lib.nix {
    inherit lib pkgs;
    config = moduleEval.config;
  };
  renderedConfig = builtins.fromJSON moduleEval.config.home.file."${configPathKey}".text;
  configFile =
    assert !openclawLib.usesAgentEntries || renderedConfig.agents.entries == { main = { }; };
    moduleEval.config.home.file."${configPathKey}".source;
  expectedWorkspace = "/tmp/openclaw-explicit-workspace";

in
stdenv.mkDerivation {
  pname =
    if includeRuntimePluginSmoke then
      "openclaw-runtime-plugin-config-validity"
    else
      "openclaw-config-validity";
  version = lib.getVersion openclawGateway;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [
    nodejs_22
  ]
  ++ lib.optional includeRuntimePluginSmoke pkgs.openclawRuntimePlugins.${runtimePluginSmokeId};

  env = {
    OPENCLAW_CONFIG_PATH = configFile;
    OPENCLAW_GATEWAY = openclawGateway;
    OPENCLAW_EXPECTED_WORKSPACE = expectedWorkspace;
  }
  // lib.optionalAttrs includeRuntimePluginSmoke {
    OPENCLAW_RUNTIME_PLUGIN_SMOKE_ID = runtimePluginSmokeId;
  };

  doCheck = true;
  checkPhase = "${nodejs_22}/bin/node ${../scripts/check-config-validity.mjs}";
  installPhase = "${../scripts/empty-install.sh}";
}
