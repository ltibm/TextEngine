namespace TextEngine
{
	namespace XPathClasses
	{
		class XPathOrItem : IXPathBlockContainer, IXPathList
		{
			XPathBlocksContainer@ XPathBlockList
			{
				get const
				{
					return null;
				}
				set
				{

				}
			}
			IXPathBlockContainer@ Parent
			{
				get const
				{
					return null;
				}
				set
				{

				}
			}
			bool Any()
			{
				return true;
			}
			bool IsBlocks()
			{
				return false;
			}
			bool IsOr()
			{
				return true;
			}
			bool IsXPathPar()
			{
				return false;
			}
		}
	}
}
