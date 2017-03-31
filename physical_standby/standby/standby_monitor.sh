#!/bin/bash
su oracle -c "sqlplus -s \"/as sysdba\" @/tmp/standby_scripts/standby_monitor.sql"
