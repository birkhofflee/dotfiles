{ config, ... }:

{
  # GNU nano 7.0+ supports $XDG_CONFIG_HOME/nano/nanorc
  xdg.configFile."nano/nanorc" = {
    text = ''
      # Editor:
      set morespace
      set tabstospaces
      set const

      # UX:
      set smooth

      # Extra files:
      set backup
      set backupdir "${config.xdg.dataHome}/nano/backups"
      set historylog

      # line numbers are copied with text,
      # it is not useful:
      # set linenumbers
    '';
  };
}
