namespace TextEngine
{
	namespace Text
	{
		funcdef void OnTagHandler(TextElement@ element);
		funcdef bool OnTagPredicate(TextElement@ element);
	    class TextElementInfo
		{
			TextElementInfo()
			{
				@customData = @dictionary();
			}
			OnTagHandler@ OnTagClosed;
			OnTagHandler@ OnTagOpened;
			OnTagPredicate@ OnAutoCreating;
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
