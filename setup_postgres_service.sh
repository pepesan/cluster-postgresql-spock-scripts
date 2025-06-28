#!/bin/bash

# variables de configuración
source ./config.sh

set -euo pipefail

# servicio systemd
create_service_file() {
    echo "Creating systemd service file for PostgreSQL..."
    sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=PostgreSQL database server
After=network.target

[Service]
Type=forking
User=postgres
Group=postgres

ExecStart=${PG_CTL} start -D ${PGDATA} -l ${PGDATA}/logfile
ExecStop=${PG_CTL} stop -D ${PGDATA}
ExecReload=${PG_CTL} reload -D ${PGDATA}

Environment=PATH=${INSTALL_PREFIX}/bin:/usr/bin:/bin
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
}

enable_service() {
    echo "Reloading Systemd, enabling and starting PostgreSQL service..."
    sudo systemctl daemon-reexec
    sudo systemctl daemon-reload
    sudo systemctl enable postgresql
    sudo systemctl start postgresql
}


main() {
    create_service_file
    enable_service
    echo "✅ PostgreSQL Service configured and started successfully!"
}

main