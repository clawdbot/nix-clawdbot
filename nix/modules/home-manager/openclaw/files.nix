{
  lib,
  pkgs,
  openclawLib,
  enabledInstances,
  plugins,
}:

let
  cfg = openclawLib.cfg;
  resolvePath = openclawLib.resolvePath;
  toolSets = openclawLib.toolSets;
  bootstrapFiles = cfg.workspace.bootstrapFiles;
  bootstrapFilesEnabled = bootstrapFiles != null;
  extraWorkspaceFiles = cfg.workspace.files or { };
  instanceWorkspaceDirs = map (inst: resolvePath inst.workspaceDir) (lib.attrValues enabledInstances);

  bootstrapFileEntries =
    if bootstrapFilesEnabled then
      [
        {
          optionName = "agents";
          targetName = "AGENTS.md";
          source = bootstrapFiles.agents;
        }
        {
          optionName = "soul";
          targetName = "SOUL.md";
          source = bootstrapFiles.soul;
        }
        {
          optionName = "tools";
          targetName = "TOOLS.md";
          source = bootstrapFiles.tools;
        }
        {
          optionName = "identity";
          targetName = "IDENTITY.md";
          source = bootstrapFiles.identity;
        }
        {
          optionName = "user";
          targetName = "USER.md";
          source = bootstrapFiles.user;
        }
      ]
      ++ lib.optional (bootstrapFiles.heartbeat != null) {
        optionName = "heartbeat";
        targetName = "HEARTBEAT.md";
        source = bootstrapFiles.heartbeat;
      }
    else
      [ ];

  upstreamBootstrapTargetNames = [
    "AGENTS.md"
    "SOUL.md"
    "TOOLS.md"
    "IDENTITY.md"
    "USER.md"
    "HEARTBEAT.md"
    "BOOTSTRAP.md"
    "MEMORY.md"
  ];

  reservedWorkspaceTargetNames = upstreamBootstrapTargetNames ++ [
    "memory"
  ];

  oldDocumentDirectoryEntries =
    if cfg.documents != null && builtins.pathExists cfg.documents then
      builtins.readDir cfg.documents
    else
      { };

  oldDocumentFileNames = lib.attrNames (
    lib.filterAttrs (_: kind: kind == "regular" || kind == "symlink") oldDocumentDirectoryEntries
  );

  oldDocumentExtraFileNames = lib.filter (
    name: !(lib.elem name upstreamBootstrapTargetNames)
  ) oldDocumentFileNames;

  oldDocumentExtrasHint =
    if oldDocumentExtraFileNames == [ ] then
      " If the old directory contained files such as LORE.md or PROMPTING-EXAMPLES.md, declare each one under programs.openclaw.workspace.files."
    else
      " Move old non-bootstrap files into programs.openclaw.workspace.files to keep them Nix-managed: ${lib.concatStringsSep ", " oldDocumentExtraFileNames}.";

  oldDocumentHeartbeatHint =
    if lib.elem "HEARTBEAT.md" oldDocumentFileNames then
      " Set programs.openclaw.workspace.bootstrapFiles.heartbeat if HEARTBEAT.md should remain Nix-managed."
    else
      " HEARTBEAT.md is managed only if programs.openclaw.workspace.bootstrapFiles.heartbeat is set.";

  validWorkspaceFileName =
    name:
    name != ""
    && name != "."
    && !(lib.hasPrefix "/" name)
    && !(lib.hasPrefix "./" name)
    && !(lib.hasPrefix "../" name)
    && !(lib.hasInfix "/../" name)
    && !(lib.hasSuffix "/" name)
    && !(lib.hasSuffix "/.." name)
    && !(lib.hasInfix "\t" name)
    && !(lib.hasInfix "\n" name)
    && name != ".."
    && lib.all (segment: segment != "" && segment != "." && segment != "..") (
      lib.splitString "/" name
    );

  invalidWorkspaceFileNames = lib.filter (name: !(validWorkspaceFileName name)) (
    lib.attrNames extraWorkspaceFiles
  );

  reservedWorkspacePath =
    name:
    lib.any (target: name == target || lib.hasPrefix "${target}/" name) reservedWorkspaceTargetNames;

  reservedWorkspacePathCollisions = lib.filter reservedWorkspacePath (
    lib.attrNames extraWorkspaceFiles
  );

  workspaceAssertions = [
    {
      assertion = cfg.documents == null;
      message =
        "programs.openclaw.documents was removed. Use programs.openclaw.workspace.bootstrapFiles = { agents = ./AGENTS.md; soul = ./SOUL.md; tools = ./TOOLS.md; identity = ./IDENTITY.md; user = ./USER.md; }; and programs.openclaw.workspace.files for non-bootstrap workspace files."
        + oldDocumentExtrasHint
        + " "
        + oldDocumentHeartbeatHint;
    }
    {
      assertion = invalidWorkspaceFileNames == [ ];
      message = "programs.openclaw.workspace.files keys must be relative paths below the workspace without empty, '.', or '..' path segments, tabs, newlines, or trailing slash: ${lib.concatStringsSep ", " invalidWorkspaceFileNames}";
    }
    {
      assertion = reservedWorkspacePathCollisions == [ ];
      message = "programs.openclaw.workspace.files cannot manage reserved OpenClaw workspace paths. Use programs.openclaw.workspace.bootstrapFiles for declarative bootstrap files, and leave BOOTSTRAP.md, MEMORY.md, and memory/ runtime-owned: ${lib.concatStringsSep ", " reservedWorkspacePathCollisions}";
    }
  ]
  ++ lib.optionals bootstrapFilesEnabled (
    map (entry: {
      assertion = builtins.pathExists entry.source;
      message = "programs.openclaw.workspace.bootstrapFiles.${entry.optionName} must point to an existing file.";
    }) bootstrapFileEntries
  );

  toolsReport =
    if bootstrapFilesEnabled then
      let
        renderPkgName = pkg: if pkg ? pname then pkg.pname else lib.getName pkg;
        renderPkgCommand =
          pkg:
          let
            pkgName = renderPkgName pkg;
            commandName = pkg.meta.mainProgram or pkgName;
          in
          if commandName == pkgName then commandName else "${commandName} (${pkgName})";
        toolPackages = lib.filter (p: p != null) (toolSets.tools or [ ]);
        renderPlugin =
          plugin:
          let
            pkgNames = map renderPkgCommand (lib.filter (p: p != null) plugin.packages);
            pkgSuffix = if pkgNames == [ ] then "" else " — " + (lib.concatStringsSep ", " pkgNames);
          in
          "- " + plugin.name + pkgSuffix + " (" + plugin.source + ")";
        renderPkgList =
          packages:
          let
            actualPackages = lib.filter (p: p != null) packages;
          in
          if actualPackages == [ ] then
            [ "- (none)" ]
          else
            map (pkg: "- " + renderPkgCommand pkg) actualPackages;
        pluginLinesFor =
          instName: inst:
          let
            pluginsForInstance = plugins.resolvedPluginsByInstance.${instName} or [ ];
            pluginLines =
              if pluginsForInstance == [ ] then [ "- (none)" ] else map renderPlugin pluginsForInstance;
            instanceConfig = lib.recursiveUpdate (cfg.config or { }) (inst.config or { });
            qmdEnabled = (((instanceConfig.memory or { }).backend or null) == "qmd");
            runtimePackages = lib.unique (
              (lib.optional (qmdEnabled && openclawLib.qmdPackage != null) openclawLib.qmdPackage)
              ++ (cfg.runtimePackages or [ ])
              ++ (inst.runtimePackages or [ ])
            );
          in
          [
            ""
            "### Instance: ${instName}"
          ]
          ++ [
            ""
            "Plugins:"
          ]
          ++ pluginLines
          ++ [
            ""
            "Runtime packages:"
          ]
          ++ renderPkgList runtimePackages;
        reportLines = [
          "<!-- BEGIN NIX-REPORT -->"
          ""
          "## Nix-managed tools"
          ""
          "### Built-in toolchain"
        ]
        ++ (
          if toolPackages == [ ] then [ "- (none)" ] else map (pkg: "- " + renderPkgCommand pkg) toolPackages
        )
        ++ [
          ""
          "## Nix-managed plugin report"
          ""
          "Plugins enabled per instance (last-wins on name collisions):"
        ]
        ++ lib.concatLists (lib.mapAttrsToList pluginLinesFor enabledInstances)
        ++ [
          ""
          "Tools: batteries-included toolchain + runtime packages + plugin-provided CLIs."
          ""
          "<!-- END NIX-REPORT -->"
        ];
        reportText = lib.concatStringsSep "\n" reportLines;
      in
      pkgs.writeText "openclaw-tools-report.md" reportText
    else
      null;

  toolsWithReport =
    if bootstrapFilesEnabled then
      pkgs.runCommand "openclaw-tools-with-report.md" { } ''
        cat ${bootstrapFiles.tools} > $out
        echo "" >> $out
        cat ${toolsReport} >> $out
      ''
    else
      null;

  bootstrapEntries =
    if bootstrapFilesEnabled then
      let
        mkBootstrapFiles =
          dir:
          map (entry: {
            source = if entry.targetName == "TOOLS.md" then toolsWithReport else entry.source;
            target = dir + "/${entry.targetName}";
          }) bootstrapFileEntries;
      in
      lib.flatten (map mkBootstrapFiles instanceWorkspaceDirs)
    else
      [ ];

  workspaceFileEntries =
    let
      entriesForDir =
        dir:
        lib.mapAttrsToList (name: source: {
          inherit source;
          target = dir + "/${name}";
        }) extraWorkspaceFiles;
    in
    lib.flatten (map entriesForDir instanceWorkspaceDirs);

  materializedEntries = bootstrapEntries ++ workspaceFileEntries;
  workspaceRootsManifest = pkgs.writeText "openclaw-workspace-roots" (
    (lib.concatStringsSep "\n" (lib.unique instanceWorkspaceDirs)) + "\n"
  );
  materializedManifest =
    let
      renderEntry = entry: "${entry.source}\t${entry.target}";
    in
    pkgs.writeText "openclaw-workspace-files.tsv" (
      (lib.concatStringsSep "\n" (map renderEntry materializedEntries)) + "\n"
    );

in
{
  inherit
    bootstrapFilesEnabled
    workspaceAssertions
    materializedManifest
    workspaceRootsManifest
    materializedEntries
    ;
}
