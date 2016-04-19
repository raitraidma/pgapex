#!/bin/bash
echo "Starting deployment"

echo "Set env variables"
TIMESTAMP=$( date +"%Y-%m-%d-%H-%M-%S")
DEPLOY_ROOT="/usr/local/apache2/htdocs/t143682/stage"
DEPLOY_DIR="$DEPLOY_ROOT/$TIMESTAMP"
DESTINATION_DIR="/usr/local/apache2/htdocs/t143682/pgapex"

echo "Create package"
git clone --depth=5 --branch=master https://github.com/raitraidma/pgapex.git ~/deploy/pgapex
cd ~/deploy/pgapex
npm install --unsafe-perm
composer install --no-dev
rm -rf ~/deploy/pgapex/pgapex/tests
zip -r "pgapex-$TIMESTAMP.zip" ./pgapex/

echo "Deploy package"
sshpass -p $SERVER_PASSWORD ssh -o "StrictHostKeyChecking no" -p 22 $SERVER_USER_HOST -P "mkdir -p $DEPLOY_DIR"
sshpass -p $SERVER_PASSWORD scp -P 22 -rp ~/deploy/pgapex/pgapex-$TIMESTAMP.zip $SERVER_USER_HOST:$DEPLOY_DIR
sshpass -p $SERVER_PASSWORD ssh -o "StrictHostKeyChecking no" -p 22 $SERVER_USER_HOST -P "(cd $DEPLOY_DIR && unzip pgapex-$TIMESTAMP.zip)"
sshpass -p $SERVER_PASSWORD ssh -o "StrictHostKeyChecking no" -p 22 $SERVER_USER_HOST -P "(unlink $DESTINATION_DIR; ln -fs $DEPLOY_DIR/pgapex/public $DESTINATION_DIR)"

echo "Delete 14 days old versions"
sshpass -p $SERVER_PASSWORD ssh -o "StrictHostKeyChecking no" -p 22 $SERVER_USER_HOST -P "find $DEPLOY_ROOT/* -maxdepth 0 -type d -ctime +14 | xargs rm -rf"

echo "Deployed successfully"
exit 0