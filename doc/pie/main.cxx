/*
    Pacman Instructional Emulator
    User interface for Windows

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
#include <windows.h>
#include <ddraw.h>
#include <dsound.h>
#include <stdio.h>
#include <assert.h>

#include "resource.h"

#include "arcade.h"
#include "dib24.h"

unsigned framesPerSecond    = PacmanMachine::VideoFrequency;
unsigned samplesPerSecond   = 44100;    // Valid values: 11025, 22050, 44100
unsigned bytesPerSample     = 2;        // Valid values: 1 or 2
unsigned samplesPerFrame    = samplesPerSecond / framesPerSecond;
unsigned sampleBytesPerFrame= bytesPerSample * samplesPerFrame;
unsigned soundBuffers       = 3;

static HWND     hWindow = NULL;         // Handle of main window
static int      windowWidth = PacmanMachine::ScreenWidth; // Width of client area
static int      windowHeight = PacmanMachine::ScreenHeight; // Height of client area
static BOOL     boIsActive = FALSE;     // Program active/inactive
static char     szAppName[] = "PacMan";

// Bitmap used for off-screen rendering
static Dib24    dCanvas( PacmanMachine::ScreenWidth, PacmanMachine::ScreenHeight );

// DIP switches
static unsigned dipDifficulty   = PacmanMachine::DipDifficulty_Normal;
static unsigned dipGhostNames   = PacmanMachine::DipGhostNames_Normal;
static unsigned dipLivesPerGame = PacmanMachine::DipLives_3;   
static unsigned dipCabinet      = PacmanMachine::DipCabinet_Upright;   
static unsigned dipBonus        = PacmanMachine::DipBonus_10000;

static char szHelp[] =
    "1 = one player\n"
    "2 = two players\n"
    "3 = insert coin in slot 1\n"
    "4 = insert coin in slot 2\n"
    "5 = add credit\n"
    "A = toggle rack advance switch\n"
    "F = activate speed hack\n"
    "S = deactivate speed hack\n"
    "T = toggle test switch\n"
    "Left/Up/Right/Down arrow keys = move joystick\n"
    "F2 = single/double window size\n"
    "F5/F6/F7 = save game snapshot\n"
    "F9 = restore F5 snapshot\n"
    "Escape = quit";

static char szAbout[] = 
    "PIE - Pacman Instructional Emulator\n"
    "Copyright (c) 1997-2003,2004 Alessandro Scotti\n"
    "\n"
    "http://www.ascotti.org/";

const char * SnapF5 = "snap.f5";
const char * SnapF6 = "snap.f6";
const char * SnapF7 = "snap.f7";

enum {
    GameNone = 0,
    GamePacmanMidway,
    GamePacmanNamco,
    GameMsPacman
};

PacmanMachine * machine = 0; // Arcade emulator
int gameLoaded = GameNone; // What type of machine is currently loaded

LPDIRECTSOUND directSound = 0; // Main direct sound object
IDirectSoundBuffer * directSoundBuf = 0; // Sound buffer
int * rawSoundBuf = 0; // Raw sound buffer used for machine->playSound()
BOOL applicationInitialized = FALSE;

IDirectDraw * directDraw = 0;
IDirectDrawSurface * ddPrimarySurface = 0;
IDirectDrawClipper * ddClipper = 0;
IDirectDrawSurface * ddBackSurface = 0;

HRESULT createObject( LPVOID object, HRESULT hres )
{
    if( hres != DD_OK ) {
        *((LPVOID *) object) = 0;
    }

    return hres;
}

void terminateDirectDraw()
{
    if( directDraw != 0 ) {
        if( ddBackSurface != 0 ) {
            ddBackSurface->Release();
        }

        if( ddClipper != 0 ) {
            ddClipper->Release();
        }

        if( ddPrimarySurface != 0 ) {
            ddPrimarySurface->Release();
        }

        directDraw->Release();
        directDraw = 0;
    }
}

bool initializeDirectDraw( HWND hWnd )
{
    bool result = true;

    HRESULT res;

    // Create direct draw interface
    res = createObject( &directDraw, DirectDrawCreate( NULL, &directDraw, NULL ) );

    // Set cooperative level
    if( res == DD_OK ) {
        res = directDraw->SetCooperativeLevel( hWnd, DDSCL_NORMAL );
    }

    // Create primary surface
    if( res == DD_OK ) {
        DDSURFACEDESC sd;

        ZeroMemory( &sd, sizeof(sd) );
        sd.dwSize = sizeof(sd);
        sd.dwFlags = DDSD_CAPS;
        sd.ddsCaps.dwCaps = DDSCAPS_PRIMARYSURFACE;

        res = createObject( &ddPrimarySurface, directDraw->CreateSurface( &sd, &ddPrimarySurface, NULL ) );
    }

    // Create clipper for the primary surface
    if( res == DD_OK ) {
        res = createObject( &ddClipper, directDraw->CreateClipper( 0, &ddClipper, NULL ) );
    }

    if( res == DD_OK ) {
        res = ddClipper->SetHWnd( 0, hWnd );
    }

    if( res == DD_OK ) {
        res = ddPrimarySurface->SetClipper( ddClipper );
    }

    // Create back buffer
    if( res == DD_OK ) {
        DDSURFACEDESC sd;

        ZeroMemory( &sd, sizeof(sd) );
        sd.dwSize = sizeof(sd);
        sd.dwFlags = DDSD_CAPS | DDSD_WIDTH | DDSD_HEIGHT;
        sd.dwWidth = windowWidth;
        sd.dwHeight = windowHeight;
        sd.ddsCaps.dwCaps = DDSCAPS_OFFSCREENPLAIN;

        res = createObject( &ddBackSurface, directDraw->CreateSurface( &sd, &ddBackSurface, NULL ) );
    }

    // Free resources if some error occurred
    if( res != DD_OK ) {
        terminateDirectDraw();
        result = false;
    }

    return result;
}

BOOL showError( const char * msg )
{
    MessageBox( 0, msg, "Error", MB_OK | MB_ICONERROR );
    return FALSE;
}

BOOL loadFile( const char * name, unsigned char * buf, int len, BOOL showErrorMsg = FALSE )
{
    char msg[200];
    FILE * f = fopen( name, "rb" );

    if( f == NULL ) {
        sprintf( msg, "Cannot open '%s'", name );
        if( showErrorMsg ) showError( msg );
        return FALSE;
    }
    
    int n = fread( buf, len, 1, f );
    
    fclose( f );

    if( n != 1 ) {
        sprintf( msg, "Error reading from '%s'", name );
        if( showErrorMsg ) showError( msg );
        return FALSE;
    }

    return TRUE;
}

int menuCheck( int condition )
{
    return condition ? MF_CHECKED : MF_UNCHECKED;
}

/*
    Sets the game DIP switches and updates the program menu accordingly.
*/
void setDipSwitches()
{
    HMENU   hMenu = GetMenu( hWindow );

    CheckMenuItem( hMenu, IDM_NORMAL, menuCheck(dipDifficulty == PacmanMachine::DipDifficulty_Normal) );
    CheckMenuItem( hMenu, IDM_HARD, menuCheck(dipDifficulty == PacmanMachine::DipDifficulty_Hard) );
  
    CheckMenuItem( hMenu, IDM_LIFE_0, menuCheck(dipLivesPerGame == PacmanMachine::DipLives_1) );
    CheckMenuItem( hMenu, IDM_LIFE_1, menuCheck(dipLivesPerGame == PacmanMachine::DipLives_2) );
    CheckMenuItem( hMenu, IDM_LIFE_2, menuCheck(dipLivesPerGame == PacmanMachine::DipLives_3) );
    CheckMenuItem( hMenu, IDM_LIFE_3, menuCheck(dipLivesPerGame == PacmanMachine::DipLives_5) );

    CheckMenuItem( hMenu, IDM_GHOST_0, menuCheck(dipGhostNames == PacmanMachine::DipGhostNames_Normal) );
    CheckMenuItem( hMenu, IDM_GHOST_1, menuCheck(dipGhostNames == PacmanMachine::DipGhostNames_Alternate) );

    CheckMenuItem( hMenu, IDM_CABINET_UPRIGHT, menuCheck(dipCabinet == PacmanMachine::DipCabinet_Upright) );
    CheckMenuItem( hMenu, IDM_CABINET_COCKTAIL, menuCheck(dipCabinet == PacmanMachine::DipCabinet_Cocktail) );

    CheckMenuItem( hMenu, IDM_BONUS_10000, menuCheck(dipBonus == PacmanMachine::DipBonus_10000) );
    CheckMenuItem( hMenu, IDM_BONUS_15000, menuCheck(dipBonus == PacmanMachine::DipBonus_15000) );
    CheckMenuItem( hMenu, IDM_BONUS_20000, menuCheck(dipBonus == PacmanMachine::DipBonus_20000) );
    CheckMenuItem( hMenu, IDM_BONUS_NONE, menuCheck(dipBonus == PacmanMachine::DipBonus_None) );

    unsigned dip = machine->getDipSwitches() & (PacmanMachine::DipPlay_Mask | PacmanMachine::DipMode_Mask);
    machine->setDipSwitches( dip | dipDifficulty | dipGhostNames | dipLivesPerGame | dipBonus | dipCabinet );
}

