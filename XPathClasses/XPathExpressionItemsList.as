namespace TextEngine
{
	namespace XPathClasses
	{
		class XPathExpressionItemsList
		{
			private array<IXPathExpressionItem@> inner;
			int Count
			{
				get const 
				{
					 return int(inner.length()); 
				}
			}
			XPathExpressionItemsList()
			{
				
			}
			IXPathExpressionItem@ get_opIndex(int index) const
			{ 
				return @inner[index];
			}
			void Add(IXPathExpressionItem@ item)
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
