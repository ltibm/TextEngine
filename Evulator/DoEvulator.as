namespace TextEngine
{
	namespace Evulator
	{
		class DoEvulator : BaseEvulator
		{
			TextEngine::Text::TextEvulateResult@ Render(TextEngine::Text::TextElement@ tag, dictionary@ vars)
			{
				if(this.Evulator.IsParseMode) return null;
				if ((tag.NoAttrib && tag.Value.IsEmpty()) || (!tag.NoAttrib && tag.GetAttribute("c").IsEmpty())) return null;
				TextEngine::Text::TextEvulateResult@ result = TextEngine::Text::TextEvulateResult();
				this.CreateLocals();
				int loop_count = 0;
				result.Result = TextEngine::Text::EVULATE_TEXT;
				while (this.ConditionSuccess(@tag, "*", @vars))
				{
					this.SetLocal("loop_count", Object_Int(loop_count++));
					auto@ cresult = tag.EvulateValue(0, 0, @vars);
					if (@cresult is null) continue;
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
					if (this.Options.Max_DoWhile_Loop != 0 && loop_count - 1 > this.Options.Max_DoWhile_Loop) break;
				} 
				this.DestroyLocals();
				return result;
			}
		}
	}
}
