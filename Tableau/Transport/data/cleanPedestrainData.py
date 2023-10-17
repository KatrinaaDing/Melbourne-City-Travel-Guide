import pandas as pd
import numpy as np
import geopandas as gpd

pedestrain_Data = pd.read_csv('data/September_2023.csv')
sensor_geoData = gpd.read_file('data/pedestrian-counting-system-sensor-locations.geojson')
tramStop_data = gpd.read_file(
    'data/mga2020_55/esrishape/customised_delivery/MELB_METRO_VAR1-0/PTV/CLEANED_PTV_METRO_TRAM_STOP.shp')


# clean the sensor dataset
sensors_geoData_cleaned = sensor_geoData.drop(['installation_date', 'note','location_type',
                        'status', 'direction_1', 'direction_2','sensor_name'], axis=1)

# to find the nearest sensor of each tram station
sensors_geoData_cleaned = sensors_geoData_cleaned.to_crs("EPSG:28355")
tramStop_data = tramStop_data.to_crs("EPSG:28355")

def find_nearest_sensor(tramStop_data, sensors_geoData_cleaned):
    # 计算到所有传感器的距离
    distances = sensors_geoData_cleaned.geometry.distance(tramStop_data.geometry)
    closest_sensor_index = distances.idxmin()
    
    closest_sensor_id = sensors_geoData_cleaned.loc[closest_sensor_index, 'location_id']
    return closest_sensor_id

tramStop_data['location_id'] = None  # 这会初始化一个空列

# 对于每个站点，获取最近的传感器
tramStop_data['location_id'] = tramStop_data.apply(find_nearest_sensor, args=(sensors_geoData_cleaned,), axis=1)

tramStop_data_merged_SensorLocation = pd.merge(tramStop_data, sensors_geoData_cleaned, on="location_id")
tramStop_data_merged_SensorLocation.rename(columns={'latitude': 'sensor_latitude', 
                                                    'longitude': 'sensor_longitude',
                                                    'geometry_y': 'sensor_geometry',
                                                    'sensor_description': 'Sensor Name'}, inplace=True)

print(tramStop_data_merged_SensorLocation.columns)


# clean the pedestrain data type
pedestrain_Data.replace({'na': np.nan, 'undefined': np.nan}, inplace=True)
pedestrain_Data['Date'] = pd.to_datetime(pedestrain_Data['Date'])
pedestrain_Data['Hour'] = pedestrain_Data['Hour'].astype(int)

#  get the sensor locations 
geo_columns = pedestrain_Data.columns[2:]
pedestrain_Data[geo_columns] = pedestrain_Data[geo_columns].astype(float)


average_pedestrian_per_Hour = pedestrain_Data.groupby('Hour')[geo_columns].mean()
average_pedestrian_per_Hour = average_pedestrian_per_Hour.T
average_pedestrian_per_Hour.index.name = "Sensor Name"

average_pedestrian_per_Hour_withLocation = pd.merge(tramStop_data_merged_SensorLocation, average_pedestrian_per_Hour, on='Sensor Name')
                                                                               
average_pedestrian_per_Hour_withLocation["geometry_x"].to_crs("EPSG:4326")
average_pedestrian_per_Hour_withLocation["sensor_geometry"].to_crs("EPSG:4326")

# # 4. 结果输出
# # 输出月平均人流量数据到一个新的csv文件
# #
average_pedestrian_per_Hour_withLocation.to_csv('data/average_pedestrian_per_Hour_WithLocation.csv')


