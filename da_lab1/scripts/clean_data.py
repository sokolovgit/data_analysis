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


# Apply the cleaning function for box office data
# clean_box_office_data(
#     "da_lab1/data/box_office.csv", "da_lab1/clean_data/box_office.csv"
# )

# Apply the cleaning function for movie data
clean_movie_data("da_lab1/data/movies.csv", "da_lab1/clean_data/movies.csv")

print("✅ Data cleaning complete! Cleaned files are in 'clean_data/'")
