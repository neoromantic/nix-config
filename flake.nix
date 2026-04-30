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

      determinateNix.customSettings = {
        warn-dirty = false;
        accept-flake-config = true;
        extra-trusted-users = [ "@admin" "sergeypetrov" ];
        extra-substituters = [ "https://nix-community.cachix.org" ];
        extra-trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };

      nixpkgs.config.allowUnfree = true;
      nixpkgs.hostPlatform = "aarch64-darwin";

      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;
      system.primaryUser = "sergeypetrov";

      programs.zsh = {
        enable = true;
        enableCompletion = true;
        enableSyntaxHighlighting = true;
        enableFzfCompletion = true;
        enableFzfHistory = true;
        enableFzfGit = true;
      };

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

          # Smart-substitution off — критично для кода/JSON/CLI в нативных полях
          NSAutomaticDashSubstitutionEnabled = false;
          NSAutomaticQuoteSubstitutionEnabled = false;
          NSAutomaticCapitalizationEnabled = false;
          NSAutomaticPeriodSubstitutionEnabled = false;
          NSAutomaticSpellingCorrectionEnabled = false;
          NSAutomaticInlinePredictionEnabled = false;

          # Скроллбары всегда видны
          AppleShowScrollBars = "Always";

          # Cmd+Ctrl+drag за любую часть окна
          NSWindowShouldDragOnGesture = true;

          # Метрика и 24h
          AppleICUForce24HourTime = true;
          AppleMeasurementUnits = "Centimeters";
          AppleMetricUnits = 1;
          AppleTemperatureUnit = "Celsius";

          # Save-диалоги развёрнуты, без iCloud-дефолта
          NSDocumentSaveNewDocumentsToCloud = false;
          NSNavPanelExpandedStateForSaveMode = true;
          NSNavPanelExpandedStateForSaveMode2 = true;
          PMPrintingExpandedStateForPrint = true;
          PMPrintingExpandedStateForPrint2 = true;
        };

        # Stage Manager и edge-tiling Sequoia — конфликтует с Aerospace
        WindowManager = {
          GloballyEnabled = false;
          EnableTilingByEdgeDrag = false;
          EnableTopTilingByEdgeDrag = false;
          EnableTilingOptionAccelerator = false;
          EnableStandardClickToShowDesktop = false;
        };

        controlcenter = {
          BatteryShowPercentage = true;
          Sound = true;
          Bluetooth = true;
          NowPlaying = false;
        };

        menuExtraClock = {
          Show24Hour = true;
          ShowSeconds = true;
          ShowDate = 1;          # 1 = always show date
          ShowDayOfWeek = true;
        };

        ActivityMonitor = {
          IconType = 5;          # CPU history graph in Dock
          SortColumn = "CPUUsage";
          SortDirection = 0;     # descending
          ShowCategory = 100;    # All Processes
        };

        LaunchServices.LSQuarantine = false;

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
          FXEnableExtensionChangeWarning = false;
          _FXShowPosixPathInTitle = true;
        };

        trackpad.Clicking = true;

        loginwindow.LoginwindowText = "goodit.works";

        screencapture = {
          location = "~/Pictures/screenshots";
          type = "png";
          disable-shadow = true;
          show-thumbnail = false;
          include-date = true;
        };

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
