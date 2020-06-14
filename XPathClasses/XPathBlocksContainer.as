namespace TextEngine
{
	namespace XPathClasses
	{
		class XPathBlocksContainer
		{
			private array<IXPathList@> inner;
			int Count
			{
				get const 
				{
					 return int(inner.length()); 
				}
			}
			XPathBlocksContainer()
			{
				
			}
			IXPathList@ get_opIndex(int index) const
			{ 
				return @inner[index];
			}
			void Add(IXPathList@item)
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
			IXPathList@ Last()
			{
				if (this.Count == 0) return null;
				return this[this.Count - 1];
			}
		}
	}
}
