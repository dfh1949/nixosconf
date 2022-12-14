{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.extraModulePackages = [ ];
  boot.plymouth.enable = false ;
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/9af27e2b-5e56-46ef-9009-6a3cd3144e9f";
      fsType = "f2fs";
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/adac7e05-6d5d-4e7c-876c-36f454c96981";
      fsType = "f2fs";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/adac7e05-6d5d-4e7c-876c-36f454c96981";
      fsType = "f2fs";
    };


  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/CF4C-6304";
      fsType = "vfat";
    };

  swapDevices = [ ];
  networking.useDHCP = lib.mkDefault true;


  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
