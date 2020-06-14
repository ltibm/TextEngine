namespace TextEngine
{
	namespace Json
	{
		/* 
		* 0 - Single Line
		* 1 - Multi Line
		* 2 - Tab format
		* */	
		enum JSON_OUTPUT_FORMAT
		{
			FORMATTING_SINGLELINE = 0,
			FORMATTING_MULTILINE = 1,
			FORMATTING_TABFORMAT = 2
		}
        Object@ Json_Encode(JsonItem@ jsonItem, JSON_OUTPUT_FORMAT formatting = FORMATTING_TABFORMAT, bool printcomment = true)
        {
			if(jsonItem is null) return null;
			JsonEncoder@ jsonEncoder = JsonEncoder();
			jsonEncoder.formattingtype = formatting;
            jsonEncoder.printComment = printcomment;
            @jsonEncoder.rootItem = @jsonItem;
            return @jsonEncoder.EncodeJson(jsonItem);
        }
		class JsonEncoder
		{
			int depth2 = 0;
			int formattingtype = 0;
			private bool preventfirstlineformat = false;
			JsonItem@ rootItem = null;
			bool printComment = true;
			JsonEncoder()
			{

			}
			Object@ EncodeJson(JsonItem@ jsonItem)
			{
				if (jsonItem.ObjectType == OBJ_SINGLE)
				{
					string sval = "";
					if(jsonItem.Value !is null)
					{
						sval = jsonItem.Value.ToString(true);
					}
					return "\"" + jsonItem.Value.ToString(true) + "\"";
				}
				if (jsonItem.ObjectType != OBJ_ARRAY && jsonItem.ObjectType != OBJ_OBJECT)
				{
					return null;
				}
				StringBuilder@ sb = StringBuilder();
				int added = 0;
				if (formattingtype != FORMATTING_SINGLELINE)
				{
					if (formattingtype == FORMATTING_TABFORMAT || depth2 == 1)
					{
						if (!preventfirstlineformat)
						{
							sb.AppendChar('\t', depth2);
						}
					}
				}
				preventfirstlineformat = false;

				if (jsonItem.ObjectType == OBJ_ARRAY)
				{
					sb.Append("[");
				}
				else
				{
					sb.Append("{");
				}
				if (formattingtype != FORMATTING_SINGLELINE)
				{
					if (formattingtype == FORMATTING_TABFORMAT || depth2 == 0)
					{
						sb.Append("\n");
					}
				}
				bool donotadd = false;
				if(jsonItem.SubItems is null) return null;
				for(int i = 0; i < jsonItem.SubItems.Count; i++)
				{
					JsonItem@ jitem = jsonItem.SubItems[i];
					if ((jitem.ObjectType == OBJ_COMMENT_SINGLELINE || jitem.ObjectType == OBJ_COMMENT_MULTILINE) && !this.printComment) continue;
					if ((jitem.ObjectType == OBJ_COMMENT_SINGLELINE || jitem.ObjectType == OBJ_COMMENT_MULTILINE) && formattingtype != FORMATTING_TABFORMAT) continue;
					if (added > 0)
					{
						if (!donotadd) sb.Append(", ");
						if (donotadd)
						{

							donotadd = false;
						}

						if (formattingtype != FORMATTING_SINGLELINE)
						{
							if (formattingtype == FORMATTING_TABFORMAT || depth2 == 0)
							{
								if (formattingtype == FORMATTING_TABFORMAT)
								{
									if ((jitem.ObjectType == OBJ_COMMENT_SINGLELINE || jitem.ObjectType == OBJ_COMMENT_MULTILINE) || added == 0)
									{
										if (jitem.LineOffset > 0)
										{
											for (int j = 0; j < jitem.LineOffset; j++)
											{
												sb.Append("\n");
											}
										}
										else
										{

											sb.Append(" ");
										}
									}
									else
									{
										sb.Append("\n");
									}
								}

								else
								{
									sb.Append("\n");
								}

							}
						}
					}
					if (jsonItem.ObjectType == OBJ_ARRAY)
					{
						if (jsonItem.ObjectType == OBJ_NONE || jsonItem.ObjectType == OBJ_SINGLE || jsonItem.ObjectType == OBJ_VARIANT)
						{
							return null;
						}
					}
					else
					{
						if (jsonItem.ObjectType == OBJ_NONE || jsonItem.ObjectType == OBJ_SINGLE || jsonItem.ObjectType == OBJ_ARRAYITEM)
						{
							return null;
						}
					}

					if (jitem.ObjectType == OBJ_ARRAY || jitem.ObjectType == OBJ_OBJECT)
					{
						depth2++;
						if (jsonItem.ObjectType == OBJ_OBJECT)
						{
							preventfirstlineformat = true;
						}
						Object@ sresult = EncodeJson(jitem);
						
						if (sresult is null) return null;
						string result = sresult.ToString();
						if (jsonItem.ObjectType == OBJ_ARRAY)
						{
							sb.Append(result);
						}
						else
						{
							if (formattingtype != FORMATTING_SINGLELINE)
							{
								if (formattingtype == FORMATTING_TABFORMAT || depth2 == 1)
								{
									sb.AppendChar('\t', depth2);
								}
							}
							string name = "";
							if (rootItem.IsParse)
							{
								if (jitem.NameQuot != '\0')
								{
									name = string(jitem.NameQuot) + jitem.Name + string(jitem.NameQuot);
								}
								else
								{
									name = jitem.Name;
								}

							}
							else
							{
								name = "\"" + jitem.Name + "\"";
							}
							sb.Append(name + ": ");
							sb.Append(result);
						}
						added++;
						depth2--;
						continue;
					}
					if (formattingtype != FORMATTING_SINGLELINE)
					{
						if (formattingtype == FORMATTING_TABFORMAT || depth2 == 0)
						{
							if (jitem.ObjectType == OBJ_COMMENT_SINGLELINE || jitem.ObjectType == OBJ_COMMENT_MULTILINE)
							{
								if (jitem.LineOffset > 0 || added == 0)
								{
									sb.AppendChar('\t', depth2 + 1);
								}
							}
							else
							{
								sb.AppendChar('\t', depth2 + 1);
							}

						}
					}
					if (jitem.ObjectType == OBJ_COMMENT_SINGLELINE || jitem.ObjectType == OBJ_COMMENT_MULTILINE)
					{
						if (jitem.ObjectType == OBJ_COMMENT_SINGLELINE)
						{
							sb.Append("//");
							sb.Append(jitem.Value);
						}
						else
						{
							sb.Append("/*");
							sb.Append(jitem.Value);
							sb.Append("*/");
						}


						donotadd = true;
					}
					else
					{
						if (jsonItem.ObjectType == OBJ_ARRAY)
						{
							string value = "";

							if (rootItem.IsParse || (jitem.Value is null || !jitem.Value.IsString()))
							{
								if (jitem.Value is null || jitem.Value.IsEmpty())
								{
									value = "null";
								}
								else if (jitem.Value !is null && jitem.Value.IsBool())
								{
									value = jitem.Value.ToString(true).ToLowercase();
								}
								else if (jitem.ValueQuot != '\0')
								{

									value = string(jitem.ValueQuot) + jitem.GetValueWithVars() + string(jitem.ValueQuot);

								}
								else
								{
									value = jitem.GetValueWithVars();

								}

							}
							else
							{
								value = "\"" + jitem.GetValueWithVars() + "\"";
							}
							sb.Append(value);
						}
						else
						{
							string name = "";
							string value = "";
							if (rootItem.IsParse || (jitem.Value is null || !jitem.Value.IsString()))
							{
								if (jitem.NameQuot != '\0')
								{
									name = string(jitem.NameQuot) + jitem.Name + string(jitem.NameQuot);
								}
								else
								{
									name = jitem.Name;
								}
								if (jitem.Value is null)
								{
									value = "null";
								}
								else if (jitem.Value !is null && jitem.Value.IsBool())
								{
									value = jitem.Value.ToString(true).ToLowercase();
								}
								else if (jitem.ValueQuot != '\0')
								{
									value = string(jitem.ValueQuot) + jitem.GetValueWithVars() + string(jitem.ValueQuot);
								}
								else
								{
									value = jitem.GetValueWithVars();
								}

							}
							else
							{
								name = "\"" + jitem.Name + "\"";
								value = "\"" + jitem.GetValueWithVars() + "\"";
							}
							sb.Append(name + ": " + value);
						}
					}

					added++;
				}

				if (formattingtype != FORMATTING_SINGLELINE)
				{
					if (formattingtype == FORMATTING_TABFORMAT || depth2 == 0)
					{
						sb.Append("\n");
						if (formattingtype == FORMATTING_TABFORMAT)
						{
							sb.AppendChar('\t', depth2);
						}
					}
				}
				if (jsonItem.ObjectType == OBJ_ARRAY)
				{
					sb.Append("]");
				}
				else
				{
					sb.Append("}");
				}
				return sb.ToString();
			}
		}

	}
}
