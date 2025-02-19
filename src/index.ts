import { WebSocketServer } from "ws";

const wss = new WebSocketServer({ port:3000 });

wss.on("connection", (socket)=> {
    console.log('connected!')

    console.log("API_KEY: a75db8c5-3078-4c50-8ecf-feb06b00b20e")

    socket.on("message", (e)=>{
        console.log(e.toString())
        if (e.toString() === 'ping'){
            socket.send('pong')
        }
    })
})

