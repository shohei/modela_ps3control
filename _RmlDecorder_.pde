class RmlCommandDecoder implements CNCMachineConst{
  int DebugPrint = 0;

  String MachineName;
  
  float []Param = new float [StatusMax];
  float []Status = new float [StatusMax];
  float [][]AxisSpec = new float[AxisMax][SpecMax];
  
  String CommandParsingBuf ="";
  String ParamParsingBuf ="";
  String CommandBlock =""; 
  
  int ParsingStatus = NotParsing;
  int ParsingCommand = Command_noCommand;
 
  final int Param_none = 0;
  final int Param_XAxis = 1;
  final int Param_YAxis = 2;
  final int Param_ZAxis = 3;
  final int Param_AAxis = 4;
  final int Param_BAxis = 5;
  final int Param_CAxis = 6;
  final int Param_SpindleRev = 7;
  final int Param_SpindleOnOff = 8;
  final int Param_Speed = 9;
  final int Param_ZOrigin = 10;
  final int Param_Unknown = 11;
  int ParsingParam = Param_none;
  
  int SpindleOnOff = 0;
  int Result = NotParsing;
  
  boolean ZECommand = false;
  
  int ParsedCommand = Command_noCommand;
  
  void Initialize(String ProfileFileName){
    LoadProfile(ProfileFileName);
  }
  
  int Parse(char RecieveData){
    if((Result == CommandParsed) || (Result == UnknownCommand)){
      CommandBlock = "";
    }
    Result = NotParsing;
    if((RecieveData != Code_CR) && (RecieveData != Code_LF)){
      CommandBlock += RecieveData;
    }
    if((RecieveData >= '0' && RecieveData <= '9')
        || RecieveData == '.'){
      Result = ParamParsing;
      if(ParsingStatus == NotParsing){
        ParsingStatus = ParamParsing;
        ParamParsingBuf += RecieveData;
      }
      if(ParsingStatus == ParamParsing){
        ParamParsingBuf += RecieveData;
      }else if(ParsingStatus == CommandParsing){
        CommandFix();
        ParsingStatus = ParamParsing;
        ParamParsingBuf += RecieveData;
     }
    }else if((RecieveData >= 'A' && RecieveData <= 'z') 
              || RecieveData == '!'){
      Result = CommandParsing;
      if(ParsingStatus == NotParsing){
        ParsingStatus = CommandParsing;
        CommandParsingBuf += RecieveData;
      }else if(ParsingStatus == ParamParsing){
        ParamFix();
        ParsingStatus = CommandParsing;
        CommandParsingBuf += RecieveData;
      }else if(ParsingStatus == CommandParsing){
        if(RecieveData == 'e'|| RecieveData == 'E'){
          CommandParsingBuf += 'E';
          if(CommandParsingBuf.equals("!ZE")){
            // !ZEコマンドの特例処理(英字コマンドのあとにパラメータフィールドとして英字が来るため）
            ZECommand = true;
            ParsingCommand = Command_MoveTo;
            CommandParsingBuf = "";
          }
        }else{
          CommandParsingBuf += RecieveData;
        }
      }
     }else if(RecieveData == ','){
       ParamFix();
     }else if(RecieveData == ';' || RecieveData == Code_CR 
              || RecieveData == Code_LF){
       if(ParsingStatus == CommandParsing){
         CommandFix();
         if(ParsingCommand == Command_Unknown){
           FinalizeCommand();
           Result = UnknownCommand;
         }else{
           FinalizeCommand();
           Result = CommandParsed;
         }
       }else if(ParsingStatus == ParamParsing){
         ParamFix();
         if(ParsingCommand == Command_Unknown){
           FinalizeCommand();
           Result = UnknownCommand;
         }else{
           FinalizeCommand();
           Result = CommandParsed;
         }
         Result = CommandParsed;
       }
       ParsingStatus = NotParsing;
     }
  
    Debugprintln(CommandBlock);
    return Result;
  }
  
  void CommandFix(){
    CommandParsingBuf.toUpperCase();
    if(ZECommand == true){
      if(CommandParsingBuf.equals("X")){
        ParsingParam = Param_XAxis;
      }else if(CommandParsingBuf.equals("Y")){
        ParsingParam = Param_YAxis;
      }else if(CommandParsingBuf.equals("Z")){
        ParsingParam = Param_ZAxis;
      }else if(CommandParsingBuf.equals("A")){
        ParsingParam = Param_AAxis;
      }else if(CommandParsingBuf.equals("B")){
        ParsingParam = Param_BAxis;
      }else if(CommandParsingBuf.equals("C")){
        ParsingParam = Param_CAxis;
      }
          
    }else{
      if(CommandParsingBuf.equals("!ZZ")){
        ParsingCommand = Command_MoveTo;
        ParsingParam = Param_XAxis;
      }else if(CommandParsingBuf.equals("Z")){
        ParsingCommand = Command_MoveTo;
        ParsingParam = Param_XAxis;
      }else if(CommandParsingBuf.equals("V")){
        ParsingCommand = Command_Speed;
        ParsingParam = Param_Speed;
      }else if(CommandParsingBuf.equals("VS")){
        ParsingCommand = Command_Speed;
        ParsingParam = Param_Speed;
      }else if(CommandParsingBuf.equals("!MC")){
        ParsingCommand = Command_SpindleOnOff;
        ParsingParam = Param_SpindleOnOff;
      }else if(CommandParsingBuf.equals("!RC")){
        ParsingCommand = Command_SpindleRev;
        ParsingParam = Param_SpindleOnOff;
      }else if(CommandParsingBuf.equals("^PA")){
        ParsingCommand = Command_MoveAbsolute;
        ParsingParam = Param_none;
      }else if(CommandParsingBuf.equals("^PR")){
        ParsingCommand = Command_MoveRelative;
        ParsingParam = Param_none;
      }else if(CommandParsingBuf.equals("^!ZO")){
        ParsingCommand = Command_SetZOrigin;
        ParsingParam = Param_ZOrigin;
      }else{        
        ParsingCommand = Command_Unknown;
        ParsingParam = Param_Unknown;
      }

      CommandParsingBuf = "";
    }
  } 
  
  void ParamFix(){
    float FieldParam = Float.parseFloat(ParamParsingBuf);
    if(ParsingParam == Param_XAxis){
      Param[X] = FieldParam;
      ParsingParam = Param_YAxis;
    }else if(ParsingParam == Param_YAxis){
      Param[Y] = FieldParam;
      ParsingParam = Param_ZAxis;
    }else if(ParsingParam == Param_ZAxis){
      Param[Z] = FieldParam;
      ParsingParam = Param_AAxis;
    }else if(ParsingParam == Param_AAxis){
      Param[Aaxis] = FieldParam;
      ParsingParam = Param_BAxis;
    }else if(ParsingParam == Param_BAxis){
      Param[Baxis] = FieldParam;
      ParsingParam = Param_CAxis;
    }else if(ParsingParam == Param_CAxis){
      Param[Caxis] = FieldParam;
      ParsingParam = Param_none;
    }else if(ParsingParam == Param_Speed){
      Param[Speed] = FieldParam;
      ParsingParam = Param_none;
    }else if(ParsingParam == Param_SpindleRev){
      Param[SpindleRev] = FieldParam;
      ParsingParam = Param_none;
    }else if(ParsingParam == Param_SpindleOnOff){
      SpindleOnOff = (int)FieldParam;
      ParsingParam = Param_none;
    }
    ParamParsingBuf="";    
    
  }
  
  void FinalizeCommand(){
    ParsedCommand = ParsingCommand;
    if(ParsingCommand == Command_MoveTo){
      Debugprintln("ParsingCommand == Command_MoveTo");
      MoveTo();
    }
    if(ParsingCommand == Command_Speed){
      Speed();
    }
    if(ParsingCommand == Command_SpindleRev){
      SpindleRev();
    }
    if(ParsingCommand == Command_SpindleOnOff){
      SpindleOnOff();
    }
    ParsingCommand = Command_noCommand;
    ParsingParam = Param_none;
  }
  
  void MoveTo(){
    for(int i = 0;i < AxisMax;i++){
      Debugprintln("Param" + i +": "+Param[i]);
      Status[i]=Param[i]* AxisSpec[i][Resolution];
    }
  }
  
  void Speed(){
    Status[Speed]=Param[Speed];
  }
  
  void SpindleRev(){
    Status[SpindleRev] =Param[SpindleRev];  
  }
  
  void SpindleOnOff(){
    if(SpindleOnOff == 0){
      Status[SpindleRev] = 0;
    }  
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
  
  void Debugprint(String DebugString){
    if(DebugPrint != 0){
      print(DebugString);
    }
  }
  void Debugprintln(String DebugString){
    if(DebugPrint != 0){
      println(DebugString);
    }
  }  

}
// end class RmlCommandDecoder{} 
