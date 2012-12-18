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
#include "arcade.h"

#include <string.h>

// Namco 3-channel Wave Sound Generator wave data (8 waveforms with 32 4-bit entries each)
static unsigned char NamcoSoundPROM[] = {
	0x07,0x09,0x0A,0x0B,0x0C,0x0D,0x0D,0x0E,0x0E,0x0E,0x0D,0x0D,0x0C,0x0B,0x0A,0x09,
	0x07,0x05,0x04,0x03,0x02,0x01,0x01,0x00,0x00,0x00,0x01,0x01,0x02,0x03,0x04,0x05,
	0x07,0x0C,0x0E,0x0E,0x0D,0x0B,0x09,0x0A,0x0B,0x0B,0x0A,0x09,0x06,0x04,0x03,0x05,
	0x07,0x09,0x0B,0x0A,0x08,0x05,0x04,0x03,0x03,0x04,0x05,0x03,0x01,0x00,0x00,0x02,
	0x07,0x0A,0x0C,0x0D,0x0E,0x0D,0x0C,0x0A,0x07,0x04,0x02,0x01,0x00,0x01,0x02,0x04,
	0x07,0x0B,0x0D,0x0E,0x0D,0x0B,0x07,0x03,0x01,0x00,0x01,0x03,0x07,0x0E,0x07,0x00,
	0x07,0x0D,0x0B,0x08,0x0B,0x0D,0x09,0x06,0x0B,0x0E,0x0C,0x07,0x09,0x0A,0x06,0x02,
	0x07,0x0C,0x08,0x04,0x05,0x07,0x02,0x00,0x03,0x08,0x05,0x01,0x03,0x06,0x03,0x01,
	0x00,0x08,0x0F,0x07,0x01,0x08,0x0E,0x07,0x02,0x08,0x0D,0x07,0x03,0x08,0x0C,0x07,
	0x04,0x08,0x0B,0x07,0x05,0x08,0x0A,0x07,0x06,0x08,0x09,0x07,0x07,0x08,0x08,0x07,
	0x07,0x08,0x06,0x09,0x05,0x0A,0x04,0x0B,0x03,0x0C,0x02,0x0D,0x01,0x0E,0x00,0x0F,
	0x00,0x0F,0x01,0x0E,0x02,0x0D,0x03,0x0C,0x04,0x0B,0x05,0x0A,0x06,0x09,0x07,0x08,
	0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F,
	0x0F,0x0E,0x0D,0x0C,0x0B,0x0A,0x09,0x08,0x07,0x06,0x05,0x04,0x03,0x02,0x01,0x00,
	0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F,
	0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F
};

PacmanMachine::PacmanMachine()
    : sound_chip_( SoundClock )
{
    // Initialize the CPU and the RAM
    cpu_ = new Z80( *this );
    memset( ram_, 0xFF, sizeof(ram_) );

    // Set the sound PROM to the default values for the original Namco chip
    sound_chip_.setSoundPROM( NamcoSoundPROM );

    // Initialize parameters
    port1_ = 0xFF;
    port2_ = 0xFF;
    coin_counter_ = 0;

    // Reset the machine
    reset();

    // Set the DIP switches to a default configuration
    setDipSwitches( 
        DipPlay_OneCoinOneGame | 
        DipBonus_10000 | 
        DipLives_3 | 
        DipDifficulty_Normal | 
        DipGhostNames_Normal |
        DipCabinet_Upright | 
        DipMode_Play |
        DipRackAdvance_Off );

    // Initialize the video character translation tables: video memory has a very
    // peculiar arrangement in Pacman so we precompute a few tables to move around faster
    for( int i=0x000; i<0x400; i++ ) {
        int x, y;

        if( i < 0x040 ) {
          x = 29 - (i & 0x1F);
          y = 34 + (i >> 5);
        }
        else if( i >= 0x3C0 ) {
          x = 29 - (i & 0x1F);
          y = ((i-0x3C0) >> 5);
        }
        else {
          x = 27 - ((i-0x40) >> 5);
          y = 2 + ((i-0x40) & 0x1F);
        }
        vchar_to_x_[i] = x;
        vchar_to_y_[i] = y;
        if( (y >= 0) && (y < 36) && (x >= 0) && (x < 28) )
            vchar_to_i_[i] = y*28 + x;
        else
            vchar_to_i_[i] = 0x3FF;
    }
}

PacmanMachine::~PacmanMachine()
{
    delete cpu_;
}

