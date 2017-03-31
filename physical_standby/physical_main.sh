#!/bin/bash
PRIMARY_SERVER=primary_oracle
STANDBY_SERVER=standby_oracle

docker exec -it ${PRIMARY_SERVER} yum install net-tools vim file -y
docker exec -it ${STANDBY_SERVER} yum install net-tools vim file -y
PRIMARY_IP=$(docker exec -it ${PRIMARY_SERVER} /sbin/ifconfig -a|grep 172|awk '{print $2}')
STANDBY_IP=$(docker exec -it ${STANDBY_SERVER} /sbin/ifconfig -a|grep 172|awk '{print $2}')

./update_tnsnames_ora.sh ${PRIMARY_IP} ${STANDBY_IP}

docker exec -it ${PRIMARY_SERVER} /bin/mkdir -p /tmp/standby_scripts 
docker exec -it ${PRIMARY_SERVER} /bin/mkdir -p /tmp/primary_backups
docker exec -it ${PRIMARY_SERVER} chown oracle:oinstall /tmp/primary_backups

docker cp primary/primary_step.sql ${PRIMARY_SERVER}:/tmp/standby_scripts
docker cp tnsnames.ora ${PRIMARY_SERVER}:/tmp/standby_scripts
docker cp primary/rman_backup.rman  ${PRIMARY_SERVER}:/tmp/standby_scripts
docker cp primary/control_spfile.sql  ${PRIMARY_SERVER}:/tmp/standby_scripts
docker cp primary/standby_logfile.sql ${PRIMARY_SERVER}:/tmp/standby_scripts
docker cp primary/restartdb.sql ${PRIMARY_SERVER}:/tmp/standby_scripts
docker cp primary/primary_monitor.sql ${PRIMARY_SERVER}:/tmp/standby_scripts
docker cp primary/physical_monitor.sh ${PRIMARY_SERVER}:/tmp/standby_scripts
docker cp primary/create_user.sql ${PRIMARY_SERVER}:/tmp/standby_scripts
docker cp primary/sample_table.sql ${PRIMARY_SERVER}:/tmp/standby_scripts
docker cp primary/glogin.sql ${PRIMARY_SERVER}:/u01/app/oracle/product/12.1.0/dbhome_1/sqlplus/admin
docker exec -it ${PRIMARY_SERVER} chown -R oracle:oinstall /u01/app/oracle/product/12.1.0/dbhome_1/sqlplus/admin
docker exec -it ${PRIMARY_SERVER} chown -R oracle:oinstall /tmp/standby_scripts
docker exec -it ${PRIMARY_SERVER} chown -R oracle:oinstall /tmp/primary_backups

docker exec -it ${PRIMARY_SERVER} /bin/su oracle -c "sqlplus -s \"/as sysdba\" @/tmp/standby_scripts/primary_step.sql"
docker exec -it ${PRIMARY_SERVER} su oracle -c "rman target=/ cmdfile=/tmp/standby_scripts/rman_backup.rman"
docker exec -it ${PRIMARY_SERVER} su oracle -c "cp /tmp/standby_scripts/tnsnames.ora /u01/app/oracle/product/12.1.0/dbhome_1/network/admin"
docker exec -it ${PRIMARY_SERVER} /bin/su oracle -c "sqlplus -s \"/as sysdba\" @/tmp/standby_scripts/control_spfile.sql"
docker exec -it ${PRIMARY_SERVER} /bin/su oracle -c "echo \"\*.db_unique_name='ORCL_STBY'\" >>/tmp/primary_backups/initORCL_stby.ora"

mkdir -p ${PRIMARY_SERVER}_backups
docker cp ${PRIMARY_SERVER}:/u01/app/oracle/fast_recovery_area/ORCL/backupset ${PRIMARY_SERVER}_backups
docker cp ${PRIMARY_SERVER}:/u01/app/oracle/fast_recovery_area/ORCL/archivelog ${PRIMARY_SERVER}_backups
docker cp ${PRIMARY_SERVER}:/tmp/primary_backups/initORCL_stby.ora ${PRIMARY_SERVER}_backups
docker cp ${PRIMARY_SERVER}:/tmp/primary_backups/ORCL_stby.ctl ${PRIMARY_SERVER}_backups
docker cp ${PRIMARY_SERVER}:/u01/app/oracle/product/12.1.0/dbhome_1/dbs/orapwORCL ${PRIMARY_SERVER}_backups

