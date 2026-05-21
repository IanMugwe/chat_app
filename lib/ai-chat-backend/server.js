import express from "express";
import http from "http";
import { WebSocketServer } from "ws";
import cors from "cors";
import dotenv from "dotenv";
import { streamChat } from "./ai.js";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const server = http.createServer(app);
const wss = new WebSocketServer({ server });

wss.on("connection", (ws) => {
  console.log("Client connected");

  ws.on("message", async (raw) => {
    try {
      const data = JSON.parse(raw.toString());
      const userMessage = data.message;

      console.log("User:", userMessage);

      // STREAM OPENAI RESPONSE
      await streamChat(userMessage, (token) => {
        ws.send(
          JSON.stringify({
            type: "token",
            text: token,
          })
        );
      });

      ws.send(
        JSON.stringify({
          type: "done",
        })
      );
    } catch (err) {
      console.error(err);
      ws.send(
        JSON.stringify({
          type: "error",
          message: "Something went wrong",
        })
      );
    }
  });

  ws.on("close", () => {
    console.log("Client disconnected");
  });
});

server.listen(process.env.PORT || 8080, () => {
  console.log(`Server running on port ${process.env.PORT || 8080}`);
});
