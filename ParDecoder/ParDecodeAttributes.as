namespace TextEngine
{
	namespace ParDecoder
	{
		
		class ParDecodeAttributes
		{
			dictionary@ GlobalFunctions;
			private bool surpressError;
			bool SurpressError 
			{ 
				get const
				{
					return surpressError;
				}					
				set
				{
					surpressError = value;
				}
			}
			private int flags;
		    int Flags
			{
				get
				{
					return this.flags;
				}
				set
				{
					this.flags = value;
				}
			}
			int AssignReturnType;
			ParDecodeAttributes()
			{
				this.Initialise();

			}
			void Initialise()
			{
				@this.GlobalFunctions = @dictionary();
				this.AssignReturnType = PIART_RETRUN_BOOL;
				this.Flags = PDF_AllowMethodCall | PDF_AllowSubMemberAccess | PDF_AllowArrayAccess;
			}
		}	
	}
}
