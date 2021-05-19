namespace TextEngine
{
	namespace ParDecoder
	{
		namespace ParFormat
		{
			funcdef void PF_OnInitialiseHandler(TextEngine::ParDecoder::ParDecodeAttributes@);
			string Format(string s, Object@ data = null)
			{
				auto@ pf = @ParFormat(s);
				return pf.Apply(data);
			}
			string FormatEx(string s, Object@ data = null, PF_OnInitialiseHandler@ onInitialise = null)
			{
				auto@ pf = @ParFormat(s);
				if(@onInitialise !is null) onInitialise(@pf.ParAttributes);
				return pf.Apply(data);
			}
		}
		class ParFormat
		{
			ParDecodeAttributes@ ParAttributes;
			ParFormat()
			{
				this.Initialise();
			}
			ParFormat(string text)
			{
				this.Text = text;
				this.Initialise();
			}
			private void Initialise()
			{

				@this.ParAttributes =  @ParDecodeAttributes();
				this.ParAttributes.AssignReturnType = PIART_RETURN_ASSIGNVALUE_OR_NULL;
				
			}
			private string text;
			string Text {
				get
				{
					return this.text;
				}
				set
				{
					this.text = value;
					@this.FormatItems = null;
				}
			}
			private array<ParFormatItem@>@ FormatItems;
			string Apply(Object@ data = null)
			{
				if (this.Text.IsEmpty()) return this.Text;
				if(@this.FormatItems is null)
				{
					this.ParseFromString(this.Text);
				}
				StringBuilder@ text = @StringBuilder();
				for (uint i = 0; i < this.FormatItems.length(); i++)
				{
					auto@ item = @this.FormatItems[i];
					if(item.ItemType == PFT_TextPar)
					{
						text.Append(item.ItemText);
						continue;
					}
					else if(item.ItemType == PFT_FormatPar)
					{
						if(@item.ParData is null)
						{
							@item.ParData = @ParDecode(item.ItemText);
							@item.ParData.CustomData = @any(@this.ParAttributes);
							@item.ParData.OnGetAttributes = function(item){
								TextEngine::ParDecoder::ParDecodeAttributes@ attr = null;
								item.CustomData.retrieve(@attr);
								return @attr;
							};
							item.ParData.Decode();
						}
						auto@ cr = @item.ParData.Items.Compute(@data);
						if(@cr !is null && cr.Result.Count > 0 && @cr.Result[0] !is null)
						{
							text.Append(cr.Result[0].ToString());
						}
					}
				}
				return text.ToString();
			}
			private void ParseFromString(string s)
			{
				@this.FormatItems = @array<ParFormatItem@>();
				StringBuilder@ text =  @StringBuilder();
				bool inpar = false;
				int openedPar = 0;
				char quotchar = '0';
				for (uint i = 0; i < s.Length(); i++)
				{
					char cur = s[i];
					char next = '\0';

					if (i + 1 < s.Length()) next = s[i + 1];
					if(!inpar)
					{
						if(cur == '{' && next == '{')
						{
							i++;
							text.Append(cur);
							continue;
						}
						if (cur == '{' && next == '%')
						{
							i += 1;
							if(text.Length > 0)
							{
								auto@ pfi = @ParFormatItem();
								pfi.ItemText = text.ToString();
								pfi.ItemType = PFT_TextPar;
								this.FormatItems.insertLast(@pfi);
								text.Clear();
							}
							inpar = true;
							continue;
						}
					}
					else
					{
						if(quotchar == '0' && (cur == '\'' || cur == '"'))
						{
							quotchar = cur;
						}
						else if (quotchar != '0' && cur == quotchar) quotchar = '0';
						if(cur == '{'  && quotchar == '0')
						{
							openedPar++;
						}
						if(cur == '}')
						{
							if(openedPar > 0)
							{
								openedPar--;
								text.Append(cur);
								continue;
							}
							if (text.Length > 0)
							{
								auto@ pfi = @ParFormatItem();
								pfi.ItemText = text.ToString();
								pfi.ItemType = PFT_FormatPar;
								this.FormatItems.insertLast(@pfi);
								text.Clear();
							}
							inpar = false;
							continue;
						}
					}
					text.Append(cur);
				}
				if(text.Length > 0)
				{
					auto@ pfi = @ParFormatItem();
					pfi.ItemText = text.ToString();
					pfi.ItemType = (inpar) ? PFT_FormatPar : PFT_TextPar;
					this.FormatItems.insertLast(@pfi);
					text.Clear();
				}	
			}
		}
	}
}
