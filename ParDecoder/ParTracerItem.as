namespace TextEngine
{
	namespace ParDecoder
	{
		class ParTracerItem
		{
			string Name;
			Object@ Value;
			int Type;
			bool IsAssign;
			bool Accessed;
			ParTracerItem(string name = "", int type = PT_Property, Object@ value = null)
			{
				this.Name = name;
				this.Type = type;
				@this.Value = @value;
			}
		}
	}
}
