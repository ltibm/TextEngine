namespace TextEngine
{
	namespace Evulator
	{
		class UnsetEvulator : BaseEvulator
		{
			TextEngine::Text::TextEvulateResult@ Render(TextEngine::Text::TextElement@ tag, dictionary@ vars)
			{
				TextEngine::Text::TextEvulateResult@ result = TextEngine::Text::TextEvulateResult();
				bool conditionok = this.ConditionSuccess(@tag, "if");
				result.Result = TextEngine::Text::EVULATE_NOACTION;
				if(conditionok)
				{
					string defname = tag.GetAttribute("name");
					if(defname.IsEmpty() || !isalnum(defname)) return result;
					this.Evulator.DefineParameters.delete(defname);
				}
				return result;
			}
		}
	}
}
