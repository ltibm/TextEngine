//Author: Lt.
//https://steamcommunity.com/id/ibmlt
//TextEngine Version 1.0 Beta

namespace TextEngine
{
	void RegisterXPathFunctions(TextEngine::XPathClasses::XPathFunctions@ funcbase)
	{
		funcbase.AddFunction("text", @XPFunc_Text);
		funcbase.AddFunction("contains", @XPFunc_Contains);
		funcbase.AddFunction("lower-case", @XPFunc_LowerCase);
		funcbase.AddFunction("upper-case", @XPFunc_UpperCase);
		funcbase.AddFunction("starts-with", @XPFunc_StartsWith);
		funcbase.AddFunction("ends-with", @XPFunc_EndsWith);
		funcbase.AddFunction("last", @XPFunc_Last);
		funcbase.AddFunction("position", @XPFunc_Position);
		RegisterXPathUserFunctions(@funcbase);
	}
	Object@ XPFunc_Text(TextEngine::XPathClasses::XPathFunctions@ sender, Objects@ parameters)
	{
		return @Object(sender.BaseItem.InnerText());
	}
	Object@ XPFunc_Contains(TextEngine::XPathClasses::XPathFunctions@ sender, Objects@ parameters)
	{
		Object@ result = Object();
		if(parameters.Count != 2)
		{
			result.SetValueBool(false);
		}
		else
		{
			string stra = parameters[0].ToString();
			string strb = parameters[1].ToString();
			result.SetValueBool(stra.Find(strb) != String::INVALID_INDEX);
		}
		return @result;
	}	
	Object@ XPFunc_LowerCase(TextEngine::XPathClasses::XPathFunctions@ sender, Objects@ parameters)
	{
		Object@ result = Object();
		if(parameters.Count != 1)
		{
			result.SetValueBool(false);
		}
		else
		{
			string stra = parameters[0].ToString().ToLowercase();
			result.SetValue(stra);
		}

		return @result;
	}	
	Object@ XPFunc_UpperCase(TextEngine::XPathClasses::XPathFunctions@ sender, Objects@ parameters)
	{
		Object@ result = Object();
		if(parameters.Count != 1)
		{
			result.SetValueBool(false);
		}
		else
		{
			string stra = parameters[0].ToString().ToUppercase();
			result.SetValue(stra);
		}
		return @result;
	}	
	Object@ XPFunc_StartsWith(TextEngine::XPathClasses::XPathFunctions@ sender, Objects@ parameters)
	{
		Object@ result = Object();
		if(parameters.Count != 2)
		{
			result.SetValueBool(false);
		}
		else
		{
			string stra = parameters[0].ToString();
			string strb = parameters[1].ToString();
			result.SetValueBool(stra.StartsWith(strb));
		}
		return @result;
	}	
	Object@ XPFunc_EndsWith(TextEngine::XPathClasses::XPathFunctions@ sender, Objects@ parameters)
	{
		Object@ result = Object();
		if(parameters.Count != 2)
		{
			result.SetValueBool(false);
		}
		else
		{
			string stra = parameters[0].ToString();
			string strb = parameters[1].ToString();
			result.SetValueBool(stra.EndsWith(strb));
		}
		return @result;
	}
	Object@ XPFunc_Last(TextEngine::XPathClasses::XPathFunctions@ sender, Objects@ parameters)
	{
		Object@ obj = Object();
		obj.SetValueInt(sender.TotalItems);
		return @obj;
	}
	Object@ XPFunc_Position(TextEngine::XPathClasses::XPathFunctions@ sender, Objects@ parameters)
	{
		Object@ obj = Object();
		obj.SetValueInt(sender.BaseItem.Index + 1);
		return @obj;
	}
}
