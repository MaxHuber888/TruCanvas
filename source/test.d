module test;
import std.conv;
import std.exception;
import Client : Client;
import Window : Window;
import Surface : Surface;
import Packet : Packet;
import Pixel : Pixel;
import std.algorithm;
import std.stdio;
import std.conv;
import std.net.isemail;
import std.net.curl;

import std.socket;

import std.range;

// Import D standard libraries

import std.string;
import std.concurrency;

// Load the SDL2 library
import bindbc.sdl;
import loader = bindbc.loader.sharedlib;

import Server;

@("Client constructor")
unittest
{
    auto client = new Client;
    assert(client !is null);
}

version (unittest)
{
    import std.stdio;
    import std.string;
    import std.process;
    import std.conv;
    import core.thread;
    import core.time;

    unittest
    {
        // Test Window constructor with different dimensions
        auto surface1 = new Surface(200, 200, 32);
        auto window1 = new Window(200, 200, surface1);

        assert(window1 !is null, "Failed to create window with different dimensions.");
        assert(window1.window !is null, "Failed to create SDL_Window with different dimensions.");
        assert(window1.imgSurface !is null, "Failed to set surface with different dimensions.");

        // Test updateWindow with different surface dimensions
        auto surface2 = new Surface(200, 200, 32);
        auto window2 = new Window(100, 100, surface2);
        window2.updateWindow();

        // Test updateWindow with a sequence of updates
        auto surface3 = new Surface(100, 100, 32);
        auto window3 = new Window(100, 100, surface3);
        window3.updateWindow();
        window3.updateWindow();
        window3.updateWindow();
    }
}

@("Checking expected pixel value after arbitrary change")
unittest
{
    Surface s = new Surface(640, 480, 32);
    int x = 240;
    int y = 240;
    ubyte b = 100;
    ubyte g = 101;
    ubyte r = 102;
    s.UpdateSurfacePixel(x, y, r, g, b);
    assert(s.PixelAt(x, y).b == 100 &&
            s.PixelAt(x, y).g == 101 &&
            s.PixelAt(x, y)
            .r == 102, "error bgr value at x,y is wrong!");
}

@("Another check for expected pixel value after arbitrary change")
unittest
{
    Surface s = new Surface(640, 480, 32);
    int x = 240;
    int y = 240;
    ubyte b = 101;
    ubyte g = 102;
    ubyte r = 103;
    s.UpdateSurfacePixel(x, y, r, g, b);
    assert(s.PixelAt(x, y).b == 101 &&
            s.PixelAt(x, y).g == 102 &&
            s.PixelAt(x, y)
            .r == 103, "error bgr value at x,y is wrong!");
}

@("Checking edge case at beginning end of pixels")
unittest
{
    Surface s = new Surface(640, 480, 32);
    int x = 0;
    int y = 0;
    ubyte b = 0;
    ubyte g = 0;
    ubyte r = 0;
    s.UpdateSurfacePixel(x, y, r, g, b);
    assert(s.PixelAt(x, y).b == 0 &&
            s.PixelAt(x, y).g == 0 &&
            s.PixelAt(x, y)
            .r == 0, "error bgr value at 0,0 is wrong!");
}

@("Checking edge case at bottom corner end of pixels")
unittest
{
    Surface s = new Surface(640, 480, 32);
    // due to zero indexing, this is the bottom right
    int x = 639;
    int y = 479;
    ubyte b = 255;
    ubyte g = 255;
    ubyte r = 255;
    s.UpdateSurfacePixel(x, y, r, g, b);
    assert(s.PixelAt(x, y).b == 255 &&
            s.PixelAt(x, y).g == 255 &&
            s.PixelAt(x, y)
            .r == 255, "error bgr value at bottom right corner is wrong!");
}

