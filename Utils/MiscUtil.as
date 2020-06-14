namespace MISCUTIL
{
	bool InStringArray(string key, array<string> values)
    {
		return values.find(key) >= 0;
	}
}