class CNCMachineControl extends CNCMachineBasis{
  SerialPort CNCPort;
  Serial PortMonitor;
  CNCMachineSim CNCSim = new CNCMachineSim() ;
  String MachineName;
  String PortName;
  String OutputFileName;
  String RemainingData;
  InputStream CNCPortIn;
  OutputStream CNCPortOut;
  
 
  RmlCommandDecoder Rml = new RmlCommandDecoder();

  BufferedReader ProcessFileReader;
  boolean PortSetup = false;
  boolean PortEnable = true;
  boolean FileOutput = false;
  boolean DataRemaining = false;
  
  int PreSendDataMax = 128;
  float PreSendLineTimeMax = 10.0;
  float LineTime = 0;
  float ProcessDeltaTime = 0;
  float ProcessTaskTime = 0;
  int DecodeResult = 0;
  int WriteChar = 2;
 
  float SimTime = 0;
  int OutputStartTime;
  
  void MachineInitialize(String ProfilefileName){
    super.MachineInitialize(ProfilefileName);
    CNCSim.MachineInitialize(ProfilefileName);
    Rml.Initialize(ProfilefileName);
    PortName = super.PortName;

  }
  
  void PortSetup(SerialPort SerialPort){
    CNCPort = SerialPort;
    try{
      CNCPortIn = CNCPort.getInputStream();
    } catch (IOException ex){}

   try{
      CNCPortOut = CNCPort.getOutputStream();
    } catch (IOException ex){};
    PortSetup = true;
  }
  
  void MoveTo(int MoveMode, float PosX, float PosY, float PosZ){
    super.MoveTo(MoveMode, PosX, PosY, PosZ);
    CNCSim.MoveTo(MoveMode, PosX, PosY, PosZ);

  }

  void MoveTo(int MoveMode, float PosX, float PosY, float PosZ,
               float PosA, float PosB, float PosC){
    super.MoveTo(MoveMode, PosX, PosY, PosZ, PosA, PosB, PosC);
    CNCSim.MoveTo(MoveMode, PosX, PosY, PosZ, PosA, PosB, PosC);
  }
  
  void Speed(float Speed){
    super.Speed(Speed);
    CNCSim.Speed(Speed);
  }

  void DirectCommand(String Command){
    //最も新しい動作データと同一座標で特殊コマンドのみを出力する。
    //座標を取得するのはこの後の移動データの距離・時間計算に影響を及ぼさないため
    int Last = LastIndex();
    MoveTo(MoveMode_DirectCommand, MoveData[Last][X], MoveData[Last][Y], MoveData[Last][Z]);
    // MoveToの出力によってLastIndex()が更新される
//    CommandData[LastIndex()] = Command;
  } 
  
  void OutputFile(String FileName){
    OutputFileName = FileName;
    ProcessFileReader = createReader(OutputFileName);
    FileOutput = true;
    OutputStartTime = millis();
  }
  
  void Process(float DeltaTime){
    ProcessDeltaTime = DeltaTime;
  }
  
  void ProcessTask(){
    int SendData = GetNumOfSendData();
   
    float DeltaTime = ProcessDeltaTime;
    float Time = millis() /1000.0;

    if(SendData > 0){
      float Accel = 1.0 + (0.03 * SendData);
      DeltaTime = DeltaTime * Accel;
     if( Time < (ProcessTaskTime + DeltaTime)){
       DeltaTime = Time - ProcessTaskTime;
     }
     CNCSim.Process(DeltaTime);
 
    }

    ProcessTaskTime = Time;

    for(int i = 0;i < StatusMax; i++){
      CurrentStatus[i]=CNCSim.CurrentStatus[i];
    }
  
    MoveDataIndex[BaseIndex] = CNCSim.MoveDataIndex[BaseIndex];

  }

