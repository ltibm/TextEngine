namespace TextEngine
{
	namespace Text
	{
        bool CompareTextElements(const TextElement@ &in a,const TextElement@ & in b)
        {
            if(a.Depth == b.Depth)
            {
                if(a.Index > b.Index)
                {
                    return false;
                }
                else if(b.Index > a.Index)
                {
                    return true;
                }
                return false;
            }

            if(a.Depth > b.Depth)
            {
                int depthfark = a.Depth - b.Depth;
                const TextElement@ next = a;
                for (int i = 0; i < depthfark; i++)
                {
                    @next = @next.Parent;
                }
                return CompareTextElements(@next, @b);
            }
            else
            {
				int depthfark = b.Depth - a.Depth;
				const TextElement@ next = b;
                for (int i = 0; i < depthfark; i++)
                {
                    @next = @next.Parent;
                }
                return CompareTextElements(@a, @next);
            }
        }
		class TextElementsList
		{
			private array<TextElement@> inner;
			int Count
			{
				get const 
				{
					 return int(inner.length()); 
				}
			}
			TextElementsList()
			{
				
			}
			TextElement@ get_opIndex(int index) const
			{ 
				if(index == -1) return null;
				return @inner[index];
			}
			bool Any()
			{
				return this.Count > 0;
			}
			TextElement@ First()
			{
				if(this.Count > 0)
				{
					return @this[0];
				}
				return null;
			}
			TextElement@ Last()
			{
				if(this.Count > 0)
				{
					return @this[this.Count - 1];
				}
				return null;
			}
			//TextElement@ get_opIndex(string name) const
			//{ 
				//int index = this.GetAttributeIndexByName(name);
				//if(index == -1) return @null;
				//return @inner[index];
			//}
			int GetAttributeIndexByName(string name)
			{
				for(int i = 0; i < this.Count; i++)
				{
					TextElement@ cur = this[i];
					if(cur.ElemName == name) return i;
				}
				return -1;
			}
			void Add(TextElement@ item)
			{
				item.Index = this.Count;
				this.inner.insertLast(@item);
			}
			void AddRange(TextElementsList@ elements)
			{
				for(int i = 0; i < elements.Count; i++)
				{
					this.Add(@elements[i]);
				}
			}
			void Insert(int index, TextElement@ item)
			{
				inner.insertAt(index, @item);
			}
			void InsertRange(int index, TextElementsList@ elements)
			{
				inner.insertAt(index, elements.inner);
			}
			void Clear()
			{
				this.inner.resize(0);
			}
			bool Contains(TextElement@ item)
			{
				for(int i = 0; i < this.Count; i++)
				{
					if(@this[i] == @item) return true;
				}
				return false;
			}
			int GetItemIndex(const TextElement@ item)
			{
				for(int i = 0; i < this.Count; i++)
				{
					if(@this[i] == @item) return i;
				}
				return -1;
			}
			bool Remove(TextElement@ item)
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
			TextElementsList@ FindByXPath(TextEngine::XPathClasses::XPathBlock@ xblock)
			{
				TextElementsList@ elements = TextElementsList();
				for (int j = 0; j < this.Count; j++)
				{
					TextElement@ elem = this[j];
					TextElementsList@ nextelems = elem.FindByXPath(@xblock);
					for (int k = 0; k < nextelems.Count; k++)
					{
						if (elements.Contains(@nextelems[k])) continue;
						elements.Add(@nextelems[k]);
					}
				}
				return elements;
			}
			void SortItems()
			{
				if(this.Count > 1)
				{
					inner.sort(CompareTextElements);
				}
			}
		}
	}
}
