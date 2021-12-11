using Pkg
Pkg.add(["Telegram","ConfigEnv"])
using Telegram, Telegram.API
using ConfigEnv

# cd("./dev/")
dotenv()
sendMessage(text  = "Hello world!")
sendMessage(text = """List of available commands:\n/help\n/roll""")


run_bot() do msg
    if msg.message.text == "/help"
        sendMessage(text = """List of available commands:\n/help\n/roll""")
    elseif msg.message.text == "/roll"
        sendMessage(text = "$(rand(1:100))")
    end
end

Pkg.add(["BenchmarkTools", "UnicodePlots", "PyPlot"])
