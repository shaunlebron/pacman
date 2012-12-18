/*
    Pacman arcade machine emulator

    Copyright (c) 1997-2003,2004 Alessandro Scotti
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
#ifndef ARCADE_H_
#define ARCADE_H_

#include "namcowsg3.h"
#include "z80.h"

/**
    Pacman sprite properties.

    This information is only needed by applications that want to do their own
    sprite rendering, as the renderVideo() function already draws the sprites.

    @see PacmanMachine::renderVideo
*/
struct PacmanSprite
{
    /** Display mode constants */
    enum {
        Normal  = 0x00,
        FlipY   = 0x01,
        FlipX   = 0x02,
        FlipXY  = 0x03
    };

    /** Default constructor */
    PacmanSprite() : mode(0), x(0), y(0), n(0), color(0) {
    }

    /** Display mode (normal or flipped) */
    int mode;
    /** X coordinate */
    int x;
    /** Y coordinate */
    int y;
    /** Shape (from 0 to 63) */
    int n;
    /** Base color (0=not visible) */
    int color;  
};

/**
    Pacman machine emulator.

    This class implements the Z80Environment interface to provide the Z80 CPU
    core with a virtual Pacman hardware.

    The emulator also virtualizes input and output systems so that any application
    can easily interface with the emulator in order to provide input (e.g. key presses
    or joystick movements) and display output. For the latter, the application can
    choose to perform its own rendering or to use emulator functions that render video
    and sound in a standard, easy-to-use format.

    @author Alessandro Scotti
    @version 1.1
*/
class PacmanMachine : public Z80Environment
{
public:
    /** Machine hardware data */
    enum {
        ScreenWidth         = 224,
        ScreenHeight        = 288,
        ScreenWidthChars    = 28,
        ScreenHeightChars   = 36,
        CharWidth           = 8,
        CharHeight          = 8,
        VideoFrequency      = 60,
        CpuClock            = 3072000,
        SoundClock          = 96000,    // CPU clock divided by 32
        CpuCyclesPerFrame   = CpuClock / VideoFrequency
    };

    /** Input devices and switches */
    enum InputDevice {
        Joy1_Up = 0,
        Joy1_Left,
        Joy1_Right,
        Joy1_Down,
        Switch_RackAdvance,
        CoinSlot_1,
        CoinSlot_2,
        Switch_AddCredit,
        Joy2_Up,
        Joy2_Left,
        Joy2_Right,
        Joy2_Down,
        Switch_Test,
        Key_OnePlayer,
        Key_TwoPlayers,
        Switch_CocktailMode
    };

    /** Input device mode */
    enum InputDeviceMode {
        DeviceOn,
        DevicePushed = DeviceOn,
        DeviceOff,
        DeviceReleased = DeviceOff,
        DeviceToggle
    };

    /** DIP switches */
    enum {
        DipPlay_Free            =   0x00, // Coins per play
        DipPlay_OneCoinOneGame  =   0x01,
        DipPlay_OneCoinTwoGames =   0x02,
        DipPlay_TwoCoinsOneGame =   0x03,
        DipPlay_Mask            =   0x03,
        DipLives_1              =   0x00, // Lives per game
        DipLives_2              =   0x04,
        DipLives_3              =   0x08,
        DipLives_5              =   0x0C,
        DipLives_Mask           =   0x0C,
        DipBonus_10000          =   0x00, // Bonus life
        DipBonus_15000          =   0x10,
        DipBonus_20000          =   0x20,
        DipBonus_None           =   0x30,
        DipBonus_Mask           =   0x30,
        DipDifficulty_Normal    =   0x40, // Difficulty
        DipDifficulty_Hard      =   0x00,
        DipDifficulty_Mask      =   0x40,
        DipGhostNames_Normal    =   0x80, // Ghost names
        DipGhostNames_Alternate =   0x00,
        DipGhostNames_Mask      =   0x80,
        DipMode_Play            = 0x0000, // Play/test mode
        DipMode_Test            = 0x0100,
        DipMode_Mask            = 0x0100,
        DipCabinet_Upright      = 0x0000, // Cabinet upright/cocktail
        DipCabinet_Cocktail     = 0x0200,
        DipCabinet_Mask         = 0x0200,
        DipRackAdvance_Off      = 0x0000, // Automatic level advance
        DipRackAdvance_Auto     = 0x0400,
        DipRackAdvance_Mask     = 0x0400
    };

public:
    /** 
        Constructor.
    */
    PacmanMachine();

