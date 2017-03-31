#!/bin/bash
echo "
ORCL =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = $1 )(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = ORCL)
    )
  )

ORCL_STBY =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = $2 )(PORT = 1521))
    )
    (CONNECT_DATA =
      (SID = ORCL)
    )
  )" >tnsnames.ora
