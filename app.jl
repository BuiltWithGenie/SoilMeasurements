# the app.jl file is the main entry point to the application. It is a bridge between the UI and the data processing logic.
using GenieFramework, Arrow, DataFrames, CSV
@genietools

# the measurements taken by each station are stored in a table
df = DataFrame(Arrow.Table("data/data.lz4"))
columns = names(df)
# the soil_data table contains the location of each station along with other information
soil_data = CSV.read("data/soil_data.csv", DataFrame)

# in the reactive code block, we'll implement the logic to handle user interaction
@app begin
    # we first declare reactive variables to hold the state of the interactive UI components
    # for the select menu, we need a list of station codes, and a variable to hold the selected station code
    @out fips = soil_data.fips
    @in selected_fips = 1001
    # same for the metrics
    @out metrics = ["PS", "TS", "WS10M", "PRECTOT"]
    @in selected_metrics = ["PS", "TS", "WS10M"]
    # we expose a dataframe containing the data for the line plot configured in Genie Builder's visual editor
    @out fips_data = DataFrame("PS_date" => Date[], "PS" => Float64[], "TS_date" => Date[], "TS" => Float64[], "T2M_date" => Date[], "T2M" => Float64[], "WS10M_date" => Date[], "WS10M" => Float64[])
    @in N = 400
    # map plot data, plot configured in GB
    @out lat_fips = soil_data.lat
    @out lon_fips = soil_data.lon
    @out mapcolor = []
    @in data_click = Dict{String, Any}()  # data from map click event
    # metric shown on map
    @in map_metric = "TS"
    # date of data shown on map
    @in date = "2000-01-21"
    # when selecting a new station, metric  or N update the plot data. The isready variable is a pre-defined boolean that is set 
    # to true when the page finishes loading
    @onchange selected_fips, selected_metrics, N, isready begin
        processing = true
        fips_data[!] = DataFrame() # with the [!] suffix, the reactive variable changes in value but the update is not sent to the browser
        for m in selected_metrics
            # the lttb function resamples the data in the array to a set of N points
            idx, resampled = lttb(df[df.fips .== selected_fips, m], N)
            fips_data[!, m*"_date"] = df[df.fips .== selected_fips, :date][idx]
            fips_data[!, m] = resampled
        end
        @push fips_data # push the updated data to the browser
        processing = false
    end
    # update the map when picking a new date or metric.
    @onchange isready, date, map_metric begin
        @show "updating map with data from $date"
        mapcolor = df[df.date .== Date(date), map_metric]
    end
    # when clicking on a plot, the data_click variable will be populated with the event info
    @onchange data_click begin
        # each chart generates different event data. The map click event has a "points" field with the lat and lon
        if haskey(data_click, "points")
            lat_click, lon_click = data_click["points"][1]["lat"], data_click["points"][1]["lon"]
            #find closest fip
            distances = sqrt.((soil_data.lat .- lat_click).^2 + (soil_data.lon .- lon_click).^2)
            closest_index = argmin(distances)
            selected_fips = fips[closest_index]
        else
            # clicking on a line chart generates event data with x and y coordinates of the clicked point
            date = string(Date(unix2datetime(data_click["cursor"]["x"]/1000))) # the x point data is in Unix time
            date_data = df[(df.date .== Date(date)) .& (df.fips .== selected_fips), selected_metrics] |> Matrix |> vec
            closest_index = argmin(abs.( date_data .- (data_click["cursor"]["y"]+10))) # for some reason the y value is off by 10
            map_metric = metrics[closest_index]
        end

    end
end

# enable event detection in charts. Moreover, you'll need to add the class `sync_data` to the `plotly`
# element in the HTML code
@mounted watchplots()

# declare a route at / that'll render the HTML
@page("/", "app.jl.html")