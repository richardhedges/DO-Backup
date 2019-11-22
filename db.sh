#!/bin/bash
# Database Dump Script

MYSQL_USERNAME="root"
MYSQL_PASSWORDS=(
	"PASSWORD1"
	"PASSWORD2"
)

IGNORE_DB="(^mysql|_schema|phpmyadmin$)"
MYSQL_LOGIN=""

PATH=$PATH:/usr/local/mysql/bin

TIMESTAMP=$(date +%F)

database_list () {
	local show_databases_sql="SHOW DATABASES WHERE \`Database\` NOT REGEXP '$IGNORE_DB'"
	echo $(mysql $MYSQL_LOGIN -e "$show_databases_sql"|awk -F " " '{if (NR!=1) print $1}')
}

backup_database () {
	$(mysqldump $MYSQL_LOGIN $database | gzip -9 > $BACKUP_FILE)
}

backup_databases () {

	MYSQL_LOGIN="-u $MYSQL_USERNAME -p${MYSQL_PASSWORDS[0]}"

	local databases=$(database_list)

	if [[ $database == *"Access denied"* ]]; then

		MYSQL_LOGIN="-u $MYSQL_USERNAME -p${MYSQL_PASSWORDS[1]}"
		
		local databases=$(database_list)

		if [[ $database == *"Access denied"* ]]; then
			echo "Access denied"
			exit 1
		fi

	fi

	local total=$(echo $databases | wc -w | xargs)
	local count=1

	for database in $databases; do
		BACKUP_FILE="$TIMESTAMP.$database.sql.gz"
		backup_database
		local count=$((count+1))
	done

	echo $BACKUP_FILE

}

backup_databases