/*
    Saves a snapshot of the game.
*/
void takeSnapshot( const char * filename )
{
    unsigned bufsize = 1 + machine->getSizeOfSnapshotBuffer();
    unsigned char * buffer = new unsigned char [ bufsize ];

    *buffer = (unsigned char)(gameLoaded);
    machine->takeSnapshot( buffer+1 );

    FILE * f = fopen( filename, "wb" );

    assert( f != NULL );

    fwrite( buffer, 1, bufsize, f );
    fclose( f );

    delete buffer;
}

/*
    Restores a snapshot of the game.
*/
void restoreSnapshot( const char * filename )
{
    PacmanMachine * newmachine = 0;

    FILE * f = fopen( filename, "rb" );

    if( f != 0 ) {
        unsigned char game;

        fread( &game, 1, 1, f );

        switch( game ) {
        case GamePacmanMidway:
        case GamePacmanNamco:
            newmachine = new PacmanMachine;
            break;
        case GameMsPacman:
            newmachine = new MsPacmanMachine;
            break;
        }

        if( newmachine != 0 ) {
            unsigned bufsize = newmachine->getSizeOfSnapshotBuffer();
            unsigned char * buffer = new unsigned char [ bufsize ];

            if( fread( buffer, 1, bufsize, f ) == bufsize ) {
                newmachine->restoreSnapshot( buffer );

                dipDifficulty = newmachine->getDipSwitches() & PacmanMachine::DipDifficulty_Mask;
                dipGhostNames = newmachine->getDipSwitches() & PacmanMachine::DipGhostNames_Mask;
                dipLivesPerGame = newmachine->getDipSwitches() & PacmanMachine::DipLives_Mask;
                dipBonus = newmachine->getDipSwitches() & PacmanMachine::DipBonus_Mask;
                setDipSwitches();

                delete machine;
                machine = newmachine;
            }
            else {
                delete newmachine;
            }

            fclose( f );

            delete buffer;
        }
    }
}

