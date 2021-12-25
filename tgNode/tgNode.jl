using Telegram, Telegram.API
using ConfigEnv
using Sockets
using JSON

sendlers = Sockets.listen(IPv4("0.0.0.0"), 1999) # This is the year of my birth

#cd("/home/rosenrot/devOps/")
dotenv()
sendMessage(chat_id = 332968259, text  = "Hello world!")

@async while true
    sock = accept(sendlers)
    @async while isopen(sock)
        mail = Sockets.readuntil(sock, '\0')
        echo = JSON.parse(mail)
        sendMessage(chat_id = echo["chat_id"], text = echo["message"])
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
