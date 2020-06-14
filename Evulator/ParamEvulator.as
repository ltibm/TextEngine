namespace TextEngine
{
	namespace Evulator
	{
		class ParamEvulator : BaseEvulator
		{
			TextEngine::Text::TextEvulateResult@ Render(TextEngine::Text::TextElement@ tag, dictionary@ vars)
			{
				if(this.Evulator.IsParseMode) return null;
				TextEngine::Text::TextEvulateResult@ result = TextEngine::Text::TextEvulateResult();
				if (tag.ElementType != TextEngine::Text::Parameter)
				{
					result.Result = TextEngine::Text::EVULATE_NOACTION;
					return result;
				}
				Object@ content = this.EvulateText(tag.ElemName, @vars);
				if(content !is null)
				{
					result.TextContent += content.ToString();
				}
				return result;
			}
		}
	}
}
