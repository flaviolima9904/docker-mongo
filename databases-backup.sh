set -x

#Volume do backup no container docker
CONTAINER_FOLDER=/home/backup/

#Pasta local do backup
LOCAL_BACKUPFOLDER=$(dirname $0)/backup/

#Quantidade de dias que o backup ficará salvo
KEEP_DAY=1

#UID E GID do usuário local
# LOCAL_UID=$(id -u $USER)
# LOCAL_GID=$(id -g $USER)

#Local no servidor remoto para qual o backup será enviado
#ex: user@host:/backup
REMOTE_BACKUPFOLDER=null

#Email que receberá as notificações
RECIPIENT_EMAIL=null

#Caminho + Nome do backup 
GZFILE=$CONTAINER_FOLDER/mongo-backup-$(date +%d-%m-%Y_%H-%M-%S).gz

#Cria backup
if docker-compose exec mongo bash -c 'mongodump --gzip --archive='$GZFILE' --username $MONGO_INITDB_ROOT_USERNAME --password $MONGO_INITDB_ROOT_PASSWORD' ; then
   echo 'Backup criado'
else
   echo 'Não foi possível criar o backup '$GZFILE | mailx -s 'Erro ao criar backup MongoDB' $RECIPIENT_EMAIL
   exit
fi

#Remove backup antigo
find $LOCAL_BACKUPFOLDER -mtime +$KEEP_DAY -delete

#Envia para servidor remoto (Alterar porta ssh caso seja necessário)
if rsync -avP -e 'ssh -p 22' --delete $LOCAL_BACKUPFOLDER $REMOTE_BACKUPFOLDER ; then
   echo 'Backup sended'
else
   echo 'Não foi possível enviar o backup '$GZFILE | mailx -s 'Erro ao enviar backup MongoDB' $RECIPIENT_EMAIL
   exit
fi

#Envia email
echo $GZFILE | mailx -s 'Backup MongoDB Criado com sucesso' $RECIPIENT_EMAIL