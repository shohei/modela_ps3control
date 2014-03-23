class CNCMachineSim extends CNCMachineBasis{

  void MachineInitialize(String ProfilefileName){
    super.MachineInitialize(ProfilefileName);
  }
  
  void MoveTo(int MoveMode, float PosX, float PosY, float PosZ){
    super.MoveTo(MoveMode, PosX, PosY, PosZ);
  }

  void MoveTo(int MoveMode, float PosX, float PosY, float PosZ,
               float PosA, float PosB, float PosC){
    super.MoveTo(MoveMode, PosX, PosY, PosZ, PosA, PosB, PosC);
  }
  
  void Process(float DeltaTime){
    float accel = 0.05;

    // velocity process 加減速処理
    if(GetNumOfMoveData() > 0){
      int Base = BaseIndex();
      int Next = GetNextOfBaseIndex();
      
      if(CurrentStatus[Speed] < MoveData[Next][Speed]){
        CurrentStatus[Speed] += accel * 1000 * DeltaTime;
        if(CurrentStatus[Speed] > MoveData[Next][Speed]){
          CurrentStatus[Speed] = MoveData[Next][Speed];
        }
      }
      else if(CurrentStatus[Speed] > MoveData[Next][Speed]){
        CurrentStatus[Speed] -= accel * DeltaTime;
        if(CurrentStatus[Speed] < MoveData[Next][Speed]){
          CurrentStatus[Speed] = MoveData[Next][Speed];
        }
      }
      
      CurrentStatus[Distance] = sqrt(sq(MoveData[Next][X]-CurrentStatus[X]) 
                          + sq(MoveData[Next][Y]-CurrentStatus[Y])
                          + sq(MoveData[Next][Z]-CurrentStatus[Z]));

                          
      if(CurrentStatus[Distance] > 0.00001){
        float []distanceV = new float[3];
        float DeltaMove = CurrentStatus[Speed]*DeltaTime;
   
        for(int i=0;i < 3;i++){
          distanceV[i] = (MoveData[Next][i]-CurrentStatus[i])/CurrentStatus[Distance]
                         *DeltaMove;
  
          if(CurrentStatus[Distance] > DeltaMove){
            CurrentStatus[i] += distanceV[i];
          }
          else{
            CurrentStatus[i] = MoveData[Next][i];
          }
        }
      }
        
      if(CurrentStatus[Distance] < 0.0001){
          IncrementBaseIndex();
          if(GetNumOfMoveData()==0){
            println("Buffer Empty:Stop"); 
            CurrentStatus[Speed]=0;
          }
//          println ("MoveData Buffered:"+GetNumOfMoveData()+" BaseIndex:"+BaseIndex()+" NextIndex:"+GetNextOfBaseIndex()+" LastIndex:"+LastIndex() 
//                    +" Distance:"+CurrentStatus[Distance] );
      }

    }
  }
}    

