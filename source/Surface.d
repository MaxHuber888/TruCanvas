/**
 * A D module for creating and manipulating a graphical surface using the SDL2 library.
 */
module Surface;

// Import D standard libraries
import std.stdio;
import std.string;

// Load the SDL2 library
import bindbc.sdl;
import loader = bindbc.loader.sharedlib;

import Pixel : Pixel;

/**
 * Represents a graphical surface with pixel manipulation capabilities.
 */
class Surface
{

    /**
     * Constructs a new Surface with the specified dimensions and color depth.
     *
     * Params:
     *  width = The width of the surface in pixels.
     *  height = The height of the surface in pixels.
     *  depth = The color depth of the surface in bits per pixel.
     */
    this(int width, int height, int depth)
    {
        imgSurface = SDL_CreateRGBSurface(0, width, height, depth, 0, 0, 0, 0);
        this.width = width;
        this.height = height;

        drawAllButtons();
    }

    /// Destructor that frees the allocated SDL_Surface.
    ~this()
    {
        SDL_FreeSurface(imgSurface);
    }

    SDL_Surface* imgSurface;
    int width;
    int height;

    /**
     * Updates the color of a pixel at the specified position.
     *
     * Params:
     *  xPos = The x-coordinate of the pixel to update.
     *  yPos = The y-coordinate of the pixel to update.
     *  b = The blue component of the new color.
     *  g = The green component of the new color.
     *  r = The red component of the new color.
     */
    void UpdateSurfacePixel(int xPos, int yPos, ubyte r, ubyte g, ubyte b)
    {
        // When we modify pixels, we need to lock the surface first
        SDL_LockSurface(this.imgSurface);
        // Make sure to unlock the surface when we are done.
        scope (exit)
            SDL_UnlockSurface(this.imgSurface);

        if (xPos < this.width && yPos < this.height)
        {
            // Retrieve the pixel array that we want to modify
            ubyte* pixelArray = cast(ubyte*) this.imgSurface.pixels;
            // Change the 'blue' component of the pixels
            pixelArray[yPos * this.imgSurface.pitch + xPos * this.imgSurface.format.BytesPerPixel + 0] = b;
            // Change the 'green' component of the pixels
            pixelArray[yPos * this.imgSurface.pitch + xPos * this.imgSurface.format.BytesPerPixel + 1] = g;
            // Change the 'red' component of the pixels
            pixelArray[yPos * this.imgSurface.pitch + xPos * this.imgSurface.format.BytesPerPixel + 2] = r;
        }
    }

