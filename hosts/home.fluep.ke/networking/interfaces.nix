{ ... }:

{
  networking.useDHCP = false;

  networking.interfaces.enp2s0 = {
    ipv6.addresses = [{
      address = "fdc1:f5e0:7c67::1";
      prefixLength = 48;
    }];
    ipv4.addresses = [{
      address = "10.0.0.1";
      prefixLength = 24;
    }];
  };

  networking.interfaces.internet = {
    ipv6.addresses = [{
      address = "2a0f:5381:1:1::1";
      prefixLength = 64;
    }];
    ipv4.addresses = [{
      address = "45.158.40.1";
      prefixLength = 25;
    }];
  };

  networking.interfaces.guests = {
    ipv6.addresses = [{
      address = "2a0f:5381:1:2::1";
      prefixLength = 64;
    }];
    ipv4.addresses = [{
      address = "45.158.40.129";
      prefixLength = 25;
    }];
  };

  networking.interfaces.wan = {
    # TODO switch to vodafone business plan for static IP
    useDHCP = true;
  };
}
