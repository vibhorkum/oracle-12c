#!/bin/bash
su oracle -c "sqlplus -s \"/as sysdba\" @/tmp/standby_scripts/primary_monitor.sql"
