#! /bin/bash
touch /etc/systemd/system/puma.service
chmod 664 /etc/systemd/system/puma.service
cat <<EOF> /etc/systemd/system/puma.service
[Unit]
Description=Puma server

[Service]
WorkingDirectory=/home/appuser/reddit
ExecStart=/usr/local/bin/puma

[Install]
WantedBy=multi-user.target
EOF
systemctl enable puma