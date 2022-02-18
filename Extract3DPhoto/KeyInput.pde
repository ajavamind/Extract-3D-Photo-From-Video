// Keyboard and mouse input handling

int KEYCODE_BACKSPACE = 8;
int KEYCODE_ENTER = 10;
int KEYCODE_ESCAPE = 27;
int KEYCODE_SPACE = 32;
int KEYCODE_0 = 48;
int KEYCODE_1 = 49;
int KEYCODE_2 = 50;
int KEYCODE_3 = 51;
int KEYCODE_4 = 52;
int KEYCODE_5 = 53;
int KEYCODE_6 = 54;
int KEYCODE_7 = 55;
int KEYCODE_8 = 56;
int KEYCODE_9 = 57;
int KEYCODE_MINUS = 45;
int KEYCODE_PLUS = 61;
int KEYCODE_A = 65;
int KEYCODE_B = 66;
int KEYCODE_C = 67;
int KEYCODE_D = 68;
int KEYCODE_E = 69;
int KEYCODE_F = 70;
int KEYCODE_G = 71;
int KEYCODE_H = 72;
int KEYCODE_I = 73;
int KEYCODE_J = 74;
int KEYCODE_K = 75;
int KEYCODE_L = 76;
int KEYCODE_M = 77;
int KEYCODE_N = 78;
int KEYCODE_O = 79;
int KEYCODE_P = 80;
int KEYCODE_Q = 81;
int KEYCODE_R = 82;
int KEYCODE_S = 83;
int KEYCODE_T = 84;
int KEYCODE_U = 85;
int KEYCODE_V = 86;
int KEYCODE_W = 87;
int KEYCODE_X = 88;
int KEYCODE_Y = 89;
int KEYCODE_Z = 90;
int KEYCODE_LEFT_BRACKET = 91;
int KEYCODE_RIGHT_BRACKET = 93;
int KEYCODE_DEL = 127;
int KEYCODE_MEDIA_NEXT;
int KEYCODE_MEDIA_PLAY_PAUSE = 80;
int KEYCODE_MEDIA_PREVIOUS;
int KEYCODE_PAGE_DOWN;
int KEYCODE_PAGE_UP;
int KEYCODE_MEDIA_STOP;
int KEYCODE_MOVE_HOME       = 122;
int KEYCODE_MOVE_END       = 123;

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

// Process key from main loop not in keyPressed()
// returns false no key processed
// returns true when a key is processed
boolean keyUpdate() {
  if (lastKey == 0 && lastKeyCode == 0) {
    return false;
  }
  //if (DEBUG) println("keyUpdate lastKey="+lastKey + " lastKeyCode="+lastKeyCode);

  if (lastKeyCode == KEYCODE_A) {
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

  if (lastKeyCode == KEYCODE_BACKSPACE) {
    if (0 < newFrame) {
      newFrame--;
      offsetX = 0;
      offsetY = 0;
      setFrame(newFrame);
    }
  } else if (lastKeyCode == KEYCODE_SPACE) {
    if (newFrame < getLength() - 1) {
      newFrame++;
      offsetX = 0;
      offsetY = 0;
      setFrame(newFrame);
    }
  } else if (lastKeyCode == LEFT) {
    offsetX--;
  } else if (lastKeyCode == RIGHT) {
    offsetX++;
  } else if (lastKeyCode == UP) {
    offsetY--;
  } else if (lastKeyCode == DOWN) {
    offsetY++;
  } else if (lastKeyCode == KEYCODE_W) {  // debug stereo window parallax offset
    parallax = leftMouseX - rightMouseX;
    if (DEBUG) println("lastMouseX="+lastMouseX);
    if (DEBUG) println("leftMouseX="+leftMouseX);
    if (DEBUG) println("rightMouseX="+rightMouseX);
    if (DEBUG) println("parallax="+parallax);
  } else if (lastKeyCode == KEYCODE_3) {
    mode = 3;
    modeString = MODESTR_3D;
  } else if (lastKeyCode == KEYCODE_4) {
    mode = 4;
    modeString = MODESTR_4V;
  } else if (lastKeyCode == KEYCODE_P) {
    outputFileType = PNG;
  } else if (lastKeyCode == KEYCODE_J) {
    outputFileType = JPG;
  } else if (lastKeyCode == KEYCODE_I) {
    selectVideoFile();
  } else if (lastKeyCode == KEYCODE_O) {
    selectPhotoOutputFolder();
  } else if (lastKeyCode == KEYCODE_S) {
    if (anaglyph) {
      savedAnaglyphFn = name+"_"+counter+"_L"+leftFrame+"_R"+rightFrame+"_ana"+outputFileType;
      savePhoto(savedAnaglyphFn);
    } else {
      savePhoto(name+"_"+counter+"_"+newFrame+outputFileType);
    }
  } else if (lastKeyCode == KEYCODE_L) {
    if (mode == MODE_3D) {
      leftFrame = newFrame;
      leftMouseX = lastMouseX;
      savedLeftFn = name+"_"+counter+"_"+leftFrame+"_L"+outputFileType;
      savePhoto(savedLeftFn);
    } else {
      savePhoto(name+"_"+counter+"_"+newFrame+"_LL"+outputFileType);
    }
  } else if (lastKeyCode == KEYCODE_M) {
    savePhoto(name+"_"+counter+"_"+newFrame+"_LM"+outputFileType);
  } else if (lastKeyCode == KEYCODE_N) {
    savePhoto(name+"_"+counter+"_"+newFrame+"_RM"+outputFileType);
  } else if (lastKeyCode == KEYCODE_R) {
    if (mode == MODE_3D) {
      rightFrame = newFrame;
      rightMouseX = lastMouseX;
      savedRightFn = name+"_"+counter+"_"+rightFrame+"_R"+outputFileType;
      savePhoto(savedRightFn);
    } else {
      savePhoto(name+"_"+counter+"_"+newFrame+"_RR"+outputFileType);
    }
  } else if (lastKeyCode == KEYCODE_H) {
    showHelp = !showHelp;
  } else if (lastKeyCode == KEYCODE_PLUS) {
    counter++;
  } else if (lastKeyCode == KEYCODE_MINUS) {
    counter--;
  } else if (lastKeyCode == KEYCODE_LEFT_BRACKET) {
    CROSSHAIR_SPACING_PERCENT = CROSSHAIR_SPACING_PERCENT-CROSSHAIR_SPACING_INCREMENT;
  } else if (lastKeyCode == KEYCODE_RIGHT_BRACKET) {
    CROSSHAIR_SPACING_PERCENT = CROSSHAIR_SPACING_PERCENT+CROSSHAIR_SPACING_INCREMENT;
  } else if (lastKeyCode == KEYCODE_C) {
    changeTextColor();
  } else if (lastKeyCode == KEYCODE_MEDIA_PLAY_PAUSE || lastKeyCode == KEYCODE_ENTER ) {
    play();
  }

  lastKey = 0;
  lastKeyCode = 0;
  return true;
}
