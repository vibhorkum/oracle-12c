#!/bin/bash
PRIMARY_SERVER=primary_oracle
STANDBY_SERVER=standby_oracle

docker exec -it ${PRIMARY_SERVER} /bin/mkdir -p /u01/app/oracle/fast_recovery_area/ORCL/logical
docker exec -it ${PRIMARY_SERVER} chown -R oracle:oinstall /u01/app/oracle/fast_recovery_area/ORCL/logical
docker exec -it ${PRIMARY_SERVER} /bin/mkdir -p /tmp/logical
docker cp logical/primary_logical.sql ${PRIMARY_SERVER}:/tmp/logical
docker exec -it ${PRIMARY_SERVER} chown -R oracle:oinstall /tmp/logical

docker exec -it ${STANDBY_SERVER} /bin/mkdir -p /u01/app/oracle/fast_recovery_area/ORCL_STBY/logical
docker exec -it ${STANDBY_SERVER} chown -R oracle:oinstall /u01/app/oracle/fast_recovery_area/ORCL_STBY/logical
docker exec -it ${STANDBY_SERVER} /bin/mkdir -p /tmp/logical
docker cp  logical/logical_standby.sql ${STANDBY_SERVER}:/tmp/logical
docker cp  logical/logical_standby2.sql ${STANDBY_SERVER}:/tmp/logical
docker exec -it ${STANDBY_SERVER} chown -R oracle:oinstall /tmp/logical

docker exec -it ${STANDBY_SERVER} /bin/su oracle -c "sqlplus -s \"/as sysdba\" @/tmp/logical/logical_standby.sql"
docker exec -it ${PRIMARY_SERVER} /bin/su oracle -c "sqlplus -s \"/as sysdba\" @/tmp/logical/primary_logical.sql"
docker exec -it ${STANDBY_SERVER} /bin/su oracle -c "sqlplus -s \"/as sysdba\" @/tmp/logical/logical_standby2.sql"

