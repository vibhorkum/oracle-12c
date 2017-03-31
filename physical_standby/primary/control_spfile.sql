ALTER DATABASE CREATE STANDBY CONTROLFILE AS '/tmp/primary_backups/ORCL_stby.ctl';
CREATE PFILE='/tmp/primary_backups/initORCL_stby.ora' FROM SPFILE;
exit;

