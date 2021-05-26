namespace TextEngine
{
	namespace ParDecoder
	{
		enum ParPropRestrictedType
		{
			PRT_RESTRICT_GET = 1 << 0,
			PRT_RESTRICT_SET = 1 << 1,
			PRT_RESTRICT_ALL = PRT_RESTRICT_GET | PRT_RESTRICT_SET
		}
		funcdef bool OnPropertyAccessHandler(ParProperty@);
		class ParDecodeAttributes
		{
			dictionary@ GlobalFunctions;
			dictionary@ RestrictedProperties;
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
			OnPropertyAccessHandler@ OnPropertyAccess;
			ParTracer@ _tracing;
			ParTracer@ Tracing
			{
				get
				{
					return @this._tracing;
				}
			}
			ParDecodeAttributes()
			{
				this.Initialise();

			}
			void Initialise()
			{
				@this.GlobalFunctions = @dictionary();
				this.AssignReturnType = PIART_RETRUN_BOOL;
				this.Flags = PDF_AllowMethodCall | PDF_AllowSubMemberAccess | PDF_AllowArrayAccess;
				@this._tracing = @ParTracer();
			}
		}	
	}
}
