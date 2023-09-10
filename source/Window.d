/**
 * A D module for creating and managing graphical windows using the SDL2 library.
 */
module Window;

// Import D standard libraries
import std.stdio;
import std.string;

// Load the SDL2 library
import bindbc.sdl;
import loader = bindbc.loader.sharedlib;

import Surface : Surface;

/**
 * Represents a graphical window with the ability to update and display a Surface.
 */
class Window
{

    /**
     * Constructs a new Window with the specified dimensions and an associated Surface.
     *
     * Params:
     *  width = The width of the window in pixels.
     *  height = The height of the window in pixels.
     *  surface = The Surface to associate with the window.
     */
    this(int width, int height, Surface surface)
    {
        window = SDL_CreateWindow("TruCanvas",
            SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED,
            width,
            height,
            SDL_WINDOW_SHOWN);
        this.imgSurface = surface;
    }

    /// Destructor that frees the allocated SDL_Window.
    ~this()
    {
        // Destroy our window
        SDL_DestroyWindow(window);
    }

    SDL_Window* window;
    Surface imgSurface;

    /**
     * Copies the pixels from the associated Surface to the window's surface.
     */
    void BlitSurface()
    {
        // Blit the surace (i.e. update the window with another surfaces pixels
        //                       by copying those pixels onto the window).
        SDL_BlitSurface(imgSurface.imgSurface, null, SDL_GetWindowSurface(window), null);
    }

    /**
     * Updates the window's surface with the pixels copied from the associated Surface.
     */
    void UpdateWindowSurface()
    {
        // Update the window surface
        SDL_UpdateWindowSurface(window);
    }

    /**
     * Delays the window update process by a fixed amount of time.
     */
    void Delay()
    {
        // Delay for 16 milliseconds
        // Otherwise the program refreshes too quickly
        SDL_Delay(16);
    }

    /**
     * Updates the window by blitting the associated Surface, updating the window surface, and applying a delay.
     */
    void updateWindow()
    {
        BlitSurface();
        UpdateWindowSurface();
        Delay();
    }
}
