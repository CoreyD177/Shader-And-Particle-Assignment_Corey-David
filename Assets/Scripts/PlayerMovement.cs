using UnityEngine; //Required for Unity connection
using System.Collections;

//Require a Character controller component to be attached to the game object for movement
[RequireComponent(typeof(CharacterController))]
public class PlayerMovement : MonoBehaviour
{
    #region Variables
    //GameObject components to allow us to modify position and animation
    [Header("Character Components")]
    [Tooltip("You can drag the Character Controller attached to this character here, but it will be grabbed automatically anyway")]
    public CharacterController charC;
    [Header("Speeds")]
    //Set the different speeds for the player
    public float moveSpeed = 0f;
    public float walkSpeed = 5f, runSpeed = 10f, crouchSpeed = 2.5f;
    public float jumpSpeed = 10f, gravity = 20f;
    //A Vector2 to store the X and Y position input values for movement
    private Vector2 _input;
    //A variable to store our movement direction to use for movement
    private Vector3 _moveDir;
    private Vector3 _pos;
    //GameObject to store the door we are trying to open
    private GameObject _door;
    //Raycast hit to store hitinfo
    private RaycastHit _hitInfo;
    #endregion

    void Start()
    {
        //Time may have been pause from previous return to main menu, reactivate on load
        Time.timeScale = 1;
        //Start the game with cursor locked and hidden
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
        //Retrieve the required components from the GameObject this script is attached to
        charC = GetComponent<CharacterController>();
    }

    void Update()
    {
        #region Player Input
        //If player presses pause button run the pause function
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            Pause();
        }
        //If our player is touching the ground or water we are allowed to control movement
        if (charC.isGrounded)
        {
            //Store our Y axis input in the input variable
            _input.y = Input.GetKey(KeyCode.W) ? 1 : Input.GetKey(KeyCode.S) ? -1 : 0;
            //Store our X axis input in the input variable
            _input.x = Input.GetKey(KeyCode.D) ? 1 : Input.GetKey(KeyCode.A) ? -1 : 0;
            //Set our movement speed based off whether we are pressing any of the modifier keys
            moveSpeed = Input.GetKey(KeyCode.LeftShift) ? runSpeed : Input.GetKey(KeyCode.LeftControl) ? crouchSpeed : walkSpeed;
            //Store our input movement vectors in the direction variable so we have a direction to move toward
            _moveDir = transform.TransformDirection(new Vector3(_input.x, 0, _input.y));
            //Multiply our direction by the speed of movement so we will move the appropriate distance
            _moveDir *= moveSpeed;
            //If we press the jump key add the jump value to our y position and trigger the animation
            if (Input.GetKey(KeyCode.Space))
            {
                //Create a ray to hit the doors
                Ray _doorRay = new Ray(Camera.main.ScreenToWorldPoint(Input.mousePosition), transform.forward);
                //Cast the ray
                if (Physics.Raycast(_doorRay, out _hitInfo, 10f))
                {
                    if (_hitInfo.transform.tag == "Doors")
                    {
                        StartCoroutine("OpenDoor", _hitInfo);
                    }
                    else if (_hitInfo.transform.tag == "Garage")
                    {
                        StartCoroutine("OpenGarage", _hitInfo);
                    }
                }
            }
        }
        //Allow gravity to pull us down regardless of us being on the ground or not
        _moveDir.y -= gravity * Time.deltaTime;
        //Apply our calculated movement to the character
        charC.Move(_moveDir * Time.deltaTime);
        //Make sure we can't sink lower than surface of water
        _pos = transform.position;
        transform.position = _pos;
        #endregion
    }
    public IEnumerator OpenDoor(RaycastHit hitinfo)
    {
        GameObject _door = hitinfo.collider.gameObject;
        _door.GetComponent<Collider>().enabled = false;
        float currentFloat = _door.GetComponent<Renderer>().material.GetFloat("_Amount");
        while (_door.GetComponent<Renderer>().material.GetFloat("_Amount") < 1.65f)
        {
            currentFloat += 0.02f;
            _door.GetComponent<Renderer>().material.SetFloat("_Amount", currentFloat);
            yield return new WaitForSecondsRealtime(0.05f);
        }
        yield return new WaitForSecondsRealtime(3f);
        while (_door.GetComponent<Renderer>().material.GetFloat("_Amount") > 0.9f)
        {
            currentFloat -= 0.02f;
            _door.GetComponent<Renderer>().material.SetFloat("_Amount", currentFloat);
            yield return new WaitForSecondsRealtime(0.05f);
        }
        _door.GetComponent<Collider>().enabled = true;
    }
    public IEnumerator OpenGarage(RaycastHit hitinfo)
    {
        GameObject _door = hitinfo.collider.gameObject;
        _door.GetComponent<Collider>().enabled = false;
        float currentFloat = _door.GetComponent<Renderer>().material.GetFloat("_Amount");
        while (_door.GetComponent<Renderer>().material.GetFloat("_Amount") < 0.7f)
        {
            currentFloat += 0.05f;
            _door.GetComponent<Renderer>().material.SetFloat("_Amount", currentFloat);
            yield return new WaitForSecondsRealtime(0.05f);
        }
        yield return new WaitForSecondsRealtime(3f);
        while (_door.GetComponent<Renderer>().material.GetFloat("_Amount") > 0.15f)
        {
            currentFloat -= 0.05f;
            _door.GetComponent<Renderer>().material.SetFloat("_Amount", currentFloat);
            yield return new WaitForSecondsRealtime(0.05f);
        }
        _door.GetComponent<Collider>().enabled = true;
    }
    #region Pause
    public void Pause()
    {
        //If game is running, pause the timescale, reactivate cursor and enable pause menu
        if (Time.timeScale == 1)
        {
            Time.timeScale = 0;
            Cursor.lockState = CursorLockMode.None;
            Cursor.visible = true;
        }
        //Else hide and lock cursor and resume timescale
        else
        {
            Time.timeScale = 1;
            Cursor.lockState = CursorLockMode.Locked;
            Cursor.visible = false;
        }
    }
    #endregion
    #region Trigger
    private void OnTriggerEnter(Collider other)
    {
        //If we enter a trigger turn the light on
        other.gameObject.GetComponent<Light>().enabled = true;
    }
    private void OnTriggerExit(Collider other)
    {
        //Turn light off when we leave trigger
        other.gameObject.GetComponent<Light>().enabled = false;
    }
    #endregion
}