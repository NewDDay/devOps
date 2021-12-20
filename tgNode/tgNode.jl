using Telegram, Telegram.API
using ConfigEnv
using Sockets

sendlers = Sockets.listen(IPv4("127.0.0.1"), 1999) # This is the year of my birth

# cd("./dev/devOps/tgNode")
dotenv()
sendMessage(text  = "Hello world!")

@async while true
    sock = accept(sendlers)
    @async while isopen(sock)
        echo = Sockets.readuntil(sock, '\0')
        println(echo)
        sendMessage(text = echo)
        result = echo |> Meta.parse |> eval #parse code
        Sockets.write(sock, string(result, '\0'))
    end
end

run_bot() do msg
    if msg.message.text == "/help"
        sendMessage(text = """List of available commands:\n/help\n/roll""")
    elseif msg.message.text == "/roll"
        sendMessage(text = "$(rand(1:100))")
    end
end
