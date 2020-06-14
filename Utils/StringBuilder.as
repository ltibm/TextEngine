class StringBuilder
{
	string innerString;
	StringBuilder()
	{
	}
	StringBuilder(string str)
	{
		this.Append(str);
	}
	StringBuilder@ Append(string str)
	{
		this.innerString += str;
		return @this;
	}
	StringBuilder@ AppendChar(char chr, int repeat = 1)
	{
		for(int i = 0; i < repeat; i++)
		{
			this.Append(chr);
		}
		return @this;
	}
	StringBuilder@ Clear()
	{
		this.innerString = "";
		return @this;
	}
	string ToString()
	{
		return this.innerString;
	}
	int Length
	{
		get const
		{
			return this.innerString.Length();
		}
	}
	bool IsEmpty()
	{
		return this.innerString.IsEmpty();
	}
}