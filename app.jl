using GenieFramework, Arrow, DataFrames, CSV
@genietools

df = DataFrame(Arrow.Table("data.lz4"))
columns = names(df)
soil_data = CSV.read("soil_data.csv", DataFrame)

@app begin
    @out fips = soil_data.fips
    @in selected_fips = 1001
    @out metrics = ["PS", "TS", "T2M", "WS10M", "PRECTOT"]
    @in selected_metrics = ["PS", "TS", "WS10M"]
    @out fips_data = DataFrame("PS_date" => Date[], "PS" => Float64[], "TS_date" => Date[], "TS" => Float64[], "T2M_date" => Date[], "T2M" => Float64[], "WS10M_date" => Date[], "WS10M" => Float64[])
    @in N = 400
    @out processing = false
    @out lat_fips = soil_data.lat
    @out lon_fips = soil_data.lon
    @in date = Date("2000-01-01")
    @in data_click = Dict{String, Any}()  # data from map click event
    @out mapcolor = []
    @in map_metric = "TS"
    @onchange isready begin
        @show "page loaded"
    end
    @onchange selected_fips, selected_metrics, N, isready begin
        @show selected_fips, selected_metrics, N
        processing = true
        fips_data[!] = DataFrame()
        for m in selected_metrics
            idx, resampled = lttb(df[df.fips .== selected_fips, m], N)
            fips_data[!, m*"_date"] = df[df.fips .== selected_fips, :date][idx]
            fips_data[!, m] = resampled
        end
        @push fips_data
        processing = false
    end
    @onchange data_click begin
        @show data_click
        if haskey(data_click, "points")
        lat_click, lon_click = data_click["points"][1]["lat"], data_click["points"][1]["lon"]
        #find closest fip
        distances = sqrt.((soil_data.lat .- lat_click).^2 + (soil_data.lon .- lon_click).^2)
        closest_index = argmin(distances)
        selected_fips = fips[closest_index]
    else
        date = unix2datetime(data_click["cursor"]["x"]/1000)
        date_data = df[(df.date .== date) .& (df.fips .== selected_fips), metrics] |> Matrix |> vec
        closest_index = argmin(abs.( date_data .- data_click["cursor"]["y"]))
        map_metric = metrics[closest_index]
    end

    end
    @onchange isready, date, map_metric begin
        @show "updating map with data from $date"
        mapcolor = df[df.date .== Date(date), map_metric]
    end
end

@mounted watchplots()

@page("/", "app.jl.html")
