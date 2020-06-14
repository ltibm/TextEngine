namespace STRINGUTIL
{
	string Trim(string input)
	{
		return TrimStart(TrimEnd(input));
	}
	string TrimStart(string input)
	{
		int start = -1;
		int ilen =  input.Length();
		for(uint i = 0; i < input.Length(); i++)
		{
			char cur = input[i];
			if(cur != '\r' && cur != '\n' && cur != '\t' && cur != ' ')
			{
				start = i;
				break;
			}
		}
		if(start == -1) return "";
		return input.SubString(start);
	}
	string TrimEnd(string input)
	{
		int end = 0;
		int ilen = input.Length();
		if(ilen == 0)
		{
			return TrimStart(input);
		}
		if(ilen <= 0) return input;
		int cnt = 0;
		for(int i = (ilen - 1);i >= 0; i--)
		{
			char cur = input[i];
			if(cur != '\r' && cur != '\n' && cur != '\t' && cur != ' ')
			{
				end = i;
				break;
			}
		}
		return input.SubString(0, end + 1);
	}
	bool HasInQuot(string item)
	{
		return item.Length() > 1 && (item.StartsWith("\"") && item.EndsWith("\"") || item.StartsWith("'") && item.EndsWith("'"));
	}
	string TrimQuot(string item)
	{
		return  item.SubString(1, int(item.Length()) - 2);
	}
}