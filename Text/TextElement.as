namespace TextEngine
{
	namespace Text
	{
	    class TextElement
		{
			TextElement()
			{
				this.ElementType = ElementNode;
				@this.SubElements = TextElementsList();
				@this.ElemAttr = TextElementAttributesList();
			}
			private TextEngine::ParDecoder::ParDecode@ parData;
			TextEngine::ParDecoder::ParDecode@ ParData 
			{
				get
				{
					return this.parData;
				}
				set
				{
					@this.parData = @value;
				}
			}			
			int Depth 
			{
				get const
				{
					TextElement@ parent = @this.Parent;
					int total = 0;
					while (@parent != @null && parent.ElemName != "#document")
					{
						total++;
						@parent = @parent.Parent;
					}
					return total;
				}
			}

			private string elemName;
			string ElemName
			{
				get const { return elemName; }
				set { 
					elemName = value; 
					this.NoAttrib = false;
                    if (this.BaseEvulator !is null && ((this.GetTagFlags() & TEF_NoAttributedTag) != TEF_NONE))
                    {
                        this.NoAttrib = true;
                    }
				}
			}
			private TextElementAttributesList@ elemAttr;
			TextElementAttributesList@ ElemAttr
			{
				get const { return elemAttr; }
				set { @elemAttr = @value; }
			}
			private TextElementType elementType;
			TextElementType ElementType 
			 {
				get const
				{
				   return elementType;
				}
				set
				{
				   elementType = value;
				}
			 }
			private TextEvulator@ baseEvulator;
			TextEvulator@ BaseEvulator 
			 {
				get const
				{
				   return @baseEvulator;
				}
				set
				{
				   @baseEvulator = @value;
				}
			 }
			private bool closed;
			bool Closed
			{
				get const { return closed; }
				set
				{
					closed = value;
					if(this.BaseEvulator !is null)
					{
						this.BaseEvulator.OnTagClosed(@this);
					}
				}
			}
			private string value;

			string Value
			{
				get const { return value; }
				set { 
					@this.ParData = null;
					this.value = value; 
				}
			}
			private TextElementsList@ subElements;
			TextElementsList@ SubElements
			{
				get const { return subElements; }
				set { @subElements = @value; }
			}
			TextElement@ FirstChild
			{
				get const

				{
					if (this.SubElementsCount > 0) return @this.SubElements[0];
					return null;
				}
			}
			TextElement@ LastChild
			{
				get const
				{
					if (this.SubElementsCount > 0)
						return @this.SubElements[this.SubElementsCount - 1];
					return @null;
				}
			}
			int SubElementsCount { get const { return SubElements.Count; } }
			private bool slashused;
			bool SlashUsed
			{
				get const { return slashused; }
				set { this.slashused = value; }
			}
			private TextElement@ parent;
			TextElement@ Parent
			{
				get const { return @parent; }
				set { @this.parent = @value; }
			}
			private bool directclosed;
			bool DirectClosed
			{
				get const { return directclosed; }
				set { this.directclosed = value; }
			}

			private bool autoadded;
			bool AutoAdded
			{
				get const { return autoadded; }
				set { this.autoadded = value; }
			}
			private string aliasName;
			string AliasName
			{
				get const { return aliasName; }
				set { this.aliasName = value; }
			}
			private bool autoclosed;
			bool AutoClosed
			{
				get const { return autoclosed; }
				set { this.autoclosed = value; }
			}
			private bool noAttrib;
			bool NoAttrib
			{
				get const { return noAttrib; }
				set { this.noAttrib = value; }
			}
			private int index;
			int Index
			{
				get const
				{ 
					if(this.Parent is null) return -1;
					return this.Parent.SubElements.GetItemIndex(@this);
				}
				set 
				{ 
					//this.index = value; 
				}
			}
			private string tag_attrib;
			string TagAttrib
			{
				get const { return tag_attrib; }
				set { this.tag_attrib = value; }
			}
			void AddElement(TextElement@ element)
			{
				element.Index = this.SubElements.Count;
				this.SubElements.Add(@element);
			}
			string GetAttribute(string name, string defvalue = "")
			{
				return this.ElemAttr.GetAttribute(name, defvalue);
			}
			bool GetAttributeBool(string name, bool defvalue = false)
			{
				int def = 0;
				if(defvalue) def = 1;
				string s = this.GetAttribute(name, "false");
				if(s.ToLowercase() == "true") return true;
				return atoi(s) > 0;
			}
			int GetAttributeInt(string name, int defvalue = 0)
			{
				string attr = this.GetAttribute(name, defvalue);
				return atoi(attr);
			}
			float GetAttributeFloat(string name, float defvalue = 0)
			{
				string attr = this.GetAttribute(name, defvalue);
				return atof(attr);
			}
			int InnerTextInt()
			{
				string s = this.InnerText();
				return atoi(s);
			}
			float InnerTextFloat()
			{
				string s = this.InnerText();
				return atof(s);
			}
			bool InnerTextBool()
			{
				string s = this.InnerText();
				if(s.ToLowercase() == "true") return true;
				return atoi(s) > 0;
			}
			void SetAttribute(string name, string value)
			{
				this.ElemAttr.SetAttribute(name, value);
			}
			bool NameEquals(string name, bool matchalias = false)
			{
				if (this.ElemName == name) return true;
				if (matchalias)
				{
					if (this.BaseEvulator.Aliasses.exists(name))
					{
						string alias;
						this.BaseEvulator.Aliasses.get(name, alias);
						if (alias == this.ElemName) return true;
						return true;
					}
					else if(this.BaseEvulator.Aliasses.exists(this.ElemName))
					{
						string alias;
						this.BaseEvulator.Aliasses.get(this.ElemName, alias);
						if (alias == name) return true;
						return true;
					}
				}
				return false;
			}
			TextElement@ SetInner(string text)
			{
				this.SubElements.Clear();
				this.BaseEvulator.Parse(@this, text);
				return @this;
			}
			TextElement@ SetInnerText(string text)
			{
				string newtext = text;
				array<string> keys = this.BaseEvulator.AmpMaps.getKeys();
				for(uint i = 0; i < keys.length(); i++)
				{
					string item;
					this.BaseEvulator.AmpMaps.get(keys[i], item);
					newtext = newtext.Replace(keys[i], item);
				}
				this.SetInner(text);
				return @this;
			}
			string Outer(bool outputformat = false)
			{
				if (this.ElemName == "#document")
				{
					return this.Inner();
				}
				if (this.ElemName == "#text")
				{
					return this.value;
				}
				if (this.ElementType == CommentNode)
				{	
					StringBuilder@ ctext = StringBuilder();
					if(outputformat)
					{
						ctext.AppendChar('\t', this.Depth);
					}
					ctext.Append(string(this.BaseEvulator.LeftTag) + "!--" + this.Value + "--" + string(this.BaseEvulator.RightTag));
					ctext.Append("\n");
					return ctext.ToString();
				}
				StringBuilder@ text = StringBuilder();
				StringBuilder@ additional = StringBuilder();
				if (!this.TagAttrib.IsEmpty())
				{
					additional.Append("=" + this.TagAttrib);
				}
				if (this.ElementType == Parameter)
				{
					text.Append(string(this.BaseEvulator.LeftTag) + string(this.BaseEvulator.ParamChar) + this.ElemName + ((this.NoAttrib && this.ElementType == ElementNode)  ?  " " + this.Value : HTMLUTIL::ToAttribute(@this.ElemAttr)) + string(this.BaseEvulator.RightTag));
				}
				else
				{
					if (this.AutoAdded)
					{
						if (this.SubElementsCount == 0) return "";
					}
					text.Append(string(this.BaseEvulator.LeftTag) + this.ElemName + additional.ToString() + HTMLUTIL::ToAttribute(@this.ElemAttr));
					if (this.DirectClosed)
					{
						text.Append(" /" + string(this.BaseEvulator.RightTag));
					}
					else if (this.AutoClosed)
					{
						text.Append(string(this.BaseEvulator.RightTag));
					}
					else
					{
						text.Append(string(this.BaseEvulator.RightTag));
						text.Append(this.Inner(outputformat));
						string eName = this.ElemName;
						if (!this.AliasName.IsEmpty())
						{
							eName = this.AliasName;
						}
						text.Append(string(this.BaseEvulator.LeftTag) + '/' + eName + string(this.BaseEvulator.RightTag));
					}
				}
				return text.ToString();
			}
			string Header(bool outputformat = false)
			{
				if (this.AutoAdded && this.SubElementsCount == 0) return "";
				StringBuilder@ text = StringBuilder();
				if (outputformat)
				{
					text.AppendChar('\t', this.Depth);
				}
				if (this.ElementType == XMLTag)
				{
					text.Append(string(this.BaseEvulator.LeftTag) + "?" + this.ElemName + HTMLUTIL::ToAttribute(@this.ElemAttr) + "?" + string(this.BaseEvulator.RightTag));
				}
				if (this.ElementType == Parameter)
				{
					text.Append(string(this.BaseEvulator.LeftTag) + string(this.BaseEvulator.ParamChar) + this.ElemName + HTMLUTIL::ToAttribute(@this.ElemAttr) + string(this.BaseEvulator.RightTag));
				}
				else if (this.ElementType == ElementNode)
				{
					StringBuilder@ additional = StringBuilder();
					if (!this.TagAttrib.IsEmpty())
					{
						additional.Append('=' + this.TagAttrib);
					}
					text.Append(string(this.BaseEvulator.LeftTag) + this.ElemName + additional.ToString() + ((this.NoAttrib) ?  " " + this.Value : HTMLUTIL::ToAttribute(@this.ElemAttr)));
					if (this.DirectClosed)
					{
						text.Append(" /" + string(this.BaseEvulator.RightTag));
					}
					else if (this.AutoClosed)
					{
						text.Append(string(this.BaseEvulator.RightTag));
					}
					else
					{
						text.Append(string(this.BaseEvulator.RightTag));

					}
				}
				else if (this.ElementType == CDATASection)
				{
					text.Append(string(this.BaseEvulator.LeftTag) + "![CDATA[" + this.Value + "]]" + string(this.BaseEvulator.RightTag));
				}
				else if (this.ElementType == CommentNode)
				{
					text.Append(string(this.BaseEvulator.LeftTag) + "--" + this.Value + "--" + string(this.BaseEvulator.RightTag));
				}
				if(outputformat && (this.FirstChild is null || this.FirstChild.ElemName != "#text"))
				{
					text.Append("\n");
				}
				return text.ToString() ;
			}
			string Footer(bool outputformat = false)
			{
				if (this.SlashUsed || this.DirectClosed || this.AutoClosed) return "";
				StringBuilder@ text = StringBuilder();
				if (this.ElementType == ElementNode)
				{
					if (outputformat )
					{
						if(@this.LastChild != null && this.LastChild.ElemName != "#text")
						{
							text.AppendChar('\t', this.Depth);
						}
					}
					string eName = this.ElemName;
					if (!this.AliasName.IsEmpty())
					{
						eName = this.AliasName;
					}
					text.Append(string(this.BaseEvulator.LeftTag) + '/' + eName + string(this.BaseEvulator.RightTag));

				}
				if(outputformat)
				{
					text.Append("\n");
				}
				return text.ToString();
			}
			string Inner(bool outputformat = false)
			{
				StringBuilder@ text = StringBuilder();

				if (this.ElementType == CommentNode || this.ElementType == XMLTag)
				{
					return text.ToString();
				}
				if (this.ElemName == "#text" || this.ElementType == CDATASection)
				{
					if(this.ElementType == EntityReferenceNode)
					{
						text.Append("&" + this.Value + ";");
						return text.ToString();
					}
					text.Append(this.Value);
					return text.ToString();
				}
				if (this.SubElementsCount == 0) return text.ToString();
				for(int i = 0; i < this.SubElements.Count; i++)
				{
					TextElement@ subElement = @this.SubElements[i];
					if (subElement.ElemName == "#text")
					{
						text.Append(subElement.Inner(outputformat));
					}
					else if (subElement.ElementType == CDATASection)
					{
						text.Append(subElement.Header());
					}
					else if (subElement.ElementType == CommentNode)
					{
						text.Append(subElement.Outer(outputformat));
					}
					else if (subElement.ElementType == Parameter)
					{
						text.Append(subElement.Header());
					}
					else
					{
						text.Append(subElement.Header(outputformat));
						text.Append(subElement.Inner(outputformat));
						text.Append(subElement.Footer(outputformat));
					}
				}
				return text.ToString();
			}
			TextElement@ PreviousElementWN(array<string> names)
			{
				TextElement@ prev = @this.PreviousElement();
				while (@prev != null)
				{
					if (prev.ElementType == Parameter || prev.ElemName == "#text")
					{
						@prev = @prev.PreviousElement();
						continue;
					}
					if (MISCUTIL::InStringArray(prev.ElemName, names))
					{
						return @prev;
					}
					@prev = @prev.PreviousElement();
				}
				return @null;
			}
			TextElement@ NextElementWN(array<string> names)
			{
				TextElement@ next = this.NextElement();
				while (@next != null)
				{
					if (next.ElementType == Parameter || next.ElemName == "#text")
					{
						@next = @next.NextElement();
						continue;
					}
					if (MISCUTIL::InStringArray(next.ElemName, names))
					{
						return next;
					}
					@next = @next.NextElement();
				}
				return null;
			}
			TextElement@ PreviousElement()
			{
				if (this.Index - 1 >= 0)
				{
					return @this.Parent.SubElements[this.Index - 1];
				}
				return @null;
			}
			TextElement@ NextElement()
			{
				if (this.Index + 1 < this.Parent.SubElementsCount)
				{
					return @this.Parent.SubElements[this.Index + 1];
				}
				return null;
			}
			TextElement@ GetSubElement(array<string> names)
			{

				for (int i = 0; i < this.SubElementsCount; i++)
				{
					if (MISCUTIL::InStringArray(this.SubElements[i].ElemName, names))
					{
						return @this.SubElements[i];
					}
				}
				return @null;
			
			}
			string InnerText()
			{
				if (this.ElemName == "#text" || this.ElementType == CDATASection)
				{
					if(this.ElementType == EntityReferenceNode)
					{
						string nval = "";
						if(this.BaseEvulator.AmpMaps.exists(this.Value))
						{
							this.BaseEvulator.AmpMaps.get(this.Value, nval);
						}
						return nval;
					}
					return this.Value;
				}
				StringBuilder@ text = StringBuilder();
				if (this.SubElementsCount == 0) return text.ToString();
				for(int i = 0; i < this.SubElements.Count; i++)
				{
					TextElement@ subElement = @this.SubElements[i];
					if (subElement.ElemName == "#text" || subElement.ElementType == CDATASection)
					{
						if (subElement.ElementType == EntityReferenceNode)
						{
							string nval = "";
							if(this.BaseEvulator.AmpMaps.exists(subElement.Value))
							{
								this.BaseEvulator.AmpMaps.get(subElement.Value, nval);
							}
							text.Append(nval);
						}
						else
						{
							text.Append(subElement.Value);

						}
					}
					else
					{
						text.Append(subElement.InnerText());
					}

				}
				return text.ToString();
			}
			TextEvulateResult@ EvulateValue(int start = 0, int end = 0, dictionary@ vars = null)
			{
				TextEvulateResult@ result = TextEvulateResult();
				if (this.ElementType == CommentNode)
				{
					return null;
				}
				if (this.ElemName == "#text")
				{
					if(@this.BaseEvulator.EvulatorTypes.Text !is null)
					{
						TextEngine::Evulator::BaseEvulator@ evulator = @this.BaseEvulator.EvulatorTypes.Text;
						evulator.SetEvulator(@this.BaseEvulator);
						return evulator.Render(@this, @vars);
					}
					result.TextContent = this.Value;
					return result;
				}
				if (this.ElementType == Parameter)
				{
					if (this.BaseEvulator.EvulatorTypes.Param !is null)
					{
						TextEngine::Evulator::BaseEvulator@ evulator = @this.BaseEvulator.EvulatorTypes.Param;
						evulator.SetEvulator(@this.BaseEvulator);
						TextEvulateResult@ vresult = evulator.Render(@this, @vars);
						result.Result = vresult.Result;
						if (vresult.Result == EVULATE_TEXT)
						{
							result.TextContent += vresult.TextContent;
						}
						return result;
					}
				}
				if (end == 0 ||end > this.SubElementsCount) end = this.SubElementsCount;
				for (int i = start; i < end; i++)
				{
					TextElement@ subElement = this.SubElements[i];
					if(subElement is null) continue;
					TextEngine::Evulator::BaseEvulator@ targetType = null;
	
					if (subElement.ElementType == Parameter)
					{
						@targetType = @this.BaseEvulator.EvulatorTypes.Param;
					}
					else
					{
						if (subElement.ElemName != "#text")
						{
							@targetType = @this.BaseEvulator.EvulatorTypes[subElement.ElemName];
							if (targetType is null)
							{
								@targetType = @this.BaseEvulator.EvulatorTypes.GeneralType;
							}
						}

					}
					TextEvulateResult@ vresult = null;
					if (targetType !is null)
					{
						targetType.SetEvulator(this.BaseEvulator);
						@vresult = @targetType.Render(subElement, vars);
						if (vresult is null)
						{
							targetType.RenderFinish(subElement, vars, @vresult);
							continue;
						}
						
						if (vresult.Result == EVULATE_DEPTHSCAN)
						{
							@vresult = @subElement.EvulateValue(vresult.Start, vresult.End, @vars);
						}
						targetType.RenderFinish(subElement, vars, @vresult);
						if(vresult is null) continue;
					}
					else
					{
						@vresult = @subElement.EvulateValue(0, 0, @vars);
						if (vresult is null) continue;
					}
					if (vresult.Result == EVULATE_TEXT)
					{
						result.TextContent += vresult.TextContent;
					}
					else if (vresult.Result == EVULATE_RETURN || vresult.Result == EVULATE_BREAK || vresult.Result == EVULATE_CONTINUE)
					{

						result.Result = vresult.Result;
						result.TextContent += vresult.TextContent;
						break;
					}
				}
				return @result;
			}
			TextElementsList@ GetElementsHasAttributes(string name, bool depthscan = false, int limit = 0)
			{
				TextElementsList@ elements = TextElementsList();
				string lower = name.ToLowercase();
				for (int i = 0; i < this.subElements.Count; i++)
				{
					TextElement@ elem = this.subElements[i];
					if (elem.ElemAttr.Count > 0 && lower == "*")
					{
						elements.Add(@elem);
					}
					else
					{
                   if(elem.ElemAttr.HasAttribute(lower))
                   {
                     elements.Add(@elem);
                   }
					}

					if (depthscan && elem.SubElementsCount > 0)
					{
						elements.AddRange(@elem.GetElementsHasAttributes(name, depthscan));
					}

				}
				return @elements;
			}
			TextElementsList@ GetElementsByTagName(string name, bool depthscan = false, int limit = 0)
			{

				TextElementsList@ elements = TextElementsList();
				string lower = name.ToLowercase();
				for (int i = 0; i < this.subElements.Count; i++)
				{
					TextElement@ elem = this.subElements[i];
					if (elem.ElemName == lower || lower == "*")
					{
						elements.Add(@elem);
						if (limit > 0 && elements.Count >= limit)
						{
							break;
						}
					}
					if (depthscan && elem.SubElementsCount > 0)
					{
						elements.AddRange(@elem.GetElementsByTagName(name, depthscan));
					}

				}
				return @elements;
			}
			TextElementsList@ FindByXPath(TextEngine::XPathClasses::XPathBlock@ block)
			{
				TextElementsList@ foundedElems = TextElementsList();
				if (block.IsAttributeSelector)
				{
					@foundedElems = @this.GetElementsHasAttributes(block.BlockName, block.BlockType == TextEngine::XPathClasses::XPathBlockScanAllElem);
				}
				else
				{
					if (!block.BlockName.IsEmpty())
					{
						if(block.BlockName == ".")
						{
							foundedElems.Add(@this);
							return foundedElems;
						}
						else if(block.BlockName == "..")
						{
							foundedElems.Add(@this.Parent);
							return foundedElems;

						}
						else
						{
							@foundedElems = @this.GetElementsByTagName(block.BlockName, block.BlockType == TextEngine::XPathClasses::XPathBlockScanAllElem);
						}
					}
				}
				if(block.XPathExpressions.Count > 0 && foundedElems.Count > 0)
				{

					for (int i = 0; i < block.XPathExpressions.Count; i++)
					{
						TextEngine::XPathClasses::XPathExpression@ exp = @block.XPathExpressions[i];
						@foundedElems = @TextEngine::XPathClasses::XPathAction_Eliminate(@foundedElems, @any(@exp), TextEngine::XPathClasses::XPathExpType_XPathExpression);
						if(foundedElems.Count == 0 )
						{
							break;
						}
					}
				}
				return @foundedElems;
			}
			TextElementsList@ FindByXPath(string xpath)
			{
				TextElementsList@ elements = TextElementsList();
				TextEngine::XPathClasses::XPathItem@ xpathItem = @TextEngine::XPathClasses::Parse_XPathItemNew(xpath);
				@elements = @this.FindByXPathByBlockContainer(@xpathItem.XPathBlockList);
				elements.SortItems();
				return elements;
			}
			TextElementsList@ FindByXPathByBlockContainer(TextEngine::XPathClasses::XPathBlocksContainer@ container, TextElementsList@ senderitems = null)
			{
				TextElementsList@ elements = TextElementsList();
				bool inor = true;
				for (int i = 0; i < container.Count; i++)
				{
					TextEngine::XPathClasses::IXPathList@ curblocks = container[i];
					if(curblocks.IsOr())
					{
						inor = true;
						continue;
					}
					if(!inor)
					{

						if (curblocks.IsBlocks())
						{
							@elements  = @this.FindByXPathBlockList(cast<TextEngine::XPathClasses::XPathBlocksList@>(curblocks), @elements);
						}
						else
						{
							elements.AddRange(@this.FindByXPathPar(cast<TextEngine::XPathClasses::XPathPar@>(curblocks), @senderitems));
						}
					}
					else
					{
						if (curblocks.IsBlocks())
						{
							elements.AddRange(@this.FindByXPathBlockList(cast<TextEngine::XPathClasses::XPathBlocksList@>(curblocks)));
						}
						else
						{
							elements.AddRange(@this.FindByXPathPar(cast<TextEngine::XPathClasses::XPathPar@>(curblocks)));
						}
					}

					inor = false;
				}
				
				return elements;
			}
			TextElementsList@ FindByXPathPar(TextEngine::XPathClasses::XPathPar@ xpar, TextElementsList@ senderitems = null)
			{
				TextElementsList@ elements = TextElementsList();
				@elements = @this.FindByXPathByBlockContainer(@xpar.XPathBlockList, @senderitems);
				if (xpar.XPathExpressions.Count > 0 && elements.Count > 0)
				{
					elements.SortItems();
					for (int j = 0; j < xpar.XPathExpressions.Count; j++)
					{
						TextEngine::XPathClasses::XPathExpression@ exp = xpar.XPathExpressions[j];
						@elements = @TextEngine::XPathClasses::XPathAction_Eliminate(@elements, @any(@exp), TextEngine::XPathClasses::XPathExpType_XPathExpression);
						if (elements.Count == 0)
						{
							break;
						}
					}
				}
				return elements;
			}
			TextElementsList@ FindByXPathBlockList(TextEngine::XPathClasses::XPathBlocksList@ blocks, TextElementsList@ senderlist = null)
			{
				TextElementsList@ elements = senderlist;
				for (int i = 0; i < blocks.Count; i++)
				{
					TextEngine::XPathClasses::XPathBlock@ xblock = blocks[i];
					if (i == 0 && senderlist is null)
					{
						@elements = @FindByXPath(@xblock);
					}
					else
					{
						@elements = @elements.FindByXPath(@xblock);
					}
				}
				return elements;
			}
			TextElementsList@ FindByXPathOld(string xpath)
			{
				TextElementsList@ elements = TextElementsList();
				TextEngine::XPathClasses::XPathFunctions@ fn =  TextEngine::XPathClasses::XPathFunctions();
				TextEngine::XPathClasses::XPathItem@ xpathblock = @TextEngine::XPathClasses::Parse_XPathItem(xpath);
				TextEngine::XPathClasses::XPathActions@ actions =  TextEngine::XPathClasses::XPathActions();
				@actions.XPathFunctions =  TextEngine::XPathClasses::XPathFunctions();
				for (int i = 0; i < xpathblock.XPathBlocks.Count; i++)
				{
					TextEngine::XPathClasses::XPathBlock@ xblock = @xpathblock.XPathBlocks[i];
					if (i == 0)
					{
						@elements = @this.FindByXPath(@xblock);
					}
					else
					{
						TextElementsList@ newelements = TextElementsList();
						for (int j = 0; j < elements.Count; j++)
						{
							TextElement@ elem = elements[j];
							TextElementsList@ nextelems = @elem.FindByXPath(xblock);
							for (int k = 0; k < nextelems.Count; k++)
							{
								if (newelements.Contains(@nextelems[k])) continue;
								newelements.Add(@nextelems[k]);
							}
						}
						@elements = @newelements;
					}
				}
				return @elements;
			}
			TextElementInfo@ GetTagInfo()
			{
				if (@this.BaseEvulator is null) return null;
				if (this.BaseEvulator.TagInfos.HasTagInfo(this.ElemName)) return this.BaseEvulator.TagInfos[this.ElemName];
				if (this.BaseEvulator.TagInfos.HasTagInfo("*")) return this.BaseEvulator.TagInfos["*"];
				return null;
			}
			int GetTagFlags()
			{
				auto@ info = @this.GetTagInfo();
				if (@info is null) return TEF_NONE;
				return info.Flags;
			}
			void SetTextTag(bool closetag = false)
			{
				this.ElemName = "#text";
				this.ElementType = TextNode;
				if(closetag) this.Closed = true;
			}
		}
	}
}