/*
    Initializes the sound library and creates the DirectX sound objects
    used by the application.
*/
BOOL initSound( void )
{
    BOOL result = FALSE;

    if( DS_OK == DirectSoundCreate(NULL, &directSound, NULL) ) {
        directSound->SetCooperativeLevel( hWindow, DSSCL_NORMAL );

        DSBUFFERDESC    bufdesc = { 0 };
        WAVEFORMATEX    wfx = { 0 };

        wfx.wFormatTag = WAVE_FORMAT_PCM;
        wfx.nChannels = 1;
        wfx.nSamplesPerSec = samplesPerSecond;
        wfx.wBitsPerSample = bytesPerSample * 8;
        wfx.nBlockAlign = (wfx.nChannels * wfx.wBitsPerSample) / 8;
        wfx.nAvgBytesPerSec = wfx.nSamplesPerSec * wfx.nBlockAlign;

        bufdesc.dwSize = sizeof(bufdesc);
        bufdesc.dwFlags = DSBCAPS_GLOBALFOCUS | DSBCAPS_GETCURRENTPOSITION2;
        bufdesc.dwBufferBytes = wfx.nBlockAlign * samplesPerFrame * soundBuffers;
        bufdesc.lpwfxFormat = &wfx;

        if( SUCCEEDED(directSound->CreateSoundBuffer( &bufdesc, &directSoundBuf, NULL)) ) {
            LPVOID p1;
            DWORD size1;

            if( SUCCEEDED(directSoundBuf->Lock(0, bufdesc.dwBufferBytes, &p1, &size1, 0, 0, 0)) ) {
                ZeroMemory( p1, size1 );
                directSoundBuf->Unlock( p1, size1, 0, 0 );
                result = TRUE;
            }
            else {
                showError( "Error: cannot lock the DirectSoundBuffer object!" );
                directSoundBuf->Release();
                directSoundBuf = 0;
            }
        }
        else {
            showError( "Error: cannot create DirectSoundBuffer object!" );
            directSoundBuf = 0;
        }
    }
    else {
        showError( "Error: cannot create DirectSound object!" );
        directSound = 0;
    }

    return result;
}