void PacmanMachine::reset()
{
    cpu_->reset();
    output_devices_ = 0;
    interrupt_vector_ = 0;

    memset( ram_+0x4000, 0, 0x1000 );
    memset( color_mem_, 0, sizeof(color_mem_) );
    memset( video_mem_, 0, sizeof(video_mem_) );

    for( int i=0; i<8; i++ ) {
        sprites_[i].color = 0;
        sprites_[i].x = ScreenWidth;
    }

    frame_counter_ = 0;
}

/*
    Run the machine for one frame.
*/
int PacmanMachine::run()
{
    frame_counter_++;

    // Run until the CPU has executed the number of cycles per frame
    // (the function returns the number of "extra" cycles spent by the
    // last instruction but that is not really important here)
    unsigned extraCycles = cpu_->run( CpuCyclesPerFrame );

    // Reset the CPU cycle counter to make sure it doesn't overflow,
    // also take into account the extra cycles from the previous run
    cpu_->setCycles( extraCycles );

    // If interrupts are enabled, force a CPU interrupt with the vector
    // set by the program
    if( output_devices_ & InterruptEnabled ) {
        cpu_->interrupt( interrupt_vector_ );
    }

    return 0;
}

/*
    For Z80 Environment: read a byte from memory.
*/
unsigned char PacmanMachine::readByte( unsigned addr ) 
{
    addr &= 0xFFFF;

    if( addr < sizeof(ram_) )
        return ram_[addr];

    // Address is not in RAM, check to see if it's a memory mapped register
    switch( addr & 0xFFC0 ) {
    // IN0
    case 0x5000: 
        // bit 0 : up
        // bit 1 : left
        // bit 2 : right
        // bit 3 : down
        // bit 4 : switch: advance to next level
        // bit 5 : coin 1
        // bit 6 : coin 2
        // bit 7 : credit (same as coin but coin counter is not incremented)
        return port1_;
    // IN1
    case 0x5040: 
        // bit 0 : up (2nd player)
        // bit 1 : left (2nd player)
        // bit 2 : right (2nd player)
        // bit 3 : down (2nd player)
        // bit 4 : switch: rack test -> 0x10=off, 0=on
        // bit 5 : start 1
        // bit 6 : start 2
        // bit 7 : cabinet -> 0x80=upright, 0x00=table
        return port2_;
    // DSW1
    case 0x5080:
        // bits 0,1 : coinage -> 0=free play, 1=1 coin/play, 2=1 coin/2 play, 3=2 coin/1 play
        // bits 2,3 : lives -> 0x0=1, 0x4=2, 0x8=3, 0xC=5
        // bits 4,5 : bonus life -> 0=10000, 0x10=15000, 0x20=20000, 0x30=none
        // bit  6   : jumper pad: difficulty -> 0x40=normal, 0=hard
        // bit  7   : jumper pad: ghost name -> 0x80=normal, 0=alternate
        return dip_switches_;
    // Watchdog reset
    case 0x50C0:
        break;
    }

    return 0xFF;
}

void PacmanMachine::setOutputFlipFlop( unsigned char bit, unsigned char value )
{
    if( value ) {
        output_devices_ |= bit;
    }
    else {
        output_devices_ &= ~bit;
    }
}

