#include "../TextEngine/Par"
void PluginInit()
{	
	
	g_Module.ScriptInfo.SetAuthor( "Lt." );
	g_Module.ScriptInfo.SetContactInfo( "https://steamcommunity.com/id/ibmlt" );
	g_EngineFuncs.ServerPrint("Lt - Par Examples Loaded");
	//TextEngine::ParDecoder::ParDecode@ pd = TextEngine::ParDecoder::ParDecode("5 + ((3 * 6 + 2 + 2 * 6) * 2 + 5"); //Result 74
	dictionary@ vars = dictionary();
	vars.set("item1", 100);
	vars.set("current_map", @Object_Function(@FN_map));
	TextEngine::ParDecoder::ParDecode@ pd = TextEngine::ParDecoder::ParDecode("(current_map() == 'auspices')"); //Result 1 (true)
	pd.Decode();
	TextEngine::ParDecoder::ComputeResult@ result = pd.Items.Compute(@vars);
	Object@ objresult = result.Result[0];
	if(objresult !is null)
	{
		PrintLine("Null değil: " + objresult.ToString());
	}

}
Object@ FN_map(Objects@ parameters)
{
	int param1 = parameters[0]; //parameter 1
	return Object_String(g_Engine.mapname);
}
void PrintLine(string str)
{
	g_EngineFuncs.ServerPrint("\r\n" + str + "\r\n");
}
