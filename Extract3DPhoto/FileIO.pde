///**
// Java or Android platform build
// Important Comment out the platform not used in the build
// */

//// Android Platform Build Mode
//final static boolean ANDROID_MODE = true;
//import android.content.SharedPreferences;
//import android.preference.PreferenceManager;
//import android.content.Context;
//import android.app.Activity;
//import select.files.*;
//boolean grantedRead = false;
//boolean grantedWrite = false;

//SelectLibrary files;

//void openFileSystem() {
//  requestPermissions();
//  files = new SelectLibrary(this);
//}

//public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
//  println("onRequestPermissionsResult "+ requestCode + " " + grantResults + " ");
//  for (int i=0; i<permissions.length; i++) {
//    println(permissions[i]);
//  }
//}  


//void requestPermissions() {
//  if (!hasPermission("android.permission.READ_EXTERNAL_STORAGE")) {
//    requestPermission("android.permission.READ_EXTERNAL_STORAGE", "handleRead");
//  }
//  if (!hasPermission("android.permission.WRITE_EXTERNAL_STORAGE")) {
//    requestPermission("android.permission.WRITE_EXTERNAL_STORAGE", "handleWrite");
//  }
//}

//void handleRead(boolean granted) {
//  if (granted) {
//    grantedRead = granted;
//    println("Granted read permissions.");
//  } else {
//    println("Does not have permission to read external storage.");
//  }
//}

//void handleWrite(boolean granted) {
//  if (granted) {
//    grantedWrite = granted;
//    println("Granted write permissions.");
//  } else {
//    println("Does not have permission to write external storage.");
//  }
//}

//void selectConfigurationFile() {
//  //if (!grantedRead || !grantedWrite) {
//  //  requestPermissions();
//  //}
//  files.selectInput("Select XML Configuration File:", "fileSelected");
//}

//void selectPhotoFolder() {
//  if (saveFolderPath == null) {
//    files.selectFolder("Select Photo Folder", "folderSelected");
//  } else {
//    state = PRE_SAVE_STATE;
//    if (DEBUG) println("saveFolderPath="+saveFolderPath);
//    gui.displayMessage("Save Photos", 30);
//  }
//}

//final String configKey = "ConfigFilename";
//final String photoNumberKey = "photoNumber";
//final String myAppPrefs = "MultiNX";

//void saveConfig(String config) {
//  if (DEBUG) println("saveConfig "+config);
//  SharedPreferences sharedPreferences;
//  SharedPreferences.Editor editor;
//  sharedPreferences = getContext().getSharedPreferences(myAppPrefs, Context.MODE_PRIVATE);
//  editor = sharedPreferences.edit();
//  editor.putString(configKey, config );
//  editor.commit();
//}

//String loadConfig() {
//  SharedPreferences sharedPreferences;
//  sharedPreferences = getContext().getSharedPreferences(myAppPrefs, Context.MODE_PRIVATE);
//  String result = sharedPreferences.getString(configKey, null);
//  if (DEBUG) println("loadConfig "+result);
//  return result;
//}

//void savePhotoNumber(int number) {
//  if (DEBUG) println("savePhotoNumber "+number);
//  SharedPreferences sharedPreferences;
//  SharedPreferences.Editor editor;
//  sharedPreferences = getContext().getSharedPreferences(myAppPrefs, Context.MODE_PRIVATE);
//  editor = sharedPreferences.edit();
//  editor.putInt(photoNumberKey, number );
//  editor.commit();
//}

//int loadPhotoNumber() {
//  SharedPreferences sharedPreferences;
//  sharedPreferences = getContext().getSharedPreferences(myAppPrefs, Context.MODE_PRIVATE);
//  int result = sharedPreferences.getInt(photoNumberKey, 0);
//  if (DEBUG) println("loadPhotoNumber "+result);
//  return result;
//}


//..........................................................................

// Java mode
final static boolean ANDROID_MODE = false;

SelectLibrary files;

void openFileSystem() {
  files = new SelectLibrary(this);
}

void selectVideoFile() {
  //if (DEBUG) println("Select Input Video File state="+stateName[state]);
  selectInput("Select Input Video File:", "fileSelected");
}

void selectPhotoOutputFolder() {
//  if (outputFolderPath == null) {
    selectFolder("Select Photo Folder", "folderSelected");
//  } else {
//    if (DEBUG) println("Save Output Folder: "+ outputFolderPath);
//    displayMessage("Save Output Folder: "+ outputFolderPath, 60);
//  }
}

void saveConfig(String config) {
  
}

String loadConfig()
{
  return null;
}

void fileSelected(File selection) {
  if (selection == null) {
    if (DEBUG) println("Nothing was selected.");
    displayMessage("No File selected, using: "+filename, 60);
  } else {
    if (DEBUG) println("User selected " + selection.getAbsolutePath());
    displayMessage("Video File selected " + selection.getName(), 60);
    //displayMessage("Video File selected " + selection.getAbsolutePath(), 60);
    filenamePath = selection.getAbsolutePath();
    filename = selection.getName();
    if (DEBUG) println("filenamePath="+filenamePath);
    if (DEBUG) println("filename="+filename);
    newVideo = true;
  }
}

void folderSelected(File selection) {
  if (selection == null) {
    if (DEBUG) println("No Output Folder was selected.");
    displayMessage("No Output Folder was selected. Using "+ outputFolderPath + " folder", 60);
  } else {
    if (DEBUG) println("Photo Output Folder selected " + selection.getAbsolutePath());
    outputFolderPath = selection.getAbsolutePath();
    displayMessage("Photo Output Folder selected " + selection.getAbsolutePath(), 60);
  }
}
