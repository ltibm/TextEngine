namespace TextEngine
{
	namespace XPathClasses
	{
		class XPathBlock : IXPathExpressionItems
		{
			XPathBlock()
			{
				//@this.XPathExpressions = @XPathExpressionsList();
			}
			private bool isAttributeSelector;
			bool IsAttributeSelector
			{ 
				get const
				{
					return isAttributeSelector;
				}
				set
				{
					isAttributeSelector = value;
				}					
			}
			private XPathBlockType blockType;
			XPathBlockType BlockType
			{ 
				get const
				{
					return blockType;
				}
				set
				{
					blockType = value;
				}					
			}
			private string blockName;
			string BlockName
			{
				get const
				{
					return blockName;
				}
				set
				{
					blockName = value;
				}
			}
			private XPathExpressionsList@ xexpressions = @XPathExpressionsList();
			IXPathExpressionItem@ Parent
			{
				get const
				{
					return null;
				}
				set{}
			}
			XPathExpressionsList@ XPathExpressions
			{
				get const
				{
					return @xexpressions;
				}
				set
				{
					@xexpressions = @value;
				}
			}

			bool IsSubItem
			{
				get const
				{
					return true;
				}
			}
			char ParChar
			{
				get const
				{
					return '\0';
				}
				set
				{
	
				}
			}
	

		}
	}
}