/**
 * A D module for representing a Pixel with color values.
 */
module Pixel;

/**
 * A struct representing a pixel with blue, green, and red color components.
 */
struct Pixel
{
    int b;
    int g;
    int r;

    /**
     * Constructs a Pixel object with the specified blue, green, and red color components.
     *
     * Params:
     *     b = The blue color component of the pixel
     *     g = The green color component of the pixel
     *     r = The red color component of the pixel
     */
    this(int b, int g, int r)
    {
        this.b = b;
        this.g = g;
        this.r = r;
    }
}
