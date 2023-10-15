import pandas as pd
import numpy as np
import geopandas as gpd

pedestrain_Data = pd.read_csv('data/September_2023.csv')


sensor_geoData = gpd.read_file('data/pedestrian-counting-system-sensor-locations.geojson')

print(sensor_geoData)
# 2. 数据清理
# 确保日期和时间为正确的数据类型
pedestrain_Data.replace({'na': np.nan, 'undefined': np.nan}, inplace=True)
pedestrain_Data['Date'] = pd.to_datetime(pedestrain_Data['Date'])
pedestrain_Data['Hour'] = pedestrain_Data['Hour'].astype(int)


geo_columns = pedestrain_Data.columns[2:]
pedestrain_Data[geo_columns] = pedestrain_Data[geo_columns].astype(float)



average_pedestrian_per_Hour = pedestrain_Data.groupby('Hour')[geo_columns].mean()
average_pedestrian_per_Hour = average_pedestrian_per_Hour.T
average_pedestrian_per_Hour.index.name = "Sensor Name"
sensor_geoData.rename(columns={"sensor_description": "Sensor Name"}, inplace=True)

average_pedestrian_per_Hour_withLocation = pd.merge(sensor_geoData, average_pedestrian_per_Hour, on='Sensor Name')

# 4. 结果输出
# 输出月平均人流量数据到一个新的csv文件
average_pedestrian_per_Hour_withLocation.to_csv('average_pedestrian_per_Hour_WithLocation.csv')


