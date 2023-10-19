import pandas as pd
import numpy as np
import geopandas as gpd
from shapely.geometry import Point


BASE_DIR = '../../..'
RADIUS = 500

# find the nearest sensor for each tram stop
def find_nearest_stop(hotel_data, tramStop_data):
    # calculate the distance to all sensors
    distances = hotel_data.geometry.distance(tramStop_data.geometry)
    indices_within_radius = distances[distances <= RADIUS].index
    stop_names = list(set(tramStop_data.loc[indices_within_radius, "STOP_NAME"].values))

    if len(stop_names) == 0:
        return None
      
    # return limitedRange
    # closest_stop_name = tramStop_data.loc[tramStop_data, 'location_id']
    # return closest_sensor_id
    return ', '.join(f'"{x}"' for x in stop_names)
  
# import data
tramStop_data = gpd.read_file(
    BASE_DIR + '/Tableau/Transport/data/mga2020_55/esrishape/customised_delivery/MELB_METRO_VAR1-0/PTV/CLEANED_PTV_METRO_TRAM_STOP.shp')
hotel_data = pd.read_csv('hotels_with_suburb.csv')
# Convert hotel_data to a GeoDataFrame
hotel_data['geometry'] = [Point(xy) for xy in zip(hotel_data.Longitude, hotel_data.Latitude)]
hotel_data['id'] = hotel_data['id'].astype(int)
print(hotel_data.head())
hotel_geo = gpd.GeoDataFrame(hotel_data, geometry='geometry', crs="EPSG:4326")
hotel_geo['id'] = hotel_geo['id'].astype(int)
print(hotel_geo.head())

# match the crs
hotel_geo = hotel_geo.to_crs("EPSG:28355")  
tramStop_data = tramStop_data.to_crs("EPSG:28355")

# calculate buffer for hotels
# hotel_geo['buffer'] = hotel_geo.buffer(RADIUS)
# nearby_stops = gpd.sjoin(tramStop_data, hotel_geo, how="inner", op="within")

hotel_geo['nearby_stops'] = hotel_geo.apply(find_nearest_stop, args=(tramStop_data,), axis=1)
hotel_geo.to_csv('hotels_nearby_stops.csv', index=False)
