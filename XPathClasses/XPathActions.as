namespace TextEngine
{
	namespace XPathClasses
	{
		enum XPathExpType
		{
			XPathExpType_XPathItems = 0,
			XPathExpType_XPathExpression = 1
		}
		bool XExpressionSuccess(TextEngine::Text::TextElement@ item, any@ expressions, XPathExpType itemtype = XPathExpType_XPathItems, TextEngine::Text::TextElementsList@ baselist = null, int curindex = -1, int totalcounts = -1)
		{
			XPathActions@ actions = XPathActions();
			@actions.XPathFunctions = @XPathFunctions();
			RegisterXPathFunctions(@actions.XPathFunctions);
			@actions.XPathFunctions.BaseItem = @item;
			if(totalcounts != -1)
            {
                actions.XPathFunctions.TotalItems = totalcounts;
            }
            else
            {
                if (baselist !is null)
                {
                    actions.XPathFunctions.TotalItems = baselist.Count;
                }
                else
                {
                    actions.XPathFunctions.TotalItems = item.Parent.SubElementsCount;
                }
            }
			Objects@ result = null;
			if(itemtype == XPathExpType_XPathExpression)
			{
				XPathExpression@ eexp = null;
				expressions.retrieve(@eexp);
				@result = @actions.EvulateActionSingle(@eexp);
			}
			else if(itemtype == XPathExpType_XPathItems)
			{
				IXPathExpressionItems@ expitem = null;
				expressions.retrieve(@expitem);
				@result = @actions.EvulateAction(@expitem);
			}
			if (@result[0] is null || result[0].ObjectType == ObjectType_Empty || result[0].ObjectType == ObjectType_Bool)
			{
				bool boolval = false;
				if(@result[0] !is null)
				{
					 boolval = result[0];
				}
				return boolval;
			}
			else if (result[0].IsNumericType())
			{
				int c = result[0];
				c--;
                int totalcount = 0;
				
				if (totalcounts != -1)
                {
                    totalcount = totalcounts;
                }
                else
                {
                    if (baselist !is null)
                    {
                        totalcount = baselist.Count;

                    }
                    else
                    {
                        totalcount = item.Parent.SubElementsCount;
                    }
                }
                if (c < -1 || c >= totalcount)
                {
                    return false;
                }
                else
                {
                    return c == actions.XPathFunctions.ItemPosition;
                }
			}
			else if(result[0].ToString().IsEmpty())
			{
				return false;
			}
			return true;
		}
		TextEngine::Text::TextElementsList@ XPathAction_Eliminate(TextEngine::Text::TextElementsList@ items, any@ expressions, XPathExpType itemtype = XPathExpType_XPathItems, bool issecondary = true)
		{
			int total = 0;
            int totalcount = items.Count;
			for (int i = 0; i < items.Count; i++)
			{
				bool result = false;
                if(issecondary)
                {
                    result = XExpressionSuccess(items[i], @expressions, itemtype, @items, total++, totalcount);
                }
                else
                {
                    result = XExpressionSuccess(items[i], @expressions);
                }
                if(!result)
                {
                    items.RemoveAt(i);
                    i--;
                    continue;
                }
			}
			return @items;
		}
	    class XPathActions
		{

			private XPathFunctions@ xPathFunctions;
			XPathFunctions@ XPathFunctions 
			{ 
				get const
				{
					return @xPathFunctions;
				}
				set
				{
					@xPathFunctions = @value;
				}
			}
			Objects@ EvulateActionSingle(XPathExpression@ item, IXPathExpressionItem@ sender = null)
			{
				Object@ curvalue = null;
				IXPathExpressionItem@ previtem = null;
				XPathExpressionItem@ xoperator = null;
				Object@ waitvalue = null;
				string waitop = "";
				Objects@ values = Objects();
				for (int j = 0; j < item.XPathExpressionItems.Count; j++)
				{
					IXPathExpressionItem@ curitem = @item.XPathExpressionItems[j];
					IXPathExpressionItem@  nextitem = (j + 1 < item.XPathExpressionItems.Count) ? @item.XPathExpressionItems[j + 1] : @null;
					string nextop = "";
					XPathExpressionItem@ nextExp = null;
					if (@nextitem !is null && !nextitem.IsSubItem)
					{
						@nextExp = cast<XPathExpressionItem@>(nextitem);
						nextop = (nextExp !is null && nextExp.IsOperator) ? nextExp.Value.ToString() : "";
					}
					Object@ expvalue = null;

					if (curitem.IsSubItem)
					{
						IXPathExpressionItems@ curitems = cast<IXPathExpressionItems@>(curitem);
						
						Objects@ results = EvulateAction(@curitems);
						if (!previtem.IsSubItem)
						{
							XPathExpressionItem@ prevexp = cast<XPathExpressionItem@>(previtem);
							if (prevexp.IsOperator)
							{
								@expvalue = @results[0];
							}
							else
							{
								if (@XPathFunctions !is null)
								{
									if (curitem.ParChar == '[')
									{
										TextEngine::Text::TextElementsList@ xitems = @this.XPathFunctions.BaseItem.FindByXPath(prevexp.Value.ToString());
										if (xitems.Count > 0)
										{
											@xitems = @XPathAction_Eliminate(@xitems, @any(@curitem));
										}
										if (xitems.Count > 0)
										{
											@expvalue = @Object();
											expvalue.SetValueBool(true);
										}
										else
										{
											@expvalue = @Object();
											expvalue.SetValueBool(false);
										}
										if (curvalue is null || curvalue.IsEmpty())
										{
											@curvalue = @expvalue;
											@previtem = @curitem;
											continue;
										}
									}
									else if (curitem.ParChar == '(')
									{
										XPathFunctionItem@ method = @this.XPathFunctions.GetFunctionByName(prevexp.Value.ToString());
										if (@method !is null)
										{
											@expvalue = @method.FunctionHandler(@this.XPathFunctions, @results);
											if (curvalue is null || curvalue.IsEmpty())
											{
												@curvalue = @expvalue;
												@previtem = @curitem;
												continue;
											}
										}
										else
										{
												
											@expvalue = @Object();
											expvalue.SetValueBool(false);
											if (curvalue is null || curvalue.IsEmpty())
											{
												@curvalue = @expvalue;
												@previtem = @curitem;
												continue;
											}
										}
									}
								}

							}
						}
					}
					else
					{
						XPathExpressionItem@ expItem = cast<XPathExpressionItem@>(curitem);

						if (@nextitem !is null && nextitem.IsSubItem)
						{
							@previtem = @curitem;
							continue;
						}

						if (expItem.IsOperator)
						{
							if (expItem.Value.ToString() == ",")
							{
								if (!waitop.IsEmpty())
								{
									@curvalue = @OperatorResult(@waitvalue, @curvalue, waitop);
									@waitvalue = null;
									waitop = "";
								}
								values.Add(@curvalue);
								@curvalue = null;
								@xoperator = null;
								continue;
							}
							string opstr = expItem.Value.ToString();
							if (opstr == "||" || opstr == "|" || opstr == "or" || opstr == "&&" || opstr == "&" || opstr == "and")
							{
								if (!waitop.IsEmpty())
								{
									@curvalue = @OperatorResult(@waitvalue, @curvalue, waitop);
									@waitvalue = null;
									waitop = "";
								}
								bool state = (curvalue !is null && curvalue.ToBool());

								if (opstr == "||" || opstr == "|" || opstr == "or")
								{
									if (state)
									{
										Object@ newobj = @Object();
										newobj.SetValueBool(true);
										values.Add(@newobj);
										return @values;
									}
									else 
									{
										@curvalue = null;
									}

								}
								else
								{
									if (!state)
									{
								
										Object@ newobj = @Object();
										newobj.SetValueBool(false);
										values.Add(@newobj);
										
										return @values;
									}
									else
									{
										@curvalue = null;
									}
								}
								@xoperator = null;
							}
							else
							{
								@xoperator = @expItem;
							}
							@previtem = @curitem;
							continue;
						}
						else
						{
							if (expItem.IsVariable)
							{
								if (expItem.Value.ToString().StartsWith("@"))
								{
									string s = expItem.Value.ToString().SubString(1);
									if ((previtem is null || !previtem.IsSubItem) && (nextExp is null || !nextExp.IsOperator) && (sender is null || !sender.IsSubItem || sender.ParChar != '('))
									{
										bool result = this.XPathFunctions.BaseItem.ElemAttr.HasAttribute(s);
										@expvalue = Object();
										expvalue.SetValueBool(result);
									}
									else
									{
										@expvalue = Object();
										expvalue.SetValue(this.XPathFunctions.BaseItem.GetAttribute(s, ""));
									}
									if (expvalue is null || expvalue.IsEmpty())
									{
										@expvalue = @Object();
										expvalue.SetValueBool(false);
									}
								}
								else
								{
									TextEngine::Text::TextElementsList@ items = this.XPathFunctions.BaseItem.FindByXPath(expItem.Value.ToString());
									if (items.Count == 0)
									{
										@expvalue = @Object();
										expvalue.SetValueBool(false);
									}
									else
									{
										expvalue = @Object(items[0].Inner());
									}
								}
							}
							else
							{
								@expvalue = @expItem.Value;

							}
							if (curvalue is null)
							{
								@curvalue = @expvalue;
								@previtem = @curitem;
								continue;
							}


						}
					}
					if (@xoperator !is null)
					{
						if (protirystop.find(xoperator.Value.ToString()) >= 0)
						{
							if (!waitop.IsEmpty())
							{
								@curvalue = @OperatorResult(@waitvalue, @curvalue, waitop);
								@waitvalue = null;
								waitop = "";
							}
						}
		
						if ((xoperator.Value.ToString() != "+" && xoperator.Value.ToString() != "-") || nextop.IsEmpty() || protirystop.find(nextop) >= 0)
						{
							@curvalue = @OperatorResult(@curvalue, @expvalue, xoperator.Value.ToString());
						}
						else
						{
							@waitvalue = @curvalue;
							waitop = xoperator.Value.ToString();
							@curvalue = @expvalue;
						}
						@xoperator = null;
					}
					@previtem = @curitem;
				}
				if (!waitop.IsEmpty())
				{
					@curvalue = @OperatorResult(@waitvalue, @curvalue, waitop);
					@waitvalue = null;
					waitop = "";
				}
				values.Add(@curvalue);
				return @values;
			}
			Objects@ EvulateAction(IXPathExpressionItems@ item)
			{
				Objects@ values = Objects();
				for (int i = 0; i < item.XPathExpressions.Count; i++)
				{
					XPathExpression@ curExp = @item.XPathExpressions[i];
					Objects@ results = @EvulateActionSingle(@curExp, @item);
					values.AddRange(@results);
				}

				return @values;
			}
		}
	}
}
