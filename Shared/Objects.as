
	class Objects
	{
		private array<Object@> inner;
		int Count
		{
			get const 
			{
				 return int(inner.length()); 
			}
		}
		Objects()
		{
			
		}
		Object@ get_opIndex(int index) const
		{ 
			return @inner[index];
		}
		void set_opIndex(int index, Object@ value) 
		{ 
			@inner[index] = @value;
		}
		void Add(Object@ item)
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
		void AddRange(Objects@ objects)
		{
			for(int i = 0;  i < objects.Count; i++)
			{
				this.Add(@objects[i]);
			}
		}
	}