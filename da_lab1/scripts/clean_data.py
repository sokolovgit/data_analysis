import pandas as pd
import os

# Ensure clean_data directory exists
os.makedirs("da_lab1/clean_data", exist_ok=True)


def clean_box_office_data(file_path, output_path):
    """Clean specific columns in the box office dataset."""
    print(f"Processing {file_path}...")

    # Read CSV with proper handling of commas in numbers and percentage signs
    df = pd.read_csv(file_path)

    # Drop the 'Rank' column
    df = df.drop(columns=["Rank"])

    # Clean the 'Worldwide', 'Domestic', and 'Foreign' columns by removing commas and converting to numeric
    df["Worldwide"] = df["Worldwide"].replace({",": ""}, regex=True).astype(float)
    df["Domestic"] = df["Domestic"].replace({",": ""}, regex=True).astype(float)
    df["Foreign"] = df["Foreign"].replace({",": ""}, regex=True).astype(float)

    # Clean the 'Domestic_percent' and 'Foreign_percent' columns by removing '%' and converting to decimal
    # Handle cases where the percentage is in the format '<0.1%' by replacing it with 0
    df["Domestic_percent"] = (
        df["Domestic_percent"]
        .replace({",": "", "%": "", "<0.1": "0"}, regex=True)
        .astype(float)
        / 100
    )
    df["Foreign_percent"] = (
        df["Foreign_percent"]
        .replace({",": "", "%": "", "<0.1": "0"}, regex=True)
        .astype(float)
        / 100
    )

    # Ensure the 'Year' column is an integer
    df["year"] = df["year"].astype(int)

    # Rename columns to match table schema names
    df = df.rename(
        columns={
            "Release Group": "release_group",
            "Worldwide": "worldwide",
            "Domestic": "domestic",
            "Domestic_percent": "domestic_percent",
            "Foreign": "foreign",
            "Foreign_percent": "foreign_percent",
            "year": "year",
        }
    )

    # Save the cleaned data
    df.to_csv(output_path, index=False)
    print(f"✅ Cleaned data saved to {output_path}")


def clean_movie_data(file_path, output_path):
    """Clean specific columns in the movie dataset."""
    print(f"Processing {file_path}...")

    # Read CSV
    df = pd.read_csv(file_path)

    # Clean the columns

    # Clean 'score' and 'votes' by ensuring they are numeric, and replace errors with NaN
    df["score"] = pd.to_numeric(df["score"], errors="coerce")

    df["votes"] = (
        df["votes"]
        .apply(lambda x: int(float(x)) if pd.notnull(x) else None)
        .astype(pd.Int64Dtype())
    )

    # Clean 'budget' and 'gross' by ensuring they are numeric, and replace errors with NaN
    df["budget"] = pd.to_numeric(df["budget"], errors="coerce")
    df["gross"] = pd.to_numeric(df["gross"], errors="coerce")

    # Clean 'runtime' by ensuring it's a numeric value, and replace errors with NaN
    df["runtime"] = pd.to_numeric(df["runtime"], errors="coerce")

    # Handle missing release dates by converting to datetime
    df["released"] = df["released"].str.extract(r"([a-zA-Z]+\s\d{1,2},\s\d{4})")[0]
    df["released"] = pd.to_datetime(df["released"], errors="coerce")

    # Drop rows with missing 'released' dates
    df = df.dropna(subset=["released"])

    # Ensure the 'year' column is an integer
    df["year"] = df["year"].astype(int)

    # Save the cleaned data
    df.to_csv(output_path, index=False)
    print(f"✅ Cleaned data saved to {output_path}")


def clean_oscar_award_data(file_path, output_path):
    """Clean specific columns in the oscar award dataset."""
    print(f"Processing {file_path}...")

    # Read CSV
    df = pd.read_csv(file_path)

    # Drop rows with any missing values
    df = df.dropna()

    # Ensure the 'year_film', 'year_ceremony', and 'ceremony' columns are integers
    df["year_film"] = df["year_film"].astype(int)
    df["year_ceremony"] = df["year_ceremony"].astype(int)
    df["ceremony"] = df["ceremony"].astype(int)

    # Ensure the 'winner' column is boolean
    df["winner"] = df["winner"].astype(bool)

    # Save the cleaned data
    df.to_csv(output_path, index=False)
    print(f"✅ Cleaned data saved to {output_path}")


