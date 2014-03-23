import processing.serial.*;

import procontroll.*;
import java.io.*;

int X = 0;
int Y = 1;
int Z = 2;
int Aaxis = 3;
int Baxis = 4;
int Caxis = 5;
int AxisMax = 1 + Caxis;
  
int MoveMode =6;
int Distance = 7;
int Speed = 8;
int SpindleRev = 9;
int StatusMax = 1 + SpindleRev;

ControllIO controll;
ControllDevice device;
ControllStick stick;
ControllButton button;

CNCMachineControl CNC = new CNCMachineControl();
CNCControlTaskThread TaskThread = new CNCControlTaskThread();
SerialPort CNCPort;

int tmp = 10;

void setup(){
  size(400,400);

  CNC.MachineInitialize("MDX20.ini");
  CNCPortSetup();
  TaskThread.Control = CNC;
  TaskThread.start();
  TaskThread.pause = false;

  controll = ControllIO.getInstance(this);
  try{
  device = controll.getDevice("PLAYSTATION(R)3 Controller");
  //device = controll.getDevice("MotioninJoy Virtual Game Controller");
  device.printSticks();
  device.printSliders();
  device.printButtons();
  device.setTolerance(0.05f);  
  ControllSlider sliderX = device.getSlider("x");
  ControllSlider sliderY = device.getSlider("y");
  //ControllSlider sliderX = device.getSlider(7);
  //ControllSlider sliderY = device.getSlider(6);
  stick = new ControllStick(sliderX,sliderY);
  button = device.getButton(8);
  } catch(RuntimeException e){
    println("Game controller not found.");
  }
  
  fill(0);
  rectMode(CENTER);
}

float totalX = width/2;
float totalY = height/2;

void draw(){
  background(255);

  /*  
  if(button.pressed()){
    fill(255,0,0);
  }else{
    fill(0);
  }
  */
/*
   if(keyPressed) { 
    if (keyCode == UP) { 
      totalY -= tmp; 
    } else if (keyCode == DOWN) { 
      totalY += tmp;
    } else if (keyCode == RIGHT){
      totalX += tmp;
    } else if (keyCode == LEFT){
      totalX -= tmp;
    }    
  }   
  print(totalX);
  print(",");
  println(totalY);

  print(stick.getX());
  print(",");
  println(stick.getY());
  totalX = constrain(totalX + stick.getX(),10,width-10);
  totalY = constrain(totalY + stick.getY(),10,height-10);
  //totalX = constrain(totalX,10,width-10);
  //totalY = constrain(totalY,10,height-10);

  rect(totalX,totalY,20,20);

  //Serial.write("PU");
  //Serial.write(totalX);
  //Serial.write(".");
  //Serial.write(totalY);
  //Serial.write(";");
*/
}

void CNCPortSetup(){
  if(CNC.PortName != null){
    for(int i = 0;i < Serial.list().length;i++){
      if(CNC.PortName.equals(Serial.list()[i])){
        println("Port "+ CNC.PortName +" detect");
       //使用するCOMポートを取得
       CommPortIdentifier comID = null;
       try{
         comID = CommPortIdentifier.getPortIdentifier( CNC.PortName );
       } catch (NoSuchPortException ex) {
           ex.printStackTrace();
       }
       
       CommPort commPort = null;
       if(comID != null){
         //COMポートを開きます
         try{
           commPort = comID.open("CNCContronPanel",2000);
          } catch (PortInUseException ex) {
              ex.printStackTrace();
          }
              
 
          
         //シリアルポートのインスタンスを生成…
         CNCPort = (SerialPort)commPort;        
  
         //ボーレート、データビット数、ストップビット数、パリティを設定
         try{
           CNCPort.setSerialPortParams( 9600,SerialPort.DATABITS_8, SerialPort.STOPBITS_1, SerialPort.PARITY_NONE );
         } catch (UnsupportedCommOperationException ex) {
            ex.printStackTrace();
         }
         //フロー制御
         try{
           CNCPort.setFlowControlMode( SerialPort.FLOWCONTROL_RTSCTS_IN | SerialPort.FLOWCONTROL_RTSCTS_OUT );
         } catch (UnsupportedCommOperationException ex) {
            ex.printStackTrace();
         }
       }        
       println("Port "+ CNC.PortName +" open");

        CNC.PortSetup(CNCPort);

      }
    }
  }
}  
