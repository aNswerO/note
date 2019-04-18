#!/bin/bash
cd /etc/pki/CA
[ -f index.txt ] || touch index.txt
[ -f serial ] || echo 01 > serial
umask 077;openssl genrsa -out private/cakey.pem 4096
expect <<EOF
spawn openssl req -new -x509 -key /etc/pki/CA/private/cakey.pem -days 3650 -out /etc/pki/CA/cacert.pem
expect {
        "XX" {send "cn\n";exp_continue}
        "Province" {send "beijing\n";exp_continue}
        "Locality" {send "beijing\n";exp_continue}
        "Organization" {send "magedu\n";exp_continue}
        "Unit" {send "magedu\n";exp_continue}
        "Common" {send "qyh\n";exp_continue}
        "Email" {send "qyh@163.com\n"}
}
expect eof
EOF
