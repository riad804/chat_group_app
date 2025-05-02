package main

import (
	"encoding/json"
	"log"
	"os"
	"sync"
	"time"

	"github.com/gofiber/contrib/websocket"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/joho/godotenv"
)

type Client struct {
	Username string
	Conn     *websocket.Conn
}

type Message struct {
	ID        string    `json:"id"`
	Username  string    `json:"username"`
	Message   string    `json:"message"`
	Timestamp time.Time `json:"timestamp"`
}

type UserEvent struct {
	Username       string    `json:"username"`
	Timestamp     time.Time `json:"timestamp"`
	ConnectedUsers []string `json:"connectedUsers"`
}

type TypingEvent struct {
	Username string `json:"username"`
	IsTyping bool   `json:"isTyping"`
}

var (
	clients   = make(map[*websocket.Conn]*Client)
	messages  = make([]Message, 0, 100)
	mutex     sync.RWMutex
	broadcast = make(chan []byte)
)

func main() {
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found")
	}

	app := fiber.New()

	app.Use(cors.New(cors.Config{
		AllowOrigins: "*",
		AllowHeaders: "Origin, Content-Type, Accept",
	}))

	app.Use("/ws", func(c *fiber.Ctx) error {
		if websocket.IsWebSocketUpgrade(c) {
			c.Locals("allowed", true)
			return c.Next()
		}
		return fiber.ErrUpgradeRequired
	})

	go handleBroadcast()

	app.Get("/ws", websocket.New(handleWebSocket))

	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
	}

	log.Printf("Server running on port %s", port)
	log.Fatal(app.Listen(":" + port))
}

func handleWebSocket(c *websocket.Conn) {
	// Register new client
	clients[c] = &Client{Conn: c}

	defer func() {
		mutex.Lock()
		if client, ok := clients[c]; ok {
			if client.Username != "" {
				// Broadcast user left message
				event := UserEvent{
					Username:       client.Username,
					Timestamp:     time.Now(),
					ConnectedUsers: getConnectedUsers(),
				}
				broadcastUserEvent("user_left", event)
			}
			delete(clients, c)
		}
		mutex.Unlock()
		c.Close()
	}()

	for {
		messageType, msg, err := c.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("error: %v", err)
			}
			return
		}

		if messageType == websocket.TextMessage {
			var data map[string]interface{}
			if err := json.Unmarshal(msg, &data); err != nil {
				log.Printf("error unmarshaling message: %v", err)
				continue
			}

			eventType, ok := data["type"].(string)
			if !ok {
				continue
			}

			mutex.Lock()
			switch eventType {
			case "join":
				if username, ok := data["username"].(string); ok {
					clients[c].Username = username
					// Send previous messages
					c.WriteJSON(fiber.Map{
						"type":     "previous_messages",
						"messages": messages,
					})
					// Broadcast user joined
					event := UserEvent{
						Username:       username,
						Timestamp:     time.Now(),
						ConnectedUsers: getConnectedUsers(),
					}
					broadcastUserEvent("user_joined", event)
				}

			case "message":
				if messageText, ok := data["message"].(string); ok {
					message := Message{
						ID:        generateID(),
						Username:  clients[c].Username,
						Message:   messageText,
						Timestamp: time.Now(),
					}
					messages = append(messages, message)
					if len(messages) > 100 {
						messages = messages[1:]
					}
					broadcastMessage("new_message", message)
				}

			case "typing":
				if isTyping, ok := data["isTyping"].(bool); ok {
					event := TypingEvent{
						Username:  clients[c].Username,
						IsTyping: isTyping,
					}
					broadcastTypingEvent("user_typing", event)
				}
			}
			mutex.Unlock()
		}
	}
}

func handleBroadcast() {
	for message := range broadcast {
		mutex.RLock()
		for client := range clients {
			if err := client.WriteMessage(websocket.TextMessage, message); err != nil {
				log.Printf("error broadcasting message: %v", err)
			}
		}
		mutex.RUnlock()
	}
}

func broadcastMessage(eventType string, message Message) {
	data := fiber.Map{
		"type": eventType,
		"data": message,
	}
	if jsonData, err := json.Marshal(data); err == nil {
		broadcast <- jsonData
	}
}

func broadcastUserEvent(eventType string, event UserEvent) {
	data := fiber.Map{
		"type": eventType,
		"data": event,
	}
	if jsonData, err := json.Marshal(data); err == nil {
		broadcast <- jsonData
	}
}

func broadcastTypingEvent(eventType string, event TypingEvent) {
	data := fiber.Map{
		"type": eventType,
		"data": event,
	}
	if jsonData, err := json.Marshal(data); err == nil {
		broadcast <- jsonData
	}
}

func getConnectedUsers() []string {
	users := make([]string, 0)
	for _, client := range clients {
		if client.Username != "" {
			users = append(users, client.Username)
		}
	}
	return users
}

func generateID() string {
	return time.Now().Format("20060102150405.000")
} 