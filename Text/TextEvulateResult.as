namespace TextEngine
{
	namespace Text
	{
		enum TextEvulateResultEnum
		{        
			EVULATE_NOACTION = 0,
			EVULATE_TEXT = 1,
			EVULATE_CONTINUE = 2,
			EVULATE_RETURN = 3,
			EVULATE_DEPTHSCAN = 4,
			EVULATE_BREAK = 5
		}
		class TextEvulateResult
		{
			private string textContent;
			private string mvalue;
			private int start;
			private int end;
			private TextEvulateResultEnum result;	
			TextEvulateResult()
			{
				this.Result = EVULATE_TEXT;
			}
			string TextContent
			{
				get const
				{
					return textContent;
				}
				set
				{
					textContent = value;
				}
			}
			int Start 
			{ 
				get const
				{
					return start;
				}
				set
				{	
					start = value;
				}				
			}			
			int End 
			{ 
				get const
				{
					return end;
				}
				set
				{	
					end = value;
				}				
			}			
			TextEvulateResultEnum Result 
			{ 
				get const
				{
					return result;
				}
				set
				{	
					result = value;
				}				
			}
		}
	}
}
