import processing.pdf.*;
import controlP5.*;



color colorHL = color(255, 204, 153);
IntList airData = new IntList();


public void setup(){
    size(displayWidth, 300, P3D);
    background(190);
    smooth();
    stroke(200);
}

public void draw(){
  
}

public void keyReleased() {
  switch(key){            
    case'L':
    case'l':
      selectInput("Select a file to process:", "fileSelected");
    break;
  }
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    String fPath = selection.getAbsolutePath();
    println("User selected" + fPath);
    String airFile[] = loadStrings(fPath);
    for(String fileRow: airFile){
      String[][] m = matchAll(fileRow, "(\\d+)");
      for(String[] rowDigits: m){
        for(String probe: rowDigits){
          //println(probe);
          airData.append(int(probe));
        }
      }
    }
    print(airData);
  }
}