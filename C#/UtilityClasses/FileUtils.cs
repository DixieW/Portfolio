public static class FileUtils
{
    public static string GetExtension(string fileName)
    {
        return Path.GetExtension(fileName)?.TrimStart('.') ?? "";
    }
}
