using Pkg
packages = ["JSON", "CSV", "DataFrames", "Telegram", "ConfigEnv", "HTTP", "Dates", "SHA", "BenchmarkTools", "Sockets", "Printf"]
Pkg.add(packages)
using JSON, CSV, DataFrames, Telegram, ConfigEnv, HTTP, Dates, SHA, BenchmarkTools, Sockets, Printf # For compilation
