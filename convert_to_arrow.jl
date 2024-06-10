#download data from https://www.kaggle.com/datasets/cdminix/us-drought-meteorological-data
using CSV, DataFrames, Arrow
df = CSV.read("archive/train_timeseries/train_timeseries.csv", DataFrame)
function compress_data(data::DataFrame)
    io = Arrow.tobuffer(data)
    d = Arrow.Table(io; convert=false)
    Arrow.write("data.lz4", d; compress=:lz4)
end
compress_data(df)
cp("archive/soil_data.csv", "soil_data.csv", force=true)
