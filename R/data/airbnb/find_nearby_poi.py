import pandas as pd
import numpy as np
import geopandas as gpd
from shapely.geometry import Point

BASE_DIR = '../../..'
RADIUS = 500

# import data
# tramStop_data = gpd.read_file(
#     BASE_DIR + '/Tableau/Transport/data/mga2020_55/esrishape/customised_delivery/MELB_METRO_VAR1-0/PTV/CLEANED_PTV_METRO_TRAM_STOP.shp')
hotel_data = pd.read_csv('hotels_with_suburb.csv')
# Convert hotel_data to a GeoDataFrame
hotel_data['geometry'] = [Point(xy) for xy in zip(hotel_data.Longitude, hotel_data.Latitude)]
hotel_data['id'] = hotel_data['id'].astype(int)

# convert to geodataframe
hotel_geo = gpd.GeoDataFrame(hotel_data, geometry='geometry', crs="EPSG:4326")
hotel_geo['id'] = hotel_geo['id'].astype(int)

# match the crs
hotel_geo = hotel_geo.to_crs("EPSG:28355")  
# tramStop_data = tramStop_data.to_crs("EPSG:28355")

# calculate buffer for hotels
hotel_geo['geometry'] = hotel_geo.buffer(RADIUS)
# nearby_stops = gpd.sjoin(tramStop_data, hotel_geo, how="inner", op="within")

hotel_geo = hotel_geo[['id', 'geometry']]
print(hotel_geo.head())
# hotel_geo['nearby_stops'] = hotel_geo.apply(find_nearest_stop, args=(tramStop_data,), axis=1)
hotel_geo.to_csv('hotels_nearby_buffer.csv', index=False)
