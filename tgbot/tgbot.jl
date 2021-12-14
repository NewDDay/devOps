using Pkg
Pkg.add(["Telegram","ConfigEnv", "HTTP", "JSON", "Dates", "SHA", "Printf"])
using Telegram, Telegram.API
using ConfigEnv
using HTTP
using JSON
using Dates
using SHA
using Printf

# cd("./dev/")
dotenv()
sendMessage(text  = "Hello world!")
sendMessage(text = """List of available commands:\n/help\n/roll\n/bnBalance\n/myMine""")

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
    message = "💰 𝐌𝐘 𝐅𝐈𝐀𝐓 𝐀𝐍𝐃 𝐒𝐏𝐎𝐓 𝐖𝐀𝐋𝐋𝐄𝐓 💰\n---------------------------------------------------\n"
    for b in balances
        parse(Float64, b["free"]) > 0 ? (message = message * b["free"] * " " * b["asset"] * "\n") : false
    end
    return message
end

function myMine()
    n = 20
    headers = Dict("X-MBX-APIKEY" => ENV["BINANCE_PUBLIC_KEY"])
    query = string("userName=village2021&algo=sha256&recvWindow=10000&timestamp=", timestamp())
    r = HTTP.request("GET", string(BINANCE_API_REST, "/sapi/v1/mining/payment/list?", query, "&signature=", doSign(query)), headers)
    balances = r2j(r.body)
    r = HTTP.request("GET", "https://api.binance.com/api/v3/avgPrice?symbol=BTCUSDT")
    price = parse(Float64, r2j(r.body)["price"])
    message = "👷 𝐌𝐘 𝐌𝐈𝐍𝐈𝐍𝐆 𝐏𝐑𝐎𝐅𝐈𝐓𝐒 ⛏\n---------------------------------------------------\n"
    date = Date(now(UTC))
    sum6 = 0 # for comparing
    dhr_sum = 0
    for b in balances["data"]["accountProfits"][1:n]
        dhr = b["dayHashRate"] / 1e12
        pa = Int(b["profitAmount"] * 1e8)
        sum6 += pa
        dhr_sum += dhr
    end
    for b in balances["data"]["accountProfits"][1:n]
        dhr = b["dayHashRate"] / 1e12
        pa = Int(b["profitAmount"] * 1e8)
        compare = " 💰"
        if pa > 1.03*sum6/n
            compare = " ✅"
        elseif pa < 0.97*sum6/n
            compare = " ❌"
        end
        dateString = replace(string(date), "-" => ".")[6:end]
        message = string(message, dateString, "    " , @sprintf("%.2f", dhr), "    ", pa, "    ", @sprintf("%.2f", pa*price*1e-8), "\$  ",compare, "\n")
        date -= Day(1)
    end
    #println(balances["data"]["accountProfits"][1]["profitAmount"])
    message = string(message, "---------------------------------------------------\n𝗔𝗩𝗥      ", @sprintf("%.2f", dhr_sum/n), "    ", trunc(Int, sum6/n), "    ", @sprintf("%.2f", sum6/n*price*1e-8), "\$\n")
    message = string(message, "BTC -  ", trunc(Int, price), "\$")
    return message
end

run_bot() do msg
    if msg.message.text == "/help"
        sendMessage(text = """List of available commands:\n/help\n/roll\n/bnBalance\n/myMine""")
    elseif msg.message.text == "/roll"
        sendMessage(text = "$(rand(1:100))")
    elseif msg.message.text == "/bnBalance"
        sendMessage(text = bnBalance())
    elseif msg.message.text == "/myMine"
        sendMessage(text = myMine())
    end
end
