namespace TextEngine
{
	namespace Evulator
	{
		class TextParamEvulator : BaseEvulator
		{
			TextEngine::Text::TextEvulateResult@ Render(TextEngine::Text::TextElement@ tag, dictionary@ vars)
			{
				TextEngine::Text::TextEvulateResult@ result = TextEngine::Text::TextEvulateResult();
				result.Result = TextEngine::Text::EVULATE_TEXT;
				for (int i = 0; i < tag.SubElementsCount; i++)
				{
					TextEngine::Text::TextElement@ elem = tag.SubElements[i];
					if(elem.ElementType == TextEngine::Text::TextNode)
					{
						result.TextContent += elem.Value;
					}
					else if(elem.ElementType == TextEngine::Text::Parameter)
					{
						result.TextContent += elem.EvulateValue().TextContent;
					}
				}
				return result;
			}
		}
	}
}
