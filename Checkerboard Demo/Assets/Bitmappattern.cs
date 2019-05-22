using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PatternFromBitmap : PatternParent3D
{

  public GameObject[,] Parents;
  protected float Distancechange;
  protected int maxX;

  public void Draw(byte[][] pattern, int cols, int height, int width,
                                        int camerax, int cameray, int camerazdist
                         , float distancechange = 0.2f, float maxdistance = 30) {
    Scale = maxdistance;
    Distancechange = distancechange;
    Height = height;
    maxX = cols * 8;
    Parents = new GameObject[maxX, Height];
    Width = width;

    for (int z = 0; z < pattern.GetLength(0); z++)
      for (int col = 0; col < cols; col++)
        for (int y = 0; y < height; y++) {
          //int x = col * 8;
          byte curpattern = pattern[z][col + y * cols];
          for(int x=col*8;x<col*8+8;x++) {
            GameObject go;
            if ((curpattern & 0x80) == 0x80) {
              go = DrawSquare(x,y,z);
              SetParent(go, x, y, z);
            }
            curpattern = (byte) (((int) curpattern << 1) & 0xff);
          }
        }

    /*GameBrain.instance.TransformCamera.SetPositionAndRotation(
             new Vector3(Parents[camerax, cameray].transform.position.x - 0.65f
                               , Parents[camerax, cameray].transform.position.y
                , Parents[camerax, cameray].transform.position.z - camerazdist)
                                , GameBrain.instance.TransformCamera.rotation);*/
  }

  public override void FixedUpdate() {
    float xmovement = 0;
    float ymovement = 0;
    float zmovement = 0;

    float speed = 8; 

    if (Input.GetKey("a"))
        xmovement -= GameBrain.instance.Speed * Time.deltaTime;
    else if(Input.GetKey("d"))
        xmovement += GameBrain.instance.Speed * Time.deltaTime;

    if(Input.GetKey("w")) 
        ymovement += GameBrain.instance.Speed * Time.deltaTime;
    else if(Input.GetKey("s"))
        ymovement -= GameBrain.instance.Speed * Time.deltaTime;

    if (Input.GetKey(KeyCode.Space))
    zmovement += 8 * Time.deltaTime;

    /*if (TransformCamera.position.z >= 6f)
      TransformCamera.SetPositionAndRotation(
           new Vector3(TransformCamera.position.x, TransformCamera.position.y
           , -10f), TransformCamera.rotation);
    else*/
    GameBrain.instance.TransformCamera.Translate(xmovement, ymovement, 
                                                                    zmovement);

  }

  protected virtual void SetParent(GameObject go, int x, int y, int z) {

    //int yArrayPos = Parents.GetLength(1) - 1;

    if (Parents[x, y] == null)
      Parents[x, y] = go;
    else
      go.transform.parent = Parents[x, y].transform;
  }
}
