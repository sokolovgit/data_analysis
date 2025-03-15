COPY staging.box_office (release_group, worldwide, domestic, domestic_percent, "foreign", foreign_percent, year)
FROM '/private/tmp/box_office.csv' DELIMITER ',' CSV HEADER;

COPY staging.movies (name, rating, genre, year, released, score, votes, director, writer, star, country, budget, gross, company, runtime)
FROM '/private/tmp/movies.csv' DELIMITER ',' CSV HEADER;

COPY staging.oscar_awards(year_film, year_ceremony, ceremony, category, canon_category, name, film, winner)
FROM '/private/tmp/oscar_award.csv' DELIMITER ',' CSV HEADER;

COPY staging.movie_budget (movie_title, production_date, genres, runtime_minutes, director_name, director_professions, director_birth_year, director_death_year, movie_average_rating, movie_number_of_votes, approval_index, production_budget, domestic_gross, worldwide_gross)
FROM '/private/tmp/movie_budget.csv' DELIMITER ',' CSV HEADER;