namespace TextEngine
{
	namespace Text
	{
		class TextElementInfos
		{
			private dictionary@ inner;
			private TextElementInfo@ lastElement;
			private bool autoInitialize;
			TextElementInfo@ Default;
			bool AutoInitialize
			{
				get const
				{
					return this.autoInitialize;
				}
				set
				{
					this.autoInitialize = value;
				}
			}
			TextElementInfos()
			{
				this.AutoInitialize = true;
				@this.Default = @TextElementInfo();
				@this.inner = @dictionary();
			}
			TextElementInfo@ get_opIndex(string name)
			{ 
				if(name.IsEmpty() || name == "#text") return null;
                if(@lastElement !is null && name.ToLowercase() == lastElement.ElementName)
                {
                    return lastElement;
                }
                TextElementInfo@ info = null;
				this.inner.get(name.ToLowercase(), @info);
                if(@info is null)
                {
                    if(this.AutoInitialize)
                    {
                        @info = @TextElementInfo();
						info.ElementName = name.ToLowercase();
						this.inner.set(info.ElementName, @info);
                    }
                }
                @lastElement = @info;
                return info;
			}
			void set_opIndex(string key, TextElementInfo@ value)
			{ 
				if(@value is null) return;
				TextElementInfo@ info = null;
				this.inner.get(key.ToLowercase(), @info);
				if(info !is null && @info == @this.lastElement)
				{
					@this.lastElement = null;
				}
				value.ElementName = key.ToLowercase();
				this.inner.set(key, @value);
			}		
			void Clear()
			{
				@this.lastElement = null;
				this.inner.deleteAll();
			}
			bool HasTagInfo(string tagName)
			{
				return this.inner.exists(tagName.ToLowercase());
			}
			int GetElementFlags(string tagName)
			{
				if (!this.HasTagInfo(tagName)) return TEF_NONE;
				return this[tagName].Flags;
			}
		}
	}
}
