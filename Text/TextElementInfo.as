namespace TextEngine
{
	namespace Text
	{
	    class TextElementInfo
		{
			TextElementInfo()
			{
				@customData = @dictionary();
			}
			private string elementName;
			string ElementName
			{
				get const { return elementName; }
				set { 
					elementName = value; 
				}
			}
			private int flags;
			int Flags
			{
				get const { return flags; }
				set { 
					flags = value; 
				}
			}
			private dictionary@ customData;
			dictionary@ CustomData
			{
				get const { return @customData; }
				set { 
					@customData = @value; 
				}
			}
		}
	}
}
