TIMESTAMP=$( date +"%Y-%m-%d-%H-%M-%S")
DEPLOY_ROOT="/usr/local/apache2/htdocs/t143682/stage"
DEPLOY_DIR="$DEPLOY_ROOT/$TIMESTAMP"
DESTINATION_DIR="/usr/local/apache2/htdocs/t143682/pgapex"
git clone --depth=5 --branch=master https://github.com/raitraidma/pgapex.git ~/deploy/pgapex
cd ~/deploy/pgapex
npm install --unsafe-perm
zip -r "pgapex-$TIMESTAMP.zip" ./pgapex/
sshpass -p $SERVER_PASSWORD ssh -o "StrictHostKeyChecking no" -p 22 $SERVER_USER_HOST -P "mkdir -p $DEPLOY_DIR"
sshpass -p $SERVER_PASSWORD scp -P 22 -rp ~/deploy/pgapex/pgapex-$TIMESTAMP.zip $SERVER_USER_HOST:$DEPLOY_DIR
sshpass -p $SERVER_PASSWORD ssh -o "StrictHostKeyChecking no" -p 22 $SERVER_USER_HOST -P "(cd $DEPLOY_DIR && unzip pgapex-$TIMESTAMP.zip)"
sshpass -p $SERVER_PASSWORD ssh -o "StrictHostKeyChecking no" -p 22 $SERVER_USER_HOST -P "(unlink $DESTINATION_DIR; ln -fs $DEPLOY_DIR/pgapex/public $DESTINATION_DIR)"