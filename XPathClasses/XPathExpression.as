namespace TextEngine
{
	namespace XPathClasses
	{
		array<string> operators =
		{
			"and",
			"mod",
			"div",
			"or",
			"!=",
			"==",
			">=",
			"<=",
			"&&",
			"||",
			"+",
			"-",
			"*",
			"/",
			"%",
			"=",
			"<",
			">",
			","
		};
		array<string> protirystop =
		{
			"and",
			"&&",
			"||",
			"|",
			"!=",
			"==",
			"=",
			">",
			"<",
			">=",
			"<=",
			"or",
			"+",
			"-",
			","
		};
		XPathExpression@ Parse_XPathExpression(string input, int istate, int &out istateout)
		{
			bool inquot = false;
			char quotchar = '\0';
			bool inspec = false;
			StringBuilder@ curstr = StringBuilder();
			XPathExpression@ elem = XPathExpression();

			if(input[istate] == '['  || input[istate] == '(')
			{
				istate++;
			}
			istateout = istate;
			for (uint i = istate; i < input.Length(); i++)
			{
				char cur = input[i];
				char next = '\0';
				if(i + 1 < input.Length())
				{
					next = input[i + 1];
				}
				if (inspec)
				{
					inspec = false;
					curstr.Append(cur);
					continue;
				}
				if (!inquot && cur == '\'' || cur == '"')
				{
					if (curstr.Length > 0 || quotchar != '\0')
					{
						XPathExpressionItem@ item = XPathExpressionItem();
						item.QuotChar = quotchar;
						item.IsOperator = quotchar == '\0' && operators.find(curstr.ToString()) >= 0;
						item.SetValue(curstr.ToString());
						elem.XPathExpressionItems.Add(@item);						
					}
					curstr.Clear();
					inquot = true;
					quotchar = cur;
					curstr.Clear();
					continue;
				}
				if (inquot)
				{
					if (cur == quotchar)
					{
						inquot = false;
					}
					else
					{
						curstr.Append(cur);
					}
					continue;
				}

				if (cur == '\\')
				{
					inspec = true;
					continue;
				}
				if (cur == ' ' && next == ' ') continue;
				if(cur == '-' || cur == '/')
				{
					if(curstr.Length > 0 && !isdigit(curstr.ToString()))
					{
						curstr.Append(cur);
						continue;
					}
				}
				if(cur != ' ' && curstr.Length > 0)
				{
					if(operators.find(string(cur)) == -1 && operators.find(curstr.ToString()) >= 0 || operators.find(string(cur)) >= 0 && operators.find(curstr.ToString()) == -1)
					{
						if (curstr.Length > 0 || quotchar != '\0')
							{
							XPathExpressionItem@ item = XPathExpressionItem();
							item.QuotChar = quotchar;
							item.IsOperator = quotchar == '\0' && operators.find(curstr.ToString()) >= 0;
							item.SetValue(curstr.ToString());
							elem.XPathExpressionItems.Add(@item);			
						}
						curstr.Clear();
					}
				}
				if (cur == ' ' || cur == ':' || cur == ']' || cur == ')' )
				{
					
					if(curstr.Length > 0 || quotchar != '\0')
					{
						XPathExpressionItem@ item = XPathExpressionItem();
						item.QuotChar = quotchar;
						item.IsOperator = quotchar == '\0' && operators.find(curstr.ToString()) >= 0;
						item.SetValue(curstr.ToString());
						elem.XPathExpressionItems.Add(@item);		
					}
					quotchar = '\0';
					curstr.Clear();
					if (cur == ']' || cur == ')')
					{
						istate = i;
						istateout = i;
						break;
					}
					continue;
				}
					
				if(cur == '(' || cur == '[')
				{
					if(curstr.Length > 0 || quotchar != '\0')
					{
						XPathExpressionItem@ item = XPathExpressionItem();
						item.QuotChar = quotchar;
						item.IsOperator = quotchar == '\0' && operators.find(curstr.ToString()) >= 0;
						item.SetValue(curstr.ToString());
						elem.XPathExpressionItems.Add(@item);
						curstr.Clear();
					}
					int outi;
					XPathExpression@ subElem = Parse_XPathExpression(input, i, outi);
					i = outi;
					XPathExpressionSubItem@ subitem = XPathExpressionSubItem();
					subitem.ParChar = cur;
					@subElem.Parent = @elem;
					subitem.XPathExpressions.Add(@subElem);
					elem.XPathExpressionItems.Add(@subitem);
					continue;
				}
				curstr.Append(cur);
			}
			if(curstr.Length > 0 || quotchar != '\0')
			{
				XPathExpressionItem@ item = XPathExpressionItem();
				item.QuotChar = quotchar;
				item.IsOperator = quotchar == '\0' && operators.find(curstr.ToString()) >= 0;
				item.SetValue(curstr.ToString());
				elem.XPathExpressionItems.Add(@item);			
			}
			return elem;
		}	
		class XPathExpression
		{
			private XPathExpressionItemsList@ xPathExpressionItems = @XPathExpressionItemsList();
			XPathExpressionItemsList@ XPathExpressionItems 
			{ 
				get const
				{
					return @xPathExpressionItems;
				}
				set
				{
					@xPathExpressionItems = @value;
				}
			}
			XPathExpression()
			{
				//@this.XPathExpressionItems = @XPathExpressionItemsList();
			}
			private XPathExpression@ parent;
			XPathExpression@ Parent 
			{ 
				get const
				{
					return @parent;
				}
				set
				{
					@parent = @value;
				}
			}
		}
	}
}
