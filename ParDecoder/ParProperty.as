namespace TextEngine
{
	namespace ParDecoder
	{
		class ParProperty
		{
			string Name;
			int Type;
			bool IsAssign;
			ParProperty(string name = "", int type = PT_Property, bool isassign = false)
			{
				this.Name = name;
				this.Type = type;
				this.IsAssign = isassign;
			}
		}
	}
}
