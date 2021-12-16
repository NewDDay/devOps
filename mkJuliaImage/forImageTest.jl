using Dates
a = now(UTC)
using JSON, CSV, DataFrames, Telegram, ConfigEnv, HTTP, Dates, SHA, BenchmarkTools, Sockets, Printf
println("Time spend for all packages - ", now(UTC)-a)
df = DataFrame(A=["G", "O", "O", "D"], B=["J", "O", "B", "!"])
println(df)
