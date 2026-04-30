{
  description = "Goodit Book Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, determinate }:
  let
    configuration = { pkgs, ... }: {
      determinateNix.enable = true;

      nixpkgs.config.allowUnfree = true;
      nixpkgs.hostPlatform = "aarch64-darwin";

      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;
      system.primaryUser = "sergeypetrov";

      programs.zsh.enable = true;
      security.pam.services.sudo_local.touchIdAuth = true;

      environment = {
        shells = with pkgs; [ zsh bash ];
        pathsToLink = [ "/share/zsh" ];
        systemPackages = with pkgs; [
          vim
          fnm
          uv
        ];
      };

      fonts.packages = with pkgs;
        [ geist-font ]
        ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues nerd-fonts);

      system.defaults = {
        NSGlobalDomain = {
          AppleShowAllExtensions = true;
          AppleShowAllFiles = true;
          ApplePressAndHoldEnabled = false;
          KeyRepeat = 2;
          InitialKeyRepeat = 15;
          "com.apple.mouse.tapBehavior" = 1;
          "com.apple.sound.beep.volume" = 0.0;
          "com.apple.sound.beep.feedback" = 0;
        };

        dock = {
          autohide = true;
          mru-spaces = false;
          mouse-over-hilite-stack = true;
          tilesize = 48;
          autohide-delay = 0.0;
          autohide-time-modifier = 0.2;
          launchanim = false;
          static-only = false;
          showhidden = true;
        };

        finder = {
          ShowStatusBar = true;
          ShowPathbar = true;
          AppleShowAllExtensions = true;
          FXPreferredViewStyle = "clmv";
        };

        trackpad.Clicking = true;

        loginwindow.LoginwindowText = "goodit.works";

        screencapture.location = "~/Pictures/screenshots";

        screensaver.askForPasswordDelay = 10;

        CustomUserPreferences = {
          "com.apple.finder" = {
            ShowExternalHardDrivesOnDesktop = true;
            ShowHardDrivesOnDesktop = true;
            ShowMountedServersOnDesktop = true;
            ShowRemovableMediaOnDesktop = true;
            _FXSortFoldersFirst = true;
            FXDefaultSearchScope = "SCcf";
          };
          "com.apple.desktopservices" = {
            DSDontWriteNetworkStores = true;
            DSDontWriteUSBStores = true;
          };
          "com.apple.SoftwareUpdate" = {
            AutomaticCheckEnabled = true;
            ScheduleFrequency = 1;
            AutomaticDownload = 1;
            CriticalUpdateInstall = 1;
          };
          "com.apple.ImageCapture".disableHotPlug = true;
          "com.apple.commerce".AutoUpdate = true;
        };
      };

    };
  in
  {
    darwinConfigurations.gooditbook = nix-darwin.lib.darwinSystem {
      modules = [
        determinate.darwinModules.default
        configuration
      ];
    };
  };
}