    /**
        Destructor.
    */
    virtual ~PacmanMachine();

    /** 
        Resets the machine. 
        
        This function is equivalent to turning the machine off and on again,
        but it preserves the ROMs that were previously set so the application does
        not have to reinitialize them.

        It is usually called on startup and to enable changes in the DIP switch settings.

        @param settings 
    */
    virtual void reset();

    /**
        Runs the machine for one frame, i.e. 1/60th of a second in Pacman.

        Note that sound is updated after each frame, but the video is only updated 
        every other frame.
    */
    virtual int run();

    /**
        Sets the main game ROM.

        @param rom pointer to the 16K game ROM
    */
    virtual void setROM( const unsigned char * rom );

    /**
        Sets the video ROMs that contain character and sprite definitions.

        Usually character and sprite data come together with the game ROM in
        a 24K ROM bundle and the application can use the following code:

        <BLOCKQUOTE>
        <PRE>
        @@    unsigned char * rom_bundle = ...24K game and video ROM bundle...
        @@
        @@    pacmanMachine.setROM( rom_bundle );
        @@    pacmanMachine.setVideoROMs( rom_bundle+0x4000, rom_bundle+0x5000 );
        </PRE>
        </BLOCKQUOTE>

        @param charset pointer to 4K character definition data
        @param spriteset pointer to 4K sprite definition data
    */
    virtual void setVideoROMs( const unsigned char * charset, const unsigned char * spriteset );

    /**
        Sets the color ROMs containing the color definitions and the color map.

        @param palette pointer to 32 byte PROM containing color definitions
        @param color pointer to 256-entry 4-bit PROM containing the mapping
                     between the color index and the color definition (from the
                     palette)
    */
    virtual void setColorROMs( const unsigned char * palette, const unsigned char * color );

    /**
        Returns the current status of an input device.
    */
    virtual InputDeviceMode getDeviceMode( InputDevice device ) const;

    /**
        Tells the emulator that the status of an input device has changed.
    */
    virtual void setDeviceMode( InputDevice device, InputDeviceMode mode );

    /**
        Returns the value of the DIP switches.
    */
    unsigned getDipSwitches() const;

    /**
        Sets the value of the DIP switches that control several game settings
        (see the Dip... constants above). 
        
        Most of the DIP switches are read at program startup and take effect 
        only after a machine reset.
    */
    void setDipSwitches( unsigned value );

    /**
        Returns the number of coins inserted since the machine was powered on.
    */
    unsigned getCoinMeter() const {
        return coin_counter_;
    }

    /** Returns how many times run() has been called since last reset. */
    unsigned getFrameCount() const {
        return frame_counter_;
    }

    /**
        Reproduces the sound that is currently being generated by the sound
        chip into the specified buffer.

        The sound chip has three independent voices that generate 8-bit signed
        PCM audio at 96 KHz. This function resamples the voices at the specified
        sampling rate and mixes them into the output buffer. The output buffer
        can be converted to 8-bit (signed) PCM by dividing each sample by 3 (since 
        there are three voices) or it can be expanded to 16-bit by multiplying
        each sample by 85 (i.e. 256 divided by 3). If necessary, it is possible
        to approximate these values with 4 and 64 in order to use arithmetic
        shifts that are usually faster to execute.

        Note: this function clears the content of the output buffer before
        mixing voices into it.

        @param buf pointer to sound buffer that receives the audio samples
        @param len length of the sound buffer
        @param samplingRate sampling rate (in Hertz or samples per second) of the sound buffer
    */
    virtual void playSound( int * buf, int len, int samplingRate );

