CREATE TABLE IF NOT EXISTS sessions (
    id           CHAR(72) PRIMARY KEY,
    session_data TEXT
);

CREATE TABLE IF NOT EXISTS user (
    id       INTEGER NOT NULL PRIMARY KEY,
    name     VARCHAR(32),
    password VARCHAR(32),
    UNIQUE (name)
);
INSERT INTO user VALUES (1, 'admin', 'fd-_e~');
