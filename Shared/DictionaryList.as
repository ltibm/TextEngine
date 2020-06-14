
	class DictionaryList
	{
		private array<dictionary@> inner;
		int Count
		{
			get const 
			{
				 return int(inner.length()); 
			}
		}
		DictionaryList()
		{
			
		}
		dictionary@ get_opIndex(int index) const
		{ 
			return @inner[index];
		}
		void Add(dictionary@ item)
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
		bool Remove(dictionary@ item)
		{
			int indx = GetIndex(@item);
			if(indx  < 0) return false;
			this.RemoveAt(indx);
			return true;
		}
		int GetIndex(dictionary@ item)
		{
			for(int i = 0;  i < this.Count; i++)
			{
				if(@this[i] == @item)
				{
					return i;
				}
			}
			return - 1;
		}
		void AddRange(DictionaryList@ objects)
		{
			for(int i = 0;  i < objects.Count; i++)
			{
				this.Add(@objects[i]);
			}
		}
		dictionary@ GetDictionaryIfKeyExists(string key)
		{
			for(int i = this.Count - 1; i >= 0; i--)
			{
				if(this[i].exists(key))
				{
					return @this[i];
				}
			}
			return null;
		}
	}