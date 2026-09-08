{ config, lib, pkgs, ... }:

let
  openclawLib = import ../../modules/home-manager/openclaw/lib.nix {
    inherit config lib pkgs;
  };
in
{
  home = {
    username = "runner";
    homeDirectory = "/tmp/hm-activation-home";
    stateVersion = "23.11";
  };
  manual = {
    html.enable = false;
    json.enable = false;
    manpages.enable = false;
  };

  programs.openclaw = {
    enable = true;
    installApp = false;
    skills = [
      {
        name = "activation-skill";
        mode = "inline";
        description = "Synthetic activation fixture";
      }
      {
        name = "copied-skill";
        mode = "copy";
        source = toString ../plugins/alpha/skill;
      }
    ];
    workspace = {
      pinAgentDefaults = false;
      files."LORE.md" = ../workspace/LORE.md;
    };
    runtimePackages = [ pkgs.jq ];
    environment.OPENCLAW_TEST_SECRET = "/tmp/openclaw-secret";
    instances.default = {
      stateDir = "~/openclaw state";
      configPath = "~/openclaw state/config with spaces and 'quotes'.json";
      workspaceDir = "~/custom workspace";
      gatewayPort = 18999;
      logPath = "/tmp/hm-activation-home/.openclaw/openclaw-gateway.log";
      launchd.label = "com.steipete.openclaw.gateway.hm-test";
      config = {
        agents.defaults.workspace = "/tmp/hm-activation-home/custom workspace";
        logging = {
          level = "debug";
          file = "/tmp/hm-activation-home/.openclaw/openclaw-gateway.log";
        };
        gateway = {
          mode = "local";
          auth = {
            token = "hm-activation-test-token";
          };
        };
      };
    };
    instances.implicit = {
      launchd.enable = false;
      systemd.enable = false;
      config = lib.optionalAttrs openclawLib.usesAgentEntries {
        agents.entries = { };
      };
    };
    instances.roster = {
      launchd.enable = false;
      systemd.enable = false;
      config.agents =
        if openclawLib.usesAgentEntries then
          lib.optionalAttrs openclawLib.hasAgentOwnership { ownership = "explicit"; }
          // { entries = { Writer = { }; research = { }; }; }
        else
          { list = [ { id = "writer"; } { id = "research"; } ]; };
    };
  };
}
