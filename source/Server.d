/**
 * A D module for implementing a server with a basic communication functionality.
 */
module Server;

import std.socket;
import std.stdio;
import Packet : Packet;
import std.container : DList;
import std.algorithm.mutation;

/**
 * Returns the local IP address by connecting to an external server.
 *
 * Returns: A string representing the local IP address.
 */
auto GetIP()
{
	auto r = getAddress("8.8.8.8", 53);
	auto sockfd = new Socket(AddressFamily.INET, SocketType.STREAM);
	import std.conv;

	const char[] address = r[0].toAddrString().dup;
	ushort port = to!ushort(r[0].toPortString());
	sockfd.connect(new InternetAddress(address, port));
	auto localip = sockfd.localAddress;
	sockfd.close();
	return localip.toAddrString();
}

/**
 * Starts the server, listens for incoming connections, and handles client messages.
 */
void startServer()
{
	writeln("Starting server...");
	writeln("Server must be started before clients may join");
	auto listener = new Socket(AddressFamily.INET, SocketType.STREAM);
	scope (exit)
		listener.close();
	string host = GetIP();
	ushort port = 8020;
	writeln("Server IP: ", host, ":", port);
	listener.bind(new InternetAddress(host, port));
	// Allow 4 connections to be queued up
	listener.listen(4);

	auto readSet = new SocketSet();
	Socket[] connectedClientsList;

	// Message buffer will be large enough to send/receive Packet.sizeof
	byte[Packet.sizeof] buffer;
	DList!Packet packetQueue;

	bool serverIsRunning = true;
	bool hostClientIsRunning = false;

	auto width = 640;
	auto height = 480;

	ubyte[3][480][640] trueCanvas;

	auto disconnectClient = -1;

	// Main application loop for the server
	writeln("Awaiting client connections");
	while (serverIsRunning)
	{
		// Clear the readSet
		readSet.reset();
		// Add the server
		readSet.add(listener);

		if (disconnectClient != -1)
		{
			writeln("Removing one client at index: ", disconnectClient);
			connectedClientsList = connectedClientsList[0 .. disconnectClient] ~ connectedClientsList[disconnectClient + 1 .. $];
			disconnectClient = -1;
		}
		// Add each client to the readSet
		foreach (client; connectedClientsList)
		{
			readSet.add(client);
		}
		// Handle each clients message
		if (Socket.select(readSet, null, null))
		{
			foreach (client; connectedClientsList)
			{
				// Check to ensure that the client
				// is in the readSet before receving
				// a message from the client.
				if (readSet.isSet(client))
				{
					// Server effectively is blocked
					// until a message is received here.
					// When the message is received, then
					// we send that message from the 
					// server to the client
					auto got = client.receive(buffer);

					// Have clients disconnect properly withouth crashing the server
					if (got <= 0)
					{
						// Client has disconnected
						// Remove the client from the list
						readSet.remove(client);
						for (auto i = 0; i < connectedClientsList.length; i++)
						{
							if (connectedClientsList[i] == client)
							{
								disconnectClient = i;
								break;
							}
						}
						writeln("Client disconnected");
						continue;
					}

					// Setup a packet to echo back
					// to the client
					Packet p;
					byte[16] field0 = buffer[0 .. 16].dup;
					byte[4] field1 = buffer[16 .. 20].dup;
					byte[4] field2 = buffer[20 .. 24].dup;
					ubyte r = buffer[25];
					ubyte g = buffer[26];
					ubyte b = buffer[27];
					byte[64] field6 = buffer[28 .. 92].dup;

					char[16] user = cast(char[])(field0);
					int f1 = *cast(int*)&field1;
					int f2 = *cast(int*)&field2;
					char[64] message = cast(char[])(field6);
					p.user = user;
					p.x = f1;
					p.y = f2;
					p.r = r;
					p.g = g;
					p.b = b;
					p.message = message;

					if (p.x >= 0 && p.x < width && p.y >= 0 && p.y < height)
					{
						// Send raw bytes from packet,
						foreach (sendClient; connectedClientsList)
						{
							sendClient.send(p.GetPacketAsBytes());
						}
						trueCanvas[p.x][p.y][0] = p.r;
						trueCanvas[p.x][p.y][1] = p.g;
						trueCanvas[p.x][p.y][2] = p.b;
					}
				}
			}

			// The listener is ready to read
			// Client wants to connect so we accept here.
			if (readSet.isSet(listener))
			{
				auto newSocket = listener.accept();
				// Based on how our client is setup,
				// we need to send them an 'acceptance'
				// message, so that the client can
				// proceed forward.
				newSocket.send("Welcome from server, you are now in our connectedClientsList");
				// Add a new client to the list
				connectedClientsList ~= newSocket;

				// Sends the canvas to the new client
				for (int i = 0; i < width; i++)
				{
					for (int j = 0; j < height; j++)
					{
						if (trueCanvas[i][j][0] != 0 || trueCanvas[i][j][1] != 0 || trueCanvas[i][j][2] != 0)
						{
							Packet p;
							p.x = i;
							p.y = j;
							p.r = trueCanvas[i][j][0];
							p.g = trueCanvas[i][j][1];
							p.b = trueCanvas[i][j][2];
							p.message = "paint\0";
							newSocket.send(p.GetPacketAsBytes());
						}
					}
				}
				writeln("> client", connectedClientsList.length, " added to connectedClientsList");
			}

			while (!packetQueue.empty)
			{
				auto packet = packetQueue.front;
				packetQueue.removeFront();
				// Echo the message back to all clients
				foreach (client; connectedClientsList)
				{
					client.send(packet.GetPacketAsBytes());
				}
			}
		}

	}
}
