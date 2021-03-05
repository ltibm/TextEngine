namespace TextEngine
{
	namespace Evulator
	{
		class IncludeEvulator : BaseEvulator
		{
			private string GetFileName(TextEngine::Text::TextElement@ tag, dictionary@ vars)
			{
				bool allowjoker = tag.GetAttribute("joker") == "true";
				string loc = this.EvulateAttribute(@tag.ElemAttr.GetByName('name'), @vars).ToString();
				if(!allowjoker || loc.IsEmpty()) return loc;
				uint find = loc.FindLastOf(".");
				string extension = "";
				if(find != String::INVALID_INDEX)
				{
					extension = loc.SubString(find);
					loc = loc.SubString(0, find);
				}
	
				string new_loc = loc + extension;
				//g_EngineFuncs.ServerPrint("location: " + new_loc);    
				if(!FILEUTIL::Exists(new_loc))
				{
					int ilen = loc.Length();
					for(int i = ilen - 1; i > 0; i--)
					{
						if(loc[i] == "/" || loc[i] == "\\") break;
						new_loc = loc.SubString(0, i) + "+" + extension;
						if(FILEUTIL::Exists(new_loc))
						{
							break;
						}
					}
				}
				return new_loc;
			}
			private string GetLocation(TextEngine::Text::TextElement@ tag, dictionary@ vars)
			{
				string loc = this.GetFileName(@tag, @vars);
				//Object@ evresult = this.EvulateText(loc, @vars);
				//loc = evresult.ToString();
				if(FILEUTIL::Exists(loc)) return loc;
				uint total = 1;
				while(true)
				{
					auto@ alter = @tag.ElemAttr.GetByName("alternate" + total++);
					if(@alter is null || alter.Value.IsEmpty()) break;
					Object@ evresult = @this.EvulateAttribute(@alter, @vars);
					loc = evresult.ToString();
					if(FILEUTIL::Exists(loc)) return loc;
				}
				return "";
			}
			private TextEngine::Text::TextEvulateResult@ RenderDefault(TextEngine::Text::TextElement@ tag, dictionary@ vars)
			{
				if(!this.ConditionSuccess(@tag, "if")) return null;
			    string loc = this.GetFileName(@tag, @vars);
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
					TextEngine::Text::TextElement@ tempelem2 = TextEngine::Text::TextElement();
					tempelem2.ElemName = "#document";		
					@tempelem.BaseEvulator = @this.Evulator;	
					@tempelem2.BaseEvulator = @this.Evulator;					
					string xpath = tag.GetAttribute("xpath");
					bool xpathold = false;
					if(xpath.IsEmpty())
					{
						xpath = tag.GetAttribute("xpath_old");
						xpathold = true;
					}
					this.Evulator.Parse(@tempelem2, content);
					if(xpath.IsEmpty())
					{
						@tempelem = @tempelem2;
					}
					else
					{
						TextEngine::Text::TextElementsList@ elems = null;
						if(!xpathold)
						{
							@elems = @tempelem2.FindByXPath(xpath);
						}
						else
						{
							@elems = @tempelem2.FindByXPathOld(xpath);
						}
						for(int i = 0; i < elems.Count; i++)
						{
							@elems[i].Parent = @tempelem;
							tempelem.SubElements.Add(@elems[i]);
						}
					}
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
