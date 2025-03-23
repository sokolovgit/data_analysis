INSERT INTO main.dim_company (name, previous_name)
SELECT DISTINCT company, NULL
FROM staging.movies s
WHERE company IS NOT NULL
  AND NOT EXISTS (SELECT 1
                  FROM main.dim_company c
                  WHERE c.name = s.company)
ON CONFLICT (name) DO NOTHING;


INSERT INTO main.dim_person (name, birth_year, death_year)
SELECT DISTINCT director_name, director_birth_year, director_death_year
FROM staging.movie_budget s
WHERE director_name IS NOT NULL
  AND NOT EXISTS (SELECT 1
                  FROM main.dim_person p
                  WHERE p.name = s.director_name
                    AND p.birth_year = s.director_birth_year
                    AND p.death_year = s.director_death_year)
ON CONFLICT (name, birth_year, death_year) DO NOTHING;


INSERT INTO main.dim_genre (name)
SELECT DISTINCT genre
FROM staging.movies s
WHERE NOT EXISTS (SELECT 1
                  FROM main.dim_genre g
                  WHERE g.name = s.genre)
ON CONFLICT (name) DO NOTHING;


INSERT INTO main.dim_time (year, month, day, quarter, weekday, iso_week)
SELECT DISTINCT EXTRACT(YEAR FROM released),
                EXTRACT(MONTH FROM released),
                EXTRACT(DAY FROM released),
                EXTRACT(QUARTER FROM released),
                TRIM(TO_CHAR(released, 'Day')),
                EXTRACT(WEEK FROM released)
FROM staging.movies s
WHERE NOT EXISTS (SELECT 1
                  FROM main.dim_time t
                  WHERE t.year = EXTRACT(YEAR FROM s.released)
                    AND t.month = EXTRACT(MONTH FROM s.released)
                    AND t.day = EXTRACT(DAY FROM s.released))
ON CONFLICT (year, month, day) DO NOTHING;

INSERT INTO main.dim_movie (name, release_date, previous_release_date, runtime_minutes, company_id)
SELECT DISTINCT s.name,
                s.released,
                NULL,
                s.runtime,
                c.id AS company_id
FROM staging.movies s
         LEFT JOIN main.dim_company c ON s.company = c.name
WHERE NOT EXISTS (SELECT 1
                  FROM main.dim_movie m
                  WHERE m.name = s.name)
ON CONFLICT (name)
    DO UPDATE SET previous_release_date = main.dim_movie.release_date,
                  release_date          = EXCLUDED.release_date;


WITH new_directors AS (SELECT DISTINCT p.id AS person_id
                       FROM staging.movie_budget s
                                JOIN main.dim_person p ON s.director_name = p.name
                       WHERE NOT EXISTS (SELECT 1
                                         FROM main.dim_director d
                                         WHERE d.person_id = p.id
                                           AND d.is_current = TRUE))
UPDATE main.dim_director
SET valid_to   = NOW(),
    is_current = FALSE
WHERE person_id IN (SELECT person_id FROM new_directors)
  AND is_current = TRUE;

WITH new_directors AS (SELECT DISTINCT p.id AS person_id
                       FROM staging.movie_budget s
                                JOIN main.dim_person p ON s.director_name = p.name
                       WHERE NOT EXISTS (SELECT 1
                                         FROM main.dim_director d
                                         WHERE d.person_id = p.id
                                           AND d.is_current = TRUE))
INSERT
INTO main.dim_director (person_id, valid_from)
SELECT person_id, NOW()
FROM new_directors;


INSERT INTO main.fact_movie_performance (movie_id, production_budget, domestic_gross, worldwide_gross,
                                         movie_average_rating, movie_number_of_votes, approval_index, time_id)
SELECT dm.id,
       s.production_budget,
       s.domestic_gross,
       s.worldwide_gross,
       s.movie_average_rating,
       s.movie_number_of_votes,
       s.approval_index,
       dt.id AS time_id
FROM staging.movie_budget s
         JOIN main.dim_movie dm ON s.movie_title = dm.name
         JOIN main.dim_time dt ON EXTRACT(YEAR FROM s.production_date) = dt.year
ON CONFLICT (movie_id, time_id) DO UPDATE
    SET production_budget     = EXCLUDED.production_budget,
        domestic_gross        = EXCLUDED.domestic_gross,
        worldwide_gross       = EXCLUDED.worldwide_gross,
        movie_average_rating  = EXCLUDED.movie_average_rating,
        movie_number_of_votes = EXCLUDED.movie_number_of_votes,
        approval_index        = EXCLUDED.approval_index;

