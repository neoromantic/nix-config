{
  description = "Goodit Book Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
        url = "github:LnL7/nix-darwin";
        inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };

    genebean-omp-themes = {
      url = "github:genebean/my-oh-my-posh-themes";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle, genebean-omp-themes }:
  let
    modules = [
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;

            # User owning the Homebrew prefix
            user = "sergeypetrov";

            # Automatically migrate existing Homebrew installations
            autoMigrate = true;
          };
        }
    ];
    configuration = {pkgs, ... }: {

      nix.settings.experimental-features = "nix-command flakes";
      nix.enable = false;
        
      nixpkgs.config.allowUnfree = true;

      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility. please read the changelog
      # before changing: `darwin-rebuild changelog`.
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      # If you're on an Intel system, replace with "x86_64-darwin"
      nixpkgs.hostPlatform = "aarch64-darwin";

      # Declare the user that will be running `nix-darwin`.
      users.users.sergeypetrov = {
          name = "sergeypetrov";
          home = "/Users/sergeypetrov";
      };

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;
      security.pam.services.sudo_local.touchIdAuth = true;

      environment = {
        shells = with pkgs; [ zsh bash ];
        pathsToLink = [ "/Applications" "/share/zsh" ];
        systemPackages = with pkgs; [ 
          neofetch 
          vim
          arc-browser
          code-cursor 
          raycast
          warp-terminal
          defaultbrowser
        ];
      };

      homebrew = {
        enable = true;
        brews = [
          "fastfetch"
          "ffmpeg"
        ];
        casks = [ "1password" "1password-cli" ];
      };

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
        finder  = {
          ShowStatusBar = true;
          ShowPathbar = true;
        };
        trackpad = {
          Clicking = true;
        };
        finder = {
          AppleShowAllExtensions = true;
          FXPreferredViewStyle = "clmv";
        };
        loginwindow = {
          LoginwindowText = "goodit.works";
        };
        screencapture = {
          location = "~/Pictures/screenshots";
        };
        screensaver.askForPasswordDelay = 10;
        CustomUserPreferences = {
          "com.apple.finder" = {
            ShowExternalHardDrivesOnDesktop = true;
            ShowHardDrivesOnDesktop = true;
            ShowMountedServersOnDesktop = true;
            ShowRemovableMediaOnDesktop = true;
            _FXSortFoldersFirst = true;
            # When performing a search, search the current folder by default
            FXDefaultSearchScope = "SCcf";
          };
          "com.apple.desktopservices" = {
            # Avoid creating .DS_Store files on network or USB volumes
            DSDontWriteNetworkStores = true;
            DSDontWriteUSBStores = true;
          };
          "com.apple.SoftwareUpdate" = {
            AutomaticCheckEnabled = true;
            # Check for software updates daily, not just once per week
            ScheduleFrequency = 1;
            # Download newly available updates in background
            AutomaticDownload = 1;
            # Install System data files & security updates
            CriticalUpdateInstall = 1;
          };
                "com.apple.ImageCapture".disableHotPlug = true;
      "com.apple.commerce".AutoUpdate = true;

        };
      };
      system.activationScripts.postUserActivation.text = "/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u";
    };
  in
  {
    darwinConfigurations.gooditbook = nix-darwin.lib.darwinSystem {
      modules = [
         configuration
      ];
    };
  };
}
