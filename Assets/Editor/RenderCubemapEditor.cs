using UnityEditor;
using UnityEngine;

public class RenderCubemapEditor : MonoBehaviour
{
    [MenuItem("GameObject/Cubemaps/Render Cubemap from the Position", false, 10)]
    private static void CreateCustomGameObject()
    {
        GameObject activeGameObject = Selection.activeGameObject;

        if (activeGameObject == null)
        {
            return;
        }

        activeGameObject.SetActive(false);

        string path = EditorUtility.SaveFilePanelInProject( "Save Cubemap", "CustomCubemap", "cubemap", "Specify where to save the cubemap." );

        if( path.Length > 0 )
        {
            GameObject cubemapCameraObj = new GameObject("CubemapCamera");
            cubemapCameraObj.transform.position = activeGameObject.transform.position;
            cubemapCameraObj.transform.rotation = Quaternion.identity;

            Camera cubemapCamera = cubemapCameraObj.AddComponent<Camera>();
            Cubemap cubemap = CubemapGenerator.CreateCubemap(cubemapCamera);

            DestroyImmediate(cubemapCameraObj);

            AssetDatabase.CreateAsset(cubemap, path );

            Selection.activeObject = cubemap;
        }

        activeGameObject.SetActive(true);
    }
}
