namespace TextEngine
{
	namespace XPathClasses
	{
	    interface IXPathExpressionItem 
		{
			bool IsSubItem { get const; }
			char ParChar { get const; set; }
		}
	}
}