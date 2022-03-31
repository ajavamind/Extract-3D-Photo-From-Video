// Keyboard input handling
// These codes (ASCII) are for Java applications
// Android codes (not implemented) differ with some keys

static final int KEYCODE_BACKSPACE = 8;
static final int KEYCODE_TAB = 9;
static final int KEYCODE_ENTER = 10;
static final int KEYCODE_ESCAPE = 27;
static final int KEYCODE_SPACE = 32;
static final int KEYCODE_COMMA = 44;
static final int KEYCODE_MINUS = 45;
static final int KEYCODE_PERIOD = 46;
static final int KEYCODE_SLASH = 47;
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
static final int KEYCODE_SEMICOLON = 59;
static final int KEYCODE_PLUS = 61;
static final int KEYCODE_EQUAL = 61;
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
static final int KEYCODE_BACK_SLASH = 92;
static final int KEYCODE_RIGHT_BRACKET = 93;
static final int KEYCODE_DEL = 127;
//static final int KEYCODE_MEDIA_NEXT = 87;
//static final int KEYCODE_MEDIA_PLAY_PAUSE = 85;
//static final int KEYCODE_MEDIA_PREVIOUS = 88;
static final int KEYCODE_PAGE_DOWN = 93;
static final int KEYCODE_PAGE_UP = 92;
static final int KEYCODE_PLAY = 126;
static final int KEYCODE_MEDIA_STOP = 86;
static final int KEYCODE_MEDIA_REWIND = 89;
static final int KEYCODE_MEDIA_RECORD = 130;
static final int KEYCODE_MEDIA_PAUSE = 127;
static final int KEYCODE_MOVE_HOME = 122;
static final int KEYCODE_MOVE_END  = 123;

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
  //if (DEBUG) println("keyUpdate lastKey="+lastKey + " lastKeyCode="+lastKeyCode);
  if (lastKey == 0 && lastKeyCode == 0) {
    return false;
  }

  boolean common = true;
  switch(lastKeyCode) {
  case KEYCODE_Q:
  case KEYCODE_ESCAPE:
    exit();
    break;
  case KEYCODE_G:
    // toggle crosshair display
    showCrosshair = !showCrosshair;
    break;
  case KEYCODE_H:
    showHelp++;
    if (showHelp > NO_HELP) {
      showHelp = INFO;
    }
    break;
  case KEYCODE_SLASH: // debug output including stereo window parallax offset
    parallax = saveMouseX - rightMouseX;
    if (DEBUG) println("anaglyph=" + anaglyph +" parallax="+parallax);
    if (DEBUG) println("lastMouseX="+lastMouseX+" lastMouseY="+lastMouseY);
    if (DEBUG) println("leftMouseX="+leftMouseX + " rightMouseX="+rightMouseX);
    if (DEBUG) println("saveMouseX="+saveMouseX + " saveMouseY="+saveMouseY);
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
  default:
    common = false;
    break;
  }
  if (common) {
    lastKey = 0;
    lastKeyCode = 0;
    return true;
  }

  if (lastKeyCode == KEYCODE_A && mode == MODE_3D) {
    anaglyph = !anaglyph;
    if (anaglyph) {
      screen = makeAnaglyph(true);
      if (screen != null) {
        if (leftToRight) {
          savePhoto(name+"_"+convert(counter)+"_"+convert(leftFrame)+"L"+convert(rightFrame)+"R"+"_ana"+outputFileType, "", false, false);
        } else {
          savePhoto(name+"_"+convert(counter)+"_"+convert(rightFrame)+"L"+convert(leftFrame)+"R"+"_ana"+outputFileType, "", false, false);
        }
      }
    } else {
      screen = null;
    }
    lastKey = 0;
    lastKeyCode = 0;
    return true;
  } else if (anaglyph) {
    if (lastKeyCode == KEYCODE_X) {
      leftToRight = ! leftToRight;
      //} else if (lastKeyCode == LEFT) {
      //  offsetX--;
      //} else if (lastKeyCode == RIGHT) {
      //  offsetX++;
      //} else if (lastKeyCode == UP) {
      //  offsetY--;
      //} else if (lastKeyCode == DOWN) {
      //  offsetY++;
    } else {
      lastKey = 0;
      lastKeyCode = 0;
      return true;
    }
    screen = makeAnaglyph(true);
    if (leftToRight) {
      savePhoto(name+"_"+convert(counter)+"_"+convert(leftFrame)+"L"+convert(rightFrame)+"R"+"_ana"+outputFileType, "", false, false);
    } else {
      savePhoto(name+"_"+convert(counter)+"_"+convert(rightFrame)+"L"+convert(leftFrame)+"R"+"_ana"+outputFileType, "", false, false);
    }
    lastKey = 0;
    lastKeyCode = 0;
    return true;
  }

  switch (lastKeyCode) {
  case KEYCODE_BACKSPACE:
    if (currentFrame > 0 ) {
      currentFrame--;
      offsetX = 0;
      offsetY = 0;
      setFrame(movie, currentFrame);
      frameType = FRAME_TYPE_MISSING;
    }
    break;
  case KEYCODE_SPACE:
    if (currentFrame < getLength(movie) - 1) {
      currentFrame++;
      offsetX = 0;
      offsetY = 0;
      setFrame(movie, currentFrame);
      frameType = FRAME_TYPE_MISSING;
    }
    break;
  case KEYCODE_TAB:
    currentFrame = getFrame(movie) + 10;
    if (currentFrame > getLength(movie)) {
      currentFrame = getLength(movie) -1;
    }
    offsetX = 0;
    offsetY = 0;
    setFrame(movie, currentFrame);
    frameType = FRAME_TYPE_MISSING;
    break;
  case KEYCODE_Z:
    currentFrame = 0;
    offsetX = 0;
    offsetY = 0;
    setFrame(movie, currentFrame);
    frameType = FRAME_TYPE_MISSING;
    lastMouseX = 0;
    lastMouseY = 0;
    break;
  case LEFT:
    offsetX--;
    updated = true;
    break;
  case RIGHT:
    offsetX++;
    updated = true;
    break;
  case UP:
    offsetY--;
    updated = true;
    break;
  case DOWN:
    offsetY++;
    updated = true;
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
    if (mode == MODE_LENTICULAR) {
      if (lastKeyCode == KEYCODE_0) {
        saveMouseX = lastMouseX;
        saveMouseY = lastMouseY;
        saveFrameType = FRAME_TYPE_BASE_LENTICULAR + lastKeyCode - KEYCODE_0;
      }
      modeString = MODE_STR[mode];
      frameType = FRAME_TYPE_BASE_LENTICULAR + lastKeyCode - KEYCODE_0;
      offsetX += saveMouseX - lastMouseX;
      offsetY += saveMouseY - lastMouseY;
      updated = true;
      //savePhoto(name+"_"+counter+"_"+getFrame(movie)+FRAME_TYPE_STR[frameType]+outputFileType, "", true, false);
    } else {
      displayMessage("Not Lenticular Mode.", 30);
    }
    break;
  case KEYCODE_D: // set mode to 3D
    mode = MODE_3D;
    modeString = MODE_STR[mode];
    resetSavedFn();
    break;
  case KEYCODE_U: // set mode to 4V for Leia LumePad 3D Tablet
    mode = MODE_4V;
    modeString = MODE_STR[mode];
    resetSavedFn();
    break;
  case KEYCODE_V: // save 3D SBS video 
    if (mode == MODE_3D && lrFrameDiff > 0) {
      saveVideo = SETUP_VIDEO;
    } else {
      displayMessage("Cannot save 3D video, not in 3D mode.", 60);
    }
    break;
  case KEYCODE_E: // save 3D L/R frames as separate files 
    if (mode == MODE_3D) {
      saveLRphoto = SETUP_READ;
    } else {
      displayMessage("Cannot save 3D photos, not in 3D mode.", 60);
    }
    break;
  case KEYCODE_Y: // set mode to Single and save
    mode = MODE_SINGLE;
    modeString = MODE_STR[mode];
    frameType = FRAME_TYPE_SINGLE;
    resetSavedFn();
    updated = true;
    break;
  case KEYCODE_T: // set mode to Lenticular
    mode = MODE_LENTICULAR;
    modeString = MODE_STR[mode];
    resetSavedFn();
    break;
  case KEYCODE_P:
    outputFileType = PNG;
    break;
  case KEYCODE_J:
    outputFileType = JPEG;
    break;
  case KEYCODE_B:
    outputFileType = BMP;
    break;
  case KEYCODE_F:
    outputFileType = TIFF;
    break;
  case KEYCODE_I:
    selectVideoFile();
    break;
  case KEYCODE_O:
    selectPhotoOutputFolder();
    break;
  case KEYCODE_K:
    savePhoto(name+"_"+convert(counter)+"_"+convert(getFrame(movie))+FRAME_TYPE_STR[frameType]+outputFileType, "F", false, true);
    break;
  case KEYCODE_S:
    //launch(sketchPath("")+"makeSBS.bat");
    if (mode == MODE_3D) {
      if (DEBUG) println("Launch Windows Batch File   "+sketchPath("data") + File.separator + "makeSBS.bat");
      launch(sketchPath("data") + File.separator + "makeSBS.bat "+ saved3DFn[0] + " " + saved3DFn[1] + " "+ 
        configuration[OUTPUT_FOLDER]+File.separator +name + "_"+counter+"_"+leftFrame+"L"+rightFrame+"R");
      displayMessage("Save SBS 3D Photo", 30);
    } else if (mode == MODE_4V) {
      if (DEBUG) println("Launch Windows Batch File   "+sketchPath("data") + File.separator +"make4v.bat");
      launch(sketchPath("data") + File.separator + "make4v.bat "+ saved4VFn[0] + " " + saved4VFn[1] + " "+ 
        saved4VFn[2] + " " + saved4VFn[3] + " " + 
        configuration[OUTPUT_FOLDER]+File.separator +name+"_"+counter+"_"+leftFrame+"LL"+leftMiddleFrame+"LM"+rightMiddleFrame+"RM"+rightFrame+"RR");
      displayMessage("Save 4V 3D Photo", 30);
    } else if (mode == MODE_LENTICULAR) { // Note: incomplete work in progress
      if (DEBUG) println("Launch Windows Batch File   "+sketchPath("data") + File.separator +"makeLGP.bat");
      launch(sketchPath("data") + File.separator + "makeLGP.bat "+ configuration[OUTPUT_FOLDER] + File.separator + name + "_" + counter + " " + 
        savedLentFn[4] + " " + savedLentFn[5] + " " + savedLentFn[6] + " " + savedLentFn[7] + " " +
        savedLentFn[0] + " " + savedLentFn[1] + " " + savedLentFn[2] + " " + savedLentFn[3] );
      displayMessage("Save Quilt 3D Photo", 30);
    }
    break;
  case KEYCODE_L:
    if (mode == MODE_3D) {
      frameType = FRAME_TYPE_LEFT;
      leftFrame = getFrame(movie);
      leftMouseX = lastMouseX;
    } else if (mode == MODE_4V) {
      frameType = FRAME_TYPE_LEFT_LEFT;
      leftFrame = getFrame(movie);
    } else {
      break;
    }
    saveMouseX = lastMouseX;
    saveMouseY = lastMouseY;
    saveFrameType = frameType;
    updated = true;
    //savePhoto(name+"_"+counter+"_"+getFrame(movie)+FRAME_TYPE_STR[frameType]+outputFileType, "", true, false);
    break;
  case KEYCODE_M:
    if (mode == MODE_4V) {
      frameType = FRAME_TYPE_LEFT_MIDDLE;
      offsetX += saveMouseX - lastMouseX;
      offsetY += saveMouseY - lastMouseY;
      updated = true;
      leftMiddleFrame = getFrame(movie);
      //savePhoto(name+"_"+counter+"_"+getFrame(movie)+FRAME_TYPE_STR[frameType]+outputFileType, "", true, false);
    }
    break;
  case KEYCODE_N:
    if (mode == MODE_4V) {
      frameType = FRAME_TYPE_RIGHT_MIDDLE;
      offsetX += saveMouseX - lastMouseX;
      offsetY += saveMouseY - lastMouseY;
      rightMiddleFrame = getFrame(movie);
      updated = true;
      //savePhoto(name+"_"+counter+"_"+getFrame(movie)+FRAME_TYPE_STR[frameType]+outputFileType, "", true, false);
    }
    break;
  case KEYCODE_R:
    if (mode == MODE_3D) {
      frameType = FRAME_TYPE_RIGHT;
      rightFrame = getFrame(movie);
      rightMouseX = lastMouseX;
      lrFrameDiff = rightFrame - leftFrame + 1;
    } else if (mode == MODE_4V) {
      frameType = FRAME_TYPE_RIGHT_RIGHT;
      rightFrame = getFrame(movie);
    } else {
      break;
    }
    if (saveMouseX == 0 || saveMouseY == 0) {
      displayMessage("Left Frame NOT Selected!", 30);
      break;
    } else {
      offsetX = saveMouseX - lastMouseX;
      offsetY = saveMouseY - lastMouseY;
      updated = true;
    }
    //savePhoto(name+"_"+counter+"_"+getFrame(movie)+FRAME_TYPE_STR[frameType]+outputFileType, "", true, false);
    break;
  case KEYCODE_PLUS:
    counter++;
    resetSavedFn();
    break;
  case KEYCODE_MINUS:
    if (counter > 1) {
      counter--;
      resetSavedFn();
    }
    break;
  case KEYCODE_PLAY:
  case KEYCODE_ENTER: // play input video file
    play();
    break;
  default:
    break;
  }

  lastKey = 0;
  lastKeyCode = 0;
  return true;
}
