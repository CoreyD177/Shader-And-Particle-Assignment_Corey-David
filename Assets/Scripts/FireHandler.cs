using UnityEngine;

public class FireHandler : MonoBehaviour
{
    public GameObject player;

    private void Start()
    {
        if (player == null)
        {
            player = GameObject.Find("Player");
        }
    }
    // Update is called once per frame
    void Update()
    {
        transform.LookAt(player.transform.position);
    }
}
