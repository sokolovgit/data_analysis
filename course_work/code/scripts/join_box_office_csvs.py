import pandas as pd

# File paths
file1 = "da_lab1/data/2000-2009-box-office.csv"
file2 = "da_lab1/data/2010-2024-box-office.csv"
file3 = "da_lab1/data/2024-box-office.csv"

output_file = "da_lab1/data/combined-box-office.csv"

# Read the CSV files
df1 = pd.read_csv(file1)
df2 = pd.read_csv(file2)
df3 = pd.read_csv(file3)

# Concatenate the dataframes
combined_df = pd.concat([df1, df2, df3], ignore_index=True)

# Write the combined dataframe to a new CSV file
combined_df.to_csv(output_file, index=False)

print(f"Combined CSV file saved to {output_file}")