/*
    Activates/deactivates the program.

    Note: when the program is not active, emulation and sound playing are stopped.
*/
void setActive( BOOL active )
{
    if( !applicationInitialized || (gameLoaded == GameNone) )
        return;

    active = active ? TRUE : FALSE; // Normalize the boolean values!

    if( active != boIsActive ) {
        boIsActive = active;
        if( active ) {
            directSoundBuf->Play( 0, 0, DSBPLAY_LOOPING );
        }
        else {
            directSoundBuf->Stop();
        }
    }
}

BOOL loadGameROM( int game )
{
    BOOL romLoaded = FALSE;
    PacmanMachine * newmachine = 0;

    unsigned char   buffer[ 0x6000 ];
    unsigned char   palette[0x20];
    unsigned char   color[0x100];

    // Files common to all ROM sets
    if( (! loadFile( "82s126.4a", color, sizeof(color), TRUE)) ||
        (! loadFile( "82s123.7f", palette, sizeof(palette), TRUE)) )
    {
        return FALSE;
    }

    // Basic game ROMs
    switch( game ) {
    case GamePacmanNamco:
        newmachine = new PacmanMachine;
        romLoaded = loadFile( "namcopac.6e", buffer, 0x1000 ) &&
            loadFile( "namcopac.6f", buffer+0x1000, 0x1000 ) &&
            loadFile( "namcopac.6h", buffer+0x2000, 0x1000 ) &&
            loadFile( "namcopac.6j", buffer+0x3000, 0x1000 ) &&
            loadFile( "pacman.5e", buffer+0x4000, 0x1000 ) &&
            loadFile( "pacman.5f", buffer+0x5000, 0x1000 );
        break;
    case GameMsPacman:
        newmachine = new MsPacmanMachine;
        romLoaded = loadFile( "pacman.6e", buffer, 0x1000 ) &&
            loadFile( "pacman.6f", buffer+0x1000, 0x1000 ) &&
            loadFile( "pacman.6h", buffer+0x2000, 0x1000 ) &&
            loadFile( "pacman.6j", buffer+0x3000, 0x1000 ) &&
            loadFile( "5e", buffer+0x4000, 0x1000 ) &&
            loadFile( "5f", buffer+0x5000, 0x1000 );
        break;
    case GamePacmanMidway:
        newmachine = new PacmanMachine;
        romLoaded = loadFile( "pacman.6e", buffer, 0x1000 ) &&
            loadFile( "pacman.6f", buffer+0x1000, 0x1000 ) &&
            loadFile( "pacman.6h", buffer+0x2000, 0x1000 ) &&
            loadFile( "pacman.6j", buffer+0x3000, 0x1000 ) &&
            loadFile( "pacman.5e", buffer+0x4000, 0x1000 ) &&
            loadFile( "pacman.5f", buffer+0x5000, 0x1000 );
        break;
    }

    // Set ROMs and, if necessary, load aux ROMs
    if( romLoaded ) {
        newmachine->setROM( buffer );
        newmachine->setVideoROMs( buffer+0x4000, buffer+0x5000 );
        newmachine->setColorROMs( palette, color );

        // Load Ms. Pacman ROMs (must do it after the basic ROMs!)
        if( game == GameMsPacman ) {
            romLoaded = loadFile( "u5", buffer+0x0000, 0x0800 ) &&
                loadFile( "u6", buffer+0x0800, 0x1000 ) &&
                loadFile( "u7", buffer+0x1800, 0x1000 );

            // Add extra (ROM) board to emulator
            reinterpret_cast<MsPacmanMachine *>(newmachine)->setAuxROM( buffer+0x0000, buffer+0x0800, buffer+0x1800 );
        }
    }

    if( romLoaded ) {
        delete machine;
        machine = newmachine;
        machine->reset();
        gameLoaded = game;
    }
    else {
        delete newmachine;
    }

    return romLoaded;
}

