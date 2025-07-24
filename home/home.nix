{ pkgs, ... }:

{
  # Environment Variables
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Add directories to PATH
  home.sessionPath = [
    "~/.cargo/bin"
  ];

  # Shell aliases
  home.shellAliases = {
    claude = "~/.claude/local/claude";
  };

  programs.zsh.enable = true;

  programs.jujutsu = {
    enable = true;
    ediff = true;
    settings = {
      user = {
        name = "__NAME__";
        email = "__EMAIL__";
      };
      ui = {
        default-command = "log";
        pager = "less -FRX";
      };
    };
  };

  programs.tmux = {
    enable = true;
    escapeTime = 10;
  };

  # Symlink claude files back to ~/.claude
  home.file = {
    ".claude/CLAUDE.md".source = ../context/CLAUDE.md;
    ".claude/agents" = {
      source = ../context/agents;
      recursive = true;
    };
  };

  # Do not modify unless you want to delete your home directory.
  home.stateVersion = "23.05";
}
