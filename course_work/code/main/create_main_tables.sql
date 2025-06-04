CREATE SCHEMA IF NOT EXISTS main;

CREATE TABLE main.dim_movie
(
    movie_id           SERIAL PRIMARY KEY,
    title              TEXT           NOT NULL,
    release_date       DATE           NOT NULL,
    year               INTEGER        NOT NULL,
    genre              TEXT           NOT NULL,
    rating             TEXT           NULL,
    runtime_minutes    NUMERIC(5, 1)  NULL,
    budget             NUMERIC(15, 2) NULL,
    production_company TEXT           NULL,
    country            TEXT           NULL
);

CREATE TABLE main.dim_director
(
    director_id SERIAL PRIMARY KEY,
    name        TEXT    NOT NULL,
    birth_year  INTEGER NULL,
    death_year  INTEGER NULL,
    professions TEXT[]  NULL
);

CREATE TABLE main.dim_oscar_category
(
    category_id    SERIAL PRIMARY KEY,
    category       TEXT NOT NULL,
    canon_category TEXT NOT NULL
);

CREATE TABLE main.dim_star
(
    star_id SERIAL PRIMARY KEY,
    name    TEXT NOT NULL
);

CREATE TABLE main.dim_writer
(
    writer_id SERIAL PRIMARY KEY,
    name      TEXT NOT NULL
);

CREATE TABLE main.fact_box_office
(
    fact_id          SERIAL PRIMARY KEY,
    movie_id         INTEGER REFERENCES main.dim_movie (movie_id),
    worldwide        NUMERIC(15, 2) NOT NULL,
    domestic         NUMERIC(15, 2) NOT NULL,
    domestic_percent NUMERIC(5, 2)  NOT NULL,
    "foreign"        NUMERIC(15, 2) NOT NULL,
    foreign_percent  NUMERIC(5, 2)  NOT NULL,
    year             INTEGER        NOT NULL
);

CREATE TABLE main.fact_movie_performance
(
    fact_id           SERIAL PRIMARY KEY,
    movie_id          INTEGER REFERENCES main.dim_movie (movie_id),
    director_id       INTEGER REFERENCES main.dim_director (director_id),
    average_rating    NUMERIC(3, 1)  NOT NULL,
    number_of_votes   BIGINT         NOT NULL,
    approval_index    NUMERIC(5, 2)  NOT NULL,
    production_budget NUMERIC(15, 2) NOT NULL,
    domestic_gross    NUMERIC(15, 2) NOT NULL,
    worldwide_gross   NUMERIC(15, 2) NOT NULL
);

CREATE TABLE main.fact_oscar_awards
(
    fact_id       SERIAL PRIMARY KEY,
    movie_id      INTEGER REFERENCES main.dim_movie (movie_id),
    category_id   INTEGER REFERENCES main.dim_oscar_category (category_id),
    ceremony      INTEGER NOT NULL,
    year_film     INTEGER NOT NULL,
    year_ceremony INTEGER NOT NULL,
    winner        BOOLEAN NOT NULL
);

CREATE TABLE main.movie_stars
(
    movie_id INTEGER REFERENCES main.dim_movie (movie_id),
    star_id  INTEGER REFERENCES main.dim_star (star_id),
    PRIMARY KEY (movie_id, star_id)
);

CREATE TABLE main.movie_writers
(
    movie_id  INTEGER REFERENCES main.dim_movie (movie_id),
    writer_id INTEGER REFERENCES main.dim_writer (writer_id),
    PRIMARY KEY (movie_id, writer_id)
);
