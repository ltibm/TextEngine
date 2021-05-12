//Author: Lt.
//https://steamcommunity.com/id/ibmlt
namespace TextEngine
{
	namespace Text
	{
	    class TextEvulatorParser
		{
			private TextEvulator@ evulator;
		    TextEvulator@ Evulator
			{
				get const
				{
					return evulator;
				}
			}
			TextEvulatorParser(TextEvulator@ baseevulator)
			{
				@this.evulator = @baseevulator;
			}
			private bool syntaxError;
			bool SyntaxError
			{
				get const
				{
					return syntaxError;
				}
				set
				{
					syntaxError = value;
				}
			}
			private string text;
			string Text 
			{ 
				get const
				{
					return text;
				}
				set
				{
					text = value;
				}
			}
			private int pos = 0;
			private bool in_noparse = false;
			private string noparse_tag = "";
			int TextLength
			{
				get const
				{
					return int(this.Text.Length());
				}
			}
			private void OnTagClosed(TextElement@ element)
			{
				if(@element.TagInfo !is null && @element.TagInfo.OnTagClosed !is null) element.TagInfo.OnTagClosed(@element);
			}
			private void OnTagOpened(TextElement@ element)
			{
				if(@element.TagInfo !is null && @element.TagInfo.OnTagOpened !is null) element.TagInfo.OnTagOpened(@element);
			}
			void Parse(TextElement@ baseitem,string text)
			{
				this.Text = text;
				this.Evulator.IsParseMode = true;
				this.SyntaxError = false;
				TextElement@ currenttag = null;
				if (baseitem is null)
				{
					@currenttag = @this.Evulator.Elements;
				}
				else
				{
					@currenttag = @baseitem;
				}
				@currenttag.BaseEvulator = @this.Evulator;
				for (int i = 0; i < TextLength; i++)
				{
					TextElement@ tag = @this.ParseTag(i, @currenttag);
					if(!AllowContinue()) 
					{
						this.Evulator.IsParseMode = false;
						return;
					}
					if (tag is null || tag.ElemName.IsEmpty())
					{
						i = this.pos;
						continue;
					}

					if (!tag.SlashUsed)
					{
						this.OnTagOpened(@tag);
						if (tag.HasFlag(TEF_AutoCloseIfSameTagFound))
						{
							auto@ prev = @this.GetNotClosedPrevTagWithName(@tag, tag.ElemName);
							if (@prev !is null && !prev.Closed)
							{
								prev.CloseState = TECT_AUTOCLOSED;
								this.OnTagClosed(@prev);
								@currenttag = @this.GetNotClosedPrevTag(@prev);
								@tag.Parent = @currenttag;
								if (@currenttag is null && this.Evulator.ThrowExceptionIFPrevIsNull && !this.Evulator.SurpressError)
								{
									this.Evulator.IsParseMode = false;
									this.SyntaxError = true;
									//throw new Exception("Syntax Error");
								}
								else if(@currenttag is null)
								{
									continue;
								}
							}
						}
						currenttag.AddElement(@tag);
						if (tag.DirectClosed)
						{
							this.OnTagClosed(@tag);
							this.Evulator.OnTagClosed(@tag);
						}
					}
					if (tag.SlashUsed)
					{
						TextElement@ prevtag = @this.GetNotClosedPrevTag(@tag);
						TextElement@ previtem = null;
						while (@prevtag != null)
						{

							if (!prevtag.NameEquals(tag.ElemName, true))
							{
								TextElement@ elem = TextElement();
								elem.ElemName = prevtag.ElemName;
								@elem.ElemAttr = @prevtag.ElemAttr.Clone();
								elem.AutoAdded = true;
								@elem.BaseEvulator = @this.Evulator;
								prevtag.CloseState = TECT_CLOSED;
								this.OnTagClosed(@prevtag);
								bool  allowautocreation = !elem.HasFlag(TEF_PreventAutoCreation) && (@elem.TagInfo.OnAutoCreating is null || elem.TagInfo.OnAutoCreating(@elem));
								if(allowautocreation)
								{
									if (@previtem != null)
									{
										@previtem.Parent = @elem;
										elem.AddElement(@previtem);
									}
									else
									{
										@currenttag = @elem;
									}
									@previtem = @elem;
								}


							}
							else
							{
								if (prevtag.ElemName != tag.ElemName)
								{
									prevtag.AliasName = tag.ElemName;
								}
								if (@previtem != null)
								{
									@previtem.Parent = @prevtag.Parent;
									previtem.Parent.AddElement(@previtem);
								}
								else
								{
									@currenttag = @prevtag.Parent;
								}

								prevtag.CloseState = TECT_CLOSED;
								this.OnTagClosed(@prevtag);
								break;
							}
							@prevtag = @this.GetNotClosedPrevTag(@prevtag);


						}
						if (@prevtag == null && this.Evulator.ThrowExceptionIFPrevIsNull && !this.Evulator.SurpressError)
						{
							SetSyntaxError();
							this.Evulator.IsParseMode = false;
							return;
							
						}
					}
					else if (!tag.Closed)
					{
						@currenttag = @tag;
					}
					i = this.pos;
				}
				this.pos = 0;
				this.in_noparse = false;
				this.noparse_tag = "";
				this.Evulator.IsParseMode = false;
			}
			private bool AllowContinue()
			{
				if(this.SyntaxError)
				{
					return false;
				}
				return true;
			}
			private void SetSyntaxError()
			{
				this.SyntaxError = true;
				//throw new Exception("Syntax Error");
			}
			private TextElement@ GetNotClosedPrevTagWithName(TextElement@ tag, string name)
			{
				TextElement@ stag = this.GetNotClosedPrevTag(@tag);
				while (@stag != null)
				{
					if (stag.ElemName == name)
					{
						return stag;
					}
				}
				return null;
			}
			private TextElementsList@ GetNotClosedPrevTagsUntil(TextElement@ tag, string name)
			{
				TextElementsList@ array = TextElementsList();
				TextElement@ stag = this.GetNotClosedPrevTag(@tag);
				while (@stag != null)
				{

					if (stag.ElemName == name)
					{
						array.Add(@stag);
						break;
					}
					array.Add(@stag);
					@stag = this.GetNotClosedPrevTag(@stag);
				}
				return @array;
			}

