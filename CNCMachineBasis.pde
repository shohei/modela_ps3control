class CNCMachineBasis implements CNCMachineConst{
  
  String MachineName;
  String PortName;
  
  float SetSpeed = 0.5;

  int MoveDataMax = 1024;
  float[][] MoveData= new float[MoveDataMax][StatusMax];
  int[] MoveDataSendFlag = new int[MoveDataMax];
  String[] CommandData = new String[MoveDataMax];
  
  int BaseIndex = 0;
  int LastIndex = 1;
  int [] MoveDataIndex = new int[2];

  float[] CurrentStatus = new float[StatusMax];
  float[][] AxisSpec = new float[AxisMax][SpecMax];

  
  void MachineInitialize (String ProfileFileName){
    LoadProfile(ProfileFileName);
  }
 
  void ManualMove(float dirX, float dirY, float dirZ){
    if(GetNumOfMoveData() < 2){
      MoveTo(MoveMode_Absolute,CurrentStatus[X] + dirX,
             CurrentStatus[Y] + dirY,
             CurrentStatus[Z] + dirZ);
    }
  }

  void ManualMove(float dirX, float dirY, float dirZ,
                  float dirA, float dirB, float dirC){
    if(GetNumOfMoveData() < 2){
      MoveTo(MoveMode_Absolute,CurrentStatus[X] + dirX,
             CurrentStatus[Y] + dirY,
             CurrentStatus[Z] + dirZ,
             CurrentStatus[Aaxis] + dirA,
             CurrentStatus[Baxis] + dirB,
             CurrentStatus[Caxis] + dirC);
    }
  }

  void MoveTo(int MoveMode, float PosX, float PosY, float PosZ){
    if(GetNumOfMoveData() < (MoveDataMax - 2)){
      int PrevIndex=LastIndex();
      IncrementLastIndex();
       
      MoveData[LastIndex()][X] = PosX;
      MoveData[LastIndex()][Y] = PosY;
      MoveData[LastIndex()][Z] = PosZ;
      MoveData[LastIndex()][Aaxis] = MoveData[PrevIndex][Aaxis];
      MoveData[LastIndex()][Baxis] = MoveData[PrevIndex][Baxis];
      MoveData[LastIndex()][Caxis] = MoveData[PrevIndex][Caxis];
      MoveData[LastIndex()][Speed] = SetSpeed;
/*      
      println("BaseIndex:"+BaseIndex()+" LastIndex:"+LastIndex());
      for (int i = 0; i < MoveDataMax; i++){
        if(i==LastIndex()){
          println("----------------------------");
        }
        println("MoveData ["+ i +"] X:"+ MoveData[i][X]+" Y:"+MoveData[i][Y]+" Z:"+MoveData[i][Z]+ " CommandBlock:"+CommandData[i]);
        if(i==LastIndex()){
          println("----------------------------");
        }
        
      }
*/
    }
  }

  void MoveTo(int MoveMode, float PosX, float PosY, float PosZ,
               float PosA, float PosB, float PosC){
    if(GetNumOfMoveData() < (MoveDataMax - 2)){
      IncrementLastIndex();
      int LastIndex=LastIndex();
      MoveData[LastIndex()][X] = PosX;
      MoveData[LastIndex()][Y] = PosY;
      MoveData[LastIndex()][Z] = PosZ;
      MoveData[LastIndex()][Aaxis] = PosA;
      MoveData[LastIndex()][Baxis] = PosB;
      MoveData[LastIndex][Caxis] = PosC;
    }

  }
  
  void Speed(float Speed){
    SetSpeed = Speed;
  }
  
  void Spindle(int OnOff){
  }
  
  void SetXYOrigin(float XOrigin, float YOrigin){
  }
  
  void SetZOrigin(float ZOrigin){
  }

  void OverRide(float FeedRate, float SpindleRate){
  }
  
  void Process(float DeltaTime){
  }
  
  void IncrementBaseIndex(){
    MoveDataIndex[BaseIndex]++;
    if(MoveDataIndex[BaseIndex] > (MoveDataMax - 1)){
      MoveDataIndex[BaseIndex] = 0;
    }
  }

  void IncrementLastIndex(){
    MoveDataIndex[LastIndex]++;
    if(MoveDataIndex[LastIndex] > (MoveDataMax - 1)){
      MoveDataIndex[LastIndex] = 0;
    }
  }
  
  int GetPrevOfLastIndex(){
    int Prev = MoveDataIndex[LastIndex]-1;
    if(Prev < 0){
      Prev = MoveDataMax - 1;
    }
    return Prev;
  }

   int BaseIndex(){
     return MoveDataIndex[BaseIndex];
   }

   int LastIndex(){
     return MoveDataIndex[LastIndex];
   }
  
   
   int GetNextOfBaseIndex(){
    int Next = MoveDataIndex[BaseIndex]+1;
    if(Next > (MoveDataMax - 1)){
      Next = 0;
    }
    return Next;
  }
  
  int GetIndexOfBase(int n){
    int Index = MoveDataIndex[BaseIndex]+n;
    if(Index >  (MoveDataMax - 1)){
      Index -= MoveDataMax;
    }
    return Index;
  }
  
  int GetNumOfMoveData(){
    int Num;
    if(MoveDataIndex[LastIndex] >= MoveDataIndex[BaseIndex]){
      Num = MoveDataIndex[LastIndex] - MoveDataIndex[BaseIndex];
    }else{
      Num = (MoveDataMax + MoveDataIndex[LastIndex]) - MoveDataIndex[BaseIndex];
    }
    return Num;
  }
  
  int GetNumOfSendData(){
    int Num = 0;
    for(int i = 0;i < MoveDataMax; i++){
      if(MoveDataSendFlag[i] == 1){
        Num++;
      }
    }
    return Num;
  }
  
  void LoadProfile(String ProfileFileName){
    BufferedReader reader;
    String[] pieces = new String[1];
  
    reader = createReader(ProfileFileName); 
    if(reader == null){
      reader = createReader(selectInput());
       if(reader == null){
         return;
       } 
    }
    try {
      String line = reader.readLine();
      while(line != null){ 
        pieces = splitTokens(line, " ;"); //区切り文字は" "と";"
        for(int i=0;i <pieces.length;i++){
        }
        line = reader.readLine();
 
        if(pieces[0].equals("Machine")){
          MachineName = pieces[2];
        }
        else if(pieces[0].equals("Port")){
          PortName = pieces[2];
        }
        else if(pieces[0].equals("Xmax")){
          AxisSpec[X][AreaMax] = Float.valueOf(pieces[2]);
        }
        else if(pieces[0].equals("Ymax")){
          AxisSpec[Y][AreaMax] = Float.valueOf(pieces[2]);
        }
        else if(pieces[0].equals("Zmax")){
          AxisSpec[Z][AreaMax] = Float.valueOf(pieces[2]);
        }
        else if(pieces[0].equals("MaxSpeed")){
          AxisSpec[X][MaxSpeed] = Float.valueOf(pieces[2]);
          AxisSpec[Y][MaxSpeed] = Float.valueOf(pieces[2]);
          AxisSpec[Z][MaxSpeed] = Float.valueOf(pieces[2]);
        }
        else if(pieces[0].equals("MinSpeed")){
          AxisSpec[X][MinimumSpeed] = Float.valueOf(pieces[2]);
          AxisSpec[Y][MinimumSpeed] = Float.valueOf(pieces[2]);
          AxisSpec[Z][MinimumSpeed] = Float.valueOf(pieces[2]);
        }
        else if(pieces[0].equals("Resolution")){
          AxisSpec[X][Resolution] = Float.valueOf(pieces[2]);
          AxisSpec[Y][Resolution] = Float.valueOf(pieces[2]);
          AxisSpec[Z][Resolution] = Float.valueOf(pieces[2]);
        }      
      }  
    }catch (IOException e) {
      e.printStackTrace();
    }
  }
}
