namespace TextEngine
{
	namespace Text
	{
		enum TextElementFlags
		{
			TEF_NONE = 0,
			TEF_ConditionalTag = 1 << 0,
			TEF_NoAttributedTag = 1 << 1,
			TEF_AutoClosedTag = 1 << 2,
			/// <summary>
			/// E.G [TAG=ATTRIB=test atrribnext/], returns: ATTRIB=test atrribnext
			/// </summary>
			TEF_TagAttribonly =  1 << 3,
			/// <summary>
			/// if set [TAG/], tag not flagged autoclosed, if not set tag flagged autoclosed. 
			/// </summary>
			TEF_DisableLastSlash = 1 << 4
		}
	}
}
