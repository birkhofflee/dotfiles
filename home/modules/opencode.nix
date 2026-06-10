{
  programs.opencode = {
    enable = true;

    # Pull in shared servers from programs.mcp.servers (mcp.nix)
    enableMcpIntegration = true;

    # hooks =
    # lspServers =

    # skills = {}
  };

  # skills
  # /spark
  # npx skills add wishworldbetter/seedex-skills --skill spark
  # /improve
  # npx skills add shadcn/improve
}