/*
    For Z80 Environment: write a byte to memory.
*/
void PacmanMachine::writeByte( unsigned addr, unsigned char b )
{
    addr &= 0x7FFF;

    if( addr < 0x4000 ) {
        // This is a ROM address, do not write into it!
    }
    else if( addr < 0x4400 ) {
        // Video memory
        ram_[addr] = b;
        video_mem_[ vchar_to_i_[addr-0x4000] ] = b;
    }
    else if( addr < 0x4800 ) {
        // Color memory
        ram_[addr] = b;
        color_mem_[ vchar_to_i_[addr-0x4400] ] = b;
    }
    else if( addr < 0x4FF0 ) {
        // Standard memory
        ram_[addr] = b;
    }
    else if( addr < 0x5000 ) {
        // Sprites
        ram_[addr] = b;

        unsigned idx = (addr - 0x4FF0) / 2;

        if( addr & 1 ) {
            sprites_[ idx ].color = b;
        }
        else {
            sprites_[ idx ].n = b >> 2;
            sprites_[ idx ].mode = b & 0x03;
        }
    }
    else {
        // Memory mapped ports
        switch( addr ) {
        case 0x5000:
            // Interrupt enable
            setOutputFlipFlop( InterruptEnabled, b & 0x01 );
            break;
        case 0x5001:
            // Sound enable
            setOutputFlipFlop( SoundEnabled, b & 0x01 );
            break;
        case 0x5002:
            // Aux board enable?
            break;
        case 0x5003:
            // Flip screen
            setOutputFlipFlop( FlipScreen, b & 0x01 );
            break;
        case 0x5004:
            // Player 1 start light
            setOutputFlipFlop( PlayerOneLight, b & 0x01 );
            break;
        case 0x5005:
            // Player 2 start light
            setOutputFlipFlop( PlayerTwoLight, b & 0x01 );
            break;
        case 0x5006:
            // Coin lockout: bit 0 is used to enable/disable the coin insert slots 
            // (0=disable).
            // The coin slot is enabled at startup and (temporarily) disabled when 
            // the maximum number of credits (99) is inserted.
            setOutputFlipFlop( CoinLockout, b & 0x01 );
            break;
        case 0x5007:
            // Coin meter (coin counter incremented on 0/1 edge)
            if( (output_devices_ & CoinMeter) == 0 && (b & 0x01) != 0 )
                coin_counter_++;
            setOutputFlipFlop( CoinMeter, b & 0x01 );
            break;
        case 0x50c0:
            // Watchdog reset
            break;
        default:
            if( addr >= 0x5040 && addr < 0x5060 ) {
                // Sound registers
                sound_chip_.setRegister( addr-0x5040, b );
            }
            else if( addr >= 0x5060 && addr < 0x5070 ) {
                // Sprite coordinates, x/y pairs for 8 sprites
                unsigned idx = (addr-0x5060) / 2;

                if( addr & 1 ) {
                    sprites_[ idx ].y = 272 - b + 1;
                }
                else {
                    sprites_[ idx ].x = 240 - b - 1;

                    if( idx <= 2 ) {
                        // In Pacman the first few sprites must be further offset 
                        // to the left to get a correct display (is this a hack?)
                        sprites_[ idx ].x -= 1;
                    }
                }
            }
            break;
        }
    }
}

/*
    For Z80 Environment: read from a port.

    Note: all ports in Pacman are memory mapped so they are read with readByte().
*/
unsigned char PacmanMachine::readPort( unsigned port ) 
{
    return 0;
}

/*
    For Z80 Environment: write to a port.
*/
void PacmanMachine::writePort( unsigned addr, unsigned char b )
{
    if( addr == 0 ) {
        // Sets the interrupt vector for the next CPU interrupt
        interrupt_vector_ = b;
    }
}

void PacmanMachine::setROM( const unsigned char * rom )
{
    memcpy( ram_, rom, 0x4000 );
}

void PacmanMachine::setVideoROMs( const unsigned char * charset, const unsigned char * spriteset )
{
    memcpy( charset_rom_, charset, sizeof(charset_rom_) );
    memcpy( spriteset_rom_, spriteset, sizeof(spriteset_rom_) );

    decodeCharSet( charset_rom_, charmap_ );
    decodeSprites( spriteset_rom_, spritemap_ );
}

void PacmanMachine::setColorROMs( const unsigned char * palette, const unsigned char * color )
{
    unsigned decoded_palette[0x20];

    memcpy( palette_data_, palette, sizeof(palette_data_) );
    memcpy( color_data_, color, sizeof(color_data_) );

    int i;

    for( i=0x00; i<0x20; i++ ) {
        decoded_palette[i] = decodePaletteByte( palette[i] );
    }

    for( i=0; i<256; i++ ) {
        palette_[i] = decoded_palette[ color[i] & 0x0F ];
    }
}

void PacmanMachine::getDeviceInfo( InputDevice device, unsigned char * mask, unsigned char ** port )
{
    static unsigned char MaskInfo[] = {
        { 0x01 }, // Joy1_Up
        { 0x02 }, // Joy1_Left
        { 0x04 }, // Joy1_Right
        { 0x08 }, // Joy1_Down
        { 0x10 }, // Switch_RackAdvance
        { 0x20 }, // CoinSlot_1
        { 0x40 }, // CoinSlot_2
        { 0x80 }, // Switch_AddCredit
        { 0x01 }, // Joy2_Up
        { 0x02 }, // Joy2_Left
        { 0x04 }, // Joy2_Right
        { 0x08 }, // Joy2_Down
        { 0x10 }, // Switch_Test
        { 0x20 }, // Key_OnePlayer
        { 0x40 }, // Key_TwoPlayers
        { 0x80 }  // Switch_CocktailMode
    };

    *mask = MaskInfo[device];

    switch( device ) {
        case Joy1_Up:
        case Joy1_Left:
        case Joy1_Right:
        case Joy1_Down:
        case Switch_RackAdvance:
        case CoinSlot_1:
        case CoinSlot_2:
        case Switch_AddCredit:
            *port = &port1_;
            break;
        case Joy2_Up:
        case Joy2_Left:
        case Joy2_Right:
        case Joy2_Down:
        case Switch_Test:
        case Key_OnePlayer:
        case Key_TwoPlayers:
        case Switch_CocktailMode:
            *port = &port2_;
            break;
        default:
            *port = 0;
            break;
    }
}