    /**
        Draws the current video into the specified buffer.

        The buffer must be at least 224*288 bytes long. Pixels are stored in
        left-to-right/top-to-bottom order starting from the upper left corner.
        There is one byte per pixel, containing an index into the color palette 
        returned by getPalette().

        It's up to the application to display the buffer to the user. The 
        code might look like this:
        <BLOCKQUOTE>
        <PRE>
        @@    unsigned char video_buffer[ PacmanMachine::ScreenWidth * PacmanMachine::ScreenHeight ];
        @@    unsigned char * vbuf = video_buffer;
        @@    const unsigned * palette = arcade.getPalette();
        @@
        @@    arcade.renderVideo( vbuf );
        @@
        @@    for( int y=0; y<PacmanMachine::ScreenHeight; y++ ) {
        @@        for( int x=0; x<PacmanMachine::ScreenWidth; x++ ) {
        @@            unsigned color = palette[ *vbuf++ ];
        @@            unsigned char red = color & 0xFF;
        @@            unsigned char green = (color >> 8) & 0xFF;
        @@            unsigned char blue = (color >> 16) & 0xFF;
        @@
        @@            setPixel( x, y, red, green, blue );
        @@        }
        @@    }
        </PRE>
        </BLOCKQUOTE>

    */
    virtual void renderVideo( unsigned char * buffer );

    /**
        Returns a pointer to the decoded 32 color palette: each entry contains
        a color in RGB format encoded as 0x00bbggrr.
    */
    const unsigned * getPalette() const {
        return palette_;
    }

    /**
        Returns a pointer to the 20K ROM/RAM buffer containing the 16K game
        ROM (starting at 0x0000) and 4K of RAM (starting at 0x4000, this
        includes the video RAM at 0x4000-0x43FF and the color RAM at
        0x4400-0x47FF).

        The first 16K of the buffer contain the game ROM as specified in the
        setROM() function.
    */
    const unsigned char * getRAM() const {
        return ram_;
    }

    /**
        Returns a pointer to the current settings of the specified sprite.

        This function is only necessary if the application wants to perform
        its own rendering, because renderVideo() already draws the sprites.

        @see #renderVideo
    */
    const PacmanSprite * getSprite( int index ) const {
        return &(sprites_[index]);
    }

    /** 
        Returns a pointer to the video memory in "normalized" form
        (224x288, one byte per pixel).

        Note: Pacman has a rather peculiar video/color memory layout but this
        buffer is kept "normalized" by the emulator so it has the same
        format as the output buffer used by renderVideo(). The raw video
        memory can be found in the RAM buffer at 0x4000-0x43FF.

        This function is only necessary if the application wants to perform
        its own rendering, because renderVideo() already draws the video.

        @see #renderVideo
    */
    const unsigned char * getVideoMem() const {
        return video_mem_;
    }

    /** 
        Returns a pointer to the color memory in "normalized" form
        (224x288, one byte per pixel).

        Note: Pacman has a rather peculiar video/color memory layout but this
        buffer is kept "normalized" by the emulator so it has the same
        format as the output buffer used by renderVideo(). The raw color
        memory can be found in the RAM buffer at 0x4400-0x47FF.

        This function is only necessary if the application wants to perform
        its own rendering, because renderVideo() already draws the video.

        @see #renderVideo
    */
    const unsigned char * getColorMem() const {
        return color_mem_;
    }

    /** 
        Returns the size of the buffer needed to take a snapshot of the machine.
    */
    virtual unsigned getSizeOfSnapshotBuffer() const;

    /**         
        Takes a snapshot of the machine.

        A snapshot saves all of the machine memory and settings, including RAM,
        ROM, CPU status and I/O registers. It can be restored at any time to bring 
        the machine back to the exact status it had when the snapshot was taken.

        Snapshots come very handy to save the progress of a game during a good
        performance!

        Note: the size of the snapshot buffer must be no less than the size
        returned by the getSizeOfSnapshotBuffer() function.

        @param buffer buffer where the snapshot data is stored

        @return the number of bytes written into the buffer
    */
    virtual unsigned takeSnapshot( unsigned char * buffer );

