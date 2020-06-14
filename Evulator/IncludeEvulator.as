namespace TextEngine
{
	namespace Evulator
	{
		class IncludeEvulator : BaseEvulator
		{
			private string GetLocation(TextEngine::Text::TextElement@ tag, dictionary@ vars)
			{
				string loc = tag.GetAttribute("name");
				Object@ evresult = this.EvulateText(loc, @vars);
				loc = evresult.ToString();
				if(FILEUTIL::Exists(loc)) return loc;
				uint total = 1;
				while(true)
				{
					loc = tag.GetAttribute("alternate" + total++);
					if(loc.IsEmpty()) break;
					@evresult = @this.EvulateText(loc, @vars);
					loc = evresult.ToString();
					if(FILEUTIL::Exists(loc)) return loc;
				}
				return "";
			}
			private TextEngine::Text::TextEvulateResult@ RenderDefault(TextEngine::Text::TextElement@ tag, dictionary@ vars)
			{
				if(!this.ConditionSuccess(@tag, "if")) return null;
			    string loc = GetLocation(@tag, @vars);
				if(loc.IsEmpty()) return null;
				string parse = tag.GetAttribute("parse", "true");
				string content = FILEUTIL::ReadAllText(loc);
				if(content.IsEmpty()) return null;
				TextEngine::Text::TextEvulateResult@ result = TextEngine::Text::TextEvulateResult();
				if (parse == "false")
				{
					result.Result = TextEngine::Text::EVULATE_TEXT;
					result.TextContent = content + "\n";
				}
				else
				{
					TextEngine::Text::TextElement@ tempelem = TextEngine::Text::TextElement();
					tempelem.ElemName = "#document";
					@tempelem.BaseEvulator = @this.Evulator;
					this.Evulator.Parse(@tempelem, content);
					TextEngine::Text::TextEvulateResult@ cresult = tempelem.EvulateValue(0, 0, vars);
					result.TextContent += cresult.TextContent + "\n";
					if (cresult.Result == TextEngine::Text::EVULATE_RETURN)
					{
						result.Result = TextEngine::Text::EVULATE_RETURN;
						return result;
					}
					result.Result = TextEngine::Text::EVULATE_TEXT;
				}
				return result;
			}
			TextEngine::Text::TextEvulateResult@ Render(TextEngine::Text::TextElement@ tag, dictionary@ vars)
			{
				if(!this.Evulator.IsParseMode) return this.RenderDefault(@tag, @vars);
				TextEngine::Text::TextEvulateResult@ result = TextEngine::Text::TextEvulateResult();
				if(this.Evulator.IsParseMode && this.ConditionSuccess(@tag, "if"))
				{
					
					string loc =  GetLocation(@tag, @vars);
					string xpath = tag.GetAttribute("xpath");
					bool xpathold = false;
					if(xpath.IsEmpty())
					{
						xpath = tag.GetAttribute("xpath_old");
						xpathold = true;
					}
					if(!loc.IsEmpty())
					{
						string content = FILEUTIL::ReadAllText(loc);
						if(!content.IsEmpty())
						{
							if(xpath.IsEmpty())
							{
								this.Evulator.Parse(@tag.Parent, content);	
							}
							else
							{
								TextEngine::Text::TextElement@ tempitem = TextEngine::Text::TextElement();
								tempitem.ElemName = "#document";
								this.Evulator.Parse(@tempitem, content);	
								TextEngine::Text::TextElementsList@ elems = null;
								if(!xpathold)
								{
									@elems = @tempitem.FindByXPath(xpath);
								}
								else
								{
									@elems = @tempitem.FindByXPathOld(xpath);
								}
								for(int i = 0; i < elems.Count; i++)
								{
									@elems[i].Parent = @tag.Parent;
									tag.Parent.SubElements.Add(@elems[i]);
								}
							}
								
						}
					}
				}
				tag.Parent.SubElements.Remove(@tag);
				result.Result = TextEngine::Text::EVULATE_NOACTION;
				return result;
			}
		}
	}
}
