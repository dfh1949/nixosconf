
{ config, pkgs, ... }:

let
  nvidia-sync = pkgs.writeShellScriptBin "nvidia-sync" ''
    export LIBVA_DRIVER_NAME=nvidia
    export LIBVA_DRIVER_PATH=/usr/lib/x86_64-linux-gnu/dri/
    export MOZ_DISABLE_RDD_SANDBOX=1
    export MOZ_X11_EGL=1
    export MOZ_ENABLE_WAYLAND=1
    exec "$@"
  '';
in


{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  nix.settings = {
    cores = 0 ;
    auto-optimise-store = true;
    # 使用镜像源
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
    ]; 
    trusted-users = [
       "@wheel"
       "xsb"
       "root"
    ];
 
    # 启用 flake 和 nix commands 实验性功能
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
 
  hardware.enableAllFirmware = true;
  boot.kernelPackages = pkgs.linuxPackages_latest ;
  #boot.kernelPackages =  pkgs.linuxKernel.kernels.linux_zen;

  #开启pipewire
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    jack.enable = true ;
  };
  
  #开启Flatpak
  services.flatpak.enable = true ;
  
  #NVIDIA Prime显卡切换
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.nvidia.nvidiaSettings = true ;
  hardware.video.hidpi.enable = true ;
  hardware.nvidia.modesetting.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.dpi = 96 ;
  hardware.nvidia.prime = {
    sync.enable = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
  
  #Nvidia-Vaapi
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs ; [
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver
      vaapiIntel
    ];
  };
 

  #自动更新，更换镜像源为中科大镜像源
  system.autoUpgrade = {
    enable = true;

    allowReboot = true;
    channel = https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixos-unstable ;
  };


  #允许闭源软件
  nixpkgs.config.allowUnfree = true;

  #GRUB
   boot.loader = {
   efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      device = "nodev";
      default = "1"; # 从0计数
      efiSupport = true;
      gfxmodeEfi = "1920x1080"; # 在 hidpi 高分辨率屏幕显示很小，改成低分辨率直接拉伸放大
     
      useOSProber = true;
    };
   };

  
  #开启NTFS支持
  boot.supportedFilesystems = [ "ntfs" ];

  #IWD
  networking.networkmanager.wifi.backend = "iwd";
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
    dhcp = "dhcpcd";
  };
  
  services.resolved.enable = true;  
  hardware.bluetooth.enable = true;
  
  #IWD设置
  networking.wireless.iwd.enable = true;
  networking.wireless.iwd.settings={
     Network = {
       EnableIPv6 = true;
     };
     Settings = {
       AutoConnect = true;
     };
  };

  #设置时区
  time.timeZone = "Asia/Shanghai";


  #语言选项
  i18n = {
    defaultLocale = "zh_CN.UTF-8";
    supportedLocales = [ "zh_CN.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
  };

  #输入法Fcitx5
  i18n.inputMethod = {
    fcitx5.enableRimeData = true ;
    
    enabled = "fcitx5";
    fcitx5.addons = [
       pkgs.fcitx5-rime  
       pkgs.fcitx5-chinese-addons 
    ];
  }; 

  #systemd
  systemd = {
    watchdog.rebootTime = "2s";
    watchdog.runtimeTime = "3s";
  };

  # X11支持
  services.xserver.enable = true;

  #字体
  fonts = {
    enableDefaultFonts = true;
    fontconfig = {
      enable = true;
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        monospace = [
          "Hack"
          "Source Han Mono SC"
        ];
        sansSerif = [
          "Inter"
          "Liberation Sans"
          "Source Han Sans SC"
        ];
        serif = [
          "Liberation Serif"
          "Source Han Serif SC"
        ];
      };
    };
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      hack-font
      jetbrains-mono
      hack-font
      inter
      liberation_ttf
      noto-fonts-emoji
      roboto
      sarasa-gothic
      source-han-mono
      source-han-sans
      source-han-serif
      wqy_microhei
      wqy_zenhei
      roboto-mono
      cascadia-code
    ];
  };

  #桌面环境为KDE
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.colord.enable = true;
  services.geoclue2.enable = true;
  programs.kdeconnect.enable = false;
   


  #programs.zsh.enable = true ;
  #开启Root
  users.users.xsb = {
    shell = pkgs.nushell;
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      sublime4
      vscode
      kate
    ];
  };
  

  #软件安装
  # 搜索命令为 nix search
  environment.systemPackages = with pkgs; [
    wget
    nano
    curl
    gdb
    gcc
    axel
    nushell
    iwd
    linuxKernel.kernels.linux_zen
    fcitx5-configtool
    fcitx5-rime
    rime-data
    firefox-beta-bin
    wpsoffice
    sublime4
    vscode
    smplayer
    mpv
    ntfs3g
    libvdpau-va-gl
    vaapiVdpau
    nvidia-vaapi-driver
    mesa
    uget
    flatpak
    flatpak-builder
  ];

  #系统版本
  system.stateVersion = "22.11";

}

