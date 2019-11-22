#!/bin/bash
# C2O Backup Script

servers=(
	"SERVERNAME::SERVERIP"
	"SERVERNAME::SERVERIP"
	"SERVERNAME::SERVERIP"
)

downloadFiles () {

	echo "Downloading files... This could take a minute..."
	rsync -a "root@$2:/var/www/html" "$1"

	echo "Download complete."

}

uploadDatabaseScript () {

	echo "Uploading database script..."

	rsync "./db.sh" "root@$1:~/db.sh"

}

downloadDatabase () {

	uploadDatabaseScript $2

	echo "Zipping up database..."

	DB_NAME=$(ssh "root@$2" "./db.sh && exit")

	echo "Downloading database..."

	if [[ $DB_NAME == *"Access denied"* ]]; then
		echo "Authentication error in MySQL - skipping database"
	else
		rsync "root@$2:~/$DB_NAME" "$1"
	fi

}

backupServer () {

	DATE=$(date +%F)

	echo "Backing up server $1"
	sleep .5
	echo "Server IP is: $2"

	DIR="$1-$DATE"

	echo "Creating archive directory: $DIR"
	mkdir $DIR
	sleep .5

	downloadFiles $DIR $2
	downloadDatabase $DIR $2

}

echo "Servers to backup: ${#servers[@]}"

sleep 1.5

for index in "${servers[@]}"
do
	NAME="${index%%::*}"
	IP="${index##*::}"

	backupServer $NAME $IP
done

echo "We're done here..."