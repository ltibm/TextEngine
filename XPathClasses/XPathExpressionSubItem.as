namespace TextEngine
{
	namespace XPathClasses
	{
		class XPathExpressionSubItem : IXPathExpressionItems
		{
			XPathExpressionSubItem()
			{
				@this.XPathExpressions = @XPathExpressionsList();
				ParChar = '(';
			}
			private XPathExpressionsList@ xPathExpressions;
			XPathExpressionsList@ XPathExpressions 
			{ 
				get const
				{
					return @xPathExpressions;
				}
				set
				{
					@xPathExpressions = @value;
				}			
			}
			bool IsSubItem
			{
				get const
				{
					return true;
				}
			}
			private char parChar;
			char ParChar 
			{ 
				get const
				{
					return parChar;
				}
				set
				{
					parChar = value;
				}			
			}
			private IXPathExpressionItem@ parent;
			IXPathExpressionItem@ Parent
			{
				get const
				{
					return @parent;
				}
				set
				{
					@parent = null;
				}
			}
		}
	}
}