@("Checking to confirm functionality of blue pixel function")
unittest
{
    Surface s = new Surface(640, 480, 32);
    // due to zero indexing, this is the bottom right
    int x = 100;
    int y = 100;
    int x2 = 101;
    s.UpdateBluePixel(x, y);
    s.UpdateSurfacePixel(x2, y, 32, 128, 255);
    assert(s.PixelAt(x, y).b == s.PixelAt(x2, y).b &&
            s.PixelAt(x, y)
            .g == s.PixelAt(x2, y).g &&
            s.PixelAt(x, y).r == s.PixelAt(x2, y).r, "error bgr value of blue pixel is incorrect!");
}

@("Checking greyscale function on a surface")
unittest
{
    Surface s = new Surface(640, 480, 32);
    // Set pixel values
    int x = 100;
    int y = 100;
    ubyte b = 255;
    ubyte g = 255;
    ubyte r = 255;
    s.UpdateSurfacePixel(x, y, b, g, r);

    // Assert pixel values before applying greyscale
    assert(s.PixelAt(x, y).b == 255 &&
            s.PixelAt(x, y).g == 255 &&
            s.PixelAt(x, y)
            .r == 255, "Error: BGR value at x,y is wrong!");

    // Apply greyscale
    s.GreyScaleAll();

    // Calculate the greyscale value
    ubyte greyValue = cast(ubyte)((r + g + b) / 3);

    // Assert pixel values after applying greyscale
    assert(s.PixelAt(x, y).b == greyValue &&
            s.PixelAt(x, y).g == greyValue &&
            s.PixelAt(x, y).r == greyValue, "Error: Greyscale value at x,y is wrong!");
}

@("Checking get IP address function")
unittest
{
    auto r = getAddress("8.8.8.8", 53);
    auto sockfd = new Socket(AddressFamily.INET, SocketType.STREAM);
    import std.conv;

    const char[] address = r[0].toAddrString().dup;
    ushort port = to!ushort(r[0].toPortString());
    sockfd.connect(new InternetAddress(address, port));
    auto localip = sockfd.localAddress;
    sockfd.close();
    assert(localip.toAddrString() == Server.GetIP());
}

@("Checking packet sending and receiving")
unittest
{
    string host = GetIP();
    ushort port = 1234;

    // Create a server and client
    auto server = new Socket(AddressFamily.INET, SocketType.STREAM);
    auto readSet = new SocketSet();

    auto client = new Socket(AddressFamily.INET, SocketType.STREAM);
    byte[Packet.sizeof] buffer;

    scope (exit)
    {
        server.close();
        client.close();
    }

    server.bind(new InternetAddress(host, port));
    server.listen(1);
    readSet.reset();
    readSet.add(server);

    client.connect(new InternetAddress(host, port));
    Socket clientSocket;

    if (Socket.select(readSet, null, null))
    {
        if (readSet.isSet(server))
        {
            clientSocket = server.accept();
            readSet.add(clientSocket);
        }
    }

    // Create a packet
    Packet* packet = new Packet;
    packet.message = "paint\0";
    packet.x = 100;
    packet.y = 100;
    packet.r = 255;
    packet.g = 255;
    packet.b = 255;

    // Send the packet to the server
    client.send(packet.GetPacketAsBytes());
    auto got = clientSocket.receive(buffer);

    byte[4] field1 = buffer[16 .. 20].dup;
    byte[4] field2 = buffer[20 .. 24].dup;
    ubyte r = buffer[25];
    ubyte g = buffer[26];
    ubyte b = buffer[27];
    byte[64] field6 = buffer[28 .. 92].dup;

    int x = *cast(int*)&field1;
    int y = *cast(int*)&field2;
    char[64] message = cast(char[])(field6);

    // Assert that the packet was received correctly
    assert(message == packet.message, "Error: Packet message is wrong!");
    assert(x == packet.x, "Error: Packet x is wrong!");
    assert(y == packet.y, "Error: Packet y is wrong!");
    assert(r == packet.r, "Error: Packet r is wrong!");
    assert(g == packet.g, "Error: Packet g is wrong!");
    assert(b == packet.b, "Error: Packet b is wrong!");
}
