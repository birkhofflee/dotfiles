{
  nixpkgs,
  overlays,
  inputs,
}:

name:
{
  system,
  user,
  # Darwin hosts always have a desktop; NixOS hosts opt in.
  hasDesktop ? nixpkgs.lib.hasSuffix "-darwin" system,
}:

let
  isDarwin = nixpkgs.lib.hasSuffix "-darwin" system;

  # The config files for this system.
  # Host configs are in hosts/${name}/ and will auto-import default.nix
  machineConfig = ../hosts/${name};
  homeConfig = ../hosts/${name}/home.nix;

  # NixOS vs nix-darwin functions
  systemFunc = if isDarwin then inputs.nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  platformModules = if isDarwin then "darwinModules" else "nixosModules";
in
systemFunc {
  inherit system;

  specialArgs = { inherit inputs; };

  modules = [
    # Apply our overlays. We do this first so the overlays are available globally.
    { nixpkgs.overlays = overlays; }

    # Allow unfree packages.
    { nixpkgs.config.allowUnfree = true; }

    # Machine-specific configuration
    machineConfig

    # Home-manager integration
    inputs.home-manager.${platformModules}.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = {
        inherit inputs;
        currentSystemUser = user;
        inherit hasDesktop;
      };
      home-manager.users.${user} = import homeConfig;
    }

    # nix-index-database integration
    # This gives `, <command>` that run commands without installation
    inputs.nix-index-database.${platformModules}.nix-index
    { programs.nix-index-database.comma.enable = true; }

    # agenix integration
    inputs.agenix.${platformModules}.default
    { home-manager.sharedModules = [ inputs.agenix.homeManagerModules.age ]; }

    # Determinate Nix integration
    inputs.determinate.${platformModules}.default

    # We expose some extra arguments so that our modules can parameterize
    # better based on these values.
    {
      config._module.args = {
        currentSystemName = name;
        currentSystemUser = user;
      };
    }
  ];
}
