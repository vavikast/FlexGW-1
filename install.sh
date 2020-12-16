#!/bin/bash
wget https://github.com/Ostaer/FlexGW/releases/download/v1.1/flexgw-1.1.0-1.el7.centos.x86_64.rpm
sysctl -a | egrep "ipv4.*(accept|send)_redirects" | awk -F "=" '{print $1"= 0"}' >> /etc/sysctl.conf
sed -i 's/^net.ipv4.ip_forward.*//g' /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1">> /etc/sysctl.conf
sysctl -p
yum makecache fast
yum install -y strongswan openvpn zip curl wget
rpm -ivh flexgw-1.1.0-1.el7.centos.x86_64.rpm
cat >  /usr/local/flexgw/rc/strongswan.conf <<EOF
charon {
    filelog {
        charon {
            path = /var/log/strongswan.charon.log
            time_format = % b % e % T
            ike_name = yes
            append = no
            default = 1
            flush_line = yes
        }
    }
    plugins {
        include strongswan.d/charon/*.conf
        duplicheck {
            enable = yes
        }
    }
}
EOF
sed -i  's/load/#load/g' /etc/strongswan/strongswan.d/charon/dhcp.conf
> /etc/strongswan/ipsec.secrets
/etc/init.d/initflexgw 

