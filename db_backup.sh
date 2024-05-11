#!/bin/sh

if [ -e .env ]; then
    #set -x
    . .env
fi

dateStr=`date -u +%FT%TZ00:00`
echo "Running DB Backup at ${dateStr}..."

if [ -n "$INFLUX_HOST" ] && [ -n "$INFLUX_ORG" ] && [ -n "$INFLUX_TOKEN" ] && [ -n "$DB_BACKUP_ROOT" ]; then
    influx ping >/dev/null 2>&1
    failedPing=$?

    if [[ $failedPing == 1 ]]; then
        echo "... Failed to ping Influx server at ${INFLUX_HOST}, stopping."
    else
        backupDest=$DB_BACKUP_ROOT/influx/${dateStr}
        mkdir -p $backupDest
        echo "... Influx backup to ${backupDest}"
        influx backup $INFLUX_BACKUP_EXTRA_OPTS $backupDest > ${backupDest}.log 2>&1
        backupRc=$?

        if [[ $backupRc == 0 ]]; then
            echo "... Influx backup successful, rotating backups"

            rotateCTime=7
            echo "... Backups older than ${rotateCTime} (deleted)"
            #find $DB_BACKUP_ROOT/influx -type d -maxdepth 1 -ctime ${rotateCTime} #-delete
            #find $DB_BACKUP_ROOT/influx -type d -maxdepth 1 -ctime ${rotateCTime} -delete
        else
            echo "... Influx backup failed with status ${backupRc}"
            rm -rf $backupDest
        fi
    fi
else
    echo "... Influx backup skipped, missing config (INFLUX_HOST: ${INFLUX_HOST}, INFLUX_ORG: ${INFLUX_ORG}, INFLUX_TOKEN: ${INFLUX_TOKEN}, DB_BACKUP_ROOT: ${DB_BACKUP_ROOT})"
fi

if [ -n "$MARIADB_USER" ] && [ -n "$MARIADB_PASS" ] && [ -n "$MARIADB_SERVER" ] && [ -n "$DB_BACKUP_ROOT" ]; then
    mariadb-admin -u $MARIADB_USER --password=$MARIADB_PASS -h $MARIADB_SERVER ping >/dev/null 2>&1
    failedPing=$?

    if [[ $failedPing == 1 ]]; then
        echo "... Failed to ping MariaDB server at ${MARIADB_SERVER}, stopping."
    else
        backupDest=$DB_BACKUP_ROOT/mariadb/${dateStr}
        mkdir -p $backupDest
        echo "... MariaDB backup to ${backupDest}"
        mariadb-dump -u $MARIADB_USER --password=$MARIADB_PASS -h $MARIADB_SERVER --all-databases 2>${backupDest}.log | gzip > $backupDest/db.sql.gz
        backupRc=$?

        if [[ $backupRc == 0 ]]; then
            echo "... MariaDB backup successful, rotating backups"

            rotateCTime=+10s
            echo "... Backups older than ${rotateCTime} (deleted)"
            #find $DB_BACKUP_ROOT/mariadb -type d -maxdepth 1 -ctime ${rotateCTime} #-delete
            #find $DB_BACKUP_ROOT/mariadb -type d -maxdepth 1 -ctime ${rotateCTime} -delete
        else
            echo "... MariaDB backup failed with status ${backupRc}"
            rm -rf $backupDest
        fi
    fi
else
    echo "... MariaDB backup skipped, missing config (MARIADB_USER: ${MARIADB_USER}, MARIADB_PASS: ${MARIADB_PASS}, MARIADB_SERVER: ${MARIADB_SERVER}, DB_BACKUP_ROOT: ${DB_BACKUP_ROOT})"
fi
