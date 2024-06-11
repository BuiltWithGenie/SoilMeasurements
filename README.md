## US soil measurements

This app presents the data in the <a data-cke-saved-href="https://www.kaggle.com/datasets/cdminix/us-drought-meteorological-data" target="_blank" href="https://www.kaggle.com/datasets/cdminix/us-drought-meteorological-data">US Drought Meteorological Data dataset</a>, which contains measurements of meteorological quantities taken across 56000 stations in the US.

To work with such a large dataset (2GB in CSV format), this app uses the Arrow file format to load the data, and server-side resampling for plotting.

https://github.com/BuiltWithGenie/SoilMeasurements/assets/5058397/b9a30ddc-4b0f-46c7-b3de-ab8d0ea790f4

Moreover, this app showcases the following:

- Event detection when clicking on line and map plots
- UI controls like menus, sliders, date pickers
- Two-column layout
- Plot configuration with Genie Builder
- Map for showing geospatial data

## Installation

The data included with this repo only contains measurements from three stations. You can download the full dataset [here](https://www.dropbox.com/scl/fo/43cdpk5c2454y7y1lgs1a/ACvKoEzmY7EpD12ehu8Macs?rlkey=tqizlmim2e04kqg3n0nj87i13&dl=0).

Clone the repository and install the dependencies:

First `cd` into the project directory then run:

```bash
$> julia --project -e 'using Pkg; Pkg.instantiate()'
```


Finally, run the app

```bash
$> julia --project
```

```julia
julia> using GenieFramework
julia> Genie.loadapp() # load app
julia> up() # start server
```
Finally, open your browser and navigate to `http://localhost:8000/` to use the app.