INSERT INTO main.fact_oscar_awards (movie_id, person_id, category, canon_category, winner, time_id)
SELECT dm.id, dp.id, s.category, s.canon_category, s.winner, dt.id
FROM staging.oscar_awards s
         LEFT JOIN main.dim_movie dm ON s.film = dm.name
         LEFT JOIN main.dim_person dp ON s.name = dp.name
         JOIN main.dim_time dt ON s.year_film = dt.year
WHERE dm.id IS NOT NULL
ON CONFLICT (movie_id, time_id, category) DO NOTHING;


INSERT INTO main.movie_genre (movie_id, genre_id)
SELECT DISTINCT dm.id, dg.id
FROM staging.movie_budget s
         JOIN main.dim_movie dm ON s.movie_title = dm.name
         JOIN main.dim_genre dg ON dg.name = ANY (string_to_array(s.genres, ','))
ON CONFLICT (movie_id, genre_id) DO NOTHING;


INSERT INTO main.movie_director (movie_id, director_id)
SELECT DISTINCT dm.id, dd.id
FROM staging.movie_budget s
         JOIN main.dim_movie dm ON s.movie_title = dm.name
         JOIN main.dim_person dp ON s.director_name = dp.name
         JOIN main.dim_director dd ON dp.id = dd.person_id
ON CONFLICT (movie_id, director_id) DO NOTHING;

-- Update the existing records to set them as not current
WITH new_stars AS (SELECT DISTINCT p.id AS person_id
                   FROM staging.movies s
                            JOIN main.dim_person p ON s.star = p.name
                   WHERE NOT EXISTS (SELECT 1
                                     FROM main.dim_star ds
                                     WHERE ds.person_id = p.id
                                       AND ds.is_current = TRUE))

UPDATE main.dim_star
SET valid_to   = NOW(),
    is_current = FALSE
WHERE person_id IN (SELECT person_id FROM new_stars)
  AND is_current = TRUE;

-- Insert new records into dim_star
WITH new_stars AS (SELECT DISTINCT p.id AS person_id
                   FROM staging.movies s
                            JOIN main.dim_person p ON s.star = p.name
                   WHERE NOT EXISTS (SELECT 1
                                     FROM main.dim_star ds
                                     WHERE ds.person_id = p.id
                                       AND ds.is_current = TRUE))
INSERT
INTO main.dim_star (person_id, valid_from)
SELECT person_id, NOW()
FROM new_stars;

WITH new_writers AS (SELECT DISTINCT p.id AS person_id
                     FROM staging.movies s
                              JOIN main.dim_person p ON s.writer = p.name
                     WHERE NOT EXISTS (SELECT 1
                                       FROM main.dim_writer dw
                                       WHERE dw.person_id = p.id
                                         AND dw.is_current = TRUE))
UPDATE main.dim_writer
SET valid_to   = NOW(),
    is_current = FALSE
WHERE person_id IN (SELECT person_id FROM new_writers)
  AND is_current = TRUE;


WITH new_writers AS (SELECT DISTINCT p.id AS person_id
                     FROM staging.movies s
                              JOIN main.dim_person p ON s.writer = p.name
                     WHERE NOT EXISTS (SELECT 1
                                       FROM main.dim_writer dw
                                       WHERE dw.person_id = p.id
                                         AND dw.is_current = TRUE))

INSERT
INTO main.dim_writer (person_id, valid_from)
SELECT person_id, NOW()
FROM new_writers;

INSERT INTO main.movie_star (movie_id, star_id)
SELECT DISTINCT dm.id, ds.id
FROM staging.movies s
         JOIN main.dim_movie dm ON s.name = dm.name
         JOIN main.dim_star ds ON ds.person_id = (SELECT id FROM main.dim_person WHERE name = s.star LIMIT 1)
ON CONFLICT (movie_id, star_id) DO NOTHING;

INSERT INTO main.movie_writer (movie_id, writer_id)
SELECT DISTINCT dm.id, dw.id
FROM staging.movies s
         JOIN main.dim_movie dm ON s.name = dm.name
         JOIN main.dim_writer dw ON dw.person_id = (SELECT id FROM main.dim_person WHERE name = s.writer LIMIT 1)
ON CONFLICT (movie_id, writer_id) DO NOTHING;