void loadGame( int game, int quiet )
{
    if( ! loadGameROM( game ) ) {
        if( ! quiet ) showError( "Game ROMs not found!" );
    }

    setActive( TRUE );
}

void blitGameScreen()
{
    RECT rcRectDest;
    POINT p;

    p.x = 0; 
    p.y = 0;
    ClientToScreen(hWindow, &p);
    GetClientRect(hWindow, &rcRectDest);
    OffsetRect(&rcRectDest, p.x, p.y);
    ddPrimarySurface->Blt( &rcRectDest, ddBackSurface, NULL, DDBLT_WAIT, NULL);
}

void drawGameScreen()
{
    HDC dc;
    
    if( DD_OK == ddBackSurface->GetDC(&dc) ) {
        dCanvas.stretch( dc, 0, 0, PacmanMachine::ScreenWidth, PacmanMachine::ScreenHeight);
        ddBackSurface->ReleaseDC( dc );
    }
}

/*
    Initializes the game engine.
*/
BOOL gameInit( void )
{
    // Initialize the sound library
    if( ! initSound() )
        return FALSE;

    if( ! initializeDirectDraw(hWindow) )
        return FALSE;

    dCanvas.clear();
    drawGameScreen();

    rawSoundBuf = new int[ samplesPerFrame ];

    // Load game ROMs
    loadGame( GamePacmanMidway, TRUE );

    applicationInitialized = TRUE;

    return TRUE;
}

/*
    Runs the game engine for one frame.
*/
void CALLBACK gameProc( void )
{
    static unsigned bufferIndex = 0;

    if( ! boIsActive )
        return;

    // Run the machine for a frame
    machine->run();

    bool drawVideo = (machine->getFrameCount() & 1) != 0;

    // Prepare the sound buffer
    machine->playSound( rawSoundBuf, samplesPerFrame, samplesPerSecond );

    // Draw the video image into the off-screen bitmap
    if( drawVideo ) {
        unsigned char video_buffer[ PacmanMachine::ScreenWidth * PacmanMachine::ScreenHeight ];
        unsigned char * vbuf = video_buffer;
        const unsigned * palette = machine->getPalette();
        
        machine->renderVideo( vbuf );

        for( int y=0; y<PacmanMachine::ScreenHeight; y++ ) {
            // Use direct access to the bitmap scanline in place of
            // setFastPixel() for performance (the time saved here comes useful when
            // the window is zoomed, which slows down painting considerably).
            unsigned char * dst = dCanvas.getScanLine( y );
            for( int x=0; x<PacmanMachine::ScreenWidth; x++ ) {
                unsigned color = palette[ *vbuf++ ];
                *dst++ = (unsigned char) (color >> 16);
                *dst++ = (unsigned char) (color >> 8);
                *dst++ = (unsigned char) (color);
            }
        }
    }

    // Sync to audio buffer: this makes sure the play cursor is not in the part
    // of the buffer that we are going to write, but I'm not particularly
    // happy of this solution because GetCurrentPosition() returns often
    // wrong information. Triple buffering seems to help a little...
    DWORD dwPlayCursor;
    DWORD dwWriteCursor;
    DWORD dwLoBound = bufferIndex*sampleBytesPerFrame;
    DWORD dwHiBound = dwLoBound + sampleBytesPerFrame;

    do {
        directSoundBuf->GetCurrentPosition( &dwPlayCursor, &dwWriteCursor );
    } while( dwPlayCursor >= dwLoBound && dwPlayCursor < dwHiBound );

    // Copy the sound in the back buffer
    void *  pwBuf = 0;
    DWORD   dwBufSize = 0;

    if( DS_OK == directSoundBuf->Lock( bufferIndex*sampleBytesPerFrame, 
        sampleBytesPerFrame, 
        &pwBuf, 
        &dwBufSize, 
        0, 0, 0 ) )
    {
        assert( pwBuf != 0 );
        assert( dwBufSize == sampleBytesPerFrame );

        // Write into the sound buffer
        int i;
        int * rawBuf = rawSoundBuf;
        BYTE * sndBuf = (BYTE *)pwBuf;

        if( bytesPerSample == 1 ) {
            for( i=0; i<(int)samplesPerFrame; i++ ) {
                *sndBuf++ = (BYTE) (*rawBuf++ / 3) + 0x80;
                /*
                    A faster sequence could be:  
                      *sndBuf++ = (BYTE) (*rawBuf++ >> 2) + 0x80;
                */
            }
        }
        else {
            for( i=0; i<(int)samplesPerFrame; i++ ) {
                WORD w = (WORD)(*rawBuf++ * 85);
                *sndBuf++ = (BYTE) (w);
                *sndBuf++ = (BYTE) (w >> 8);
                /*
                    A faster sequence could be:  
                      *((WORD *)sndBuf) = (WORD)(*rawBuf++ << 6);
                      sndBuf += 2;
                */
            }
        }

        directSoundBuf->Unlock( pwBuf, dwBufSize, 0, 0 );
    }

    // Blit last frame and draw current in the back buffer
    if( drawVideo ) {
        blitGameScreen();
        drawGameScreen();
    }

    // Flip the buffer!
    bufferIndex++;
    if( bufferIndex >= soundBuffers ) bufferIndex = 0;
}

