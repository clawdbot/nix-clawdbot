# NixOS module options for Clawdbot system service
#
# TODO: Consolidate with home-manager/clawdbot.nix options
# This file duplicates option definitions for NixOS system service support.
# The duplication is intentional to avoid risking the stable home-manager module
# while adding NixOS support. Once patterns stabilize, extract shared options.
#
# Key differences from home-manager:
# - Namespace: services.clawdbot (not programs.clawdbot)
# - Paths: /var/lib/clawdbot (not ~/.clawdbot)
# - Adds: user, group options for system user
# - Removes: launchd.*, app.*, appDefaults.* (macOS-specific)
# - systemd options are for system services (not user services)

{ lib, cfg, defaultPackage, generatedConfigOptions }:

let
  stateDir = "/var/lib/clawdbot";

  instanceModule = { name, config, ... }: {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable this Clawdbot instance.";
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = defaultPackage;
        description = "Clawdbot batteries-included package.";
      };

      stateDir = lib.mkOption {
        type = lib.types.str;
        default = if name == "default"
          then stateDir
          else "${stateDir}-${name}";
        description = "State directory for this Clawdbot instance.";
      };

      workspaceDir = lib.mkOption {
        type = lib.types.str;
        default = "${config.stateDir}/workspace";
        description = "Workspace directory for this Clawdbot instance.";
      };

      configPath = lib.mkOption {
        type = lib.types.str;
        default = "${config.stateDir}/clawdbot.json";
        description = "Path to generated Clawdbot config JSON.";
      };

      gatewayPort = lib.mkOption {
        type = lib.types.int;
        default = 18789;
        description = "Gateway port for this Clawdbot instance.";
      };

      providers.telegram = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable Telegram provider.";
        };

        botTokenFile = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Path to Telegram bot token file.";
        };

        allowFrom = lib.mkOption {
          type = lib.types.listOf lib.types.int;
          default = [];
          description = "Allowed Telegram chat IDs.";
        };

        groups = lib.mkOption {
          type = lib.types.attrs;
          default = {};
          description = "Per-group Telegram overrides.";
        };
      };

      providers.anthropic = {
        apiKeyFile = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Path to Anthropic API key file.";
        };
      };

      plugins = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            source = lib.mkOption {
              type = lib.types.str;
              description = "Plugin source pointer (e.g., github:owner/repo).";
            };
            config = lib.mkOption {
              type = lib.types.attrs;
              default = {};
              description = "Plugin-specific configuration.";
            };
          };
        });
        default = [];
        description = "Plugins enabled for this instance.";
      };

      agent = {
        model = lib.mkOption {
          type = lib.types.str;
          default = cfg.defaults.model;
          description = "Default model for this instance.";
        };
        thinkingDefault = lib.mkOption {
          type = lib.types.enum [ "off" "minimal" "low" "medium" "high" ];
          default = cfg.defaults.thinkingDefault;
          description = "Default thinking level for this instance.";
        };
      };

      routing.queue = {
        mode = lib.mkOption {
          type = lib.types.enum [ "queue" "interrupt" ];
          default = "interrupt";
          description = "Queue mode when a run is active.";
        };

        byChannel = lib.mkOption {
          type = lib.types.attrs;
          default = {
            telegram = "interrupt";
            discord = "queue";
            webchat = "queue";
          };
          description = "Per-channel queue mode overrides.";
        };
      };

      configOverrides = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        description = "Additional config to merge into generated JSON.";
      };

      config = lib.mkOption {
        type = lib.types.submodule { options = generatedConfigOptions; };
        default = {};
        description = "Upstream Clawdbot config (generated from schema).";
      };
    };
  };

in {
  inherit instanceModule;

  # Top-level options for services.clawdbot
  topLevelOptions = {
    enable = lib.mkEnableOption "Clawdbot system service";

    package = lib.mkOption {
      type = lib.types.package;
      description = "Clawdbot batteries-included package.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "clawdbot";
      description = "System user to run the Clawdbot gateway.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "clawdbot";
      description = "System group for the Clawdbot user.";
    };

    toolNames = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      default = null;
      description = "Override the built-in toolchain names.";
    };

    excludeTools = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Tool names to remove from the built-in toolchain.";
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = stateDir;
      description = "State directory for Clawdbot.";
    };

    workspaceDir = lib.mkOption {
      type = lib.types.str;
      default = "${stateDir}/workspace";
      description = "Workspace directory for Clawdbot agent skills.";
    };

    documents = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to documents directory (AGENTS.md, SOUL.md, TOOLS.md).";
    };

    skills = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Skill name (directory name).";
          };
          description = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Short description for skill frontmatter.";
          };
          homepage = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Optional homepage URL.";
          };
          body = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Optional skill body (markdown).";
          };
          clawdbot = lib.mkOption {
            type = lib.types.nullOr lib.types.attrs;
            default = null;
            description = "Optional clawdbot metadata.";
          };
          mode = lib.mkOption {
            type = lib.types.enum [ "symlink" "copy" "inline" ];
            default = "copy";  # Default to copy for system service (no user home)
            description = "Install mode for the skill.";
          };
          source = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Source path for the skill (required for symlink/copy).";
          };
        };
      });
      default = [];
      description = "Declarative skills installed into workspace.";
    };

    plugins = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          source = lib.mkOption {
            type = lib.types.str;
            description = "Plugin source pointer.";
          };
          config = lib.mkOption {
            type = lib.types.attrs;
            default = {};
            description = "Plugin-specific configuration.";
          };
        };
      });
      default = [];
      description = "Plugins enabled for the default instance.";
    };

    defaults = {
      model = lib.mkOption {
        type = lib.types.str;
        default = "anthropic/claude-sonnet-4-20250514";
        description = "Default model for all instances.";
      };
      thinkingDefault = lib.mkOption {
        type = lib.types.enum [ "off" "minimal" "low" "medium" "high" ];
        default = "high";
        description = "Default thinking level for all instances.";
      };
    };

    providers.telegram = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Telegram provider.";
      };

      botTokenFile = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Path to Telegram bot token file.";
      };

      allowFrom = lib.mkOption {
        type = lib.types.listOf lib.types.int;
        default = [];
        description = "Allowed Telegram chat IDs.";
      };
    };

    providers.anthropic = {
      apiKeyFile = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Path to Anthropic API key file.";
      };
    };

    routing.queue = {
      mode = lib.mkOption {
        type = lib.types.enum [ "queue" "interrupt" ];
        default = "interrupt";
        description = "Queue mode when a run is active.";
      };

      byChannel = lib.mkOption {
        type = lib.types.attrs;
        default = {
          telegram = "interrupt";
          discord = "queue";
          webchat = "queue";
        };
        description = "Per-channel queue mode overrides.";
      };
    };

    instances = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule instanceModule);
      default = {};
      description = "Named Clawdbot instances.";
    };
  };
}
