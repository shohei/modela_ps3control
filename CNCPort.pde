import java.io.*;
import gnu.io.*;

class CNCPort implements CNCMachineConst{
  SerialPort SerialPort = null;
  InputStream PortIn = null;
  OutputStream PortOut = null;
  
  String PortOwner = "CNCControl";
  String InputBuffer;
  String OutputBuffer;
  
  protected boolean PortOpen = false;
  
  int CNCPort(String PortName){
     CommPortIdentifier comID = null;
     try{
       comID = CommPortIdentifier.getPortIdentifier(PortName);
     } catch (NoSuchPortException ex) {
         ex.printStackTrace();
         return PortOpen_notfound;
     }
     
     CommPort commPort = null;
     if(comID != null){
       //COMポートを開きます
       try{
         commPort = comID.open(PortOwner,2000);
        } catch (PortInUseException ex) {
            ex.printStackTrace();
            return PortOpen_fail;
        }
         
       //シリアルポートのインスタンスを生成
       SerialPort = (SerialPort)commPort;        
    
       //ボーレート、データビット数、ストップビット数、パリティを設定
       try{
         SerialPort.setSerialPortParams( 9600,SerialPort.DATABITS_8, SerialPort.STOPBITS_1, SerialPort.PARITY_NONE );
       } catch (UnsupportedCommOperationException ex) {
          ex.printStackTrace();
          return PortOpen_fail;
       }
       //フロー制御
       try{
         CNCPort.setFlowControlMode( SerialPort.FLOWCONTROL_RTSCTS_IN | SerialPort.FLOWCONTROL_RTSCTS_OUT );
       } catch (UnsupportedCommOperationException ex) {
          ex.printStackTrace();
          return PortOpen_fail;
       }
     }
     PortOpen = true;
     return PortOpen_success;     

  }
  
  void  write(String WriteData){
    OutputBuffer += WriteData;
  }

  String read(){
    return InputBuffer;
  }   
  
  void close(){
    if(PortIn != null){
      PortIn = null;
    }
    
    if(PortOut != null){
      PortOut = null;
    }
    
    SerialPort.close();
    SerialPort = null;
  }
  
  void finalize(){
    close();
  } 
}
