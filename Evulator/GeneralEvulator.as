namespace TextEngine
{
	namespace Evulator
	{
		class GeneralEvulator : BaseEvulator
		{
			TextEngine::Text::TextEvulateResult@ Render(TextEngine::Text::TextElement@ tag, dictionary@ vars)
			{
				TextEngine::Text::TextEvulateResult@ result = TextEngine::Text::TextEvulateResult();
				result.Result = TextEngine::Text::EVULATE_DEPTHSCAN;
				return result;
			}
		}
	}
}
