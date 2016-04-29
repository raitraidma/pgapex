#!/bin/sh

sudo -u postgres psql pgapex < /vagrant/pgapex/evolutions/1_setup.sql
sudo -u postgres psql pgapex < /vagrant/pgapex/evolutions/2_create_tables.sql
sudo -u postgres psql pgapex < /vagrant/pgapex/evolutions/3_create_materialized_view_functions.sql
sudo -u postgres psql pgapex < /vagrant/pgapex/evolutions/4_create_materialized_views.sql
sudo -u postgres psql pgapex < /vagrant/pgapex/evolutions/5_create_functions.sql
sudo -u postgres psql pgapex < /vagrant/pgapex/evolutions/5_2_create_app_functions.sql
sudo -u postgres psql pgapex < /vagrant/pgapex/evolutions/6_create_triggers.sql
sudo -u postgres psql pgapex < /vagrant/pgapex/evolutions/7_insert_classifiers.sql
sudo -u postgres psql --variable=DB_DATABASE=pgapex --variable=DB_APP_USER=pgapex_app --variable=DB_APP_USER_PASS=pgapex_app pgapex < /vagrant/pgapex/evolutions/8_share_permissions.sql
sudo -u postgres psql pgapex < /vagrant/pgapex/evolutions/9_templates.sql