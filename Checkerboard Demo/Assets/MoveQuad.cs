using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveQuad : MonoBehaviour
{
  public Transform RecentTranform;
  public float zMovement;

  // Start is called before the first frame update
  void Start() {
  }

  // Update is called once per frame
  void FixedUpdate() {

    if (RecentTranform.position.z <= GameBrain.instance.zMin
                                 || RecentTranform.position.z >= GameBrain.instance.zMax)
      zMovement *= -1;

    RecentTranform.Translate(0, 0, zMovement * Time.deltaTime);

  }
}
