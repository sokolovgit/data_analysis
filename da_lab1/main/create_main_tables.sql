CREATE SCHEMA IF NOT EXISTS main;

-- Dimension Tables

-- SCD Type 3
CREATE TABLE main.dim_company
(
    id   SERIAL PRIMARY KEY,
    previous_name TEXT NULL,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE main.dim_person
(
    id         SERIAL PRIMARY KEY,
    name       TEXT NOT NULL UNIQUE,
    birth_year INTEGER,
    death_year INTEGER,
    CONSTRAINT  unique_person UNIQUE (name, birth_year, death_year)
);

CREATE TABLE main.dim_genre
(
    id   SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);


CREATE TABLE main.dim_time
(
    id       SERIAL PRIMARY KEY,
    year     INTEGER NOT NULL,
    month    INTEGER NOT NULL,
    day      INTEGER NOT NULL,
    quarter  INTEGER NOT NULL,
    weekday  TEXT    NOT NULL,
    iso_week INTEGER NOT NULL,
    CONSTRAINT unique_date UNIQUE (year, month, day)
);

-- SCD Type 3
CREATE TABLE main.dim_movie
(
    id              SERIAL PRIMARY KEY,
    name            TEXT NOT NULL UNIQUE,
    previous_release_date DATE NULL,
    release_date    DATE NOT NULL,
    runtime_minutes NUMERIC(5, 1),
    company_id      INT,
    CONSTRAINT fk_company FOREIGN KEY (company_id) REFERENCES main.dim_company (id)
);


-- SCD Type 2
CREATE TABLE main.dim_director
(
    id         SERIAL PRIMARY KEY,
    person_id  INT       NOT NULL,
    valid_from TIMESTAMP DEFAULT now(),
    valid_to   TIMESTAMP NULL,
    is_current BOOLEAN   DEFAULT TRUE,
    CONSTRAINT fk_person FOREIGN KEY (person_id) REFERENCES main.dim_person (id)
);

-- SCD Type 2
CREATE TABLE main.dim_writer
(
    id         SERIAL PRIMARY KEY,
    person_id  INT       NOT NULL,
    valid_from TIMESTAMP DEFAULT now(),
    valid_to   TIMESTAMP NULL,
    is_current BOOLEAN   DEFAULT TRUE,
    CONSTRAINT fk_person FOREIGN KEY (person_id) REFERENCES main.dim_person (id)
);

-- SCD Type 2
CREATE TABLE main.dim_star
(
    id         SERIAL PRIMARY KEY,
    person_id  INT       NOT NULL,
    valid_from TIMESTAMP DEFAULT now(),
    valid_to   TIMESTAMP NULL,
    is_current BOOLEAN   DEFAULT TRUE,
    CONSTRAINT fk_person FOREIGN KEY (person_id) REFERENCES main.dim_person (id)
);

-- Fact Table 
CREATE TABLE main.fact_movie_performance
(
    id                    SERIAL PRIMARY KEY,
    movie_id              INT            NOT NULL,
    production_budget     NUMERIC(15, 2) NOT NULL,
    domestic_gross        NUMERIC(15, 2) NOT NULL,
    worldwide_gross       NUMERIC(15, 2) NOT NULL,
    domestic_percent      NUMERIC(5, 2) GENERATED ALWAYS AS
        (100 * domestic_gross / NULLIF(worldwide_gross, 0)) STORED,
    foreign_gross         NUMERIC(15, 2) GENERATED ALWAYS AS
        (worldwide_gross - domestic_gross) STORED,
    foreign_percent       NUMERIC(5, 2) GENERATED ALWAYS AS
        (100 * (worldwide_gross - domestic_gross) / NULLIF(worldwide_gross, 0)) STORED,
    movie_average_rating  NUMERIC(3, 1)  NOT NULL,
    movie_number_of_votes BIGINT         NOT NULL,
    approval_index        NUMERIC(5, 2)  NOT NULL,
    time_id               INT            NOT NULL,
    CONSTRAINT fk_movie FOREIGN KEY (movie_id) REFERENCES main.dim_movie (id),
    CONSTRAINT fk_time FOREIGN KEY (time_id) REFERENCES main.dim_time (id),
    CONSTRAINT unique_movie_time UNIQUE (movie_id, time_id)
);

CREATE TABLE main.fact_oscar_awards
(
    id             SERIAL PRIMARY KEY,
    movie_id       INT     NOT NULL,
    person_id      INT     NULL,
    category       TEXT    NOT NULL,
    canon_category TEXT    NOT NULL,
    winner         BOOLEAN NOT NULL,
    time_id        INT     NOT NULL,
    CONSTRAINT fk_movie FOREIGN KEY (movie_id) REFERENCES main.dim_movie (id),
    CONSTRAINT fk_person FOREIGN KEY (person_id) REFERENCES main.dim_person (id),
    CONSTRAINT fk_time FOREIGN KEY (time_id) REFERENCES main.dim_time (id),
    CONSTRAINT unique_movie_time_category UNIQUE (movie_id, time_id, category)
);

-- Movie-Genre Relationship (Many-to-Many)
CREATE TABLE main.movie_genre
(
    movie_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (movie_id, genre_id),
    CONSTRAINT fk_movie FOREIGN KEY (movie_id) REFERENCES main.dim_movie (id),
    CONSTRAINT fk_genre FOREIGN KEY (genre_id) REFERENCES main.dim_genre (id)
);

-- Movie-Director Relationship (Many-to-Many)
CREATE TABLE main.movie_director
(
    movie_id    INT NOT NULL,
    director_id INT NOT NULL,
    PRIMARY KEY (movie_id, director_id),
    CONSTRAINT fk_movie FOREIGN KEY (movie_id) REFERENCES main.dim_movie (id),
    CONSTRAINT fk_director FOREIGN KEY (director_id) REFERENCES main.dim_director (id)
);

-- Movie-Writer Relationship (Many-to-Many)
CREATE TABLE main.movie_writer
(
    movie_id  INT NOT NULL,
    writer_id INT NOT NULL,
    PRIMARY KEY (movie_id, writer_id),
    CONSTRAINT fk_movie FOREIGN KEY (movie_id) REFERENCES main.dim_movie (id),
    CONSTRAINT fk_writer FOREIGN KEY (writer_id) REFERENCES main.dim_writer (id)
);

-- Movie-Star Relationship (Many-to-Many)
CREATE TABLE main.movie_star
(
    movie_id INT NOT NULL,
    star_id  INT NOT NULL,
    PRIMARY KEY (movie_id, star_id),
    CONSTRAINT fk_movie FOREIGN KEY (movie_id) REFERENCES main.dim_movie (id),
    CONSTRAINT fk_star FOREIGN KEY (star_id) REFERENCES main.dim_star (id)
);
