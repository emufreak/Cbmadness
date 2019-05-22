using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraMovement : MonoBehaviour
{
  public Transform TransformCamera;

  // Start is called before the first frame update
  void Start() {
        
  }

  // Update is called once per frame
  void FixedUpdate() {

    /*float xmovement = 0;
    float ymovement = 0;
    float zmovement = 0;

    float speed = 8;*/

    /*if (Input.GetKey("a"))
        xmovement -= GameBrain.instance.Speed * Time.deltaTime;
    else if(Input.GetKey("d"))
        xmovement += GameBrain.instance.Speed * Time.deltaTime;

    if(Input.GetKey("w")) 
        ymovement += GameBrain.instance.Speed * Time.deltaTime;
    else if(Input.GetKey("s"))
        ymovement -= GameBrain.instance.Speed * Time.deltaTime;

    if (Input.GetKey(KeyCode.Space))*/
      //zmovement += 8 * Time.deltaTime;

    /*if (TransformCamera.position.z >= 6f)
      TransformCamera.SetPositionAndRotation(
           new Vector3(TransformCamera.position.x, TransformCamera.position.y
           , -10f), TransformCamera.rotation);
    else*/
      //TransformCamera.Translate(xmovement, ymovement, zmovement);

  }
}