    /** 
     * Draws the menu buttons.
     */
    void drawAllButtons()
    {
        // Set Menu Height
        auto menuHeight = 80;

        // Draw GUI
        for (int i = 0; i < width; i++)
        {
            // Draw a line across menu top
            int buttonsHeight = 100;
            UpdateSurfacePixel(i, height - menuHeight - 3, 255, 255, 255);
            for (int r = 0; r < menuHeight - 40; r++)
            {
                //draw buttons
                switch (i)
                {
                case 3: .. case 80:
                    UpdateSurfacePixel(i,
                        height - menuHeight + r, 255, 0, 0); //red
                    break;
                case 83: .. case 160:
                    UpdateSurfacePixel(i,
                        height - menuHeight + r, 255, 99, 71); //orange
                    break;
                case 163: .. case 240:
                    UpdateSurfacePixel(i,
                        height - menuHeight + r, 255, 255, 0); //yellow
                    break;
                case 243: .. case 320:
                    UpdateSurfacePixel(i,
                        height - menuHeight + r, 0, 255, 127); //green
                    break;
                case 323: .. case 400:
                    UpdateSurfacePixel(i,
                        height - menuHeight + r, 0, 0, 255); //blue
                    break;
                case 403: .. case 480:
                    UpdateSurfacePixel(i,
                        height - menuHeight + r, 238, 130, 238); //pink
                    break;
                case 483: .. case 560:
                    UpdateSurfacePixel(i,
                        height - menuHeight + r, 150, 75, 0);
                    break;
                case 563: .. case 637:
                    UpdateSurfacePixel(i,
                        height - menuHeight + r, 255, 255, 255);
                    break;
                default:
                    break;
                }
            }

            for (int q = 40; q < 80; q++)
            {
                switch (i)
                {
                case 3: .. case 80:
                    UpdateSurfacePixel(i,
                        height - menuHeight + q, 100, 100, 100);
                    break;
                case 83: .. case 160:
                    UpdateSurfacePixel(i,
                        height - menuHeight + q, 200, 200, 200);
                    break;
                case 163: .. case 240:
                    UpdateSurfacePixel(i,
                        height - menuHeight + q, 100, 100, 100);
                    break;
                case 243: .. case 320:
                    UpdateSurfacePixel(i,
                        height - menuHeight + q, 200, 200, 200);
                    break;
                case 323: .. case 400:
                    UpdateSurfacePixel(i,
                        height - menuHeight + q, 100, 100, 100);
                    break;
                case 403: .. case 480:
                    UpdateSurfacePixel(i,
                        height - menuHeight + q, 200, 200, 200);
                    break;
                case 483: .. case 560:
                    UpdateSurfacePixel(i,
                        height - menuHeight + q, 100, 100, 100);
                    break;
                case 563: .. case 637:
                    UpdateSurfacePixel(i,
                        height - menuHeight + q, 200, 200, 200);
                    break;
                default:
                    break;

                }

            }
        }

        //Button increase size
        SDL_Surface* surface;
        SDL_Rect r1, r2;
        surface = SDL_LoadBMP("../media/plus.bmp".toStringz);
        SDL_Rect_Set(&r1, 0, 0, 77, 80);
        SDL_Rect_Set(&r2, 183, height - (menuHeight / 2), 77, 80);
        SDL_BlitSurface(surface, &r1, imgSurface, &r2);
        SDL_FreeSurface(surface);

        //Button decrease size
        SDL_Surface* surface1;
        SDL_Rect r3, r4;
        surface1 = SDL_LoadBMP("../media/minus.bmp".toStringz);
        SDL_Rect_Set(&r3, 0, 0, 77, 80);
        SDL_Rect_Set(&r4, 263, height - (menuHeight / 2), 77, 80);
        SDL_BlitSurface(surface1, &r3, imgSurface, &r4);
        SDL_FreeSurface(surface1);

        //Button clear screen
        SDL_Surface* surface2;
        SDL_Rect r5, r6;
        surface2 = SDL_LoadBMP("../media/clear.bmp".toStringz);
        SDL_Rect_Set(&r5, 0, 0, 77, 80);
        SDL_Rect_Set(&r6, 343, height - (menuHeight / 2), 77, 80);
        SDL_BlitSurface(surface2, &r5, imgSurface, &r6);
        SDL_FreeSurface(surface2);

        //Button eraser screen
        SDL_Surface* surface3;
        SDL_Rect r7, r8;
        surface3 = SDL_LoadBMP("../media/erase.bmp".toStringz);
        SDL_Rect_Set(&r7, 0, 0, 77, 80);
        SDL_Rect_Set(&r8, 423, height - (menuHeight / 2), 77, 80);
        SDL_BlitSurface(surface3, &r7, imgSurface, &r8);
        SDL_FreeSurface(surface3);

        //Button Circle Brush
        SDL_Surface* surface4;
        SDL_Rect r9, r10;
        surface = SDL_LoadBMP("../media/circle.bmp".toStringz);
        SDL_Rect_Set(&r9, 0, 0, 77, 80);
        SDL_Rect_Set(&r10, 23, height - (menuHeight / 2), 77, 80);
        SDL_BlitSurface(surface, &r9, imgSurface, &r10);
        SDL_FreeSurface(surface);

        //Button Dotted Circle Brush
        SDL_Surface* surface5;
        SDL_Rect r11, r12;
        surface = SDL_LoadBMP("../media/dottedCircle.bmp".toStringz);
        SDL_Rect_Set(&r11, 0, 0, 77, 80);
        SDL_Rect_Set(&r12, 103, height - (menuHeight / 2), 77, 80);
        SDL_BlitSurface(surface, &r11, imgSurface, &r12);
        SDL_FreeSurface(surface);

        //Button Square Brush
        SDL_Surface* surface6;
        SDL_Rect r13, r14;
        surface = SDL_LoadBMP("../media/square.bmp".toStringz);
        SDL_Rect_Set(&r13, 0, 0, 77, 80);
        SDL_Rect_Set(&r14, 503, height - (menuHeight / 2), 77, 80);
        SDL_BlitSurface(surface, &r13, imgSurface, &r14);
        SDL_FreeSurface(surface);

        //Button Dotted Square Brush
        SDL_Surface* surface7;
        SDL_Rect r15, r16;
        surface = SDL_LoadBMP("../media/dottedSqaure.bmp".toStringz);
        SDL_Rect_Set(&r15, 0, 0, 77, 80);
        SDL_Rect_Set(&r16, 583, height - (menuHeight / 2), 77, 80);
        SDL_BlitSurface(surface, &r15, imgSurface, &r16);
        SDL_FreeSurface(surface);

        //Button GreyScale
        SDL_Surface* surface8;
        SDL_Rect r17, r18;
        surface = SDL_LoadBMP("../media/gray.bmp".toStringz);
        SDL_Rect_Set(&r17, 0, 0, 77, 80);
        SDL_Rect_Set(&r18, 583, height - (menuHeight), 77, 80);
        SDL_BlitSurface(surface, &r17, imgSurface, &r18);
        SDL_FreeSurface(surface);
    }

