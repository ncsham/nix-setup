# Git configuration (delta, aliases, core settings).
{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "NCSham";
        email = "sudoer@ncsham.in";
      };
      core = {
        pager = "";
        editor = "nvim";
      };
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate = true;
        light = false;
        side-by-side = false;
        line-numbers = true;
        syntax-theme = "Dracula";
        minus-style = "syntax '#450a15'";
        minus-emph-style = "syntax '#600818'";
        plus-style = "syntax '#0c4a1b'";
        plus-emph-style = "syntax '#0e6823'";
        file-style = "bold yellow ul";
        file-decoration-style = "none";
        hunk-header-style = "cyan bold";
        hunk-header-decoration-style = "cyan box";
        line-numbers-left-style = "cyan";
        line-numbers-right-style = "cyan";
        line-numbers-minus-style = "red";
        line-numbers-plus-style = "green";
        max-line-distance = 1;
        tabs = 4;
      };
      color = {
        ui = "auto";
        diff = "auto";
        status = "auto";
        branch = "auto";
      };
      diff = {
        colorMoved = "default";
        algorithm = "patience";
      };
      merge.conflictstyle = "diff3";
      pull.rebase = false;
      push = {
        default = "simple";
        autoSetupRemote = true;
      };
      init.defaultBranch = "main";
    };
  };
}
