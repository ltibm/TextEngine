namespace TextEngine
{
	namespace XPathClasses
	{
	    interface IXPathBlockContainer 
		{
			bool IsXPathPar();
			XPathBlocksContainer@ XPathBlockList { get const; set; }
			IXPathBlockContainer@ Parent { get const; set; }
		}
	}
}