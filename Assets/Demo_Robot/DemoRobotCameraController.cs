using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DemoRobotCameraController : MonoBehaviour
{
    private int m_curRow = 0;
    private void Awake()
    {
        UpdateRowPosition();
    }


    private void Update()
    {
        if(Input.GetKeyDown(KeyCode.DownArrow))
        {
            m_curRow++;
            UpdateRowPosition();
        }

        if(Input.GetKeyDown(KeyCode.UpArrow))
        {
            m_curRow--;
            UpdateRowPosition();
        }

        transform.Rotate(new Vector3(0, Input.GetAxis("Horizontal"), 0) * 100 * Time.deltaTime);

        float x = 0;
        if(Input.GetKey(KeyCode.Z))
        {
            x = 1;
        }

        if(Input.GetKey(KeyCode.C))
        {
            x = -1;
        }
        transform.Translate(new Vector3(x, 0, 0) * Time.deltaTime);
    }


    private void UpdateRowPosition()
    {
        if(m_curRow < 0)
        {
            m_curRow = 6;
        }

        if(m_curRow > 6)
        {
            m_curRow = 0;
        }

        Vector3 position = transform.localPosition;
        position.y = 3 - 2 * m_curRow;
        transform.localPosition = position;
    }
}
