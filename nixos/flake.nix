{
  description = "Default system Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    hyprland-hyprspace = {
      url = "github:KZDKM/Hyprspace";
      inputs.hyprland.follows = "hyprland";
    };

    matugen.url = "github:InioX/matugen?ref=v2.2.0";
    ags.url = "github:Aylur/ags";
    astal.url = "github:Aylur/astal";

    lf-icons = {
      url = "github:gokcehan/lf";
      flake = false;
    };

    firefox-gnome-theme = {
      url = "github:rafaelmardojai/firefox-gnome-theme";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: 
	let
		system = "x86_64-linux";
		pkgs = import nixpkgs {
			inherit system;
			config = {
				allowUnfree = true;
				};
			};
		in
		{
		packages.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.callPackage ../homemanager/ags {inherit inputs;};
		nixosConfigurations = {
			myNixos = nixpkgs.lib.nixosSystem {
				specialArgs = { 
				  inherit inputs system; 
				  asztal = self.packages.x86_64-linux.default;
				  };

				modules = [
				./configuration.nix
				];
			};
		};
	};
}
