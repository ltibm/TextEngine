namespace TextEngine
{
	namespace ParDecoder
	{
		namespace ParFormat
		{
			string Format(string s, dictionary@ data = null)
			{
				auto@ pf = @ParFormat(s);
				return pf.Apply(data);
			}
		}
		class ParFormat
		{
			ParFormat()
			{

			}
			ParFormat(string text)
			{
				this.Text = text;
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
			private bool surpressError;
			bool SurpressError 
			{
				get
				{
					return this.surpressError;
				}
				set
				{
					this.surpressError = value;
				}
			}
			string Apply(dictionary@ data = null)
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
							item.ParData.Decode();
							item.ParData.SurpressError = this.SurpressError;
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
						if(cur == '{')
						{
							if (this.SurpressError)
							{
								continue;
							}
							//For exception.
							int f = 0;
							int h = 1 / f;
							//throw("Syntax Error: Unexpected {");
						}
						if(cur == '}')
						{
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