  void FileOutputTask(){
    for (int i = 0; i < 1024; i++){
      if(GetNumOfMoveData() < (MoveDataMax - 16)){
        int ReadChar = -1;
        try{
          ReadChar = ProcessFileReader.read();
        } catch (IOException e) {
          FileOutput = false;
          ReadChar = -1;
        }
    
        if(ReadChar != -1){
          DecodeResult = Rml.Parse((char)ReadChar);
        }
        
        if(DecodeResult == CommandParsed){
          if(Rml.ParsedCommand == Command_MoveTo){
            MoveTo(MoveMode_Absolute, Rml.Status[X], Rml.Status[Y], Rml.Status[Z]);
            CommandData[LastIndex()] = Rml.CommandBlock;
            MoveDataSendFlag[LastIndex()] = 0;
          }
          else if (Rml.ParsedCommand == Command_Speed){
            Speed( Rml.Status[Speed]);
            DirectCommand(Rml.CommandBlock);
            CommandData[LastIndex()] = Rml.CommandBlock;
            MoveDataSendFlag[LastIndex()] = 0;
          }
          else if (Rml.ParsedCommand == Command_MoveAbsolute){
            DirectCommand(Rml.CommandBlock);
            CommandData[LastIndex()] = Rml.CommandBlock;
            MoveDataSendFlag[LastIndex()] = 0;
          }
          else if (Rml.ParsedCommand == Command_MoveRelative){
            DirectCommand(Rml.CommandBlock);
            CommandData[LastIndex()] = Rml.CommandBlock;
            MoveDataSendFlag[LastIndex()] = 0;
          }
          else if (Rml.ParsedCommand == Command_SpindleOnOff){
            DirectCommand(Rml.CommandBlock);
            CommandData[LastIndex()] = Rml.CommandBlock;
            MoveDataSendFlag[LastIndex()] = 0;
          }
          
        }else if(DecodeResult == UnknownCommand){
          DirectCommand(Rml.CommandBlock);
          MoveDataSendFlag[LastIndex()] = 0;
        }
        
      }
    }
  }

  void MoveDataSendTask(){
    PortMonitorCheck();
    if((PortSetup == true) && (PortEnable == true)){
      FlushRemainingData();

      int Num = GetNumOfMoveData();
      if(Num > PreSendDataMax){
        Num = PreSendDataMax;
      }
 
      int i = 0;

      while((i < Num) && (DataRemaining == false)){
        int j = GetIndexOfBase(i);
          
          if(MoveDataSendFlag[j] == 0 && CommandData[j] != null){
            int Len = CommandData[j].length();
            int k = 0;
            int l = 0;
            while((k < Len) && DataRemaining == false){
               PortMonitorCheck();
               if(PortEnable == true){
                 l = k + WriteChar;
                 if(l > Len){
                   l = Len; 
                 }
                 try{
                   CNCPortOut.write((CommandData[j].substring(k, l)).getBytes());
                 }catch (IOException ex){
                 }
                 k = l;
               }
               else{
                 DataRemaining = true;
                 RemainingData = CommandData[j].substring(k);
               }
                 
            }

             MoveDataSendFlag[j] = 1; 
          }
          
         i++;
       }
    }
  }

  void PortStatusRequest(){
    if(PortSetup == true){
//      PortMonitor.write('@');
    }
  }
  
  void PortMonitorCheck(){
    if(PortSetup == true){
        if(CNCPort.isDSR() && CNCPort.isCTS()){
          PortEnable = true;
        }
        else{
          PortEnable = false;
        }
    }
   
  }

  void FlushRemainingData(){
    if(DataRemaining == true){ 
      int l = 0;
      PortMonitorCheck();
      while(l < RemainingData.length() && (PortEnable == true)){
         if(PortEnable == true){
           try{
             CNCPortOut.write(RemainingData.charAt(l));
           }catch(IOException ex){
           }
           l++;
         }
         PortMonitorCheck();
      }
      if(l == RemainingData.length()){
        RemainingData = "";
        DataRemaining = false;
      }
      else{
        RemainingData = RemainingData.substring(l);
      }
    }    
  }
  
}

public class CNCControlTaskThread extends Thread{
  CNCMachineControl Control;
  boolean pause = true;

  public void run(){
    int wait = 0;
    while(true){
      if(pause ==false){
      
        wait++;
        if((Control.FileOutput == true) && (wait > 5)){
          Control.FileOutputTask();
          wait = 0;
        }
        
        Control.MoveDataSendTask();
    
        Control.ProcessTask();

      }
        
      try {
        sleep(7);
      } catch (InterruptedException e) {
      }
        
    }
  }
}
