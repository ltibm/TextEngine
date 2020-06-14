namespace TextEngine
{
	namespace ParDecoder
	{
	    class InnerItem
		{
			InnerItem()
			{
			}
			private Object@ objvalue;
			Object@ Value
			{
				get const
				{
					return objvalue;
				}
				set
				{
					@objvalue = @value;
				}
			}
			private char quote;
			char Quote
			{
				get const
				{
					return quote;
				}
				set
				{
					quote = value;
				}
			}
			private bool isOperator;
			bool IsOperator
			{
				get const
				{
					return isOperator;
				}
				set
				{
					isOperator = value;
				}
			}
			private InnerTypeEnum innerType;
			InnerTypeEnum InnerType
			{
				get const
				{
					return innerType;
				}
				set
				{
					innerType = value;
				}
			}
			private InnerItemsList@ innerItems;
			InnerItemsList@ InnerItems
			{
				get const
				{
					return innerItems;
				}
				set
				{
					@innerItems = @value;
				}
			}
			private InnerItem@ parent;
			InnerItem@ Parent
			{
				get const
				{
					return parent;
				}
				set
				{
					@parent = @value;
				}
			}
			bool IsObject()
			{
				return false;
			}
			bool IsParItem()
			{
				return false;
			}
			bool IsArray()
			{
				return this.InnerItems !is null;
			}
		}
	}
}
