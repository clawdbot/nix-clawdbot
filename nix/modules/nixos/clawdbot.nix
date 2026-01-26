# NixOS module for Clawdbot system service
#
# Runs the Clawdbot gateway as an isolated system user with systemd hardening.
# This contains the blast radius if the LLM is compromised.
#
# Example usage (OAuth - recommended, uses Claude Pro/Max subscription):
#   services.clawdbot = {
#     enable = true;
#     # Use Claude CLI OAuth credentials (run `claude` to authenticate first)
#     providers.anthropic.oauthCredentialsDir = "/home/myuser/.claude";
#     providers.telegram = {
#       enable = true;
#       botTokenFile = "/run/agenix/telegram-bot-token";
#       allowFrom = [ 12345678 ];
#     };
#   };
#
# Example usage (API key):
#   services.clawdbot = {
#     enable = true;
#     providers.anthropic.apiKeyFile = "/run/agenix/anthropic-api-key";
#   };

{ config, lib, pkgs, ... }:

let
  cfg = config.services.clawdbot;

  # Tool overrides (same pattern as home-manager)
  toolOverrides = {
    toolNamesOverride = cfg.toolNames;
    excludeToolNames = cfg.excludeTools;
  };
  toolOverridesEnabled = cfg.toolNames != null || cfg.excludeTools != [];
  toolSets = import ../../tools/extended.nix ({ inherit pkgs; } // toolOverrides);
  defaultPackage =
    if toolOverridesEnabled && cfg.package == pkgs.clawdbot
    then (pkgs.clawdbotPackages.withTools toolOverrides).clawdbot
    else cfg.package;

  generatedConfigOptions = import ../../generated/clawdbot-config-options.nix { inherit lib; };

  # Import option definitions
  optionsDef = import ./options.nix {
    inherit lib cfg defaultPackage generatedConfigOptions;
  };

  # Default instance when no explicit instances are defined
  defaultInstance = {
    enable = cfg.enable;
    package = cfg.package;
    stateDir = cfg.stateDir;
    workspaceDir = cfg.workspaceDir;
    configPath = "${cfg.stateDir}/clawdbot.json";
    gatewayPort = 18789;
    providers = cfg.providers;
    routing = cfg.routing;
    gateway = cfg.gateway;
    plugins = cfg.plugins;
    configOverrides = {};
    config = {};
    agent = {
      model = cfg.defaults.model;
      thinkingDefault = cfg.defaults.thinkingDefault;
    };
  };

  instances = if cfg.instances != {}
    then cfg.instances
    else lib.optionalAttrs cfg.enable { default = defaultInstance; };

  enabledInstances = lib.filterAttrs (_: inst: inst.enable) instances;

  # Config generation helpers (mirrored from home-manager)
  mkBaseConfig = workspaceDir: inst: {
    gateway = { mode = "local"; };
    agents = {
      defaults = {
        workspace = workspaceDir;
        model = { primary = inst.agent.model; };
        thinkingDefault = inst.agent.thinkingDefault;
      };
      list = [
        {
          id = "main";
          default = true;
        }
      ];
    };
  };

  mkTelegramConfig = inst: lib.optionalAttrs inst.providers.telegram.enable {
    channels.telegram = {
      enabled = true;
      tokenFile = inst.providers.telegram.botTokenFile;
      allowFrom = inst.providers.telegram.allowFrom;
      groups = inst.providers.telegram.groups;
    };
  };

  mkRoutingConfig = inst: {
    messages = {
      queue = {
        mode = inst.routing.queue.mode;
        byChannel = inst.routing.queue.byChannel;
      };
    };
  };

  # Build instance configuration
  mkInstanceConfig = name: inst:
    let
      gatewayPackage = inst.package;
      oauthDir = inst.providers.anthropic.oauthCredentialsDir;
      hasOauth = oauthDir != null;

      baseConfig = mkBaseConfig inst.workspaceDir inst;
      mergedConfig = lib.recursiveUpdate
        (lib.recursiveUpdate baseConfig (lib.recursiveUpdate (mkTelegramConfig inst) (mkRoutingConfig inst)))
        inst.configOverrides;
      configJson = builtins.toJSON mergedConfig;
      configFile = pkgs.writeText "clawdbot-${name}.json" configJson;

      # Gateway auth configuration
      gatewayAuthMode = inst.gateway.auth.mode;
      gatewayTokenFile = inst.gateway.auth.tokenFile or null;
      gatewayPasswordFile = inst.gateway.auth.passwordFile or null;

      # Gateway wrapper script that loads credentials at runtime
      gatewayWrapper = pkgs.writeShellScriptBin "clawdbot-gateway-${name}" ''
        set -euo pipefail

        # Load Anthropic API key if configured
        if [ -n "${inst.providers.anthropic.apiKeyFile}" ] && [ -f "${inst.providers.anthropic.apiKeyFile}" ]; then
          ANTHROPIC_API_KEY="$(cat "${inst.providers.anthropic.apiKeyFile}")"
          if [ -z "$ANTHROPIC_API_KEY" ]; then
            echo "Anthropic API key file is empty: ${inst.providers.anthropic.apiKeyFile}" >&2
            exit 1
          fi
          export ANTHROPIC_API_KEY
        fi

        # Load gateway token if configured
        ${lib.optionalString (gatewayTokenFile != null) ''
        if [ -f "${gatewayTokenFile}" ]; then
          CLAWDBOT_GATEWAY_TOKEN="$(cat "${gatewayTokenFile}")"
          if [ -z "$CLAWDBOT_GATEWAY_TOKEN" ]; then
            echo "Gateway token file is empty: ${gatewayTokenFile}" >&2
            exit 1
          fi
          export CLAWDBOT_GATEWAY_TOKEN
        else
          echo "Gateway token file not found: ${gatewayTokenFile}" >&2
          exit 1
        fi
        ''}

        # Load gateway password if configured
        ${lib.optionalString (gatewayPasswordFile != null) ''
        if [ -f "${gatewayPasswordFile}" ]; then
          CLAWDBOT_GATEWAY_PASSWORD="$(cat "${gatewayPasswordFile}")"
          if [ -z "$CLAWDBOT_GATEWAY_PASSWORD" ]; then
            echo "Gateway password file is empty: ${gatewayPasswordFile}" >&2
            exit 1
          fi
          export CLAWDBOT_GATEWAY_PASSWORD
        else
          echo "Gateway password file not found: ${gatewayPasswordFile}" >&2
          exit 1
        fi
        ''}

        exec "${gatewayPackage}/bin/clawdbot" "$@"
      '';

      unitName = if name == "default"
        then "clawdbot-gateway"
        else "clawdbot-gateway-${name}";
    in {
      inherit configFile configJson unitName gatewayWrapper hasOauth oauthDir;
      configPath = inst.configPath;
      stateDir = inst.stateDir;
      workspaceDir = inst.workspaceDir;
      gatewayPort = inst.gatewayPort;
      package = gatewayPackage;
    };

  instanceConfigs = lib.mapAttrs mkInstanceConfig enabledInstances;

  # Assertions
  assertions = lib.flatten (lib.mapAttrsToList (name: inst: [
    {
      assertion = !inst.providers.telegram.enable || inst.providers.telegram.botTokenFile != "";
      message = "services.clawdbot.instances.${name}.providers.telegram.botTokenFile must be set when Telegram is enabled.";
    }
    {
      assertion = !inst.providers.telegram.enable || (lib.length inst.providers.telegram.allowFrom > 0);
      message = "services.clawdbot.instances.${name}.providers.telegram.allowFrom must be non-empty when Telegram is enabled.";
    }
  ]) enabledInstances);

in {
  options.services.clawdbot = optionsDef.topLevelOptions // {
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.clawdbot;
      description = "Clawdbot batteries-included package.";
    };

    instances = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule optionsDef.instanceModule);
      default = {};
      description = "Named Clawdbot instances.";
    };
  };

  config = lib.mkIf (cfg.enable || cfg.instances != {}) {
    inherit assertions;

    # Create system user and group
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.stateDir;
      createHome = true;
      description = "Clawdbot gateway service user";
    };

    users.groups.${cfg.group} = {};

    # Create state directories via tmpfiles
    systemd.tmpfiles.rules = lib.flatten (lib.mapAttrsToList (name: instCfg: [
      "d ${instCfg.stateDir} 0750 ${cfg.user} ${cfg.group} -"
      "d ${instCfg.workspaceDir} 0750 ${cfg.user} ${cfg.group} -"
    ]) instanceConfigs);

    # Systemd services with hardening
    systemd.services = lib.mapAttrs' (name: instCfg: lib.nameValuePair instCfg.unitName {
      description = "Clawdbot gateway (${name})";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${instCfg.gatewayWrapper}/bin/clawdbot-gateway-${name} gateway --port ${toString instCfg.gatewayPort}";
        WorkingDirectory = instCfg.stateDir;
        Restart = "always";
        RestartSec = "5s";

        # Environment
        Environment = [
          "CLAWDBOT_CONFIG_PATH=${instCfg.configPath}"
          "CLAWDBOT_STATE_DIR=${instCfg.stateDir}"
          "CLAWDBOT_NIX_MODE=1"
          # Backward-compatible env names
          "CLAWDIS_CONFIG_PATH=${instCfg.configPath}"
          "CLAWDIS_STATE_DIR=${instCfg.stateDir}"
          "CLAWDIS_NIX_MODE=1"
        ];

        # Hardening options
        # ProtectHome disabled when OAuth credentials are in /home
        # (BindPaths can't access /home when ProtectHome=true)
        ProtectHome = !instCfg.hasOauth;
        ProtectSystem = "strict";
        PrivateTmp = true;
        PrivateDevices = true;
        NoNewPrivileges = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";
        ProtectHostname = true;
        ProtectClock = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        LockPersonality = true;

        # Filesystem access
        ReadWritePaths = [ instCfg.stateDir ];

        # Capability restrictions
        CapabilityBoundingSet = "";
        AmbientCapabilities = "";

        # Network restrictions (gateway needs network)
        # AF_NETLINK required for os.networkInterfaces() in Node.js
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK" ];
        IPAddressDeny = "multicast";

        # System call filtering
        # Only @system-service - Node.js with native modules needs more syscalls
        # Security comes from capability restrictions and namespace isolation instead
        SystemCallFilter = [ "@system-service" ];
        SystemCallArchitectures = "native";

        # Memory protection
        # Note: MemoryDenyWriteExecute may break Node.js JIT - disabled for now
        # MemoryDenyWriteExecute = true;

        # Restrict namespaces
        RestrictNamespaces = true;

        # UMask for created files
        UMask = "0027";
      } // lib.optionalAttrs instCfg.hasOauth {
        # Bind-mount OAuth credentials dir into service's home
        # This allows the service to use Claude CLI OAuth while remaining sandboxed
        BindPaths = [ "${instCfg.oauthDir}:${cfg.stateDir}/.claude" ];
      };
    }) instanceConfigs;

    # Write config files
    environment.etc = lib.mapAttrs' (name: instCfg:
      lib.nameValuePair "clawdbot/${name}.json" {
        text = instCfg.configJson;
        user = cfg.user;
        group = cfg.group;
        mode = "0640";
      }
    ) instanceConfigs;

    # Symlink config from /etc to state dir (activation script)
    system.activationScripts.clawdbotConfig = lib.stringAfter [ "etc" ] ''
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: instCfg: ''
        ln -sfn /etc/clawdbot/${name}.json ${instCfg.configPath}
      '') instanceConfigs)}
    '';
  };
}
