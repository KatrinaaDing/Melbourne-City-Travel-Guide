# Restaurant Data

The restaurant data was fetched by [Google Place API](https://developers.google.com/maps/documentation/places/web-service/overview) 
and [Trip Advisor API](https://tripadvisor-content-api.readme.io/reference/overview). The city boundary data was fetched from [City of Melbourne Open Data](https://data.melbourne.vic.gov.au/explore/dataset/small-areas-for-census-of-land-use-and-employment-clue/map/?location=12,-37.81306,144.94413&basemap=jawg.light).

### Data acquisition and processing

1. Google Place API is the major API to fetch basic information of restaurants in 
City of Melbourne. In the `R/data/restaurant/fetched_process_data/data_fetching_and_processing.R` file, 
we fetched restaurant data by passing the query "restaurant in \<suburub\>" 
to [Google Place Text Search API](https://developers.google.com/maps/documentation/places/web-service/search-text)
 `https://maps.googleapis.com/maps/api/place/textsearch/output` 
to get the data in each suburb saved in `R/data/restaurant/fetched_process_data/original` folder.

2. As the data fetched from Google Text Search API has only basic information such as name, and location rating. 
We further used the [Google Place Detail Api](https://maps.googleapis.com/maps/api/place/details/json) 
to get details of the restaurant such as delivery, reservable and so forth.

3. Even though Google Place Detail API has already provided some useful details, 
we didn't find the very important information **"cuisine"**. So we then use Tripadvisor 
API to get the cuisine information. By passing the restaurant name and latitude and longitude pair to 
[Tripadvisor Find Search Api](https://tripadvisor-content-api.readme.io/reference/searchforlocations), 
we then get the corresponding location id in Tripadvisor and then use this location id to get the cuisine 
information via [Tripadvisor Location Detail API](https://tripadvisor-content-api.readme.io/reference/searchforlocations).


### Data processing

Here are descriptions for each file under `R/data/restaurant/fetched_process_data/`

| Type      | Folder/File Name             | Description                                                  |
| --------  | ----------------------       | ------------------------------------------------------------ |
| Original  | /original/restaurant-*.csv                                                 | Original data fetched from Google Place                          |
| Original  | /original/trip_data_all.rds                                                | Original data fetched from TripAdvisor                           |
| Original  | /original/small-areas-for-census-of-land-use-and-employment-clue.geojson   | City boundary data fetched from City of Melbourne open data      |
| Processed | /processed/*.csv                                                           | Intermediate processed data                                      |
| Final     | melbourne_restaurant.csv                                                   | Final data used for restaurant page                              |
| Final     | suburbs_data.geojson.                                                      | Final suburb boundaries data used for suburb filter              | 
