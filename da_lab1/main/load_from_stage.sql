-- Завантаження вимірювань

INSERT INTO main.dim_movie (title, release_date, year, genre, rating, runtime_minutes, budget, production_company,
                            country)
SELECT DISTINCT name,
                released,
                year,
                genre,
                rating,
                runtime,
                budget,
                company,
                country
FROM staging.movies;

INSERT INTO main.dim_director (name, birth_year, death_year, professions)
SELECT DISTINCT director_name, director_birth_year, director_death_year, director_professions
FROM staging.movie_budget
WHERE director_name IS NOT NULL;

INSERT INTO main.dim_oscar_category (category, canon_category)
SELECT DISTINCT category, canon_category
FROM staging.oscar_awards;

INSERT INTO main.dim_star (name)
SELECT DISTINCT star
FROM staging.movies
WHERE star IS NOT NULL;

INSERT INTO main.dim_writer (name)
SELECT DISTINCT writer
FROM staging.movies
WHERE writer IS NOT NULL;

-- Завантаження фактів

INSERT INTO main.fact_box_office (movie_id, worldwide, domestic, domestic_percent, "foreign", foreign_percent, year)
SELECT dm.movie_id, bo.worldwide, bo.domestic, bo.domestic_percent, bo.foreign, bo.foreign_percent, bo.year
FROM staging.box_office bo
         JOIN main.dim_movie dm ON bo.release_group = dm.title AND bo.year = dm.year;

INSERT INTO main.fact_movie_performance (movie_id, director_id, average_rating, number_of_votes, approval_index,
                                         production_budget, domestic_gross, worldwide_gross)
SELECT dm.movie_id,
       dd.director_id,
       mb.movie_average_rating,
       mb.movie_number_of_votes,
       mb.approval_index,
       mb.production_budget,
       mb.domestic_gross,
       mb.worldwide_gross
FROM staging.movie_budget mb
         JOIN main.dim_movie dm ON mb.movie_title = dm.title
         LEFT JOIN main.dim_director dd ON mb.director_name = dd.name;

INSERT INTO main.fact_oscar_awards (movie_id, category_id, ceremony, year_film, year_ceremony, winner)
SELECT dm.movie_id, dc.category_id, oa.ceremony, oa.year_film, oa.year_ceremony, oa.winner
FROM staging.oscar_awards oa
         JOIN main.dim_movie dm ON oa.film = dm.title AND oa.year_film = dm.year
         JOIN main.dim_oscar_category dc ON oa.category = dc.category;

-- Завантаження зв’язків

INSERT INTO main.movie_stars (movie_id, star_id)
SELECT DISTINCT dm.movie_id, ds.star_id
FROM staging.movies m
         JOIN main.dim_movie dm ON m.name = dm.title
         JOIN main.dim_star ds ON m.star = ds.name;

INSERT INTO main.movie_writers (movie_id, writer_id)
SELECT DISTINCT dm.movie_id, dw.writer_id
FROM staging.movies m
         JOIN main.dim_movie dm ON m.name = dm.title
         JOIN main.dim_writer dw ON m.writer = dw.name;
