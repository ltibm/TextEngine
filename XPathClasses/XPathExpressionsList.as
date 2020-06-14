namespace TextEngine
{
	namespace XPathClasses
	{
		class XPathExpressionsList
		{
			private array<XPathExpression@> inner;
			int Count
			{
				get const 
				{
					 return int(inner.length()); 
				}
			}
			XPathExpressionsList()
			{
				
			}
			XPathExpression@ get_opIndex(int index) const
			{ 
				return @inner[index];
			}
			void Add(XPathExpression@ item)
			{
				this.inner.insertLast(@item);
			}
			void Clear()
			{
				this.inner.resize(0);
			}
			void RemoveAt(int index)
			{
				this.inner.removeAt(index);
			}
		}
	}
}
