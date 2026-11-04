{
  programs.opencode = {
    enable = true;

    # Pull in shared servers from programs.mcp.servers (mcp.nix)
    enableMcpIntegration = true;

    # hooks =
    # lspServers =

    # skills = {}
  };

  # skills: see agent-skills.nix
}
