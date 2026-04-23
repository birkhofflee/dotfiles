{ currentSystemUser, ... }:

{
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ currentSystemUser ];
  };

  users.users.${currentSystemUser}.extraGroups = [ "_1password" ];
}
