public static class ListUtils
{
    public static bool AreEqual<T>(List<T> list1, List<T> list2)
    {
        if (list1.Count != list2.Count)
        {
            return false;
        }

        Dictionary<T, int> counts = new Dictionary<T, int>();

        foreach (T item in list1)
        {
            if (!counts.ContainsKey(item))
            {
                counts[item] = 0;
            }
            counts[item]++;
        }

        foreach (T item in list2)
        {
            if (!counts.ContainsKey(item))
            {
                return false;
            }

            counts[item]--;
            if (counts[item] < 0)
            {
                return false;
            }
        }

        return true;
    }
}
