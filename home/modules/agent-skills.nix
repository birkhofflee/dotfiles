# Agent Skills, pinned by flake.lock and installed with agent-skills-nix.
#
# Targets use the `link` structure, so home.file adds one symlink per skill and
# the directories stay shared. The tree structures rsync --delete the whole
# destination, which would remove Rex's stub (`rex skill setup` owns
# */skills/rex) and home-manager's plugins in .claude/skills.
#
# ~/.agents/skills is read by Codex, Cursor and Gemini CLI; Claude
# Code only reads ~/.claude/skills.
{ inputs, pkgs, ... }:
let
  sourceInSkills = input: {
    inherit input;
    subdir = "skills";
  };

  # The paper-search skill expects this CLI on PATH. Bump alongside the
  # paper-search-mcp input.
  paper-search = pkgs.writeShellScriptBin "paper-search" ''
    exec ${pkgs.uv}/bin/uvx --from paper-search-mcp==0.1.4 paper-search "$@"
  '';
in
{
  # Imported here rather than by each host, so every consumer of the shared home
  # base (mkSystem, standalone WSL, the Homelab and Proxy repos) gets the option.
  imports = [ inputs.agent-skills.homeManagerModules.default ];

  # firecrawl-research-papers drives the Research Index through this CLI, which
  # reads FIRECRAWL_API_KEY from secrets/mcp-env.age.
  home.packages = [
    paper-search
    pkgs.firecrawl-cli
  ];

  # Installed as a plugin, not through agent-skills: its skills read shared/ and
  # scripts/ at the repo root, and its commands, agents and hooks are wired by
  # the plugin manifest.
  #
  # Linked directly rather than through programs.claude-code.plugins, which wraps
  # the plugin in a directory of per-entry symlinks. Claude Code then skips every
  # skill in the manifest with "Path escapes plugin directory", because each one
  # resolves outside that wrapper. Can move back once this is fixed:
  # https://github.com/nix-community/home-manager/issues/9906
  home.file.".claude/skills/academic-research-skills".source = inputs.academic-research-skills;

  programs.agent-skills = {
    enable = true;

    sources = {
      emil = sourceInSkills "emil-skills";
      cloudflare = sourceInSkills "cloudflare-skills";
      hallmark = sourceInSkills "hallmark-skills";
      improve = sourceInSkills "improve-skills";
      seedex = sourceInSkills "seedex-skills";
      vocabulary = sourceInSkills "vocabulary-skills";
      find-skills = sourceInSkills "find-skills";
      mattpocock = sourceInSkills "mattpocock-skills";
      firecrawl = sourceInSkills "firecrawl-skills";
      tw-formal-writing = sourceInSkills "tw-formal-writing-skills";
      security-audit = sourceInSkills "security-audit-skill";
      paper-search.input = "paper-search-mcp";
    };

    skills.enableAll = [
      "emil"
      "cloudflare"
      "hallmark"
      "improve"
      "vocabulary"
    ];

    skills.enable = [
      "spark" # wishworldbetter/seedex-skills
      "firecrawl-research-papers" # firecrawl/firecrawl-workflows
      "tw-formal-writing" # Imbad0202/tw-formal-writing
      "security-audit" # cloudflare/security-audit-skill
    ];

    skills.explicit = {
      # Upstream installs with `npx skills add`, which bypasses this module.
      find-skills = {
        from = "find-skills";
        transform =
          { original, ... }:
          original
          + ''

            ## Installing skills on this machine

            This overrides every install instruction above. Skills here are managed by Nix, so never run `npx skills add` or `npx skills update`. `npx skills find` is still fine for searching.

            To install a skill, edit `home/modules/agent-skills.nix` in the dotfiles repo (`~/.config/dotfiles` on AlexMBP):

            1. Add the repository to `flake.nix` as an input with `flake = false`.
            2. Declare it under `programs.agent-skills.sources`.
            3. Select the skill with `skills.enable`, or `skills.explicit` if it is nested below the source root.
            4. Ask the user to run `just switch`, which needs their sudo password.
          '';
      };
      research = {
        from = "mattpocock";
        path = "engineering/research";
      };
      paper-search = {
        from = "paper-search";
        path = "claude-code";
      };
    };

    targets = {
      claude = {
        enable = true;
        dest = ".claude/skills";
        structure = "link";
      };
      agents = {
        enable = true;
        dest = ".agents/skills";
        structure = "link";
      };
    };
  };
}
