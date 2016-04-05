#!/bin/sh

PROJECT="pgapex"
DB_NAME="pgapex"
POSTGRESQL_VERSION="9.4"

# PHP
add-apt-repository -y ppa:ondrej/php5-5.6

#PostgreSQL
add-apt-repository "deb https://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main"
wget --quiet -O - https://postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - 

apt-get update

# Install apache and create/link folders
apt-get install -y apache2
rm -rf /var/www/html
mkdir -p "/vagrant/$PROJECT/public"
ln -fs "/vagrant/$PROJECT/public" /var/www/html

# Install PHP5 and modules
apt-get install -y php5
apt-get install -y libapache2-mod-php5
apt-get install -y php5-pgsql

# Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# PHPunit
wget https://phar.phpunit.de/phpunit.phar
chmod +x phpunit.phar
mv phpunit.phar /usr/local/bin/phpunit

# GIT
apt-get install -y git

# Nodejs
curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
apt-get install -y nodejs

# Bower
npm install -g bower

# Postgresql (postgres:postgres)
apt-get install -y postgresql-$POSTGRESQL_VERSION postgresql-contrib-$POSTGRESQL_VERSION postgresql-client-$POSTGRESQL_VERSION
sudo -u postgres psql -U postgres -d postgres -c "alter user postgres with password 'postgres';"

# Set estonian locale
locale-gen et_EE
locale-gen et_EE.UTF-8
update-locale
dpkg-reconfigure locales
sed -i -- 's/en_US/et_EE/g' /etc/default/locale
. /etc/default/locale

# Allow access to PostgreSQL from outside (For DEV only!)
echo "host all all 0.0.0.0/0 trust" | tee -a "/etc/postgresql/$POSTGRESQL_VERSION/main/pg_hba.conf"
echo "listen_addresses='*'" | tee -a "/etc/postgresql/$POSTGRESQL_VERSION/main/postgresql.conf"

# Restart services
service apache2 restart
sudo -u postgres service postgresql restart

# Create database to Postgresql
sudo -u postgres createdb -E UTF8 -l et_EE.utf-8 -T template0 "$DB_NAME"

# swap
# Composer shows proc_open() fork failed on some commands
# This could be happening because the VPS runs out of memory and has no Swap space enabled.
# Enable the swap:
/bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
/sbin/mkswap /var/swap.1
/sbin/swapon /var/swap.1


# For PhantomJS
apt-get install -y libfontconfig

# Install dependencies
cd /vagrant
npm install
bower install --allow-root
