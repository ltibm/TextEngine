namespace TextEngine
{
	namespace Evulator
	{
		class EvulatorOptions
		{
		    private dictionary@ p_otherOptions;
			dictionary@ OtherOptions
			{
				get
				{
					return @this.p_otherOptions;
				}
			}
			int Max_For_Loop;
			int Max_DoWhile_Loop;
			EvulatorOptions()
			{
				@this.p_otherOptions = @dictionary();
			}
			any@ GetOption(string name, any@ defaultV = null)
			{
				any@ val = null;
				if (this.OtherOptions.get(name, @val)) return val;
				return defaultV;
			}
			void SetOptions(string name, any@ value)
			{
				this.OtherOptions.set(name, @value);
			}
		}
		
	}
}