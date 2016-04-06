![CI build](https://travis-ci.org/raitraidma/pgapex.svg)

pgApex
======

Prerequisites
-------------
* Install Oracle VirtualBox 5.0.16 or greater (https://www.virtualbox.org/wiki/Downloads)
* Install Vagrant 1.8.1 or greater (https://www.vagrantup.com/downloads.html)
* Install Putty (http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html)

Windows host (vagrant < 1.7.3)
------------------------------
To enable longer paths than 260 chars:
* Open C:\HashiCorp\Vagrant\embedded\gems\gems\vagrant-1.7.2\plugins\providers\virtualbox\driver\version_4_3.rb
(Path may vary)
* Find method 'share_folders' (lines 495-510)
* Relpace:
`folder[:hostpath]]`
with
`'\\\\?\\' + folder[:hostpath].gsub(/[\/\\]/,'\\')]`

Start VM
--------
* Open command line as Administrator
* Go to the folder where is Vagrantfile
* Run command: `vagrant up`

Access VM
---------
* Log into the VM, open Putty
  * Host name: localhost
  * Port: 2222
  * Press Open button
  * Username: vagrant
  * Password: vagrant

Shared folder is in /vagrant directory:
  `cd /vagrant`

Access UI
---------
http://localhost:8000

Stop VM
-------
* Open command line
* Go to the folder where is Vagrantfile
* Run command: `vagrant halt`

Run tests in VM
---------------
* Go to /vagrant folder: `cd /vagrant`
* Run tests once: `npm run test-single-run`
* Run tests when code changes: `npm run test`

CI
--
* https://travis-ci.org/
* `deploy.sh` (`SERVER_PASSWORD` and `SERVER_USER_HOST` are variables defined in repository settings)