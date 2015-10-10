import controlP5.*;
import processing.pdf.*;


color colorHL = color(255, 204, 153);
IntList airData = new IntList();
int newX = 0, newY = 0, spacer = 0;
int norm = 280, timePeriod = 48;
int rectWidth = 5, colHeight = 240;
boolean isDrawn = false, isLoaded = false;
color rectColor;
String fPath = "";
String fName = "";
PGraphics preview;
ControlP5 cp5;
Textlabel txtLab;
Textfield normFld, timeFld;



public void setup(){
    size(800, 450, P2D);
    noStroke();
    colorMode(HSB, 360, 100, 100);
    preview = createGraphics(displayWidth, 300);
    
    cp5 = new ControlP5(this);
  
    // create a new button with name 'buttonA'
    cp5.addButton("loadFile")
       //.setValue(0)
       .setPosition(100,100)
       .setSize(200,19)
       ;
       
    txtLab = cp5.addTextlabel("label")
                    .setText("No data loaded")
                    .setPosition(310,107)
                    .setColorValue(0xffffff00)
                    ;
    
    cp5.addButton("generate")
       //.setValue(0)
       .setPosition(100,130)
       .setSize(200,19)
       ;
       
    timeFld = cp5.addTextfield("timePeriod")
       .setText("48")
       .setPosition(220,220)
       .setSize(100,20)
       .setAutoClear(true)
       ;
       
    normFld = cp5.addTextfield("norm")
       .setText("280")
       .setPosition(100,220)
       .setSize(100,20)
       .setAutoClear(true)
       ;
}

public void draw(){
  background(0);
  //norm = int(cp5.get(Textfield.class,"norm").getText());
  norm = int(normFld.getText());
  timePeriod = int(timeFld.getText());
  
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
    fPath = selection.getAbsolutePath();
    println("User selected" + fPath);
    if (loadData(fPath)) {
      fName = selection.getName();
      txtLab.setText("Data loaded: " + fName);
    }
  }
}


boolean loadData(String fPath){
  airData.clear();
  String airFile[] = loadStrings(fPath);
    for(String fileRow: airFile){
      String[][] m = matchAll(fileRow, "(\\d+)");
      for(String[] rowDigits: m){
        for(int i=1; i<rowDigits.length; i++){
          airData.append(int(rowDigits[i]));
        }
      }
    }
    print(airData);
    return true;
}


public void drawData2(PGraphics output, IntList airData)
{
  
  int i = 0;
  output.noStroke();
  output.colorMode(HSB, 360, 100, 100);
  int rectHeight = int(colHeight / timePeriod);
  output.fill(0);
  output.rect(0, 0, rectWidth, rectHeight);
  for(int probe: airData){
    newY = i%timePeriod * (rectHeight + spacer);
    i++;
    if(i%timePeriod == 0){
      newX += rectWidth + spacer;
      newY = 0;
    }
    //print(newY + ", " + newX + "; ");
    
    
    if (probe < 1){
      rectColor = color(360, 0, 100);
    } else if (probe > 1 && probe < norm){
      rectColor = color(200, 50, map(probe, 1, norm, 100, 0));
    } else if (probe > norm){
      rectColor = color(360, 100, map(probe, 1, norm*3, 0, 100));
    }
    output.fill(rectColor);
    output.rect(newX, newY, rectWidth, rectHeight);
  }
}

public void loadFile(int theValue) {
   selectInput("Select a file to process:", "fileSelected");
}

public void generate(int theValue) {
   if (airData.size() > 0) {
     newX = 0;
     newY = 0;
     spacer = 0;
     savePdf(airData);
     println("\ndone: " + fName);
   }
}

public void savePdf(IntList airData){
  int pdfWidth = ceil(airData.size()/timePeriod+1) * (rectWidth + spacer);
  int pdfHeight = timePeriod * (colHeight / timePeriod + spacer)+20;
  PGraphics pdf = createGraphics(pdfWidth, pdfHeight, PDF, split(fName, '.')[0] + ".pdf");
  pdf.beginDraw();
  drawData2(pdf, airData);
  pdf.dispose();
  pdf.endDraw();
}