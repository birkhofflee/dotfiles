{
  nixpkgs,
  overlays,
  inputs,
}:

name:
{
  system,
  user,
  nixos-anywhere ? false,
  hasDesktop ? false,
  homeConfig ? ../home,
}:

let
  isDarwin = nixpkgs.lib.hasSuffix "-darwin" system;

  # The config files for this system.
  # Host configs are in hosts/${name}/ and will auto-import default.nix
  machineConfig = ../hosts/${name};

  # NixOS vs nix-darwin functions
  systemFunc = if isDarwin then inputs.nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  home-manager =
    if isDarwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;
in
systemFunc rec {
  inherit system;

  specialArgs = { inherit inputs; };

  modules = [
    # Include disko and nixos-facter modules only for nixos-anywhere deployments
    (if nixos-anywhere then inputs.disko.nixosModules.disko else { })
    (if nixos-anywhere then inputs.nixos-facter-modules.nixosModules.facter else { })
    (
      if nixos-anywhere then
        {
          config.facter.reportPath =
            let
              facterPath = machineConfig + "/facter.json";
            in
            if builtins.pathExists facterPath then
              facterPath
            else
              throw "Have you forgotten to run nixos-anywhere with `--generate-hardware-config nixos-facter ./hosts/${name}/facter.json`?";
        }
      else
        { }
    )

    # Apply our overlays. Overlays are keyed by system type so we have
    # to go through and apply our system type. We do this first so
    # the overlays are available globally.
    { nixpkgs.overlays = overlays; }

    # Allow unfree packages.
    { nixpkgs.config.allowUnfree = true; }

    # Machine-specific configuration
    machineConfig

    # Home-manager integration
    home-manager.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs; currentSystemUser = user; inherit hasDesktop; };
      home-manager.users.${user} = import homeConfig;
    }

    # nix-index-database integration
    inputs.nix-index-database.${if isDarwin then "darwinModules" else "nixosModules"}.nix-index
    { programs.nix-index-database.comma.enable = true; }

    # agenix integration
    (if isDarwin then inputs.agenix.darwinModules.default else inputs.agenix.nixosModules.default)

    # Determinate Nix integration
    (if isDarwin then inputs.determinate.darwinModules.default else inputs.determinate.nixosModules.default)

    # We expose some extra arguments so that our modules can parameterize
    # better based on these values.
    {
      config._module.args = {
        currentSystem = system;
        currentSystemName = name;
        currentSystemUser = user;
        inputs = inputs;
      };
    }
  ];
}
