#!/bin/sh

sudo -u postgres psql pgapex < /vagrant/pgapex/evolutions/1_setup.sql
sudo -u postgres psql pgapex < /vagrant/pgapex/evolutions/2_create_tables.sql