docker cp ${PRIMARY_SERVER}_backups/orapwORCL ${STANDBY_SERVER}:/u01/app/oracle/product/12.1.0/dbhome_1/dbs/
docker cp ${PRIMARY_SERVER}_backups/backupset ${STANDBY_SERVER}:/u01/app/oracle/fast_recovery_area/ORCL/
docker cp ${PRIMARY_SERVER}_backups/archivelog ${STANDBY_SERVER}:/u01/app/oracle/fast_recovery_area/ORCL/
docker exec -it ${STANDBY_SERVER} chown -R oracle:oinstall /u01/app/oracle/fast_recovery_area/ORCL/
docker exec -it ${STANDBY_SERVER} chown -R oracle:oinstall /u01/app/oracle/product/12.1.0/dbhome_1/dbs/
sed -i 's/SERVICE=ORCL_STBY NOAFFIRM ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=ORCL_STBY/SERVICE=ORCL NOAFFIRM ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=ORCL/g' ${PRIMARY_SERVER}_backups/initORCL_stby.ora
sed -i 's/\\//g'  ${PRIMARY_SERVER}_backups/initORCL_stby.ora

docker exec -it ${STANDBY_SERVER} /bin/mkdir -p /tmp/standby_scripts 
docker exec -it ${STANDBY_SERVER} /bin/mkdir -p /tmp/primary_backups
docker cp ${PRIMARY_SERVER}_backups/initORCL_stby.ora ${STANDBY_SERVER}:/tmp/primary_backups
docker cp ${PRIMARY_SERVER}_backups/ORCL_stby.ctl ${STANDBY_SERVER}:/tmp/primary_backups
docker cp tnsnames.ora ${STANDBY_SERVER}:/tmp/primary_backups
docker cp standby/standby_spfile.sql ${STANDBY_SERVER}:/tmp/standby_scripts
docker cp standby/rman_standby_restore.rman ${STANDBY_SERVER}:/tmp/standby_scripts
docker cp standby/standby_monitor.sql ${STANDBY_SERVER}:/tmp/standby_scripts
docker cp standby/standby_monitor.sh ${STANDBY_SERVER}:/tmp/standby_scripts
docker cp standby/standby_file_management.sql ${STANDBY_SERVER}:/tmp/standby_scripts
docker exec -it ${STANDBY_SERVER} chown -R oracle:oinstall /tmp/primary_backups
docker cp standby/glogin.sql ${STANDBY_SERVER}:/u01/app/oracle/product/12.1.0/dbhome_1/sqlplus/admin
docker exec -it ${STANDBY_SERVER} chown -R oracle:oinstall /u01/app/oracle/product/12.1.0/dbhome_1/sqlplus/admin

docker exec -it ${STANDBY_SERVER} /bin/su oracle -c "sqlplus -s \"/as sysdba\" @/tmp/standby_scripts/standby_spfile.sql"
docker exec -it ${STANDBY_SERVER} /bin/su oracle -c "cp /tmp/primary_backups/ORCL_stby.ctl /u01/app/oracle/oradata/ORCL/controlfile/o1_mf_d757kwbn_.ctl"
docker exec -it ${STANDBY_SERVER} /bin/su oracle -c "cp /tmp/primary_backups/ORCL_stby.ctl /u01/app/oracle/fast_recovery_area/ORCL/controlfile/o1_mf_d757kwd8_.ctl"
docker exec -it ${STANDBY_SERVER} /bin/su oracle -c "cp /tmp/primary_backups/tnsnames.ora  /u01/app/oracle/product/12.1.0/dbhome_1/network/admin"
docker exec -it ${STANDBY_SERVER} su oracle -c "rman target=/ cmdfile=/tmp/standby_scripts/rman_standby_restore.rman"
docker exec -it ${STANDBY_SERVER} /bin/su oracle -c "sqlplus -s \"/as sysdba\" @/tmp/standby_scripts/standby_file_management.sql"

docker exec -it ${PRIMARY_SERVER} /bin/su oracle -c "sqlplus -s \"/as sysdba\" @/tmp/standby_scripts/standby_logfile.sql"
docker exec -it ${PRIMARY_SERVER} /bin/su oracle -c "sqlplus -s \"/as sysdba\" @/tmp/standby_scripts/restartdb.sql"
docker exec -it ${PRIMARY_SERVER} /bin/su oracle -c "sqlplus -s \"/as sysdba\" @/tmp/standby_scripts/create_user.sql"
docker exec -it ${PRIMARY_SERVER} /bin/su oracle -c "sqlplus -s replication/oracle @/tmp/standby_scripts/sample_table.sql"


