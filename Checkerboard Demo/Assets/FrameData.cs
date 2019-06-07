using System.Collections;
using System;
using System.Collections.Generic;
using UnityEngine;
 
public class AsmMatrix<dynamic> : List<dynamic> {
  
  public override string ToString( ) {
    string result = "dc.w ";
    int counter = 1;
    foreach(  dynamic item in this) {
      if( counter != 1) result += ",";
      result += string.Format(  "{0}", item);
      if( counter++ == 10) {
        counter = 1;
        result += "\n  dc.w ";
      }
    }
    return result;
  }

}

public class ColorData {

  public string Name;
  public List<int[]> Data;

  public ColorData( ) {
    Data = new List<int[]>();
  }

  public void SetShaderData(  int frame) {
    Shader.SetGlobalFloatArray( "_Color" , Array.ConvertAll( Data[frame], x => (float) x));
  }

  public override string ToString( ) {
    string result = "";
    int cntframe = 0;
    foreach(int[] item in Data) {
      result += string.Format("\n\n{1}_COLOR{0}: \n  dc.w ", cntframe++, Name);
      int itmline = 1;
      foreach(int i in item) {
        if(itmline != 1) result += ",";
        result += string.Format("{0}", i);
        if(itmline++ == 10) {
          itmline = 1;
          result += "\n  dc.w ";
        }
      }
    }
    return result;
  }

}

public class PatternData {
  public float[] Data;
  public string Name;
  public int Width;
  public int Height;

  public override string ToString( ) {
    string result = string.Format("{0}_WIDTH: dc.w {1}\n", Name, Width);
    result += string.Format("{0}_HEIGHT: dc.w {1}\n", Name, Height);
    result += string.Format("{0}_DATA:\n  dc.w ", Name);
    int counter = 1;
    foreach(float flitem in Data)
    {
      int item = (int) flitem;
      if(counter != 1) result += ",";
      result += string.Format("{0}", item);
      if(counter++ == 10)
      {
        counter = 1;
        result += "\n  dc.w ";
      }
    }
    return result;
  }
}

public class MoveDirectionData {
  public string Name;
  public int[] flmvx;
  public int[] flmvy;

  public override string ToString( ) {
    string result = string.Format(  "{0}_MOVEX: \n  dc.w ", Name);
    int counter = 1;
    foreach(int item in flmvx) {
      if(counter != 1) result += ",";
      result += string.Format("{0}", item);
      if(counter++ == 10) {
        counter = 1;
        result += "\n  dc.w ";
      }
    }
    result += "\n\n";

    result += string.Format("{0}_MOVEY: \n  dc.w ", Name);
    counter = 1;
    foreach(int item in flmvy) {
      if(counter != 1) result += ",";
      result += string.Format("{0}", item);
      if(counter++ == 10) {
        counter = 1; 
        result += "\n  dc.w ";
      }
    }

    return result;
  }
}

public class FrameDataXYMoving : FrameData {
  
  public MoveDirectionData movedata;
  public int mdindex;

  private void MoveXY( int pos, int posdet, int size, int pctmv, 
                                         string varshdr,  string varshdrdet ) {

    posdet -= size * pctmv / 100;
    for(int i = 0; i < 2; i++)
      if(posdet < 0) {
        posdet += size;
        pos++;
      } 
      else if(posdet >= size) {
        posdet -= size;
        pos--;
      }

    Shader.SetGlobalFloat(varshdr, pos);
    Shader.SetGlobalFloat(varshdrdet, posdet);
  }

  public void SetShaderData(int layer, int frame, int pctmv) { 
    
    base.SetShaderData(layer, frame);
    
    MoveXY(PosX[frame], PosxDet[frame], Size[frame]
       , pctmv * movedata.flmvx[mdindex], "_PosX" + layer, "_DetPosX" + layer);
    MoveXY(PosY[frame], PosyDet[frame], Size[frame]
       , pctmv * movedata.flmvy[mdindex], "_PosY" + layer, "_DetPosY" + layer);
    /*Debug.Log(  string.Format(  "layer {0}: posx = {1} detposx = {2}", 
                                                        layer, posx, posxdet));*/
  }
}

public class FrameData {
  public string Name;
  public AsmMatrix<int> PosX;
  public AsmMatrix<int> PosY;
  public AsmMatrix<int> PosxDet;
  public AsmMatrix<int> PosyDet;
  public AsmMatrix<int> Size;
  public PatternData ptrndata;

  public FrameData() {
    PosX = new AsmMatrix<int>();
    PosY = new AsmMatrix<int>();
    PosxDet = new AsmMatrix<int>();
    PosyDet = new AsmMatrix<int>();
    Size = new AsmMatrix<int>();
  }

  public virtual void SetShaderData(int layer, int frame, float totallayers = 8) {
    Shader.SetGlobalFloatArray("_PatternData" + layer, ptrndata.Data);
    Shader.SetGlobalFloat("_PosX" + layer, PosX[frame]);
    Shader.SetGlobalFloat("_PosY" + layer, PosY[frame]);
    Shader.SetGlobalFloat("_DetPosY" + layer, PosyDet[frame]);
    Shader.SetGlobalFloat("_DetPosX" + layer, PosxDet[frame]);
    Shader.SetGlobalFloat("_Size" + layer, Size[frame]);
    Shader.SetGlobalFloat("_TotalLayers", totallayers);
  } 

  public virtual string ToString(  int layer) {
    //Offset in Memory for different things
    int fdoposx = 4;
    int fdoposy = fdoposx + PosX.Count * 2;
    int fdoposxdet = fdoposy + PosY.Count * 2;
    int fdoposydet = fdoposxdet + PosxDet.Count * 2;
    int fdosize = fdoposydet + PosyDet.Count * 2;
    return string.Format("{7}_PATTERNDATA{0}: dc.l {1}_DATA\n"
                       + "{7}_POSX{0}:\n"
                       + "  {2}\n" 
                       + "{7}_POSY{0}:\n"
                       + "  {3}\n"
                       + "{7}_POSXDET{0}:\n"
                       + "  {4}\n"
                       + "{7}_POSYDET{0}:\n"
                       + "  {5}\n"
                       + "{7}_SIZE{0}:\n"
                       + "  {6}\n\n", layer, ptrndata.Name, PosX.ToString(  ), 
                                        PosY.ToString( ), PosxDet.ToString(  ), 
                                 PosyDet.ToString(  ), Size.ToString( ), Name);
  }
}

/*public class FrameDataBitMap {
  public FrameData[] Items;

  public ColorData GetColors() {

    boolean itemsreset = new itemsreset() 

    foreach(FrameData item in Items) {
      
    }
  }
}*/

