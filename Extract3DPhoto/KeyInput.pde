// Keyboard and mouse input handling

static final int KEYCODE_BACKSPACE = 8;
static final int KEYCODE_ENTER = 10;
static final int KEYCODE_ESCAPE = 27;
static final int KEYCODE_SPACE = 32;
static final int KEYCODE_0 = 48;
static final int KEYCODE_1 = 49;
static final int KEYCODE_2 = 50;
static final int KEYCODE_3 = 51;
static final int KEYCODE_4 = 52;
static final int KEYCODE_5 = 53;
static final int KEYCODE_6 = 54;
static final int KEYCODE_7 = 55;
static final int KEYCODE_8 = 56;
static final int KEYCODE_9 = 57;
static final int KEYCODE_MINUS = 45;
static final int KEYCODE_PLUS = 61;
static final int KEYCODE_A = 65;
static final int KEYCODE_B = 66;
static final int KEYCODE_C = 67;
static final int KEYCODE_D = 68;
static final int KEYCODE_E = 69;
static final int KEYCODE_F = 70;
static final int KEYCODE_G = 71;
static final int KEYCODE_H = 72;
static final int KEYCODE_I = 73;
static final int KEYCODE_J = 74;
static final int KEYCODE_K = 75;
static final int KEYCODE_L = 76;
static final int KEYCODE_M = 77;
static final int KEYCODE_N = 78;
static final int KEYCODE_O = 79;
static final int KEYCODE_P = 80;
static final int KEYCODE_Q = 81;
static final int KEYCODE_R = 82;
static final int KEYCODE_S = 83;
static final int KEYCODE_T = 84;
static final int KEYCODE_U = 85;
static final int KEYCODE_V = 86;
static final int KEYCODE_W = 87;
static final int KEYCODE_X = 88;
static final int KEYCODE_Y = 89;
static final int KEYCODE_Z = 90;
static final int KEYCODE_LEFT_BRACKET = 91;
static final int KEYCODE_RIGHT_BRACKET = 93;
static final int KEYCODE_DEL = 127;
static final int KEYCODE_MEDIA_NEXT = 87;
static final int KEYCODE_MEDIA_PLAY_PAUSE = 85;
static final int KEYCODE_MEDIA_PREVIOUS = 88;
static final int KEYCODE_PAGE_DOWN = 93;
static final int KEYCODE_PAGE_UP = 92;
static final int KEYCODE_PLAY = 126;
static final int KEYCODE_MEDIA_STOP = 86;
static final int KEYCODE_MEDIA_REWIND = 89;
static final int KEYCODE_MEDIA_RECORD = 130;
static final int KEYCODE_MEDIA_PAUSE = 127;
static final int KEYCODE_MOVE_HOME       = 122;
static final int KEYCODE_MOVE_END       = 123;

// lastKey and lastKeyCode are handled in the draw loop
int lastKey;
int lastKeyCode;

void keyReleased() {
}

void keyPressed() {
  if (DEBUG) println("key="+key + " keyCode="+keyCode);        
  //if (DEBUG) Log.d(TAG, "key=" + key + " keyCode=" + keyCode);
  lastKey = key;
  lastKeyCode = keyCode;
}

