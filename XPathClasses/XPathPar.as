namespace TextEngine
{
	namespace XPathClasses
	{
		class XPathPar : IXPathBlockContainer, IXPathList, IXPathExpressionItems
		{
			private IXPathBlockContainer@ parent;
			IXPathBlockContainer@ Parent
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

			private XPathBlocksContainer@ xpathBlockList;
			XPathBlocksContainer@ XPathBlockList
			{
				get const
				{
					return xpathBlockList;
				}
				set
				{
					@xpathBlockList = @value;
				}
			}
			private XPathExpressionsList@ xexpressions;
			XPathExpressionsList@ XPathExpressions
			{
				get const
				{
					return xexpressions;
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
					return false;
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
			bool IsXPathPar()
			{
				return true;
			}

			bool IsBlocks()
			{
				return false;
			}

			XPathPar()
			{
				@this.XPathExpressions = XPathExpressionsList();
				@this.XPathBlockList = XPathBlocksContainer();
			}
			bool Any()
			{
				return this.XPathBlockList.Count > 0 || this.XPathExpressions.Count > 0;
			}
			bool IsOr()
			{
				return false;
			}
		}
	}
}
