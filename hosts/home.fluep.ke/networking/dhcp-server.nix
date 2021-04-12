{ ... }:

{
  services.dhcpd4 = {
    enable = true;
    interfaces = [ "internet" "guests" "enp2s0" ];
    extraConfig = ''
      option domain-name-servers 1.1.1.1, 9.9.9.9;
      option interface-mtu 1400;
      option path-mtu-aging-timeout 60;

      # Force sending of option interface-mtu (21 [hex 0x1A])
      if exists dhcp-parameter-request-list {
        option dhcp-parameter-request-list = concat(option dhcp-parameter-request-list,1a);
      }

      # default VLAN
      subnet 10.0.0.0 netmask 255.255.255.0 {
        range 10.0.0.100 10.0.0.200;
        option routers 10.0.0.1;
        option domain-name "intern.wifi.fluep.ke";
      }

      # internet VLAN
      subnet 45.158.40.0 netmask 255.255.255.128 {
        range 45.158.40.16 45.158.40.127;
        option routers 45.158.40.1;
        option domain-name "wifi.fluep.ke";
        option domain-search "wifi.fluep.ke";
        option broadcast-address 45.158.40.128;

        host fritzbox {
          hardware ethernet 44:4e:6d:07:a3:dc;
          fixed-address 45.158.40.2;
          option host-name "fritzbox";
        }
        host tradfri {
          hardware ethernet dc:ef:ca:ba:89:7d;
          fixed-address 45.158.40.3;
          option host-name "tradfri";
        }
        host nuki {
          hardware ethernet 24:62:ab:d0:e2:00;
          fixed-address 45.158.40.4;
          option host-name "nuki";
        }
        host sonos-bathroom {
          hardware ethernet 34:7e:5c:f8:3f:54;
          fixed-address 45.158.40.7;
          option host-name "sonos-bathroom";
        }
        host sonos-bedroom-left {
          hardware ethernet 34:7e:5c:ff:5b:28;
          fixed-address 45.158.40.5;
          option host-name "sonos-bedroom-left";
        }
        host sonos-bedroom-right {
          hardware ethernet 34:7e:5c:ff:5d:2c;
          fixed-address 45.158.40.6;
          option host-name "sonos-bedroom-right";
        }
        host apple-tv-bedroom {
          hardware ethernet 6c:4a:85:42:9d:d3;
          fixed-address 45.158.40.8;
          option host-name "apple-tv-bedroom.wifi.fluep.ke";
        }
        host lenovo {
          hardware ethernet 18:56:80:60:90:91;
          fixed-address 45.158.40.12;
          option host-name "lenovo.wifi.fluep.ke";
        }
        host homepod {
          hardware ethernet e0:2b:96:af:3d:30;
          fixed-address 45.158.40.9;
          option host-name "homepod";
        }
        host air-humidifier {
          hardware ethernet e4:23:54:17:9c:79;
          fixed-address 45.158.40.25;
          option host-name "air-humidifier";
        }
        host air-cleaner {
          hardware ethernet e4:23:54:10:d7:ab;
          fixed-address 45.158.40.23;
          option host-name "air-cleaner";
        }
      }

      # guests VLAN
      subnet 45.158.40.128 netmask 255.255.255.128 {
        option domain-name "guests.wifi.fluep.ke";
        option domain-search "guests.wifi.fluep.ke";

        range 45.158.40.130 45.158.40.254;
        option routers 45.158.40.129;
      }
    '';
  };
}
