/// Run with: 'dub'

// Import D standard libraries
import std.stdio;
import std.string;
import std.concurrency;

// Load the SDL2 library
import bindbc.sdl;
import loader = bindbc.loader.sharedlib;

import Server;

/**
 * The entry point of the TRUCANVAS application.
 */
// Entry point to program
void main()
{
    writeln("Welcome to TRUCANVAS!");
    writeln("Are you:");
    writeln("(0) hosting a canvas?");
    writeln("(1) joining a canvas?");

    auto userType = readln().chomp();
    if (userType == "0")
    {
        // Start the server in a new thread
        //spawn(&Server.startServer);
        Server.startServer();
    }
    else if (userType == "1")
    {
        import Client : Client;

        Client myClient = new Client;
        myClient.MainApplicationLoop();
    }
    else
    {
        writeln("Invalid user type. Defaulting to HOST..");
        // Start the server in a new thread
        spawn(&Server.startServer);
    }
}
