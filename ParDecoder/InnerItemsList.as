namespace TextEngine
{
	namespace ParDecoder
	{
		class InnerItemsList
		{
			private array<InnerItem@> inner;
			int Count
			{
				get const 
				{
					 return int(inner.length()); 
				}
			}
			InnerItemsList()
			{
				
			}
			InnerItem@ get_opIndex(int index) const
			{ 
				return @inner[index];
			}
			bool Any()
			{
				return this.Count > 0;
			}
			InnerItem@ First()
			{
				if(this.Count > 0)
				{
					return @this[0];
				}
				return null;
			}
			InnerItem@ Last()
			{
				if(this.Count > 0)
				{
					return @this[this.Count - 1];
				}
				return null;
			}
			void Add(InnerItem@ item)
			{
				this.inner.insertLast(@item);
			}
			void AddRange(InnerItemsList@ elements)
			{
				for(int i = 0; i < elements.Count; i++)
				{
					this.Add(@elements[i]);
				}
			}
			void Clear()
			{
				this.inner.resize(0);
			}
			bool Contains(InnerItem@ item)
			{
				for(int i = 0; i < this.Count; i++)
				{
					if(@this[i] == @item) return true;
				}
				return false;
			}
			int GetItemIndex(InnerItem@ item)
			{
				for(int i = 0; i < this.Count; i++)
				{
					if(@this[i] == @item) return i;
				}
				return -1;
			}
			bool Remove(InnerItem@ item)
			{
				int index  = this.GetItemIndex(@item);
				if(index < 0) return false;
				this.RemoveAt(index);
				return true;
			}
			void RemoveAt(int index)
			{
				this.inner.removeAt(index);
			}
		}
	}
}
