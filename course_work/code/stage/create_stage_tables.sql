CREATE SCHEMA IF NOT EXISTS staging;


CREATE TABLE staging.box_office
(
    id               SERIAL PRIMARY KEY,
    release_group    TEXT           NOT NULL,
    worldwide        NUMERIC(15, 2) NOT NULL,
    domestic         NUMERIC(15, 2) NOT NULL,
    domestic_percent NUMERIC(5, 2)  NOT NULL,
    "foreign"        NUMERIC(15, 2) NOT NULL,
    foreign_percent  NUMERIC(5, 2)  NOT NULL,
    year             INTEGER        NOT NULL
);

CREATE TABLE staging.movie_budget
(
    id                    SERIAL PRIMARY KEY,
    movie_title           TEXT           NOT NULL,
    production_date       DATE           NOT NULL,
    genres                TEXT           NOT NULL,
    runtime_minutes       NUMERIC(5, 1)  NOT NULL,
    director_name         TEXT           NULL,
    director_professions  TEXT[],
    director_birth_year   INTEGER        NULL,
    director_death_year   INTEGER        NULL,
    movie_average_rating  NUMERIC(3, 1)  NOT NULL,
    movie_number_of_votes BIGINT         NOT NULL,
    approval_index        NUMERIC(5, 2)  NOT NULL,
    production_budget     NUMERIC(15, 2) NOT NULL,
    domestic_gross        NUMERIC(15, 2) NOT NULL,
    worldwide_gross       NUMERIC(15, 2) NOT NULL
);

CREATE TABLE staging.movies
(
    id       SERIAL PRIMARY KEY,
    name     TEXT           NOT NULL,
    rating   TEXT           NULL,
    genre    TEXT           NOT NULL,
    year     INTEGER        NOT NULL,
    released DATE           NOT NULL,
    score    NUMERIC(3, 1)  NULL,
    votes    BIGINT         NULL,
    director TEXT           NULL,
    writer   TEXT           NULL,
    star     TEXT           NULL,
    country  TEXT           NULL,
    budget   NUMERIC(15, 2) NULL,
    gross    NUMERIC(15, 2) NULL,
    company  TEXT           NULL,
    runtime  NUMERIC(5, 1)  NULL
);

CREATE TABLE staging.oscar_awards
(
    id             SERIAL PRIMARY KEY,
    year_film      INTEGER NOT NULL,
    year_ceremony  INTEGER NOT NULL,
    ceremony       INTEGER NOT NULL,
    category       TEXT    NOT NULL,
    canon_category TEXT    NOT NULL,
    name           TEXT    NOT NULL,
    film           TEXT    NOT NULL,
    winner         BOOLEAN NOT NULL
);
