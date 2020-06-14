namespace TextEngine
{
	namespace Json
	{
		JsonFromType GetObjectTypeFromAny(any@ item, any@ iany = null)
		{
			string s = "";
			bool b = false;
			double d = 0;
			array<string> arritem;
			Object@ obj = null;
			Objects@ objs = null;
			dictionary dict;
			JsonFromType fromtype;
			if (item.retrieve(arritem))
			{
				fromtype = JsonFrom_StringArray;
				if(iany !is null)
				{
					iany.store(arritem);
				}
			}
			else if (item.retrieve(dict))
			{
				fromtype = JsonFrom_Dictionary;
				if(iany !is null)
				{
					iany.store(dict);
				}
			}
			else if(item.retrieve(s))
			{
				fromtype = JsonFrom_String;
				if(iany !is null)
				{
					iany.store(s);
				}

			}
			else if (item.retrieve(b))
			{
				fromtype = JsonFrom_Bool;
				if(iany !is null)
				{
					iany.store(b);
				}
			}
			else if (item.retrieve(d))
			{
				fromtype = JsonFrom_Double;
				if(iany !is null)
				{
					iany.store(d);
				}
			}
			else if (item.retrieve(@obj))
			{
				fromtype = JsonFrom_Object;
				if(iany !is null)
				{
					iany.store(@obj);
				}
			}
			else if (item.retrieve(@objs))
			{
				fromtype = JsonFrom_Objects;
				if(iany !is null)
				{
					iany.store(@objs);
				}
			}
			return fromtype;
		}
		JsonFromType GetObjectTypeFromDictionary(dictionary item, string key, any@ iany = null)
		{
			string s = "";
			bool b = false;
			double d = 0;
			array<string> arritem;
			dictionary dict;
			Object@ obj = null;
			Objects@ objs = null;
			JsonFromType fromtype;
			if (item.get(key,arritem))
			{
				fromtype = JsonFrom_StringArray;
				if(iany !is null)
				{
					iany.store(arritem);
				}
			}
			else if (item.get(key, dict))
			{
				fromtype = JsonFrom_Dictionary;
				if(iany !is null)
				{
					iany.store(dict);
				}
			}
			else if(item.get(key, s))
			{
				fromtype = JsonFrom_String;
				if(iany !is null)
				{
					iany.store(s);
				}
			}
			else if (item.get(key, b))
			{
				fromtype = JsonFrom_Bool;
				if(iany !is null)
				{
					iany.store(b);
				}
			}
			else if (item.get(key, d))
			{
				fromtype = JsonFrom_Double;
				if(iany !is null)
				{
					iany.store(d);
				}
			}
			else if (item.get(key, @obj))
			{
				fromtype = JsonFrom_Object;
				if(iany !is null)
				{
					iany.store(@obj);
				}
			}
			else if (item.get(key, @objs))
			{
				fromtype = JsonFrom_Objects;
				if(iany !is null)
				{
					iany.store(@objs);
				}
			}
			return fromtype;
		}
	}
}
