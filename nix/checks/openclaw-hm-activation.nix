{ pkgs, home-manager }:

let
  openclawModule = ../modules/home-manager/openclaw.nix;
  testScript = builtins.readFile ../tests/hm-activation.py;

in
pkgs.testers.nixosTest {
  name = "openclaw-hm-activation";

  nodes.machine =
    { ... }:
    {
      imports = [ home-manager.nixosModules.home-manager ];

      networking.firewall.allowedTCPPorts = [ 18999 ];

      users.users.alice = {
        isNormalUser = true;
        home = "/home/alice";
        extraGroups = [ "wheel" ];
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.alice =
          { config, lib, ... }:
          let
            openclawLib = import ../modules/home-manager/openclaw/lib.nix {
              inherit config lib pkgs;
            };
          in
          {
            imports = [ openclawModule ];

            home = {
              username = "alice";
              homeDirectory = "/home/alice";
              stateVersion = "23.11";
            };
            manual = {
              html.enable = false;
              json.enable = false;
              manpages.enable = false;
            };

            programs.openclaw = {
              enable = true;
              workspace = {
                bootstrapFiles = {
                  agents = ../tests/workspace/AGENTS.md;
                  soul = ../tests/workspace/SOUL.md;
                  tools = ../tests/workspace/TOOLS.md;
                  identity = ../tests/workspace/IDENTITY.md;
                  user = ../tests/workspace/USER.md;
                  heartbeat = ../tests/workspace/HEARTBEAT.md;
                };
                files."LORE.md" = ../tests/workspace/LORE.md;
              };
              skills = [
                {
                  name = "activation-skill";
                  mode = "inline";
                  description = "Synthetic activation fixture";
                }
                {
                  name = "copied-skill";
                  mode = "copy";
                  source = toString ../tests/plugins/alpha/skill;
                }
              ];
              installApp = false;
              launchd.enable = false;
              instances.default = {
                stateDir = "~/openclaw state";
                configPath = "~/openclaw state/config with spaces and 'quotes'.json";
                workspaceDir = "~/custom workspace";
                gatewayPort = 18999;
                config = {
                  logging = {
                    level = "debug";
                    file = "/tmp/openclaw/openclaw-gateway.log";
                  };
                  gateway = {
                    mode = "local";
                    auth = {
                      token = "hm-activation-test-token";
                    };
                  };
                  plugins = {
                    enabled = false;
                  };
                } // lib.optionalAttrs openclawLib.usesAgentEntries {
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

            systemd.user.services."openclaw-gateway".Service = {
              Environment = lib.mkAfter [
                "OPENCLAW_SKIP_BROWSER_CONTROL_SERVER=1"
                "OPENCLAW_SKIP_CANVAS_HOST=1"
                "OPENCLAW_SKIP_CHANNELS=1"
                "OPENCLAW_SKIP_CRON=1"
                "OPENCLAW_SKIP_GMAIL_WATCHER=1"
                "OPENCLAW_GATEWAY_STARTUP_TRACE=1"
                "OPENCLAW_DISABLE_BONJOUR=1"
                "NODE_OPTIONS=--report-on-fatalerror"
                "NODE_REPORT_DIRECTORY=/tmp/openclaw"
                "NODE_REPORT_FILENAME=node-report.%p.json"
              ];
              Restart = lib.mkForce "no";
              RestartSec = lib.mkForce "0";
              StandardOutput = lib.mkForce "journal";
              StandardError = lib.mkForce "journal";
            };
          };
      };
    };

  testScript = testScript;
}
