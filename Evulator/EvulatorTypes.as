namespace TextEngine
{
	namespace Evulator
	{
		funcdef BaseEvulator@ ET_Instance();
		class EvulatorTypes
		{
			dictionary types;
			ET_Instance@ get_opIndex(string key) const
			{ 
				ET_Instance@ evulator = null;
				if(key.IsEmpty()) return evulator;
				if(!types.get(key, @evulator))
				{
					return null;
				}
				return evulator;
			}
			void set_opIndex(string key, ET_Instance@ evulator)
			{ 
				this.types.set(key, @evulator);
			}		

			EvulatorTypes()
			{
				
			}
			private ET_Instance@ param;
			ET_Instance@ Param 
			{ 
				get const
				{
					return param;
				}
				set
				{
					@param = @value;
				}
			}
			private ET_Instance@ generalType;
			ET_Instance@ GeneralType 
			{ 
				get const
				{
					return generalType;
				}
				set
				{
					@generalType = @value;
				}
			}
			private ET_Instance@ text;
			ET_Instance@ Text 
			{ 
				get const
				{
					return text;
				}
				set
				{
					@text = @value;
				}
			}
			void SetType(string name, ET_Instance@ evulator)
			{
				@this[name] = @evulator;
			}
			ET_Instance@ GetType(string name)
			{
				return this[name];
			}
		}

	}
}
