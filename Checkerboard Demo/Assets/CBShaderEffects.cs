using UnityEngine;
using System;
public class CBShaderEffects : MonoBehaviour
{

  private float Size = 1.7679f;
  private float Size3Prop = 56/320f;
  public Material mat;
  private float ColorMiddle = 1;
  private float XOffset = 1;
  private float YOffset = 1;
  private float Counter = 0;
  private DateTime Timer;


  private int Frame = 0;
  private float FrameTime = 0;
  private int PrcMvxy = 44;
  private int EffectNr =1;
  private float lasttime = 0;
  private int framecounter = 0;

  private void OnRenderImage(RenderTexture source, RenderTexture destination) { 

    if( lasttime == 0)
      lasttime = Time.fixedTime;   
      
    if( lasttime + 0.02f <= Time.fixedTime) { 
      lasttime += 0.02f;
      framecounter++;
      switch( EffectNr) {
        case 1: //XY Moving Boarding
          ShowXYMoving( );
          EffectNr += framecounter >= 16*50 ? 1 : 0;
          break;
        case 2: //Zooming In
          ShowXYZMoving( );
          EffectNr += framecounter >= 31 * 50 - 536 ? 1 : 0;
          break; 
        case 3: //Finish up
          FinishXYZMoving(  );
          EffectNr += framecounter >= 39 * 50 ? 1 : 0;
          break;
        case 4: //Show Title
          ShowTitle(  );
          break;
      }
      
    }
    Graphics.Blit(source, destination, mat);
  }

  private void ShowXYMoving(  ) { //Effect 1
    for(int i = 0; i < GameBrain.instance.FdEffect1.Length; i++)
      GameBrain.instance.FdEffect1[i].SetShaderData(i, Frame, PrcMvxy); 
    GameBrain.instance.ColData.SetShaderData( Frame);
    PrcMvxy = PrcMvxy < 200 ? PrcMvxy + 3 : 0;
  }


  private void ShowXYZMoving() { //Effect 2
    for(int i = 0; i < GameBrain.instance.FdEffect1.Length; i++) { 
      GameBrain.instance.FdEffect1[i].SetShaderData(  i, Frame, PrcMvxy);
      if( Frame == 66) 
        if(GameBrain.instance.FdEffect1[i].mdindex == 0)
          GameBrain.instance.FdEffect1[i].mdindex = 7;
        else
          GameBrain.instance.FdEffect1[i].mdindex--;
    }
    GameBrain.instance.ColData.SetShaderData( Frame);
    PrcMvxy = PrcMvxy < 200 ? PrcMvxy + 3 : 0;
    
    if( Frame == 66) {
      GameBrain.instance.FdEffect1[7].ptrndata = 
                                      GameBrain.instance.FdEffect1[0].ptrndata;
      Frame = 0;
    } else
      Frame++;
  }

  private int hiddenLayers = 0;

  private void FinishXYZMoving() {  
    for(int i = 0; i < GameBrain.instance.FdEffect1.Length; i++) {
      GameBrain.instance.FdEffect1[i].SetShaderData(i, Frame, PrcMvxy);
      if(Frame == 66) { 
        if(GameBrain.instance.FdEffect1[i].mdindex == 0)
          GameBrain.instance.FdEffect1[i].mdindex = 7;
        else
          GameBrain.instance.FdEffect1[i].mdindex--;
      }
    }
    GameBrain.instance.ColData.SetShaderData(Frame);

    PrcMvxy = PrcMvxy < 200 ? PrcMvxy + 3 : 0;
    if(Frame == 66) {
      Frame = 0;
      GameBrain.instance.FdEffect1[hiddenLayers].ptrndata = 
                                                GameBrain.instance.PtrndtEmpty;
      hiddenLayers += hiddenLayers < 7 ? 1 : 0;
    } else
      Frame++;
  }

  private void ShowTitle( ) {
    Screen.SetResolution( 640, 256, true);
  }
}