{ pkgs
, steipetePkgs ? {}
, toolNamesOverride ? null
, excludeToolNames ? []
}:
let
  lib = pkgs.lib;
  safe = list: builtins.filter (p: p != null) list;
  pickFrom = scope: name:
    if builtins.hasAttr name scope then
      let pkg = scope.${name}; in
      if lib.meta.availableOn pkgs.stdenv.hostPlatform pkg then pkg else null
    else
      null;
  pick = name:
    let fromSteipete = pickFrom steipetePkgs name; in
    if fromSteipete != null then fromSteipete else pickFrom pkgs name;
  ensure = names: safe (map pick names);

  baseNames = [
    "pnpm_10"
    "git"
    "curl"
    "jq"
    "python3"
    "ffmpeg"
    "sox"
    "ripgrep"
  ];

  extraNames = [
    "go"
    "uv"
    "openai-whisper"
    "spotify-player"
    "gogcli"
    "peekaboo"
    "camsnap"
    "bird"
    "sag"
    "summarize"
    "openhue-cli"
    "wacli"
    "sonoscli"
    "ordercli"
    "blucli"
    "eightctl"
    "mcporter"
    "oracle"
    "qmd"
    "nano-pdf"
  ];
  toolNamesBase = if toolNamesOverride != null then toolNamesOverride else baseNames ++ extraNames;
  toolNames = builtins.filter (name: !builtins.elem name excludeToolNames) toolNamesBase;

in {
  tools = ensure toolNames;
  toolNames = toolNames;
}
