{ lib, ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    # @see https://starship.rs/config
    settings = {
      palette = "catppuccin_macchiato";

      palettes.catppuccin_macchiato = {
        rosewater = "#f4dbd6";
        flamingo = "#f0c6c6";
        pink = "#f5bde6";
        mauve = "#c6a0f6";
        red = "#ed8796";
        maroon = "#ee99a0";
        peach = "#f5a97f";
        yellow = "#eed49f";
        green = "#a6da95";
        teal = "#8bd5ca";
        sky = "#91d7e3";
        sapphire = "#7dc4e4";
        blue = "#8aadf4";
        lavender = "#b7bdf8";
        text = "#cad3f5";
        subtext1 = "#b8c0e0";
        subtext0 = "#a5adcb";
        overlay2 = "#939ab7";
        overlay1 = "#8087a2";
        overlay0 = "#6e738d";
        surface2 = "#5b6078";
        surface1 = "#494d64";
        surface0 = "#363a4f";
        base = "#24273a";
        mantle = "#1e2030";
        crust = "#181926";
      };

      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_state"
        "$git_status"
        "$nix_shell"
        "$python"
        "$direnv"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];

      directory = {
        style = "blue";
        fish_style_pwd_dir_length = 1;
        truncate_to_repo = false; # Don't truncate to git repo name
      };

      direnv = {
        disabled = false;
        format = "[$symbol]($style)";
      };

      character = {
        success_symbol = "[❯](blue)";
        error_symbol = "[❯](red)";
        vimcmd_symbol = "[❮](green)";
      };

      git_branch = {
        format = "[$branch]($style)";
        style = "overlay0";
      };

      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style) ";
        style = "teal";
        ahead = "⇡\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        behind = "⇣\${count}";
        staged = "";
      };

      nix_shell = {
        disabled = false;
        format = "[$symbol]($style) ";
        symbol = "❄️";
        heuristic = true;
      };

      python = {
        version_format = "\${major}\${minor}";
        symbol = "py";
      };

      git_state = {
        format = "([$state( $progress_current/$progress_total)]($style) )";
        style = "overlay0";
      };

      cmd_duration = {
        format = "[$duration]($style) ";
        style = "yellow";
      };
    };
  };
}
