CREATE TABLE IF NOT EXISTS sessions (
    id           CHAR(72) PRIMARY KEY,
    session_data TEXT
);

CREATE TABLE IF NOT EXISTS images (
    id         INTEGER NOT NULL PRIMARY KEY,
    name       VARCHAR(10) NOT NULL,
    author     CHAR(72) NOT NULL,
    accesscode CHAR(32) NOT NULL,
    UNIQUE (name)
);

INSERT INTO images VALUES (1, 'flag', 0, '0ff8f82205b60defbc2e94c3131bc8ca');
INSERT INTO images VALUES (2, 'welcome', 0, '0d7bba2a83745a968b76f22df9a9e176');
