{
  description = "My system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
        url = "github:LnL7/nix-darwin";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
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

        environment.systemPackages = [ 
	  pkgs.neofetch 
	  pkgs.vim
	  pkgs.arc-browser 
	];

	system.defaults = {
  		dock.autohide = true;
		dock.mru-spaces = false;
  		finder.AppleShowAllExtensions = true;
		finder.FXPreferredViewStyle = "clmv";
  		loginwindow.LoginwindowText = "goodit.works";
  		screencapture.location = "~/Pictures/screenshots";
  		screensaver.askForPasswordDelay = 10;
	};
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