    /**
        Restores a snapshot taken with takeSnapshot().

        This function uses the data saved in the snapshot buffer to restore the
        machine status.

        @param buffer buffer where the snapshot data is stored
    
        @return the number of bytes read from the buffer
    */
    virtual unsigned restoreSnapshot( unsigned char * buffer );

    /** 
        Decodes and expands the 4K ROM containing the character definitions into a 16K RAM
        buffer where each byte correspond directly to a 8x8 character pixel.
    */
    static void decodeCharSet( unsigned char * mem, unsigned char * charset );

    /** 
        Decodes and expands the 4K ROM containing the sprite definitions into a 16K RAM
        buffer where each byte correspond directly to a 16x16 sprite pixel.
    */
    static void decodeSprites( unsigned char * mem, unsigned char * sprite_data );

    /** Decode one byte from the encoded color palette. */
    static unsigned decodePaletteByte( unsigned char b );

    /** Returns the status of the start light for player one. */
    unsigned char getPlayerOneLight() const {
        return output_devices_ & PlayerOneLight ? 1 : 0;
    }
    
    /** Returns the status of the start light for player two. */
    unsigned char getPlayerTwoLight() const {
        return output_devices_ & PlayerTwoLight ? 1 : 0;
    }

    /** Returns the status of the coin lockout door. */
    unsigned char getCoinLockout() const {
        return output_devices_ & CoinLockout ? 1 : 0;
    }

    /**
        Enables/disables a common speed hack that allows Pacman to
        move four times faster than the ghosts.

        @param enabled true to enabled the hack, false to disable

        @return 0 if successful, otherwise the patch could not be applied
                (probably because the loaded ROM set does not support it)
    */
    virtual int setSpeedHack( int enabled );

protected:
    // Implementation of the CpuEnvironment interface
    unsigned char readByte( unsigned addr );

    void writeByte( unsigned, unsigned char );

    unsigned char readPort( unsigned port );

    void writePort( unsigned, unsigned char );

protected:
    // Utilities
    void drawChar( unsigned char * buffer, int index, int ox, int oy, int color );

    void drawSprite( unsigned char * buffer, int index );

    // Helper functions for working with ROM data
    static void decodeCharByte( unsigned char b, unsigned char * charbuf, int charx, int chary, int charwidth );

    static void decodeCharLine( unsigned char * src, unsigned char * charbuf, int charx, int chary, int charwidth );

    // Descendants can get write access to some members
    unsigned getSizeOfRAM() const {
        return sizeof(ram_);
    }

    unsigned char * getAddrOfRAM() {
        return ram_;
    }

private:
    // Output flip-flops
    enum {
        FlipScreen          = 0x01,
        PlayerOneLight      = 0x02,
        PlayerTwoLight      = 0x04,
        InterruptEnabled    = 0x08,
        SoundEnabled        = 0x10,
        CoinLockout         = 0x20,
        CoinMeter           = 0x40,
        AuxBoardEnabled     = 0x80
    };

    void setOutputFlipFlop( unsigned char bit, unsigned char value );

