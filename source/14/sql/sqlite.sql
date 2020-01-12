CREATE TABLE IF NOT EXISTS user (
    user_id    INTEGER NOT NULL PRIMARY KEY,
    name       VARCHAR(10),
    password   VARCHAR(255),
    last_login INT UNSIGNED NOT NULL,
    UNIQUE (name)
);
