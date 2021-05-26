namespace TextEngine
{
	namespace ParDecoder
	{
		enum ParTraceFlags
		{
			PTF_TRACE_PROPERTY = 1 << 0,
			PTF_TRACE_METHOD = 1 << 1,
			PTF_TRACE_INDIS = 1 << 2,
			PTF_TRACE_ASSIGN = 1 << 3,
			PTF_KEEP_VALUE = 1 << 4,
		}
		class ParTracer
		{
			private array<ParTracerItem@> inner;
			int Flags;
			bool Enabled;
			int Count
			{
				get const
				{
					return this.inner.length();
				}
			}
			ParTracer()
			{
				this.Flags = PTF_KEEP_VALUE | PTF_TRACE_METHOD | PTF_TRACE_PROPERTY | PTF_TRACE_ASSIGN | PTF_TRACE_INDIS;
			}
			void Clear()
			{
				this.inner.resize(0);
			}
			void Add(ParTracerItem@ item)
			{
				this.inner.insertLast(@item);
			}
			ParTracerItem@ Get(int id)
			{
				return this.inner[id];
			}
			ParTracerItem@ GetField(string name)
			{
				for (uint i = 0; i < this.inner.length(); i++)
				{
					if(this.inner[i].Name == name)
					{
						return this.inner[i];
					}
				}
				return null;
			}
			array<ParTracerItem@> GetFields(string name, uint limit = 0)
			{
				array<ParTracerItem@> list;
				for (uint i = 0; i < this.inner.length(); i++)
				{
					if(this.inner[i].Name == name)
					{
						list.insertLast(@this.inner[i]);
					}
					if(limit > 0 && list.length() >= limit) break;
				}
				return list;
			}
			bool HasFlag(int flag)
			{
				return (this.Flags & flag) != 0;
			}
			bool HasTraceThisType(int pt)
			{
				switch (pt)
				{
					case PT_Property:
						return this.HasFlag(PTF_TRACE_PROPERTY);
					case PT_Indis:
						return this.HasFlag(PTF_TRACE_INDIS);
					case PT_Method:
						return this.HasFlag(PTF_TRACE_METHOD);
				}
				return false;
			}
		}
	}
}