    /**
     * Updates the color of a pixel at the specified position to a blue-ish color.
     *
     * Params:
     *  xPos = The x-coordinate of the pixel to update.
     *  yPos = The y-coordinate of the pixel to update.
     */
    void UpdateBluePixel(int xPos, int yPos)
    {
        UpdateSurfacePixel(xPos, yPos, 32, 128, 255);
    }

    /**
     * Applies a greyscale to all pixels on the screen.
     */
    void GreyScaleAll()
    {
        for (int x = 0; x < width; x++)
        {
            for (int y = 0; y < 396; y++)
            {
                auto p = PixelAt(x, y);
                auto value = cast(ubyte)((p.r + p.g + p.b) / 3);
                UpdateSurfacePixel(x, y, value, value, value);
            }
        }
    }
    /**
     * Clears all pixels on the screen.
     */

    void clearScreen()
    {
        for (int x = 0; x < width; x++)
        {
            for (int y = 0; y < 396; y++)
            {
                UpdateSurfacePixel(x, y, 0, 0, 0);
            }
        }
    }
    /**
     * Retrieves the color of a pixel at the specified position.
     *
     * Params:
     *  xPos = The x-coordinate of the pixel.
     *  yPos = The y-coordinate of the pixel.
     *
     * Returns: A Pixel instance representing the color of the specified pixel.
     */
    Pixel PixelAt(int xPos, int yPos)
    {
        assert(xPos <= width, "X position must be within surface width.");
        assert(xPos >= 0, "X position must be greater than 0.");
        assert(yPos <= height, "Y position must be within surface height.");
        assert(yPos >= 0, "Y position must be greater than 0.");

        ubyte* pixelArray = cast(ubyte*) this.imgSurface.pixels;
        int b = pixelArray[yPos * this.imgSurface.pitch + xPos * this.imgSurface.format.BytesPerPixel + 0];
        int g = pixelArray[yPos * this.imgSurface.pitch + xPos * this.imgSurface.format.BytesPerPixel + 1];
        int r = pixelArray[yPos * this.imgSurface.pitch + xPos * this.imgSurface.format.BytesPerPixel + 2];
        auto pixel = Pixel(b, g, r);
        return pixel;
    }

    void animateButton(int button_row, int button_num)
    {
        auto button_width = width / 8;
        auto button_height = 40;

        drawAllButtons();

        if (button_row > 1 || button_num > 7)
        {
            return;
        }

        for (int x = 0; x < button_width; x++)
        {
            for (int y = 0; y < button_height; y++)
            {
                if (x % 2 == 0 || y % 2 == 0)
                {
                    UpdateSurfacePixel(x + (button_num * button_width) + 3, y + height - (
                            2 * button_height) + (button_row * button_height), 0, 0, 0);
                }
            }
        }
    }

    void SDL_Rect_Set(SDL_Rect* r, int x, int y, int w, int h)
    {
        r.x = x;
        r.y = y;
        r.w = w;
        r.h = h;
    }

}
