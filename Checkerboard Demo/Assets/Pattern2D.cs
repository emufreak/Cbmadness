using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//xScale = (0.8996875)
//yScale = (0.897265625)

public class PatternParent2D : MonoBehaviour {
  private int StartWidth;

  private float XScale = 4.5f;
  private float YScale = 4.5f;

  public void DrawSquare() {
    GameObject prefab = Resources.Load("Quad2D") as GameObject;
    GameObject go = GameObject.Instantiate(prefab);
    go.transform.position = new Vector3(0, 0, 20);
    go.transform.localScale = new Vector3(XScale * 10, YScale * 10, 1);
  }

  // Start is called before the first frame update
  public void Draw(int startwidth) {
        DrawSquare();
  }
}
