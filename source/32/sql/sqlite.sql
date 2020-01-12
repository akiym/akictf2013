CREATE TABLE message (id INTEGER NOT NULL PRIMARY KEY, body VARCHAR);
BEGIN;
    INSERT INTO message VALUES (1, 'do you want a hint?');
    INSERT INTO message VALUES (2, 'it is no meaning.');
    INSERT INTO message VALUES (3, 'what you may call it.');
    INSERT INTO message VALUES (4, 'simple sqli is literally simple :)');
    INSERT INTO message VALUES (5, 'sqli is sql injeciton.');
END;

CREATE TABLE flag (key CHAR);
CREATE TABLE flog (key CHAR);
CREATE TABLE frig (key CHAR);
CREATE TABLE frog (key CHAR);

BEGIN;
    INSERT INTO flag VALUES ('7');
    INSERT INTO flag VALUES ('0');
    INSERT INTO flag VALUES ('0');
    INSERT INTO flag VALUES ('_');
    INSERT INTO flag VALUES ('5');
    INSERT INTO flag VALUES ('1');
    INSERT INTO flag VALUES ('m');
    INSERT INTO flag VALUES ('p');
    INSERT INTO flag VALUES ('l');
    INSERT INTO flag VALUES ('3');
END;
