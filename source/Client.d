/**
 * A D module for a Client implementation that creates a window and communicates with a server.
 */
module Client;

// Import D standard libraries
import std.stdio;
import std.string;
import std.conv : to;
import std.socket;
import std.algorithm : equal;

// Load the SDL2 library
import bindbc.sdl;
import loader = bindbc.loader.sharedlib;

import Surface : Surface;
import Window : Window;
import Packet : Packet;
import std.container : DList;

SDLSupport ret;

/**
 * The Client class encapsulates the functionality of the client-side of a socket connection
 * and provides methods for setting up the window, managing user input, and communicating
 * with a server.
 */
class Client
{
    string hostIP = "";
    ushort portShort = 0;
    bool hasIP = 0;
    bool buttonsZones = 0;
    int brushSize = 4;
    bool isCircle = 0;
    bool isDottedCircle = 0;
    bool isSquare = 0;
    bool isDottedSqaure = 0;
    this()
    {
        // Load the SDL libraries from bindbc-sdl
        // on the appropriate operating system
        version (Windows)
        {
            writeln("Searching for SDL on Windows");
            ret = loadSDL("SDL2.dll");
        }
        version (OSX)
        {
            writeln("Searching for SDL on Mac");
            ret = loadSDL();
        }
        version (linux)
        {
            writeln("Searching for SDL on Linux");
            ret = loadSDL();
        }

        // Error if SDL cannot be loaded
        if (ret != sdlSupport)
        {
            writeln("error loading SDL library");

            foreach (info; loader.errors)
            {
                writeln(info.error, ':', info.message);
            }
        }
        if (ret == SDLSupport.noLibrary)
        {
            writeln("error no library found");
        }
        if (ret == SDLSupport.badLibrary)
        {
            writeln(
                "Eror badLibrary, missing symbols, perhaps an older or very new version of SDL is causing the problem?");
        }

        // Initialize SDL
        if (SDL_Init(SDL_INIT_EVERYTHING) != 0)
        {
            writeln("SDL_Init: ", fromStringz(SDL_GetError()));
        }
    }

    /**
     * Constructs a Client object with a specified hostIP and portShort.
     *
     * Params:
     *     hostIP = A string representing the IP address of the host
     *     portShort = A ushort representing the port number
     */
    this(string hostIP, ushort portShort)
    {
        this();
        this.hostIP = hostIP;
        this.portShort = portShort;
        this.hasIP = 1;
    }

    /**
     * Destructor for the Client class.
     */
    ~this()
    {
        // Quit the SDL Application 
        SDL_Quit();
        writeln("Ending application--good bye!");
    }

