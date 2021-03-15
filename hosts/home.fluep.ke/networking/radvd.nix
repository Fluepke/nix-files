{ config, ... }:

{
  services.radvd = {
    enable = true;
    config = ''
      interface internet {
        AdvSendAdvert on;
        MaxRtrAdvInterval 15;
        AdvLinkMTU 1400;
        prefix 2a0f:5381:1:1::/64 {
          AdvRouterAddr on;
        };
        RDNSS 2606:4700:4700::1111 2606:4700:4700::1001 {};
      };
      interface internal {
        AdvSendAdvert on;
        MaxRtrAdvInterval 15;
        AdvLinkMTU 1400;
        prefix 2a0f:5381:1:2::/64 {
          AdvRouterAddr on;
        };
        RDNSS 2606:4700:4700::1111 2606:4700:4700::1001 {};
      };
    '';
  };
}
