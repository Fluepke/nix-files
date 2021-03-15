{ ... }:

{
  networking.vlans.internet = {
    id = 42;
    interface = "enp2s0";
  };

  networking.vlans.guests = {
    id = 23;
    interface = "enp2s0";
  };

  networking.vlans.wan = {
    id = 420;
    interface = "enp2s0";
  };
}
