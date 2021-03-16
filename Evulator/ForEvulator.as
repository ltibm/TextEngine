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
				auto@ startAttr = @tag.ElemAttr.GetByName("start");
				string start = "";
				if(@startAttr !is null) start = startAttr.Value;
				auto@ stepAttr = @tag.ElemAttr.GetByName("step");
				string step = "";
				if(@stepAttr !is null) step = stepAttr.Value;
				if (start.IsEmpty())
				{
					start = "0";
				}
				if (step.IsEmpty() || step == "0")
				{
					step = "1";
				}
				auto@ toAttr = tag.ElemAttr.GetByName("to");
				if (varname.IsEmpty() && step.IsEmpty() && (@toAttr is null || toAttr.Value.IsEmpty()))
				{
					return null;
				}
				Object@ startres = null;
				Object@ stepres = null;
				if(@startAttr !is null)
				{
					if (@startAttr.ParData is null)
					{
						@startAttr.ParData = TextEngine::ParDecoder::ParDecode(start);
						startAttr.ParData.Decode();
					}
					@startres = @this.EvulatePar(@startAttr.ParData);
				}
				else
				{
					@startres = @Object_Int(0);
				}
				if(@stepAttr !is null)
				{
					if (@stepAttr.ParData is null)
					{
						@stepAttr.ParData = TextEngine::ParDecoder::ParDecode(step);
						stepAttr.ParData.Decode();
					}
					@stepres = @this.EvulatePar(@stepAttr.ParData);
				}
				else
				{
					@stepres = @Object_Int(1);
				}
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
				Object@ tores = this.EvulateAttribute(@toAttr);
				if (!tores.IsNumericType())
				{
					return null;
				}
				tonum = tores;
				TextEngine::Text::TextEvulateResult@ result = TextEngine::Text::TextEvulateResult();
				this.CreateLocals();
				for (int i = startnum; i < tonum; i += stepnum)
				{
					this.SetLocal(varname, Object_Int(i));
					TextEngine::Text::TextEvulateResult@ cresult = tag.EvulateValue(0, 0, @vars);
					if (cresult is null) continue;
					result.TextContent += cresult.TextContent;
					if (cresult.Result == TextEngine::Text::EVULATE_RETURN)
					{
						result.Result = TextEngine::Text::EVULATE_RETURN;

						this.DestroyLocals();
						return result;
					}
					else if (cresult.Result == TextEngine::Text::EVULATE_BREAK)
					{
						break;
					}
				}
				this.DestroyLocals();
				result.Result = TextEngine::Text::EVULATE_TEXT;
				return result;
			}
		}
	}
}
