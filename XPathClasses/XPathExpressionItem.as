namespace TextEngine
{
	namespace XPathClasses
	{
		class XPathExpressionItem : IXPathExpressionItem
		{
			private Object@ mvalue;
			Object@ Value
			{
				get
				{
					return @mvalue;
				}
				set
				{

					@this.mvalue = @value;
				}
			}
			void SetValue(string str)
			{
				this.IsNumeric = false;
				this.IsBool = false;
				if (!IsOperator && QuotChar == '\0')
				{
					if (isdigit(str))
					{
						this.IsNumeric = true;
						Object@ obj = Object();
						obj.SetValueDouble(atod(str));
						@this.Value = @obj;
					}
					else if (str.ToLowercase() == "true" || str.ToLowercase() == "false")
					{
						this.IsBool = true;
						bool v = str.ToLowercase() == "true";
						Object@ obj = Object();
						obj.SetValueBool(v);
						@this.Value = @obj;
					}
					else
					{
						@this.Value = @Object(str);
					}
				}
				else
				{
					@this.Value = @Object(str);
				}
			}
			private char quotChar;
			char QuotChar 
			{ 
				get const
				{
					return quotChar;
				}					
				set
				{
					quotChar = value;
				}
			}
			private bool isNumeric;
			bool IsNumeric 
			{ 
				get const
				{
					return isNumeric;
				}					
				set
				{
					isNumeric = value;
				}
			}
			private bool isBool;
			bool IsBool 
			{ 
				get const
				{
					return isBool;
				}					
				set
				{
					isBool = value;
				}
			}
			private bool isOperator;
			bool IsOperator 
			{ 
				get const
				{
					return isOperator;
				}					
				set
				{
					isOperator = value;
				}
			}
			bool IsVariable
			{
				get const
				{
					return !IsOperator && !IsNumeric && !IsBool &&  QuotChar == '\0';
				}
			}

			bool IsSubItem
			{
				get const
				{
					return false;
				}
			}
			private IXPathExpressionItem@ parent;
			IXPathExpressionItem@ Parent
			{
				get const
				{
					return @parent;
				}
				set
				{
					@parent = null;
				}
			}
			char ParChar { get const { return '\0'; } set { } }

		}
	}
}