			private TextElement@ GetNotClosedPrevTag(TextElement@ tag)
			{
				TextElement@ parent = tag.Parent;
				while (@parent != null)
				{
					if (parent.Closed || parent.ElemName == "#document")
					{
						return null;
					}
					return @parent;
				}
				return null;
			}

			private TextElement@ GetNotClosedTag(TextElement@ tag, string name)
			{
				TextElement@ parent = tag.Parent;
				while (@parent != null)
				{
					if (parent.Closed) return null;
					if (parent.NameEquals(name))
					{
						return parent;
					}
					@parent = @parent.Parent;
				}
				return null;
			}
			private string DecodeAmp(int start, bool decodedirect = true)
			{
				StringBuilder@ current = StringBuilder();

				for (int i = start; i < this.TextLength; i++)
				{
					char cur = this.Text[i];
					if (cur == ';')
					{
						this.pos = i;
						if(decodedirect)
						{
							if(this.Evulator.AmpMaps.exists(current.ToString()))
							{
								string key;
								this.Evulator.AmpMaps.get(current.ToString(), key);
								return key;
							}
						}
						else
						{
							return current.ToString();
						}

						return "";
					}
					if (!isalnum(cur))
					{
						break;
					}
					current.Append(cur);
				}
				this.pos = this.TextLength;
				return "&" + current.ToString();
			}
			private TextElement@ ParseTag(int start, TextElement@ parent = null)
			{
				bool inspec = false;
				TextElement@ tagElement = TextElement();
				@tagElement.Parent = @parent;
				@tagElement.BaseEvulator = @this.Evulator;
				bool istextnode = false;
				bool intag = false;
				for (int i = start; i < this.TextLength; i++)
				{
					if (this.Evulator.NoParseEnabled && this.in_noparse)
					{
						istextnode = true;
						tagElement.SetTextTag(true);
					}
					else
					{
						char cur = this.Text[i];
						if (!inspec)
						{
							if (cur == this.Evulator.LeftTag)
							{
								if (intag)
								{
									if(this.Evulator.SurpressError)
									{
										tagElement.SetTextTag(true);
										tagElement.Value = this.Text.SubString(start, i - start);
										this.pos = i - 1;
										return @tagElement;
									}
									SetSyntaxError();
									return null;
								}
								intag = true;
								continue;
							}
							else if(this.Evulator.DecodeAmpCode && cur == '&')
							{
								string ampcode = this.DecodeAmp(i + 1, false);
								i = this.pos;
								tagElement.SetTextTag(true);
								tagElement.ElementType = EntityReferenceNode;
								if(ampcode.StartsWith("&"))
								{
									if(this.Evulator.SurpressError)
									{
										tagElement.ElementType = TextNode;
									}
									else
									{
										SetSyntaxError();
										return null;
									}
	
								}
								tagElement.CloseState = TECT_AUTOCLOSED;
								tagElement.Value = ampcode;
								return @tagElement; 
							}
							else
							{
								if (!intag)
								{
									istextnode = true;
									tagElement.SetTextTag(true);
								}
							}
						}
						if (!inspec && cur == this.Evulator.RightTag)
						{
							if (!intag)
							{
								if(this.Evulator.SurpressError)
								{
									tagElement.SetTextTag(true);
									tagElement.Value = this.Text.SubString(start, i - start);
									this.pos = i - 1;
									return @tagElement;
								}
								SetSyntaxError();
								return null;
							}
							intag = false;
						}
					}
					this.pos = i;
					if (!intag || istextnode)
					{
						tagElement.Value = this.ParseInner();
						if(!AllowContinue()) return null;
						if(!this.in_noparse && tagElement.ElementType == TextNode && tagElement.Value.IsEmpty())
						{
							
							return null;
						}
						intag = false;
						if (this.in_noparse)
						{
							parent.AddElement(@tagElement);
							TextElement@ elem = TextElement();
							@elem.Parent = @parent;
							elem.ElemName = this.noparse_tag;
							elem.SlashUsed = true;
							this.in_noparse = false;
							this.noparse_tag = "";
							return @elem;
						}
						return @tagElement;
					}
					else
					{
						this.ParseTagHeader(@tagElement);
						if(tagElement.ElemName.IsEmpty()) return null;
						if(!AllowContinue()) return null;
						intag = false;
						if (this.Evulator.NoParseEnabled && (tagElement.GetTagFlags() & TEF_NoParse) > 0)
						{
							this.in_noparse = true;
							this.noparse_tag = tagElement.ElemName;
						}
						return @tagElement;

					}
				}
				return @tagElement;
			}
			private void ParseTagHeader(TextElement@ tagElement)
			{
				bool inquot = false;
				bool inspec = false;
				StringBuilder@ current = StringBuilder();
				bool namefound = false;
				//bool inattrib = false;
				bool firstslashused = false;
				bool lastslashused = false;
				StringBuilder@ currentName = StringBuilder();
				bool quoted = false;
				char quotchar = '\0';
				bool initial = false;
				bool istagattrib = false;
				for (int i = this.pos; i < this.TextLength; i++)
				{
					char cur = this.Text[i];
					if (inspec)
					{
						inspec = false;
						current.Append(cur);
						continue;
					}
					char next = '\0';
					char next2 = '\0';
					if (i + 1 < this.TextLength)
					{
						next = this.Text[i + 1];
					}
					if (i + 2 < this.TextLength)
					{
						next2 = this.Text[i + 2];
					}
					if (tagElement.ElementType == CDATASection)
					{
						if(cur == ']' && next == ']' && next2 == this.Evulator.RightTag)
						{
							tagElement.Value = current.ToString();
							this.pos  = i += 2;
							return;
						}
						current.Append(cur);
						continue;
					}
					if(this.Evulator.AllowXMLTag && cur == '?' && !namefound && current.Length == 0)
					{
						tagElement.CloseState = TECT_AUTOCLOSED;
						tagElement.ElementType = XMLTag;
						continue;

					}
					if (this.Evulator.SupportExclamationTag && cur == '!' && !namefound && current.Length == 0)
					{
						tagElement.CloseState = TECT_AUTOCLOSED;
						if(i + 8 < this.TextLength)
						{
							string mtn = this.Text.SubString(i, 8);
							if(this.Evulator.SupportCDATA && mtn == "![CDATA[")
							{
								tagElement.ElementType = CDATASection;
								tagElement.ElemName = "#cdata";
								namefound = true;
								i += 7;
								continue;
							}
						}
					}
					if (cur == '\\' && tagElement.ElementType != CommentNode )
					{
						if (!namefound && tagElement.ElementType != Parameter)
						{
							if(this.Evulator.SurpressError) continue;
							SetSyntaxError();
							return;
						}
						inspec = true;
						continue;
					}

					if (!initial && cur == '!' && next == '-' && next2 == '-')
					{
						tagElement.ElementType =  CommentNode;
						tagElement.ElemName = "#summary";
						tagElement.CloseState = TECT_CLOSED;
						i += 2;
						continue;
					}
					if (tagElement.ElementType == CommentNode)
					{
						if (cur == '-' && next == '-' && next2 == this.Evulator.RightTag)
						{
							tagElement.Value = current.ToString();
							this.pos = i + 2;
							return;
						}
						else
						{
							current.Append(cur);
						}
						continue;
					}
					initial = true;
					if (this.Evulator.DecodeAmpCode && tagElement.ElementType != CommentNode && cur == '&')
					{
						current.Append(this.DecodeAmp(i + 1));
						i = this.pos;
						continue;
					}
					if ((tagElement.ElementType == Parameter && this.Evulator.ParamNoAttrib)
					|| (namefound && tagElement.NoAttrib) || (istagattrib && tagElement.HasFlag(TEF_TagAttribonly)))
					{
						if ((cur != this.Evulator.RightTag || tagElement.ElementType == Parameter) || cur != this.Evulator.RightTag && (cur != '/' && next != this.Evulator.RightTag || (tagElement.HasFlag(TEF_DisableLastSlash))))
						{
							current.Append(cur);
							continue;
						}
					}

					if (firstslashused && namefound)
					{
						if (cur != this.Evulator.RightTag)
						{
							if (cur == ' ' && next != '\t' && next != ' ')
							{
								if(this.Evulator.SurpressError) continue;
								SetSyntaxError();
								return;	
							}
						}
					}
					if (cur == '"' || cur == '\'')
					{
						if (!namefound || currentName.Length == 0)
						{
							if(this.Evulator.SurpressError) continue;
							SetSyntaxError();
							return;
							
						}
						if (inquot && cur == quotchar)
						{
							if (istagattrib)
							{
								tagElement.TagAttrib = current.ToString();
								istagattrib = false;
							}
							else if (!tagElement.HasFlag(TEF_TagAttribonly) && currentName.Length > 0)
							{
								tagElement.ElemAttr.SetAttribute(currentName.ToString(), current.ToString());
							}
							currentName.Clear();
							current.Clear();
							inquot = false;
							quoted = true;
							continue;
						}
						else if (!inquot)
						{
							quotchar = cur;
							inquot = true;
							continue;
						}
					}
					if (!inquot)
					{
						if (cur == this.Evulator.ParamChar && !namefound && !firstslashused)
						{
							tagElement.ElementType =  Parameter;
							tagElement.CloseState = TECT_CLOSED;
							continue;
						}
						if (cur == '/')
						{
							if (!namefound && current.Length > 0)
							{
								namefound = true;
								tagElement.ElemName = current.ToString();
								current.Clear();
							}
							if (namefound)
							{
								if(next == this.Evulator.RightTag && !tagElement.HasFlag(TEF_DisableLastSlash))
								{
									lastslashused = true;
								}
							}
							else
							{
								firstslashused = true;
							}
							if(tagElement.HasFlag(TEF_DisableLastSlash))
							{
								current.Append(cur);
							}
							continue;
						}
						if (cur == '=')
						{
							if (namefound)
							{
								if(istagattrib)
								{
									current.Append(cur);
									continue;
								}
								if (current.Length == 0)
								{
									if(this.Evulator.SurpressError) continue;
									SetSyntaxError();
									return;
									
								}
								currentName.Clear();
								currentName.Append(current.ToString());
								current.Clear();
							}
							else
							{
								namefound = true;
								tagElement.ElemName = current.ToString();
								current.Clear();
								currentName.Clear();
								istagattrib = true;
							}
							continue;
						}
						if(tagElement.ElementType == XMLTag)
						{
							if(cur == '?' && next == this.Evulator.RightTag)
							{
								cur = next;
								i++;
							}
						}

						if (cur == this.Evulator.LeftTag)
						{
							if(this.Evulator.SurpressError) continue;
							SetSyntaxError();
							return;
							
						}
						if (cur == this.Evulator.RightTag)
						{
							if (!namefound)
							{
								tagElement.ElemName = current.ToString();
								current.Clear();
							}
							if(tagElement.NoAttrib)
							{
								tagElement.Value = current.ToString();
							}
							else if (istagattrib)
							{
								tagElement.TagAttrib = current.ToString();
								istagattrib = false;
							}
							else if (!tagElement.HasFlag(TEF_TagAttribonly) && currentName.Length > 0)
							{
								tagElement.SetAttribute(currentName.ToString(), current.ToString());
							}
							else if (!tagElement.HasFlag(TEF_TagAttribonly) && current.Length > 0)
							{
								tagElement.SetAttribute(current.ToString(), "");
							}
							tagElement.SlashUsed = firstslashused;
							if (lastslashused)
							{
								@tagElement.BaseEvulator = @this.Evulator;
								tagElement.CloseState = TECT_DIRECTCLOSED;
							}
							string elname = tagElement.ElemName;
							elname = elname.ToLowercase();
							
							if ((this.Evulator.TagInfos.GetElementFlags(elname) & TEF_AutoClosedTag) != TEF_NONE)
							{
								@tagElement.BaseEvulator = @this.Evulator;
								tagElement.CloseState = TECT_AUTOCLOSED;
							}
							this.pos = i;
							return;
						}
						if (cur == ' ')
						{
							if (next == ' ' || next == '\t' || next == this.Evulator.RightTag) continue;
							if (!namefound && !current.IsEmpty())
							{
								namefound = true;
								tagElement.ElemName = current.ToString();
								current.Clear();
							}
							else if (namefound)
							{
								if (istagattrib)
								{
									tagElement.TagAttrib = current.ToString();
									istagattrib = false;
									quoted = false;
									currentName.Clear();
									current.Clear();
								}
								else if (!tagElement.HasFlag(TEF_TagAttribonly) && !currentName.IsEmpty())
								{
									tagElement.SetAttribute(currentName.ToString(), current.ToString());
									currentName.Clear();
									current.Clear();
									quoted = false;
								}
								else if (!tagElement.HasFlag(TEF_TagAttribonly) && !current.IsEmpty())
								{
									tagElement.SetAttribute(current.ToString(), "");
									current.Clear();
									quoted = false;
								}
							}
							continue;
						}
					}
					current.Append(cur);
				}
				this.pos = this.TextLength;
			}
			private string ParseInner(bool allowtrim = true)
			{
				StringBuilder@ text = StringBuilder();
				bool inspec = false;
				StringBuilder@ nparsetext = StringBuilder();
				bool parfound = false;
				StringBuilder@ waitspces = StringBuilder();

				for (int i = this.pos; i < this.TextLength; i++)
				{
					char cur = this.Text[i];
					char next = '\0';
					if(i + 1 < this.TextLength)
					{
						next = this.Text[i + 1];
					}
					if (inspec)
					{
						inspec = false;
						text.Append(cur);
						continue;
					}
					if (cur == '\\')
					{
	                    if (this.Evulator.SpecialCharOption == SCT_AllowedAll ||  (this.Evulator.SpecialCharOption == SCT_AllowedClosedTagOnly && next == this.Evulator.RightTag))
						{
							inspec = true;
							continue;
						}
					}
					if(this.Evulator.AllowCharMap && cur != this.Evulator.LeftTag && cur != this.Evulator.RightTag && this.Evulator.CharMap.exists(cur))
					{
						string map;
						this.Evulator.CharMap.get(cur, map);
						if(parfound)
						{
							nparsetext.Append(map);
						}
						else
						{
							text.Append(map);
						}
						continue;
					}
					//if (this.DecodeAmpCode && cur == '&')
					//{
					//    text.Append(this.DecodeAmp(i + 1));
					//    i = this.pos;
					//    continue;
					//}
					if (this.Evulator.NoParseEnabled && this.in_noparse)
					{
						if (parfound)
						{
							if (cur == this.Evulator.LeftTag || cur == '\r' || cur == '\n' || cur == '\t' || cur == ' ')
							{
								text.Append(string(this.Evulator.LeftTag) + nparsetext.ToString());
								parfound = (cur == this.Evulator.LeftTag);
								nparsetext.Clear();
							}
							else if (cur == this.Evulator.RightTag)
							{
								string stra = this.noparse_tag;
								if (nparsetext.ToString().ToLowercase() == '/' + stra.ToLowercase())
								{
									parfound = false;
									this.pos = i;
									if (this.Evulator.TrimStartEnd && allowtrim)
									{
										string str = text.ToString();
										str = STRINGUTIL::Trim(str);
										return str;
									}
									return text.ToString();
								}
								else
								{
									text.Append(string(this.Evulator.LeftTag) + nparsetext.ToString() + string(cur));
									parfound = false;
									nparsetext.Clear();
								}
								continue;
							}

						}
						else
						{
							if (cur == this.Evulator.LeftTag)
							{
								parfound = true;
								continue;
							}
						}
					}
					else
					{
						if (!inspec && cur == this.Evulator.LeftTag || this.Evulator.DecodeAmpCode && cur == '&')
						{
							this.pos = i - 1;
							if(this.Evulator.TrimStartEnd && allowtrim)
							{
								string str = text.ToString();
								str = STRINGUTIL::Trim(str);
								return str;
							}
							return text.ToString();
						}
					}
					if (parfound)
					{
						nparsetext.Append(cur);
					}
					else
					{
						if(this.Evulator.TrimMultipleSpaces)
						{
							if (cur == ' ' && next == ' ') continue;
						}
						text.Append(cur);
					}
				}
				this.pos = this.TextLength;

				if (this.Evulator.TrimStartEnd && allowtrim)
				{
					string str = text.ToString();
					str = STRINGUTIL::Trim(str);
					return str;
				}
				return text.ToString();
			}
		}
	}
}
