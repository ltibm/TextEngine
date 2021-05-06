namespace TextEngine
{
	namespace Text
	{
		enum SpecialCharType
		{
			/// <summary>
			/// \ character disabled
			/// </summary>
			SCT_NotAllowed = 1,
			/// <summary>
			/// e.g(\test, result: test)
			/// </summary>
			SCT_AllowedAll = 2,
			/// <summary>
			/// e.g(\test\{} result: \test{ 
			/// </summary>
			SCT_AllowedClosedTagOnly = 3
		}
	}
}
