/*
    24 bit Device Independent Bitmap class

    Copyright (c) 2002,2003 Alessandro Scotti
    http://www.ascotti.org/
 
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/
#ifndef DIB24_
#define DIB24_

#include <windows.h>

/**
    Device Independent Bitmap in RGB (24 bits per pixel) format.
*/
class Dib24
{
public:
    /** Constructor. */
    Dib24( int width, int height );
    
    /** Copy constructor. */
    Dib24( const Dib24 & );
    
    /** Destructor. */
    virtual ~Dib24();

    /** Clears the bitmap setting all pixels to black. */
    void clear();

    /** 
        Copies the bitmap into a device context.

        @param hdc handle of device context to receive bitmap copy
        @param x x destination of bitmap in device context
        @param y y destination of bitmap in device context
        @param width width of copied bitmap in device context
        @param height width of copied bitmap in device context
    */
    void stretch( HDC hdc, int x, int y, int width, int height );

    /** Retrieves a pixel at the specified coordinates, with no range checking. */
    DWORD getFastPixel( int x, int y ) {
        LPBYTE  pb = bitmapbits_ + y*scanlength_ + x*3;
        return pb[0] | ((DWORD)pb[1] << 8) | ((DWORD)pb[2] << 16);
    }

    /** Sets a pixel at the specified coordinates, with no range checking. */
    void setFastPixel( int x, int y, DWORD value ) {
        LPBYTE  pb = bitmapbits_ + y*scanlength_ + x*3;
        *pb++ = (BYTE)(value >> 16);
        *pb++ = (BYTE)(value >> 8);
        *pb   = (BYTE)(value);
    }

    /** Retrieves a pixel at the specified coordinates (safe method). */
    DWORD getPixel( int x, int y );

    /** Sets a pixel at the specified coordinates (safe method). */
    void setPixel( int x, int y, DWORD value );

    /** Returns the address of the specified bitmap row. */
    unsigned char * getScanLine( int row ) {
        if( row >= 0 && row < height_ )
            return bitmapbits_ + row*scanlength_;
        return 0;
    }

    /** Returns the width of the bitmap. */
    int getWidth() const {
        return width_;
    }

    /** Returns the height of the bitmap. */
    int getHeight() const {
        return height_;
    }

    /** Returns the bitmap handle. */
    HDC getHandle() {
        return hdc_;
    }

private:
    void createBitmap( int width, int height );

    BITMAPINFO  bitmapinfo_;
    HANDLE      hbm_;
    LPBYTE      bitmapbits_;
    int         scanlength_;
    int         width_;
    int         height_;
    HDC         hdc_;
};

#endif // DIB24_
