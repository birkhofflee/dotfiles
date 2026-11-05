_: {
  home.file.".ssh/id_ed25519.pub".text = (import ../../lib/keys.nix).ale;
}
