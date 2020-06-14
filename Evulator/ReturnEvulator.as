namespace TextEngine
{
	namespace Evulator
	{
		class ReturnEvulator : BaseEvulator
		{
			TextEngine::Text::TextEvulateResult@ Render(TextEngine::Text::TextElement@ tag, dictionary@ vars)
			{
				bool cr = this.ConditionSuccess(@tag, "if");
				if(!cr) return null;
				TextEngine::Text::TextEvulateResult@ result = TextEngine::Text::TextEvulateResult();
				result.Result = TextEngine::Text::EVULATE_RETURN;
				return result;
			}
		}
	}
}
