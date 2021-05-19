namespace TextEngine
{
	namespace Evulator
	{
		class TextTagCommandEvulator : BaseEvulator
		{
			TextEngine::Text::TextEvulateResult@ Render(TextEngine::Text::TextElement@ tag, dictionary@ vars)
			{
				TextEngine::Text::TextEvulateResult@ result = TextEngine::Text::TextEvulateResult();
				result.Result = TextEngine::Text::EVULATE_NOACTION;
				string str = tag.Value;
				if (str.IsEmpty()) return result;
				array<string> lines = STRINGUTIL::SplitLineWithQuote(str);
				for (uint i = 0; i < lines.length(); i++)
				{
					string line = lines[i];
					line.Trim(" \r\n\t");
					if (line.IsEmpty()) continue;
					this.EvulateText(line, @vars);
				}
				return result;
			}
		}
	}
}
