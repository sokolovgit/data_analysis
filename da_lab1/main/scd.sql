-- SCD Type 2
ALTER TABLE main.dim_movie
    ADD COLUMN valid_from DATE    DEFAULT CURRENT_DATE,
    ADD COLUMN valid_to   DATE NULL,
    ADD COLUMN is_current BOOLEAN DEFAULT TRUE;

-- 1. Оновлення dim_movie (SCD Type 2)
WITH new_movies AS (SELECT DISTINCT name     AS title,
                                    released AS release_date,
                                    year,
                                    genre,
                                    rating,
                                    runtime,
                                    budget,
                                    company  AS production_company,
                                    country
                    FROM staging.movies)
INSERT
INTO main.dim_movie (title, release_date, year, genre, rating, runtime_minutes, budget, production_company, country,
                     valid_from, valid_to, is_current)
SELECT nm.*, CURRENT_DATE, NULL, TRUE
FROM new_movies nm
         LEFT JOIN main.dim_movie dm ON nm.title = dm.title AND nm.year = dm.year
WHERE dm.movie_id IS NULL
   OR (dm.is_current = TRUE AND (
    nm.genre <> dm.genre OR nm.rating <> dm.rating OR nm.runtime <> dm.runtime_minutes
    ));

-- Закриття старих записів у разі змін
UPDATE main.dim_movie
SET valid_to   = CURRENT_DATE,
    is_current = FALSE
WHERE is_current = TRUE
  AND movie_id IN (SELECT old.movie_id
                   FROM main.dim_movie old
                            JOIN staging.movies new ON old.title = new.name AND old.year = new.year
                   WHERE old.genre <> new.genre
                      OR old.rating <> new.rating
                      OR old.runtime_minutes <> new.runtime);

-- 2. Оновлення dim_director (SCD Type 1)
INSERT INTO main.dim_director (name, birth_year, death_year, professions)
SELECT DISTINCT director_name, director_birth_year, director_death_year, director_professions
FROM staging.movie_budget
WHERE director_name IS NOT NULL
ON CONFLICT (director_id) DO UPDATE
    SET birth_year  = EXCLUDED.birth_year,
        death_year  = EXCLUDED.death_year,
        professions = EXCLUDED.professions;

-- 3. Оновлення dim_oscar_category
INSERT INTO main.dim_oscar_category (category, canon_category)
SELECT DISTINCT category, canon_category
FROM staging.oscar_awards
ON CONFLICT (category_id) DO NOTHING;

-- 4. Оновлення dim_star
INSERT INTO main.dim_star (name)
SELECT DISTINCT star
FROM staging.movies
WHERE star IS NOT NULL
ON CONFLICT (star_id) DO NOTHING;

-- 5. Оновлення dim_writer
INSERT INTO main.dim_writer (name)
SELECT DISTINCT writer
FROM staging.movies
WHERE writer IS NOT NULL
ON CONFLICT (writer_id) DO NOTHING;