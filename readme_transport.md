The transport part uses four database:

1. Tram Route
2. Tram Stop
3. Pedestrian Count Sensor Location
4. Pedestrian Count on September

Processing Data:

1. Tram Route: no processing
2. Tram Stop: Link the tram route and tram stops together
3. Pedestrian Count Sensor Location: 
    1. Link the Sensor Location with Tram Stop by distance(500m)
    2. Link the Sensor Location with Pedestrian Count Data by Sensor Name
4. Pedestrian Count on September:
    1. Link the Sensor Location By Sensor Name
    2. Calculate the mean value of each hour by one month data