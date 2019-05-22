using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Greetings : PatternFromBitmap
{
  protected float ZTarget;

  public void Draw(byte[][] pattern, int cols, int height, int width, 
                                       int camerax, int cameray, int zdistance,
                                 float distancechange = 0.2f, int ztarget = 81,
                                                        float maxdistance = 30) {
    ZTarget = ztarget;
    base.Draw(pattern, cols, height, width, camerax, cameray, zdistance, 
                                                   distancechange, maxdistance);
  }

  public override void FixedUpdate()
  {
    if (Parents[0, 0].transform.position.z <= ZTarget)
      MoveSquares();
    MoveCamera();
  }

  void MoveSquares() {
    for (int x = 0; x < Parents.GetLength(0); x++)
      for (int y = 0; y < Parents.GetLength(1); y++)
        if (Parents[x, y] != null)
        {
          float yMovement =
                     Distancechange * (Height + 2 * y * -1);
          float xMovement =
                      Distancechange * (Width * -1 + 2 * x);
          Parents[x, y].transform.Translate(xMovement * Speed * Time.deltaTime
                 , yMovement * Speed * Time.deltaTime, Speed * Time.deltaTime);
        }
  }

  void MoveCamera()
  {
    float zmCamera = Speed / 2 * Time.deltaTime;
    float xmCamera = Parents[62, 17].transform.position.x
                               - GameBrain.instance.TransformCamera.position.x - 0.65f;
    float ymCamera = Parents[62, 17].transform.position.y
                               - GameBrain.instance.TransformCamera.position.y;

    GameBrain.instance.TransformCamera.Translate(xmCamera, ymCamera, zmCamera);
  }
}
