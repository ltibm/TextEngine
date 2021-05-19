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
				if(@tag.ParData is null)
				{
					@tag.ParData = @this.CreatePardecode(tag.ElemName);
				}
				
				Object@ content = this.EvulatePar(@tag.ParData, @vars);
				if(content !is null)
				{
					result.TextContent += content.ToString();
				}
				return result;
			}
		}
	}
}
