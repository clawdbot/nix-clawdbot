{
  config,
  lib,
  pkgs,
}:

let
  cfg = config.programs.openclaw;
  homeDir = config.home.homeDirectory;
  autoExcludeTools = lib.optionals config.programs.git.enable [ "git" ];
  effectiveExcludeTools = lib.unique (cfg.excludeTools ++ autoExcludeTools);
  toolOverrides = {
    toolNamesOverride = cfg.toolNames;
    excludeToolNames = effectiveExcludeTools;
  };
  toolOverridesEnabled = cfg.toolNames != null || effectiveExcludeTools != [ ];
  overlayPackage = pkgs.openclaw or null;
  toolSets = import ../../../tools/extended.nix ({ inherit pkgs; } // toolOverrides);
  defaultPackage =
    if toolOverridesEnabled && overlayPackage != null && cfg.package == overlayPackage then
      (pkgs.openclawPackages.withTools toolOverrides).openclaw
    else
      cfg.package;
  appPackage = if cfg.appPackage != null then cfg.appPackage else defaultPackage;
  qmdPackage = pkgs.openclawPackages.qmd or null;
  generatedConfigOptions = import ../../../generated/openclaw-config-options.nix { lib = lib; };
  agentOptions = generatedConfigOptions.agents.type.getSubOptions [ ];
  usesAgentEntries = agentOptions ? entries;
  hasAgentOwnership = agentOptions ? ownership;
  agentIds =
    configuration:
    let
      agents = configuration.agents or { };
    in
    if usesAgentEntries then
      let
        keys = lib.attrNames (agents.entries or { });
        normalized = map lib.toLower keys;
      in
      # Generated options omit upstream key patterns; validate before forming paths.
      if lib.any (key: builtins.match "[a-zA-Z0-9_][a-zA-Z0-9_-]{0,63}" key == null) keys then
        throw "OpenClaw agents.entries keys must match the upstream agent ID alphabet and 1-64 character limit."
      else if lib.length (lib.unique normalized) != lib.length normalized then
        throw "OpenClaw agents.entries keys must be unique after lowercase normalization."
      else
        normalized
    else
      let
        configured = lib.filter (id: id != null) (map (agent: agent.id or null) (agents.list or [ ]));
      in
      lib.unique ([ "main" ] ++ configured);
  pluginCatalog = import ./plugin-catalog.nix;

  bundledPluginSources =
    let
      openclawToolsRev = "25fcec492e22996af9ee87106338a448bc6893a2";
      openclawToolsNarHash = "sha256-FF75z2jVZJjymkLtt7e7rKBLQZtC1LBEoM8qDhQPLQ8=";
      openclawTools =
        tool:
        "github:openclaw/nix-openclaw-tools?dir=tools/${tool}&rev=${openclawToolsRev}&narHash=${openclawToolsNarHash}";
    in
    lib.mapAttrs (_name: plugin: plugin.source or (openclawTools plugin.tool)) pluginCatalog;

  bundledPlugins = lib.filter (p: p != null) (
    lib.mapAttrsToList (
      name: source:
      let
        pluginCfg = cfg.bundledPlugins.${name};
      in
      if (pluginCfg.enable or false) then
        {
          inherit source;
          config = pluginCfg.config or { };
        }
      else
        null
    ) bundledPluginSources
  );

  effectivePlugins = cfg.customPlugins ++ bundledPlugins;

  resolvePath = p: if lib.hasPrefix "~/" p then "${homeDir}/${lib.removePrefix "~/" p}" else p;

  toRelative = p: if lib.hasPrefix "${homeDir}/" p then lib.removePrefix "${homeDir}/" p else p;

in
{
  inherit
    cfg
    homeDir
    toolOverrides
    toolOverridesEnabled
    toolSets
    defaultPackage
    appPackage
    qmdPackage
    generatedConfigOptions
    usesAgentEntries
    hasAgentOwnership
    agentIds
    bundledPluginSources
    bundledPlugins
    effectivePlugins
    resolvePath
    toRelative
    ;
}
