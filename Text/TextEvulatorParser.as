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
			int TextLength
			{
				get const
				{
					return int(this.Text.Length());
				}
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
					if (tag is null)
					{
						i = this.pos;
						continue;
					}
					@tag.BaseEvulator = @this.Evulator;

					if (!tag.SlashUsed)
					{
						currenttag.AddElement(@tag);
						if (tag.DirectClosed)
						{
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
								prevtag.Closed = true;
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

								prevtag.Closed = true;
								break;
							}
							@prevtag = @this.GetNotClosedPrevTag(@prevtag);


						}
						if (@prevtag == null)
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
			private TextElementsList@ GetNotClosedPrevTagUntil(TextElement@ tag, string name)
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
				bool istextnode = false;
				bool intag = false;
				for (int i = start; i < this.TextLength; i++)
				{
					if (this.Evulator.NoParseEnabled && this.in_noparse)
					{
						istextnode = true;
						tagElement.ElemName = "#text";
						tagElement.ElementType = TextNode;
						tagElement.Closed = true;
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
								if(ampcode.StartsWith("&"))
								{
									SetSyntaxError();
									return null;
								}
								tagElement.AutoClosed = true;
								tagElement.Closed = true;
								tagElement.Value = ampcode;
								tagElement.ElementType = EntityReferenceNode;
								tagElement.ElemName = "#text";
								return @tagElement; 
							}
							else
							{
								if (!intag)
								{
									istextnode = true;
									tagElement.ElemName = "#text";
									tagElement.ElementType = TextNode;
									tagElement.Closed = true;
								}
							}
						}
						if (!inspec && cur == this.Evulator.RightTag)
						{
							if (!intag)
							{
								 SetSyntaxError();
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
							elem.ElemName = this.Evulator.NoParseTag;
							elem.SlashUsed = true;
							this.in_noparse = false;
							return @elem;
						}
						return @tagElement;
					}
					else
					{
						this.ParseTagHeader(@tagElement);
						if(!AllowContinue()) return null;
						intag = false;
						if (this.Evulator.NoParseEnabled && tagElement.ElemName == this.Evulator.NoParseTag)
						{
							this.in_noparse = true;
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
						tagElement.Closed = true;
						tagElement.AutoClosed = true;
						tagElement.ElementType = XMLTag;
						continue;

					}
					if (this.Evulator.SupportExclamationTag && cur == '!' && !namefound && current.Length == 0)
					{
						tagElement.Closed = true;
						tagElement.AutoClosed = true;
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
						tagElement.Closed = true;
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
					if (tagElement.ElementType == Parameter && this.Evulator.ParamNoAttrib)
					{
						if (cur != this.Evulator.RightTag)
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
								SetSyntaxError();
								return;	
							}
						}
					}
					if (cur == '"' || cur == '\'')
					{
						if (!namefound || currentName.Length == 0)
						{
							SetSyntaxError();
							return;
							
						}
						if (inquot && cur == quotchar)
						{
							if (currentName.ToString() == "##set_TAG_ATTR##")
							{
								tagElement.TagAttrib = current.ToString();

							}
							else if (currentName.Length > 0)
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
							tagElement.Closed = true;
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
								lastslashused = true;
							}
							else
							{
								firstslashused = true;
							}
							continue;
						}
						if (cur == '=')
						{
							if (namefound)
							{
								if (current.Length == 0)
								{
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
								currentName.Append("##set_TAG_ATTR##");
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
							if (currentName.ToString() == "##set_TAG_ATTR##")
							{
								tagElement.TagAttrib = current.ToString();
							}
							else if (currentName.Length > 0)
							{
								tagElement.SetAttribute(currentName.ToString(), current.ToString());
							}
							else if (current.Length > 0)
							{
								tagElement.SetAttribute(current.ToString(), "");
							}
							tagElement.SlashUsed = firstslashused;
							if (lastslashused)
							{
								@tagElement.BaseEvulator = @this.Evulator;
								tagElement.DirectClosed = true;
								tagElement.Closed = true;
							}
							if (this.Evulator.AutoClosedTags.find(tagElement.ElemName) >= 0)
							{
								@tagElement.BaseEvulator = @this.Evulator;
								tagElement.Closed = true;
								tagElement.AutoClosed = true;
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
								if (currentName.ToString() == "##set_TAG_ATTR##")
								{
									tagElement.TagAttrib = current.ToString();
									quoted = false;
									currentName.Clear();
									current.Clear();
								}
								else if (!currentName.IsEmpty())
								{
									tagElement.SetAttribute(currentName.ToString(), current.ToString());
									currentName.Clear();
									current.Clear();
									quoted = false;
								}
								else if (!current.IsEmpty())
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
			private string ParseInner()
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
						inspec = true;
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
								if (nparsetext.ToString() == '/' + this.Evulator.NoParseTag)
								{
									parfound = false;
									this.pos = i;
									if (this.Evulator.TrimStartEnd)
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
							if(this.Evulator.TrimStartEnd)
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

				if (this.Evulator.TrimStartEnd)
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
