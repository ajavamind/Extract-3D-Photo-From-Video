// Mouse input handling

int lastMouseX = 0;
int lastMouseY = 0;

int leftMouseX = 0;
int rightMouseX = 0;

int saveMouseX = 0;
int saveMouseY = 0;
int saveFrameType = 0;

int clickNumber = 1;
boolean firstClick = false; // used to give window focus for key press input

void mousePressed() {
  if (firstClick) {
    lastKey = 0;
    lastMouseX = mouseX;
    lastMouseY = mouseY;
    frameType = FRAME_TYPE_MISSING;
  }
}

void mouseReleased() {
  firstClick = true;
}
