{ pkgs, ... }:

let
  pulse = (pkgs.pulseaudio.overrideAttrs ( oldAttrs: { airtunesSupport = true; }) );
in
{
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  environment.systemPackages = [ pulse ];
  nixpkgs.config.pulseaudio = true;
  hardware.pulseaudio.extraModules = [ pkgs.pulseaudio-modules-bt ];
  hardware.pulseaudio.extraConfig = ''
    load-module module-raop-discover
    load-module module-raop-sink
  '';
  # hardware.pulseaudio.extraConfig = ''
  #   load-module module-tunnel-sink-new server=hifipi.petabyte.dev
  #   load-module module-tunnel-sink-new server=tvpi.petabyte.dev
  #   load-module module-echo-cancel use_master_format=1 aec_method=webrtc aec_args="analog_gain_control=0\ digital_gain_control=0" source_name=echoCancel_source sink_name=echoCancel_sink
  #   set-default-source echoCancel_source
  #   set-default-sink echoCancel_sink
  # '';
}
