namespace TextEngine
{
	namespace Json
	{
		class JsonItem
		{
			
			JsonItem@ opAssign(int obj)
			{
				this.SetValueJson(obj);
				return this;
			}
			JsonItem@ opAssign(double obj)
			{
				this.SetValueJson(obj);
				return this;
			}	
			JsonItem@ opAssign(string obj)
			{
				this.SetValueJson(obj);
				return @this;
			}	
			array<string> opImplConv()  
			{
				return this.GetValueArrayString();
			}
			dictionary opImplConv()  
			{
				return this.GetValueDictionary(false, true);
			}
			bool opImplConv()  
			{
				return this.ValueBool();
			}	
			float opImplConv()  
			{
				return this.ValueFloat();
			}	
			double opImplConv()  
			{
				return this.ValueDouble();
			}	
			int opImplConv()  
			{
				return this.ValueInt();
			}			
			string opImplConv()   
			{
				return this.ValueString();
			}				
			Object@ get_opIndex(int index) const
			{ 
				if (this.ObjectType == OBJ_ARRAY)
				{
					if (index < 0 || index > this.SubItems.Count) return null;
					JsonItem@ jitem = this.SubItems[index];
					if (jitem !is null) return @jitem.Value;
				}
				return null;
			}
			void set_opIndex(int index, Object@ value)
			{ 
				if (this.ObjectType == OBJ_ARRAY)
				{
					if (index < 0 || index > this.SubItems.Count) return;
					JsonItem@ jitem = this.SubItems[index];
					if (jitem !is null)
					{
						@jitem.Value = @value;
					}
				}
			}
			JsonItem()
			{

			}
			private bool isParse;
			bool IsParse
			{
				get const
				{
					return isParse;
				}
				set
				{
					isParse = value;
				}
			}
			private JsonItem@ parent;
			JsonItem@ Parent
			{
				get const
				{
					return parent;
				}
				set
				{
					@parent = @value;
				}
			}
			private JsonItemType objectType;
			JsonItemType ObjectType
			{
				get const
				{
					return objectType;
				}
				set
				{
					objectType = value;
				}
			}
			private string name;
			string Name
			{
				get const
				{
					return name;
				}
				set
				{
					name = value;
				}
			}
			private Object@ jvalue;
			Object@ Value
			{
				get const
				{
					return jvalue;
				}
				set
				{
					if (this.ObjectType != OBJ_ARRAY && this.ObjectType != OBJ_OBJECT || value is null)
					{
						this.SubItems.Clear();
					}
					if(value is null)
					{
						@jvalue = null;
						this.ValueQuot = '\0';
						return;
					}
					if (value.IsString() && this.ValueQuot == '\0')
					{
						string str = value.ToString();
						if (str.ToLowercase() == "true")
						{
							value.SetValueBool(true);
						}
						else if (str.ToLowercase() == "false")
						{
							value.SetValueBool(false);
						}
						else if (str == "null")
						{
							@value = null;
						}
						else
						{
							if(isdigit(str))
							{
								value.SetValueDouble(atod(str));
							}
							else
							{
								this.ValueQuot = '\"';
							}
							
						}
					}
					else if(value.IsNumericType())
					{
						this.ValueQuot = '\0';
					}
					else
					{
						if(value.IsDictionary())
						{
							dictionary dict = value.ToDictionary();
							Json_DecodeFrom(any(dict), @this);
						}
						else if(value.IsObjects())
						{
							Objects@ obj = value;
							Json_DecodeFrom(any(@obj), @this);
						}
					}
					@jvalue = @value;
				}
			}
			private int lineOffset;
			int LineOffset 
			{ 
				get const
				{
					return lineOffset;
				}
				set
				{
					lineOffset = value;
				}
			}
			private int index;
			int Index 
			{ 
				get const
				{
					return index;
				}
				set
				{
					index = value;
				}
			}
			private JsonItemsList@ subItems = JsonItemsList();
			JsonItemsList@ SubItems 
			{ 
				get const
				{
					return subItems;
				}
				set
				{
					@subItems = @value;
				}
			}
			private char nameQuot = '"';
			char NameQuot 
			{ 
				get const
				{
					return nameQuot;
				}
				set
				{
					nameQuot = value;
				}
			}
			private char valueQuot = '"';
			char ValueQuot 
			{ 
				get const
				{
					return valueQuot;
				}
				set
				{
					valueQuot = value;
				}
			}
			string ToJson(bool tabformat = false)
			{
				JSON_OUTPUT_FORMAT format = FORMATTING_SINGLELINE;
				if(tabformat) format = FORMATTING_TABFORMAT;
				Object@ str =  Json_Encode(@this, format);
				if(str is null) return "";
				return str.ToString();
			}
			void SaveToFile(string location, JSON_OUTPUT_FORMAT formatting = FORMATTING_TABFORMAT, bool printcomment = true)
			{
				FILEUTIL::SaveAllText(location, Json_Encode(@this, formatting, printcomment));
			}
			string GetValueWithVars()
			{
				string str = "";
				if(this.Value !is null)
				{
					str = this.Value.ToString();
				}
				string result = str.Replace("\\", "\\\\");
				if (this.ValueQuot != '\0')
				{
					result = result.Replace(this.ValueQuot, "\\" + string(this.ValueQuot));
				}
				result = result.Replace("\\", "\\\\").Replace("{", "\\{").Replace("[", "\\[").Replace("}", "\\}").Replace("]", "\\]");
				return result;

			}
			string GetNameWithVars()
			{
				string name = this.Name;
				string result = name.Replace("\\", "\\\\");
				if (this.NameQuot != '\0')
				{
					result = result.Replace(this.NameQuot, "\\" + string(this.NameQuot));
				}
				result = result.Replace("\\", "\\\\").Replace("{", "\\{").Replace("[", "\\[").Replace("}", "\\}").Replace("]", "\\]");
				return result;
			}
			JsonItem@ Evulate(string evulator)
			{
				array<string> alls = evulator.Split('.');
				JsonItem@ item = this;
				for (uint i = 0; i < alls.length(); i++)
				{
					@item = @item.Find(alls[i]);
					if (item is null) return null;
				}
				return item;
			}
			JsonItem@ Find(string name)
			{
				if (this.ObjectType != OBJ_ARRAY && this.ObjectType != OBJ_OBJECT)
				{
					return null;
				}
				Regex::MatchResults@ match = Regex::MatchResults();
				bool success = Regex::Match(name, @match, @Regex::Regex("([\\w\\d]+)?\\[(\\d+|l|f|L|F)\\]$"));
				int arrayIndex = -1;
				string newname = "";
				if (success)
				{
					string result = match.GetString(2);
					if (result != "f" && result != "F" && result != "l" && result != "L")
					{
						arrayIndex = atoi(result);
					}
					else
					{
						if (result == "f" || result == "F")
						{
							arrayIndex = 0;
						}
						else
						{
							arrayIndex = -2;
						}
					}

					newname = match.GetString(1);
				}
				else

				{
					newname = name;
				}
				if (newname.IsEmpty())
				{

					if (this.ObjectType != OBJ_ARRAY || arrayIndex >= this.SubItems.Count)
					{
						return null;
					}
					if (arrayIndex == -2)
					{
						arrayIndex = this.SubItems.Count - 1;
					}
					if (arrayIndex < 0) return null;
					return @this.SubItems[arrayIndex];
				}
				if(this.SubItems is null) return null;
				for (int i = 0; i < this.SubItems.Count; i++)
				{

					JsonItem@ sub = this.SubItems[i];
					if (sub.ObjectType != OBJ_ARRAYITEM && sub.ObjectType != OBJ_OBJECT && sub.ObjectType != OBJ_ARRAY && sub.ObjectType != OBJ_VARIANT)
					{
						continue;
					}
					if (sub.ObjectType == OBJ_ARRAY && sub.Name == newname)
					{
						if (arrayIndex == -2)
						{
							arrayIndex = sub.SubItems.Count - 1;
						}
						if (arrayIndex >= 0)
						{
							if (arrayIndex >= sub.SubItems.Count)
							{
								return null;
							}
							return @sub.SubItems[arrayIndex];
						}
						else
						{
							return @sub;
						}
					}
					else
					{
						if (sub.Name == name)
						{
							return @sub;
						}

					}

				}
				return null;
			}
			string ValueString()
			{
				if(this.ObjectType == OBJ_ARRAY || this.ObjectType == OBJ_OBJECT || this.Value is null) return "";
				return this.Value.ToString();
			}
			bool ValueBool()
			{
				if(this.ObjectType == OBJ_ARRAY || this.ObjectType == OBJ_OBJECT || this.Value is null) return false;
				if(this.Value.IsBool())
				{
					bool b = this.Value;
					return b;
				}
				string str = this.Value.ToString().ToLowercase();
				if(str == "true") return true;
				return atoi(str) > 0;
			}
			int ValueInt()
			{
				if(this.ObjectType == OBJ_ARRAY || this.ObjectType == OBJ_OBJECT || this.Value is null) return 0;
				if(this.Value.IsNumericType())
				{
					int i = this.Value;
					return i;
				}
				return atoi(this.Value.ToString());
			}
			double ValueDouble()
			{
				if(this.ObjectType == OBJ_ARRAY || this.ObjectType == OBJ_OBJECT || this.Value is null) return 0;
				if(this.Value.IsNumericType())
				{
					double d = this.Value;
					return d;
				}
				return atod(this.Value.ToString());
			}
			dictionary GetValueDictionary(bool includesubvalues = false, bool valuesmustbestring = true)
			{
				dictionary dict;
				if(this.ObjectType != OBJ_OBJECT) return dict;
				for(int i = 0; i < this.SubItems.Count; i++)
				{
					JsonItem@ jitem = this.SubItems[i];
					if(jitem.ObjectType == OBJ_VARIANT)
					{
						if(valuesmustbestring)
						{
							string val = "";
							if(@jitem.Value !is null)
							{
								val = jitem.Value.ToString();
							}
							dict.set(jitem.Name, val);
						}
						else
						{
							dict.set(jitem.Name, @jitem.Value);
						}
						continue;
					}
					if(includesubvalues)
					{
						if(jitem.ObjectType == OBJ_ARRAY)
						{
							dict.set(jitem.Name, @Object(jitem.GetValueObjects(includesubvalues)));
						}
						else if(jitem.ObjectType == OBJ_OBJECT)
						{
							dict.set(jitem.Name, jitem.GetValueDictionary(includesubvalues));
						}
					}
				}
				return dict;
			}
			array<string> GetValueArrayString()
			{				
				array<string> str_array;
				if(this.ObjectType != OBJ_ARRAY) return str_array;
				for(int i = 0; i < this.SubItems.Count; i++)
				{
					JsonItem@ jitem = this.SubItems[i];
					if(jitem.ObjectType == OBJ_ARRAYITEM)
					{
						string s = "";
						if(jitem.Value !is null)
						{
							s = jitem.Value.ToString();
						}
						str_array.insertLast(s);
					}
				}
				return str_array;	
			}
			Objects@ GetValueObjects(bool includesubvalues = false)
			{
				Objects@ objectArray = Objects();
				if(this.ObjectType != OBJ_ARRAY) return objectArray;
				for(int i = 0; i < this.SubItems.Count; i++)
				{
					JsonItem@ jitem = this.SubItems[i];
					if(jitem.ObjectType == OBJ_ARRAYITEM)
					{
						objectArray.Add(@jitem.Value);
					}
					if(includesubvalues)
					{
						if(jitem.ObjectType == OBJ_ARRAY)
						{
							objectArray.Add(@Object(jitem.GetValueObjects(includesubvalues)));
						}
						else if(jitem.ObjectType == OBJ_OBJECT)
						{
							Object@ obj = Object();
							obj.SetValueDictionary(jitem.GetValueDictionary(includesubvalues, false));
							objectArray.Add(@obj);
						}
					}
				}
				return objectArray;
			}
			float ValueFloat()
			{
				if(this.ObjectType == OBJ_ARRAY || this.ObjectType == OBJ_OBJECT || this.Value is null) return 0;
				if(this.Value.IsNumericType())
				{
					double d = this.Value;
					return float(d);
				}
				return atof(this.Value.ToString());
			}
			void SetValueBool(bool newvalue)
			{
				Object@ obj = Object();
				obj.SetValueBool(newvalue);
				@this.Value = @obj;
			}
			void SetValueString(string newvalue)
			{
				this.ValueQuot = '"';
				@this.Value = Object(newvalue);
			}
			void SetValueInt(int newvalue)
			{
				Object@ obj = Object();
				obj.SetValueInt(newvalue);
				@this.Value = @obj;
			}
			void SetValueFloat(float newvalue)
			{
				this.SetValueDouble(double(newvalue));
			}
			void SetValueDouble(double newvalue)
			{
				Object@ obj = Object();
				obj.SetValueDouble(newvalue);
				@this.Value = @obj;
			}
			void SetValueAny(any@ anyobj, bool detecttypes = false)
			{
				Json_DecodeFrom(@anyobj, @this, detecttypes);
				
			}
			void SetValueJson(string json)
			{
				Json_Decode(json, false , false, @this);
	
			}
		}
	}
}