PacmanMachine::InputDeviceMode PacmanMachine::getDeviceMode( InputDevice device ) const
{
    unsigned char mask;
    unsigned char * port;

    const_cast<PacmanMachine *>(this)->getDeviceInfo( device, &mask, &port );

    return (*port & mask) == 0 ? DeviceOn : DeviceOff;
}

/*
    Fire an input event, telling the emulator for example
    that the joystick has been released from the down position.
*/
void PacmanMachine::setDeviceMode( InputDevice device, InputDeviceMode mode )
{
    if( (getCoinLockout() == 0) && ((device == CoinSlot_1)||(device == CoinSlot_2)||(device == Switch_AddCredit)) ) {
        // Coin slots are locked, ignore command and exit
        return;
    }

    unsigned char mask;
    unsigned char * port;

    getDeviceInfo( device, &mask, &port );

    if( mode == DeviceOn )
        *port &= ~mask;
    else if( mode == DeviceOff )
        *port |= mask;
    else if( mode == DeviceToggle )
        *port ^= mask;
}

void PacmanMachine::setDipSwitches( unsigned value ) {
    dip_switches_ = (unsigned char) value;

    setDeviceMode( Switch_RackAdvance, value & DipRackAdvance_Auto ? DeviceOn : DeviceOff );
    setDeviceMode( Switch_Test, value & DipMode_Test ? DeviceOn : DeviceOff );
    setDeviceMode( Switch_CocktailMode, value & DipCabinet_Cocktail ? DeviceOn : DeviceOff );
}

unsigned PacmanMachine::getDipSwitches() const {
    unsigned result = dip_switches_;

    if( getDeviceMode(Switch_RackAdvance) == DeviceOn ) result |= DipRackAdvance_Auto;
    if( getDeviceMode(Switch_Test) == DeviceOn ) result |= DipMode_Test;
    if( getDeviceMode(Switch_CocktailMode) == DeviceOn ) result |= DipCabinet_Cocktail;

    return result;
}

void PacmanMachine::decodeCharByte( unsigned char b, unsigned char * charbuf, int charx, int chary, int charwidth )
{
    for( int i=3; i>=0; i-- ) {
        charbuf[charx+(chary+i)*charwidth] = (b & 1) | ((b >> 3) & 2);
        b >>= 1;
    }
}

void PacmanMachine::decodeCharLine( unsigned char * src, unsigned char * charbuf, int charx, int chary, int charwidth )
{
    for( int x=7; x>=0; x-- ) {
        decodeCharByte( *src++, charbuf, x+charx, chary, charwidth );
    }
}

void PacmanMachine::decodeCharSet( unsigned char * mem, unsigned char * charset )
{
    for( int i=0; i<256; i++ ) {
        unsigned char * src = mem + 16*i;
        unsigned char * dst = charset + 64*i;

        decodeCharLine( src,   dst, 0, 4, 8 );
        decodeCharLine( src+8, dst, 0, 0, 8 );
    }
}

void PacmanMachine::decodeSprites( unsigned char * mem, unsigned char * sprite_data )
{
    for( int i=0; i<64; i++ ) {
        unsigned char * src = mem + i*64;
        unsigned char * dst = sprite_data + 256*i;

        decodeCharLine( src   , dst, 8, 12, 16 );
        decodeCharLine( src+ 8, dst, 8,  0, 16 );
        decodeCharLine( src+16, dst, 8,  4, 16 );
        decodeCharLine( src+24, dst, 8,  8, 16 );
        decodeCharLine( src+32, dst, 0, 12, 16 );
        decodeCharLine( src+40, dst, 0,  0, 16 );
        decodeCharLine( src+48, dst, 0,  4, 16 );
        decodeCharLine( src+56, dst, 0,  8, 16 );
    }
}

/*
    Decode one byte from the encoded color palette.

    An encoded palette byte contains RGB information bit-packed as follows:
        
          bit: 7 6 5 4 3 2 1 0
        color: b b g g g r r r
*/
unsigned PacmanMachine::decodePaletteByte( unsigned char value )
{
    unsigned    bit0, bit1, bit2;
    unsigned    red, green, blue;

	bit0 = (value >> 0) & 0x01;
	bit1 = (value >> 1) & 0x01;
	bit2 = (value >> 2) & 0x01;
	red = 0x21 * bit0 + 0x47 * bit1 + 0x97 * bit2;

    bit0 = (value >> 3) & 0x01;
	bit1 = (value >> 4) & 0x01;
	bit2 = (value >> 5) & 0x01;
	green = 0x21 * bit0 + 0x47 * bit1 + 0x97 * bit2;

    bit0 = 0;
	bit1 = (value >> 6) & 0x01;
	bit2 = (value >> 7) & 0x01;
    blue = 0x21 * bit0 + 0x47 * bit1 + 0x97 * bit2;

    return (blue << 16 ) | (green << 8) | red;
}

