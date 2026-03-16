{ pkgs, lib, ... }:

let
  # Wrap age-plugin-1p to reset umask before invoking op.
  # The agenix mount-secrets script sets umask u=r,g=,o= inside its decryption
  # subshell, which propagates to age-plugin-1p → op and causes op to create
  # its session file with 0400 instead of the required 0600, breaking subsequent
  # invocations.
  age-plugin-1p-wrapped = pkgs.writeShellScriptBin "age-plugin-1p" ''
    umask 077
    exec ${pkgs.age-plugin-1p}/bin/age-plugin-1p "$@"
  '';
in
pkgs.writeShellApplication {
  name = "age";
  runtimeInputs = [
    age-plugin-1p-wrapped
    pkgs._1password-cli
  ];
  text = ''
    exec ${pkgs.age}/bin/age "$@"
  '';
  meta = with lib; {
    description = "age encryption tool with 1Password plugin support";
    homepage = "https://github.com/FiloSottile/age";
    license = licenses.bsd3;
    platforms = platforms.all;
  };
}
