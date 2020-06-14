namespace TextEngine
{
	namespace Evulator
	{
		class EvulatorTypes
		{
			dictionary types;
			BaseEvulator@ get_opIndex(string key) const
			{ 
				BaseEvulator@ evulator = null;
				if(!types.get(key, @evulator))
				{
					return null;
				}
				return evulator;
			}
			void set_opIndex(string key, BaseEvulator@ evulator)
			{ 
				this.types.set(key, @evulator);
			}		

			EvulatorTypes()
			{
				
			}
			private BaseEvulator@ param;
			BaseEvulator@ Param 
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
			private BaseEvulator@ generalType;
			BaseEvulator@ GeneralType 
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
			void SetType(string name, BaseEvulator@ evulator)
			{
				@this[name] = @evulator;
			}
			BaseEvulator@ GetType(string name)
			{
				return this[name];
			}
		}

	}
}