    void getDeviceInfo( InputDevice device, unsigned char * mask, unsigned char ** port );

private:
    PacmanMachine( const PacmanMachine & );
    PacmanMachine & operator = ( const PacmanMachine & );

private:
    unsigned char   ram_[20*1024];          // ROM (16K) and RAM (4K)
    unsigned char   charset_rom_[4*1024];   // Character set ROM (4K)
    unsigned char   spriteset_rom_[4*1024]; // Sprite set ROM (4K)
    unsigned char   video_mem_[1024];       // Video memory (1K)
    unsigned char   color_mem_[1024];       // Color memory (1K)
    unsigned char   color_data_[256];
    unsigned char   palette_data_[32];      // Encoded palette data
    unsigned char   charmap_[256*8*8];      // Character data for 256 8x8 characters
    unsigned char   spritemap_[64*16*16];   // Sprite data for 64 16x16 sprites
    unsigned char   dip_switches_;
    unsigned char   port1_;
    unsigned char   port2_;
    unsigned char   output_devices_;        // Output flip-flops set by the game program
    unsigned char   interrupt_vector_;
    unsigned        coin_counter_;
    unsigned        frame_counter_;         // How many times run() has been called since last reset() 
    NamcoWsg3       sound_chip_;
    Z80 *           cpu_;
    // Internal tables and structures for faster access to data
    PacmanSprite    sprites_[8];            // Sprites
    unsigned        palette_[256];          // Color palette
    int             vchar_to_x_[1024];
    int             vchar_to_y_[1024];
    int             vchar_to_i_[1024];
};

/**
    Ms.Pacman machine emulator.

    Ms. Pacman hardware is identical to the Pacman hardware
    with an extra board added. This board mainly contains new ROMs for
    both code and graphics.

    The MsPacmanMachine class emulates the above hardware by extending the
    base PacmanMachine class with the functions needed to emulate only the
    extra board and logic. While not optimal for performance, this approach 
    is remarkably easy to implement are requires very little code.
*/
class MsPacmanMachine : public PacmanMachine
{
public:
    /**
        Constructor.
    */
    MsPacmanMachine() : PacmanMachine(), aux_board_enabled_(0) {
    }

    /**
        Destructor.
    */
    virtual ~MsPacmanMachine() {
    }
    
    /**
        Sets the ROMs found on the auxiliary board.

        Note: the original encrypted ROMs must be specified here, they will
        be decrypted by the emulator.

        @param u5 2K ROM at board location U5
        @param u6 4K ROM at board location U6
        @param u7 4K ROM at board location U7
    */
    void setAuxROM( unsigned char * u5, unsigned char * u6, unsigned char * u7 );

    /**
        Enables/disables a common speed hack that allows Pacman to
        move four times faster than the ghosts.

        @param enabled true to enabled the hack, false to disable

        @return 0 if successful, otherwise the patch could not be applied
                (probably because the loaded ROM set does not support it)
    */
    virtual int setSpeedHack( int enabled );

    /** 
        Returns the size of the buffer needed to take a snapshot of the machine.
        
        @see PacmanMachine::getSizeOfSnapshotBuffer
    */
    virtual unsigned getSizeOfSnapshotBuffer() const;

    /**         
        Takes a snapshot of the machine.

        A snapshot saves all of the machine memory and settings, including RAM,
        ROM, CPU status and I/O registers. It can be restored at any time to bring 
        the machine back to the exact status it had when the snapshot was taken.

        Snapshots come very handy to save the progress of a game during a good
        performance!

        Note: the size of the snapshot buffer must be no less than the size
        returned by the getSizeOfSnapshotBuffer() function.

        @param buffer buffer where the snapshot data is stored

        @return the number of bytes written into the buffer

        @see PacmanMachine::takeSnapshot
    */
    virtual unsigned takeSnapshot( unsigned char * buffer );

    /**
        Restores a snapshot taken with takeSnapshot().

        This function uses the data saved in the snapshot buffer to restore the
        machine status.

        @param buffer buffer where the snapshot data is stored

        @return the number of bytes read from the buffer

        @see PacmanMachine::restoreSnapshot
    */
    virtual unsigned restoreSnapshot( unsigned char * buffer );

protected:
    // Implementation of the CpuEnvironment interface
    unsigned char readByte( unsigned addr );

    void writeByte( unsigned, unsigned char );

private:
    unsigned char rom_aux_[26*1024]; // 10K new ROM plus 16K to backup old ROM (because it gets patched)
    unsigned char aux_board_enabled_; // Whether the aux board has been enabled or not
};

#endif // ARCADE_H_