/*
    Play and mix the sound voices into the specified buffer.
*/
void PacmanMachine::playSound( int * buf, int len, int samplingRate )
{
    // Clear the buffer
    memset( buf, 0, sizeof(int)*len );

    // Exit now if sound is disabled
    if( (output_devices_ & SoundEnabled) == 0 )
        return;

    // Let the chip play the sound
    sound_chip_.setSamplingRate( samplingRate );
    sound_chip_.playSound( buf, len );
}

static unsigned saveBuffer( unsigned char * buf, void * data, unsigned data_size )
{
    memcpy( buf, data, data_size );

    return data_size;
}

static unsigned loadBuffer( void * data, unsigned data_size, unsigned char * buf )
{
    memcpy( data, buf, data_size );

    return data_size;
}

static unsigned saveUint32( unsigned char * buffer, unsigned u )
{
    *buffer++ = (unsigned char) (u >> 24);
    *buffer++ = (unsigned char) (u >> 16);
    *buffer++ = (unsigned char) (u >> 8);
    *buffer   = (unsigned char) (u);

    return 4;
}

static unsigned loadUint32( unsigned char ** buffer )
{
    unsigned char * buf = *buffer;
    unsigned result = *buf++;

    result = (result << 8) | *buf++;
    result = (result << 8) | *buf++;
    result = (result << 8) | *buf++;

    *buffer = buf;

    return result;
}

unsigned PacmanMachine::getSizeOfSnapshotBuffer() const
{
    unsigned result = 
        sizeof( ram_ ) +
        sizeof( video_mem_ ) +
        sizeof( color_mem_ ) +
        sizeof( palette_data_ ) +
        sizeof( color_data_ ) +
        sizeof( charset_rom_ ) +
        sizeof( spriteset_rom_ ) +
        1 + // port1_
        1 + // port2_
        1 + // interrupt_vector_
        1 + // dip_switches_
        1 + // output_devices_
        4 + // coin_counter_
        8*4 + // sprites_ x
        8*4 + // sprites_ y
        sound_chip_.getSizeOfSnapshotBuffer() +
        cpu_->getSizeOfSnapshotBuffer();

    return result;
}

unsigned PacmanMachine::takeSnapshot( unsigned char * buffer )
{
    unsigned char * buf = buffer;

    buf += saveBuffer( buf, ram_, sizeof(ram_) );
    buf += saveBuffer( buf, video_mem_, sizeof(video_mem_) );
    buf += saveBuffer( buf, color_mem_, sizeof(color_mem_) );
    buf += saveBuffer( buf, palette_data_, sizeof(palette_data_) );
    buf += saveBuffer( buf, color_data_, sizeof(color_data_) );
    buf += saveBuffer( buf, charset_rom_, sizeof(charset_rom_) );
    buf += saveBuffer( buf, spriteset_rom_, sizeof(spriteset_rom_) );
    buf += saveBuffer( buf, &port1_, 1 );
    buf += saveBuffer( buf, &port2_, 1 );
    buf += saveBuffer( buf, &interrupt_vector_, 1 );
    buf += saveBuffer( buf, &dip_switches_, 1 );
    buf += saveBuffer( buf, &output_devices_, 1 );
    buf += saveUint32( buf, coin_counter_ );
    for( int i=0; i<=7; i++ ) {
        buf += saveUint32( buf, (unsigned) sprites_[i].x );
        buf += saveUint32( buf, (unsigned) sprites_[i].y );
    }
    buf += sound_chip_.takeSnapshot( buf );
    buf += cpu_->takeSnapshot( buf );

    return buf - buffer;
}

