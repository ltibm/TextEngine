namespace TextEngine
{
	
	namespace XPathClasses
	{
		funcdef Object@ XPathFunctionHandler(XPathFunctions@ baseitem, Objects@ parameters);
		class XPathFunctionItem
		{
			XPathFunctionItem()
			{
				
			}
			XPathFunctionItem(string name, XPathFunctionHandler@ handler)
			{
				this.FunctionName = name;
				@this.FunctionHandler = @handler;
			}
			private string functionName;
			string FunctionName
			{ 
				get const
				{
					return functionName;
				}
				set
				{
					functionName = value;
				}
			}		
			private XPathFunctionHandler@ functionHandler;
			XPathFunctionHandler@ FunctionHandler 
			{ 
				get const
				{
					return @functionHandler;
				}
				set
				{
					@functionHandler = @value;
				}
			}				
		}
		class XPathFunctions
		{
			private array<XPathFunctionItem@> functions;
			private TextEngine::Text::TextElement@ baseItem;
			TextEngine::Text::TextElement@ BaseItem 
			{ 
				get const
				{
					return @baseItem;
				}
				set
				{
					@baseItem = @value;
				}
			}
			private int totalItems;
			int TotalItems 
			{ 
				get const
				{
					return totalItems;
				}
				set
				{
					totalItems = value;
				}
			}
			private int itemPosition;
			int ItemPosition 
			{ 
				get const
				{
					return itemPosition;
				}
				set
				{
					itemPosition = value;
				}
			}
			void AddFunction(string name, XPathFunctionHandler@ handler)
			{
				functions.insertLast(@XPathFunctionItem(name, @handler));
			}
			XPathFunctionItem@ GetFunctionByName(string callname)
			{

				for (uint i = 0; i < functions.length(); i++)
				{
					XPathFunctionItem@ function = @functions[i];
					if(function.FunctionName == callname)
					{
						return @function;
					}
				}
				return null;
			}
		}
	}
}
