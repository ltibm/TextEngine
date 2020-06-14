#include "../TextEngine/Json"
void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Lt." );
	g_Module.ScriptInfo.SetContactInfo( "https://steamcommunity.com/id/ibmlt" );
	g_EngineFuncs.ServerPrint("Lt - Json Examples Loaded");
	//Parse from text
	//TextEngine::Json::JsonItem@ jsonItem = TextEngine::Json::Json_Decode("{'item': 'value', 'item2': 'value2', 'subitem': {'subname': 'subvalue', 'subname2': 'subvalue3'}}");
	//or Parse from file.
	TextEngine::Json::JsonItem@ jsonItem = TextEngine::Json::Json_DecodeFromFile("scripts/plugins/store/lt_json_example.json");
	TextEngine::Json::JsonItem@ find = jsonItem.Evulate("obj.obj_var");
	if(find !is null)
	{
		//Set currenty  obj.obj_var value to string 300
		find = "\"300\"";
		
		
		//Set currenty obj.obj_var valute to json 
		find = "{\"rand\": \"next\"}";
		

		TextEngine::Json::JsonItem@ next = find.Evulate("rand");
		dictionary values;
		values.set("item1", "value1");
		values.set("item2", "value2");
		values.set("item3", "1234");
		array<string> arr =
		{
			"arrobj1",
			"arrobj2",
			"arrobj3",
			"arrobj4",
			"124",
			"true"
		};
		values.set("item4", arr);

		//IF set second parameter true, variant type will detected.
		next.SetValueAny(any(values), false);
		TextEngine::Json::JsonItem@ nextfind  	= find.Evulate("rand.item4");
		//array<string> lists = nextfind.GetValueArrayString();
		//or below
		array<string> lists;
		lists = nextfind;
		for(uint i = 0; i < lists.length(); i++)
		{
			PrintLine("Included Values: " + lists[i]);
		}
	
	}
	//Save to file with tabformatted.
	PrintLine(jsonItem.ToJson());
	jsonItem.SaveToFile("scripts/plugins/store/lt_json_example_saved.json");
}
void PrintLine(string str)
{
	g_EngineFuncs.ServerPrint("\r\n" + str + "\r\n");
}