unsigned PacmanMachine::restoreSnapshot( unsigned char * buffer )
{
    unsigned char * buf =  buffer;

    unsigned char palette_data_buf[ sizeof(palette_data_) ];
    unsigned char color_data_buf[ sizeof(color_data_) ];

    buf += loadBuffer( ram_, sizeof(ram_), buf );
    buf += loadBuffer( video_mem_, sizeof(video_mem_), buf );
    buf += loadBuffer( color_mem_, sizeof(color_mem_), buf );
    buf += loadBuffer( palette_data_buf, sizeof(palette_data_buf), buf );
    buf += loadBuffer( color_data_buf, sizeof(color_data_buf), buf );
    buf += loadBuffer( charset_rom_, sizeof(charset_rom_), buf );
    buf += loadBuffer( spriteset_rom_, sizeof(spriteset_rom_), buf );
    buf += loadBuffer( &port1_, 1, buf );
    buf += loadBuffer( &port2_, 1, buf );
    buf += loadBuffer( &interrupt_vector_, 1, buf );
    buf += loadBuffer( &dip_switches_, 1, buf );
    buf += loadBuffer( &output_devices_, 1, buf );
    coin_counter_ = loadUint32( &buf );
    for( int i=0; i<=7; i++ ) {
        sprites_[i].x = (int) loadUint32( &buf );
        sprites_[i].y = (int) loadUint32( &buf );
        sprites_[i].color = ram_[ 0x4FF0 + i*2 + 1 ];
        sprites_[i].n = ram_[ 0x4FF0 + i*2 ] >> 2;
        sprites_[i].mode = ram_[ 0x4FF0 + i*2 ] & 0x03;
    }
    buf += sound_chip_.restoreSnapshot( buf );
    buf += cpu_->restoreSnapshot( buf );

    setColorROMs( palette_data_buf, color_data_buf );
    decodeCharSet( charset_rom_, charmap_ );
    decodeSprites( spriteset_rom_, spritemap_ );

    return buf - buffer;
}

void PacmanMachine::drawChar( unsigned char * buffer, int index, int ox, int oy, int color )
{
    buffer += ox + oy*224; // Make the buffer point to the character position
    index *= 64; // Make the index point to the character offset into the character table
    color = (color & 0x3F)*4;

    if( output_devices_ & FlipScreen ) {
        // Flip character
        buffer += 7*ScreenWidth;
        for( int y=0; y<8; y++ ) {
            for( int x=7; x>=0; x-- ) {
                buffer[x] = charmap_[ index++ ] + color;
            }
            buffer -= ScreenWidth; // Go to the next line
        }
    }
    else {
        for( int y=0; y<8; y++ ) {
            for( int x=0; x<=7; x++ ) {
                buffer[x] = charmap_[ index++ ] + color;
            }
            buffer += ScreenWidth; // Go to the next line
        }
    }
}

void PacmanMachine::drawSprite( unsigned char * buffer, int index )
{
    PacmanSprite & ps = sprites_[index];

    // Exit now if sprite not visible at all
    if( (ps.color == 0) || (ps.x >= ScreenWidth) || (ps.y < 16) || (ps.y >= (ScreenHeight-32)) ) {
        return;    
    }

    
    // Clip the sprite coordinates to cut the parts that fall off the screen
    int start_x = (ps.x < 0) ? 0 : ps.x;
    int end_x = (ps.x < (ScreenWidth-16)) ? ps.x+16 : ScreenWidth;

    // Prepare variables for drawing
    int color = (ps.color & 0x3F)*4;
    unsigned char * spritemap_base = spritemap_ + ((ps.n & 0x3F)*256);
    
    buffer += ScreenWidth*ps.y;

    // Draw the 16x16 sprite
    for( int y=0; y<16; y++ ) {
        for( int x=start_x; x<end_x; x++ ) {
            int c;
            int o = x-ps.x; // X position relative to the sprite

            if( ps.mode == 0 )                  // Normal
                c = spritemap_base[o+y*16];
            else if( ps.mode == 1 )             // Flip Y
                c = spritemap_base[o+(15-y)*16];
            else if( ps.mode == 2 )             // Flip X
                c = spritemap_base[15-o+y*16];
            else                                // Flip X and Y
                c = spritemap_base[15-o+(15-y)*16];

            if( c ) {
                buffer[x] = c + color;
            }
        }

        buffer += ScreenWidth;
    }
}

/*
    Draw the video into the specified buffer.
*/
void PacmanMachine::renderVideo( unsigned char * buffer )
{
    unsigned char * video = video_mem_;
    unsigned char * color = color_mem_;

    // Draw the background first...
    if( output_devices_ & FlipScreen ) {
        for( int y=ScreenHeight-CharHeight; y>=0; y-=CharHeight ) {
            for( int x=ScreenWidth-CharWidth; x>=0; x-=CharWidth ) {
                drawChar( buffer, *video++, x, y, *color++ );
            }
        }
    }
    else {
        for( int y=0; y<ScreenHeight; y+=CharHeight ) {
            for( int x=0; x<ScreenWidth; x+=CharWidth ) {
                drawChar( buffer, *video++, x, y, *color++ );
            }
        }
    }

    // ...then add the sprites
    for( int i=7; i>=0; i-- ) {
        drawSprite( buffer, i );
    }
}

