namespace TextEngine
{
	namespace Evulator
	{
		class NoPrintEvulator : BaseEvulator
		{
			TextEngine::Text::TextEvulateResult@ Render(TextEngine::Text::TextElement@ tag, dictionary@ vars)
			{
				tag.EvulateValue(0, 0, @vars);
				return null;
			}
		}
	}
}
