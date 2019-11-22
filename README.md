# DO-Backup
Backup Digital Ocean server web files and databases

This script was written for a very specific use case. Run `./script.sh` to run the script.

Make sure you add your server IPs to `script.sh` and your MySQL passwords to `db.sh`. The script allows 2 mysql passwords and uses the root user - feel free to make adjustments to make it more dynamic, i.e. marry up mysql credentials with servers?
Obviously it would also be a good idea to not use the root user when connecting via SSH.

The script utilises rsync to download web files from the `var/www/html` directory and then uploads the db.sh file to the server to create a MySQL dump, which is also then downloaded with rsync.
