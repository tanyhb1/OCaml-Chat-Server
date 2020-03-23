# AhrefsChatServer
This is a chat server application written in `OCaml` using the `Unix` library (together with some general purpose libraries from Jane Street). It can start in two modes:
* as a server, waiting for *one* client to connect
* as a client, taking an IP address of server to connect to.

Once connection has been established, the server and client can send messages to the other side. Should connection be terminated by the client, the server will _restart_ and continue waiting for another client. Furthermore, every incoming message will be acknowledged with the roundtrip time taken for the message.

The implementation primarily uses two threads for _receiving_ and _sending_ messages.

## Getting started
### To build the project, simply type `make`. Then, calling `./bin/chat' together with the relevant flags will start the chat as a _client_ or a _server_.

Usage: ``` Host and port are set to localhost by default. Starts as server by default, specify server_mode by using optional flag [-m 'client'/'server']
  -m {client|server} By default, starts as server
  -h Host to connect to: default localhost (127.0.0.1)
  -p Port to connect to: default 8888
```
