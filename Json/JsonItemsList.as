namespace TextEngine
{
	namespace Json
	{
		class JsonItemsList
		{
			private array<JsonItem@> inner;
			int Count
			{
				get const 
				{
					 return int(inner.length()); 
				}
			}
			JsonItemsList()
			{
				
			}
			JsonItem@ get_opIndex(int index) const
			{ 
				return @inner[index];
			}
			bool Any()
			{
				return this.Count > 0;
			}
			JsonItem@ First()
			{
				if(this.Count > 0)
				{
					return @this[0];
				}
				return null;
			}
			JsonItem@ Last()
			{
				if(this.Count > 0)
				{
					return @this[this.Count - 1];
				}
				return null;
			}
			int GetAttributeIndexByName(string name)
			{
				for(int i = 0; i < this.Count; i++)
				{
					JsonItem@ cur = this[i];
					if(cur.Name == name) return i;
				}
				return -1;
			}
			void Add(JsonItem@ item)
			{
				this.inner.insertLast(@item);
			}
			void AddRange(JsonItemsList@ elements)
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
			bool Contains(JsonItem@ item)
			{
				for(int i = 0; i < this.Count; i++)
				{
					if(@this[i] == @item) return true;
				}
				return false;
			}
			int GetItemIndex(JsonItem@ item)
			{
				for(int i = 0; i < this.Count; i++)
				{
					if(@this[i] == @item) return i;
				}
				return -1;
			}
			bool Remove(JsonItem@ item)
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
