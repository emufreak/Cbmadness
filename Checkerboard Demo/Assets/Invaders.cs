using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Invaders : PatternFromBitmap {
  protected override void SetParent(GameObject go, int x, int y, int z) {
    if (Parents[z, 0] == null)
      Parents[z, 0] = go;
    else
      go.transform.parent = Parents[z, 0].transform;
  }

  public void Move(Vector3[] vectors = null) {
    for (int z = 0; z < 4; z++) {
      if (Parents[z, 0].transform.position.x < -8 * Scale + (Width / 2 * -1) * Scale)
        vectors[z].x += 12 * Scale;
      else if (Parents[z, 0].transform.position.x > 8 * Scale + (Width / 2 * -1) * Scale)
        vectors[z].x -= 12 * Scale;

      Parents[z, 0].transform.Translate(vectors[z].x, 
                 vectors[z].y, vectors[z].z);
    }
  }
}