-- Insert data into dim_company
INSERT INTO main.dim_company (name)
SELECT DISTINCT company
FROM staging.movies
WHERE company IS NOT NULL
ON CONFLICT (name) DO NOTHING;

-- Insert data into dim_person
INSERT INTO main.dim_person (name, birth_year, death_year)
SELECT DISTINCT director_name, director_birth_year, director_death_year
FROM staging.movie_budget
WHERE director_name IS NOT NULL
ON CONFLICT (name) DO NOTHING;

-- Insert data into dim_genre
INSERT INTO main.dim_genre (name)
SELECT DISTINCT(genre)
FROM staging.movies
ON CONFLICT (name) DO NOTHING;

-- Insert data into dim_time
INSERT INTO main.dim_time (year, month, day, quarter, weekday, iso_week)
SELECT DISTINCT EXTRACT(YEAR FROM released),
                EXTRACT(MONTH FROM released),
                EXTRACT(DAY FROM released),
                EXTRACT(QUARTER FROM released),
                TRIM(TO_CHAR(released, 'Day')),
                EXTRACT(WEEK FROM released)
FROM staging.movies
ON CONFLICT (year, month, day) DO NOTHING;

-- Insert data into dim_movie
INSERT INTO main.dim_movie (name, release_date, runtime_minutes, company_id)
SELECT DISTINCT m.name,
                m.released,
                m.runtime,
                c.id AS company_id
FROM staging.movies m
         LEFT JOIN main.dim_company c ON m.company = c.name
ON CONFLICT (name) DO NOTHING;

-- Insert data into dim_director (SCD Type 2)
INSERT INTO main.dim_director (person_id, valid_from)
SELECT p.id, NOW()
FROM staging.movie_budget mb
         JOIN main.dim_person p ON mb.director_name = p.name
WHERE NOT EXISTS (
    SELECT 1 FROM main.dim_director d WHERE d.person_id = p.id AND d.is_current = TRUE
);

-- Insert data into fact_movie_performance
INSERT INTO main.fact_movie_performance (movie_id, production_budget, domestic_gross, worldwide_gross,
                                         movie_average_rating, movie_number_of_votes, approval_index, time_id)
SELECT dm.id,
       mb.production_budget,
       mb.domestic_gross,
       mb.worldwide_gross,
       mb.movie_average_rating,
       mb.movie_number_of_votes,
       mb.approval_index,
       dt.id AS time_id
FROM staging.movie_budget mb
         JOIN main.dim_movie dm ON mb.movie_title = dm.name
         JOIN main.dim_time dt ON EXTRACT(YEAR FROM mb.production_date) = dt.year
ON CONFLICT (movie_id, time_id) DO NOTHING;

-- Insert data into fact_oscar_awards
INSERT INTO main.fact_oscar_awards (movie_id, person_id, category, canon_category, winner, time_id)
SELECT dm.id, dp.id, oa.category, oa.canon_category, oa.winner, dt.id
FROM staging.oscar_awards oa
         LEFT JOIN main.dim_movie dm ON oa.film = dm.name
         LEFT JOIN main.dim_person dp ON oa.name = dp.name
         JOIN main.dim_time dt ON oa.year_film = dt.year
WHERE dm.id IS NOT NULL  -- Filter out rows with no matching movie_id
ON CONFLICT (movie_id, time_id, category) DO NOTHING;

-- Insert movie-genre relationships
INSERT INTO main.movie_genre (movie_id, genre_id)
SELECT DISTINCT dm.id, dg.id
FROM staging.movie_budget mb
         JOIN main.dim_movie dm ON mb.movie_title = dm.name
         JOIN main.dim_genre dg ON dg.name = ANY (string_to_array(mb.genres, ','))
ON CONFLICT (movie_id, genre_id) DO NOTHING;

-- Insert movie-director relationships
INSERT INTO main.movie_director (movie_id, director_id)
SELECT DISTINCT dm.id, dd.id
FROM staging.movie_budget mb
         JOIN main.dim_movie dm ON mb.movie_title = dm.name
         JOIN main.dim_person dp ON mb.director_name = dp.name
         JOIN main.dim_director dd ON dp.id = dd.person_id
ON CONFLICT (movie_id, director_id) DO NOTHING;

-- Insert data into dim_star
INSERT INTO main.dim_star (person_id, valid_from)
SELECT p.id, NOW()
FROM staging.movies m
         JOIN main.dim_person p ON m.star = p.name
WHERE m.star IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM main.dim_star ds WHERE ds.person_id = p.id AND ds.is_current = TRUE
      );

-- Insert data into dim_writer
INSERT INTO main.dim_writer (person_id, valid_from)
SELECT p.id, NOW()
FROM staging.movies m
         JOIN main.dim_person p ON m.writer = p.name
WHERE m.writer IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM main.dim_writer dw WHERE dw.person_id = p.id AND dw.is_current = TRUE
      );

-- Insert data into movie_star relationship
INSERT INTO main.movie_star (movie_id, star_id)
  SELECT DISTINCT dm.id, ds.id
  FROM staging.movies m
           JOIN main.dim_movie dm ON m.name = dm.name
           JOIN main.dim_star ds
               ON ds.person_id = (SELECT id FROM main.dim_person WHERE name = m.star LIMIT 1)
  ON CONFLICT (movie_id, star_id) DO NOTHING;

-- Insert data into movie_writer relationship
INSERT INTO main.movie_writer (movie_id, writer_id)
  SELECT DISTINCT dm.id, dw.id
  FROM staging.movies m
           JOIN main.dim_movie dm ON m.name = dm.name
           JOIN main.dim_writer dw
               ON dw.person_id = (SELECT id FROM main.dim_person WHERE name = m.writer LIMIT 1)
  ON CONFLICT (movie_id, writer_id) DO NOTHING;




