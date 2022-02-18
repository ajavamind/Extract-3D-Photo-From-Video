// Create Anaglyph screen
String savedLeftFn = "";
String savedRightFn = "";
String savedAnaglyphFn = "";

PImage makeAnaglyph(boolean anaglyph) {
  PImage img = null;
  if (anaglyph) {
    if (mode == MODE_3D) {
      if (leftToRight) {
        img = createAnaglyph(savedLeftFn, savedRightFn);
      } else {
        img = createAnaglyph(savedRightFn, savedLeftFn);
      }
      if (img == null) {
        anaglyph = false;
      }
    }
  }
  return img;
}

PImage createAnaglyph(String leftFn, String rightFn) {
  PImage img;
  PImage left;
  PImage right;

  left = loadImage(outputFolderPath + File.separator+ leftFn);
  right = loadImage(outputFolderPath + File.separator+ rightFn);
  if (left == null || right == null) {
    return null;
  }
  parallax = leftMouseX - rightMouseX;
  img = colorAnaglyph(left, right, parallax);
  //img = colorAnaglyph(left, right);

  return img;
}


private PImage colorAnaglyph(PImage bufL, PImage bufR) {
  // color anaglyph merge left and right images
  // reuse left image for faster performance
  bufL.loadPixels();
  bufR.loadPixels();
  int cr = 0;
  int len = bufL.pixels.length;
  int i = 0;
  while (i < len) {
    cr = bufR.pixels[i];
    bufL.pixels[i] = color(red(bufL.pixels[i]), green(cr), blue(cr));
    i++;
  }
  bufL.updatePixels();
  return bufL;
}

private PImage colorAnaglyph(PImage bufL, PImage bufR, int offset) {
  // color anaglyph merge left and right images
  // reuse left image for faster performance
  if (DEBUG) println("createAnaglyph "+savedLeftFn +"   "+savedRightFn);
  if (DEBUG) println("parallax="+parallax);

  bufL.loadPixels();
  bufR.loadPixels();
  int cr = 0;
  int w = bufL.width;
  int h = bufL.height;
  int i = 0;
  int j = w - offset;
  int k = w;
  int len = bufL.pixels.length;
  while (i < len) {
    if (j > 0) {
      cr = bufR.pixels[i ];
      if ((i + offset) < 0  || (i+offset) >= len) {
        println("anaglyph creation out of range, need crosshairs for both left and right "+ (i+offset));
      } else {
        bufR.pixels[i] = color(red(bufL.pixels[i+offset]), green(cr), blue(cr));
      }
      j--;
    } else {
      bufR.pixels[i] = 0;
    }
    k--;
    if (k <= 0) {
      k = w;
      j = w - offset;
    }
    i++;
  }
  bufR.updatePixels();
  return bufR;
}
