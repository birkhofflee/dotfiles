# Shared MCP servers, consumed by claude-code via enableMcpIntegration.
#
# Servers requiring auth tokens are declared on claude-code below instead of in
# programs.mcp, because headers are copied verbatim and need Claude Code's
# variable syntax. The tokens live in secrets/mcp-env.age (agenix), decrypted to
# ~/.config/mcp/secrets.env on AlexMBP and exported by zsh.
{ lib, pkgs, ... }:
{
  programs.mcp = {
    enable = true;

    servers = {
      exa.url = "https://mcp.exa.ai/mcp";
      alphaxiv.url = "https://api.alphaxiv.org/mcp/v1";
      consensus.url = "https://mcp.consensus.app/mcp";
      # Local stdio server: NixOS/Home Manager/nix-darwin option and package lookup
      nixos.command = lib.getExe pkgs.mcp-nixos;
    };
  };

  # Claude Code expands `${VAR}` in .mcp.json at launch
  programs.claude-code.mcpServers.github = {
    url = "https://api.githubcopilot.com/mcp";
    headers.Authorization = "Bearer \${GITHUB_MCP_PAT}";
  };

  programs.zsh.initContent = ''
    # MCP auth tokens (agenix, see secrets/mcp-env.age)
    [[ -f "$HOME/.config/mcp/secrets.env" ]] && source "$HOME/.config/mcp/secrets.env"
  '';
}
