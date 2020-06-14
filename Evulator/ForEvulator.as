namespace TextEngine
{
	namespace Evulator
	{
		class ForEvulator : BaseEvulator
		{
			TextEngine::Text::TextEvulateResult@ Render(TextEngine::Text::TextElement@ tag, dictionary@ vars)
			{
				if(this.Evulator.IsParseMode) return null;
				string varname = tag.GetAttribute("var");
				string start = tag.GetAttribute("start");
				string step = tag.GetAttribute("step");
				if (start.IsEmpty())
				{
					start = "0";
				}
				if (step.IsEmpty() || step == "0")
				{
					step = "1";
				}
				string to = tag.GetAttribute("to");
				if (varname.IsEmpty() && step.IsEmpty() && to.IsEmpty())
				{
					return null;
				}
				Object@ startres = this.EvulateText(start);
				Object@ stepres = this.EvulateText(step);
				int startnum = 0;
				int stepnum = 0;
				int tonum = 0;
				if (!startres.IsNumericType())
				{
					stepnum = 1;
				}
				else
				{
					stepnum = stepres;
				}
				if(startres.IsNumericType())
				{
					startnum = startres;
				}
				Object@ tores = this.EvulateText(to);
				if (!tores.IsNumericType())
				{
					return null;
				}
				tonum = tores;
				TextEngine::Text::TextEvulateResult@ result = TextEngine::Text::TextEvulateResult();
				dictionary@ svar = dictionary();
				for (int i = startnum; i < tonum; i += stepnum)
				{
					svar.set(varname, i);
					this.Evulator.LocalVariables.Add(@svar);
					TextEngine::Text::TextEvulateResult@ cresult = tag.EvulateValue(0, 0, @vars);
					if (cresult is null) continue;
					result.TextContent += cresult.TextContent;
					if (cresult.Result == TextEngine::Text::EVULATE_RETURN)
					{
						result.Result = TextEngine::Text::EVULATE_RETURN;
						this.Evulator.LocalVariables.Remove(@svar);
						return result;
					}
					else if (cresult.Result == TextEngine::Text::EVULATE_BREAK)
					{
						break;
					}
				}
				this.Evulator.LocalVariables.Remove(@svar);
				result.Result = TextEngine::Text::EVULATE_TEXT;
				return result;
			}
		}
	}
}
