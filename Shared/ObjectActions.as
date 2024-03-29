namespace TextEngine
{
	array<string> PriotiryStop =
	{
		"and",
		"&&",
		"||",
		"!=",
		"==",
		"=",
		">",
		"<",
		">=",
		"<=",
		"or",
		"+",
		"-",
		",",
		"=>",
        "?",
        ":"
	};
	Object@ OperatorResult(Object@ item1, Object@ item2, string soperator)
	{
		/*string item1s = "null";
		string item2s = "null";
		if(item1 !is null)
		{
			item1s = item1.ToString();
		}
		if(item2 !is null)
		{
			item2s = item2.ToString();
		}
		PrintLine(item1s + " " + soperator + " " + item2s);*/
		Object@ results = Object();
		if(item1 is null && item2 is null)
		{
			return null;
		}
		bool istwonumeric = false;
		if(item1 !is null && item2 !is null)
		{
			if(item1.IsString() || item2.IsString())
			{
				//string istr1 = item1.ToString();
				//string istr2 = item2.ToString();
				//istwonumeric = isdigit(istr1) && isdigit(istr2);
			}

		}
		if ((soperator == "||" || soperator == "|" || soperator == "&&" || soperator == "and") || ((@item1 is null || !item1.IsNumericType() || @item2 is null || !item2.IsNumericType()) && (soperator == "or" || soperator == "&" )))
		{
			bool leftstate = false;
			if(item1 !is null)
			{
				leftstate = !item1.IsEmptyOrDefault();
			}
			bool rightstate = false;
			if(item2 !is null)
			{
				rightstate = !item2.IsEmptyOrDefault();
			}
			if (soperator == "||" || soperator == "|" || soperator == "or")
			{
				if(leftstate != rightstate)
				{
					results.SetValueBool(true);
				}
				else
				{
					results.SetValueBool(leftstate);
				}

				return results;
			}
			else
			{
				if(leftstate && rightstate)
				{
					results.SetValueBool(true);
				}
				else
				{
					results.SetValueBool(false);
				}
				return results;
			}
        }
        if(item1 !is null && item1.IsString() && item2 is null || item2 !is null && item2.IsString() && item1 is null)
        {
			results.SetValueBool(false);
        }
		else if(soperator == "")
		{
			return @item1;
		}
		else if((soperator == "==" || soperator == "=" || soperator == "!=") && (item1 is null || item2 is null))
        {
		
			if(item1 is null)
			{
				if(soperator == "==" || soperator == "=")
				{
					results.SetValueBool(item2 is null);
                }
                else
                {
					results.SetValueBool(item2 !is null);
				}
            }
			else if(item2 is null)
			{
				if (soperator == "==" || soperator == "=")
				{
					results.SetValueBool(item1 is null);
				}
				else
				{
					results.SetValueBool(item1 !is null);
				}
			};
		}
		else if(item1 !is null && item1.IsString() && soperator == "+")
		{
			string item2str = "";
			if(item2 !is null)
			{
				item2str = item2.ToString();
			}
			return @Object(item1.ToString() + item2str);

		}
		else if(item2 !is null && item2.IsString() && soperator == "+")
		{
			string item1str = "";
			if(item2 !is null)
			{
				item1str = item2.ToString();
			}
			results.SetValue(item1.ToString() + item2.ToString());
		}
		else if(item1 !is null && item1.IsBool() && item2 !is null && item2.IsBool())
		{
			bool leftitem = item1;
			bool rightitem = item2;
			if(soperator == "==" || soperator == "=")
			{
				results.SetValueBool(leftitem == rightitem);
			}
			else if(soperator == "!=")
			{
				results.SetValueBool(leftitem != rightitem);
			}

		}
		else if(!istwonumeric && item1 !is null && item1.IsString() && item2 !is null && item2.IsString())
		{
									
			string leftitem = item1.ToString();
			string rightitem = item2.ToString();

			int cmpres = leftitem.Compare(rightitem);
			if(soperator == "==" || soperator == "=")
			{
				results.SetValueBool(cmpres == 0);
			}
			else if(soperator == "!=")
			{
				results.SetValueBool(cmpres != 0);
			}
			else if(soperator == "<")
			{
				results.SetValueBool(cmpres == -1);
			}
			else if(soperator == "<=")
			{
				results.SetValueBool(cmpres == 0 || cmpres == -1);
			}
			else if(soperator == ">")
			{
				results.SetValueBool(cmpres == 1);
			}
			else if(soperator == ">=")
			{
				results.SetValueBool(cmpres == 0 || cmpres == 1);
			}
		}
		else
		{

			if (item2 is null) @item2 = @Object("");
			if (item1 is null) @item1 = @Object("");
			string item1str = item1.ToString();
			string item2str = item2.ToString();

			if(item1.IsNumericType() && item2.IsNumericType() || item1.IsNumericType() && isdigit(item2str) || item2.IsNumericType() && isdigit(item1str) || isdigit(item1str) && isdigit(item2str))
			{
				double leftitem = 0;
				double rightitem = 0;
				if(item1.IsNumericType())
				{
					leftitem = item1;
				}
				else
				{
					leftitem = atod(item1str);
				}
				if(item2.IsNumericType())
				{
					rightitem = item2;
				}
				else
				{
					rightitem = atod(item2str);
				}
				if(soperator == "==" || soperator == "=")
				{
					results.SetValueBool(leftitem == rightitem);
				}
				else if(soperator == "!=")
				{
					results.SetValueBool(leftitem != rightitem);
				}
				else if(soperator == "<")
				{
					results.SetValueBool(leftitem < rightitem);
				}
				else if(soperator == "<=")
				{
					results.SetValueBool(leftitem <= rightitem);
				}
				else if(soperator == ">")
				{
					results.SetValueBool(leftitem > rightitem);
				}
				else if(soperator == ">=")
				{
					results.SetValueBool(leftitem >= rightitem);
				}
				else if(soperator == "+")
				{
					results.SetValueDouble(leftitem + rightitem);
				}
				else if(soperator == "-")
				{
					results.SetValueDouble(leftitem - rightitem);
				}
				else if(soperator == "*")
				{
					results.SetValueDouble(leftitem * rightitem);
				}
				else if(soperator == "/" || soperator == "div")
				{
					results.SetValueDouble(leftitem / rightitem);
				}
				else if(soperator == "%" || soperator == "mod")
				{
					results.SetValueDouble(leftitem % rightitem);
				}
				else if(soperator == "&")
				{
					results.SetValueInt(int(leftitem) & int(rightitem));
				}
				else if(soperator == "|")
				{
					results.SetValueInt(int(leftitem) | int(rightitem));
				}
				else if(soperator == "<<")
				{
					results.SetValueInt(int(leftitem) << int(rightitem));
				}
				else if(soperator == ">>")
				{
					results.SetValueInt(int(leftitem) >> int(rightitem));
				}
			}
		}
		if(results.IsEmpty())
		{
			if(@item1 is null) return @item2;
			return @item1;
		}
		return @results;
	}

	PropObject@ GetProp(string item, dictionary@ items)
	{
		PropObject@ propObj = @PropObject();
		Object@ obj = @Object();
		if(items !is null && items.exists(item))
		{		
			if(!obj.SetValueByDictionary(items, item))
			{
				items.get(item, @obj);
			}
		}
		else
		{
			return propObj;
		}
		propObj.PropType = PT_Dictionary;
		@propObj.DictionaryData = @items;
		@propObj.Value = @obj;
		propObj.StrIndex = item;
		return propObj;
	}
	PropObject@ GetPropB(string item, Object@ vars, Object@ localvars)
	{
		PropObject@ res = @PropObject();
		if(@localvars !is null)
		{
			@res = @GetProp(item, @localvars);
		}
		if(@res is null || res.PropType == PT_Empty)
		{
			@res = @GetProp(item, @vars);
		}
		return res;
	}
	PropObject@ GetPropEx(string item, Object@ items)
	{
		PropObject@ propObj = @PropObject();
		if(@items is null) return propObj;
		
		if(items.IsDictionaryList())
		{
			DictionaryList@ dl = @items;
			if(@dl is null) return propObj;
			for(int i = 0; i < dl.Count; i++)
			{
				auto@ r = GetProp(item, @dl[i]);
				if(r.PropType != PT_Empty) return r;
			}
			return @propObj;
		}
		else if(items.IsDictionaryObject())
		{
			dictionary@ d = @items;
			return GetProp(item, @d);
		}
		else if(items.IsDictionary())
		{
			dictionary d = items;
			return GetProp(item, d);
		}
		return propObj;
	}
	PropObject@ GetPropValue(string item, Object@ vars, Object@ localvars)
	{
		PropObject@ res = @PropObject();
		if(@localvars !is null)
		{
			@res = @GetPropEx(item, @localvars);
		}
		if(@res is null || res.PropType == PT_Empty)
		{
			@res = @GetPropEx(item, @vars);
		}
		return res;
	}
	AssignResult@ AssignObjectValue(PropObject@ propObj, string op, Object@ value)
	{
		AssignResult@ ar = @AssignResult();
		if (@propObj is null) return ar;
		if(op.Length() > 1)
		{
			@value = @OperatorResult(@propObj.Value, @value , op.SubString(0, op.Length() - 1));
		}
		if(propObj.PropType == PT_Dictionary)
		{
			value.AssignToDictionaryByValueType(@propObj.DictionaryData, propObj.StrIndex);
			ar.Success = true;
		}
		else if(propObj.PropType == PT_Indis)
		{
			@propObj.ArrayData[propObj.IntIndex] = @value;
			ar.Success = true;
		}
		return ar;
	}
}