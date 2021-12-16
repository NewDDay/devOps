using Dates
a = now(UTC)
using JSON, CSV, DataFrames, Telegram, ConfigEnv, HTTP, Dates, SHA, BenchmarkTools
println("Time spend for all packages - ", now(UTC)-a)
df = DataFrame(A=1:4, B=["M", "F", "F", "M"])
println(df)
