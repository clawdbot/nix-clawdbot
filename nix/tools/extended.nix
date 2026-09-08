{
  pkgs,
  openclawToolPkgs ? { },
  toolNamesOverride ? null,
  excludeToolNames ? [ ],
}:
let
  lib = pkgs.lib;
  safe = list: builtins.filter (p: p != null) list;
  pickFrom =
    scope: name:
    if builtins.hasAttr name scope then
      let
        pkg = scope.${name};
      in
      if lib.meta.availableOn pkgs.stdenv.hostPlatform pkg then pkg else null
    else
      null;
  pick =
    name:
    let
      fromOpenClawTools = pickFrom openclawToolPkgs name;
    in
    if fromOpenClawTools != null then fromOpenClawTools else pickFrom pkgs name;
  ensure = names: safe (map pick names);

  baseNames = [
    "nodejs_24"
    "pnpm"
    "git"
    "curl"
    "jq"
    "python3"
    "ffmpeg"
    "sox"
    "ripgrep"
  ];

  extraNames = [
    "gogcli"
    "goplaces"
    "summarize"
    "camsnap"
    "sonoscli"
  ];
  toolNamesBase = if toolNamesOverride != null then toolNamesOverride else baseNames ++ extraNames;
  toolNames = builtins.filter (name: !builtins.elem name excludeToolNames) toolNamesBase;

in
{
  tools = ensure toolNames;
  toolNames = toolNames;
}
