-- SCD type 3 for dim_movie
CREATE OR REPLACE FUNCTION main.update_dim_movie(
    p_id INT,
    p_new_name TEXT,
    p_new_release_date DATE
)
RETURNS VOID AS $$
BEGIN
    UPDATE main.dim_movie
    SET previous_release_date = release_date,  -- Store old value
        release_date = p_new_release_date,    -- Overwrite with new value
        name = p_new_name
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

-- SCD type 3 for dim_company
CREATE OR REPLACE FUNCTION main.update_dim_company(
    p_id INT,
    p_new_name TEXT
)
RETURNS VOID AS $$
BEGIN
    UPDATE main.dim_company
    SET previous_name = name,  -- Store old value
        name = p_new_name      -- Overwrite with new value
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

-- SCD type 2 for dim_director
CREATE OR REPLACE FUNCTION main.update_dim_director(
    p_person_id INT
)
RETURNS VOID AS $$
BEGIN
    -- Set the current record to expired
    UPDATE main.dim_director
    SET valid_to = now(), is_current = FALSE
    WHERE person_id = p_person_id AND is_current = TRUE;

    -- Insert a new record
    INSERT INTO main.dim_director (person_id, valid_from, valid_to, is_current)
    VALUES (p_person_id, now(), NULL, TRUE);
END;
$$ LANGUAGE plpgsql;

-- SCD type 2 for dim_writer
CREATE OR REPLACE FUNCTION main.update_dim_writer(
    p_person_id INT
)
RETURNS VOID AS $$
BEGIN
    UPDATE main.dim_writer
    SET valid_to = now(), is_current = FALSE
    WHERE person_id = p_person_id AND is_current = TRUE;

    INSERT INTO main.dim_writer (person_id, valid_from, valid_to, is_current)
    VALUES (p_person_id, now(), NULL, TRUE);
END;
$$ LANGUAGE plpgsql;

-- SCD type 2 for dim_star

CREATE OR REPLACE FUNCTION main.update_dim_star(
    p_person_id INT
)
RETURNS VOID AS $$
BEGIN
    UPDATE main.dim_star
    SET valid_to = now(), is_current = FALSE
    WHERE person_id = p_person_id AND is_current = TRUE;

    INSERT INTO main.dim_star (person_id, valid_from, valid_to, is_current)
    VALUES (p_person_id, now(), NULL, TRUE);
END;
$$ LANGUAGE plpgsql;