    /**
* The MainApplicationLoop handles the creation and updating of the window, user input,
* and communication with a server through a socket connection.
*/
    void MainApplicationLoop()
    {
        writeln("Starting client...attempt to create socket");
        // Create a socket for connecting to a server
        auto socket = new Socket(AddressFamily.INET, SocketType.STREAM);
        // Socket needs an 'endpoint', so we determine where we
        // are going to connect to.
        // NOTE: It's possible the port number is in use if you are not
        //       able to connect. Try another one.
        string host;
        ushort port;
        string portStr;

        if (hasIP == 1)
        {
            // Set values that were passed from Server
            host = hostIP;
            port = portShort;
        }
        else
        {
            // ask the user for the host and port
            writeln("Enter the host: ");
            host = readln().chomp();
            writeln("Enter the port: ");
            //port = to!ushort(readln().chomp() == "" ? "0" : readln().chomp());
            portStr = readln().chomp();
            if (host == "")
            {
                host = "10.0.2.15";
            }
            if (portStr == "")
            {
                portStr = "8020";
            }
            port = to!ushort(portStr);
        }

        socket.connect(new InternetAddress(host, port));
        scope (exit)
        {
            socket.close();
        }
        writeln("Connected");

        byte[Packet.sizeof] buffer;

        auto received = socket.receive(buffer);
        writeln("On Connect: ", buffer[0 .. received]);
        socket.blocking(false);

        Packet data;

        // Create an SDL window
        auto width = 640;
        auto height = 480;
        auto depth = 32;
        Surface imgSurface = new Surface(width, height, depth);
        Window window = new Window(width, height, imgSurface);

        // Set paint color
        ubyte redpaint = 255;
        ubyte greenpaint = 255;
        ubyte bluepaint = 255;

        // Set message
        char[64] packMessage = "paint\0";

        // Flag for determing if we are running the main application loop
        bool runApplication = true;
        // Flag for determining if we are 'drawing' (i.e. mouse has been pressed
        //                                                but not yet released)
        bool drawing = false;

        // Main application loop that will run until a quit event has occurred.
        // This is the 'main graphics loop'
        while (runApplication)
        {
            SDL_Event e;
            //writeln("Starting event loop...");
            // Handle events
            // Events are pushed into an 'event queue' internally in SDL, and then
            // handled one at a time within this loop for as many events have
            // been pushed into the internal SDL queue. Thus, we poll until there
            // are '0' events or a NULL event is returned.
            while (SDL_PollEvent(&e) != 0)
            {
                //For each event, we need to know the mouse position
                int xPos = e.button.x;
                int yPos = e.button.y;

                if (e.type == SDL_QUIT)
                {
                    runApplication = false;
                }
                else if (e.type == SDL_MOUSEBUTTONDOWN)
                {
                    buttonsZones = 0;
                    if (yPos < (height - 84))
                    {
                        drawing = true;
                    }
                    else
                    {
                        if (yPos > 440)
                        {
                            buttonsZones = 1;
                        }
                        //Which Button is it?
                        switch (xPos)
                        {
                        case 3: .. case 80:
                            imgSurface.animateButton(buttonsZones, 0);
                            if (buttonsZones == 1) //circle brush filled
                            {
                                isCircle = 1;
                                isDottedCircle = 0;
                                isSquare = 0;
                                isDottedSqaure = 0;

                            }
                            else //red
                            {
                                redpaint = 255;
                                greenpaint = 0;
                                bluepaint = 0;
                                packMessage = "paint\0";
                            }
                            break;
                        case 83: .. case 160:
                            imgSurface.animateButton(buttonsZones, 1);
                            if (buttonsZones == 1) //circle brush shading
                            {
                                isCircle = 0;
                                isDottedCircle = 1;
                                isSquare = 0;
                                isDottedSqaure = 0;
                            }
                            else //orange 255,99,71
                            {
                                redpaint = 255;
                                greenpaint = 99;
                                bluepaint = 71;
                                packMessage = "paint\0";
                            }

                            break;
                        case 163: .. case 240:
                            imgSurface.animateButton(buttonsZones, 2);
                            if (buttonsZones == 1) // brush size up
                            {
                                brushSize++;
                                if (brushSize >= 18)
                                {
                                    brushSize = 18;
                                }
                            }
                            else //yellow 255,255,0
                            {
                                redpaint = 255;
                                greenpaint = 255;
                                bluepaint = 0;
                                packMessage = "paint\0";
                            }
                            break;
                        case 243: .. case 320:
                            imgSurface.animateButton(buttonsZones, 3);
                            if (buttonsZones == 1) //brush size down
                            {
                                brushSize--;
                                if (brushSize < 4)
                                {
                                    brushSize = 4;
                                }
                            }
                            else //green 0,255,127
                            {
                                redpaint = 0;
                                greenpaint = 255;
                                bluepaint = 127;
                                packMessage = "paint\0";
                            }

                            break;
                        case 323: .. case 400:
                            imgSurface.animateButton(buttonsZones, 4);
                            if (buttonsZones == 1)
                            {

                                packMessage = "clear\0";

                                with (data)
                                {
                                    user = "clientName\0";
                                    x = xPos;
                                    y = yPos;
                                    r = redpaint;
                                    g = greenpaint;
                                    b = bluepaint;
                                    message = packMessage;
                                }
                                socket.send(data.GetPacketAsBytes());
                                packMessage = "paint\0";
                            }
                            else //blue 0,0,255
                            {
                                redpaint = 0;
                                greenpaint = 0;
                                bluepaint = 255;
                                packMessage = "paint\0";
                            }

                            break;
                        case 403: .. case 480:
                            imgSurface.animateButton(buttonsZones, 5);
                            if (buttonsZones == 1)
                            {
                                redpaint = 0;
                                greenpaint = 0;
                                bluepaint = 0;
                                brushSize = 10;
                            }
                            else //pink 238,130,238
                            {
                                redpaint = 238;
                                greenpaint = 130;
                                bluepaint = 238;
                                packMessage = "paint\0";
                            }

                            break;
                        case 483: .. case 560:
                            imgSurface.animateButton(buttonsZones, 6);
                            if (buttonsZones == 1)
                            {
                                isCircle = 0;
                                isDottedCircle = 0;
                                isSquare = 1;
                                isDottedSqaure = 0;
                            }
                            else if (buttonsZones == 0)
                            {
                                redpaint = 150;
                                greenpaint = 75;
                                bluepaint = 0;
                                packMessage = "paint\0";
                            }

                            break;
                        case 563: .. case 637:
                            imgSurface.animateButton(buttonsZones, 7);
                            if (buttonsZones == 1)
                            {
                                isCircle = 0;
                                isDottedCircle = 0;
                                isSquare = 0;
                                isDottedSqaure = 1;
                            }
                            else if (buttonsZones == 0)
                            {

                                packMessage = "grey\0";
                                imgSurface.animateButton(0, 7);
                                with (data)
                                {
                                    user = "clientName\0";
                                    x = xPos;
                                    y = yPos;
                                    r = redpaint;
                                    g = greenpaint;
                                    b = bluepaint;
                                    message = packMessage;
                                }
                                socket.send(data.GetPacketAsBytes());
                                packMessage = "paint\0";
                            }
                            break;
                        default:
                            break;
                        }
                    }

                }
                else if (e.type == SDL_MOUSEBUTTONUP)
                {
                    drawing = false;
                }
                else if (e.type == SDL_MOUSEMOTION && drawing && yPos < (height - 84))
                {
                    // Loop through and update specific pixels
                    int centerX = brushSize / 2;
                    int centerY = brushSize / 2;
                    int radius = centerX * 2;

                    for (int w = -brushSize; w < brushSize; w++)
                    {
                        for (int h = -brushSize; h < brushSize; h++)
                        {

                            int dx = w - centerX;
                            int dy = h - centerY;
                            int distance = w * w + h * h;
                            bool brushType = 1;
                            if (isDottedCircle == 1)
                            {
                                brushType = (distance <= radius * radius) && w % 2 == 0 && h % 2 == 0;
                            }
                            else if (isCircle == 1)
                            {
                                brushType = (distance <= radius * radius);
                            }
                            else if (isSquare == 1)
                            {
                                brushType = true;
                            }
                            else if (isDottedSqaure == 1)
                            {
                                brushType = w % 2 == 0 && h % 2 == 0;
                            }

                            if (brushType == 1)
                            {
                                with (data)
                                {
                                    user = "clientName\0";
                                    x = xPos + w;
                                    y = yPos + h;
                                    r = redpaint;
                                    g = greenpaint;
                                    b = bluepaint;
                                    message = packMessage;
                                }
                                socket.send(data.GetPacketAsBytes());
                            }
                        }
                    }
                }

            }
            auto incoming = socket.receive(buffer);

            // Process incoming packet (from server) and update canvas
            while (incoming > 0)
            {
                // Parse packet bytes
                auto fromServer = buffer[0 .. incoming];

                byte[4] field1 = fromServer[16 .. 20].dup;
                byte[4] field2 = fromServer[20 .. 24].dup;

                ubyte r = fromServer[25];
                ubyte g = fromServer[26];
                ubyte b = fromServer[27];

                auto field6 = fromServer[28 .. 92].dup;

                // Cast to usable types
                int x = *cast(int*)&field1;
                int y = *cast(int*)&field2;

                //char[] message = decode(fromServer[28 .. 92].dup, "ASCII");
                //string msgStr =  cast(string)(message);
                string msgStr = "";
                foreach (byte bi; field6)
                {
                    if (bi != 0 && bi != 10 && bi != 13)
                    { // Remove null bytes and newline/carriage return characters
                        msgStr ~= cast(char) bi;
                    }
                }
                string paint = "paint";
                if (msgStr == "paint")
                {
                    //writeln("Painting pixel here...");
                    imgSurface.UpdateSurfacePixel(x, y, r, g, b);

                }
                else if (msgStr.strip().toLower() == "grey")
                {
                    writeln("Converting to grayscale...");
                    imgSurface.GreyScaleAll();
                }
                else if (msgStr.strip().toLower() == "clear")
                {
                    writeln("Clearing Screen...");
                    imgSurface.clearScreen();
                }
                else
                {
                    writeln("Unknown command:*", msgStr, "*");
                }

                incoming = socket.receive(buffer);
            }

            window.updateWindow();
        }
    }
}
