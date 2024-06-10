## US soil measurements

This app presents the data in the <a data-cke-saved-href="https://www.kaggle.com/datasets/cdminix/us-drought-meteorological-data" target="_blank" href="https://www.kaggle.com/datasets/cdminix/us-drought-meteorological-data">US Drought Meteorological Data dataset</a>, which contains measurements of meteorological quantities taken across 56000 stations in the US.

To work with such a large dataset (2GB in CSV format), this app uses the Arrow file format to load the data, and server-side resampling for plotting.

## Installation


Clone the repository and install the dependencies:

First `cd` into the project directory then run:

```bash
$> julia --project -e 'using Pkg; Pkg.instantiate()'
```
Then, download the dataset from [Kaggle](https://www.kaggle.com/datasets/cdminix/us-drought-meteorological-data) and convert it to .arrow with the `convert_to_arrow.jl` script:

```bash
$> julia --project -e 'include("convert_to_arrow.jl")'
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

## Usage

Open your browser and navigate to `http://localhost:8000/`
