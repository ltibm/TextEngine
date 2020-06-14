//Author: Lt.
//https://steamcommunity.com/id/ibmlt
//TextEngine Version 1.0 Beta

namespace TextEngine
{
	void RegisterXPathUserFunctions(TextEngine::XPathClasses::XPathFunctions@ funcbase)
	{
		funcbase.AddFunction("map", @XPFuncCustom_CurrentMap);
	}
	Object@ XPFuncCustom_CurrentMap(TextEngine::XPathClasses::XPathFunctions@ sender, Objects@ parameters)
	{
		return @Object(g_Engine.mapname);
	}
}
