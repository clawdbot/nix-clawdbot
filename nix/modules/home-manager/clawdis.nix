{ config, lib, pkgs, ... }:

let
  cfg = config.programs.clawdis;
  homeDir = config.home.homeDirectory;
  appPackage = if cfg.appPackage != null then cfg.appPackage else cfg.package;

  mkBaseConfig = workspaceDir: {
    gateway = { mode = "local"; };
    agent = { workspace = workspaceDir; };
  };

  mkTelegramConfig = inst: lib.optionalAttrs inst.providers.telegram.enable {
    telegram = {
      enabled = true;
      tokenFile = inst.providers.telegram.botTokenFile;
      allowFrom = inst.providers.telegram.allowFrom;
      groups = inst.providers.telegram.groups;
    };
  };

  mkRoutingConfig = inst: {
    routing = {
      queue = {
        mode = inst.routing.queue.mode;
        bySurface = inst.routing.queue.bySurface;
      };
    };
  };

  instanceModule = { name, config, ... }: {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable this Clawdis instance.";
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = cfg.package;
        description = "Clawdis batteries-included package.";
      };

      stateDir = lib.mkOption {
        type = lib.types.str;
        default = if name == "default"
          then "${homeDir}/.clawdis"
          else "${homeDir}/.clawdis-${name}";
        description = "State directory for this Clawdis instance (logs, sessions, config).";
      };

      workspaceDir = lib.mkOption {
        type = lib.types.str;
        default = "${config.stateDir}/workspace";
        description = "Workspace directory for this Clawdis instance.";
      };

      configPath = lib.mkOption {
        type = lib.types.str;
        default = "${config.stateDir}/clawdis.json";
        description = "Path to generated Clawdis config JSON.";
      };

      logPath = lib.mkOption {
        type = lib.types.str;
        default = if name == "default"
          then "/tmp/clawdis/clawdis-gateway.log"
          else "/tmp/clawdis/clawdis-gateway-${name}.log";
        description = "Log path for this Clawdis gateway instance.";
      };

      gatewayPort = lib.mkOption {
        type = lib.types.int;
        default = 18789;
        description = "Gateway port used by the Clawdis desktop app.";
      };

      gatewayPath = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Local path to Clawdis gateway source (dev only).";
      };

      gatewayPnpmDepsHash = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = lib.fakeHash;
        description = "pnpmDeps hash for local gateway builds (omit to let Nix suggest the correct hash).";
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
          description = "Per-group Telegram overrides (mirrors upstream telegram.groups config).";
        };
      };

      plugins = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            source = lib.mkOption {
              type = lib.types.str;
              description = "Plugin source pointer (e.g., github:owner/repo or path:/...).";
            };
            config = lib.mkOption {
              type = lib.types.attrs;
              default = {};
              description = "Plugin-specific configuration (env/files/etc).";
            };
          };
        });
        default = cfg.plugins;
        description = "Plugins enabled for this instance.";
      };

      providers.anthropic = {
        apiKeyFile = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Path to Anthropic API key file (used to set ANTHROPIC_API_KEY).";
        };
      };

      routing.queue = {
        mode = lib.mkOption {
          type = lib.types.enum [ "queue" "interrupt" ];
          default = "interrupt";
          description = "Queue mode when a run is active.";
        };

        bySurface = lib.mkOption {
          type = lib.types.attrs;
          default = {
            telegram = "interrupt";
            discord = "queue";
            webchat = "queue";
          };
          description = "Per-surface queue mode overrides.";
        };
      };

      

      launchd.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Run Clawdis gateway via launchd (macOS).";
      };

      launchd.label = lib.mkOption {
        type = lib.types.str;
        default = if name == "default"
          then "com.steipete.clawdis.gateway"
          else "com.steipete.clawdis.gateway.${name}";
        description = "launchd label for this instance.";
      };

      app.install.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Install Clawdis.app for this instance.";
      };

      app.install.path = lib.mkOption {
        type = lib.types.str;
        default = "${homeDir}/Applications/Clawdis.app";
        description = "Destination path for this instance's Clawdis.app bundle.";
      };

      appDefaults = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = name == "default";
          description = "Configure macOS app defaults for this instance.";
        };

        attachExistingOnly = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Attach existing gateway only (macOS).";
        };
      };

      configOverrides = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        description = "Additional Clawdis config to merge into the generated JSON.";
      };
    };
  };

  defaultInstance = {
    enable = cfg.enable;
    package = cfg.package;
    stateDir = cfg.stateDir;
    workspaceDir = cfg.workspaceDir;
    configPath = "${cfg.stateDir}/clawdis.json";
    logPath = "/tmp/clawdis/clawdis-gateway.log";
    gatewayPort = 18789;
    providers = cfg.providers;
    routing = cfg.routing;
    launchd = cfg.launchd;
    plugins = cfg.plugins;
    configOverrides = {};
    appDefaults = {
      enable = true;
      attachExistingOnly = true;
    };
    app = {
      install = {
        enable = false;
        path = "${homeDir}/Applications/Clawdis.app";
      };
    };
  };

  instances = if cfg.instances != {}
    then cfg.instances
    else lib.optionalAttrs cfg.enable { default = defaultInstance; };

  enabledInstances = lib.filterAttrs (_: inst: inst.enable) instances;
  managedSkillsDir = "${homeDir}/.clawdis/skills";

  documentsEnabled = cfg.documents != null;

  resolvePath = p:
    if lib.hasPrefix "~/" p then
      "${homeDir}/${lib.removePrefix "~/" p}"
    else
      p;

  toRelative = p:
    if lib.hasPrefix "${homeDir}/" p then
      lib.removePrefix "${homeDir}/" p
    else
      p;

  instanceWorkspaceDirs = lib.mapAttrsToList (_: inst: resolvePath inst.workspaceDir) enabledInstances;

  documentsAssertions = lib.optionals documentsEnabled [
    {
      assertion = builtins.pathExists cfg.documents;
      message = "programs.clawdis.documents must point to an existing directory.";
    }
    {
      assertion = builtins.pathExists (cfg.documents + "/AGENTS.md");
      message = "Missing AGENTS.md in programs.clawdis.documents.";
    }
    {
      assertion = builtins.pathExists (cfg.documents + "/SOUL.md");
      message = "Missing SOUL.md in programs.clawdis.documents.";
    }
    {
      assertion = builtins.pathExists (cfg.documents + "/TOOLS.md");
      message = "Missing TOOLS.md in programs.clawdis.documents.";
    }
  ];

  documentsGuard =
    lib.optionalString documentsEnabled (
      let
        guardLine = file: ''
          if [ -e "${file}" ] && [ ! -L "${file}" ]; then
            echo "Clawdis documents are managed by Nix. Please adopt ${file} into your documents directory and re-run." >&2
            exit 1
          fi
        '';
        guardForDir = dir: ''
          ${guardLine "${dir}/AGENTS.md"}
          ${guardLine "${dir}/SOUL.md"}
          ${guardLine "${dir}/TOOLS.md"}
        '';
      in
        lib.concatStringsSep "\n" (map guardForDir instanceWorkspaceDirs)
    );

  toolsReport =
    if documentsEnabled then
      let
          pluginLinesFor = instName: inst:
            let
              plugins = resolvedPluginsByInstance.${instName} or [];
              render = p: "- " + p.name + " (" + p.source + ")";
              lines = if plugins == [] then [ "- (none)" ] else map render plugins;
            in
              [
                ""
                "### Instance: ${instName}"
              ] ++ lines;
        reportLines =
          [
            "<!-- BEGIN NIX-REPORT -->"
            ""
            "## Nix-managed plugin report"
            ""
            "Plugins enabled per instance (last-wins on name collisions):"
          ]
          ++ lib.concatLists (lib.mapAttrsToList pluginLinesFor enabledInstances)
          ++ [
            ""
            "Tools: batteries-included toolchain + plugin-provided CLIs."
            ""
            "<!-- END NIX-REPORT -->"
          ];
        reportText = lib.concatStringsSep "\n" reportLines;
      in
        pkgs.writeText "clawdis-tools-report.md" reportText
    else
      null;

  toolsWithReport =
    if documentsEnabled then
      pkgs.runCommand "clawdis-tools-with-report.md" {} ''
        cat ${cfg.documents + "/TOOLS.md"} > $out
        echo "" >> $out
        cat ${toolsReport} >> $out
      ''
    else
      null;

  documentsFiles =
    if documentsEnabled then
      let
        mkDocFiles = dir: {
          "${toRelative (dir + "/AGENTS.md")}" = {
            source = cfg.documents + "/AGENTS.md";
          };
          "${toRelative (dir + "/SOUL.md")}" = {
            source = cfg.documents + "/SOUL.md";
          };
          "${toRelative (dir + "/TOOLS.md")}" = {
            source = toolsWithReport;
          };
        };
      in
        lib.mkMerge (map mkDocFiles instanceWorkspaceDirs)
    else
      {};

  resolvePlugin = plugin: let
    flake = builtins.getFlake plugin.source;
    clawdisPlugin =
      if flake ? clawdisPlugin then flake.clawdisPlugin
      else throw "clawdisPlugin missing in ${plugin.source}";
    needs = clawdisPlugin.needs or {};
  in {
    source = plugin.source;
    name = clawdisPlugin.name or (throw "clawdisPlugin.name missing in ${plugin.source}");
    skills = clawdisPlugin.skills or [];
    packages = clawdisPlugin.packages or [];
    needs = {
      stateDirs = needs.stateDirs or [];
      requiredEnv = needs.requiredEnv or [];
    };
    config = plugin.config or {};
  };

  resolvedPluginsByInstance =
    lib.mapAttrs (instName: inst:
      let
        resolved = map resolvePlugin inst.plugins;
        counts = lib.foldl' (acc: p:
          acc // { "${p.name}" = (acc.${p.name} or 0) + 1; }
        ) {} resolved;
        duplicates = lib.attrNames (lib.filterAttrs (_: v: v > 1) counts);
        byName = lib.foldl' (acc: p: acc // { "${p.name}" = p; }) {} resolved;
        ordered = lib.attrValues byName;
      in
        if duplicates == []
        then ordered
        else lib.warn
          "programs.clawdis.instances.${instName}: duplicate plugin names detected (${lib.concatStringsSep ", " duplicates}); last entry wins."
          ordered
    ) enabledInstances;

  pluginPackagesFor = instName:
    lib.flatten (map (p: p.packages) (resolvedPluginsByInstance.${instName} or []));

  pluginStateDirsFor = instName:
    let
      dirs = lib.flatten (map (p: p.needs.stateDirs) (resolvedPluginsByInstance.${instName} or []));
    in
      map (dir: resolvePath ("~/" + dir)) dirs;

  pluginEnvFor = instName:
    let
      entries = resolvedPluginsByInstance.${instName} or [];
      toPairs = p:
        let
          env = (p.config.env or {});
          required = p.needs.requiredEnv;
        in
          map (k: { key = k; value = env.${k} or ""; plugin = p.name; }) required;
    in
      lib.flatten (map toPairs entries);

  pluginEnvAllFor = instName:
    let
      entries = resolvedPluginsByInstance.${instName} or [];
      toPairs = p:
        let env = (p.config.env or {});
        in map (k: { key = k; value = env.${k}; plugin = p.name; }) (lib.attrNames env);
    in
      lib.flatten (map toPairs entries);

  pluginAssertions =
    lib.flatten (lib.mapAttrsToList (instName: inst:
      let
        plugins = resolvedPluginsByInstance.${instName} or [];
        envFor = p: (p.config.env or {});
        missingFor = p:
          lib.filter (req: !(envFor p ? req)) p.needs.requiredEnv;
        configMissingStateDir = p:
          (p.config.settings or {}) != {} && (p.needs.stateDirs or []) == [];
        mkAssertion = p:
          let missing = missingFor p;
          in {
            assertion = missing == [];
            message = "programs.clawdis.instances.${instName}: plugin ${p.name} missing required env: ${lib.concatStringsSep ", " missing}";
          };
        mkConfigAssertion = p: {
          assertion = !(configMissingStateDir p);
          message = "programs.clawdis.instances.${instName}: plugin ${p.name} provides settings but declares no stateDirs (needed for config.json).";
        };
      in
        (map mkAssertion plugins) ++ (map mkConfigAssertion plugins)
    ) enabledInstances);

  pluginSkillsFiles =
    let
      skillEntriesFor = p:
        map (skillPath: {
          name = ".clawdis/skills/${p.name}/${builtins.baseNameOf skillPath}";
          value = { source = skillPath; recursive = true; };
        }) p.skills;
      allEntries =
        lib.flatten (lib.concatLists (lib.mapAttrsToList (_: plugins: map skillEntriesFor plugins) resolvedPluginsByInstance));
    in
      lib.listToAttrs (lib.flatten allEntries);

  pluginGuards =
    let
      renderCheck = entry: ''
        if [ -z "${entry.value}" ]; then
          echo "Missing env ${entry.key} for plugin ${entry.plugin} in instance ${entry.instance}." >&2
          exit 1
        fi
        if [ ! -f "${entry.value}" ] || [ ! -s "${entry.value}" ]; then
          echo "Required file for ${entry.key} not found or empty: ${entry.value} (plugin ${entry.plugin}, instance ${entry.instance})." >&2
          exit 1
        fi
      '';
      entriesForInstance = instName:
        map (entry: entry // { instance = instName; }) (pluginEnvFor instName);
      entries = lib.flatten (map entriesForInstance (lib.attrNames enabledInstances));
    in
      lib.concatStringsSep "\n" (map renderCheck entries);

  pluginConfigFiles =
    let
      entryFor = instName: inst:
      let
        plugins = resolvedPluginsByInstance.${instName} or [];
        mkEntries = p:
          let
            cfg = p.config.settings or {};
            dir =
              if (p.needs.stateDirs or []) == []
              then null
              else lib.head (p.needs.stateDirs or []);
          in
            if cfg == {} then
              []
            else
                (if dir == null then
                  throw "plugin ${p.name} provides settings but no stateDirs are defined"
                else [
                  {
                    name = toRelative (resolvePath ("~/" + dir + "/config.json"));
                    value = { text = builtins.toJSON cfg; };
                  }
                ]);
        in
          lib.flatten (map mkEntries plugins);
      entries = lib.flatten (lib.mapAttrsToList entryFor enabledInstances);
    in
      lib.listToAttrs entries;

  pluginSkillAssertions =
    let
      skillTargets =
        lib.flatten (lib.concatLists (lib.mapAttrsToList (_: plugins:
          map (p:
            map (skillPath:
              ".clawdis/skills/${p.name}/${builtins.baseNameOf skillPath}"
            ) p.skills
          ) plugins
        ) resolvedPluginsByInstance));
      counts = lib.foldl' (acc: path:
        acc // { "${path}" = (acc.${path} or 0) + 1; }
      ) {} skillTargets;
      duplicates = lib.attrNames (lib.filterAttrs (_: v: v > 1) counts);
    in
      if duplicates == [] then [] else [
        {
          assertion = false;
          message = "Duplicate skill paths detected: ${lib.concatStringsSep ", " duplicates}";
        }
      ];
  mkInstanceConfig = name: inst: let
    gatewayPackage =
      if inst.gatewayPath != null then
        pkgs.callPackage ../../packages/clawdis-gateway.nix {
          gatewaySrc = builtins.path {
            path = inst.gatewayPath;
            name = "clawdis-gateway-src";
          };
          pnpmDepsHash = inst.gatewayPnpmDepsHash;
        }
      else
        inst.package;
    pluginPackages = pluginPackagesFor name;
    pluginEnvAll = pluginEnvAllFor name;
    baseConfig = mkBaseConfig inst.workspaceDir;
    mergedConfig = lib.recursiveUpdate
      (lib.recursiveUpdate baseConfig (lib.recursiveUpdate (mkTelegramConfig inst) (mkRoutingConfig inst)))
      inst.configOverrides;
    configJson = builtins.toJSON mergedConfig;
    gatewayWrapper = pkgs.writeShellScriptBin "clawdis-gateway-${name}" ''
      set -euo pipefail

      if [ "${toString (pluginPackages != [])}" = "true" ]; then
        export PATH="${lib.makeBinPath pluginPackages}:$PATH"
      fi

      ${lib.concatStringsSep "\n" (map (entry: "export ${entry.key}=\"${entry.value}\"") pluginEnvAll)}

      if [ -n "${inst.providers.anthropic.apiKeyFile}" ]; then
        if [ ! -f "${inst.providers.anthropic.apiKeyFile}" ]; then
          echo "Anthropic API key file not found: ${inst.providers.anthropic.apiKeyFile}" >&2
          exit 1
        fi
        ANTHROPIC_API_KEY="$(cat "${inst.providers.anthropic.apiKeyFile}")"
        if [ -z "$ANTHROPIC_API_KEY" ]; then
          echo "Anthropic API key file is empty: ${inst.providers.anthropic.apiKeyFile}" >&2
          exit 1
        fi
        export ANTHROPIC_API_KEY
      fi

      exec "${gatewayPackage}/bin/clawdis" "$@"
    '';
  in {
    homeFile = {
      name = inst.configPath;
      value = { text = configJson; };
    };

    dirs = [ inst.stateDir inst.workspaceDir (builtins.dirOf inst.logPath) ];

    launchdAgent = lib.optionalAttrs (pkgs.stdenv.hostPlatform.isDarwin && inst.launchd.enable) {
      "${inst.launchd.label}" = {
        enable = true;
        config = {
          Label = inst.launchd.label;
          ProgramArguments = [
            "${gatewayWrapper}/bin/clawdis-gateway-${name}"
            "gateway"
            "--port"
            "${toString inst.gatewayPort}"
          ];
          RunAtLoad = true;
          KeepAlive = true;
          WorkingDirectory = inst.stateDir;
          StandardOutPath = inst.logPath;
          StandardErrorPath = inst.logPath;
          EnvironmentVariables = {
            HOME = homeDir;
            CLAWDIS_CONFIG_PATH = inst.configPath;
            CLAWDIS_STATE_DIR = inst.stateDir;
            CLAWDIS_IMAGE_BACKEND = "sips";
            CLAWDIS_NIX_MODE = "1";
          };
        };
      };
    };

    appDefaults = lib.optionalAttrs (pkgs.stdenv.hostPlatform.isDarwin && inst.appDefaults.enable) {
      attachExistingOnly = inst.appDefaults.attachExistingOnly;
      gatewayPort = inst.gatewayPort;
    };

    appInstall = if !(pkgs.stdenv.hostPlatform.isDarwin && inst.app.install.enable && appPackage != null) then
      null
    else {
      name = lib.removePrefix "${homeDir}/" inst.app.install.path;
      value = {
        source = "${appPackage}/Applications/Clawdis.app";
        recursive = true;
        force = true;
      };
    };

    package = gatewayPackage;
  };

  instanceConfigs = lib.mapAttrsToList mkInstanceConfig enabledInstances;
  appInstalls = lib.filter (item: item != null) (map (item: item.appInstall) instanceConfigs);

  appDefaults = lib.foldl' (acc: item: lib.recursiveUpdate acc item.appDefaults) {} instanceConfigs;

  appDefaultsEnabled = lib.filterAttrs (_: inst: inst.appDefaults.enable) enabledInstances;
  pluginStateDirsAll = lib.flatten (map pluginStateDirsFor (lib.attrNames enabledInstances));

  assertions = lib.flatten (lib.mapAttrsToList (name: inst: [
    {
      assertion = !inst.providers.telegram.enable || inst.providers.telegram.botTokenFile != "";
      message = "programs.clawdis.instances.${name}.providers.telegram.botTokenFile must be set when Telegram is enabled.";
    }
    {
      assertion = !inst.providers.telegram.enable || (lib.length inst.providers.telegram.allowFrom > 0);
      message = "programs.clawdis.instances.${name}.providers.telegram.allowFrom must be non-empty when Telegram is enabled.";
    }
  ]) enabledInstances);

