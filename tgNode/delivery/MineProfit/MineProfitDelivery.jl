using ConfigEnv
using HTTP
using JSON
using Dates
using SHA
using Printf
using Sockets

BINANCE_API_REST = "https://api.binance.com/"

function doSign(queryString, PRIVATE_KEY)
    bytes2hex(hmac_sha256(Vector{UInt8}(PRIVATE_KEY), Vector{UInt8}(queryString)))
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

function send2TgNode(msg::String)
    conn = Sockets.connect(IPv4("127.0.0.1"), 1999)
    Sockets.write(conn, string(msg, '\0'))
    # resp = Sockets.readuntil(conn, '\0')
    close(conn)
    # return resp
end

cd("/home/rosenrot/devOps/")
dotenv()
for user in ["KMAX", "ZDM"]
    env = JSON.parse(ENV[user])

    n = 20
    headers = Dict("X-MBX-APIKEY" => env["BINANCE_PUBLIC_KEY"])
    query = string("userName=", env["MINING_ACCOUNT"],"&algo=sha256&recvWindow=10000&timestamp=", timestamp())
    r = HTTP.request("GET", string(BINANCE_API_REST, "/sapi/v1/mining/payment/list?", query, "&signature=", doSign(query, env["BINANCE_PRIVATE_KEY"])), headers)
    profits = r2j(r.body)["data"]["accountProfits"][1:n]
    r = HTTP.request("GET", "https://api.binance.com/api/v3/avgPrice?symbol=BTCUSDT")
    BTCprice = parse(Float64, r2j(r.body)["price"])

    avrProfitAmount = 0
    avrDayHashRate = 0
    for p in profits
        avrProfitAmount += p["profitAmount"]
        avrDayHashRate += p["dayHashRate"]
    end
    avrProfitAmount = avrProfitAmount/n * 1e8
    avrDayHashRate = avrDayHashRate/n * 1e-12

    message = "👷 𝐌𝐘 𝐌𝐈𝐍𝐈𝐍𝐆 𝐏𝐑𝐎𝐅𝐈𝐓𝐒 ⛏\n---------------------------------------------------\n"
    date = Date(now(UTC))

    for p in profits
        profitAmount = p["profitAmount"] * 1e8
        dayHashRate = p["dayHashRate"] * 1e-12
        compare = " 💰"
        if profitAmount > 1.03 * avrProfitAmount
            compare = " ✅"
        elseif profitAmount < 0.97 * avrProfitAmount
            compare = " ❌"
        end
        dateString = replace(string(date), "-" => ".")[6:end]
        message = string(message, dateString, "    " , @sprintf("%.2f", dayHashRate), "    ", convert(Int64, round(profitAmount, digits=0)), "    ", @sprintf("%.2f", BTCprice*profitAmount*1e-8), "\$  ",compare, "\n")
        date -= Day(1)
    end

    message = string(message, "---------------------------------------------------\n𝗔𝗩𝗥      ", @sprintf("%.2f", avrDayHashRate), "    ", convert(Int64, round(avrProfitAmount, digits=0)), "    ", @sprintf("%.2f", BTCprice*avrProfitAmount*1e-8), "\$\n")
    message = string(message, "BTC -  ", trunc(Int, BTCprice), "\$")
    dict = Dict("chat_id" => env["TG_CHAT_ID"], "message" => message)
    mail = json(dict)
    send2TgNode(mail)
end
