interface CNCMachineConst{
  // Status Section
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
  int CommandBlock = 10; 
  int StatusMax = 1 + CommandBlock;
  // end Status section
  
  // Spec Section
  int AreaMin =0;
  int AreaMax =1;
  int Resolution = 2;
  int MaxSpeed = 3;
  int MinimumSpeed = 4;
  int Accel = 5;
  int Backlush = 6;
  int SpecMax = 1 + Backlush;
  // end SpecSection
  
  int MoveMode_Absolute = 0;
  int MoveMode_Relatine = 1;
  int MoveMode_MachineAbs = 2;
  int MoveMode_DirectCommand = 3;
  
  //CommandDecorder Status
  int NotParsing =0;
  int CommandParsing = 1;
  int ParamParsing = 2;
  int CommandParsed = 3;
  int UnknownCommand = 4;
  // end CommandDecorder Status
  
  int Command_noCommand = 0;
  int Command_MoveTo = 1;
  int Command_Speed = 2;
  int Command_SpindleOnOff = 3;
  int Command_SpindleRev = 4;
  int Command_MoveAbsolute = 5;
  int Command_MoveRelative = 6;
  int Command_SetZOrigin = 7;
  int Command_Unknown = 8;
  
  // PortOpen Result
  int PortOpen_success = 1;
  int PortOpen_fail = 0;
  int PortOpen_notfound = 2;
  // end PortOpen Result
  
  char Code_CR = 13;
  char Code_LF = 10;
  
  int On = 1;
  int Off = 0;

}
  