/* Enables/disables the speed hack. */
int PacmanMachine::setSpeedHack( int enabled )
{
    int result = 0;

    if( enabled ) {
        if( (ram_[0x180B] == 0xBE) && (ram_[0x1FFD] == 0x00) ) {
            // Patch the ROM to activate the speed hack
            ram_[0x180B] = 0x01; // Activate speed hack
            ram_[0x1FFD] = 0xBD; // Fix ROM checksum

            result = 1;
        }
    }
    else {
        if( (ram_[0x180B] == 0x01) && (ram_[0x1FFD] == 0xBD) ) {
            // Restore the patched ROM locations
            ram_[0x180B] = 0xBE;
            ram_[0x1FFD] = 0x00;

            result = 1;
        }
    }

    return result;
}

/*
    The code to decrypt the Ms. Pacman aux ROMs derives from the
    MAME machine driver (mspacman.c) written by David Widel.
*/
static unsigned char decryptd( unsigned char e )
{
	unsigned char d;

	d  = (e & 0xC0) >> 3;
	d |= (e & 0x10) << 2;
	d |= (e & 0x0E) >> 1;
	d |= (e & 0x01) << 7;
	d |= (e & 0x20);

	return d;
}

static unsigned int decrypta1( unsigned int e )
{
	unsigned int d;

	d  = (e & 0x807);
	d |= (e & 0x400) >> 7;
	d |= (e & 0x200) >> 2;
	d |= (e & 0x080) << 3;
	d |= (e & 0x040) << 2;
	d |= (e & 0x138) << 1;

	return d;
}

static unsigned int decrypta2( unsigned int e )
{
	unsigned int d;

	d  = (e & 0x807);
	d |= (e & 0x040) << 4;
	d |= (e & 0x100) >> 3;
	d |= (e & 0x080) << 2;
	d |= (e & 0x600) >> 2;
	d |= (e & 0x028) << 1;
	d |= (e & 0x010) >> 1;

	return d;
}

void MsPacmanMachine::setAuxROM( unsigned char * u5, unsigned char * u6, unsigned char * u7 )
{
    int i;

    // Decrypt aux ROMs
	for( i=0; i<0x1000; i++ ) {
		rom_aux_[decrypta1(i)+0x4000] = decryptd(u7[i]);
		rom_aux_[decrypta1(i)+0x5000] = decryptd(u6[i]);
	}

	for( i=0; i<0x0800; i++ ) {
		rom_aux_[decrypta2(i)+0x6000] = decryptd(u5[i]);
	}

    // Copy original ROM, but replace 6J with U7
    memcpy( rom_aux_+0x0000, getRAM()+0x0000, 0x1000 );
    memcpy( rom_aux_+0x1000, getRAM()+0x1000, 0x1000 );
    memcpy( rom_aux_+0x2000, getRAM()+0x2000, 0x1000 );
    memcpy( rom_aux_+0x3000, rom_aux_+0x4000, 0x1000 ); // U7

    // Apply ROM patches (from scattered U5 locations)
	for( i=0; i<8; i++ ) {
        rom_aux_[0x0410+i] = rom_aux_[0x6008+i];
        rom_aux_[0x08E0+i] = rom_aux_[0x61D8+i];
        rom_aux_[0x0A30+i] = rom_aux_[0x6118+i];
        rom_aux_[0x0BD0+i] = rom_aux_[0x60D8+i];
        rom_aux_[0x0C20+i] = rom_aux_[0x6120+i];
        rom_aux_[0x0E58+i] = rom_aux_[0x6168+i];
        rom_aux_[0x0EA8+i] = rom_aux_[0x6198+i];

        rom_aux_[0x1000+i] = rom_aux_[0x6020+i];
        rom_aux_[0x1008+i] = rom_aux_[0x6010+i];
        rom_aux_[0x1288+i] = rom_aux_[0x6098+i];
        rom_aux_[0x1348+i] = rom_aux_[0x6048+i];
        rom_aux_[0x1688+i] = rom_aux_[0x6088+i];
        rom_aux_[0x16B0+i] = rom_aux_[0x6188+i];
        rom_aux_[0x16D8+i] = rom_aux_[0x60C8+i];
        rom_aux_[0x16F8+i] = rom_aux_[0x61C8+i];
        rom_aux_[0x19A8+i] = rom_aux_[0x60A8+i];
        rom_aux_[0x19B8+i] = rom_aux_[0x61A8+i];

        rom_aux_[0x2060+i] = rom_aux_[0x6148+i];
        rom_aux_[0x2108+i] = rom_aux_[0x6018+i];
        rom_aux_[0x21A0+i] = rom_aux_[0x61A0+i];
        rom_aux_[0x2298+i] = rom_aux_[0x60A0+i];
        rom_aux_[0x23E0+i] = rom_aux_[0x60E8+i];
        rom_aux_[0x2418+i] = rom_aux_[0x6000+i];
        rom_aux_[0x2448+i] = rom_aux_[0x6058+i];
        rom_aux_[0x2470+i] = rom_aux_[0x6140+i];
        rom_aux_[0x2488+i] = rom_aux_[0x6080+i];
        rom_aux_[0x24B0+i] = rom_aux_[0x6180+i];
        rom_aux_[0x24D8+i] = rom_aux_[0x60C0+i];
        rom_aux_[0x24F8+i] = rom_aux_[0x61C0+i];
        rom_aux_[0x2748+i] = rom_aux_[0x6050+i];
        rom_aux_[0x2780+i] = rom_aux_[0x6090+i];
        rom_aux_[0x27B8+i] = rom_aux_[0x6190+i];
        rom_aux_[0x2800+i] = rom_aux_[0x6028+i];
        rom_aux_[0x2B20+i] = rom_aux_[0x6100+i];
        rom_aux_[0x2B30+i] = rom_aux_[0x6110+i];
        rom_aux_[0x2BF0+i] = rom_aux_[0x61D0+i];
        rom_aux_[0x2CC0+i] = rom_aux_[0x60D0+i];
        rom_aux_[0x2CD8+i] = rom_aux_[0x60E0+i];
        rom_aux_[0x2CF0+i] = rom_aux_[0x61E0+i];
        rom_aux_[0x2D60+i] = rom_aux_[0x6160+i];
	}
}

