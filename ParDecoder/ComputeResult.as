namespace TextEngine
{
	namespace ParDecoder
	{
	    class ComputeResult
		{
			private Objects@ result;
			Objects@ Result 
			{ 
				get const
				{
					return result;
				}
				set
				{
					@result = @value;
				}
			}
			ComputeResult()
			{
				@this.Result = Objects();
			}
		}
	}
}
