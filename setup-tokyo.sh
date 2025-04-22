
#!/bin/bash

apt update && apt upgrade -y

wget https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.23.0/shadowsocks-v1.23.0.x86_64-unknown-linux-musl.tar.xz
tar -xf shadowsocks-v1.23.0.x86_64-unknown-linux-musl.tar.xz
cp ssserver /usr/local/bin/
chmod +x /usr/local/bin/ssserver

mkdir -p /etc/shadowsocks-rust
cat > /etc/shadowsocks-rust/config.json <<EOF
{
    "server": "::",
    "server_port": 3443,
    "method": "2022-blake3-aes-256-gcm",
    "password": "1MVEgwkmsRnQwYpzwyjOO+q4xOZUpNKu6LHQwSJDewo=",
    "mode": "tcp_and_udp"
}
EOF

cat > /etc/systemd/system/shadowsocks.service <<EOF
[Unit]
Description=Shadowsocks-Rust Server
After=network.target

[Service]
ExecStart=/usr/local/bin/ssserver -c /etc/shadowsocks-rust/config.json
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable shadowsocks --now

ufw allow 3443/tcp && ufw allow 3443/udp
iptables -I INPUT -p tcp --dport 3443 -j ACCEPT
iptables -I INPUT -p udp --dport 3443 -j ACCEPT
