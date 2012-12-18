/*
    Namco custom waveform sound generator 3 (Pacman hardware)

    Copyright (c) 2003,2004 Alessandro Scotti
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
#include <string.h>

#include "namcowsg3.h"

NamcoWsg3::NamcoWsg3( unsigned masterClock )
{
    master_clock_ = masterClock;
    setSamplingRate( 0 );

    for( int i=0; i<3; i++ ) {
        wave_offset_[i] = 0;
    }
}

void NamcoWsg3::setSoundPROM( const unsigned char * prom )
{
    memcpy( sound_prom_, prom, sizeof(sound_prom_) );

    for( int i=0; i<32*8; i++ ) {
        sound_wave_data_[i] = (int)*prom++ - 8;
    }
}

void NamcoWsg3::getVoice( NamcoWsg3Voice * voice, int index ) const
{
    int base = 5*index;

    voice->waveform = sound_regs_[ 0x05 + base ] & 0x07;
    voice->volume = sound_regs_[ 0x15 + base ] & 0x0F;

    unsigned f;
    
    f =            (sound_regs_[ 0x14+base ] & 0x0F);
    f = (f << 4) | (sound_regs_[ 0x13+base ] & 0x0F);
    f = (f << 4) | (sound_regs_[ 0x12+base ] & 0x0F);
    f = (f << 4) | (sound_regs_[ 0x11+base ] & 0x0F);
    f = (f << 4);

    if( index == 0 ) { // The first voice has an extra 4-bit of data
        f |= (sound_regs_[ 0x10+base ] & 0x0F); 
    }

    voice->frequency = f;
}

/*
    Play and mix the sound voices into the specified buffer.
*/
void NamcoWsg3::playSound( int * buf, int len )
{
    NamcoWsg3Voice voice;

    for( int index=0; index<3; index++ ) {
        getVoice( &voice, index );
        if( voice.isActive() ) {
            unsigned offset = wave_offset_[index];
            unsigned offset_step = voice.frequency * resample_step_;
            int * wave_data = sound_wave_data_ + 32 * voice.waveform;

            for( int i=0; i<len; i++ ) {
                // Should be shifted right by 15, but we must also get rid
                // of the 10 bits used for decimals
                buf[i] += wave_data[(offset >> 25) & 0x1F] * (int) voice.volume;
                offset += offset_step;
            }

            wave_offset_[index] = offset;
        }
    }
}

static unsigned addUint32( unsigned char * buffer, unsigned u )
{
    *buffer++ = (unsigned char) (u >> 24);
    *buffer++ = (unsigned char) (u >> 16);
    *buffer++ = (unsigned char) (u >> 8);
    *buffer   = (unsigned char) (u);

    return 4;
}

static unsigned getUint32( unsigned char ** buffer )
{
    unsigned char * buf = *buffer;
    unsigned result = *buf++;

    result = (result << 8) | *buf++;
    result = (result << 8) | *buf++;
    result = (result << 8) | *buf++;

    *buffer = buf;

    return result;
}

unsigned NamcoWsg3::getSizeOfSnapshotBuffer() const
{
    unsigned result =
        4 + // master_clock_
        4 + // sampling_rate_
        4*3 + // wave_offset_
        sizeof(sound_regs_) +
        sizeof(sound_prom_);

    return result;
}

unsigned NamcoWsg3::takeSnapshot( unsigned char * buffer )
{
    unsigned char * buf = buffer;

    buf += addUint32( buf, master_clock_ );
    buf += addUint32( buf, sampling_rate_ );
    buf += addUint32( buf, wave_offset_[0] );
    buf += addUint32( buf, wave_offset_[1] );
    buf += addUint32( buf, wave_offset_[2] );
    memcpy( buf, sound_regs_, sizeof(sound_regs_) );
    buf += sizeof(sound_regs_);
    memcpy( buf, sound_prom_, sizeof(sound_prom_) );
    buf += sizeof(sound_prom_);

    return buf - buffer;
}

unsigned NamcoWsg3::restoreSnapshot( unsigned char * buffer )
{
    unsigned char * buf = buffer;

    unsigned char prom[ sizeof(sound_prom_) ];

    master_clock_ = getUint32( &buf );
    sampling_rate_ = getUint32( &buf );
    wave_offset_[0] = getUint32( &buf );
    wave_offset_[1] = getUint32( &buf );
    wave_offset_[2] = getUint32( &buf );
    memcpy( sound_regs_, buf, sizeof(sound_regs_) );
    buf += sizeof(sound_regs_);
    memcpy( prom, buf, sizeof(prom) );
    buf += sizeof(prom);

    setSoundPROM( prom );

    return buf - buffer;
}
