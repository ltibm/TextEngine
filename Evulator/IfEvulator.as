namespace TextEngine
{
	namespace Evulator
	{
		class IfEvulator : BaseEvulator
		{
		    private TextEngine::Text::TextEvulateResult@ RenderDefault(TextEngine::Text::TextElement@ tag, dictionary@ vars)
			{
				TextEngine::Text::TextEvulateResult@ result = TextEngine::Text::TextEvulateResult();
				if(this.ConditionSuccess(@tag))
				{
					TextEngine::Text::TextElement@ elseitem = tag.GetSubElement({"elif", "else"});
					if (elseitem !is null)
					{
						result.End = elseitem.Index;
					}
					result.Result = TextEngine::Text::EVULATE_DEPTHSCAN;
				}
				else
				{
					TextEngine::Text::TextElement@ elseitem = tag.GetSubElement({"elif", "else"});
					while (elseitem !is null)
					{
						if (elseitem.ElemName == "else")
						{
							result.Start = elseitem.Index + 1;
							result.Result = TextEngine::Text::EVULATE_DEPTHSCAN;
							return result;
						}
						else
						{

							if (this.ConditionSuccess(@elseitem))
							{
								result.Start = elseitem.Index + 1;
								TextEngine::Text::TextElement@ nextelse = elseitem.NextElementWN({"elif", "else"});
								if (nextelse !is null)
								{
									result.End = nextelse.Index;
								}
								result.Result = TextEngine::Text::EVULATE_DEPTHSCAN;
								return result;
							}
						}
						@elseitem = @elseitem.NextElementWN({"elif", "else"});
					}
					if (elseitem is null)
					{
						return result;
					}
				}
				return result;
			}
			TextEngine::Text::TextEvulateResult@ Render(TextEngine::Text::TextElement@ tag, dictionary@ vars)
			{
				if(!this.Evulator.IsParseMode) return RenderDefault(@tag, @vars);
				TextEngine::Text::TextEvulateResult@ result = TextEngine::Text::TextEvulateResult();
				bool conditionok = this.ConditionSuccess(@tag);
				bool sil = false;
				for (int i = 0; i < tag.SubElementsCount; i++)
				{
					TextEngine::Text::TextElement@ sub = tag.SubElements[i];
					if (!conditionok || sil)
					{
						if(!sil)
						{
							if (sub.ElemName == "else")
							{
								conditionok = true;
							}
							else if (sub.ElemName == "elif")
							{
								conditionok = this.ConditionSuccess(@sub);
							}
						}

						tag.SubElements.RemoveAt(i);
						i--;
						continue;
					}
					else
					{
						if(sub.ElemName == "else" || sub.ElemName == "elif")
						{
							sil = true;
							i--;
							continue;
						}
						sub.Index = tag.Parent.SubElements.Count;
						@sub.Parent = @tag.Parent;
						tag.Parent.SubElements.Add(@sub);
					}
				}
				tag.Parent.SubElements.Remove(@tag);
				result.Result = TextEngine::Text::EVULATE_NOACTION;
				return result;
			}
		}
	}
}
