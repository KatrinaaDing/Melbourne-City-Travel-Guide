# Author: Ziqi Ding
# Description: This script cleans the Airbnb data and exports it to a CSV file.
import pandas as pd

# Convert the CSV data into a DataFrame
df = pd.read_csv('listings.csv')

# Drop useless columns
columns_to_drop = ['license', 'neighbourhood_group']
df.drop(columns=columns_to_drop, inplace=True)

# Function to split 'name' column into separate fields
def split_name(line):
  # define indices for each field
  [i_name, i_rating, i_bedroom, i_beds, i_baths] = [0, 1, 2, 3, 4]
  # no rating if '★' not in name
  if '★' not in line:
    [i_name, i_rating, i_bedroom, i_beds, i_baths] = [0, -1, 1, 2, 3]
  
  parts = line.split('·')
  if len(parts) < 4:
    return parts[i_name].strip(), None, None, None, None
  
  if i_rating < 1:
    rating = None
  else:
    try:
      rating = float(parts[i_rating].strip().split('★')[1])
    except ValueError:
      rating = None
  try:
    name = parts[i_name].strip()
    bedrooms = parts[i_bedroom].strip().split(' ')[0]
    beds = parts[i_beds].strip().split(' ')[0]
    baths = parts[i_baths].strip().split(' ')[0]
    return name, rating, bedrooms, beds, baths
  except Exception as e:
    # only return name if other fields are not available
    print('Error parsing: ' + line)
    print(e)
    return parts[i_name].strip(), None, None, None, None

# Apply the function and split the DataFrame
df[['new_name', 'rating', 'number_of_bedrooms', 'number_of_beds', 'number_of_baths']] = df['name'].apply(lambda x: pd.Series(split_name(x)))

# Drop the old 'name' column and rename the new one
df.drop(columns=['name'], inplace=True)
df.rename(columns={'new_name': 'name'}, inplace=True)

# export the DataFrame to a CSV file
df.to_csv('listings-clean.csv', index=False)