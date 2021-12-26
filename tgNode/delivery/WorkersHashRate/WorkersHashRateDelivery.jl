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
    if user == "ZDM"
        avrHR = 10
    elseif user == "KMAX"
        avrHR = 9
    end
    env = JSON.parse(ENV[user])

    headers = Dict("X-MBX-APIKEY" => env["BINANCE_PUBLIC_KEY"])
    query = string("userName=", env["MINING_ACCOUNT"],"&algo=sha256&recvWindow=10000&timestamp=", timestamp())
    r = HTTP.request("GET", string(BINANCE_API_REST, "/sapi/v1/mining/worker/list?", query, "&signature=", doSign(query, env["BINANCE_PRIVATE_KEY"])), headers)
    profits = r2j(r.body)["data"]["workerDatas"]
    message = "⛰⛏ WORKERS HASH RATE 💰\n---------------------------------------------------\n"
    for p in profits
        rt = @sprintf("%.2f", p["hashRate"] * 1e-12)
        daily = @sprintf("%.2f",p["dayHashRate"] * 1e-12)
        compare = "🤔"
        if ((p["hashRate"] * 1e-12) > 10) && ((p["dayHashRate"] * 1e-12) > avrHR)
            compare = "🟢"
        elseif ((p["hashRate"] * 1e-12) < 10) && ((p["dayHashRate"] * 1e-12) < avrHR)
            compare = "🔴"
        end
        message = string(message, p["workerName"], "    ", rt, length(rt) < 5 ? "       " : "    ", daily, length(daily) < 5 ? "      " : "    ", compare, "\n")
    end
    dict = Dict("chat_id" => env["TG_CHAT_ID"], "message" => message)
    mail = json(dict)
    send2TgNode(mail)
end
