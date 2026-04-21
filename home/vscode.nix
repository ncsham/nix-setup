{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = true;

    profiles = {
      default = {
        enableUpdateCheck = false;
        extensions = [
          pkgs.vscode-extensions.github.copilot-chat
          pkgs.vscode-extensions.golang.go
          pkgs.vscode-extensions.illixion.vscode-vibrancy-continued
          pkgs.vscode-extensions.jnoortheen.nix-ide
          pkgs.vscode-extensions."mads-hartmann".bash-ide-vscode
          pkgs.vscode-extensions.mechatroner.rainbow-csv
          pkgs.vscode-extensions.mkhl.shfmt
          pkgs.vscode-extensions."ms-azuretools".vscode-containers
          pkgs.vscode-extensions."ms-python".debugpy
          pkgs.vscode-extensions."ms-python".python
          pkgs.vscode-extensions."ms-python".vscode-pylance
          pkgs.vscode-extensions.oderwat.indent-rainbow
          pkgs.vscode-extensions.redhat.vscode-yaml
          # Missing extensions (not in nixpkgs): install manually via VS Code UI or CLI
          # code --install-extension 4ops.packer
          # code --install-extension chouzz.vscode-better-align
          # code --install-extension openai.chatgpt
          # code --install-extension qcz.text-power-tools
          # code --install-extension qezhu.gitlink
          # code --install-extension ms-python.vscode-python-envs
          # code --install-extension ms-vscode.sublime-keybindings
        ];

        userSettings = {
          "workbench.startupEditor" = "none";
          "git.autofetch" = true;
          "workbench.colorTheme" = "Dark+";
          "workbench.colorCustomizations" = {
            "terminal.background" = "#00000000";
            "editorPane.background" = "#1e1e1e00";
            "editorGroupHeader.tabsBackground" = "#1e1e1e00";
            "editorGroupHeader.noTabsBackground" = "#1e1e1e00";
            "breadcrumb.background" = "#1e1e1e00";
            "editorGutter.background" = "#1e1e1e00";
            "panel.background" = "#1e1e1e00";
            "panelStickyScroll.background" = "#1e1e1e00";
            "tab.activeBackground" = "#1e1e1e00";
            "tab.unfocusedActiveBackground" = "#1e1e1e00";
            "sideBar.background" = "#1e1e1ecc";
            "sideBarTitle.background" = "#1e1e1ecc";
            "sideBarStickyScroll.background" = "#1e1e1ecc";
            "activityBar.background" = "#1e1e1ecc";
            "editor.background" = "#1e1e1ecc";
            "editorStickyScroll.background" = "#1e1e1ecc";
            "editorStickyScrollGutter.background" = "#1e1e1ecc";
            "tab.inactiveBackground" = "#1e1e1ecc";
            "tab.unfocusedInactiveBackground" = "#1e1e1ecc";
            "inlineChat.background" = "#1e1e1ee6";
            "editorWidget.background" = "#1e1e1ee6";
            "editorHoverWidget.background" = "#1e1e1ee6";
            "editorSuggestWidget.background" = "#1e1e1ee6";
            "notifications.background" = "#1e1e1ee6";
            "notificationCenterHeader.background" = "#1e1e1ee6";
            "menu.background" = "#1e1e1ee6";
            "quickInput.background" = "#1e1e1ee6";
          };
          "window.titleBarStyle" = "custom";
          "workbench.activityBar.compact" = true;
          "editor.minimap.enabled" = false;
          "workbench.secondarySideBar.defaultVisibility" = "hidden";
          "files.autoSave" = "afterDelay";
          "python.analysis.typeCheckingMode" = "basic";
          "accessibility.openChatEditedFiles" = true;
          "workbench.editor.enablePreview" = false;
          "python.createEnvironment.trigger" = "off";
          "redhat.telemetry.enabled" = false;
          "terminal.integrated.gpuAcceleration" = "off";
          "window.systemColorTheme" = "dark";
          "window.autoDetectColorScheme" = false;
          "workbench.activityBar.location" = "hidden";
          "security.workspace.trust.untrustedFiles" = "open";
          "chat.viewSessions.orientation" = "stacked";
          "vscode_vibrancy.type" = "auto";
          "vscode_vibrancy.opacity" = 0.6;
          "vscode_vibrancy.preventFlash" = true;
          "vscode_vibrancy.forceFramelessWindow" = true; # Improves rendering on macOS
        };
      };
    };
  };
}