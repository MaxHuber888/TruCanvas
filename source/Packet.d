/**
 * A D module for the Packet struct, which is used to send and receive data
 * between the client and server.
 */
module Packet;

import core.stdc.string;

// NOTE: Consider the endianness of the target machine when you 
//       send packets. If you are sending packets to different
//       operating systems with different hardware, the
//       bytes may be flipped!
//       A test you can do is to when you send a packet to a
//       operating system is send a 'known' value to the operating system
//       i.e. some number. If that number is expected (e.g. 12345678), then
//       the byte order need not be flipped.

/**
 * A struct representing a packet for sending and receiving data between
 * the client and server.
 *
 * Note: Consider the endianness of the target machine when sending packets.
 * Different operating systems and hardware may have different byte orders.
 */
struct Packet
{
	// NOTE: Packets usually consist of a 'header'
	//   	 that otherwise tells us some information
	//  	 about the packet. Maybe the first byte
	// 	 	 indicates the format of the information.
	// 		 Maybe the next byte(s) indicate the length
	// 		 of the message. This way the server and
	// 		 client know how much information to work
	// 		 with.
	// For this example, I have a 'fixed-size' Packet
	// for simplicity -- effectively cramming every
	// piece of information I can think of.

	char[16] user; // Perhaps a unique identifier 
	int x;
	int y;
	ubyte r;
	ubyte g;
	ubyte b;
	char[64] message; // for debugging

	/// Purpose of this function is to pack a bunch of
	/// bytes into an array for 'serialization' or otherwise
	/// ability to send back and forth across a server, or for
	/// otherwise saving to disk.	

	/**
     * Returns a char array containing the packet data for serialization
     * or for sending between the client and server.   
     * Purpose of this function is to pack a bunch of
     * bytes into an array for 'serialization' or otherwise
     * ability to send back and forth across a server, or for
     * otherwise saving to disk.
     *
     * @return A char array of size Packet.sizeof containing the packet data.
     */
	char[Packet.sizeof] GetPacketAsBytes()
	{
		//user = "test user\0";
		//message = "test message\0";
		char[Packet.sizeof] payload;
		// Populate the payload with some bits
		// I used memmove for this to move the bits.
		memmove(&payload, &user, user.sizeof);
		memmove(&payload[16], &x, x.sizeof);
		memmove(&payload[20], &y, y.sizeof);

		memmove(&payload[25], &r, r.sizeof);
		memmove(&payload[26], &g, g.sizeof);
		memmove(&payload[27], &b, b.sizeof);

		memmove(&payload[28], &message, message.sizeof);
		// Populate the color with some bytes
		import std.stdio;

		// writeln("USER: ", user);
		// writeln("x is:", x);
		// writeln("y is:", y);
		// writeln("r is:", r);
		// writeln("g is:", g);
		// writeln("b is:", b);
		// writeln("msg is:", message);

		return payload;
	}
}
