namespace TextEngine
{
	namespace Text
	{
		class TextElementAttributesList
		{
			TextElementAttributesList@ Clone()
			{
				TextElementAttributesList@ elemAttr = TextElementAttributesList();
				for(int i = 0; i < this.Count; i++)
				{
					elemAttr.Add(@this[i]);
				}
				return @elemAttr;
			}
			private array<TextElementAttribute@> inner;
			int Count
			{
				get const 
				{
					 return int(inner.length()); 
				}
			}
			TextElementAttributesList()
			{
				
			}
			TextElementAttribute@ get_opIndex(int index) const
			{ 
				return @inner[index];
			}
			TextElementAttribute@ GetByName(string name)
			{
				int index = this.GetAttributeIndexByName(name);
				if(index == -1) return @null;
				return @inner[index];
			}
			int GetAttributeIndexByName(string name)
			{
				for(int i = 0; i < this.Count; i++)
				{
					TextElementAttribute@ cur = this[i];
					if(cur.Name == name) return i;
				}
				return -1;
			}
			
			bool HasAttribute(string attrib, bool casesensivite = false)
			{
				string lower = attrib;
				if(casesensivite)
				{
					lower = lower.ToLowercase();
				}
				for (int i = 0; i < this.Count; i++)
				{
					TextElementAttribute@ attr = @this[i];
					if(casesensivite)
					{
						if (attr.Name.ToLowercase() == lower) return true;

					}
					else
					{
						if (attr.Name == lower) return true;

					}
				}
				return false;
			}
			TextElementAttribute@ FirstAttribute
			{
				get const
				{
					if (this.Count == 0) return null;
					return @this[0];
				}
			}
			void Add(TextElementAttribute@ item)
			{
				this.inner.insertLast(@item);
			}

			void Clear()
			{
				this.inner.resize(0);
			}
			bool RemoveByName(string name)
			{
				int index  = this.GetAttributeIndexByName(name);
				if(index < 0) return false;
				this.RemoveAt(index);
				return true;
			}
			bool Remove(TextElementAttribute@ item)
			{
				return false;
			}
			void RemoveAt(int index)
			{
				this.inner.removeAt(index);
			}
			string GetAttribute(string name, string defvalue = null)
			{
				TextElementAttribute@ item = @this.GetByName(name);
				if (item !is null) return item.Value;
				return defvalue;
			}
			void SetAttribute(string name, string value)
			{
				TextElementAttribute@ item = @this.GetByName(name);
				if (item is null)
				{
					@item = TextElementAttribute();
					item.Name = name;
					this.Add(item);
				}
				item.Value = value;
			}
		}
	}
}
