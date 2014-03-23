class RmlCommandEncorder implements CNCMachineConst{
  
  
  String MoveTo(float PosX, float PosY, float PosZ){
    String s = "Z";
    return s;
  }
  
  String Speed(){
    String s = "VS";
    return s;
  }
  
  String Spindle(){
    String s = "!MC";
    return s;
  }
  
  String SetZOrigin(){
    String s = "!ZO";
    return s;
  }
}