unsigned char MsPacmanMachine::readByte( unsigned addr )
{
    addr &= 0xFFFF;

    if( aux_board_enabled_ ) {
        if( addr <= 0x4000 ) 
            return rom_aux_[addr];
        else if( addr >= 0x8000 ) {
            if( addr < 0x8800 )
                return rom_aux_[addr-0x8000+0x6000]; // U5
            else if( addr < 0xA000 )
                return rom_aux_[(addr & 0xFFF)+0x5000]; // U6
        }
    }
    else if( addr < getSizeOfRAM() ) {
        // Parent's readByte() handles this case too, however this saves a virtual 
        // function call in the likely case that the read location is in the Pacman ROM/RAM
        return getRAM()[addr];
    }

    return PacmanMachine::readByte( addr );
}

void MsPacmanMachine::writeByte( unsigned addr, unsigned char b )
{
    if( (addr == 0x5002) && (b & 1) ) {
        // Enable the aux board if writing to port 0x5002
        aux_board_enabled_ = 1;
    }

    PacmanMachine::writeByte( addr, b );
}

int MsPacmanMachine::setSpeedHack( int enabled )
{
    int result = 0;
    unsigned char * ram = getAddrOfRAM();

    if( enabled ) {
        if( (ram[0x1180] == 0xBE) && (ram[0x1FFD] == 0xFF) ) {
            // Patch the ROM to activate the speed hack
            ram[0x1180] = 0x01; // Activate speed hack
            ram[0x1FFD] = 0xBD; // Fix ROM checksum

            result = 1;
        }
    }
    else {
        if( (ram[0x1180] == 0x01) && (ram[0x1FFD] == 0xBC) ) {
            // Restore the patched ROM locations
            ram[0x1180] = 0xBE;
            ram[0x1FFD] = 0x00;

            result = 1;
        }
    }

    return result;
}

unsigned MsPacmanMachine::getSizeOfSnapshotBuffer() const
{
    unsigned result = 
        sizeof( rom_aux_ ) +
        1 + // aux_board_enabled_
        PacmanMachine::getSizeOfSnapshotBuffer();

    return result;
}

unsigned MsPacmanMachine::takeSnapshot( unsigned char * buffer )
{
    unsigned char * buf = buffer;

    buf += saveBuffer( buf, rom_aux_, sizeof(rom_aux_) );
    buf += saveBuffer( buf, &aux_board_enabled_, 1 );
    buf += PacmanMachine::takeSnapshot( buf );

    return buf - buffer;
}

unsigned MsPacmanMachine::restoreSnapshot( unsigned char * buffer )
{
    unsigned char * buf = buffer;

    buf += loadBuffer( rom_aux_, sizeof(rom_aux_), buf );
    buf += loadBuffer( &aux_board_enabled_, 1, buf );
    buf += PacmanMachine::restoreSnapshot( buf );

    return buf - buffer;
}
