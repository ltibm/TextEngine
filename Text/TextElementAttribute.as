namespace TextEngine
{
	namespace Text
	{
		class TextElementAttribute
		{
			private string name;
			private string mvalue;
			string Name
			{
				get const
				{
					return name;
				}
				set
				{
					name = value;
				}
			}
			string Value 
			{ 
				get const
				{
					return mvalue;
				}
				set
				{	
					mvalue = value;
				}				
			}
		}
	}
}
