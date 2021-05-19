namespace TextEngine
{
	namespace Evulator
	{
		class SwitchEvulator : BaseEvulator
		{
			TextEngine::Text::TextEvulateResult@ Render(TextEngine::Text::TextElement@ tag, dictionary@ vars)
			{
				if(this.Evulator.IsParseMode) return null;
				TextEngine::Text::TextEvulateResult@ result = TextEngine::Text::TextEvulateResult();
				Object@ cvalue = this.EvulateAttribute(@tag.ElemAttr.GetByName("c"), @vars);
				TextEngine::Text::TextElement@ defaultV;
				TextEngine::Text::TextElement@ active;
				
				for (int i = 0; i < tag.SubElementsCount; i++)
				{
					TextEngine::Text::TextElement@ elem = tag.SubElements[i];
					string lowercase = elem.ElemName;
					lowercase = lowercase.ToLowercase();
					if (lowercase == "default")
					{
						@defaultV = @elem;
						continue;
					}
					else if (lowercase != "case")
					{
						continue;
					}
					if (this.EvulateCase(elem, cvalue.ToString()))
					{
						@active = @elem;
						break;
					}
				}
				if (active is null) @active = @defaultV;
				if (active is null) return result;
				TextEngine::Text::TextEvulateResult@ cresult = active.EvulateValue(0, 0, vars);
				result.TextContent += cresult.TextContent;
				if (cresult.Result == TextEngine::Text::EVULATE_RETURN)
				{
					result.Result = TextEngine::Text::EVULATE_RETURN;
					return result;
				}
				result.Result = TextEngine::Text::EVULATE_TEXT;
				return result;
				
			}
			 protected bool EvulateCase(TextEngine::Text::TextElement@ tag, string svalue)
			{
				string tagvalue = tag.GetAttribute("v");
				return tagvalue.Split('|').find(svalue) >= 0;
			}
		}
	}
}
