#include "../TextEngine/TextEngine"

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Lt." );
	g_Module.ScriptInfo.SetContactInfo( "https://steamcommunity.com/id/ibmlt" );
	g_EngineFuncs.ServerPrint("Lt - XML Examples Loaded");
	//TextEngine::Text::TextEvulator@ te =  TextEngine::Text::TextEvulator("<?xml version=\"1.0\" encoding=\"UTF - 8\"?><mapsettings><mapsetting>MacMillan</mapsetting><mapsetting name=\"svencoop\" ><cvar name=\"sv_cheats\" value=\"3\" /></mapsetting><mapsetting name=\"auspices2\" /><mapsetting name=\"auspices\"><cvar name=\"sv_gravity\" value=\"300\" /><cvar name=\"sv_cheats\" value=\"3\" /></mapsetting></mapsettings>");
	MapInit();
}
void MapInit()
{
	TextEngine::Text::TextEvulator@ te = TextEngine::Text::TextEvulator("scripts/plugins/store/lt_xml_example.xml", true);
	te.AllowParseCondition = true;
	dictionary@ globals = dictionary();
	globals.set("map", @Object_Function(@Func_Map));
	globals.set("max_players", @Object_Function(@Func_MaxPlayers));
	@te.GlobalParameters = @globals;
	te.ApplyXMLSettings();
	te.Parse();
	//Get currently map configiration cvar, cvar elements must be have name and value attributes.
	//TextEngine::Text::TextElementsList@ elems = te.Elements.FindByXPath("//mapsetting[lower-case(@name) = current-map()]/cvar[@name and @value]");
	TextEngine::Text::TextElementsList@ elems = te.Elements.FindByXPath("//cvar[@name and @value]");
	if(elems.Any())
	{
		for(int i = 0; i < elems.Count; i++)
		{
			TextEngine::Text::TextElement@ element = elems[i];
			//element.SetAttribute("name", "sv_test");
			//element.SetAttribute("value", "1234");
			//element.SetInnerText("This is inner text");
			//element.SetInner("<item>Value</item>")
			string cvarname = element.GetAttribute("name");
			string cvarvalue = element.GetAttribute("value");
			PrintLine("Cvar: " + cvarname + " will changed '" +  cvarvalue +  "'");
			g_EngineFuncs.ServerCommand(cvarname + " " + cvarvalue + "\r\n");
		}
	}
	te.SaveToFile("scripts/plugins/store/lt_xml_example_saved.xml");

}
Object@ Func_MaxPlayers(Objects@ parameters)
{
	return Object_Int(g_Engine.maxClients);
}
Object@ Func_Map(Objects@ parameters)
{
	return @Object(g_Engine.mapname);
}
void PrintLine(string str)
{
	g_EngineFuncs.ServerPrint("\r\n" + str + "\r\n");
}