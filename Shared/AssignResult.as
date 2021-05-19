namespace TextEngine
{
	class AssignResult
	{
		bool Success;
		Object@ AssignedValue;
		bool opImplConv() const  
		{
			if(@this is null) return false;
			return this.Success;
		}
	}
}
