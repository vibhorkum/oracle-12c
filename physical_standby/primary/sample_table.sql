CREATE TABLE replication_table(id NUMBER(10,0),
                               col VARCHAR2(90));
INSERT INTO replication_table VALUES(1,'FIRST');
INSERT INTO replication_table VALUES(2,'SECOND');
INSERT INTO replication_table VALUES(3,'THIRD');
INSERT INTO replication_table VALUES(4,'FOURTH');
INSERT INTO replication_table VALUES(5,'FIFTH');
INSERT INTO replication_table VALUES(6,'SIXTH');
INSERT INTO replication_table VALUES(7,'SEVENTH');
INSERT INTO replication_table VALUES(8,'EIGHTH');
INSERT INTO replication_table VALUES(9,'NINTH');
INSERT INTO replication_table VALUES(10,'TENTH');
COMMIT;
ALTER TABLE replication_table ADD PRIMARY KEY (id) RELY DISABLE;
EXIT;
