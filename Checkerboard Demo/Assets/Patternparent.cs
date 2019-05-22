using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class PatternParent3D {

  public float Speed = 16;
  protected int Height;
  protected int Width;
  protected float Scale = 30;

  // Update is called once per frame
  public virtual void FixedUpdate() {        
  }

  public Color[] colors =  { new Color(255,0,0), new Color(0,255,0)
               , new Color(0,0,255), new Color(255,255,0), new Color(0,255,255)
               , new Color(255,0,255), new Color(255,255,255)
               , new Color(255,128,0),
               new Color(255,0,0), new Color(0,255,0)
               , new Color(0,0,255), new Color(255,255,0), new Color(0,255,255)
               , new Color(255,0,255), new Color(255,255,255)
               , new Color(255,128,0)
  };

  protected GameObject DrawSquare(int x, int y, int z) {

    if (Height == 0) {
      Console.WriteLine("Height must be set before calling Drawsquare");
      return null;
    }

      GameObject prefab = Resources.Load("Quad") as GameObject;
      GameObject go = GameObject.Instantiate(prefab);
      go.transform.position = new Vector3(((Width / 2 * -1) + x) * Scale,
                           (Height / 2 + y * -1) * Scale, z * 2);
    go.GetComponent<Renderer>().material.color = colors[z];
      return go;

  }

}