/*
    Terminates the game engine.
*/
void gameTerm()
{
    if( directSound ) {
        if( directSoundBuf ) {
            directSoundBuf->Stop();
            directSoundBuf->Release();
        }
        directSound->Release();
        directSound = 0;
    }

    terminateDirectDraw();

    delete rawSoundBuf;
}

void setWindowSize( int sizeFactor )
{
    windowWidth = sizeFactor*PacmanMachine::ScreenWidth; 
    windowHeight = sizeFactor*PacmanMachine::ScreenHeight;

    RECT    rc;

    rc.left = 0; 
    rc.top = 0; 
    rc.right = windowWidth;
    rc.bottom = windowHeight;

    AdjustWindowRect( &rc, WS_VISIBLE | WS_OVERLAPPEDWINDOW, TRUE );

    SetWindowPos( hWindow, HWND_TOP, 0, 0, rc.right-rc.left, rc.bottom-rc.top, SWP_NOCOPYBITS | SWP_NOMOVE );
}

/*
    Window procedure.
*/
LRESULT PASCAL WndProc( HWND hWnd, UINT wMsg, WPARAM wParam, LPARAM lParam )
{
    PAINTSTRUCT stPS;
    HDC hDC;
    static BOOL boSavedActiveFlag = FALSE;

    switch( wMsg ) {
        // No need to erase the background
        case WM_ERASEBKGND:
            return TRUE;
        // Paint the window by just blitting the game video
        case WM_PAINT:
            hDC = BeginPaint( hWnd, &stPS );
            dCanvas.stretch( hDC, 0, 0, windowWidth, windowHeight );
            EndPaint( hWnd, &stPS );
            return TRUE;
        // Application is activating/deactivating
        case WM_ACTIVATEAPP:
            setActive( (BOOL)wParam );
            break;
        case WM_ENTERSIZEMOVE:
        case WM_ENTERMENULOOP:
            boSavedActiveFlag = boIsActive;
            setActive( FALSE );
            break;
        case WM_EXITSIZEMOVE:
        case WM_EXITMENULOOP:
            setActive( boSavedActiveFlag );
            break;
        // Menu commands
        case WM_COMMAND:
            switch( LOWORD(wParam) ) {
            case IDM_LOAD_PACMAN:
                loadGame( GamePacmanMidway, FALSE );
                break;
            case IDM_LOAD_NAMCOPAC:
                loadGame( GamePacmanNamco, FALSE );
                break;
            case IDM_LOAD_MSPACMAN:
                loadGame( GameMsPacman, FALSE );
                break;
            case IDM_NEW:
                machine->reset();
                break;
            case IDM_SNAP_0:
                restoreSnapshot( SnapF5 );
                break;
            case IDM_SNAP_1:
                restoreSnapshot( SnapF6 );
                break;
            case IDM_SNAP_2:
                restoreSnapshot( SnapF7 );
                break;
            case IDM_EXIT:
                PostMessage( hWnd, WM_CLOSE, 0, 0 );
                break;
            case IDM_WINDOW_SIZE:
                setWindowSize( (windowWidth == PacmanMachine::ScreenWidth) ? 2 : 1 );
                break;
            case IDM_HELP_KEYS:
                MessageBox( 0, szHelp, "Keys", MB_OK | MB_ICONINFORMATION );
                break;
            case IDM_ABOUT:
                MessageBox( 0, szAbout, szAppName, MB_OK | MB_ICONINFORMATION );
                break;
            case IDM_LIFE_0:
                dipLivesPerGame = PacmanMachine::DipLives_1;
                setDipSwitches();
                break;
            case IDM_LIFE_1:
                dipLivesPerGame = PacmanMachine::DipLives_2;
                setDipSwitches();
                break;
            case IDM_LIFE_2:
                dipLivesPerGame = PacmanMachine::DipLives_3;
                setDipSwitches();
                break;
            case IDM_LIFE_3:
                dipLivesPerGame = PacmanMachine::DipLives_5;
                setDipSwitches();
                break;
            case IDM_HARD:
                dipDifficulty = PacmanMachine::DipDifficulty_Hard;
                setDipSwitches();
                break;
            case IDM_NORMAL:
                dipDifficulty = PacmanMachine::DipDifficulty_Normal;
                setDipSwitches();
                break;
            case IDM_GHOST_0:
                dipGhostNames = PacmanMachine::DipGhostNames_Normal;
                setDipSwitches();
                break;
            case IDM_GHOST_1:
                dipGhostNames = PacmanMachine::DipGhostNames_Alternate;
                setDipSwitches();
                break;
            case IDM_BONUS_10000:
                dipBonus = PacmanMachine::DipBonus_10000;
                setDipSwitches();
                break;
            case IDM_BONUS_15000:
                dipBonus = PacmanMachine::DipBonus_15000;
                setDipSwitches();
                break;
            case IDM_BONUS_20000:
                dipBonus = PacmanMachine::DipBonus_20000;
                setDipSwitches();
                break;
            case IDM_BONUS_NONE:
                dipBonus = PacmanMachine::DipBonus_None;
                setDipSwitches();
                break;
            case IDM_CABINET_UPRIGHT:
                dipCabinet = PacmanMachine::DipCabinet_Upright;
                setDipSwitches();
                break;
            case IDM_CABINET_COCKTAIL:
                dipCabinet = PacmanMachine::DipCabinet_Cocktail;
                setDipSwitches();
                break;
            }
            break;
        // Keyboard events
        case WM_KEYDOWN:
        case WM_KEYUP:
            // Handle machine device events first...
            {
                PacmanMachine::InputDeviceMode mode = (wMsg == WM_KEYDOWN) ? PacmanMachine::DeviceOn : PacmanMachine::DeviceOff;
                switch( wParam ) {
                case '1':
                    machine->setDeviceMode( PacmanMachine::Key_OnePlayer, mode );
                    break;
                case '2':
                    machine->setDeviceMode( PacmanMachine::Key_TwoPlayers, mode );
                    break;
                case '3':
                    machine->setDeviceMode( PacmanMachine::CoinSlot_1, mode );
                    break;
                case '4':
                    machine->setDeviceMode( PacmanMachine::CoinSlot_2, mode );
                    break;
                case '5':
                    machine->setDeviceMode( PacmanMachine::Switch_AddCredit, mode );
                    break;
                case VK_LEFT: 
                    machine->setDeviceMode( PacmanMachine::Joy1_Left, mode );
                    machine->setDeviceMode( PacmanMachine::Joy2_Left, mode );
                    break;
                case VK_RIGHT:
                    machine->setDeviceMode( PacmanMachine::Joy1_Right, mode );
                    machine->setDeviceMode( PacmanMachine::Joy2_Right, mode );
                    break;
                case VK_UP:
                    machine->setDeviceMode( PacmanMachine::Joy1_Up, mode );
                    machine->setDeviceMode( PacmanMachine::Joy2_Up, mode );
                    break;
                case VK_DOWN:
                    machine->setDeviceMode( PacmanMachine::Joy1_Down, mode );
                    machine->setDeviceMode( PacmanMachine::Joy2_Down, mode );
                    break;
                }
            }
            // ...then handle application events
            if( wMsg == WM_KEYDOWN ) switch( wParam ) {
            case 'A':
                machine->setDeviceMode( PacmanMachine::Switch_RackAdvance, PacmanMachine::DeviceToggle );
                break;
            case 'F':
                machine->setSpeedHack( 1 ); // Fast pacman
                break;
            case 'S':
                machine->setSpeedHack( 0 ); // Slow (normal) pacman
                break;
            case 'T':
                machine->setDeviceMode( PacmanMachine::Switch_Test, PacmanMachine::DeviceToggle );
                break;
            case ' ':
                setActive( ! boIsActive );
                break;
            case VK_ESCAPE:
                PostMessage( hWnd, WM_CLOSE, 0, 0 );
                return 0;
            case VK_F2:
                setWindowSize( (windowWidth == PacmanMachine::ScreenWidth) ? 2 : 1 );
                break;
            case VK_F4:
                // Cheat: add one life
                {
                    unsigned char * ram = const_cast<unsigned char *>(machine->getRAM());
                    ram[0x4E14]++;
                    ram[0x4E15]++;
                }
                break;
            case VK_F5:
                takeSnapshot( SnapF5 );
                break;
            case VK_F6:
                takeSnapshot( SnapF6 );
                break;
            case VK_F7:
                takeSnapshot( SnapF7 );
                break;
            case VK_F9:
                restoreSnapshot( SnapF5 );
                break;
            }
            break;
        // Destroy window
        case WM_DESTROY:
            PostQuitMessage( 0 );
            break;
    }
    return DefWindowProc( hWnd, wMsg, wParam, lParam );
}

