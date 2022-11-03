export PORT=${PORT-8080}
export UUID=${UUID-c2d6b496656c4845a5a8e96c187eede5}
export PATH_vless=${PATH_vless-/vless/$UUID}
export PATH_trojan=${PATH_trojan-/trojan/$UUID}
export PATH_vmess=${PATH_vmess-/vmess/$UUID}
export PATH_shadowsocks=${PATH_shadowsocks-/shadowsocks/$UUID}

tar -xzvf html.tar.gz

chmod +x ./caddy
./caddy start

echo '
 {
    "log": {"loglevel": "warning"},
    "inbounds": [
        {
            "port": 4000,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "'$UUID'"
                    }
                ],
                "decryption": "none",
                "fallbacks": [
                    {
                        "path": "'${PATH_vless}'",
                        "dest": 4001
                    },{
                        "path": "'${PATH_trojan}'",
                        "dest": 4002
                    },{
                        "path": "'${PATH_vmess}'",
                        "dest": 4003
                    },{
                        "path": "'${PATH_shadowsocks}'",
                        "dest": 4004
                    }
                ]
            },
            "streamSettings": {
                "network": "tcp"
            }
        },{
            "port": 4001,
            "listen": "127.0.0.1",
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "'$UUID'"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "security": "none",
                "wsSettings": {
                    "path": "'${PATH_vless}'"
                }
            }
        },{
            "port": 4002,
            "listen": "127.0.0.1",
            "protocol": "trojan",
            "settings": {
                "clients": [
                    {
                        "password": "'$UUID'"
                    }
                ]
            },
            "streamSettings": {
                "network": "ws",
                "security": "none",
                "wsSettings": {
                    "path": "'${PATH_trojan}'"
                }
            }
        },{
            "port": 4003,
            "listen": "127.0.0.1",
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "'$UUID'"
                    }
                ]
            },
            "streamSettings": {
                "network": "ws",
                "security": "none",
                "wsSettings": {
                    "path": "'${PATH_vmess}'"
                }
            }
        },{
          "port": 4004,
          "protocol": "shadowsocks",
          "settings": {
            "method": "2022-blake3-aes-128-gcm",
            "password": "'$UUID'",
            "network": "tcp,udp"
          },
          "streamSettings": {
            "network": "ws",
            "security": "none",
            "wsSettings": {
                "path": "'${PATH_shadowsocks}'"
            }
          }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom"
        }
    ]
}
' > conf.json
chmod +x ./xy
./xy -config=conf.json
