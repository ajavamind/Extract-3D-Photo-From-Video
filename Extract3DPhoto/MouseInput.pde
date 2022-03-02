int lastMouseX = 0;
int lastMouseY = 0;

int leftMouseX = 0;
int rightMouseX = 0;

float saveMouseX = 0;
float saveMouseY = 0;

int clickNumber = 1;
boolean firstClick = false; // used to give window focus for key press input

void mousePressed() {
  if (firstClick) {
    lastKey = 0;
    lastMouseX = mouseX;
    lastMouseY = mouseY;
  }
}

void mouseReleased() {
  firstClick = true;
}
