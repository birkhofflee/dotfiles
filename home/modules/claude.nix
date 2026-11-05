{
  programs.claude-code = {
    enable = true;

    # Pull in shared servers from programs.mcp.servers (mcp.nix)
    enableMcpIntegration = true;
  };

  # skills: see agent-skills.nix
}
