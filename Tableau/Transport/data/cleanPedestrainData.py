import pandas as pd
import numpy as np
import geopandas as gpd
from shapely.geometry import Point
pedestrain_Data = pd.read_csv('Tableau/Transport/data/PedestrianData.csv')
sensor_geoData = gpd.read_file(
    'Tableau/Transport/data/pedestrian-counting-system-sensor-locations.geojson')
tramStop_data_cleaned = gpd.read_file(
    'Tableau/Transport/data/mga2020_55/esrishape/customised_delivery/MELB_METRO_VAR1-0/PTV/PTV_METRO_TRAM_STOP.shp')
tramStop_data = gpd.read_file(
    'Tableau/Transport/data/mga2020_55/esrishape/customised_delivery/MELB_METRO_VAR1-0/PTV/PTV_METRO_TRAM_STOP.shp')
hotel_data = pd.read_csv('R/data/airbnb/hotels_with_suburb.csv')

RADIUS = 500

# clean the sensor dataset
sensors_geoData_cleaned = sensor_geoData.drop(['installation_date', 'note','location_type',
                        'status', 'direction_1', 'direction_2','sensor_name'], axis=1)

# to find the nearest sensor of each tram station
sensors_geoData_cleaned = sensors_geoData_cleaned.to_crs("EPSG:28355")
tramStop_data_cleaned = tramStop_data_cleaned.to_crs("EPSG:28355")
tramStop_data = tramStop_data.to_crs("EPSG:28355")

# create geo point of hotel data
# Convert hotel_data to a GeoDataFrame
hotel_data['geometry'] = [Point(xy) for xy in zip(
    hotel_data.Longitude, hotel_data.Latitude)]
hotel_data['id'] = hotel_data['id'].astype(int)
hotel_geo = gpd.GeoDataFrame(hotel_data, geometry='geometry', crs="EPSG:4326")
hotel_geo['id'] = hotel_geo['id'].astype(int)
hotel_geo = hotel_geo.to_crs("EPSG:28355")  

# calculate the nearest sensor of each tramStop
def find_nearest_sensor(tramStop_data_cleaned, sensors_geoData_cleaned):
    distances = sensors_geoData_cleaned.geometry.distance(tramStop_data_cleaned.geometry)
    limitedRange = distances[distances <= RADIUS]
    
    if limitedRange.empty:
        return None
    closest_sensor_index = limitedRange.idxmin()
    
    closest_sensor_id = sensors_geoData_cleaned.loc[closest_sensor_index, 'location_id']
    return closest_sensor_id


# calculate the nearest airbnb of each tramstop
def find_nearest_airbnb(tramStop_data, hotel_data):
    # calculate the distance to all sensors
    distances = hotel_data.geometry.distance(
        tramStop_data.geometry)
    indices_within_radius = distances[distances <= RADIUS].index
    airbnb_ids = list(set(hotel_data.loc[indices_within_radius, "id"].values))
    if len(airbnb_ids) == 0:
        return None 
    return ','.join(f'"{x}"' for x in airbnb_ids)

# put the closest sensor location id into the data
tramStop_data_cleaned['location_id'] = None
tramStop_data_cleaned['location_id'] = tramStop_data_cleaned.apply(find_nearest_sensor, args=(sensors_geoData_cleaned,), axis=1)

# put the closest range of airbnb into the data
tramStop_data['airbnb_ids'] = None
tramStop_data['airbnb_ids'] = tramStop_data_cleaned.apply(find_nearest_airbnb, args=(hotel_geo,), axis=1)
tramStop_data['near_airbnb_polygon'] = None
tramStop_data['near_airbnb_polygon'] = tramStop_data.buffer(RADIUS)


tramStop_data_merged_SensorLocation = pd.merge(tramStop_data_cleaned, sensors_geoData_cleaned, on="location_id", how='left')
tramStop_data_merged_SensorLocation.rename(columns={'latitude': 'sensor_latitude', 
                                                    'longitude': 'sensor_longitude',
                                                    'geometry_y': 'sensor_geometry',
                                                    'sensor_description': 'Sensor Name'}, inplace=True)



# clean the pedestrain data type
pedestrain_Data.replace({'na': np.nan, 'undefined': np.nan}, inplace=True)
pedestrain_Data['Date'] = pd.to_datetime(pedestrain_Data['Date'])
pedestrain_Data['Hour'] = pedestrain_Data['Hour'].astype(int)

#  get the sensor locations 
geo_columns = pedestrain_Data.columns[2:]
pedestrain_Data[geo_columns] = pedestrain_Data[geo_columns].astype(float)

# To calculate the mean pedestrain count in this month by hour 
average_pedestrian_per_Hour = pedestrain_Data.groupby('Hour')[geo_columns].mean()
average_pedestrian_per_Hour = average_pedestrian_per_Hour.T

# To put the Hour as one column and value as another column
average_pedestrian_per_Hour_reset = average_pedestrian_per_Hour.reset_index()
average_pedestrian_per_Hour_melt = pd.melt(average_pedestrian_per_Hour_reset, id_vars='index', var_name='Hour', value_name='Value')

# To let the sensor name as the index of dataset
average_pedestrian_per_Hour_melt = average_pedestrian_per_Hour_melt.rename(
    columns={'index': 'Sensor Name'})
average_pedestrian_per_Hour_withLocation = pd.merge(
    tramStop_data_merged_SensorLocation, average_pedestrian_per_Hour_melt, on='Sensor Name', how='left')

average_pedestrian_per_Hour_withLocation["geometry_x"].to_crs("EPSG:4326")
average_pedestrian_per_Hour_withLocation["sensor_geometry"].to_crs("EPSG:4326")


# Output the dataset as csv file
average_pedestrian_per_Hour_withLocation.to_csv(
   'Tableau/Transport/data/average_pedestrian_per_Hour_WithLocation.csv')

tramStop_data.to_csv(
    'Tableau/Transport/data/tramStop_airbnb_Data.csv')
