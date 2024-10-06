Gateway-Authenticator System designed for Godot multiplayer game.

Client connects to Gateway which interfaces with Authenticator to get login tokin / create user account. Authenticator then sends tokin to game server.
Player data is hashed and salted using sha256.