def clean_movie_budget_data(file_path, output_path):
    """Clean specific columns in the movie budget dataset."""
    print(f"Processing {file_path}...")

    # Read CSV
    df = pd.read_csv(file_path)

    # Rename columns to match table schema names
    df = df.rename(
        columns={
            "movie_title": "movie_title",
            "production_date": "production_date",
            "genres": "genres",
            "runtime_minutes": "runtime_minutes",
            "director_name": "director_name",
            "director_professions": "director_professions",
            "director_birthYear": "director_birth_year",
            "director_deathYear": "director_death_year",
            "movie_averageRating": "movie_average_rating",
            "movie_numerOfVotes": "movie_number_of_votes",
            "approval_Index": "approval_index",
            "Production budget $": "production_budget",
            "Domestic gross $": "domestic_gross",
            "Worldwide gross $": "worldwide_gross",
        }
    )

    # Clean the columns

    # Clean 'runtime_minutes', 'movie_average_rating', 'movie_number_of_votes', 'approval_index', 'production_budget', 'domestic_gross', and 'worldwide_gross' by ensuring they are numeric, and replace errors with NaN
    df["runtime_minutes"] = pd.to_numeric(df["runtime_minutes"], errors="coerce")
    df["movie_average_rating"] = pd.to_numeric(
        df["movie_average_rating"], errors="coerce"
    )
    df["movie_number_of_votes"] = pd.to_numeric(
        df["movie_number_of_votes"], errors="coerce"
    ).astype("Int64")
    df["approval_index"] = pd.to_numeric(df["approval_index"], errors="coerce")
    df["production_budget"] = pd.to_numeric(df["production_budget"], errors="coerce")
    df["domestic_gross"] = pd.to_numeric(df["domestic_gross"], errors="coerce")
    df["worldwide_gross"] = pd.to_numeric(df["worldwide_gross"], errors="coerce")

    # Handle missing production dates by converting to datetime
    df["production_date"] = pd.to_datetime(df["production_date"], errors="coerce")

    # Replace invalid values in 'director_birth_year' and 'director_death_year' with NaN
    df["director_birth_year"] = df["director_birth_year"].replace(
        ["-", "\\N", "alive"], pd.NA
    )
    df["director_death_year"] = df["director_death_year"].replace(
        ["-", "\\N", "alive"], pd.NA
    )

    # Ensure the 'director_birth_year' and 'director_death_year' columns are integers
    df["director_birth_year"] = df["director_birth_year"].astype(pd.Int64Dtype())
    df["director_death_year"] = df["director_death_year"].astype(pd.Int64Dtype())

    # Format 'director_professions' as array literals
    df["director_professions"] = df["director_professions"].apply(
        lambda x: "{" + x.replace(",", ", ") + "}" if pd.notnull(x) else None
    )

    # Parse 'genres' into pg array format
    df["genres"] = df["genres"].apply(
        lambda x: "{" + ",".join(x.split(",")) + "}" if pd.notnull(x) else None
    )

    # Replace invalid values with NaN
    df.replace({"-": pd.NA, "{-}": pd.NA}, inplace=True)

    # Save the cleaned data
    df.to_csv(output_path, index=False)
    print(f"✅ Cleaned data saved to {output_path}")


# clean_box_office_data(
#     "da_lab1/data/box_office.csv", "da_lab1/clean_data/box_office.csv"
# )

# clean_movie_data("da_lab1/data/movies.csv", "da_lab1/clean_data/movies.csv")

# clean_oscar_award_data(
#     "da_lab1/data/oscar_award.csv", "da_lab1/clean_data/oscar_award.csv"
# )

clean_movie_budget_data(
    "da_lab1/data/movie_budget.csv", "da_lab1/clean_data/movie_budget.csv"
)


print("✅ Data cleaning complete! Cleaned files are in 'clean_data/'")
