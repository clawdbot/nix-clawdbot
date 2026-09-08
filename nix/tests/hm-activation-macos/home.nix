{ pkgs, ... }:

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
    workspace.files."LORE.md" = ../workspace/LORE.md;
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
  };
}
