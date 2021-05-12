namespace TextEngine
{
	namespace ParDecoder
	{
		
		funcdef int OnGetFlagsHandler();
		funcdef bool OnSetFlagsHandler(int);
		class ParDecode
		{
			private bool surpressError;
			bool SurpressError 
			{ 
				get const
				{
					return surpressError;
				}					
				set
				{
					surpressError = value;
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
			private int TextLength 
			{ 
				get 
				{ 
					return int(this.Text.Length()); 
				} 
			}
			private int pos;
			private ParItem@ items;
			ParItem@ Items
			{
				get const 
				{
					 return items; 
				}
				set
				{
					@items = @value;
				}
			}
			OnGetFlagsHandler@ OnGetFlags;
			OnSetFlagsHandler@ OnSetFlags;
			private int flags;
		    int Flags
			{
				get
				{
					if (@this.OnGetFlags !is null) return this.OnGetFlags();
					return this.flags;
				}
				set
				{
					if (@this.OnSetFlags !is null && this.OnSetFlags(value)) return;
					this.flags = value;
				}
			}
			ParDecode(string text)
			{
				this.Text = text;
				@this.Items = ParItem();
				@this.Items.BaseDecoder = @this;
				this.Items.ParName = "(";
				this.Flags = PDF_AllowMethodCall | PDF_AllowSubMemberAccess | PDF_AllowArrayAccess;
			}
			void Decode()
			{
				InnerItem@ parentItem = this.Items;
				for (int i = 0; i < this.TextLength; i++)
				{
					char cur = this.Text[i];
					if (cur == '(' || cur == '[' || cur == '{')
					{
						ParItem@ item = ParItem();
						@item.Parent = @parentItem;
						@item.BaseDecoder = @this;
						item.ParName = cur;
						parentItem.InnerItems.Add(@item);
						@parentItem = @item;
						continue;
					}
					else if (cur == ')' || cur == ']' || cur == '}')
					{
						@parentItem = @parentItem.Parent;
						if (parentItem is null)
						{
							return;
							//throw new Exception("Syntax Error");
						}
						continue;
					}
					InnerItemsList@ result = this.DecodeText(i);
					parentItem.InnerItems.AddRange(@result);
					i = this.pos;
				}
			}
			private InnerItemsList DecodeText(int start, bool autopar = false)
			{
				bool inspec = false;
				bool inquot = false;
				char qutochar = '\0';
				InnerItemsList@ innerItems = InnerItemsList();
				StringBuilder@ value = StringBuilder();
				for (int i = start; i < this.TextLength; i++)
				{
					char cur = this.Text[i];
					char next = '\0';
					if (i + 1 < this.TextLength)
					{
						next = this.Text[i + 1];
					}
					if (inspec)
					{
						value.Append(cur);
						inspec = false;
						continue;
					}
					if (cur == '\\')
					{
						inspec = true;
						continue;
					}
					if (!inquot)
					{
						if (cur == ' ' || cur == '\t')
						{
							continue;
						}
						if (cur == '\'' || cur == '\"')
						{
							inquot = true;
							qutochar = cur;
							continue;
						}
						if (cur == '+' || cur == '-' || cur == '*' ||
						cur == '/' || cur == '%' || cur == '!' ||
						cur == '=' || cur == '&' || cur == '|' ||
						cur == ')' || cur == '(' || cur == ',' ||
						cur == '[' || cur == ']' || cur == '^' ||
						cur == '<' || cur == '>' || cur == '{' ||
						cur == '}' || (cur == ':' && next != ':') || cur == '?' || cur == '.')
						{
							if (value.Length > 0)
							{
								innerItems.Add(this.Inner(value.ToString(), qutochar));
								value.Clear();
							}
							if (cur == '[' || cur == '(' || cur == '{')
							{
							   
								this.pos = i - 1;
								return innerItems;
							}
							if(autopar && (cur == '?' || cur == ':' || cur == '=' || cur == '<' || cur == '>' || (cur == '!' && next == '=')))
							{
							   
								if ((cur == '=' && next == '>') || (cur == '!' && next == '=') || (cur == '>' && next == '=') || (cur == '<' && next == '='))
								{
									this.pos = i;
								}
								else
								{
									this.pos = i;
								}
								return innerItems;
							}

							if (cur != '(' && cur != ')' && cur != '[' && cur != ']' && cur != '{' && cur != '}')
							{
								InnerItem@ inner2 = InnerItem();
								inner2.IsOperator = true;
								if ((cur == '=' && next == '>') || (cur == '!' && next == '=') || (cur == '>' && next == '=') || (cur == '<' && next == '='))
								{
									@inner2.Value = @Object(string(cur) + string(next));
									i++;
								}
								else if ((cur == '=' || cur == '&' || cur == '|') && cur == next)
								{
									@inner2.Value = @Object(string(cur) + string(next));
									i++;
								}
								else
								{
									@inner2.Value = @Object(string(cur));
								}
								string valuestr = inner2.Value.ToString();
								innerItems.Add(@inner2);
								qutochar = '\0';
								if (valuestr == "=" ||valuestr == "<=" || valuestr == ">=" || valuestr == "<" || valuestr == ">" || valuestr == "!=" || valuestr == "==")
								{
									this.pos = i;
									return innerItems;
								}

							}
							else
							{
								this.pos = i - 1;
								return innerItems;
							}
							continue;
						}
					}
					else
					{
						if (cur == qutochar)
						{
							inquot = false;
							continue;
						}
					}

					if (cur == ':' && next == ':')
					{
						value.Append(':');
						i++;
					}
					value.Append(cur);

				}
				if (value.Length > 0)
				{
					innerItems.Add(this.Inner(value.ToString(), qutochar));
				}
				this.pos = this.TextLength;
				return innerItems;
			}
			private InnerItem Inner(string current, char quotchar)
			{
				InnerItem@ inner = InnerItem();
				Object@ svalue = Object();
				inner.Quote = quotchar;
				inner.InnerType = TYPE_STRING;
				if (inner.Quote != '\'' && inner.Quote != '"')
				{
					if (current == "true" || current == "false")
					{
						inner.InnerType = TYPE_BOOLEAN;
						if(current == "true")
						{
							svalue.SetValueBool(true);
						}
						else
						{
							svalue.SetValueBool(false);
						}
					}
					else if (inner.Quote == '\0' &&  isdigit(current))
					{
						inner.InnerType = TYPE_NUMERIC;
						svalue.SetValueDouble(atod(current));
					}
					else
					{
						inner.InnerType = TYPE_VARIABLE;
						svalue.SetValue(current);
					}
				}
				else
				{
					svalue.SetValue(current);
				}
				@inner.Value = @svalue;
				return inner;
			}
		}	
	}
}
