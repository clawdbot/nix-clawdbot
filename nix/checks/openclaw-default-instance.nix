{
  lib,
  pkgs,
  stdenv,
  nodejs_22,
  includePluginChecks ? false,
  includeQmdChecks ? false,
  includeSourceOverrideChecks ? false,
}:

let
  testLib = lib.extend (
    _final: _prev: {
      hm.dag = {
        entryAfter = after: data: {
          inherit after data;
          before = [ ];
        };
      };
    }
  );

  lockedPathFlake =
    name: path: narHash:
    let
      # If a fixture changes, update with: nix hash path --sri nix/tests/plugins/<name>
      storePath = builtins.path {
        inherit name path;
        sha256 = narHash;
      };
    in
    "path:${builtins.unsafeDiscardStringContext (toString storePath)}?narHash=${narHash}";

  alphaPluginSource =
    lockedPathFlake "openclaw-test-plugin-alpha" ../tests/plugins/alpha
      "sha256-FV4UN38sPy2Yp/HhqUxd0HW5l2PcIBBmUz4JzxTAOXY=";
  betaPluginSource =
    lockedPathFlake "openclaw-test-plugin-beta" ../tests/plugins/beta
      "sha256-lDKtQKHZHqOkOprjLZzBEu8cFJhAdyEzsays9hdVeqE=";
  runtimePluginRootSource =
    lockedPathFlake "openclaw-test-plugin-runtime" ../tests/plugins/runtime
      "sha256-S/N5zWbObP8YpB89B8WylYzWORbw5roz9kFApJAbUOU=";
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

  moduleEval =
    openclawConfig:
    testLib.evalModules {
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
                launchd.enable = pkgs.stdenv.hostPlatform.isDarwin;
                systemd.enable = pkgs.stdenv.hostPlatform.isLinux;
              }
              // openclawConfig;
            };
          }
        )
      ];
      specialArgs = { inherit pkgs; };
    };

  failedAssertions =
    eval: lib.filter (assertion: !(assertion.assertion or false)) eval.config.assertions;

  requireNoAssertionFailures =
    name: eval:
    let
      failures = failedAssertions eval;
      messages = map (assertion: assertion.message or "(no message)") failures;
    in
    if failures == [ ] then "ok" else throw "${name}: ${lib.concatStringsSep "; " messages}";

  requireAssertionFailure =
    name: needle: eval:
    let
      failures = failedAssertions eval;
      matching = lib.filter (assertion: lib.hasInfix needle (assertion.message or "")) failures;
    in
    if matching != [ ] then "ok" else throw "${name}: expected assertion containing `${needle}`.";

  requireEvalFailure =
    name: value:
    let
      attempted = builtins.tryEval (builtins.deepSeq value "ok");
    in
    if attempted.success then throw "${name}: expected evaluation failure." else "ok";
  generatedConfig = eval: path: builtins.fromJSON eval.config.home.file."${path}".text;

  packageHasQmd =
    pkg:
    let
      qmdPath = builtins.unsafeDiscardStringContext (pkg.OPENCLAW_QMD_PATH or "");
    in
    qmdPath != "";
  isPluginSkillPath =
    path: path == "/tmp/.local/share/nix-openclaw/skills/default/skill";

  defaultEval = moduleEval { };
  openclawLib = import ../modules/home-manager/openclaw/lib.nix {
    inherit lib pkgs;
    config = defaultEval.config;
  };
  inherit (openclawLib) usesAgentEntries;
  explicitOwnership = lib.optionalAttrs openclawLib.hasAgentOwnership {
    ownership = "explicit";
  };
  defaultConfig = generatedConfig defaultEval ".openclaw/openclaw.json";
  hasLinuxUnit = builtins.hasAttr "openclaw-gateway" defaultEval.config.systemd.user.services;
  hasDarwinAgent = builtins.hasAttr "com.steipete.openclaw.gateway" defaultEval.config.launchd.agents;
  defaultCheck = builtins.deepSeq [
    (requireNoAssertionFailures "default instance" defaultEval)
    defaultEval.config.home.activation
  ] (
    if pkgs.stdenv.hostPlatform.isLinux && !hasLinuxUnit then
      throw "Default OpenClaw instance missing systemd.unitName."
    else if pkgs.stdenv.hostPlatform.isDarwin && !hasDarwinAgent then
      throw "Default OpenClaw instance missing launchd.label."
    else if (((defaultConfig.gateway or { }).mode or null) != "local") then
      throw "Default OpenClaw instance missing gateway.mode."
    else if lib.any packageHasQmd defaultEval.config.home.packages then
      throw "Default OpenClaw instance unexpectedly includes QMD on its runtime PATH."
    else
      "ok"
  );

  implicitRosterCheck =
    name: value:
    if usesAgentEntries then
      if value.agents.entries != { main = { }; } || value.agents ? ownership then
        throw "${name}: implicit roster must contain only main without an ownership marker."
      else
        "ok"
    else if (value.agents or { }) ? entries then
      throw "${name}: old schema must not emit keyed entries."
    else
      "ok";

  unpinnedConfig = generatedConfig (moduleEval {
    workspace.pinAgentDefaults = false;
  }) ".openclaw/openclaw.json";
  unpinnedRosterCheck =
    if usesAgentEntries then
      if unpinnedConfig.agents != { entries.main = { }; } then
        throw "Unpinned implicit roster must not inject agents.defaults.workspace."
      else
        "ok"
    else if unpinnedConfig ? agents then
      throw "Old unpinned config must keep agents absent."
    else
      "ok";

  emptyRosterChecks = lib.optionals usesAgentEntries (map (
    pinAgentDefaults:
    let
      rendered = generatedConfig (moduleEval {
        workspace = { inherit pinAgentDefaults; };
        config.agents.entries = { };
      }) ".openclaw/openclaw.json";
      expected = { entries.main = { }; } // lib.optionalAttrs pinAgentDefaults {
        defaults.workspace = "/tmp/.openclaw/workspace";
      };
    in
    if rendered.agents != expected then
      throw "Empty non-explicit roster must emit main while preserving workspace pinning."
    else
      "ok"
  ) [ true false ]);

  explicitWorkspaceConfig = generatedConfig (moduleEval {
    config.agents.defaults.workspace = "/tmp/authored-workspace";
  }) ".openclaw/openclaw.json";
  explicitWorkspaceCheck =
    if explicitWorkspaceConfig.agents != ({
      defaults.workspace = "/tmp/authored-workspace";
    } // lib.optionalAttrs usesAgentEntries { entries.main = { }; }) then
      throw "Canonical roster emission must preserve an authored default workspace."
    else
      "ok";

  authoredRosterCases = [
    { entries.writer = { }; }
    { entries.Writer = { }; }
    { entries."_worker-1" = { }; }
    { entries."${lib.concatStrings (lib.replicate 64 "a")}" = { }; }
    { ownership = "explicit"; entries = { }; }
    { ownership = "explicit"; }
    { entries = { writer = { }; research = { }; }; }
    (explicitOwnership // { entries = { writer = { }; research = { }; }; })
  ];
  authoredRosterChecks = lib.optionals usesAgentEntries (map (
    agents:
    let
      evaluated = moduleEval {
        workspace.pinAgentDefaults = false;
        config = { inherit agents; };
      };
      rendered = generatedConfig evaluated ".openclaw/openclaw.json";
    in
    builtins.deepSeq evaluated.config.home.activation (
      if rendered.agents != agents then
        throw "Authored roster or ownership was rewritten instead of preserved for upstream validation."
      else
        "ok"
    )
  ) authoredRosterCases);

  # Upstream trims trailing hyphens on its underscore-prefixed fallback,
  # while alphanumeric IDs retain them through the valid-ID fast path.
  canonicalAgentIdCases = [
    { entries."_worker--" = { }; expected = [ "_worker" ]; }
    { entries."_worker-" = { }; expected = [ "_worker" ]; }
    { entries."_Worker--" = { }; expected = [ "_worker" ]; }
    { entries."_worker-1" = { }; expected = [ "_worker-1" ]; }
    { entries."_worker-_" = { }; expected = [ "_worker-_" ]; }
    { entries."_" = { }; expected = [ "_" ]; }
    { entries."__" = { }; expected = [ "__" ]; }
    { entries."_--" = { }; expected = [ "_" ]; }
    { entries."_-" = { }; expected = [ "_" ]; }
    { entries."__--" = { }; expected = [ "__" ]; }
    { entries."_A-B--" = { }; expected = [ "_a-b" ]; }
    { entries = { worker = { }; "worker-" = { }; }; expected = [ "worker" "worker-" ]; }
    { entries."_${lib.concatStrings (lib.replicate 63 "-")}" = { }; expected = [ "_" ]; }
    { entries.Writer = { }; expected = [ "writer" ]; }
    { entries."0--" = { }; expected = [ "0--" ]; }
    { entries = { a = { }; "a--" = { }; }; expected = [ "a" "a--" ]; }
  ];
  canonicalAgentIdChecks = lib.optionals usesAgentEntries (map (
    { entries, expected }:
    let
      agents = explicitOwnership // { inherit entries; };
      rendered = generatedConfig (moduleEval {
        workspace.pinAgentDefaults = false;
        config = { inherit agents; };
      }) ".openclaw/openclaw.json";
      actual = openclawLib.agentIds rendered;
    in
    if rendered.agents != agents then
      throw "Canonical agent ID fixtures must preserve authored entries and ownership."
    else if actual != expected then
      throw "canonical-keyed-agent-ids ${builtins.toJSON (lib.attrNames entries)}: expected ${builtins.toJSON expected}, got ${builtins.toJSON actual}."
    else
      "ok"
  ) canonicalAgentIdCases);

  invalidRosterChecks = lib.optionals usesAgentEntries (
    map (
      key:
      requireEvalFailure "unsafe agent key" (moduleEval {
        config.agents.entries."${key}" = { };
      }).config.home.activation
    ) [
      ""
      "../outside"
      "nested/agent"
      "-writer"
      "writer.name"
      "writer name"
      "writer\nname"
      (lib.concatStrings (lib.replicate 65 "a"))
    ]
    ++ map (
      keys:
      requireEvalFailure "normalized agent collision ${builtins.toJSON keys}" (moduleEval {
        config.agents = explicitOwnership // { entries = lib.genAttrs keys (_: { }); };
      }).config.home.activation
    ) [
      [ "Writer" "writer" ]
      [ "_worker-" "_worker" ]
      [ "_worker--" "_worker" ]
      [ "_Worker--" "_worker-" ]
      [ "_" "_--" ]
    ]
    ++ [
      (requireEvalFailure "malformed roster value" (generatedConfig (moduleEval {
        config.agents.entries.writer.workspace = 7;
      }) ".openclaw/openclaw.json"))
    ]
  );

  mergedRosterEval = moduleEval {
    config.agents = if usesAgentEntries then {
      entries.writer.workspace = "/tmp/original-writer";
    } else {
      list = [ { id = "writer"; workspace = "/tmp/original-writer"; } ];
    };
    instances.prod = {
      appDefaults.enable = false;
      config.agents = if usesAgentEntries then explicitOwnership // {
        entries = {
          writer.workspace = "/tmp/overridden-writer";
          research = { };
        };
      } else {
        list = [
          { id = "research"; }
          { id = "writer"; workspace = "/tmp/overridden-writer"; }
        ];
      };
    };
  };
  mergedRosterConfig = generatedConfig mergedRosterEval ".openclaw-prod/openclaw.json";
  mergedRosterCheck =
    if mergedRosterConfig.agents != ({
      defaults.workspace = "/tmp/.openclaw-prod/workspace";
    } // (if usesAgentEntries then explicitOwnership // {
      entries = {
        writer.workspace = "/tmp/overridden-writer";
        research = { };
      };
    } else {
      list = [
        { id = "research"; }
        { id = "writer"; workspace = "/tmp/overridden-writer"; }
      ];
    })) then
      throw "Effective instance roster merge changed shape, values, or legacy list order."
    else
      "ok";

  homeRelativeConfigEval = moduleEval {
    instances.default.stateDir = "~/openclaw state";
  };
  homeRelativeConfigCheckFor = eval:
    let
      activation = eval.config.home.activation.openclawConfigFiles.data;
      homeFile = eval.config.home.file;
      generated =
        if builtins.hasAttr "openclaw state/openclaw.json" homeFile then
          generatedConfig eval "openclaw state/openclaw.json"
        else
          { };
      systemdService =
        if pkgs.stdenv.hostPlatform.isLinux then
          eval.config.systemd.user.services.openclaw-gateway.Service or { }
        else
          { };
      launchdConfig =
        if pkgs.stdenv.hostPlatform.isDarwin then
          eval.config.launchd.agents."com.steipete.openclaw.gateway".config or { }
        else
          { };
    in
    if !(lib.hasInfix " '/tmp/openclaw state/openclaw.json'" activation) then
      throw "Config activation must resolve home-relative paths before shell escaping."
    else if builtins.hasAttr "~/openclaw state/openclaw.json" homeFile then
      throw "home.file still uses an unresolved ~/ config destination."
    else if !(builtins.hasAttr "openclaw state/openclaw.json" homeFile) then
      throw "home.file must materialize the resolved config path, not a literal ~/ destination."
    else if (((generated.agents or { }).defaults or { }).workspace or null) != "/tmp/openclaw state/workspace" then
      throw "Workspace pin must resolve home-relative workspaceDir."
    else if pkgs.stdenv.hostPlatform.isLinux && ((systemdService.WorkingDirectory or "") != "/tmp/openclaw state") then
      throw "Systemd WorkingDirectory must resolve home-relative stateDir."
    else if
      pkgs.stdenv.hostPlatform.isLinux
      && !(lib.elem "\"OPENCLAW_STATE_DIR=/tmp/openclaw state\"" (systemdService.Environment or [ ]))
    then
      throw "Systemd OPENCLAW_STATE_DIR must resolve home-relative stateDir."
    else if
      pkgs.stdenv.hostPlatform.isLinux
      && !(lib.elem "\"OPENCLAW_CONFIG_PATH=/tmp/openclaw state/openclaw.json\"" (
        systemdService.Environment or [ ]
      ))
    then
      throw "Systemd OPENCLAW_CONFIG_PATH must resolve home-relative configPath."
    else if pkgs.stdenv.hostPlatform.isDarwin && ((launchdConfig.WorkingDirectory or "") != "/tmp/openclaw state") then
      throw "launchd WorkingDirectory must resolve home-relative stateDir."
    else if
      pkgs.stdenv.hostPlatform.isDarwin
      && (((launchdConfig.EnvironmentVariables or { }).OPENCLAW_STATE_DIR or null) != "/tmp/openclaw state")
    then
      throw "launchd OPENCLAW_STATE_DIR must resolve home-relative stateDir."
    else if
      pkgs.stdenv.hostPlatform.isDarwin
      && (
        ((launchdConfig.EnvironmentVariables or { }).OPENCLAW_CONFIG_PATH or null)
        != "/tmp/openclaw state/openclaw.json"
      )
    then
      throw "launchd OPENCLAW_CONFIG_PATH must resolve home-relative configPath."
    else
      "ok";

  homeRelativeConfigCheck = homeRelativeConfigCheckFor homeRelativeConfigEval;
  topLevelHomeRelativeConfigCheck = homeRelativeConfigCheckFor (moduleEval {
    stateDir = "~/openclaw state";
  });

  spacedConfigEval = moduleEval {
    instances.default.configPath = "/tmp/openclaw state/config 'file'.json";
  };
  spacedConfigEnvironmentCheck =
    if
      pkgs.stdenv.hostPlatform.isLinux
      && !(lib.elem "\"OPENCLAW_CONFIG_PATH=/tmp/openclaw state/config 'file'.json\""
        spacedConfigEval.config.systemd.user.services.openclaw-gateway.Service.Environment
      )
    then
      throw "Systemd config environment must preserve paths containing spaces and quotes."
    else
      "ok";

  reloadHelperText =
    eval:
    let
      file = eval.config.home.file.".local/bin/openclaw-reload" or { };
    in
    if file ? text then file.text else throw "openclaw-reload helper was not installed.";

  reloadHasLine = text: line: lib.hasInfix line text;

  reloadDefaultEval = moduleEval {
    reloadScript.enable = true;
  };
  reloadDefaultText = reloadHelperText reloadDefaultEval;
  reloadDefaultCheck =
    builtins.deepSeq (requireNoAssertionFailures "reload default targets" reloadDefaultEval)
      (
        if reloadHasLine reloadDefaultText "com.steipete.openclaw.gateway.nix" then
          throw "Default reload helper still hardcodes .nix launchd labels."
        else if pkgs.stdenv.hostPlatform.isDarwin then
          if
            !(reloadHasLine reloadDefaultText "  test)\n    launchd_labels=(com.steipete.openclaw.gateway)")
          then
            throw "Default reload helper test target missing module default launchd label."
          else if
            !(reloadHasLine reloadDefaultText "  prod)\n    launchd_labels=(com.steipete.openclaw.gateway)")
          then
            throw "Default reload helper prod target missing module default launchd label."
          else if
            !(reloadHasLine reloadDefaultText "  both)\n    launchd_labels=(com.steipete.openclaw.gateway)")
          then
            throw "Default reload helper both target missing module default launchd label."
          else
            "ok"
        else if pkgs.stdenv.hostPlatform.isLinux then
          if
            !(reloadHasLine reloadDefaultText "  test)\n    launchd_labels=()\n    systemd_units=(openclaw-gateway)")
          then
            throw "Default reload helper test target missing module default systemd unit."
          else if
            !(reloadHasLine reloadDefaultText "  prod)\n    launchd_labels=()\n    systemd_units=(openclaw-gateway)")
          then
            throw "Default reload helper prod target missing module default systemd unit."
          else if
            !(reloadHasLine reloadDefaultText "  both)\n    launchd_labels=()\n    systemd_units=(openclaw-gateway)")
          then
            throw "Default reload helper both target missing module default systemd unit."
          else
            "ok"
        else
          "ok"
      );

  reloadNamedEval = moduleEval {
    reloadScript.enable = true;
    instances.prod.enable = true;
    instances.test.enable = true;
  };
  reloadNamedText = reloadHelperText reloadNamedEval;
  reloadNamedCheck =
    builtins.deepSeq (requireNoAssertionFailures "reload named targets" reloadNamedEval)
      (
        if reloadHasLine reloadNamedText "com.steipete.openclaw.gateway.nix" then
          throw "Named reload helper still hardcodes .nix launchd labels."
        else if pkgs.stdenv.hostPlatform.isDarwin then
          if
            !(reloadHasLine reloadNamedText "  test)\n    launchd_labels=(com.steipete.openclaw.gateway.test)")
          then
            throw "Named reload helper test target missing test instance launchd label."
          else if
            !(reloadHasLine reloadNamedText "  prod)\n    launchd_labels=(com.steipete.openclaw.gateway.prod)")
          then
            throw "Named reload helper prod target missing prod instance launchd label."
          else if
            !(reloadHasLine reloadNamedText "  both)\n    launchd_labels=(com.steipete.openclaw.gateway.prod com.steipete.openclaw.gateway.test)")
          then
            throw "Named reload helper both target missing configured launchd labels."
          else
            "ok"
        else if pkgs.stdenv.hostPlatform.isLinux then
          if
            !(reloadHasLine reloadNamedText "  test)\n    launchd_labels=()\n    systemd_units=(openclaw-gateway-test)")
          then
            throw "Named reload helper test target missing test instance systemd unit."
          else if
            !(reloadHasLine reloadNamedText "  prod)\n    launchd_labels=()\n    systemd_units=(openclaw-gateway-prod)")
          then
            throw "Named reload helper prod target missing prod instance systemd unit."
          else if
            !(reloadHasLine reloadNamedText "  both)\n    launchd_labels=()\n    systemd_units=(openclaw-gateway-prod openclaw-gateway-test)")
          then
            throw "Named reload helper both target missing configured systemd units."
          else
            "ok"
        else
          "ok"
      );

  reloadCustomDefaultEval = moduleEval {
    reloadScript.enable = true;
    launchd.label = "com.example.openclaw.gateway";
    systemd.unitName = "openclaw-example";
  };
  reloadCustomDefaultText = reloadHelperText reloadCustomDefaultEval;
  reloadCustomDefaultCheck =
    builtins.deepSeq
      (requireNoAssertionFailures "reload custom default targets" reloadCustomDefaultEval)
      (
        if pkgs.stdenv.hostPlatform.isDarwin then
          if
            !(reloadHasLine reloadCustomDefaultText "  test)\n    launchd_labels=(com.example.openclaw.gateway)")
          then
            throw "Custom default reload helper test target did not use programs.openclaw.launchd.label."
          else if
            !(reloadHasLine reloadCustomDefaultText "  prod)\n    launchd_labels=(com.example.openclaw.gateway)")
          then
            throw "Custom default reload helper prod target did not use programs.openclaw.launchd.label."
          else
            "ok"
        else if pkgs.stdenv.hostPlatform.isLinux then
          if
            !(reloadHasLine reloadCustomDefaultText "  test)\n    launchd_labels=()\n    systemd_units=(openclaw-example)")
          then
            throw "Custom default reload helper test target did not use programs.openclaw.systemd.unitName."
          else if
            !(reloadHasLine reloadCustomDefaultText "  prod)\n    launchd_labels=()\n    systemd_units=(openclaw-example)")
          then
            throw "Custom default reload helper prod target did not use programs.openclaw.systemd.unitName."
          else
            "ok"
        else
          "ok"
      );

  sourceOverrideEval = moduleEval {
    instances.dev = {
      enable = true;
      gatewayPath = toString ../..;
      gatewayPnpmDepsHash = lib.fakeHash;
    };
  };
  sourceOverrideConfig = generatedConfig sourceOverrideEval ".openclaw-dev/openclaw.json";
  sourceOverrideCheck = builtins.deepSeq (requireNoAssertionFailures "source override" sourceOverrideEval) (
    if (((sourceOverrideConfig.gateway or { }).mode or null) != "local") then
      throw "Source override instance lost gateway.mode."
    else if pkgs.stdenv.hostPlatform.isLinux then
      let
        services = sourceOverrideEval.config.systemd.user.services;
        execStart = services.openclaw-gateway-dev.Service.ExecStart or "";
      in
      if !(builtins.hasAttr "openclaw-gateway-dev" services) then
        throw "Source override instance missing systemd unit."
      else if !(lib.hasInfix "/bin/openclaw-gateway-dev gateway --port " execStart) then
        throw "Source override instance did not wire the dev gateway wrapper."
      else
        "ok"
    else if pkgs.stdenv.hostPlatform.isDarwin then
      let
        agents = sourceOverrideEval.config.launchd.agents;
        programArgs =
          agents."com.steipete.openclaw.gateway.dev".config.ProgramArguments or [ ];
      in
      if !(builtins.hasAttr "com.steipete.openclaw.gateway.dev" agents) then
        throw "Source override instance missing launchd agent."
      else if !(lib.any (arg: lib.hasSuffix "/bin/openclaw-gateway-dev" arg) programArgs) then
        throw "Source override instance did not wire the dev gateway wrapper."
      else
        "ok"
    else
      "ok"
  );

  customPluginEval = moduleEval {
    customPlugins = [
      { source = alphaPluginSource; }
    ];
  };
  customPluginConfig = generatedConfig customPluginEval ".openclaw/openclaw.json";
  customPluginSkillExtraDirs = ((customPluginConfig.skills or { }).load or { }).extraDirs or [ ];
  customPluginCheck = builtins.deepSeq (requireNoAssertionFailures "customPlugins" customPluginEval) (
    if !(lib.any isPluginSkillPath customPluginSkillExtraDirs) then
      throw "customPlugins did not wire plugin skills into skills.load.extraDirs."
    else
      "ok"
  );

  multiAgentPluginSkillEval = moduleEval {
    customPlugins = [
      { source = alphaPluginSource; }
    ];
    config.agents =
      if usesAgentEntries then
        explicitOwnership // {
          entries = {
            writer.workspace = "/tmp/openclaw-writer-workspace";
            research.workspace = "/tmp/openclaw-research-workspace";
          };
        }
      else
        {
          list = [
            {
              id = "writer";
              workspace = "/tmp/openclaw-writer-workspace";
            }
            {
              id = "research";
              workspace = "/tmp/openclaw-research-workspace";
            }
          ];
        };
  };
  multiAgentPluginSkillConfig = generatedConfig multiAgentPluginSkillEval ".openclaw/openclaw.json";
  multiAgentPluginSkillExtraDirs = (
    ((multiAgentPluginSkillConfig.skills or { }).load or { }).extraDirs or [ ]
  );
  multiAgentWorkspaces = map (agent: agent.workspace) (
    if usesAgentEntries then
      lib.attrValues multiAgentPluginSkillConfig.agents.entries
    else
      multiAgentPluginSkillConfig.agents.list
  );
  multiAgentPluginSkillCheck =
    builtins.deepSeq (requireNoAssertionFailures "multi-agent plugin skills" multiAgentPluginSkillEval)
      (
        if !(lib.elem "/tmp/openclaw-writer-workspace" multiAgentWorkspaces) then
          throw "Multi-agent config lost writer workspace."
        else if !(lib.elem "/tmp/openclaw-research-workspace" multiAgentWorkspaces) then
          throw "Multi-agent config lost research workspace."
        else if !(lib.any isPluginSkillPath multiAgentPluginSkillExtraDirs) then
          throw "Custom plugin skill was not shared through skills.load.extraDirs for separate agent workspaces."
        else
          "ok"
      );

  duplicateSkillEval = moduleEval {
    customPlugins = [
      { source = alphaPluginSource; }
      { source = betaPluginSource; }
    ];
  };
  duplicateSkillCheck =
    requireAssertionFailure "duplicate plugin skills"
      "Duplicate Nix-managed skill names detected: programs.openclaw.instances.default: skill"
      duplicateSkillEval;

  userPluginSkillCollisionEval = moduleEval {
    customPlugins = [
      { source = alphaPluginSource; }
    ];
    skills = [
      {
        name = "skill";
        mode = "inline";
      }
    ];
  };
  userPluginSkillCollisionCheck =
    requireAssertionFailure "user/plugin skill collision"
      "Duplicate Nix-managed skill names detected: programs.openclaw.instances.default: skill"
      userPluginSkillCollisionEval;

  userSkillEval = moduleEval {
    config.skills.load.extraDirs = [ "/tmp/user-skill-root" ];
    skills = [
      {
        name = "inline-skill";
        mode = "inline";
        description = "Inline test skill";
        body = "Use this test skill.";
      }
    ];
  };
  userSkillConfig = generatedConfig userSkillEval ".openclaw/openclaw.json";
  userSkillExtraDirs = ((userSkillConfig.skills or { }).load or { }).extraDirs or [ ];
  generatedUserSkillExtraDirs = lib.filter (path: path != "/tmp/user-skill-root") userSkillExtraDirs;
  userSkillCheck = builtins.deepSeq (requireNoAssertionFailures "user skills" userSkillEval) (
    if !(lib.elem "/tmp/user-skill-root" userSkillExtraDirs) then
      throw "User skills.load.extraDirs entry was not preserved."
    else if !(lib.elem "/tmp/.local/share/nix-openclaw/skills/default/inline-skill" generatedUserSkillExtraDirs) then
      throw "Nix-managed raw skill did not use its per-instance runtime copy."
    else if !(lib.all (lib.hasPrefix "/tmp/.local/share/nix-openclaw/skills/default/") generatedUserSkillExtraDirs) then
      throw "A default plugin skill escaped the instance runtime root."
    else if userSkillExtraDirs != generatedUserSkillExtraDirs ++ [ "/tmp/user-skill-root" ] then
      throw "User skills.load.extraDirs entries should remain after Nix-managed skill dirs."
    else
      "ok"
  );

  namedSkillEval = moduleEval {
    skills = [
      {
        name = "inline-skill";
        mode = "inline";
      }
    ];
    instances = {
      prod = {
        enable = true;
        appDefaults.enable = false;
      };
      test = {
        enable = true;
        appDefaults.enable = false;
      };
    };
  };
  namedSkillConfigs = map (name: generatedConfig namedSkillEval ".openclaw-${name}/openclaw.json") [
    "prod"
    "test"
  ];
  namedSkillCheck = builtins.deepSeq (requireNoAssertionFailures "named instance skills" namedSkillEval) (
    if map (value: lib.filter (lib.hasSuffix "/inline-skill") value.skills.load.extraDirs) namedSkillConfigs != [
      [ "/tmp/.local/share/nix-openclaw/skills/prod/inline-skill" ]
      [ "/tmp/.local/share/nix-openclaw/skills/test/inline-skill" ]
    ] then
      throw "Named instances did not isolate their runtime skill copies."
    else
      "ok"
  );

  caseSkillEval = moduleEval {
    skills = map (name: { inherit name; mode = "inline"; }) [ "Case" "case" ];
  };
  caseSkillConfig = generatedConfig caseSkillEval ".openclaw/openclaw.json";
  caseSkillCheck =
    if lib.length (lib.unique (map lib.toLower caseSkillConfig.skills.load.extraDirs)) != lib.length caseSkillConfig.skills.load.extraDirs then
      throw "Case-distinct skills collide on case-insensitive home filesystems."
    else
      "ok";

  bootstrapFiles = {
    agents = ../tests/workspace/AGENTS.md;
    soul = ../tests/workspace/SOUL.md;
    tools = ../tests/workspace/TOOLS.md;
    identity = ../tests/workspace/IDENTITY.md;
    user = ../tests/workspace/USER.md;
    heartbeat = ../tests/workspace/HEARTBEAT.md;
  };

  workspaceBootstrapEval = moduleEval {
    workspace = {
      bootstrapFiles = bootstrapFiles;
      files."LORE.md" = ../tests/workspace/LORE.md;
    };
  };
  workspaceBootstrapConfig = builtins.fromJSON (
    builtins.unsafeDiscardStringContext
      workspaceBootstrapEval.config.home.file.".openclaw/openclaw.json".text
  );
  workspaceBootstrapCheck =
    builtins.deepSeq (requireNoAssertionFailures "workspace bootstrap files" workspaceBootstrapEval)
      (
        if (((workspaceBootstrapConfig.agents or { }).defaults or { }).skipBootstrap or false) != true then
          throw "workspace.bootstrapFiles did not force agents.defaults.skipBootstrap = true."
        else
          "ok"
      );

  documentsRemovedEval = moduleEval {
    documents = ../tests/workspace;
  };
  documentsRemovedCheck = builtins.deepSeq [
    (requireAssertionFailure "removed documents option" "programs.openclaw.documents was removed"
      documentsRemovedEval
    )
    (requireAssertionFailure "removed documents option extras" "LORE.md" documentsRemovedEval)
    (requireAssertionFailure "removed documents option prompting examples" "PROMPTING-EXAMPLES.md"
      documentsRemovedEval
    )
    (requireAssertionFailure "removed documents option heartbeat"
      "programs.openclaw.workspace.bootstrapFiles.heartbeat"
      documentsRemovedEval
    )
  ] "ok";

  bootstrapSeedConflictEval = moduleEval {
    workspace.bootstrapFiles = bootstrapFiles;
    config.agents.defaults.skipBootstrap = false;
  };
  bootstrapSeedConflictCheck =
    requireAssertionFailure "bootstrap seed conflict" "OpenClaw must not seed bootstrap files"
      bootstrapSeedConflictEval;

  workspaceFileCollisionEval = moduleEval {
    workspace = {
      bootstrapFiles = bootstrapFiles;
      files = {
        "AGENTS.md" = ../tests/workspace/LORE.md;
        "AGENTS.md/foo" = ../tests/workspace/LORE.md;
        "BOOTSTRAP.md/foo" = ../tests/workspace/LORE.md;
        "MEMORY.md/foo" = ../tests/workspace/LORE.md;
      };
    };
  };
  workspaceFileCollisionCheck =
    requireAssertionFailure "workspace file reserved collision"
      "workspace.files cannot manage reserved OpenClaw workspace paths"
      workspaceFileCollisionEval;

  workspaceRuntimeFileCollisionEval = moduleEval {
    workspace.files = {
      "memory" = ../tests/workspace/LORE.md;
      "memory/foo" = ../tests/workspace/LORE.md;
    };
  };
  workspaceRuntimeFileCollisionCheck =
    requireAssertionFailure "workspace file runtime collision"
      "workspace.files cannot manage reserved OpenClaw workspace paths"
      workspaceRuntimeFileCollisionEval;

  invalidWorkspaceFileEval = moduleEval {
    workspace.files = {
      "" = ../tests/workspace/LORE.md;
      "." = ../tests/workspace/LORE.md;
      "../outside.md" = ../tests/workspace/LORE.md;
      "nested/." = ../tests/workspace/LORE.md;
      "nested/./LORE.md" = ../tests/workspace/LORE.md;
      "nested/.." = ../tests/workspace/LORE.md;
      "nested//LORE.md" = ../tests/workspace/LORE.md;
      "nested/" = ../tests/workspace/LORE.md;
    };
  };
  invalidWorkspaceFileCheck =
    requireAssertionFailure "invalid workspace file path"
      "workspace.files keys must be relative paths below the workspace without empty, '.', or '..' path segments"
      invalidWorkspaceFileEval;

  secretProviderEval = moduleEval {
    config.secrets.providers.test-file = {
      source = "file";
      path = "/tmp/openclaw-secrets.json";
      mode = "json";
    };
  };
  secretProviderConfig = generatedConfig secretProviderEval ".openclaw/openclaw.json";
  secretProviderCheck =
    builtins.deepSeq (requireNoAssertionFailures "secrets.providers" secretProviderEval)
      (
        if
          ((((secretProviderConfig.secrets or { }).providers or { }).test-file or { }).source == "file")
        then
          "ok"
        else
          throw "secrets.providers file variant missing from generated config."
      );

  secretRefPassthroughEval = moduleEval {
    config = {
      secrets.providers = {
        aws_test = {
          source = "exec";
          command = "/usr/bin/aws";
          args = [
            "secretsmanager"
            "get-secret-value"
            "--secret-id"
            "openclaw/groq"
          ];
          jsonOnly = false;
        };
        filemain = {
          source = "file";
          path = "/run/agenix/openclaw-secrets.json";
          mode = "json";
        };
      };

      models.providers = {
        groq = {
          baseUrl = "https://api.groq.com/openai/v1";
          api = "openai-completions";
          apiKey = {
            source = "exec";
            provider = "aws_test";
            id = "value";
          };
          models = [
            {
              id = "llama-3.3-70b-versatile";
              name = "Llama 3.3 70B";
            }
          ];
        };
        filebacked = {
          baseUrl = "https://example.invalid/v1";
          api = "openai-completions";
          apiKey = {
            source = "file";
            provider = "filemain";
            id = "/providers/filebacked/apiKey";
          };
          models = [
            {
              id = "test-model";
              name = "Test model";
            }
          ];
        };
      };
    };
  };
  secretRefPassthroughConfig = generatedConfig secretRefPassthroughEval ".openclaw/openclaw.json";
  secretRefGroqApiKey =
    ((secretRefPassthroughConfig.models or { }).providers or { }).groq.apiKey or { };
  secretRefFileApiKey =
    ((secretRefPassthroughConfig.models or { }).providers or { }).filebacked.apiKey or { };
  secretRefPassthroughCheck =
    builtins.deepSeq (requireNoAssertionFailures "SecretRef passthrough" secretRefPassthroughEval)
      (
        if secretRefGroqApiKey.source != "exec" then
          throw "models.providers.groq.apiKey exec SecretRef was not rendered unchanged."
        else if secretRefGroqApiKey.provider != "aws_test" then
          throw "models.providers.groq.apiKey exec SecretRef provider was not rendered unchanged."
        else if secretRefGroqApiKey.id != "value" then
          throw "models.providers.groq.apiKey exec SecretRef id was not rendered unchanged."
        else if secretRefFileApiKey.source != "file" then
          throw "models.providers.filebacked.apiKey file SecretRef was not rendered unchanged."
        else if secretRefFileApiKey.provider != "filemain" then
          throw "models.providers.filebacked.apiKey file SecretRef provider was not rendered unchanged."
        else if secretRefFileApiKey.id != "/providers/filebacked/apiKey" then
          throw "models.providers.filebacked.apiKey file SecretRef id was not rendered unchanged."
        else
          "ok"
      );

  inherit (import ../lib/openclaw-config-capabilities.nix { inherit lib; }) supportsQmdBackend;
  retiredQmdConfigs = [
    { memory.backend = "qmd"; }
    { memory.qmd = { }; }
    { memory.search.qmd = { }; }
  ];
  qmdControlConfig = {
    gateway.mode = "local";
    memory.citations = "off";
  };
  qmdControlEval = moduleEval {
    config = qmdControlConfig;
  };
  qmdControlCheck = builtins.deepSeq [
    (requireNoAssertionFailures "QMD valid config control" qmdControlEval)
    qmdControlEval.config.home.activation
  ] (
    if (generatedConfig qmdControlEval ".openclaw/openclaw.json").memory != qmdControlConfig.memory then
      throw "QMD valid config control changed authored memory config."
    else if lib.any packageHasQmd qmdControlEval.config.home.packages then
      throw "Valid memory config without QMD opt-in added an internal QMD wrapper."
    else
      "ok"
  );
  qmdPrewarmEval = moduleEval {
    qmd.prewarmModels.enable = true;
  };
  qmdPrewarmActivation = builtins.toJSON qmdPrewarmEval.config.home.activation.openclawQmdPrewarm;
  qmdPrewarmCheck = builtins.deepSeq (requireNoAssertionFailures "qmd.prewarmModels" qmdPrewarmEval) (
    if
      lib.hasInfix "OPENCLAW_QMD_BIN=" qmdPrewarmActivation
      && lib.hasInfix "openclaw-qmd-prewarm.sh" qmdPrewarmActivation
    then
      "ok"
    else
      throw "qmd.prewarmModels did not wire QMD model-cache prewarm activation."
  );

  qmdMemoryEval = moduleEval {
    config.memory.backend = "qmd";
  };
  qmdMemoryCheck =
    if supportsQmdBackend then
      builtins.deepSeq (requireNoAssertionFailures "memory.backend qmd" qmdMemoryEval) (
        if (generatedConfig qmdMemoryEval ".openclaw/openclaw.json").memory.backend != "qmd" then
          throw "Legacy memory.backend = qmd was not preserved."
        else if !(lib.any packageHasQmd qmdMemoryEval.config.home.packages) then
          throw "memory.backend = qmd did not add QMD to the internal OpenClaw runtime."
        else
          "ok"
      )
    else
      map (
        config:
        requireEvalFailure "retired QMD generated config ${builtins.toJSON config}"
          (moduleEval { inherit config; }).config.home.file
      ) retiredQmdConfigs;
  qmdMemoryPackages =
    if supportsQmdBackend then lib.filter packageHasQmd qmdMemoryEval.config.home.packages else [ ];
  qmdMemoryPackage = if qmdMemoryPackages == [ ] then null else builtins.head qmdMemoryPackages;

  nixosQmdEval =
    gatewayConfig:
    lib.evalModules {
      modules = [
        {
          options = {
            assertions = lib.mkOption {
              type = lib.types.listOf lib.types.attrs;
              default = [ ];
            };
            users = lib.mkOption { type = lib.types.attrs; default = { }; };
            systemd = lib.mkOption { type = lib.types.attrs; default = { }; };
            environment = lib.mkOption { type = lib.types.attrs; default = { }; };
          };
        }
        ../modules/nixos/openclaw-gateway.nix
        {
          services.openclaw-gateway = {
            enable = true;
            createUser = false;
          } // gatewayConfig;
        }
      ];
      specialArgs = { inherit pkgs; };
    };
  nixosQmdChecks = map (
    config:
    let
      evaluated = nixosQmdEval { inherit config; };
      rendered = builtins.fromJSON evaluated.config.environment.etc."openclaw/openclaw.json".source.text;
      servicePath = evaluated.config.systemd.services.openclaw-gateway.path;
      expectedQmd = supportsQmdBackend && (config.memory.backend or null) == "qmd";
    in
    builtins.deepSeq (
      if supportsQmdBackend || config == qmdControlConfig then
        requireNoAssertionFailures "NixOS QMD config" evaluated
      else
        requireAssertionFailure "NixOS retired QMD config" "schema retired the QMD backend" evaluated
    ) (
      if rendered != config then
        throw "NixOS QMD handling changed authored config."
      else if lib.elem openclawLib.qmdPackage servicePath != expectedQmd then
        throw "NixOS automatic QMD service PATH disagrees with schema capability and opt-in."
      else
        "ok"
    )
  ) ([ qmdControlConfig ] ++ retiredQmdConfigs);
  nixosQmdExplicitEval = nixosQmdEval {
    configFile = ../tests/workspace/LORE.md;
    servicePath = [ openclawLib.qmdPackage ];
  };
  nixosQmdExplicitCheck =
    builtins.deepSeq (requireNoAssertionFailures "NixOS explicit QMD tooling" nixosQmdExplicitEval) (
      if nixosQmdExplicitEval.config.environment.etc."openclaw/openclaw.json".source != ../tests/workspace/LORE.md then
        throw "NixOS QMD handling must leave configFile opaque and unchanged."
      else if !(lib.elem openclawLib.qmdPackage nixosQmdExplicitEval.config.systemd.services.openclaw-gateway.path) then
        throw "NixOS QMD handling removed an explicit servicePath package."
      else
        "ok"
    );

  runtimeProfileEval = moduleEval {
    runtimePackages = [ pkgs.jq ];
    environment.OPENCLAW_TEST_SECRET = "/tmp/openclaw-secret";
  };
  runtimeProfileActivation = builtins.toJSON runtimeProfileEval.config.home.activation.openclawCodexRuntimeProfiles;
  runtimeProfileCheck =
    builtins.deepSeq (requireNoAssertionFailures "runtime profile" runtimeProfileEval)
      (
        if lib.hasInfix "openclaw-link-codex-runtime-profiles.sh" runtimeProfileActivation then
          "ok"
        else
          throw "runtimePackages did not wire the Codex runtime profile activation."
      );

  customRuntimePluginRootEval = moduleEval {
    customPlugins = [
      { source = runtimePluginRootSource; }
    ];
  };
  customRuntimePluginRootCheck = requireEvalFailure "customPlugins rejects OpenClaw runtime plugin roots" customRuntimePluginRootEval.config.home.file;

  runtimePluginEval = moduleEval {
    runtimePlugins = [ "slack" ];
    config.plugins.allow = [ "memory-core" ];
  };
  runtimePluginConfig = generatedConfig runtimePluginEval ".openclaw/openclaw.json";
  runtimePluginLoadPaths = ((runtimePluginConfig.plugins or { }).load or { }).paths or [ ];
  runtimePluginEntry = ((runtimePluginConfig.plugins or { }).entries or { }).slack or { };
  runtimePluginAllow = ((runtimePluginConfig.plugins or { }).allow or [ ]);
  runtimePluginLaunchdEnv =
    if pkgs.stdenv.hostPlatform.isDarwin then
      runtimePluginEval.config.launchd.agents."com.steipete.openclaw.gateway".config.EnvironmentVariables
    else
      { };
  runtimePluginSystemdEnv =
    if pkgs.stdenv.hostPlatform.isLinux then
      runtimePluginEval.config.systemd.user.services.openclaw-gateway.Service.Environment
    else
      [ ];
  runtimePluginCheck =
    builtins.deepSeq (requireNoAssertionFailures "runtimePlugins" runtimePluginEval)
      (
        if !(lib.any (path: lib.hasInfix "openclaw-runtime-plugin-slack" path) runtimePluginLoadPaths) then
          throw "runtimePlugins did not add Slack to plugins.load.paths."
        else if (runtimePluginEntry.enabled or false) != true then
          throw "runtimePlugins did not enable the Slack plugin entry."
        else if
          runtimePluginAllow != [
            "memory-core"
            "slack"
          ]
        then
          throw "runtimePlugins did not merge Slack into an existing plugins.allow list."
        else if ((runtimePluginConfig.plugins or { }) ? installs) then
          throw "runtimePlugins wrote plugins.installs into generated config."
        else if
          pkgs.stdenv.hostPlatform.isDarwin
          && ((runtimePluginLaunchdEnv.OPENCLAW_DISABLE_PERSISTED_PLUGIN_REGISTRY or null) != "1")
        then
          throw "runtimePlugins did not disable persisted plugin registry reads for launchd."
        else if
          pkgs.stdenv.hostPlatform.isLinux
          && !(lib.elem "OPENCLAW_DISABLE_PERSISTED_PLUGIN_REGISTRY=1" runtimePluginSystemdEnv)
        then
          throw "runtimePlugins did not disable persisted plugin registry reads for systemd."
        else
          "ok"
      );

  runtimePluginCatalogGeneratedEval = moduleEval {
    runtimePlugins = [
      "amazon-bedrock"
      "discord"
    ];
  };
  runtimePluginCatalogGeneratedConfig = generatedConfig runtimePluginCatalogGeneratedEval ".openclaw/openclaw.json";
  runtimePluginCatalogGeneratedLoadPaths =
    ((runtimePluginCatalogGeneratedConfig.plugins or { }).load or { }).paths or [ ];
  runtimePluginCatalogGeneratedEntries = (
    (runtimePluginCatalogGeneratedConfig.plugins or { }).entries or { }
  );
  runtimePluginCatalogGeneratedCheck =
    builtins.deepSeq
      (requireNoAssertionFailures "runtimePlugins generated catalog ids" runtimePluginCatalogGeneratedEval)
      (
        if
          !(lib.any (
            path: lib.hasInfix "openclaw-runtime-plugin-amazon-bedrock" path
          ) runtimePluginCatalogGeneratedLoadPaths)
        then
          throw "runtimePlugins did not accept generated provider plugin ids."
        else if
          !(lib.any (
            path: lib.hasInfix "openclaw-runtime-plugin-discord" path
          ) runtimePluginCatalogGeneratedLoadPaths)
        then
          throw "runtimePlugins did not accept generated channel plugin ids."
        else if ((runtimePluginCatalogGeneratedEntries.amazon-bedrock or { }).enabled or false) != true then
          throw "runtimePlugins did not enable generated provider plugin entry."
        else if ((runtimePluginCatalogGeneratedEntries.discord or { }).enabled or false) != true then
          throw "runtimePlugins did not enable generated channel plugin entry."
        else
          "ok"
      );

  runtimePluginInstanceEval = moduleEval {
    runtimePlugins = [ "slack" ];
    instances.one.runtimePlugins = [ ];
    instances.two.runtimePlugins = [
      "discord"
      "diagnostics-prometheus"
    ];
  };
  runtimePluginInstanceOneConfig = generatedConfig runtimePluginInstanceEval ".openclaw-one/openclaw.json";
  runtimePluginInstanceTwoConfig = generatedConfig runtimePluginInstanceEval ".openclaw-two/openclaw.json";
  runtimePluginInstanceOneLoadPaths =
    ((runtimePluginInstanceOneConfig.plugins or { }).load or { }).paths or [ ];
  runtimePluginInstanceTwoLoadPaths =
    ((runtimePluginInstanceTwoConfig.plugins or { }).load or { }).paths or [ ];
  runtimePluginInstanceCheck =
    builtins.deepSeq (requireNoAssertionFailures "runtimePlugins instances" runtimePluginInstanceEval)
      (
        if runtimePluginInstanceOneLoadPaths != [ ] then
          throw "Instance runtimePlugins = [] did not override top-level runtimePlugins."
        else if
          !(lib.any (
            path: lib.hasInfix "openclaw-runtime-plugin-discord" path
          ) runtimePluginInstanceTwoLoadPaths)
        then
          throw "Instance runtimePlugins did not render its selected plugin."
        else if
          !(lib.any (
            path: lib.hasInfix "openclaw-runtime-plugin-diagnostics-prometheus" path
          ) runtimePluginInstanceTwoLoadPaths)
        then
          throw "Instance runtimePlugins did not support hyphenated plugin ids."
        else
          "ok"
      );

  runtimePluginDuplicateEval = moduleEval {
    runtimePlugins = [
      "slack"
      "slack"
    ];
  };
  runtimePluginDuplicateCheck =
    requireAssertionFailure "duplicate runtimePlugins"
      "runtimePlugins/runtimePluginSources contains duplicate ids: slack"
      runtimePluginDuplicateEval;

  runtimePluginUnsupportedEval = moduleEval {
    runtimePlugins = [ "not-a-real-openclaw-plugin" ];
  };
  runtimePluginUnsupportedCheck =
    requireAssertionFailure "unsupported runtimePlugins"
      "Maintainers can inspect unsupported-plugin diagnostics in nix/generated/openclaw-runtime-plugins/report.json"
      runtimePluginUnsupportedEval;

  runtimePluginRawLoadPathEval = moduleEval {
    runtimePlugins = [ "slack" ];
    config.plugins.load.paths = [ "/tmp/user-openclaw-runtime-plugin" ];
  };
  runtimePluginRawLoadPathCheck =
    requireAssertionFailure "runtimePlugins raw load path"
      "runtimePlugins/runtimePluginSources cannot be mixed with raw programs.openclaw.config.plugins.load.paths"
      runtimePluginRawLoadPathEval;

  runtimePluginInstallRecordEval = moduleEval {
    runtimePlugins = [ "slack" ];
    config.plugins.installs.slack = {
      source = "npm";
      spec = "@openclaw/slack";
      installPath = "/tmp/mutable-openclaw-slack";
    };
  };
  runtimePluginInstallRecordCheck = requireEvalFailure "runtimePlugins install records are schema-rejected" runtimePluginInstallRecordEval.config.assertions;

  runtimePluginDisabledEval = moduleEval {
    runtimePlugins = [ "slack" ];
    config.plugins.entries.slack.enabled = false;
  };
  runtimePluginDisabledCheck =
    requireAssertionFailure "runtimePlugins disabled entry"
      "runtimePlugins/runtimePluginSources selected ids disabled in config.plugins.entries: slack"
      runtimePluginDisabledEval;

  runtimePluginDeniedEval = moduleEval {
    runtimePlugins = [ "slack" ];
    config.plugins.deny = [ "slack" ];
  };
  runtimePluginDeniedCheck =
    requireAssertionFailure "runtimePlugins denied entry"
      "runtimePlugins/runtimePluginSources selected ids denied in config.plugins.deny: slack"
      runtimePluginDeniedEval;

  runtimePluginSourceEval = moduleEval {
    runtimePluginSources = [
      {
        id = "diagnostics-prometheus";
        spec = "npm:@openclaw/diagnostics-prometheus@2026.6.1";
        hash = "sha256-nXDuWe72bgnuinoZFZDPwKowYml/5lturHD+sKti4AA=";
      }
    ];
    config.plugins.allow = [ "memory-core" ];
  };
  runtimePluginSourceConfig = generatedConfig runtimePluginSourceEval ".openclaw/openclaw.json";
  runtimePluginSourceLoadPaths =
    ((runtimePluginSourceConfig.plugins or { }).load or { }).paths or [ ];
  runtimePluginSourceEntry =
    ((runtimePluginSourceConfig.plugins or { }).entries or { }).diagnostics-prometheus or { };
  runtimePluginSourceAllow = ((runtimePluginSourceConfig.plugins or { }).allow or [ ]);
  runtimePluginSourceCheck =
    builtins.deepSeq
      (requireNoAssertionFailures "runtimePluginSources npm source" runtimePluginSourceEval)
      (
        if
          !(lib.any (
            path: lib.hasInfix "openclaw-runtime-plugin-diagnostics-prometheus" path
          ) runtimePluginSourceLoadPaths)
        then
          throw "runtimePluginSources did not add the npm source plugin to plugins.load.paths."
        else if (runtimePluginSourceEntry.enabled or false) != true then
          throw "runtimePluginSources did not enable the source plugin entry."
        else if
          runtimePluginSourceAllow != [
            "memory-core"
            "diagnostics-prometheus"
          ]
        then
          throw "runtimePluginSources did not merge source plugin id into an existing plugins.allow list."
        else
          "ok"
      );

  runtimePluginSourceDuplicateEval = moduleEval {
    runtimePlugins = [ "diagnostics-prometheus" ];
    runtimePluginSources = [
      {
        id = "diagnostics-prometheus";
        spec = "npm:@openclaw/diagnostics-prometheus@2026.6.1";
      }
    ];
  };
  runtimePluginSourceDuplicateCheck =
    requireAssertionFailure "duplicate runtimePluginSources"
      "runtimePlugins/runtimePluginSources contains duplicate ids: diagnostics-prometheus"
      runtimePluginSourceDuplicateEval;

  runtimePluginSourceAmbiguousEval = moduleEval {
    runtimePluginSources = [
      {
        id = "bad-source";
      }
    ];
  };
  runtimePluginSourceAmbiguousCheck =
    requireAssertionFailure "runtimePluginSources ambiguous source"
      "runtimePluginSources entries must set exactly one of spec or url"
      runtimePluginSourceAmbiguousEval;

  runtimePluginSourceInvalidSpecEval = moduleEval {
    runtimePluginSources = [
      {
        id = "bad-source";
        spec = "git:github.com/acme/openclaw-plugin@v1.0.0";
      }
    ];
  };
  runtimePluginSourceInvalidSpecCheck =
    requireAssertionFailure "runtimePluginSources invalid spec"
      "runtimePluginSources spec must start with npm: or clawhub:"
      runtimePluginSourceInvalidSpecEval;

  runtimePluginSourceInvalidUrlEval = moduleEval {
    runtimePluginSources = [
      {
        id = "bad-url";
        url = "http://example.invalid/plugin.tgz";
      }
    ];
  };
  runtimePluginSourceInvalidUrlCheck =
    requireAssertionFailure "runtimePluginSources invalid url"
      "runtimePluginSources url must start with https://: bad-url"
      runtimePluginSourceInvalidUrlEval;

  runtimePluginSourceRawLoadPathEval = moduleEval {
    runtimePluginSources = [
      {
        id = "diagnostics-prometheus";
        spec = "npm:@openclaw/diagnostics-prometheus@2026.6.1";
      }
    ];
    config.plugins.load.paths = [ "/tmp/user-openclaw-runtime-plugin" ];
  };
  runtimePluginSourceRawLoadPathCheck =
    requireAssertionFailure "runtimePluginSources raw load path"
      "runtimePlugins/runtimePluginSources cannot be mixed with raw programs.openclaw.config.plugins.load.paths"
      runtimePluginSourceRawLoadPathEval;

  npmRuntimePluginEval = moduleEval {
    customPlugins = [
      {
        source = "npm:@tencent-weixin/openclaw-weixin@2.4.2";
        id = "openclaw-weixin";
        hash = lib.fakeHash;
      }
    ];
  };
  npmRuntimePluginCheck = requireEvalFailure "npm customPlugins bridge" (
    npmRuntimePluginEval.config.home.file.".openclaw/openclaw.json".text
  );

  checkKey = builtins.deepSeq (
    [
      defaultCheck
      (implicitRosterCheck "default instance" defaultConfig)
      (implicitRosterCheck "bootstrap defaults" workspaceBootstrapConfig)
      (map (implicitRosterCheck "named instance") namedSkillConfigs)
      unpinnedRosterCheck
      emptyRosterChecks
      explicitWorkspaceCheck
      mergedRosterCheck
      authoredRosterChecks
      canonicalAgentIdChecks
      invalidRosterChecks
      homeRelativeConfigCheck
      topLevelHomeRelativeConfigCheck
      spacedConfigEnvironmentCheck
      reloadDefaultCheck
      reloadNamedCheck
      reloadCustomDefaultCheck
      userSkillCheck
      namedSkillCheck
      caseSkillCheck
      workspaceBootstrapCheck
      documentsRemovedCheck
      bootstrapSeedConflictCheck
      workspaceFileCollisionCheck
      workspaceRuntimeFileCollisionCheck
      invalidWorkspaceFileCheck
      secretProviderCheck
      secretRefPassthroughCheck
    ]
    ++ lib.optionals includePluginChecks [
      customPluginCheck
      multiAgentPluginSkillCheck
      duplicateSkillCheck
      userPluginSkillCollisionCheck
    ]
    ++ lib.optionals includeQmdChecks [
      qmdControlCheck
      qmdPrewarmCheck
      qmdMemoryCheck
      nixosQmdChecks
      nixosQmdExplicitCheck
    ]
    ++ lib.optionals includeSourceOverrideChecks [
      sourceOverrideCheck
    ]
    ++ [
      runtimeProfileCheck
    ]
    ++ lib.optionals includePluginChecks [
      customRuntimePluginRootCheck
      runtimePluginCheck
      runtimePluginCatalogGeneratedCheck
      runtimePluginInstanceCheck
      runtimePluginDuplicateCheck
      runtimePluginUnsupportedCheck
      runtimePluginRawLoadPathCheck
      runtimePluginInstallRecordCheck
      runtimePluginDisabledCheck
      runtimePluginDeniedCheck
      runtimePluginSourceCheck
      runtimePluginSourceDuplicateCheck
      runtimePluginSourceAmbiguousCheck
      runtimePluginSourceInvalidSpecCheck
      runtimePluginSourceInvalidUrlCheck
      runtimePluginSourceRawLoadPathCheck
      npmRuntimePluginCheck
    ]
  ) "ok";

in
stdenv.mkDerivation {
  pname =
    if includePluginChecks then
      "openclaw-plugin-instance"
    else if includeQmdChecks then
      "openclaw-qmd-instance"
    else if includeSourceOverrideChecks then
      "openclaw-source-override-instance"
    else
      "openclaw-default-instance";
  version = "1";
  dontUnpack = true;
  # Evaluation alone missed installPhase regressions in helper scripts.
  nativeBuildInputs =
    lib.optionals includePluginChecks [
      nodejs_22
    ]
    ++ lib.optional (includeQmdChecks && qmdMemoryPackage != null) qmdMemoryPackage;
  env = {
    OPENCLAW_DEFAULT_INSTANCE = checkKey;
  };
  installPhase =
    lib.optionalString includePluginChecks "${nodejs_22}/bin/node ${../scripts/check-openclaw-runtime-plugin-installer.mjs} ${../scripts/openclaw-runtime-plugin-install.mjs} && "
    + "${../scripts/empty-install.sh}";
}
