{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.openclaw-gateway;
  qmdPackage = pkgs.openclawPackages.qmd or null;
  inherit (import ../../lib/openclaw-config-capabilities.nix { inherit lib; }) supportsQmdBackend;
  qmdRequested = (((cfg.config.memory or { }).backend or null) == "qmd");
  qmdEnabled = supportsQmdBackend && qmdRequested;
  retiredQmdConfig =
    qmdRequested
    || lib.hasAttrByPath [ "memory" "qmd" ] cfg.config
    || lib.hasAttrByPath [ "memory" "search" "qmd" ] cfg.config;
  toJSONWithContext = import ../../lib/json-with-context.nix { inherit lib; };

  deepConfigType = lib.types.mkOptionType {
    name = "openclaw-config-attrs";
    description = "OpenClaw JSON config (attrset), merged deeply via lib.recursiveUpdate.";
    check = builtins.isAttrs;
    merge = _loc: defs: lib.foldl' lib.recursiveUpdate { } (map (d: d.value) defs);
  };

  configJson = toJSONWithContext cfg.config;
  generatedConfigFile = pkgs.writeText "openclaw.json" configJson;
  configFile = if cfg.configFile != null then cfg.configFile else generatedConfigFile;

  # `environment.etc` takes a relative path.
  etcRelPath = lib.removePrefix "/etc/" cfg.configPath;

  execStartCmd =
    if cfg.execStart != null then
      cfg.execStart
    else
      "${cfg.package}/bin/openclaw gateway --port ${toString cfg.port}";

in
{
  options.services.openclaw-gateway = with lib; {
    enable = mkEnableOption "OpenClaw gateway (openclaw gateway as a systemd service)";

    unitName = mkOption {
      type = types.str;
      default = "openclaw-gateway";
      description = "systemd unit name (service will be <unitName>.service).";
    };

    package = mkOption {
      type = types.package;
      default = if pkgs ? openclaw then pkgs.openclaw else pkgs.openclaw-gateway;
      description = "OpenClaw gateway package.";
    };

    port = mkOption {
      type = types.port;
      default = 18789;
      description = "Gateway listen port.";
    };

    user = mkOption {
      type = types.str;
      default = "openclaw";
      description = "System user running the gateway.";
    };

    group = mkOption {
      type = types.str;
      default = "openclaw";
      description = "System group running the gateway.";
    };

    createUser = mkOption {
      type = types.bool;
      default = true;
      description = "Create the user/group automatically.";
    };

    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/openclaw";
      description = "State dir (OPENCLAW_STATE_DIR).";
    };

    workingDirectory = mkOption {
      type = types.str;
      default = cfg.stateDir;
      description = "Working directory for the systemd service.";
    };

    configPath = mkOption {
      type = types.str;
      default = "/etc/openclaw/openclaw.json";
      description = "Path to the OpenClaw JSON config file (OPENCLAW_CONFIG_PATH). Must be under /etc.";
    };

    configFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Optional path to an existing config file. If set, it is copied to configPath (under /etc).";
    };

    config = mkOption {
      type = deepConfigType;
      default = { };
      description = "OpenClaw JSON config (attrset), deep-merged across definitions.";
    };

    logPath = mkOption {
      type = types.str;
      default = "${cfg.stateDir}/logs/gateway.log";
      description = "Log file path (systemd StandardOutput/StandardError append).";
    };

    environment = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Additional environment variables for the gateway process.";
    };

    environmentFiles = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "systemd EnvironmentFile= entries (use leading '-' to ignore missing).";
    };

    execStart = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Override ExecStart command. If unset, runs: openclaw gateway --port <port>.";
    };

    execStartPre = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of ExecStartPre= commands.";
    };

    servicePath = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Extra packages added to systemd service PATH.";
    };

    restart = mkOption {
      type = types.str;
      default = "always";
      description = "systemd Restart=.";
    };

    restartSec = mkOption {
      type = types.int;
      default = 2;
      description = "systemd RestartSec=.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.hasPrefix "/etc/" cfg.configPath;
        message = "services.openclaw-gateway.configPath must be under /etc (got: ${cfg.configPath}).";
      }
      {
        assertion = !qmdEnabled || qmdPackage != null;
        message = "services.openclaw-gateway.config.memory.backend = \"qmd\" requires a qmd package in openclawPackages.";
      }
      {
        assertion = supportsQmdBackend || !retiredQmdConfig;
        message = "This OpenClaw schema retired the QMD backend. Remove memory.backend = \"qmd\", memory.qmd, and memory.search.qmd from services.openclaw-gateway.config; standalone QMD remains available through explicit servicePath.";
      }
    ];

    users.groups.${cfg.group} = lib.mkIf cfg.createUser { };
    users.users.${cfg.user} = lib.mkIf cfg.createUser {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.stateDir;
      createHome = true;
      shell = pkgs.bashInteractive;
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0750 ${cfg.user} ${cfg.group} - -"
      "d ${builtins.dirOf cfg.logPath} 0750 ${cfg.user} ${cfg.group} - -"
      "d ${builtins.dirOf cfg.configPath} 0755 root root - -"
    ];

    environment.etc.${etcRelPath} = {
      mode = "0644";
      source = configFile;
    };

    systemd.services.${cfg.unitName} = {
      description = "OpenClaw gateway";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      environment = {
        OPENCLAW_CONFIG_PATH = cfg.configPath;
        OPENCLAW_STATE_DIR = cfg.stateDir;

        # Backward-compatible env names.
        CLAWDBOT_CONFIG_PATH = cfg.configPath;
        CLAWDBOT_STATE_DIR = cfg.stateDir;
      }
      // cfg.environment;

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.workingDirectory;

        EnvironmentFile = cfg.environmentFiles;
        ExecStartPre = cfg.execStartPre;
        ExecStart = execStartCmd;

        Restart = cfg.restart;
        RestartSec = cfg.restartSec;

        StandardOutput = "append:${cfg.logPath}";
        StandardError = "append:${cfg.logPath}";
      };

      path = [
        pkgs.bash
        pkgs.coreutils
      ]
      ++ lib.optional (qmdEnabled && qmdPackage != null) qmdPackage
      ++ cfg.servicePath;
    };
  };
}
