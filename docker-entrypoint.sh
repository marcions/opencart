#!/bin/bash
set -e

cd /var/www/html

if [ ! -f install.lock ] && [ -f install/cli_install.php ]; then
  cp config-dist.php config.php 2>/dev/null || true
  cp admin/config-dist.php admin/config.php 2>/dev/null || true
  
  for i in 1 2 3 4 5 6 7 8 9 10; do
    if php install/cli_install.php install       --username "${OPENCART_USERNAME:-admin}"       --password "${OPENCART_PASSWORD:-admin}"       --email "${OPENCART_ADMIN_EMAIL:-admin@example.com}"       --http_server "${OPENCART_HTTP_SERVER:-http://localhost/}"       --db_driver "${DB_DRIVER:-mysqli}"       --db_hostname "${DB_HOSTNAME:-mysql}"       --db_username "${DB_USERNAME:-opencart}"       --db_password "${DB_PASSWORD:-opencart}"       --db_database "${DB_DATABASE:-opencart}"       --db_port "${DB_PORT:-3306}"       --db_prefix "${DB_PREFIX:-oc_}"; then
      touch install.lock
      echo 'OpenCart installed!'
      break
    else
      echo "Install attempt $i failed, retrying in 5s..."
      sleep 5
    fi
  done
fi

chown -R www-data:www-data /var/www/html /storage 2>/dev/null || true

exec apache2-foreground
