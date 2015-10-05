import controlP5.*;
import processing.pdf.*;


color colorHL = color(255, 204, 153);
IntList airData = new IntList();
int newX = 0, newY = 0, spacer = 0;
int norm = 280, timePeriod = 48;
int rectWidth = 5, rectHeight = 5;
boolean isDrawn = false, isLoaded = false;
color rectColor;
String fPath = "";
String fName = "";
PGraphics preview;
ControlP5 cp5;
Textlabel txtLab;
Textfield txtFld;



public void setup(){
    size(800, 450, P3D);
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
       
       
    cp5.addSlider("timePeriod")
       .setPosition(100,180)
       .setSize(200,20)
       .setRange(1,48)
       .setNumberOfTickMarks(48)
       ;
       
    txtFld = cp5.addTextfield("norm")
     .setText("280")
     .setPosition(100,220)
     .setSize(100,20)
     .setAutoClear(false)
     ;
}

public void draw(){
  background(0);
  //norm = int(cp5.get(Textfield.class,"norm").getText());
  norm = int(txtFld.getText());
  
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
      txtLab.setText("Data loaded: ");
    }
  }
}


boolean loadData(String fPath){
  String airFile[] = loadStrings(fPath);
    for(String fileRow: airFile){
      String[][] m = matchAll(fileRow, "(\\d+)");
      for(String[] rowDigits: m){
        for(String probe: rowDigits){
          airData.append(int(probe));
        }
      }
    }
    print(airData);
    return true;
}

public void drawData(PGraphics output, IntList airData)
{
  
  int i = 0;
  output.noStroke();
  output.colorMode(HSB, 360, 100, 100);
  for(int probe: airData){
    i++;
    newY = i%timePeriod * (rectHeight + spacer);
    if(i%timePeriod == 0){
      newX = newX + rectWidth + spacer;
    }
    //println(newX + " " + newY + " " + rectWidth + " " + rectHeight);
    
      if (probe < 1){
      rectColor = color(0,0,100);
      output.fill(rectColor);
      output.rect(newX, newY, rectWidth, rectHeight);
    } else if (probe > 1 && probe < norm){
      rectColor = color(200,50,map(probe, 1, norm, 100, 0));
      output.fill(rectColor);
      output.rect(newX, newY, rectWidth, rectHeight);
    } else if (probe > norm){
      rectColor = color(360,100,map(probe, norm, 3*norm, 0, 100));
      output.fill(rectColor);
      output.rect(newX, newY, rectWidth, rectHeight);
    }
  }
}

public void loadFile(int theValue) {
   selectInput("Select a file to process:", "fileSelected");
}

public void generate(int theValue) {
   if (airData.size() > 0) {
     savePdf(airData);
   }
}

public void savePdf(IntList airData){
  int pdfWidth = int(airData.size()/timePeriod * (rectWidth + spacer));
  int pdfHeight = timePeriod * (rectHeight + spacer);
  PGraphics pdf = createGraphics(pdfWidth, pdfHeight, PDF, split(fName, '.')[0] + ".pdf");
  pdf.beginDraw();
  drawData(pdf, airData);
  pdf.dispose();
  pdf.endDraw();
}