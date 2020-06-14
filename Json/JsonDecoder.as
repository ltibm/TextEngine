namespace TextEngine
{
	namespace Json
	{
		enum JsonFromType
		{
			JsonFrom_None = 0,
			JsonFrom_String,
			JsonFrom_Bool,
			JsonFrom_Double,
			JsonFrom_StringArray,
			JsonFrom_Dictionary,
			JsonFrom_Object,
			JsonFrom_Objects
		}

        JsonItem@ Json_DecodeFrom(any@ item, JsonItem@ baseitem = null, bool detecttypes = false)
        {
	
            JsonDecoder@ jparser = JsonDecoder();
            JsonItem@ jitem = @baseitem;
			if(jitem.Parent !is null && jitem.Parent.ObjectType == OBJ_ARRAY)
			{
				jitem.ObjectType = OBJ_ARRAYITEM;
			}
            else if (jitem.Parent !is null && jitem.Parent.ObjectType == OBJ_OBJECT)
            {
                jitem.ObjectType = OBJ_VARIANT;
            }
            if (jitem is null) @jitem = JsonItem();
			JsonFromType fromtype = GetObjectTypeFromAny(@item);
            if (fromtype == JsonFrom_StringArray)
            {
                jitem.ObjectType = OBJ_ARRAY;
				array<string> itemlist;
				item.retrieve(itemlist);
                @jitem.SubItems = @jparser.JsonDecodeFromArray(itemlist, @jitem, detecttypes);
            }
			else if (fromtype == JsonFrom_Object)
			{
                Object@ obj;
				item.retrieve(@obj);
                @jitem.Value = @obj;
			}
            else if (fromtype == JsonFrom_Objects)
            {
				jitem.ObjectType = OBJ_ARRAY;
                Objects@ obj;
				item.retrieve(@obj);
                @jitem.SubItems = @jparser.JsonDecodeFromObjectArray(@obj, @jitem, detecttypes);
            }
			else if(fromtype == JsonFrom_Dictionary)
			{
				jitem.ObjectType = OBJ_OBJECT;
				dictionary dict;
				item.retrieve(dict);
				@jitem.SubItems = @jparser.JsonDecodeFromDictionary(dict, @jitem, detecttypes);
			}
            else if(fromtype == JsonFrom_String)
            {
				string s;
				item.retrieve(s);
				string s2 = s;
				Object@ obj = Object();
				if(detecttypes)
				{
					if(STRINGUTIL::HasInQuot(s))
					{
						jitem.ValueQuot = s[0];
						obj.SetValue(STRINGUTIL::TrimQuot(s));
					}
					else
					{
						jitem.ValueQuot = '\0';
						if(s2.ToLowercase() == "true" || s2.ToLowercase() == "false")
						{
							obj.SetValueBool(s2.ToLowercase() == "true");
						}
						else if(isdigit(s2))
						{
							obj.SetValueDouble(atod(s2));
						}
						else if(s2 == "null")
						{
							@obj = null;
						}
						else
						{
							jitem.ValueQuot = '\"';
							obj.SetValue(s);
						}
					}
				}
				else
				{
					obj.SetValue(s2);
				}
                @jitem.Value = @obj;
            }
			else if(fromtype == JsonFrom_Bool)
            {
				bool b;
				item.retrieve(b);
				Object@ obj = Object();
				obj.SetValueBool(b);
                @jitem.Value = @obj;
            }
			else if(fromtype == JsonFrom_Double)
            {
				double d;
				item.retrieve(d);
				Object@ obj = Object();
				obj.SetValueDouble(d);
                @jitem.Value = @obj;
            }
			else
			{
				@jitem.Value = null;
			}
            return jitem;
        }

		JsonItem@ Json_DecodeFromFile(string location, bool skipcomment = false, bool decodeunicode = false)
		{
			string content = FILEUTIL::ReadAllText(location);
			return Json_Decode(content, skipcomment, decodeunicode);
		}
        JsonItem@ Json_Decode(string input, bool skipcomment = false, bool decodeunicode = false, JsonItem@ baseitem = null)
        {
			JsonDecoder@ jparser = JsonDecoder();
			jparser.skipComment = skipcomment;
			jparser.DecodeUnicode =  decodeunicode;
            return jparser.DecodeJson(input, @baseitem);
        }
		class JsonDecoder
		{
			private string input;
			private int depth = 0;
			private int startid = 0;
			private int depth_array = 0;
			int depth_object = 0;
			bool decodeUnicode;
			bool DecodeUnicode {
				get
				{
					return decodeUnicode;
				}
				set
				{
					decodeUnicode = value;
				}
			}
			bool stopFailure = false;
			bool skipComment = false;
			//bool allowarraykey = false;
			JsonDecoder()
			{

			}
			JsonItem@ DecodeJson(string finput, JsonItem@ baseitem)
			{
				this.input = finput;

				JsonItem@ jsonItem = @baseitem;
				if(jsonItem is null)
				{
					@jsonItem = JsonItem();
					jsonItem.IsParse = true;
					jsonItem.NameQuot = '\0';
					jsonItem.ValueQuot = '\0';
				}

				char quotchar = '\0';
				bool quoted = false;
				bool numeric = false;
				StringBuilder@ builder = StringBuilder();
				for (int i = 0; i < int(input.Length()); i++)
				{
					char cur = input[i];
					if(!quoted && (isdigit(cur) || cur == 't'))
					{
						numeric = true;
						quoted = true;
					}
					if (quoted)
					{
						if (quotchar == cur)
						{
							if(numeric) return null;
							jsonItem.ObjectType = OBJ_SINGLE;
							jsonItem.ValueQuot = quotchar;
							@jsonItem.Value = @Object(builder.ToString());
							quoted = false;
							break;
						}
						else
						{
							builder.Append(cur);
						}
					}
					if(cur == ' ' || cur == '\r' || cur == '\n' || cur == '\t')
					{
						continue;
					}
					else if(cur == '"' || cur == '\'')
					{
						quoted = true;
						quotchar = cur;	
					}
					else if(cur == '{')
					{

						this.startid = i;
						jsonItem.ObjectType = OBJ_OBJECT;
						@jsonItem.SubItems = @JsonDecode(OBJ_NONE, null);
						return jsonItem;
					}
					else if(cur == '[')
					{
						this.startid = i;
						jsonItem.ObjectType = OBJ_ARRAY;
						@jsonItem.SubItems = @JsonDecode(OBJ_NONE, null);
						return jsonItem;
					}
				}
				if (quoted && numeric)
				{
					jsonItem.ObjectType = OBJ_SINGLE;
					@jsonItem.Value = @Object(builder.ToString());
				}
				return jsonItem;
			}
			private JsonItemsList@ JsonDecode(JsonItemType objtype, JsonItem@ parent)
			{
				StringBuilder@ key = StringBuilder();
				StringBuilder@ value = StringBuilder();
				StringBuilder@ comment = StringBuilder();
				bool inquot = false;
				bool quoted = false;
				bool isspec = false;
				bool splitterFound = false;
				bool inlinecomment = false;
				bool multilinecomment = false;
				int lineoffset = 0;
				char quotchar = '\0';
				JsonItem@ lastitem = JsonItem();
				lastitem.NameQuot = '\0';
				lastitem.ValueQuot = '\0';
				@lastitem.Parent = @parent;
				
				JsonItemsList@ items = JsonItemsList();
				JsonItemsList@ comments = JsonItemsList();
				for (int i = startid; i < int(input.Length()); i++)
				{
		
					char cur = input[i];
					char next = '\0';
					if(i + 1 < int(input.Length()))
					{
						next = input[i + 1];
					}
					if (inlinecomment || multilinecomment)
					{

						if (inlinecomment)
						{
							if (cur == '\r' && next == '\n') continue;
						}
						if ((inlinecomment && cur == '\n') || (multilinecomment && cur == '*' && next == '/'))
						{
							if (multilinecomment) i++;
							if (!skipComment)
							{
								JsonItem@ commentItem = JsonItem();
								commentItem.LineOffset = lineoffset;
								@commentItem.Value = Object(comment.ToString());
								commentItem.ObjectType = (inlinecomment) ? OBJ_COMMENT_SINGLELINE : OBJ_COMMENT_MULTILINE;
								@commentItem.Parent = @parent;
								commentItem.NameQuot = '\0';
								commentItem.ValueQuot = '\0';
								commentItem.Index = items.Count;
								if (key.Length > 0 || splitterFound)
								{
									comments.Add(@commentItem);
								}
								else
								{
									items.Add(@commentItem);
								}
								comment.Clear();
							}

							inlinecomment = false;
							multilinecomment = false;
						}
						else
						{
							if (!skipComment)
							{
								comment.Append(cur);
							}
						}
						continue;
					}
					if (isspec)
					{
						string s = "";
						if (this.DecodeUnicode && (cur == 'u' || cur == 'U') && i + 5 < int(input.Length())) 
						{
							bool contn = true;
							array<int> nums(4);
							for (int j = 1; j < 5; j++)
							{
								char ucur = input[i + j];
								if (!isxdigit(ucur))
								{
									contn = false;
									break;
								}
								s += ucur;
								//nums[j - 1] = atoi(ucur, 16);


							}     
							if(contn)
							{
								s = "\\u" + s;
								//int formula = nums[0] * 16 * 16 * 16  + nums[1] * 16 * 16 + nums[2] * 16 + nums[3];
								i += 4;
								//cur = (char)formula;
							}
						

						}
						if(!s.IsEmpty())
						{
							if (splitterFound)
							{
								value.Append(s);
							}
							else
							{
								key.Append(s);
							}
						}
						else
						{
							if (splitterFound)
							{
								value.Append(cur);
							}
							else
							{
								key.Append(cur);
							}
						}
						isspec = false;
						continue;
					}
					if (cur == '\\' && !isspec)
					{
						isspec = true;
						continue;
					}
					else if (cur == '/')
					{
						if (next == '/')
						{
							inlinecomment = true;
							i++;
							continue;
						}
						else if (next == '*')
						{
							multilinecomment = true;
							i++;
							continue;
						}
					}

					if (inquot)
					{
						if (cur == quotchar)
						{
							inquot = false;
							quoted = true;
							if (objtype == OBJ_ARRAY)
							{
								lastitem.ValueQuot = quotchar;
							}
							else if (objtype == OBJ_OBJECT)
							{
								if (splitterFound)
								{
									lastitem.ValueQuot = quotchar;
								}
								else
								{
									lastitem.NameQuot = quotchar;
								}
							}
							continue;
						}
						else
						{
							if (!splitterFound)
							{
								key.Append(cur);
							}
							else
							{
								value.Append(cur);
							}
						}
					}
					else
					{

						if (cur == '"' || cur == '\'')
						{
							quotchar = cur;
							inquot = true;
							continue;
						}

					}
					if (!inquot)
					{
						if(cur == '{' || cur == '[')
						{
							if (!splitterFound && key.Length > 0)
							{
								stopFailure = true;
								return null;
							}
							if (value.Length > 0)
							{
								stopFailure = true;
								return null;
							}
							startid = i + 1;
							depth++;
							if (cur == '{')
							{
								if (!splitterFound && objtype == OBJ_OBJECT)
								{
									stopFailure = true;
									return null;
								}
								depth_object++;
								lastitem.ObjectType = OBJ_OBJECT;
								@lastitem.SubItems = @JsonDecode(OBJ_OBJECT, lastitem);
							}
							else
							{
								depth_array++;
								lastitem.ObjectType = OBJ_ARRAY;
								@lastitem.SubItems = @JsonDecode(OBJ_ARRAY, lastitem);
							}
							if (stopFailure)
							{
								return null;
							}
							i = startid;
						}
						else if(cur == '}' || cur == ']')
						{
							if ((objtype == OBJ_OBJECT && !splitterFound && key.Length > 0) || (value.Length > 0 && objtype == OBJ_ARRAY))
							{
								stopFailure = true;
								return null;
							}
							startid = i;
							if (cur == '}')
							{
								depth_object--;
							}
							else
							{
								depth_array--;
							}
							depth--;
							if (depth_array < 0 || depth_object < 0 || depth < 0)
							{
								stopFailure = true;
								return null;
							}
							if (objtype == OBJ_ARRAY)
							{
								if (key.Length > 0)
								{
									lastitem.ObjectType = OBJ_ARRAYITEM;
									@lastitem.Value = @Object(key.ToString());
								}
							}
							else if (objtype == OBJ_OBJECT)
							{
								if (value.Length > 0)
								{
									lastitem.ObjectType = OBJ_VARIANT;
									@lastitem.Value = @Object(value.ToString());
								}
							}
							lastitem.Index = items.Count;
							items.Add(@lastitem);
							if (comments.Count > 0)
							{
								items.AddRange(@comments);
								comments.Clear();
							}
							return items;
						}
						else if(cur == ':')
						{
							if (splitterFound || objtype == OBJ_ARRAY || objtype == OBJ_NONE)
							{
								stopFailure = true;
								return null;
							}
							lastitem.Name = key.ToString();
							splitterFound = true;
							quoted = false;
							inquot = false;
						}
						else if(cur == ',')
						{
							if ((!splitterFound && objtype == OBJ_OBJECT))
							{
								stopFailure = true;
								return null;
							}
							if (objtype == OBJ_ARRAY)
							{
								if (key.Length > 0 || quoted)
								{
									@lastitem.Value = @Object(key.ToString());
									lastitem.ObjectType = OBJ_ARRAYITEM;
								}
							}
							else if (objtype == OBJ_OBJECT)
							{
								if (value.Length > 0 || quoted)
								{
									lastitem.ObjectType = OBJ_VARIANT;
									@lastitem.Value = @Object(value.ToString());

								}
							}
							lastitem.Index = items.Count;
							items.Add(@lastitem);
							if (comments.Count > 0)
							{
								items.AddRange(@comments);
								comments.Clear();
							}
							key.Clear();
							value.Clear();
							inquot = false;
							quoted = false;
							splitterFound = false;
							@lastitem = JsonItem();
							lastitem.NameQuot = '\0';
							lastitem.ValueQuot = '\0';
							@lastitem.Parent = @parent;
						}
						else if(cur == ' ' || cur == '\r' || cur == '\n' || cur == '\t')
						{
							if (cur == '\n' || (cur == '\r' && next != '\n'))
							{
								lineoffset++;
							}
						}
						else
						{
							if (quoted)
							{
								stopFailure = true;
								return null;
							}
							if (splitterFound)
							{
								value.Append(cur);
							}
							else
							{
								key.Append(cur);
							}
						}
					}

				}
				return lastitem.SubItems;
			}
			JsonItemsList@ JsonDecodeFromArray(array<string> items, JsonItem@ parent, bool detecttypes = false)
			{
				JsonItemsList@ objects = JsonItemsList();
				for (uint i = 0; i < items.length(); i++)
				{
					string value = items[i];
					JsonItem@ jitem = this.GetJsonItemByNameValue("", @any(value), @parent, JsonFrom_String, detecttypes);
					if (jitem is null) continue;
					objects.Add(@jitem);
				}
				return objects;
			}
			JsonItem@ GetJsonItemByNameValue(string name, any@ value, JsonItem@ parent, JsonFromType fromtype, bool detecttypes = false)
			{
				JsonItem@ jitem = JsonItem();
				jitem.Name = name;
				jitem.NameQuot = '"';
				jitem.ValueQuot = '\0';
				@jitem.Parent = @parent;
				jitem.ObjectType = (parent.ObjectType == OBJ_OBJECT) ? OBJ_VARIANT : OBJ_ARRAYITEM;
				if(fromtype == JsonFrom_String)
				{
					string s = "";
					value.retrieve(s);
					string s2 = s;
					Object@ obj = Object();
					if(detecttypes)
					{
	
						if(STRINGUTIL::HasInQuot(s))
						{
							jitem.ValueQuot = s[0];
							obj.SetValue(STRINGUTIL::TrimQuot(s));
						}
						else
						{
							jitem.ValueQuot = '\0';
							if(s2.ToLowercase() == "true" || s2.ToLowercase() == "false")
							{
								obj.SetValueBool(s2.ToLowercase() == "true");
							}
							else if(isdigit(s2))
							{
								obj.SetValueDouble(atod(s2));
							}
							else if(s2 == "null")
							{
								@obj = null;
							}
							else
							{
								jitem.ValueQuot = '\"';
								obj.SetValue(s);
							}
						}


					}
					else
					{					
						jitem.ValueQuot = '"';
						obj.SetValue(s2);
					}
					@jitem.Value = @obj;
				}
				else if (fromtype == JsonFrom_StringArray)
				{
					jitem.ObjectType = OBJ_ARRAY;
					array<string> items;
					value.retrieve(items);
					@jitem.SubItems = @this.JsonDecodeFromArray(items, @jitem, detecttypes);
				}
				else if(fromtype == JsonFrom_Bool)
				{
					bool b = false;
					value.retrieve(b);
					Object@ obj = Object();
					obj.SetValueBool(b);
					@jitem.Value = @obj;
				}
				else if(fromtype == JsonFrom_Double)
				{
					double d = 0;
					value.retrieve(d);
					Object@ obj = Object();
					obj.SetValueDouble(d);
					@jitem.Value = @obj;
				}

				else if(fromtype == JsonFrom_Dictionary)
				{
					jitem.ObjectType = OBJ_OBJECT;
					dictionary dict;
					value.retrieve(dict);
					@jitem.SubItems = @this.JsonDecodeFromDictionary(dict, @jitem, detecttypes);
				}
				else if (fromtype == JsonFrom_Objects)
				{
					jitem.ObjectType = OBJ_ARRAY;
					Objects@ obj;
					value.retrieve(@obj);
					@jitem.SubItems = @this.JsonDecodeFromObjectArray(@obj, @jitem, detecttypes);
				}
				else if (fromtype == JsonFrom_Object)
				{
					Object@ obj;
					value.retrieve(@obj);
					@jitem.Value = @obj;
				}
				else
				{
					@jitem.Value = null;

				}
				return jitem;
			}
			JsonItemsList@ JsonDecodeFromDictionary(dictionary item, JsonItem@ parent, bool detecttypes = false)
			{
				JsonItemsList@ objects = JsonItemsList();
				array<string> keys = item.getKeys();
				JsonFromType fromtype;
				for(uint i = 0; i < keys.length(); i++)
				{
					string name = keys[i];
					any@ sender = any();
		
					fromtype = GetObjectTypeFromDictionary(item, name, @sender);
												
					JsonItem@ jitem = GetJsonItemByNameValue(name, @sender, @parent, fromtype, detecttypes);
					objects.Add(@jitem);
				}
				return objects;
			}
			JsonItemsList@ JsonDecodeFromObjectArray(Objects@ item, JsonItem@ parent, bool detecttypes = false)
			{
				JsonItemsList@ objects = JsonItemsList();
				JsonFromType fromtype = JsonFrom_Object;
				any@ anyobj = any();
				for(int i = 0; i < item.Count; i++)
				{
					Object@ obj = item[i];
					if(obj !is null)
					{
						if(obj.IsDictionary())
						{
							anyobj.store(obj.ToDictionary());
						}
						else
						{
							anyobj.store(@obj);
						}
					}
					else
					{
						fromtype = JsonFrom_None;
					}
					JsonItem@ jitem = GetJsonItemByNameValue("", @anyobj, @parent, JsonFrom_Object, detecttypes);
					if(jitem !is null)
					{
						objects.Add(@jitem);
					}
				}
				return objects;
			}
		}	
	}
}
