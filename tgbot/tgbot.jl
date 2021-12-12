using Pkg
Pkg.add(["Telegram","ConfigEnv", "HTTP", "JSON", "Dates", "SHA"])
using Telegram, Telegram.API
using ConfigEnv
using HTTP
using JSON
using Dates
using SHA

# cd("./dev/")
dotenv()
sendMessage(text  = "Hello world!")
sendMessage(text = """List of available commands:\n/help\n/roll\n/bnBalance""")

BINANCE_API_REST = "https://api.binance.com/"

function doSign(queryString)
    bytes2hex(hmac_sha256(Vector{UInt8}(ENV["BINANCE_PRIVATE_KEY"]), Vector{UInt8}(queryString)))
end

function timestamp()
    Int64(floor(Dates.datetime2unix(Dates.now(Dates.UTC)) * 1000))
end

function dict2Params(dict::Dict)
    params = ""
    for kv in dict
        params = string(params, "&$(kv[1])=$(kv[2])")
    end
    params[2:end]
end

function r2j(response)
    JSON.parse(String(response))
end

function bnBalance()
    headers = Dict("X-MBX-APIKEY" => ENV["BINANCE_PUBLIC_KEY"])
    query = string("recvWindow=10000&timestamp=", timestamp())

    r = HTTP.request("GET", string(BINANCE_API_REST, "api/v3/account?", query, "&signature=", doSign(query)), headers)

    balances = r2j(r.body)["balances"]
    message = ""
    for b in balances
        parse(Float64, b["free"]) > 0 ? (message = message * b["asset"] * " - " * b["free"] * "\n") : false
    end
    return message
end

run_bot() do msg
    if msg.message.text == "/help"
        sendMessage(text = """List of available commands:\n/help\n/roll\n/bnBalance""")
    elseif msg.message.text == "/roll"
        sendMessage(text = "$(rand(1:100))")
    elseif msg.message.text == "/bnBalance"
        sendMessage(text = bnBalance())
    end
end
