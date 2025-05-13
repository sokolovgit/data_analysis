import pandas as pd
import os


os.makedirs("da_lab1/clean_data", exist_ok=True)


def clean_box_office_data(file_path, output_path):
    """Clean specific columns in the box office dataset."""
    print(f"Processing {file_path}...")

    df = pd.read_csv(file_path)

    df = df.drop(columns=["Rank"])

    df["Worldwide"] = df["Worldwide"].replace({",": ""}, regex=True).astype(float)
    df["Domestic"] = df["Domestic"].replace({",": ""}, regex=True).astype(float)
    df["Foreign"] = df["Foreign"].replace({",": ""}, regex=True).astype(float)

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

    df["year"] = df["year"].astype(int)

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

    df.to_csv(output_path, index=False)
    print(f"✅ Cleaned data saved to {output_path}")


def clean_movie_data(file_path, output_path):
    """Clean specific columns in the movie dataset."""
    print(f"Processing {file_path}...")

    df = pd.read_csv(file_path)

    df["score"] = pd.to_numeric(df["score"], errors="coerce")

    df["votes"] = (
        df["votes"]
        .apply(lambda x: int(float(x)) if pd.notnull(x) else None)
        .astype(pd.Int64Dtype())
    )

    df["budget"] = pd.to_numeric(df["budget"], errors="coerce")
    df["gross"] = pd.to_numeric(df["gross"], errors="coerce")

    df["runtime"] = pd.to_numeric(df["runtime"], errors="coerce")

    df["released"] = df["released"].str.extract(r"([a-zA-Z]+\s\d{1,2},\s\d{4})")[0]
    df["released"] = pd.to_datetime(df["released"], errors="coerce")

    df = df.dropna(subset=["released"])

    df["year"] = df["year"].astype(int)

    df.to_csv(output_path, index=False)
    print(f"✅ Cleaned data saved to {output_path}")


def clean_oscar_award_data(file_path, output_path):
    """Clean specific columns in the oscar award dataset."""
    print(f"Processing {file_path}...")

    df = pd.read_csv(file_path)

    df = df.dropna()

    df["year_film"] = df["year_film"].astype(int)
    df["year_ceremony"] = df["year_ceremony"].astype(int)
    df["ceremony"] = df["ceremony"].astype(int)

    df["winner"] = df["winner"].astype(bool)

    df.to_csv(output_path, index=False)
    print(f"✅ Cleaned data saved to {output_path}")


def clean_movie_budget_data(file_path, output_path):
    """Clean specific columns in the movie budget dataset."""
    print(f"Processing {file_path}...")

    df = pd.read_csv(file_path)

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

    df["production_date"] = pd.to_datetime(df["production_date"], errors="coerce")

    df["director_birth_year"] = df["director_birth_year"].replace(
        ["-", "\\N", "alive"], pd.NA
    )
    df["director_death_year"] = df["director_death_year"].replace(
        ["-", "\\N", "alive"], pd.NA
    )

    df["director_birth_year"] = df["director_birth_year"].astype(pd.Int64Dtype())
    df["director_death_year"] = df["director_death_year"].astype(pd.Int64Dtype())

    df["director_professions"] = df["director_professions"].apply(
        lambda x: "{" + x.replace(",", ", ") + "}" if pd.notnull(x) else None
    )

    df["genres"] = df["genres"].apply(
        lambda x: "{" + ",".join(x.split(",")) + "}" if pd.notnull(x) else None
    )

    df.replace({"-": pd.NA, "{-}": pd.NA}, inplace=True)

    df.to_csv(output_path, index=False)
    print(f"✅ Cleaned data saved to {output_path}")


clean_box_office_data(
    "da_lab1/data/box_office.csv", "da_lab1/clean_data/box_office.csv"
)

clean_movie_data("da_lab1/data/movies.csv", "da_lab1/clean_data/movies.csv")

clean_oscar_award_data(
    "da_lab1/data/oscar_award.csv", "da_lab1/clean_data/oscar_award.csv"
)

clean_movie_budget_data(
    "da_lab1/data/movie_budget.csv", "da_lab1/clean_data/movie_budget.csv"
)


print("✅ Data cleaning complete! Cleaned files are in 'clean_data/'")
