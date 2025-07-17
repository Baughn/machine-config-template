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

  # Do not modify unless you want to delete your home directory.
  home.stateVersion = "23.05";
}
