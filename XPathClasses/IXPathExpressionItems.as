namespace TextEngine
{
	namespace XPathClasses
	{
	    interface IXPathExpressionItems : IXPathExpressionItem
		{
			  XPathExpressionsList@ XPathExpressions { get const; set; }
		}
	}
}