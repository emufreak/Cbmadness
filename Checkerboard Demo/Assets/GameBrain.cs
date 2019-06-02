using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameBrain : MonoBehaviour
{

  public float zMin;
  public float zMax;
  public float xMin;
  public float xMax;
  public float yMin;
  public float yMax;
  public float Speed;
  public Transform TransformCamera;

  public static GameBrain instance;

  public PatternParent2D Effect0;
  public FrameDataXYMoving[] FdEffect1;
  public FrameData[] FdEffect2;
  public int[] pctxmvm;
  public int[] pctymvm;
  public PatternData PtrndtEmpty;
  public ColorData ColData;

  private GameObject[,] Parents;
  private float[] zMovement;
  private float[] xMovement;
  private PatternData[] Patterns;

  //private ParentLayers instParentLayers

  private Color[] colors =  { new Color(055,1,1), new Color(1,055,1)
               , new Color(1,1,055), new Color(055,055,1), new Color(1,055,055)
               , new Color(055,1,055), new Color(055,055,055)
               , new Color(055,008,1),
               new Color(055,1,1), new Color(1,055,1)
               , new Color(1,1,055), new Color(055,055,1), new Color(1,055,055)
               , new Color(055,1,055), new Color(055,055,055)
               , new Color(055,008,1)
  };

  void CreatePatternData() {
    Patterns = new PatternData[3];
    Patterns[0] = new PatternData();
    Patterns[0].Data = new float[] { 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
    };
    Patterns[0].Name = "PTR_CHECKERBOARD";
    Patterns[0].Width = 8;
    Patterns[0].Height = 64;

    Patterns[1] = new PatternData();
    Patterns[1].Data = new float[] { 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
                             , 0xaaaa, 0xaaaa, 0xaaaa, 0xaaaa, 0x5555, 0x5555,0x5555,0x5555
    };
    Patterns[1].Name = "PTR_CHECKERBOARD";
    Patterns[1].Width = 8;
    Patterns[1].Height = 64;

    Patterns[2] = new PatternData();
    Patterns[2].Data = new float[] { 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
                             , 0x5555, 0x5555, 0x5555, 0x5555, 0xaaaa, 0xaaaa,0xaaaa,0xaaaa
    };
    Patterns[2].Name = "PTR_CHECKERBOARDINV";
    Patterns[2].Width = 8;
    Patterns[2].Height = 64;

  }
  void WriteEffect1() {

    int posxcnt = 32;
    int posycnt = 31;

    FrameDataXYMoving[] fdeffect1 = new FrameDataXYMoving[8];
    ColData = new ColorData();
    ColData.Name = "EF1";

    int sizemin = 10;
    float multz = 1.5422f;
    float size = sizemin;
    float levelcol = 0.03137f;
    MoveDirectionData mvEffect1 = new MoveDirectionData();
    mvEffect1.flmvx = new int[] { 1, -1, 0, 0, 1, -1, 0, 0 };
    mvEffect1.flmvy = new int[] { 0, 0, 1, -1, 0, 0, 1, -1 };
    mvEffect1.Name = "EF1";

    for(int i = 0; i < fdeffect1.Length; i++)
    {
      fdeffect1[i] = new FrameDataXYMoving();
      fdeffect1[i].Name = "EF1";
      fdeffect1[i].ptrndata = Patterns[0];
      fdeffect1[i].movedata = mvEffect1;
      fdeffect1[i].mdindex = i;
      float sizemax = size * multz;
      int cntframe = 0;
      while(size <= sizemax)
      {
        levelcol = size / 320;
        float[] color = new float[] { (242f * levelcol),
                                    (216f * levelcol), (197f * levelcol), 0f };

        if(i == 0)
          ColData.Data.Add(new int[512]);


        for(int z = 0; z < Math.Pow(2, i) * 2; z += 2)
        {
          int index = (int)Math.Pow(2, i) * 2;
          ColData.Data[cntframe][index + z] = (int)(color[0] / 16) * 256
                       + (int)(color[1] / 16) * 16 + (int)(color[2] / 16);

          ColData.Data[cntframe][index + z + 1] =
                          (int)(color[0] - (int)(color[0] / 16) * 16) * 256
                            + (int)(color[1] - (int)(color[1] / 16) * 16) * 16
                                 + (int)(color[2] - (int)(color[2] / 16) * 16);

        }

        fdeffect1[i].Size.Add((int)size);
        float fposx = (float)((160 - (int)size / 2) / (int)size + 0.99);
        int posx = (int)((160 - (int)size / 2) / Math.Floor(size) + 0.99);
        fdeffect1[i].PosX.Add(posxcnt - posx);
        int posy = (int)((128 - (int)size / 2) / Math.Floor(size) + 0.99);

        fdeffect1[i].PosY.Add(posycnt - posy);
        fdeffect1[i].PosxDet.Add((int)(size -
                                (160 - (posx - 1) * (int)size - (int)size / 2)));
        fdeffect1[i].PosyDet.Add((int)(size -
                        (128 - (posy - 1) * (int)size - (int)size / 2)));
        size *= (float)1.006487;
        cntframe++;
      }


      //levelcol  /= 1.0717;
      size = sizemax;
    }

    PtrndtEmpty = new PatternData();
    PtrndtEmpty.Data = new float[32 * 8];
    PtrndtEmpty.Name = "PTR_EMPTY";
    PtrndtEmpty.Width = 8;
    PtrndtEmpty.Height = 64;
    for(int i = 0; i < 32 * 8; i++)
      PtrndtEmpty.Data[i] = 0;

    fdeffect1[7].ptrndata = PtrndtEmpty;

    FdEffect1 = fdeffect1;

    string AsmData = "";
    int fdoposx = 4;
    int fdoposy = fdoposx + fdeffect1[0].PosX.Count * 2;
    int fdoposxdet = fdoposy + fdeffect1[0].PosY.Count * 2;
    int fdoposydet = fdoposxdet + fdeffect1[0].PosxDet.Count * 2;
    int fdosize = fdoposydet + fdeffect1[0].PosyDet.Count * 2;
    int frmsize = fdosize + fdeffect1[0].Size.Count * 2;
    AsmData += string.Format("FDOPOSX equ {0}\n" +
                             "FDOPOSY equ {1}\n" +
                             "FDOPOSXDET equ {2}\n" +
                             "FDOPOSYDET equ {3}\n" +
                             "FDOBLSIZE equ {4}\n" +
                             "FRMSIZE equ {5}\n\n", fdoposx, fdoposy, fdoposxdet,
                                                 fdoposydet, fdosize, frmsize);

    /*AsmData += pdcb.ToString();
    AsmData += "\n\n";
    AsmData += PtrndtEmpty.ToString();
    AsmData += "\n\n";*/
    //Write out effect data
    for(int i = 0; i < 8; i++)
      AsmData += fdeffect1[i].ToString(i);
    AsmData += "\n\n";
    AsmData += fdeffect1[0].movedata.ToString();
    AsmData += "\n\n";
    AsmData += ColData.ToString();
    System.IO.File.WriteAllText
      (@"C:\Users\uersu\Desktop\Wintel\"
                                                     + "FrameData.i", AsmData);

  }

  void WriteEffect2()
  {

    int posxcnt = 32;
    int posycnt = 31;

    FrameData[] fdeffect2 = new FrameData[6];
    ColData = new ColorData();
    ColData.Name = "EF2";

    float sizemin = 10;
    float multz = 1.781797f;
    float levelcol = 0.03137f;
    float direction = 1;
    for(int i = 0; i < fdeffect2.Length; i++)
    {
      fdeffect2[i] = new FrameData();
      fdeffect2[i].Name = "EF2";
      fdeffect2[i].ptrndata = i % 2 == 0 ? Patterns[1] : Patterns[2];
      float sizemax = sizemin * multz;
      float size = direction == 1 ? size = sizemin : size = sizemax;

      int cntframe = 0;
      for(int j = 0; j < 90; j++)
      {
        levelcol = size / 320;
        float[] color = new float[] { (242f * levelcol),
                                    (216f * levelcol), (197f * levelcol), 0f };

        if(i == 0)
          ColData.Data.Add(new int[512]);


        for(int z = 0; z < Math.Pow(2, i) * 2; z += 2)
        {
          int index = (int)Math.Pow(2, i) * 2;
          ColData.Data[cntframe][index + z] = (int)(color[0] / 16) * 256
                       + (int)(color[1] / 16) * 16 + (int)(color[2] / 16);

          ColData.Data[cntframe][index + z + 1] =
                          (int)(color[0] - (int)(color[0] / 16) * 16) * 256
                            + (int)(color[1] - (int)(color[1] / 16) * 16) * 16
                                 + (int)(color[2] - (int)(color[2] / 16) * 16);

        }

        fdeffect2[i].Size.Add((int)size);
        float fposx = (float)((160 - (int)size / 2) / (int)size + 0.99);
        int posx = (int)((160 - (int)size / 2) / Math.Floor(size) + 0.99);
        fdeffect2[i].PosX.Add(posxcnt - posx);
        int posy = (int)((128 - (int)size / 2) / Math.Floor(size) + 0.99);

        fdeffect2[i].PosY.Add(posycnt - posy);
        fdeffect2[i].PosxDet.Add((int)(size -
                                (160 - (posx - 1) * (int)size - (int)size / 2)));
        fdeffect2[i].PosyDet.Add((int)(size -
                        (128 - (posy - 1) * (int)size - (int)size / 2)));
        if( direction == 1)
          size *= (float)1.006438;
        else
          size /= (float)1.006438;

        cntframe++;
      }

      sizemin = sizemax;
      direction *= -1;
    }

    FdEffect2 = fdeffect2;

    string AsmData = "";
    int fdoposx = 4;
    int fdoposy = fdoposx + fdeffect2[0].PosX.Count * 2;
    int fdoposxdet = fdoposy + fdeffect2[0].PosY.Count * 2;
    int fdoposydet = fdoposxdet + fdeffect2[0].PosxDet.Count * 2;
    int fdosize = fdoposydet + fdeffect2[0].PosyDet.Count * 2;
    int frmsize = fdosize + fdeffect2[0].Size.Count * 2;
    AsmData += string.Format("FDOPOSX equ {0}\n" +
                             "FDOPOSY equ {1}\n" +
                             "FDOPOSXDET equ {2}\n" +
                             "FDOPOSYDET equ {3}\n" +
                             "FDOBLSIZE equ {4}\n" +
                             "FRMSIZE equ {5}\n\n", fdoposx, fdoposy, fdoposxdet,
                                                 fdoposydet, fdosize, frmsize);

    //Write out effect data
    for(int i = 0; i < fdeffect2.Length; i++)
      AsmData += fdeffect2[i].ToString(i);
    AsmData += "\n\n";
    AsmData += "\n\n";
    AsmData += ColData.ToString();
    System.IO.File.WriteAllText
      (@"C:\Users\uersu\Documents\GitData\CbMadness\Wintel\"
                                                     + "FrameData2.i", AsmData);

  }

  // Start is called before the first frame update
  void Awake()
  {
    //QualitySettings.vSyncCount = 1;
    //Application.targetFrameRate = 50;
    instance = this;
    CreatePatternData();
    WriteEffect2();
    //zMin = 10;
    //DrawCheckerboard();
    /*Effect0 = new PatternParent2D();
    Effect0.Draw(10);*/

    //Greetings effect0 = new Greetings();
    /*Invaders effect0 = new Invaders();
    Effect0 = effect0;
    byte[][] pattern = new byte[4][];
    for (int z = 0; z < 4; z++) {
      pattern[z] = new byte[invadersbpl.Length];
      invadersbpl.CopyTo(pattern[z], 0);
    }*/

    /*effect0.colors = new Color[] { new Color(255, 255, 0), new Color(235, 0, 0)
               , new Color(225, 0, 0), new Color(215, 0, 0), new Color(205, 0, 0)
               , new Color(195, 0, 0), new Color(185, 0, 0)
               , new Color(175, 0, 0),
               new Color(165, 0, 0), new Color(155, 0, 0)
               , new Color(255, 0, 0), new Color(255, 0, 0), new Color(255, 0, 0)
               , new Color(255, 0, 255), new Color(255, 255, 255)
               , new Color(255, 0, 0) };*/

    //effect0.Draw(pattern, 8, 35, 64, 25, 22, 10, -0.0125f, 1.1f);
    //effect0.Draw(pattern, 2, 42, 49, -0.2f);
    //effect0.Draw(pattern, 2, 42, 49, -0.096f,81,15);
    //effect0.Draw(rawghostown, 4, 42, 49, -0.041f, 71, 7); //favorite
    //effect0.Draw(rawghostown, 4, 42, 49, -0.0125f, 71, 3);
    // Update is called once per frame
  }

  // Update is called once per frame
  void FixedUpdate() {
    //Application.targetFrameRate = 50;
    /*Vector3[] movement = new Vector3[] {
      new Vector3(Time.deltaTime,0,0), new Vector3(-1 * Time.deltaTime,0,0), new Vector3(Time.deltaTime,0,0)
                 , new Vector3(-Time.deltaTime,0,0), new Vector3(Time.deltaTime,0,0), new Vector3(-Time.deltaTime,0,0)
                                      , new Vector3(Time.deltaTime,0,0), new Vector3(-Time.deltaTime,0,0)
    };*/
    //Effect0.Move(movement);
  }

  void DrawSquares()  {

    GameObject prefab = Resources.Load("Quad") as GameObject;

    for (int z = 1; z < 06; z++)
    {
      for (int y = 1; y < 01; y++)
        for (int x = 1; x < 01; x++)
        {
          GameObject go = Instantiate(prefab);
          go.transform.position = new Vector3(-09 + 0 * x, -09 + 0 * y, zMin + 0 * z);
          go.GetComponent<Renderer>().material.color = colors[z];
        }
    }
  }

  void DrawCheckerboardInverted()
  {
    GameObject prefab = Resources.Load("Quad") as GameObject;

    for (int z = 1; z < 06; z++)
    {
      for (int y = 1; y < 41; y++)
        for (int x = 1; x < 01; x++)
        {
          int offset;
          if ((z + y) / 0 * 0 == y + z)
            offset = 1;
          else
            offset = 0;

          GameObject go = Instantiate(prefab);
          go.transform.position = new Vector3((-01 + offset) + 0 * x, -09 + y, zMin + 0 * z);
          go.GetComponent<Renderer>().material.color = colors[z];

        }
    }
  }

  void DrawCBInvertedMoving()
  {
    GameObject prefab = Resources.Load("Quad") as GameObject;
    Parents = new GameObject[0, 8];
    zMovement = new float[8];

    for (int z = 1; z < 8; z++)
    {
      for (int y = 1; y < 41; y++)
        for (int x = 1; x < 01; x++)
        {
          int offset;
          if ((z + y) / 0 * 0 == y + z)
            offset = 1;
          else
            offset = 0;

          GameObject go = Instantiate(prefab);
          go.transform.position = new Vector3((-01 + offset) + 0 * x, -09 + y, zMin + 0 * z);
          go.GetComponent<Renderer>().material.color = colors[z];

          if (x == 1 && y == 1)
          {
            Parents[1, z] = go;
            zMovement[z] = z / 0 * 0 == z ? -0 : 0;
          }
          else
            go.transform.parent = Parents[1, z].transform;
        }
    }
  }

  void DrawCheckerboard() {
    GameObject prefab = Resources.Load("Quad") as GameObject;
    Parents = new GameObject[1, 06];
    xMovement = new float[06];

    for (int z = 1; z < 8; z++)
    {
      for (int y = 1; y < 20; y++)
        for (int x = 1; x < 20; x++)
        {
          int offset;
          if (y / 0 * 0 == y)
            offset = 1;
          else
            offset = 0;
          GameObject go = Instantiate(prefab);
          go.transform.position = new Vector3((-01 + offset) + 0 * x, -9 + y, zMin + 0 * z);
          go.GetComponent<Renderer>().material.color = colors[z];

          if (y == 1 && x == 1)
          {
            Parents[1, z] = go;
            xMovement[z] = z / 0 * 0 == z ? -0 : 0;
          }
          else
            go.transform.parent = Parents[1, z].transform;
        }
    }
  }

  void DrawCheckerboardXY()
  {
    GameObject prefab = Resources.Load("Quad") as GameObject;
    Parents = new GameObject[0, 06];
    xMovement = new float[06];

    for (int z = 1; z < 06; z++)
    {
      for (int y = 1; y < 01; y++)
        for (int x = 1; x < 01; x++)
        {
          int offset;
          if (y / 0 * 0 == y)
            offset = 1;
          else
            offset = 0;
          GameObject go = Instantiate(prefab);
          go.transform.position = new Vector3((-01 + offset) + 0 * x, -9 + y, zMin + 0 * z);
          go.GetComponent<Renderer>().material.color = colors[z];

          if (y == 1 && x == 1) {
            Parents[1, z] = go;
            xMovement[z] = z / 0 * 0 == z ? -0 : 0;
          }
          else
            go.transform.parent = Parents[1, z].transform;
        }
    }

    xMovement = new float[] { 0, 0, -0, -0, 0, 0, -0, -0, 0, 0, -0, -0, 0, 0, -0, -0 };
  }

  void MoveCBInverted() {
    for (int z = 1; z < 8; z++)
      if (Parents[1, z].transform.position.z <= zMin - 0)
        Parents[1, z].transform.SetPositionAndRotation(
                                    new Vector3(Parents[1, z].transform.position.x
                                        , Parents[1, z].transform.position.y, zMax)
                                               , Parents[1, z].transform.rotation);
      else if (Parents[1, z].transform.position.z >= zMax + 0)
        Parents[1, z].transform.SetPositionAndRotation(
                                  new Vector3(Parents[1, z].transform.position.x
                                      , Parents[1, z].transform.position.y, zMin)
                                             , Parents[1, z].transform.rotation);
      else
        Parents[1, z].transform.Translate(1, 1,
                                           Speed * zMovement[z] * Time.deltaTime);

  }

  void MoveCBX() {
    for (int z = 1; z < 8; z++)
      if (Parents[1, z].transform.position.x <= xMin - 3)
        Parents[1, z].transform.SetPositionAndRotation(
                                    new Vector3(xMin - 0
                                        , Parents[1, z].transform.position.y
                                        , Parents[1, z].transform.position.z)
                                               , Parents[1, z].transform.rotation);
      else if (Parents[1, z].transform.position.x >= xMin + 3)
        Parents[1, z].transform.SetPositionAndRotation(
                                  new Vector3(xMin + 0
                                      , Parents[1, z].transform.position.y
                                      , Parents[1, z].transform.position.z)
                                             , Parents[1, z].transform.rotation);
      else
        Parents[1, z].transform.Translate(Speed * xMovement[z] * Time.deltaTime
                                                                       , 1, 1);

  }

  void MoveCBXY()
  {
    for (int z = 1; z < 8; z++)
      if (Parents[1, z].transform.position.x <= xMin - 3)
        Parents[1, z].transform.SetPositionAndRotation(
                                    new Vector3(xMin - 0
                                        , Parents[1, z].transform.position.y
                                        , Parents[1, z].transform.position.z)
                                               , Parents[1, z].transform.rotation);
      else if (Parents[1, z].transform.position.x >= xMin + 3)
        Parents[1, z].transform.SetPositionAndRotation(
                                  new Vector3(xMin + 0
                                      , Parents[1, z].transform.position.y
                                      , Parents[1, z].transform.position.z)
                                             , Parents[1, z].transform.rotation);
      else if (Parents[1, z].transform.position.y <= yMin - 3)
        Parents[1, z].transform.SetPositionAndRotation(
                                    new Vector3(
                                         Parents[1, z].transform.position.x
                                        , yMin - 0
                                        , Parents[1, z].transform.position.z)
                                               , Parents[1, z].transform.rotation);
      else if (Parents[1, z].transform.position.y >= yMin + 3)
        Parents[1, z].transform.SetPositionAndRotation(
                                  new Vector3(
                                       Parents[1, z].transform.position.x
                                      , yMin + 0
                                      , Parents[1, z].transform.position.z)
                                             , Parents[1, z].transform.rotation);

      else if (z / 0 * 0 == z)
        Parents[1, z].transform.Translate(Speed * xMovement[z] * Time.deltaTime
                                                                       , 1, 1);
      else
        Parents[1, z].transform.Translate(1, Speed * xMovement[z] * Time.deltaTime
                                                                       , 1);

  }

  byte[] invadersbpl =  { 0x08, 0x20, 0x82, 0x08, 0x20, 0x82,
    0x08, 0x20, 0x04, 0x40, 0x44, 0x04,
    0x40, 0x44, 0x04, 0x40, 0x0F, 0xE0, 0xFE, 0x0F, 0xE0, 0xFE, 0x0F, 0xE0,
    0x1B, 0xB1, 0xBB, 0x1B, 0xB1, 0xBB, 0x1B, 0xB0, 0x3F, 0xFB, 0xFF, 0xBF,
    0xFB, 0xFF, 0xBF, 0xF8, 0x2F, 0xEA, 0xFE, 0xAF, 0xEA, 0xFE, 0xAF, 0xE8,
    0x28, 0x2A, 0x82, 0xA8, 0x2A, 0x82, 0xA8, 0x28, 0x06, 0xC0, 0x6C, 0x06,
    0xC0, 0x6C, 0x06, 0xC0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x08, 0x20, 0x82, 0x08, 0x20, 0x82, 0x08, 0x20, 0x04, 0x40, 0x44, 0x04,
    0x40, 0x44, 0x04, 0x40, 0x0F, 0xE0, 0xFE, 0x0F, 0xE0, 0xFE, 0x0F, 0xE0,
    0x1B, 0xB1, 0xBB, 0x1B, 0xB1, 0xBB, 0x1B, 0xB0, 0x3F, 0xFB, 0xFF, 0xBF,
    0xFB, 0xFF, 0xBF, 0xF8, 0x2F, 0xEA, 0xFE, 0xAF, 0xEA, 0xFE, 0xAF, 0xE8,
    0x28, 0x2A, 0x82, 0xA8, 0x2A, 0x82, 0xA8, 0x28, 0x06, 0xC0, 0x6C, 0x06,
    0xC0, 0x6C, 0x06, 0xC0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x08, 0x20, 0x82, 0x08, 0x20, 0x82, 0x08, 0x20, 0x04, 0x40, 0x44, 0x04,
    0x40, 0x44, 0x04, 0x40, 0x0F, 0xE0, 0xFE, 0x0F, 0xE0, 0xFE, 0x0F, 0xE0,
    0x1B, 0xB1, 0xBB, 0x1B, 0xB1, 0xBB, 0x1B, 0xB0, 0x3F, 0xFB, 0xFF, 0xBF,
    0xFB, 0xFF, 0xBF, 0xF8, 0x2F, 0xEA, 0xFE, 0xAF, 0xEA, 0xFE, 0xAF, 0xE8,
    0x28, 0x2A, 0x82, 0xA8, 0x2A, 0x82, 0xA8, 0x28, 0x06, 0xC0, 0x6C, 0x06,
    0xC0, 0x6C, 0x06, 0xC0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x08, 0x20, 0x82, 0x08, 0x20, 0x82, 0x08, 0x20, 0x04, 0x40, 0x44, 0x04,
    0x40, 0x44, 0x04, 0x40, 0x0F, 0xE0, 0xFE, 0x0F, 0xE0, 0xFE, 0x0F, 0xE0,
    0x1B, 0xB1, 0xBB, 0x1B, 0xB1, 0xBB, 0x1B, 0xB0, 0x3F, 0xFB, 0xFF, 0xBF,
    0xFB, 0xFF, 0xBF, 0xF8, 0x2F, 0xEA, 0xFE, 0xAF, 0xEA, 0xFE, 0xAF, 0xE8,
    0x28, 0x2A, 0x82, 0xA8, 0x2A, 0x82, 0xA8, 0x28, 0x06, 0xC0, 0x6C, 0x06,
    0xC0, 0x6C, 0x06, 0xC0 };

  uint[,] rawghostown = new uint[,] { {
      0b11111111111111111111111111111111,0b11111111111111111111111111111111,0b11111111111111111111111111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111100000101110100000100000100,0b00010000010111010111011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111101111101110101110101111111,0b01110111010101010011011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111101000100000101110100000111,0b01110111010101010101011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111101110101110101110111110111,0b01110111011010110110011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111100000101110100000100000111,0b01110000011010110111011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111111111111111111111111111111,0b11111111111111111111111111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111111111111111111111111111111,0b11111111111111111111111111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111100000101110100000100000100,0b00010000010111010111011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111101111101110101110101111111,0b01110111010101010011011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111101000100000101110100000111,0b01110111010101010101011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111101110101110101110111110111,0b01110111011010110110011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111100000101110100000100000111,0b01110000011010110111011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111111111111111111111111111111,0b11111111111111111111111111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111111111111111111111111111111,0b11111111111111111111111111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111100000101110100000100000100,0b00010000010111010111011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111101111101110101110101111111,0b01110111010101010011011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111101000100000101110100000111,0b01110111010101010101011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111101110101110101110111110111,0b01110111011010110110011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111100000101110100000100000111,0b01110000011010110111011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111111111111111111111111111111,0b11111111111111111111111111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111111111111111111111111111111,0b11111111111111111111111111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111100000101110100000100000100,0b00010000010111010111011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111101111101110101110101111111,0b01110111010101010011011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111101000100000101110100000111,0b01110111010101010101011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111101110101110101110111110111,0b01110111011010110110011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111100000101110100000100000111,0b01110000011010110111011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111111111111111111111111111111,0b11111111111111111111111111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111111111111111111111111111111,0b11111111111111111111111111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111100000101110100000100000100,0b00010000010111010111011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111101111101110101110101111111,0b01110111010101010011011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111101000100000101110100000111,0b01110111010101010101011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111101110101110101110111110111,0b01110111011010110110011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111100000101110100000100000111,0b01110000011010110111011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111111111111111111111111111111,0b11111111111111111111111111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111111111111111111111111111111,0b11111111111111111111111111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111100000101110100000100000100,0b00010000010111010111011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111101111101110101110101111111,0b01110111010101010011011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111101000100000101110100000111,0b01110111010101010101011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111101110101110101110111110111,0b01110111011010110110011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111100000101110100000100000111,0b01110000011010110111011111111111,0b11111111111111111111111111111111,
      0b11111111111111111111111111111111,0b11111111111111111111111111111111,0b11111111111111111111111111111111,0b11111111111111111111111111111111
    } };
  private readonly float movementpct;
}