// Handling key in the main loop not in keyPressed()
// returns false no key processed
// returns true when a key is processed
boolean keyUpdate() {
  if (lastKey == 0 && lastKeyCode == 0) {
    return false;
  }
  //if (DEBUG) println("keyUpdate lastKey="+lastKey + " lastKeyCode="+lastKeyCode);

  if (lastKeyCode == KEYCODE_A && mode == MODE_3D) {
    anaglyph = !anaglyph;
    screen = makeAnaglyph(anaglyph);
    lastKey = 0;
    lastKeyCode = 0;
    return true;
  }
  if (anaglyph) {
    if (lastKeyCode == KEYCODE_S) {
    } else if (lastKeyCode == KEYCODE_X) {
      leftToRight = ! leftToRight;
      screen = makeAnaglyph(true);
      lastKey = 0;
      lastKeyCode = 0;
      return true;
    } else {
      lastKey = 0;
      lastKeyCode = 0;
      return true;
    }
  }

  switch (lastKeyCode) {
  case KEYCODE_BACKSPACE:
    if (0 < newFrame) {
      newFrame--;
      offsetX = 0;
      offsetY = 0;
      setFrame(newFrame);
    }
    break;
  case KEYCODE_SPACE:
    if (newFrame < getLength() - 1) {
      newFrame++;
      offsetX = 0;
      offsetY = 0;
      setFrame(newFrame);
    }
    break;
  case LEFT:
    offsetX--;
    break;
  case RIGHT:
    offsetX++;
    break;
  case UP:
    offsetY--;
    break;
  case DOWN:
    offsetY++;
    break;
  case KEYCODE_W: // debug output including stereo window parallax offset
    parallax = leftMouseX - rightMouseX;
    if (DEBUG) println("lastMouseX="+lastMouseX);
    if (DEBUG) println("leftMouseX="+leftMouseX + " rightMouseX="+rightMouseX);
    if (DEBUG) println("anaglyph=" + anaglyph +" parallax="+parallax);
    break;
  case KEYCODE_0:
  case KEYCODE_1:
  case KEYCODE_2:
  case KEYCODE_3:
  case KEYCODE_4:
  case KEYCODE_5:
  case KEYCODE_6:
  case KEYCODE_7:
  case KEYCODE_8:
  case KEYCODE_9:
    mode = MODE_LENTICULAR;
    modeString = MODE_STR[mode];
    frameType = FRAME_BASE_LENTICULAR + lastKeyCode - KEYCODE_0;
    break;
  case KEYCODE_D: // set mode to 3D
    mode = MODE_3D;
    modeString = MODE_STR[mode];
    frameType = FRAME_TYPE_LEFT;
    break;
  case KEYCODE_V: // set mode to 4V for Leia LumePad 3D Tablet
    mode = MODE_4V;
    modeString = MODE_STR[mode];
    frameType = FRAME_TYPE_LEFT_LEFT;
    break;
  case KEYCODE_P:
    outputFileType = PNG;
    break;
  case KEYCODE_J:
    outputFileType = JPG;
    break;
  case KEYCODE_I:
    selectVideoFile();
    break;
  case KEYCODE_O:
    selectPhotoOutputFolder();
    break;
  case KEYCODE_S:
    if (anaglyph) {
      savedAnaglyphFn = name+"_"+counter+"_L"+leftFrame+"_R"+rightFrame+"_ana"+outputFileType;
      savePhoto(savedAnaglyphFn);
    } else {
      savePhoto(name+"_"+counter+"_"+newFrame+FRAME_TYPE_STR[frameType]+outputFileType);
    }
    break;
  case KEYCODE_L:
    if (mode == MODE_3D) {
      frameType = FRAME_TYPE_LEFT;
      leftFrame = newFrame;
      leftMouseX = lastMouseX;
    } else if (mode == MODE_4V) {
      frameType = FRAME_TYPE_LEFT_LEFT;
    }
    break;
  case KEYCODE_M:
    if (mode == MODE_4V) {
      frameType = FRAME_TYPE_LEFT_MIDDLE;
    }
    break;
  case KEYCODE_N:
    if (mode == MODE_4V) {
      frameType = FRAME_TYPE_RIGHT_MIDDLE;
    }
    break;
  case KEYCODE_R:
    if (mode == MODE_3D) {
      frameType = FRAME_TYPE_RIGHT;
      rightFrame = newFrame;
      rightMouseX = lastMouseX;
    } else if (mode == MODE_4V) {
      frameType = FRAME_TYPE_RIGHT_RIGHT;
    }
    break;
  case KEYCODE_H:
    showHelp = !showHelp;
    break;
  case KEYCODE_PLUS:
    counter++;
    break;
  case KEYCODE_MINUS:
    counter--;
    break;
  case KEYCODE_LEFT_BRACKET:
    CROSSHAIR_SPACING_PERCENT = CROSSHAIR_SPACING_PERCENT-CROSSHAIR_SPACING_INCREMENT;
    break;
  case KEYCODE_RIGHT_BRACKET:
    CROSSHAIR_SPACING_PERCENT = CROSSHAIR_SPACING_PERCENT+CROSSHAIR_SPACING_INCREMENT;
    break;
  case KEYCODE_C:
    changeTextColor();
    break;
    // play input video file
  case KEYCODE_MEDIA_PLAY_PAUSE:
  case KEYCODE_PLAY:
  case KEYCODE_ENTER:
    play();
    break;
  default:
    break;
  }

  lastKey = 0;
  lastKeyCode = 0;
  return true;
}
