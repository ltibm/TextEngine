namespace TextEngine
{
	namespace XPathClasses
	{
		class XPathBlocksList: IXPathList
		{
			private array<XPathBlock@> inner;
			int Count
			{
				get const 
				{
					 return int(inner.length()); 
				}
			}
			XPathBlocksList()
			{
				
			}
			XPathBlock@ get_opIndex(int index) const
			{ 
				return @inner[index];
			}
			void Add(XPathBlock@ item)
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
			bool IsBlocks()
			{
				return true;
			}
			bool Any()
			{
				return this.Count > 0;
			}
			bool IsOr()
			{
				return false;
			}
		}
	}
}
