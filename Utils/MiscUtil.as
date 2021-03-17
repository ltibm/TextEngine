namespace MISCUTIL
{
	bool InStringArray(string key, array<string> values, bool ci = true)
    {
		if(ci) key = key.ToLowercase();
		return values.find(key) >= 0;
	}
	string GetDirName(string path)
	{
		if (path.IsEmpty()) return "";
		uint index = path.FindLastOf("/\\");
		if (index == String::INVALID_INDEX || index == 0 || path.Length() == 1) return "";
		return path.SubString(0, index); 
	}
}