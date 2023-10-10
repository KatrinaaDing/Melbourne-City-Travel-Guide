# Author: Yiyun Mao
#
# Description: 
# This script cleans the POI dataset (landmarks.csv)
# And exports it to a CSV file.
import pandas as pd

# Convert the CSV data into a DataFrame
df = pd.read_csv('landmarks.csv')

# Function to split 'co-ordinates' column into lat and log fields
def split_coordinate(line):
  [lat, lon] = line.split(',')
  lon = lon.split(' ')[1]
  return [lat, lon]

# Convert co-ordinates to lat and log data
df[['lat', 'lon']] = df['Co-ordinates'].apply(lambda x: pd.Series(split_coordinate(x)))

# # Drop the old 'co-ordinates' column
# df.drop(columns=['Co-ordinates'], inplace=True)

# export the DataFrame to a CSV file
df.to_csv('landmarks-clean.csv', index=False)