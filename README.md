# Melbourne-City-Travel-Guide

## Introduction

The app allows tourists to delve into Melbourne's dynamic culture, breathtaking attractions, and diverse culinary offerings. The app offers a well-designed interface, starting with an introduction page that outlines its features, which separates user needs into four specialised tabs: Restaurants, discovering top-notch restaurants; Airbnb Listings, listed cosy hotels; Attraction, outlines iconic landmarks; and Transport, provides convenient tram options. The app integrates with sophisticated filters that maximise flexibility on filtering the data. 


## Authors

  - Ziqi Ding (1335237)
  - Yiyun Mao (1304932)
  - Shiyi Xie (704597)
  - Xubin Zou (1059403)


## Demo
  * [Live demo](https://katrina-ziqi-ding.shinyapps.io/Melbourne-City-Travel-Guide/)
  * [10min video demo](https://youtu.be/4zpIQ06QSKI)

## Run App

> For best user interactions and experience of this application, please use an external browser, e.g Google Chrome.

### Running the Shiny App from terminal
> Please make sure that you are at the root project directory.
``` bash
# At the root project directory.
R -e "shiny::runApp('./R/app.R')"
```

## Directory Tree

```shell
root
├── R
│   ├──	R.Rproj					        # project file
│   ├── app.R					          # R script for Shiny app
│   ├── constants_and_data.R    # R script for constants and data import
│   ├── libraries.R				      # R script for libraries import
│   ├── attraction				      # server and ui for attraction tab
│   ├── hotel					          # server and ui for hotel(Airbnb) tab
│   ├── restaurant				      # server and ui for restaurant tab
│   ├── transport			          # server and ui for transport tab
│   ├── www						          # custom icons and css files
│   └── data					          # datasets
│       ├── airbnb
│       ├── geographic
│       ├── poi
│       └── restaurant
└── Tableau						          # Tableau workbooks
    ├── Airbnb
    ├── Attraction
    ├── Restaurant
    └── Transport
    	└── data				          # transport datasets
```

## Datasets Used

##### Restaurants

- Locations and details of Melbourne restaurants: Google Place API https://developers.google.com/maps/documentation/places/web-service/overview
- Cuisine of restaurants: Tripadvisor API https://www.tripadvisor.com/developers

##### Airbnb Listings

- Melbourne Airbnb listings http://insideairbnb.com/get-the-data/

##### Attractions

- Artworks https://data.melbourne.vic.gov.au/explore/dataset/outdoor-artworks/information/
- Places of Interest https://data.melbourne.vic.gov.au/explore/dataset/landmarks-and-places-of-interest-including-schools-theatres-health-services-spor/information/
- Fountain, Art, Monument https://data.melbourne.vic.gov.au/explore/dataset/public-artworks-fountains-and-monuments/information/
- Memorials and Sculptures https://data.melbourne.vic.gov.au/explore/dataset/public-memorials-and-sculptures/information/
- Plaques https://data.melbourne.vic.gov.au/explore/dataset/plaques-located-at-the-shrine-of-remembrance/information/
- Music Venues https://data.melbourne.vic.gov.au/explore/dataset/live-music-venues/information/
- Drinking fountains https://data.melbourne.vic.gov.au/explore/dataset/drinking-fountains/information/
- Public toilets https://data.melbourne.vic.gov.au/explore/dataset/public-toilets/information/
- Playgrounds https://data.melbourne.vic.gov.au/explore/dataset/playgrounds/information/
- Guided Walks https://data.melbourne.vic.gov.au/explore/dataset/self-guided-walks/information/

##### Transport

- Pedestrian Counting System per Hour https://www.pedestrian.melbourne.vic.gov.au/#date=20-10-2023&time=14
- Pedestrian Counting System Sensor Location https://data.melbourne.vic.gov.au/explore/dataset/pedestrian-counting-system-sensor-locations/information/
- Tram Stop https://discover.data.vic.gov.au/dataset/ptv-metro-tram-stops
- Tram Route https://discover.data.vic.gov.au/dataset/ptv-metro-tram-routes