/*
    Application main.
*/
int WINAPI WinMain( HINSTANCE hInstance, HINSTANCE hPrevInst, LPSTR lpCmdLine, int nCmdShow )
{
    MSG         stMsg;
    WNDCLASS    stWndClass;
    HWND        hWnd;

    /* Setup window class structure */
    stWndClass.style = CS_DBLCLKS;
    stWndClass.lpfnWndProc = WndProc;
    stWndClass.cbClsExtra = 0;
    stWndClass.cbWndExtra = 0;
    stWndClass.hInstance = hInstance;
    stWndClass.hIcon = LoadIcon( hInstance, MAKEINTRESOURCE(IDI_MAIN) );
    stWndClass.hCursor = LoadCursor( NULL, IDC_ARROW );
    stWndClass.hbrBackground = (HBRUSH)GetStockObject( BLACK_BRUSH );
    stWndClass.lpszMenuName = MAKEINTRESOURCE( IDM_MAIN );
    stWndClass.lpszClassName = "PacmanDemoProgram";

    /* Register window class */
    if( ! RegisterClass( &stWndClass ) )
        return 0;

    DWORD   wndStyle = WS_VISIBLE | WS_OVERLAPPEDWINDOW;
    RECT    rc;

    SetRect( &rc, 0, 0, windowWidth, windowHeight );

    AdjustWindowRect( &rc, wndStyle, TRUE );

    /* Create window */
    hWnd = CreateWindowEx( 0,               // Extended style
        stWndClass.lpszClassName,           // Class
        szAppName,                          // Title
        wndStyle,                           // Style
        CW_USEDEFAULT,                      // X
        CW_USEDEFAULT,                      // Y
        rc.right-rc.left, 
        rc.bottom-rc.top,
        NULL,                               // Parent or owner window
        NULL,                               // Menu or child window id
        hInstance,                          // Instance handle
        NULL );                             // Pointer to window creation data

    if( hWnd == NULL )
        return 0;

    hWindow = hWnd;

    /* Main loop */
    if( gameInit() ) {
        ShowWindow( hWnd, SW_SHOWNORMAL );
        UpdateWindow( hWnd );

        setActive( TRUE );

        while( TRUE ) {
            if( PeekMessage( &stMsg, NULL, 0, 0, PM_NOREMOVE ) ) {
                if( !GetMessage( &stMsg, NULL, 0, 0 ) )
                    break;
                TranslateMessage( &stMsg );
                DispatchMessage( &stMsg );
            }
            else if( boIsActive ) {
                gameProc();
            }
            else {
                WaitMessage();
            }
        }
    }

    gameTerm();

    return 0;
}
