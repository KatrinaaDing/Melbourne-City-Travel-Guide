# Dataset of Airbnb

Data source: [Inside Airbnb: Get the Data](http://insideairbnb.com/get-the-data/)

Download date: 05 Oct 2023

## Files Description

| Type    | File Name                 | Description                                                  |
| ------- | ------------------------- | ------------------------------------------------------------ |
| Dataset | listings-clean.csv        | Summary of listing after cleaned. The name column is splited into `name`, `rating`, `review`, `bedrooms`, `beds`, `bathrooms`. |
| Dataset | hotels_nearby_buffer.csv  | Cleaned Airbnb listings dataset with buffer polygons.        |
| Script  | hotels_nearby_stops.csv   | Cleaned Airbnb listings dataset with nearby tram stops.      |
| Script  | hotels_with_suburb.csv    | Cleaned Airbnb listings dataset with Suburb name.            |
| Script  | data_processing.R         | R script to identify located suburb for each Airbnb listing. |
| Script  | find_nearby_tram_stops.py | Python script to calculate distance from each Airbnb listing to tram stop and keep those within 500m. |
| Script  | clean.py                  | Clean the original dataset and split columns.                |
| Script  | create_hotels_buffer.py   | Python script to create buffer for each Airbnb listing.      |
