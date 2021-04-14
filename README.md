# SETUP

## run and log

- run manually
  - `$docker run -v "$HOME/Pen_Test/log/:/tmp/logging/" -v "$HOME/Pen_Test/docs/:/tmp/docs/" -it mvladislav/pen-testing:latest /bin/zsh`
  - description
    - `"$HOME/Pen_Test/log/:/tmp/logging/"`
      > docker will start with `script` where the logs will saved in the docker runtime under `/tmp/logging/`
    - `"$HOME/Pen_Test/docs/:/tmp/docs/"`
      > you can use this to transfer relevant files between docker runtime and host to save results from commands/services
- replay log files
  - `$scriptreplay $HOME/Pen_Test/log/<filename>.time $HOME/Pen_Test/log/<filename>.log -m0`

### relevant folders

- `/root/toolkit`
- `/root/wordlists`
- `/pentest`

## create `.env` file following:

```env
NODE_ID=
NODE_ROLE=manager
NETWORK_MODE=overlay

VERSION=latest
PORT=8080
```

## VPN tooling on host

> route all internal addresses on internal interface to access internal services

```sh
$sudo ip route flush table main
$sudo ip route flush cached
$sudo ip route add 10.0.0.0/8 dev eth0
$sudo ip route add 172.16.0.0/16 dev eth0
$sudo ip route add 192.168.0.0/16 dev eth0

$sudo ip route add default dev eth1

$sudo ip route flush table main
$sudo service network-manager restart
```

> TODO: test with `netplan`

```yml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: True
      dhcp4-overrides:
        use-routes: false
      dhcp6: False
      link-local: []
      nameservers:
        addresses:
          - 192.168.1.1
      routes:
        - to: 10.0.0.0/8
          metric: 43
          table: 400
        - to: 172.16.0.0/16
          metric: 42
          table: 400
        - to: 192.168.0.0/16
          metric: 41
          table: 400
    eth1:
      dhcp4: True
      dhcp4-overrides:
        use-routes: false
      dhcp6: False
      link-local: []
      nameservers:
        addresses:
          - 192.168.1.1
      routes:
        - to: 0.0.0.0/0
          metric: 50
          table: 200
```

> add and active VPN over console (`$nmcli connection import type openvpn file <filename>`)

```sh
$find . -type f -name "*protonvpn*.ovpn" -exec bash -c "grep -q '^auth-user-pass' '{}' && sed -i 's/^auth-user-pass.*/auth-user-pass pass\.conf/' '{}' || echo 'auth-user-pass pass.conf' >> '{}'" \;
$find . -type f -name "*protonvpn*udp*.ovpn" -exec bash -c 'nmcli connection import type openvpn file "{}"' \;
$find . -type f -name "*priv_tunnel*.ovpn" -exec bash -c 'nmcli connection import type openvpn file "{}"' \;

$nmcli connection show
$nmcli connection up <vpn connection name>
```

### VPN - OPENVPN

- `$openvpn --config <file> --auth-user-pass pass.txt`

#### add config to --config file

```vpn
# The following is added only in the config for Ubuntu 20.04
dhcp-option DOMAIN 1.1.1.1
script-security 2
up /etc/openvpn/update-resolv-conf
up-restart
down /etc/openvpn/update-resolv-conf
down-pre
```

## Info

1. Passive Information Gathering
1. Active Information Gathering
1. Vulnerability Scanning
1. Web Application Attacks
1. Introduction to Buffer Overflows
1. Windows Buffer Overflows
1. Linux Buffer Overflows
1. Client-Side Attacks
1. Locating Public Exploits
1. Fixing Exploits
1. File Transfers
1. Antivirus Evasion

## References

- <https://hub.docker.com/r/hackersploit/bugbountytoolkit>
- <https://hub.docker.com/r/axiom/docker-pycsw>
- <https://github.com/axiom-data-science/docker-pycsw>
- <https://github.com/pry0cc/axiom>