in {
  options.programs.clawdis = {
    enable = lib.mkEnableOption "Clawdis (batteries-included)";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.clawdis;
      description = "Clawdis batteries-included package.";
    };

    appPackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = "Optional Clawdis app package (defaults to package if unset).";
    };

    installApp = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install Clawdis.app at the default location.";
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "${homeDir}/.clawdis";
      description = "State directory for Clawdis (logs, sessions, config).";
    };

    workspaceDir = lib.mkOption {
      type = lib.types.str;
      default = "${homeDir}/.clawdis/workspace";
      description = "Workspace directory for Clawdis agent skills.";
    };

    documents = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to a documents directory containing AGENTS.md, SOUL.md, and TOOLS.md.";
    };

    plugins = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          source = lib.mkOption {
            type = lib.types.str;
            description = "Plugin source pointer (e.g., github:owner/repo or path:/...).";
          };
          config = lib.mkOption {
            type = lib.types.attrs;
            default = {};
            description = "Plugin-specific configuration (env/files/etc).";
          };
        };
      });
      default = [];
      description = "Plugins enabled for the default instance.";
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
        description = "Path to Anthropic API key file (used to set ANTHROPIC_API_KEY).";
      };
    };

    routing.queue = {
      mode = lib.mkOption {
        type = lib.types.enum [ "queue" "interrupt" ];
        default = "interrupt";
        description = "Queue mode when a run is active.";
      };

      bySurface = lib.mkOption {
        type = lib.types.attrs;
        default = {
          telegram = "interrupt";
          discord = "queue";
          webchat = "queue";
        };
        description = "Per-surface queue mode overrides.";
      };
    };


    launchd.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Run Clawdis gateway via launchd (macOS).";
    };

    instances = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule instanceModule);
      default = {};
      description = "Named Clawdis instances (prod/test).";
    };

    reloadScript = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Install clawdis-reload helper for no-sudo config refresh + gateway restart.";
      };
    };
  };

  config = lib.mkIf (cfg.enable || cfg.instances != {}) {
    assertions = assertions ++ [
      {
        assertion = lib.length (lib.attrNames appDefaultsEnabled) <= 1;
        message = "Only one Clawdis instance may enable appDefaults.";
      }
    ] ++ documentsAssertions ++ pluginAssertions ++ pluginSkillAssertions;

    home.packages = lib.unique (map (item: item.package) instanceConfigs);

    home.file =
      (lib.listToAttrs (map (item: item.homeFile) instanceConfigs))
      // (lib.optionalAttrs (pkgs.stdenv.hostPlatform.isDarwin && appPackage != null && cfg.installApp) {
        "Applications/Clawdis.app" = {
          source = "${appPackage}/Applications/Clawdis.app";
          recursive = true;
          force = true;
        };
      })
      // (lib.listToAttrs appInstalls)
      // documentsFiles
      // pluginSkillsFiles
      // pluginConfigFiles
      // (lib.optionalAttrs cfg.reloadScript.enable {
        ".local/bin/clawdis-reload" = {
          executable = true;
          source = pkgs.writeShellScript "clawdis-reload" ''
            set -euo pipefail

            usage() {
              cat <<'EOF'
            Usage: clawdis-reload [test|prod|both]

            Re-render Clawdis config via Home Manager (no sudo) and restart gateway(s).

            Defaults to: test
            EOF
            }

            instance="''${1:-test}"

            case "$instance" in
              test) labels=("com.steipete.clawdis.gateway.nix-test") ;;
              prod) labels=("com.steipete.clawdis.gateway.nix") ;;
              both) labels=("com.steipete.clawdis.gateway.nix" "com.steipete.clawdis.gateway.nix-test") ;;
              -h|--help) usage; exit 0 ;;
              *) usage; exit 1 ;;
            esac

            if command -v hm-apply >/dev/null 2>&1; then
              hm-apply
            elif [[ -n "''${CLAWDIS_RELOAD_HM_CMD:-}" ]]; then
              eval "$CLAWDIS_RELOAD_HM_CMD"
            else
              echo "[clawdis-reload] no Home Manager command available." >&2
              echo "[clawdis-reload] install hm-apply or set CLAWDIS_RELOAD_HM_CMD." >&2
              exit 1
            fi

            for label in "''${labels[@]}"; do
              /bin/launchctl kickstart -k "gui/$UID/$label"
            done
          '';
        };
      });

    home.activation.clawdisDocumentGuard = lib.mkIf documentsEnabled (
      lib.hm.dag.entryBefore [ "writeBoundary" ] ''
        set -euo pipefail
        ${documentsGuard}
      ''
    );

    home.activation.clawdisDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      /bin/mkdir -p ${lib.concatStringsSep " " (lib.concatMap (item: item.dirs) instanceConfigs)}
      ${lib.optionalString (pluginStateDirsAll != []) "/bin/mkdir -p ${lib.concatStringsSep " " pluginStateDirsAll}"}
    '';

    home.activation.clawdisPluginGuard = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      set -euo pipefail
      ${pluginGuards}
    '';

    home.activation.clawdisAppDefaults = lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin && appDefaults != {}) (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        /usr/bin/defaults write com.steipete.Clawdis clawdis.gateway.attachExistingOnly -bool ${lib.boolToString (appDefaults.attachExistingOnly or true)}
        /usr/bin/defaults write com.steipete.Clawdis gatewayPort -int ${toString (appDefaults.gatewayPort or 18789)}
      ''
    );

    launchd.agents = lib.mkMerge (map (item: item.launchdAgent) instanceConfigs);
  };
}
