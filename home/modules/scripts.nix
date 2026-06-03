{ lib, ... }:
let
  utilitiesDir = ./shell/utilities;
  # Read all entries in the utilities directory, keeping only regular files
  scripts = lib.filterAttrs (_: type: type == "regular") (builtins.readDir utilitiesDir);
in
{
  # For each script, install it to ~/.local/bin/ with the .zsh extension stripped
  home.file = lib.mapAttrs' (name: _: {
    name = ".local/bin/${lib.removeSuffix ".zsh" name}";
    value = {
      source = utilitiesDir + "/${name}";
      executable = true;
    };
  }) scripts;
}
