namespace TextEngine
{
	class PropObject
	{
		Object@ Value;
		int PropType = PT_Empty;
		string StrIndex;
		int IntIndex;
		dictionary@ DictionaryData;
		Objects@ ArrayData;
	}
	enum PropTypeEnum
	{
		PT_Empty = 0,
		PT_Property,
		PT_Dictionary,
		PT_KeyValues,
		PT_Indis
	}
}
