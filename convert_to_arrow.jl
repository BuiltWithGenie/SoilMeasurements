#download data from https://www.kaggle.com/datasets/cdminix/us-drought-meteorological-data
using CSV, DataFrames, Arrow
df = CSV.read("data/train_data.csv", DataFrame)
function compress_data(data::DataFrame)
    io = Arrow.tobuffer(data)
    d = Arrow.Table(io; convert=false)
    Arrow.write("data/data.lz4", d; compress=:lz4)
end
compress_data(df)
