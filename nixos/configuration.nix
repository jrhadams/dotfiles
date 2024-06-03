{ config, pkgs, lib, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  nix.nixPath =
    [
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
      "nixos-config=/persist/etc/nixos/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # source: https://grahamc.com/blog/erase-your-darlings
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/local/root@blank
  '';

  #Permanent location for network
  environment.etc = {
  "NetworkManager/system-connections".source = "/persist/etc/NetworkManager/system-connections";
};
   systemd.tmpfiles.rules = [
    "L /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
  ];
  # source: https://grahamc.com/blog/nixos-on-zfs
  boot.kernelParams = [ "elevator=none" ];

  networking.hostId = "b0e476f1";

 #networking.useDHCP = true;
 networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs;
    [
      bat
      bottom
      dolphin
      firefox
      freetube
      git
      hyprland
      luakit
      kitty
      neovim
      nushell
      playerctl
      python3
      R
      vim
      waybar
      wofi
      zellij
    ];

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
    # TODO: autoReplication
  };

#Graphical session
services.xserver.enable = true;
services.xserver.displayManager.sddm.enable = true;
services.xserver.displayManager.sddm.wayland.enable = true;
programs.hyprland = {
  enable = true;
  xwayland.enable = true;
};

#Audio and bluetooth
security.rtkit.enable = true;
services.pipewire = {
  enable = true;
  alsa.enable = true;
  alsa.support32Bit = true;
  pulse.enable = true;
  # If you want to use JACK applications, uncomment this
  #jack.enable = true;
};
services.blueman.enable = true;



  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
    hostKeys =
      [
        {
          path = "/persist/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/persist/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
      ];
  };

  users = {
    mutableUsers = false;
    users = {
      root = {
        initialHashedPassword = "\$6\$AgHMa3SiiTy8huC8\$6NMc0oFWaTAWPCwUxDkgtbKVK0dVjp99DJtnZzhU7cq1cPR0/CHvbRJV6fT1FclonRT2.tdkv41TuS4nAhFLe0";
      };

      jrha = {
        createHome = true;
	isSystemUser = true;
        initialHashedPassword = "\$6\$8QhFum7giQrNeR56\$5qxA6nleSQGISaQjFvEYCcmyF0k67QS04YyqZSWQeTk1C0FmUPdy4ZgROtigt5wBamTN0p/tCmh002oB41luE/";
	extraGroups = [ "wheel" ];
	group = "users";
	uid = 1000;
	home = "/home/jrha";
	useDefaultShell = true;
        openssh.authorizedKeys.keys = [ "" ];
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

#Don't forget fonts
 fonts = {
        enableDefaultPackages = true;
        fontDir.enable = true;

        packages = with pkgs; [
            (nerdfonts.override { fonts = [
                "SpaceMono" 
                "JetBrainsMono"
                "DejaVuSansMono"
             ]; })
        ];
    };


}
