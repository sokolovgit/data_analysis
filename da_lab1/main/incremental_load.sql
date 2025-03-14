-- 1. Завантаження fact_box_office (оновлення даних)
INSERT INTO main.fact_box_office (movie_id, worldwide, domestic, domestic_percent, "foreign", foreign_percent, year)
SELECT dm.movie_id, bo.worldwide, bo.domestic, bo.domestic_percent, bo.foreign, bo.foreign_percent, bo.year
FROM staging.box_office bo
         JOIN main.dim_movie dm ON bo.release_group = dm.title AND bo.year = dm.year
ON CONFLICT (movie_id, year) DO UPDATE SET worldwide        = EXCLUDED.worldwide,
                                           domestic         = EXCLUDED.domestic,
                                           domestic_percent = EXCLUDED.domestic_percent,
                                           "foreign"        = EXCLUDED.foreign,
                                           foreign_percent  = EXCLUDED.foreign_percent;

-- 2. Завантаження fact_movie_performance (рейтинги та збори можуть змінюватися)
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
         JOIN main.dim_movie dm ON mb.movie_title = dm.title AND mb.production_date = dm.release_date
         LEFT JOIN main.dim_director dd ON mb.director_name = dd.name
ON CONFLICT (movie_id) DO UPDATE SET average_rating  = EXCLUDED.average_rating,
                                     number_of_votes = EXCLUDED.number_of_votes,
                                     approval_index  = EXCLUDED.approval_index,
                                     domestic_gross  = EXCLUDED.domestic_gross,
                                     worldwide_gross = EXCLUDED.worldwide_gross;

-- 3. Завантаження fact_oscar_awards (можуть з’являтися нові переможці)
INSERT INTO main.fact_oscar_awards (movie_id, category_id, ceremony, year_film, year_ceremony, winner)
SELECT dm.movie_id, dc.category_id, oa.ceremony, oa.year_film, oa.year_ceremony, oa.winner
FROM staging.oscar_awards oa
         JOIN main.dim_movie dm ON oa.film = dm.title AND oa.year_film = dm.year
         JOIN main.dim_oscar_category dc ON oa.category = dc.category
ON CONFLICT (movie_id, category_id, year_film) DO NOTHING;

-- 4. Завантаження зв'язків між фільмами та акторами
INSERT INTO main.movie_stars (movie_id, star_id)
SELECT DISTINCT dm.movie_id, ds.star_id
FROM staging.movies m
         JOIN main.dim_movie dm ON m.name = dm.title AND m.year = dm.year
         JOIN main.dim_star ds ON m.star = ds.name
ON CONFLICT (movie_id, star_id) DO NOTHING;

-- 5. Завантаження зв'язків між фільмами та сценаристами
INSERT INTO main.movie_writers (movie_id, writer_id)
SELECT DISTINCT dm.movie_id, dw.writer_id
FROM staging.movies m
         JOIN main.dim_movie dm ON m.name = dm.title AND m.year = dm.year
         JOIN main.dim_writer dw ON m.writer = dw.name
ON CONFLICT (movie_id, writer_id) DO NOTHING;
