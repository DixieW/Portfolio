public static class RandomUtils
{
    private static readonly System.Random rng = new System.Random();

    public static string RandomString(int length)
    {
        const string chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        char[] buffer = new char[length];
        for (int i = 0; i < length; i++)
        {
            buffer[i] = chars[rng.Next(chars.Length)];
        }
        return new string(buffer);
    }
}
