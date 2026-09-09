{ lib }:

let
  options = import ../generated/openclaw-config-options.nix { inherit lib; };
  memoryOptions = options.memory.type.getSubOptions [ ];
in
{
  supportsQmdBackend = memoryOptions ? backend && memoryOptions.backend.type.check "qmd";
}
