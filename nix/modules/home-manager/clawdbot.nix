{ config, lib, pkgs, ... }:

let
  cfg = config.programs.clawdbot;
  homeDir = config.home.homeDirectory;
  autoExcludeTools = lib.optionals config.programs.git.enable [ "git" ];
  effectiveExcludeTools = lib.unique (cfg.excludeTools ++ autoExcludeTools);
  toolOverrides = {
    toolNamesOverride = cfg.toolNames;
    excludeToolNames = effectiveExcludeTools;
  };
  toolOverridesEnabled = cfg.toolNames != null || effectiveExcludeTools != [];
  toolSets = import ../../tools/extended.nix ({ inherit pkgs; } // toolOverrides);
  defaultPackage =
    if toolOverridesEnabled && cfg.package == pkgs.clawdbot
    then (pkgs.clawdbotPackages.withTools toolOverrides).clawdbot
    else cfg.package;
  appPackage = if cfg.appPackage != null then cfg.appPackage else defaultPackage;
  generatedConfigOptions = import ../../generated/clawdbot-config-options.nix { lib = lib; };

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
    telegram = {
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
        byProvider = inst.routing.queue.byProvider;
      };
    };
  };

  firstPartySources = let
    stepieteRev = "e4e2cac265de35175015cf1ae836b0b30dddd7b7";
    stepieteNarHash = "sha256-L8bKt5rK78dFP3ZoP1Oi1SSAforXVHZDsSiDO+NsvEE=";
    stepiete = tool:
      "github:clawdbot/nix-steipete-tools?dir=tools/${tool}&rev=${stepieteRev}&narHash=${stepieteNarHash}";
  in {
    summarize = stepiete "summarize";
    peekaboo = stepiete "peekaboo";
    oracle = stepiete "oracle";
    poltergeist = stepiete "poltergeist";
    sag = stepiete "sag";
    camsnap = stepiete "camsnap";
    gogcli = stepiete "gogcli";
    bird = stepiete "bird";
    sonoscli = stepiete "sonoscli";
    imsg = stepiete "imsg";
  };

  firstPartyPlugins = lib.filter (p: p != null) (lib.mapAttrsToList (name: source:
    if (cfg.firstParty.${name}.enable or false) then { inherit source; } else null
  ) firstPartySources);

  effectivePlugins = cfg.plugins ++ firstPartyPlugins;

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
          then "${homeDir}/.clawdbot"
          else "${homeDir}/.clawdbot-${name}";
        description = "State directory for this Clawdbot instance (logs, sessions, config).";
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

      logPath = lib.mkOption {
        type = lib.types.str;
        default = if name == "default"
          then "/tmp/clawdbot/clawdbot-gateway.log"
          else "/tmp/clawdbot/clawdbot-gateway-${name}.log";
        description = "Log path for this Clawdbot gateway instance.";
      };

      gatewayPort = lib.mkOption {
        type = lib.types.int;
        default = 18789;
        description = "Gateway port used by the Clawdbot desktop app.";
      };

      gatewayPath = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Local path to Clawdbot gateway source (dev only).";
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
        default = effectivePlugins;
        description = "Plugins enabled for this instance (includes first-party toggles).";
      };

      providers.anthropic = {
        apiKeyFile = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Path to Anthropic API key file (used to set ANTHROPIC_API_KEY).";
        };
      };

      agent = {
        model = lib.mkOption {
          type = lib.types.str;
          default = cfg.defaults.model;
          description = "Default model for this instance (provider/model). Maps to agent.model.primary.";
        };
        thinkingDefault = lib.mkOption {
          type = lib.types.enum [ "off" "minimal" "low" "medium" "high" ];
          default = cfg.defaults.thinkingDefault;
          description = "Default thinking level for this instance (\"max\" maps to \"high\").";
        };
      };

      routing.queue = {
        mode = lib.mkOption {
          type = lib.types.enum [ "queue" "interrupt" ];
          default = "interrupt";
          description = "Queue mode when a run is active.";
        };

        byProvider = lib.mkOption {
          type = lib.types.attrs;
          default = {
            telegram = "interrupt";
            discord = "queue";
            webchat = "queue";
          };
          description = "Per-provider queue mode overrides.";
        };
      };

      

      launchd.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Run Clawdbot gateway via launchd (macOS).";
      };

      launchd.label = lib.mkOption {
        type = lib.types.str;
        default = if name == "default"
          then "com.steipete.clawdbot.gateway"
          else "com.steipete.clawdbot.gateway.${name}";
        description = "launchd label for this instance.";
      };

      systemd.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Run Clawdbot gateway via systemd user service (Linux).";
      };

      systemd.unitName = lib.mkOption {
        type = lib.types.str;
        default = if name == "default"
          then "clawdbot-gateway"
          else "clawdbot-gateway-${name}";
        description = "systemd user service unit name for this instance.";
      };

      app.install.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Install Clawdbot.app for this instance.";
      };

      app.install.path = lib.mkOption {
        type = lib.types.str;
        default = "${homeDir}/Applications/Clawdbot.app";
        description = "Destination path for this instance's Clawdbot.app bundle.";
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
        description = "Additional Clawdbot config to merge into the generated JSON.";
      };

      config = lib.mkOption {
        type = lib.types.submodule { options = generatedConfigOptions; };
        default = {};
        description = "Upstream Clawdbot config (generated from schema).";
      };
    };
  };

  defaultInstance = {
    enable = cfg.enable;
    package = cfg.package;
    stateDir = cfg.stateDir;
    workspaceDir = cfg.workspaceDir;
    configPath = "${cfg.stateDir}/clawdbot.json";
    logPath = "/tmp/clawdbot/clawdbot-gateway.log";
    gatewayPort = 18789;
    providers = cfg.providers;
    routing = cfg.routing;
    launchd = cfg.launchd;
    systemd = cfg.systemd;
    plugins = cfg.plugins;
    configOverrides = {};
    config = {};
    appDefaults = {
      enable = true;
      attachExistingOnly = true;
    };
    app = {
      install = {
        enable = false;
        path = "${homeDir}/Applications/Clawdbot.app";
      };
    };
  };

  instances = if cfg.instances != {}
    then cfg.instances
    else lib.optionalAttrs cfg.enable { default = defaultInstance; };

  enabledInstances = lib.filterAttrs (_: inst: inst.enable) instances;
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

  renderSkill = skill:
    let
      metadataLine =
        if skill ? clawdbot && skill.clawdbot != null
        then "metadata: ${builtins.toJSON { clawdbot = skill.clawdbot; }}"
        else null;
      homepageLine =
        if skill ? homepage && skill.homepage != null
        then "homepage: ${skill.homepage}"
        else null;
      frontmatterLines = lib.filter (line: line != null) [
        "---"
        "name: ${skill.name}"
        "description: ${skill.description}"
        homepageLine
        metadataLine
        "---"
      ];
      frontmatter = lib.concatStringsSep "\n" frontmatterLines;
      body = if skill ? body then skill.body else "";
    in
      "${frontmatter}\n\n${body}\n";

  skillAssertions =
    let
      names = map (skill: skill.name) cfg.skills;
      nameCounts = lib.foldl' (acc: name: acc // { "${name}" = (acc.${name} or 0) + 1; }) {} names;
      duplicateNames = lib.attrNames (lib.filterAttrs (_: v: v > 1) nameCounts);
      dupAssertions =
        if duplicateNames == [] then [] else [
          {
            assertion = false;
            message = "programs.clawdbot.skills has duplicate names: ${lib.concatStringsSep ", " duplicateNames}";
          }
        ];
    in
      dupAssertions;

  skillFiles =
    let
      entriesForInstance = instName: inst:
        let
          base = "${toRelative (resolvePath inst.workspaceDir)}/skills";
          entryFor = skill:
            let
              mode = skill.mode or "symlink";
              source = if skill ? source && skill.source != null then resolvePath skill.source else null;
            in
              if mode == "inline" then
                {
                  name = "${base}/${skill.name}/SKILL.md";
                  value = { text = renderSkill skill; };
                }
              else if mode == "copy" then
                {
                  name = "${base}/${skill.name}";
                  value = {
                    source = builtins.path {
                      name = "clawdbot-skill-${skill.name}";
                      path = source;
                    };
                    recursive = true;
                  };
                }
              else
                {
                  name = "${base}/${skill.name}";
                  value = {
                    source = config.lib.file.mkOutOfStoreSymlink source;
                    recursive = true;
                  };
                };
        in
          map entryFor cfg.skills;
    in
      lib.listToAttrs (lib.flatten (lib.mapAttrsToList entriesForInstance enabledInstances));

  documentsAssertions = lib.optionals documentsEnabled [
    {
      assertion = builtins.pathExists cfg.documents;
      message = "programs.clawdbot.documents must point to an existing directory.";
    }
    {
      assertion = builtins.pathExists (cfg.documents + "/AGENTS.md");
      message = "Missing AGENTS.md in programs.clawdbot.documents.";
    }
    {
      assertion = builtins.pathExists (cfg.documents + "/SOUL.md");
      message = "Missing SOUL.md in programs.clawdbot.documents.";
    }
    {
      assertion = builtins.pathExists (cfg.documents + "/TOOLS.md");
      message = "Missing TOOLS.md in programs.clawdbot.documents.";
    }
  ];

  documentsGuard =
    lib.optionalString documentsEnabled (
      let
        guardLine = file: ''
          if [ -e "${file}" ] && [ ! -L "${file}" ]; then
            echo "Clawdbot documents are managed by Nix. Please adopt ${file} into your documents directory and re-run." >&2
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
          toolNames = toolSets.toolNames or [];
          renderPkgName = pkg:
            if pkg ? pname then pkg.pname else lib.getName pkg;
          renderPlugin = plugin:
            let
              pkgNames = map renderPkgName (lib.filter (p: p != null) plugin.packages);
              pkgSuffix =
                if pkgNames == []
                then ""
                else " — " + (lib.concatStringsSep ", " pkgNames);
            in
              "- " + plugin.name + pkgSuffix + " (" + plugin.source + ")";
          pluginLinesFor = instName: inst:
            let
              plugins = resolvedPluginsByInstance.${instName} or [];
              lines = if plugins == [] then [ "- (none)" ] else map renderPlugin plugins;
            in
              [
                ""
                "### Instance: ${instName}"
              ] ++ lines;
        reportLines =
          [
            "<!-- BEGIN NIX-REPORT -->"
            ""
            "## Nix-managed tools"
            ""
            "### Built-in toolchain"
          ]
          ++ (if toolNames == [] then [ "- (none)" ] else map (name: "- " + name) toolNames)
          ++ [
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
        pkgs.writeText "clawdbot-tools-report.md" reportText
    else
      null;

  toolsWithReport =
    if documentsEnabled then
      pkgs.runCommand "clawdbot-tools-with-report.md" {} ''
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
    clawdbotPlugin =
      if flake ? clawdbotPlugin then flake.clawdbotPlugin
      else throw "clawdbotPlugin missing in ${plugin.source}";
    needs = clawdbotPlugin.needs or {};
  in {
    source = plugin.source;
    name = clawdbotPlugin.name or (throw "clawdbotPlugin.name missing in ${plugin.source}");
    skills = clawdbotPlugin.skills or [];
    packages = clawdbotPlugin.packages or [];
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
          "programs.clawdbot.instances.${instName}: duplicate plugin names detected (${lib.concatStringsSep ", " duplicates}); last entry wins."
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
          lib.filter (req: !(builtins.hasAttr req (envFor p))) p.needs.requiredEnv;
        configMissingStateDir = p:
          (p.config.settings or {}) != {} && (p.needs.stateDirs or []) == [];
        mkAssertion = p:
          let
            missing = missingFor p;
          in {
            assertion = missing == [];
            message = "programs.clawdbot.instances.${instName}: plugin ${p.name} missing required env: ${lib.concatStringsSep ", " missing}";
          };
        mkConfigAssertion = p: {
          assertion = !(configMissingStateDir p);
          message = "programs.clawdbot.instances.${instName}: plugin ${p.name} provides settings but declares no stateDirs (needed for config.json).";
        };
      in
        (map mkAssertion plugins) ++ (map mkConfigAssertion plugins)
    ) enabledInstances);

  pluginSkillsFiles =
    let
      entriesForInstance = instName: inst:
        let
          base = "${toRelative (resolvePath inst.workspaceDir)}/skills";
          skillEntriesFor = p:
            map (skillPath: {
              name = "${base}/${p.name}/${builtins.baseNameOf skillPath}";
              value = { source = skillPath; recursive = true; };
            }) p.skills;
          plugins = resolvedPluginsByInstance.${instName} or [];
        in
          lib.flatten (map skillEntriesFor plugins);
    in
      lib.listToAttrs (lib.flatten (lib.mapAttrsToList entriesForInstance enabledInstances));

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
        lib.flatten (lib.concatLists (lib.mapAttrsToList (instName: inst:
          let
            base = "${toRelative (resolvePath inst.workspaceDir)}/skills";
            plugins = resolvedPluginsByInstance.${instName} or [];
          in
            map (p:
              map (skillPath:
                "${base}/${p.name}/${builtins.baseNameOf skillPath}"
              ) p.skills
            ) plugins
        ) enabledInstances));
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
        pkgs.callPackage ../../packages/clawdbot-gateway.nix {
          gatewaySrc = builtins.path {
            path = inst.gatewayPath;
            name = "clawdbot-gateway-src";
          };
          pnpmDepsHash = inst.gatewayPnpmDepsHash;
        }
      else
        inst.package;
    pluginPackages = pluginPackagesFor name;
    pluginEnvAll = pluginEnvAllFor name;
    baseConfig = mkBaseConfig inst.workspaceDir inst;
    mergedConfig = lib.recursiveUpdate
      (lib.recursiveUpdate baseConfig (lib.recursiveUpdate (mkTelegramConfig inst) (mkRoutingConfig inst)))
      inst.configOverrides;
    configJson = builtins.toJSON mergedConfig;
    configFile = pkgs.writeText "clawdbot-${name}.json" configJson;
    gatewayWrapper = pkgs.writeShellScriptBin "clawdbot-gateway-${name}" ''
      set -euo pipefail

      if [ -n "${lib.makeBinPath pluginPackages}" ]; then
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

      exec "${gatewayPackage}/bin/clawdbot" "$@"
    '';
  in {
    homeFile = {
      name = toRelative inst.configPath;
      value = { text = configJson; };
    };
    configFile = configFile;
    configPath = inst.configPath;

    dirs = [ inst.stateDir inst.workspaceDir (builtins.dirOf inst.logPath) ];

    launchdAgent = lib.optionalAttrs (pkgs.stdenv.hostPlatform.isDarwin && inst.launchd.enable) {
      "${inst.launchd.label}" = {
        enable = true;
        config = {
          Label = inst.launchd.label;
          ProgramArguments = [
            "${gatewayWrapper}/bin/clawdbot-gateway-${name}"
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
          CLAWDBOT_CONFIG_PATH = inst.configPath;
          CLAWDBOT_STATE_DIR = inst.stateDir;
          CLAWDBOT_IMAGE_BACKEND = "sips";
          CLAWDBOT_NIX_MODE = "1";
          # Backward-compatible env names (gateway still uses CLAWDIS_* in some builds).
          CLAWDIS_CONFIG_PATH = inst.configPath;
          CLAWDIS_STATE_DIR = inst.stateDir;
          CLAWDIS_IMAGE_BACKEND = "sips";
          CLAWDIS_NIX_MODE = "1";
        };
      };
    };
    };

    systemdService = lib.optionalAttrs (pkgs.stdenv.hostPlatform.isLinux && inst.systemd.enable) {
      "${inst.systemd.unitName}" = {
        Unit = {
          Description = "Clawdbot gateway (${name})";
        };
        Service = {
          ExecStart = "${gatewayWrapper}/bin/clawdbot-gateway-${name} gateway --port ${toString inst.gatewayPort}";
          WorkingDirectory = inst.stateDir;
          Restart = "always";
          RestartSec = "1s";
          Environment = [
            "HOME=${homeDir}"
            "CLAWDBOT_CONFIG_PATH=${inst.configPath}"
            "CLAWDBOT_STATE_DIR=${inst.stateDir}"
            "CLAWDBOT_NIX_MODE=1"
            "CLAWDIS_CONFIG_PATH=${inst.configPath}"
            "CLAWDIS_STATE_DIR=${inst.stateDir}"
            "CLAWDIS_NIX_MODE=1"
          ];
          StandardOutput = "append:${inst.logPath}";
          StandardError = "append:${inst.logPath}";
        };
        Install = {
          WantedBy = [ "default.target" ];
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
        source = "${appPackage}/Applications/Clawdbot.app";
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
  pluginPackagesAll = lib.flatten (map pluginPackagesFor (lib.attrNames enabledInstances));
  pluginStateDirsAll = lib.flatten (map pluginStateDirsFor (lib.attrNames enabledInstances));

  assertions = lib.flatten (lib.mapAttrsToList (name: inst: [
    {
      assertion = !inst.providers.telegram.enable || inst.providers.telegram.botTokenFile != "";
      message = "programs.clawdbot.instances.${name}.providers.telegram.botTokenFile must be set when Telegram is enabled.";
    }
    {
      assertion = !inst.providers.telegram.enable || (lib.length inst.providers.telegram.allowFrom > 0);
      message = "programs.clawdbot.instances.${name}.providers.telegram.allowFrom must be non-empty when Telegram is enabled.";
    }
  ]) enabledInstances);

in {
  options.programs.clawdbot = {
    enable = lib.mkEnableOption "Clawdbot (batteries-included)";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.clawdbot;
      description = "Clawdbot batteries-included package.";
    };

    toolNames = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      default = null;
      description = "Override the built-in toolchain names (see nix/tools/extended.nix).";
    };

    excludeTools = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Tool names to remove from the built-in toolchain.";
    };

    appPackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = "Optional Clawdbot app package (defaults to package if unset).";
    };

    installApp = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install Clawdbot.app at the default location.";
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "${homeDir}/.clawdbot";
      description = "State directory for Clawdbot (logs, sessions, config).";
    };

    workspaceDir = lib.mkOption {
      type = lib.types.str;
      default = "${homeDir}/.clawdbot/workspace";
      description = "Workspace directory for Clawdbot agent skills.";
    };

    documents = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to a documents directory containing AGENTS.md, SOUL.md, and TOOLS.md.";
    };

    skills = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Skill name (used as the directory name).";
          };
          description = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Short description for the skill frontmatter.";
          };
          homepage = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Optional homepage URL for the skill frontmatter.";
          };
          body = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Optional skill body (markdown).";
          };
          clawdbot = lib.mkOption {
            type = lib.types.nullOr lib.types.attrs;
            default = null;
            description = "Optional clawdbot metadata for the skill frontmatter.";
          };
          mode = lib.mkOption {
            type = lib.types.enum [ "symlink" "copy" "inline" ];
            default = "symlink";
            description = "Install mode for the skill (symlink/copy/inline).";
          };
          source = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Source path for the skill (required for symlink/copy).";
          };
        };
      });
      default = [];
      description = "Declarative skills installed into each instance workspace.";
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
      description = "Plugins enabled for the default instance (merged with first-party toggles).";
    };

    defaults = {
      model = lib.mkOption {
        type = lib.types.str;
        default = "anthropic/claude-opus-4-5";
        description = "Default model for all instances (provider/model). Slower and more expensive than smaller models.";
      };
      thinkingDefault = lib.mkOption {
        type = lib.types.enum [ "off" "minimal" "low" "medium" "high" ];
        default = "high";
        description = "Default thinking level for all instances (\"max\" maps to \"high\").";
      };
    };

    firstParty = {
      summarize.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable the summarize plugin (first-party).";
      };
      peekaboo.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable the peekaboo plugin (first-party).";
      };
      oracle.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the oracle plugin (first-party).";
      };
      poltergeist.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the poltergeist plugin (first-party).";
      };
      sag.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the sag plugin (first-party).";
      };
      camsnap.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the camsnap plugin (first-party).";
      };
      gogcli.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the gogcli plugin (first-party).";
      };
      bird.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the bird plugin (first-party).";
      };
      sonoscli.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the sonoscli plugin (first-party).";
      };
      imsg.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the imsg plugin (first-party).";
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
        description = "Path to Anthropic API key file (used to set ANTHROPIC_API_KEY).";
      };
    };

    routing.queue = {
      mode = lib.mkOption {
        type = lib.types.enum [ "queue" "interrupt" ];
        default = "interrupt";
        description = "Queue mode when a run is active.";
      };

      byProvider = lib.mkOption {
        type = lib.types.attrs;
        default = {
          telegram = "interrupt";
          discord = "queue";
          webchat = "queue";
        };
        description = "Per-provider queue mode overrides.";
      };
    };


    launchd.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Run Clawdbot gateway via launchd (macOS).";
    };

    systemd.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Run Clawdbot gateway via systemd user service (Linux).";
    };

    instances = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule instanceModule);
      default = {};
      description = "Named Clawdbot instances (prod/test).";
    };

    exposePluginPackages = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Add plugin packages to home.packages so CLIs are on PATH.";
    };

    reloadScript = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Install clawdbot-reload helper for no-sudo config refresh + gateway restart.";
      };
    };

    config = lib.mkOption {
      type = lib.types.submodule { options = generatedConfigOptions; };
      default = {};
      description = "Upstream Clawdbot config (generated from schema).";
    };
  };

  config = lib.mkIf (cfg.enable || cfg.instances != {}) {
    assertions = assertions ++ [
      {
        assertion = lib.length (lib.attrNames appDefaultsEnabled) <= 1;
        message = "Only one Clawdbot instance may enable appDefaults.";
      }
    ] ++ documentsAssertions ++ skillAssertions ++ pluginAssertions ++ pluginSkillAssertions;

    home.packages = lib.unique (
      (map (item: item.package) instanceConfigs)
      ++ (lib.optionals cfg.exposePluginPackages pluginPackagesAll)
    );

    home.file =
      (lib.listToAttrs (map (item: item.homeFile) instanceConfigs))
      // (lib.optionalAttrs (pkgs.stdenv.hostPlatform.isDarwin && appPackage != null && cfg.installApp) {
        "Applications/Clawdbot.app" = {
          source = "${appPackage}/Applications/Clawdbot.app";
          recursive = true;
          force = true;
        };
      })
      // (lib.listToAttrs appInstalls)
      // documentsFiles
      // skillFiles
      // pluginSkillsFiles
      // pluginConfigFiles
      // (lib.optionalAttrs cfg.reloadScript.enable {
        ".local/bin/clawdbot-reload" = {
          executable = true;
          source = ./clawdbot-reload.sh;
        };
      });

    home.activation.clawdbotDocumentGuard = lib.mkIf documentsEnabled (
      lib.hm.dag.entryBefore [ "writeBoundary" ] ''
        set -euo pipefail
        ${documentsGuard}
      ''
    );

    home.activation.clawdbotDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p ${lib.concatStringsSep " " (lib.concatMap (item: item.dirs) instanceConfigs)}
      ${lib.optionalString (pluginStateDirsAll != []) "run mkdir -p ${lib.concatStringsSep " " pluginStateDirsAll}"}
    '';

    home.activation.clawdbotConfigFiles = lib.hm.dag.entryAfter [ "clawdbotDirs" ] ''
      set -euo pipefail
      ${lib.concatStringsSep "\n" (map (item: "run ln -sfn ${item.configFile} ${item.configPath}") instanceConfigs)}
    '';

    home.activation.clawdbotPluginGuard = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      set -euo pipefail
      ${pluginGuards}
    '';

    home.activation.clawdbotAppDefaults = lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin && appDefaults != {}) (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        /usr/bin/defaults write com.steipete.Clawdbot clawdbot.gateway.attachExistingOnly -bool ${lib.boolToString (appDefaults.attachExistingOnly or true)}
        /usr/bin/defaults write com.steipete.Clawdbot gatewayPort -int ${toString (appDefaults.gatewayPort or 18789)}
      ''
    );

    home.activation.clawdbotLaunchdRelink = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
      lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        /usr/bin/env bash ${./clawdbot-launchd-relink.sh}
      ''
    );

    systemd.user.services = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (
      lib.mkMerge (map (item: item.systemdService) instanceConfigs)
    );

    launchd.agents = lib.mkMerge (map (item: item.launchdAgent) instanceConfigs);
  };
}
