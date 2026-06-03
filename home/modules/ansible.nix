{
  home.file.".ansible.cfg" = {
    text = ''
      [defaults]
      nocows = 1
      timeout = 25
      forks = 25
      gathering = smart
      fact_caching = jsonfile
      fact_caching_connection = /tmp
      host_key_checking = False

      [ssh_connection]
      pipelining = True
      ssh_args = -o ControlMaster=auto -o ControlPersist=3600s -o PreferredAuthentications=publickey
    '';
  };
}
