{
  programs.claude-code = {
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

  # plugins
  # claude plugin list
  #
  # Installed plugins:

  #   ❯ claude-hud@claude-hud
  #     Version: 0.0.12
  #     Scope: user
  #     Status: ✔ enabled

  #   ❯ claude-md-management@claude-plugins-official
  #     Version: 1.0.0
  #     Scope: user
  #     Status: ✔ enabled

  #   ❯ code-simplifier@claude-plugins-official
  #     Version: 1.0.0
  #     Scope: user
  #     Status: ✔ enabled

  #   ❯ feature-dev@claude-plugins-official
  #     Version: unknown
  #     Scope: user
  #     Status: ✔ enabled

  #   ❯ figma@claude-plugins-official
  #     Version: 2.2.12
  #     Scope: user
  #     Status: ✔ enabled

  #   ❯ frontend-design@claude-plugins-official
  #     Version: unknown
  #     Scope: user
  #     Status: ✔ enabled

  # ❯ playwright@claude-plugins-official
  #   Version: unknown
  #   Scope: user
  #   Status: ✔ enabled

  # ❯ rust-analyzer-lsp@claude-plugins-official
  #   Version: 1.0.0
  #   Scope: user
  #   Status: ✔ enabled

  # ❯ security-guidance@claude-plugins-official
  #   Version: 2.0.0
  #   Scope: user
  #   Status: ✔ enabled

  # ❯ swift-lsp@claude-plugins-official
  #   Version: 1.0.0
  #   Scope: user
  #   Status: ✔ enabled

  # ❯ typescript-lsp@claude-plugins-official
  #   Version: 1.0.0
  #   Scope: user
  #   Status: ✔ enabled

  # ❯ vercel@claude-plugins-official
  #   Version: 0.43.0
  #   Scope: user
  #   Status: ✔ enabled
}
