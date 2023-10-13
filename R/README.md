# R Shiny dashboard 

## File structure

```shell
R
├── R.Rproj			
├── data						# datasets
│   ├── airbnb
│   └── geographic
├── app.R						# shiny app
├── constants_and_data.R        # constants and data import
├── libraries.R					# libraries
├── restaurant					# server and ui for restaurant tab
│   ├── restaurant_server.R
│   └── restaurant_ui.R
├── hotel						# server and ui for hotel(Airbnb) tab
│   ├── hotel_server.R
│   └── hotel_ui.R
├── attraction					# server and ui for attraction tab
│   ├── attraction_server.R
│   └── attraction_ui.R
├── transport					# server and ui for transport tab
│   ├── transport_server.R
│   └── transport_ui.R
└── www							# custom icons, css and js files
```