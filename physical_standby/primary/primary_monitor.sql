ALTER SESSION SET nls_date_format='DD-MON-YYYY HH24:MI:SS';

ALTER SYSTEM SWITCH LOGFILE;

SELECT sequence#, first_time, next_time
FROM   v$archived_log
ORDER BY sequence#;
exit;
