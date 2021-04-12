# Flüpke's nix-files

## Home network
**VLANS**:
* native
  * IPv6: fdc1:f5e0:7c67::/48
    * fdc1:f5e0:7c67::1 home
  * IPv4: 10.0.0.0/24
    * 10.0.0.1 home
    * 10.0.0.2 switch-01
* `42`: Internet
* `23`: Guests
* `420`: WAN

Switch
| VLAN | Port 1 | Port 2 | Port 3 | Port 4 | Port 5 |
|:----:|:------:|:------:|:------:|:------:|:------:|
| PVID |   42   |   42   |    1   |    1   |   420  |
|   1  |    -   |    -   |  Untag |  Untag |    -   |
|  23  |    -   |    -   |   Tag  |   Tag  |    -   |
|  42  |  Untag |  Untag |   Tag  |   Tag  |    -   |
|  420 |    -   |    -   |   Tag  |   Tag  |  Untag |

## NixOs installation instructions
> For UEFI, with a swap partition

```bash
# partitioning
sudo sgdisk \
  -o \
  -n 1::+1M \
  -n 2::+512M \
  -n 3::+8G \
  -n 4:: \
  -t 1:ef02 \
  -t 2:ef00 \
  -t 3:8300 \
  /dev/nvme0n1
# filesystems
sudo mkfs.fat -F 32 -n boot /dev/nvme0n1p2
sudo mkfs.ext2 -L boot /dev/nvme0n1p2
sudo cryptsetup luksFormat /dev/nvme0n1p3
sudo cryptsetup luksOpen /dev/nvme0n1p3
sudo mkfs.xfs -m reflink=1 -L nixos /dev/mapper/crypto
sudo mount /dev/disk/by-label/nixos /mnt/
sudo mkdir /mnt/boot
sudo mount /dev/disk/by-label/boot /mnt/boot/

# key material for initrd
sudo mkdir -p /var/src/secrets/initrd /mnt/var/src/secrets/initrd
sudo ssh-keygen -t ed25519 -f /var/src/secrets/initrd/ed25519-hostkey
sudo cp /var/src/secrets/initrd/ed25519-hostkey /mnt/var/src/secrets/initrd/ed25519-hostkey

# nixos installation
sudo nixos-generate-config --root /mnt
sudo vim /mnt/etc/nixos/configuration.nix # see minimal-setup.nix
sudo nixos-install

# fingers crossed 🤞
sudo reboot
```

