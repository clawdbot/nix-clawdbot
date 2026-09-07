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
  toJSONWithContext = import ../../../lib/json-with-context.nix { inherit lib; };
  # Encode names that could escape or collide on case-insensitive filesystems.
  # Reserve the encoded prefix so literal names cannot alias generated paths.
  pathComponent =
    name:
    if builtins.match "[a-z0-9_-][a-z0-9._-]*" name != null && !(lib.hasPrefix "encoded-" name) then
      name
    else
      "encoded-${builtins.hashString "sha256" name}";
  rootForInstance =
    name: "${openclawLib.homeDir}/.local/share/nix-openclaw/skills/${pathComponent name}";
  roots = map rootForInstance (lib.attrNames enabledInstances);

  renderSkill =
    skill:
    let
      frontmatterLines = [
        "---"
        "name: ${skill.name}"
        "description: ${skill.description or ""}"
      ]
      ++ lib.optionals (skill ? homepage && skill.homepage != null) [ "homepage: ${skill.homepage}" ]
      ++ lib.optionals (skill ? openclaw && skill.openclaw != null) [
        "openclaw:"
        "  ${toJSONWithContext skill.openclaw}"
      ]
      ++ [ "---" ];
      frontmatter = lib.concatStringsSep "\n" frontmatterLines;
      body = if skill ? body then skill.body else "";
    in
    "${frontmatter}\n\n${body}\n";

  duplicateSkillAssertion =
    let
      targetsForInstance =
        instName: inst:
        let
          userTargets = map (skill: skill.name) cfg.skills;
          pluginsForInstance = plugins.resolvedPluginsByInstance.${instName} or [ ];
          pluginTargets = lib.flatten (map (p: map builtins.baseNameOf p.skills) pluginsForInstance);
        in
        map (name: "${instName}:${name}") (userTargets ++ pluginTargets);
      skillTargetsByInstance = lib.flatten (lib.mapAttrsToList targetsForInstance enabledInstances);
      counts = lib.foldl' (
        acc: path: acc // { "${path}" = (acc.${path} or 0) + 1; }
      ) { } skillTargetsByInstance;
      duplicates = lib.attrNames (lib.filterAttrs (_: v: v > 1) counts);
      renderDuplicate =
        duplicate:
        let
          parts = lib.splitString ":" duplicate;
          instName = lib.elemAt parts 0;
          skillName = lib.concatStringsSep ":" (lib.drop 1 parts);
        in
        "programs.openclaw.instances.${instName}: ${skillName}";
    in
    if duplicates == [ ] then
      [ ]
    else
      [
        {
          assertion = false;
          message = "Duplicate Nix-managed skill names detected: ${lib.concatStringsSep ", " (map renderDuplicate duplicates)}";
        }
      ];

  skillEntriesByInstance =
    let
      entriesForInstance =
        instName: inst:
        let
          sourceFor =
            skill:
            let
              mode = skill.mode or "symlink";
              source = if skill ? source && skill.source != null then resolvePath skill.source else null;
            in
            if mode == "inline" then
              pkgs.writeTextDir "SKILL.md" (renderSkill skill)
            else if mode == "copy" || mode == "symlink" then
              builtins.path {
                name = "openclaw-skill-${skill.name}";
                path = source;
              }
            else
              throw "Unsupported OpenClaw skill mode: ${mode}";
          pluginsForInstance = plugins.resolvedPluginsByInstance.${instName} or [ ];
          pluginSkillDirs =
            plugin:
            map (skill: {
              name = builtins.baseNameOf skill;
              source = builtins.path {
                name = "openclaw-plugin-skill-${builtins.baseNameOf skill}";
                path = skill;
              };
            }) plugin.skills;
          userSkillDirs = map (skill: {
            inherit (skill) name;
            source = sourceFor skill;
          }) cfg.skills;
        in
        map (skill: {
          inherit (skill) source;
          target = "${rootForInstance instName}/${pathComponent skill.name}";
        }) (userSkillDirs ++ lib.flatten (map pluginSkillDirs pluginsForInstance));
    in
    lib.mapAttrs entriesForInstance enabledInstances;

  skillLoadDirsForInstance =
    instName: map (entry: entry.target) (skillEntriesByInstance.${instName} or [ ]);

  entries = lib.flatten (lib.attrValues skillEntriesByInstance);
  rootsManifest = pkgs.writeText "openclaw-skill-roots" (lib.concatStringsSep "\n" roots + "\n");
  materializedManifest = pkgs.writeText "openclaw-skill-files.tsv" (
    lib.concatStringsSep "\n" (map (entry: "${entry.source}\t${entry.target}") entries) + "\n"
  );
in
{
  inherit
    roots
    rootsManifest
    materializedManifest
    duplicateSkillAssertion
    skillLoadDirsForInstance
    ;
}
