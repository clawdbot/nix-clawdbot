{
  config,
  lib,
  pkgs,
  ...
}:

let
  openclawLib = import ./lib.nix { inherit config lib pkgs; };
  cfg = openclawLib.cfg;
  homeDir = openclawLib.homeDir;
  appPackage = openclawLib.appPackage;
  qmdPackage = openclawLib.qmdPackage;
  toJSONWithContext = import ../../../lib/json-with-context.nix { inherit lib; };

  defaultInstance = {
    enable = cfg.enable;
    package = openclawLib.defaultPackage;
    stateDir = cfg.stateDir;
    workspaceDir = cfg.workspaceDir;
    configPath = "${cfg.stateDir}/openclaw.json";
    logPath = "/tmp/openclaw/openclaw-gateway.log";
    gatewayPort = 18789;
    gatewayPath = null;
    gatewayPnpmDepsHash = lib.fakeHash;
    runtimePackages = [ ];
    environment = { };
    launchd = cfg.launchd;
    systemd = cfg.systemd;
    plugins = openclawLib.effectivePlugins;
    runtimePlugins = cfg.runtimePlugins;
    runtimePluginSources = cfg.runtimePluginSources;
    config = { };
    appDefaults = {
      enable = true;
      attachExistingOnly = true;
    };
    app = {
      install = {
        enable = false;
        path = "${homeDir}/Applications/OpenClaw.app";
      };
    };
  };

  instances =
    if cfg.instances != { } then
      cfg.instances
    else
      lib.optionalAttrs cfg.enable { default = defaultInstance; };

  enabledInstances = lib.filterAttrs (_: inst: inst.enable) instances;

  plugins = import ./plugins.nix {
    inherit
      lib
      pkgs
      openclawLib
      enabledInstances
      ;
  };

  files = import ./files.nix {
    inherit
      lib
      pkgs
      openclawLib
      enabledInstances
      plugins
      ;
  };
  skills = import ./skills.nix {
    inherit
      lib
      pkgs
      openclawLib
      enabledInstances
      plugins
      ;
  };
  runtimePlugins = import ./runtime-plugins.nix { inherit lib pkgs; };

  stripNulls =
    value:
    if value == null then
      null
    else if builtins.isAttrs value then
      lib.filterAttrs (_: v: v != null) (builtins.mapAttrs (_: stripNulls) value)
    else if builtins.isList value then
      builtins.filter (v: v != null) (map stripNulls value)
    else
      value;

  execSecretFlowDocsUrl = "https://github.com/openclaw/nix-openclaw#secrets-and-openclaw-exec-secretrefs";

  containsExecSecretFlow =
    value:
    if builtins.isAttrs value then
      ((value.source or null) == "exec" && ((value ? command) || ((value ? provider) && (value ? id))))
      || lib.any containsExecSecretFlow (builtins.attrValues value)
    else if builtins.isList value then
      lib.any containsExecSecretFlow value
    else
      false;

  baseConfig = {
    gateway = {
      mode = "local";
    };
  };

  mkInstanceConfig =
    name: inst:
    let
      gatewayPackage =
        if inst.gatewayPath != null then
          pkgs.callPackage ../../../packages/openclaw-gateway.nix {
            sourceInfo = import ../../../sources/openclaw-source.nix;
            gatewaySrc = builtins.path {
              path = inst.gatewayPath;
              name = "openclaw-gateway-src";
            };
            pnpmDepsHash = inst.gatewayPnpmDepsHash;
          }
        else
          inst.package;
      pluginPackages = plugins.pluginPackagesFor name;
      runtimePackages = lib.unique (
        openclawLib.toolSets.tools
        ++ (lib.optional (qmdEnabled && qmdPackage != null) qmdPackage)
        ++ pluginPackages
        ++ cfg.runtimePackages
        ++ inst.runtimePackages
      );
      runtimeProfile = pkgs.symlinkJoin {
        name = "openclaw-runtime-${name}";
        paths = runtimePackages;
      };
      runtimePath = lib.makeBinPath runtimePackages;
      runtimeEnvAll =
        (plugins.pluginEnvAllFor name)
        ++ (lib.mapAttrsToList (key: value: {
          inherit key value;
          plugin = "runtime";
        }) (cfg.environment // inst.environment));
      userConfig = stripNulls (lib.recursiveUpdate (stripNulls cfg.config) (stripNulls inst.config));
      nixSkillLoadDirs = skills.skillLoadDirsForInstance name;
      mergedConfigWithoutLoadPaths = stripNulls (lib.recursiveUpdate baseConfig userConfig);
      existingOpenClawPluginLoadPaths = (
        ((mergedConfigWithoutLoadPaths.plugins or { }).load or { }).paths or [ ]
      );
      existingSkillLoadDirs = (
        ((mergedConfigWithoutLoadPaths.skills or { }).load or { }).extraDirs or [ ]
      );
      existingAllowList = ((mergedConfigWithoutLoadPaths.plugins or { }).allow or null);
      existingDenyList = ((userConfig.plugins or { }).deny or [ ]);
      userPluginEntries = ((userConfig.plugins or { }).entries or { });
      runtimePluginConfig = runtimePlugins.forInstance {
        inherit
          name
          existingAllowList
          userPluginEntries
          ;
        openclawPackage = gatewayPackage;
        ids = inst.runtimePlugins;
        sources = inst.runtimePluginSources;
        existingLoadPaths = existingOpenClawPluginLoadPaths;
        denyList = existingDenyList;
        nixOpenClawPluginIds = [ ];
      };
      disablePersistedPluginRegistry = runtimePluginConfig.loadPaths != [ ];
      generatedPluginConfig = lib.recursiveUpdate (lib.optionalAttrs
        (runtimePluginConfig.loadPaths != [ ])
        {
          plugins = {
            load = {
              paths = lib.unique (runtimePluginConfig.loadPaths ++ existingOpenClawPluginLoadPaths);
            };
          };
        }
      ) runtimePluginConfig.config;
      generatedSkillLoadConfig = lib.optionalAttrs (nixSkillLoadDirs != [ ]) {
        skills = {
          load = {
            extraDirs = lib.unique (nixSkillLoadDirs ++ existingSkillLoadDirs);
          };
        };
      };
      generatedBootstrapConfig = lib.optionalAttrs files.bootstrapFilesEnabled {
        agents = {
          defaults = {
            skipBootstrap = true;
          };
        };
      };
      generatedLoadConfig = lib.foldl' lib.recursiveUpdate { } [
        generatedPluginConfig
        generatedSkillLoadConfig
        generatedBootstrapConfig
      ];
      userSkipBootstrap = (
        ((mergedConfigWithoutLoadPaths.agents or { }).defaults or { }).skipBootstrap or null
      );
      bootstrapAssertions = lib.optionals (files.bootstrapFilesEnabled && userSkipBootstrap == false) [
        {
          assertion = false;
          message = "programs.openclaw.workspace.bootstrapFiles requires agents.defaults.skipBootstrap to stay true. Remove programs.openclaw.config.agents.defaults.skipBootstrap = false; OpenClaw must not seed bootstrap files in Nix-managed workspaces.";
        }
      ];
      mergedConfig0 = lib.recursiveUpdate mergedConfigWithoutLoadPaths generatedLoadConfig;
      existingWorkspace = (((mergedConfig0.agents or { }).defaults or { }).workspace or null);
      mergedConfig =
        if (cfg.workspace.pinAgentDefaults or true) && existingWorkspace == null then
          lib.recursiveUpdate mergedConfig0 {
            agents = {
              defaults = {
                workspace = inst.workspaceDir;
              };
            };
          }
        else
          mergedConfig0;
      hasExecSecretFlow = containsExecSecretFlow mergedConfig;
      execSecretFlowWarning = "programs.openclaw.instances.${name}.config uses OpenClaw exec secrets. nix-openclaw passes this through, but does not support or verify runtime command-based secret resolution. Prefer host-managed secrets with env/file SecretRefs: ${execSecretFlowDocsUrl}";
      qmdEnabled = (((mergedConfig.memory or { }).backend or null) == "qmd");
      gatewayRuntimePackage =
        if qmdEnabled && qmdPackage != null then
          let
            qmdPath = lib.makeBinPath [ qmdPackage ];
          in
          pkgs.stdenvNoCC.mkDerivation {
            name = "${lib.getName gatewayPackage}-qmd";
            dontUnpack = true;
            nativeBuildInputs = [ pkgs.makeWrapper ];
            OPENCLAW_GATEWAY_PACKAGE = "${gatewayPackage}";
            OPENCLAW_GATEWAY_BIN = "${gatewayPackage}/bin/openclaw";
            OPENCLAW_QMD_PATH = qmdPath;
            STDENV_SETUP = "${pkgs.stdenvNoCC}/setup";
            installPhase = "${../../../scripts/openclaw-qmd-wrapper-install.sh}";
          }
        else
          gatewayPackage;
      rawConfigJson = toJSONWithContext mergedConfig;
      configJson =
        if hasExecSecretFlow then lib.warn execSecretFlowWarning rawConfigJson else rawConfigJson;
      configFile = pkgs.writeText "openclaw-${name}.json" configJson;
      agentIds =
        let
          agents = ((mergedConfig.agents or { }).list or [ ]);
          configured = lib.filter (id: id != null) (map (agent: agent.id or null) agents);
        in
        lib.unique ([ "main" ] ++ configured);
      codexRuntimeProfiles = map (
        agentId: "${inst.stateDir}/agents/${agentId}/agent/codex-home/home/.nix-profile"
      ) agentIds;
      gatewayWrapper = pkgs.writeShellScriptBin "openclaw-gateway-${name}" ''
        set -euo pipefail

        if [ -n "${runtimePath}" ]; then
          export PATH="${runtimePath}:$PATH"
        fi

        ${lib.concatStringsSep "\n" (
          map (
            entry:
            let
              isFile = lib.hasSuffix "_FILE" entry.key;
            in
            ''
              if [ -f "${entry.value}" ]; then
                if ${if isFile then "true" else "false"}; then
                  export ${entry.key}="${entry.value}"
                else
                  rawValue="$("${lib.getExe' pkgs.coreutils "cat"}" "${entry.value}")"
                  if [ "''${rawValue#${entry.key}=}" != "$rawValue" ]; then
                    export ${entry.key}="''${rawValue#${entry.key}=}"
                  else
                    export ${entry.key}="$rawValue"
                  fi
                fi
              else
                export ${entry.key}="${entry.value}"
              fi
            ''
          ) runtimeEnvAll
        )}

        exec "${gatewayRuntimePackage}/bin/openclaw" "$@"
      '';
      appDefaults = lib.optionalAttrs (pkgs.stdenv.hostPlatform.isDarwin && inst.appDefaults.enable) {
        attachExistingOnly = inst.appDefaults.attachExistingOnly;
        gatewayPort = inst.gatewayPort;
        nixMode = inst.appDefaults.nixMode;
      };

      appInstall =
        if !(pkgs.stdenv.hostPlatform.isDarwin && inst.app.install.enable && appPackage != null) then
          null
        else
          {
            name = lib.removePrefix "${homeDir}/" inst.app.install.path;
            value = {
              source = "${appPackage}/Applications/OpenClaw.app";
              recursive = true;
              force = true;
            };
          };

      package = gatewayRuntimePackage;
    in
    {
      name = name;
      homeFile = {
        name = openclawLib.toRelative inst.configPath;
        value = {
          source = configFile;
          text = builtins.unsafeDiscardStringContext configJson;
          force = true;
        };
      };
      configFile = configFile;
      configPath = inst.configPath;
      codexRuntimeProfiles = codexRuntimeProfiles;
      runtimeProfile = runtimeProfile;

      dirs = [
        inst.stateDir
        inst.workspaceDir
        (builtins.dirOf inst.logPath)
      ];

      launchdAgent = lib.optionalAttrs (pkgs.stdenv.hostPlatform.isDarwin && inst.launchd.enable) {
        "${inst.launchd.label}" = {
          enable = true;
          config = {
            Label = inst.launchd.label;
            ProgramArguments = [
              "${gatewayWrapper}/bin/openclaw-gateway-${name}"
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
              OPENCLAW_CONFIG_PATH = inst.configPath;
              OPENCLAW_STATE_DIR = inst.stateDir;
              OPENCLAW_IMAGE_BACKEND = "sips";
              OPENCLAW_NIX_MODE = "1";
            }
            // lib.optionalAttrs disablePersistedPluginRegistry {
              OPENCLAW_DISABLE_PERSISTED_PLUGIN_REGISTRY = "1";
            };
          };
        };
      };

      systemdService = lib.optionalAttrs (pkgs.stdenv.hostPlatform.isLinux && inst.systemd.enable) {
        "${inst.systemd.unitName}" = {
          Unit = {
            Description = "OpenClaw gateway (${name})";
          };
          Service = {
            ExecStart = "${gatewayWrapper}/bin/openclaw-gateway-${name} gateway --port ${toString inst.gatewayPort}";
            WorkingDirectory = inst.stateDir;
            Restart = "always";
            RestartSec = "1s";
            # Systemd needs whole quoted items, not shell quote concatenation.
            Environment = map builtins.toJSON [
              "HOME=${homeDir}"
              "OPENCLAW_CONFIG_PATH=${inst.configPath}"
              "OPENCLAW_STATE_DIR=${inst.stateDir}"
              "OPENCLAW_NIX_MODE=1"
            ]
            ++ lib.optional disablePersistedPluginRegistry "OPENCLAW_DISABLE_PERSISTED_PLUGIN_REGISTRY=1";
            StandardOutput = "append:${inst.logPath}";
            StandardError = "append:${inst.logPath}";
          };
        };
      };

      appDefaults = appDefaults;
      appInstall = appInstall;
      package = package;
      qmdEnabled = qmdEnabled;
      runtimePluginPackages = runtimePluginConfig.packages;
      assertions = runtimePluginConfig.assertions ++ bootstrapAssertions;
      launchdLabel =
        if pkgs.stdenv.hostPlatform.isDarwin && inst.launchd.enable then inst.launchd.label else null;
      systemdUnitName =
        if pkgs.stdenv.hostPlatform.isLinux && inst.systemd.enable then inst.systemd.unitName else null;
    };

  instanceConfigs = lib.mapAttrsToList mkInstanceConfig enabledInstances;
  codexRuntimeProfileEntries = lib.flatten (
    map (
      item:
      map (profileDir: {
        inherit profileDir;
        binDir = "${item.runtimeProfile}/bin";
      }) item.codexRuntimeProfiles
    ) instanceConfigs
  );
  codexRuntimeProfilesManifest = pkgs.writeText "openclaw-codex-runtime-profiles.tsv" (
    (lib.concatStringsSep "\n" (
      map (entry: "${entry.profileDir}\t${entry.binDir}") codexRuntimeProfileEntries
    ))
    + "\n"
  );
  appInstalls = lib.filter (item: item != null) (map (item: item.appInstall) instanceConfigs);
  launchdLabels = lib.filter (label: label != null) (map (item: item.launchdLabel) instanceConfigs);
  launchdLabelArgs = lib.concatStringsSep " " (map lib.escapeShellArg launchdLabels);
  systemdUnitNames = lib.filter (unitName: unitName != null) (
    map (item: item.systemdUnitName) instanceConfigs
  );
  reloadTargetsByName =
    targetAttr:
    lib.listToAttrs (
      map (item: {
        name = item.name;
        value = item.${targetAttr};
      }) (lib.filter (item: item.${targetAttr} != null) instanceConfigs)
    );
  launchdLabelsByName = reloadTargetsByName "launchdLabel";
  systemdUnitNamesByName = reloadTargetsByName "systemdUnitName";
  reloadTargetsForName =
    targetsByName: targetName:
    if builtins.hasAttr targetName targetsByName then
      [ targetsByName.${targetName} ]
    else if builtins.hasAttr "default" targetsByName then
      [ targetsByName.default ]
    else
      [ ];
  reloadShellArray = values: lib.concatStringsSep " " (map lib.escapeShellArg values);
  reloadScriptText =
    builtins.replaceStrings
      [
        "@openclawReloadTestLaunchdLabels@"
        "@openclawReloadTestSystemdUnits@"
        "@openclawReloadProdLaunchdLabels@"
        "@openclawReloadProdSystemdUnits@"
        "@openclawReloadBothLaunchdLabels@"
        "@openclawReloadBothSystemdUnits@"
      ]
      [
        (reloadShellArray (reloadTargetsForName launchdLabelsByName "test"))
        (reloadShellArray (reloadTargetsForName systemdUnitNamesByName "test"))
        (reloadShellArray (reloadTargetsForName launchdLabelsByName "prod"))
        (reloadShellArray (reloadTargetsForName systemdUnitNamesByName "prod"))
        (reloadShellArray launchdLabels)
        (reloadShellArray systemdUnitNames)
      ]
      (builtins.readFile ../openclaw-reload.sh);
  runtimePluginPackagesAll = lib.unique (
    lib.flatten (map (item: item.runtimePluginPackages) instanceConfigs)
  );

  appDefaults = lib.foldl' (acc: item: lib.recursiveUpdate acc item.appDefaults) { } instanceConfigs;
  appDefaultsEnabled = lib.filterAttrs (_: inst: inst.appDefaults.enable) enabledInstances;
  qmdEnabledInstances = lib.filter (item: item.qmdEnabled) instanceConfigs;

in
{
  config = lib.mkIf (cfg.enable || cfg.instances != { }) {
    assertions = [
      {
        assertion = lib.length (lib.attrNames appDefaultsEnabled) <= 1;
        message = "Only one OpenClaw instance may enable appDefaults.";
      }
      {
        assertion = qmdEnabledInstances == [ ] || qmdPackage != null;
        message = "OpenClaw config memory.backend = \"qmd\" requires a qmd package in openclawPackages.";
      }
    ]
    ++ files.workspaceAssertions
    ++ skills.duplicateSkillAssertion
    ++ plugins.pluginAssertions
    ++ lib.flatten (map (item: item.assertions) instanceConfigs)
    ++ [
      {
        assertion = !cfg.qmd.prewarmModels.enable || qmdPackage != null;
        message = "programs.openclaw.qmd.prewarmModels.enable requires a qmd package in openclawPackages.";
      }
    ];

    home.packages = lib.unique (
      (map (item: item.package) instanceConfigs)
      ++ (lib.optionals cfg.exposePluginPackages plugins.pluginPackagesAll)
    );

    home.file = lib.mkMerge [
      (lib.listToAttrs (map (item: item.homeFile) instanceConfigs))
      (lib.optionalAttrs (pkgs.stdenv.hostPlatform.isDarwin && appPackage != null && cfg.installApp) {
        "Applications/OpenClaw.app" = {
          source = "${appPackage}/Applications/OpenClaw.app";
          recursive = true;
          force = true;
        };
      })
      (lib.listToAttrs appInstalls)
      plugins.pluginConfigFiles
      (lib.optionalAttrs cfg.reloadScript.enable {
        ".local/bin/openclaw-reload" = {
          executable = true;
          text = reloadScriptText;
        };
      })
    ];

    home.activation.openclawDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run --quiet ${lib.getExe' pkgs.coreutils "mkdir"} -p -- ${
        lib.escapeShellArgs (
          map openclawLib.resolvePath (lib.concatMap (item: item.dirs) instanceConfigs)
        )
      }
      ${lib.optionalString (plugins.pluginStateDirsAll != [ ])
        "run --quiet ${lib.getExe' pkgs.coreutils "mkdir"} -p -- ${lib.escapeShellArgs plugins.pluginStateDirsAll}"
      }
    '';

    home.activation.openclawWorkspaceFiles = lib.hm.dag.entryAfter [ "openclawDirs" ] ''
      run --quiet ${../openclaw-materialize-workspace-files.sh} ${lib.escapeShellArg "${homeDir}/.local/state/nix-openclaw/managed-workspace-files"} ${files.materializedManifest} ${files.workspaceRootsManifest}
    '';

    home.activation.openclawSkills = lib.hm.dag.entryAfter [ "openclawDirs" ] ''
      ${lib.optionalString (skills.roots != [ ])
        "run --quiet ${lib.getExe' pkgs.coreutils "mkdir"} -p -- ${lib.escapeShellArgs skills.roots}"
      }
      run --quiet ${../openclaw-materialize-workspace-files.sh} ${lib.escapeShellArg "${homeDir}/.local/state/nix-openclaw/managed-skill-files"} ${skills.materializedManifest} ${skills.rootsManifest}
    '';

    home.activation.openclawConfigFiles = lib.hm.dag.entryAfter [ "openclawDirs" ] ''
      ${lib.concatStringsSep "\n" (
        map (
          item:
          "run --quiet ${lib.getExe' pkgs.coreutils "ln"} -sfn ${lib.escapeShellArg item.configFile} ${lib.escapeShellArg (openclawLib.resolvePath item.configPath)}"
        ) instanceConfigs
      )}
    '';

    home.activation.openclawRuntimePlugins = lib.mkIf (runtimePluginPackagesAll != [ ]) (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${lib.concatStringsSep "\n" (
          map (
            package: "run --quiet ${lib.getExe' pkgs.coreutils "test"} -f ${package}/openclaw.plugin.json"
          ) runtimePluginPackagesAll
        )}
      ''
    );

    home.activation.openclawCodexRuntimeProfiles = lib.mkIf (codexRuntimeProfileEntries != [ ]) (
      lib.hm.dag.entryAfter [ "openclawDirs" ] ''
        run --quiet ${pkgs.bash}/bin/bash ${../openclaw-link-codex-runtime-profiles.sh} ${codexRuntimeProfilesManifest}
      ''
    );

    home.activation.openclawPluginGuard = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      set -euo pipefail
      ${plugins.pluginGuards}
    '';

    home.activation.openclawQmdPrewarm = lib.mkIf (cfg.qmd.prewarmModels.enable && qmdPackage != null) (
      lib.hm.dag.entryAfter [ "openclawDirs" ] ''
        run --quiet ${lib.getExe' pkgs.coreutils "env"} \
          HOME=${lib.escapeShellArg homeDir} \
          XDG_CACHE_HOME=${lib.escapeShellArg "${homeDir}/.cache"} \
          XDG_CONFIG_HOME=${lib.escapeShellArg "${homeDir}/.config"} \
          XDG_DATA_HOME=${lib.escapeShellArg "${homeDir}/.local/share"} \
          OPENCLAW_QMD_BIN=${lib.escapeShellArg "${qmdPackage}/bin/qmd"} \
          ${pkgs.bash}/bin/bash ${../../../scripts/openclaw-qmd-prewarm.sh}
      ''
    );

    home.activation.openclawAppDefaults =
      lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin && appDefaults != { })
        (
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            # Nix mode + app defaults (OpenClaw.app)
            /usr/bin/defaults write ai.openclaw.mac openclaw.nixMode -bool ${
              lib.boolToString (appDefaults.nixMode or true)
            }
            /usr/bin/defaults write ai.openclaw.mac openclaw.gateway.attachExistingOnly -bool ${
              lib.boolToString (appDefaults.attachExistingOnly or true)
            }
            /usr/bin/defaults write ai.openclaw.mac gatewayPort -int ${
              toString (appDefaults.gatewayPort or 18789)
            }
          ''
        );

    home.activation.openclawLaunchdRelink = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
      lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        /usr/bin/env bash ${../openclaw-launchd-relink.sh} ${launchdLabelArgs}
      ''
    );

    systemd.user.services = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (
      lib.mkMerge (map (item: item.systemdService) instanceConfigs)
    );

    launchd.agents = lib.mkMerge (map (item: item.launchdAgent) instanceConfigs);
  };
}
