using UnityEngine;

public class CubemapGenerator
{
    public static Cubemap CreateCubemap(Camera camera)
    {
        if (camera == null)
        {
            return null;
        }

        Cubemap cubemap = new Cubemap(512, TextureFormat.ARGB32, false);
        camera.RenderToCubemap(cubemap);

        return cubemap;
    }
}
