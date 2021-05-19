namespace TextEngine
{
	namespace ParDecoder
	{
		class ParItem : InnerItem
		{
			ParItem()
			{
				@this.InnerItems = InnerItemsList();
			}

			private ParDecode@ baseDecoder;
			ParDecode@ BaseDecoder
			{
				get const
				{
					return @baseDecoder;
				}
				set
				{
					@baseDecoder = @value;
				}
			}
			
			private string parName;
			string ParName
			{
				get const
				{
					return parName;
				}
				set
				{
					parName = value;
				}
			}
			bool IsParItem()
			{
				return true;
			}
			bool IsObject()
			{
				return this.ParName == "{";
			}
			bool IsArray()
			{
				return this.ParName == "[";
			}
			ComputeResult@ Compute(Object@ vars = null, InnerItem@ sender = null, Object@ localvars = null)
			{
				ComputeResult@ cr = ComputeResult();
				Object@ lastvalue = null;
				InnerItem@ xoperator = null;
				InnerItem@ previtem = null;
				InnerItem@ waititem = null;
				InnerItem@ waititem2 = null;
				string waitop = "";
				Object@ waitvalue = null;
				string waitop2 = "";
				Object@ waitvalue2 = null;
				string waitkey = "";
				bool unlemused = false;
				bool stopdoubledot = false;
				Objects@ objects = null;
				dictionary@ currentdict = null;
				int minuscount = 0;
				string assigment = "";
				PropObject@ lastPropObject = null;
				PropObject@ waitAssigmentObject = null;
				int totalOp = 0;
				if(this.IsObject())
				{
					@currentdict = dictionary();
					Object@ newobj = Object();
					newobj.SetValueDictionaryObject(@currentdict);
					cr.Result.Add(@newobj);
				}
				else if(this.IsArray())
				{
					@objects = Objects();
					cr.Result.Add(Object(@objects));
				}
				for (int i = 0; i < this.InnerItems.Count; i++)
				{
					Object@ currentitemvalue = null;
					InnerItem@ current = this.InnerItems[i];
					ParItem@ paritem = null;
					if(current.IsParItem())
					{
						@paritem = cast<ParItem@>(current);
					}
					if(stopdoubledot)
					{
						if(current.IsOperator && current.Value.ToString() == ":")
						{
							break;
						}
					}
					InnerItem@ next = null;
					string nextop = "";
					if (i + 1 < this.InnerItems.Count) @next = @this.InnerItems[i + 1];
					if (next !is null && next.IsOperator)
					{
						nextop = next.Value.ToString();
					}
					if (current.IsParItem())
					{
						ComputeResult@ subresult = paritem.Compute(@vars, @this, @localvars);
						string prevvalue = "";
						bool previsvar = false;
						if(previtem !is null && !previtem.IsOperator && previtem.Value !is null)
						{
							previsvar = previtem.InnerType == TYPE_VARIABLE;
							prevvalue = previtem.Value.ToString();
							
						}
						Object@ varnew = null;
						bool checkglobal = true;
						if (lastvalue !is null && (lastvalue.IsDictionary() || lastvalue.IsDictionaryObject() || lastvalue.IsDictionaryList()))
						{
							checkglobal = false;
							@varnew = @lastvalue;
						}
						else
						{
							@varnew = @vars;
						}
						if (prevvalue != "")
						{
					
							if (paritem.ParName == "(")
							{
								if(this.BaseDecoder.Attributes.Flags & PDF_AllowMethodCall != 0)
								{
									Object@ globalFunc = null;
									if(checkglobal && this.BaseDecoder.Attributes.GlobalFunctions.get(prevvalue, @globalFunc) && @globalFunc !is null && globalFunc.IsFunction())
									{
											ObjectFunctionHandler@ func = null;
											@func = @globalFunc;
											@currentitemvalue = @func(@subresult.Result);
									}
									else
									{
										Object@ tempvalue = GetProp(prevvalue, @varnew).Value;
										if(@tempvalue !is null && tempvalue.IsFunction())
										{

											ObjectFunctionHandler@ func = null;
											@func = @tempvalue;
											@currentitemvalue = @func(@subresult.Result);
										}
										else
										{
											@currentitemvalue = null;
										}
										@lastPropObject = null;
									}
								}
								else
								{
									//@currentitemvalue = null;
								}
							}
							else if(paritem.ParName == "[")
							{
								if(this.BaseDecoder.Attributes.Flags & PDF_AllowArrayAccess != 0)
								{
									Object@ tempvalue = Object();
									@lastPropObject = GetProp(prevvalue, @varnew);
									if(lastPropObject.PropType != PT_Empty)
									{
										@tempvalue = @lastPropObject.Value;
									}
									else
									{
										@currentitemvalue = null;
									}
									if (tempvalue.IsObjects() && subresult.Result[0].IsNumericType())
									{
										int indis = subresult.Result[0];
										Objects@ list = @tempvalue;
										if(list !is null && indis >= 0 && indis < list.Count)
										{
											@lastPropObject.ArrayData = @list;
											lastPropObject.IntIndex = indis;
											lastPropObject.PropType = PT_Indis;
											@currentitemvalue = @list[indis];
										}
										else
										{
											@lastPropObject = null;
											@currentitemvalue = null;
										}
									}
									else if (tempvalue.IsString())
									{
										string s = tempvalue.ToString();
										int indis = subresult.Result[0];
										int slen = int(s.Length());
										if(indis >= 0 && indis < slen)
										{
											@currentitemvalue = @Object(string(s[indis]));
										}
										else
										{
											@currentitemvalue = null;
											@lastPropObject = null;
										
										}
										@lastPropObject = null;
									}
									else
									{
										@currentitemvalue = null;
										@lastPropObject = null;
									}
								}
								else
								{
									//@currentitemvalue = null;
								}
		
							}
						}
						else
						{
							if(paritem.ParName == "(")
							{

								@currentitemvalue = @subresult.Result[0];
							}
							else if(paritem.ParName == "[")
							{
								@currentitemvalue = @subresult.Result[0];
							}
							else if(paritem.ParName == "{")
							{
								@currentitemvalue = @subresult.Result[0];
							}
						}

					}
					else
					{
						if(!current.IsOperator && current.InnerType == TYPE_VARIABLE &&  next !is null && next.IsParItem())
						{
							@currentitemvalue = null;
						}
						else
						{
							if(@previtem !is null && previtem.IsOperator)
							{
								if(current.Value.ToString() == "+")
								{
									continue;
								}
								else if (current.Value.ToString() == "-")
								{
									minuscount++;
									continue;
								}
							}
							@currentitemvalue = @current.Value;
						}
			 
						if (current.InnerType == TYPE_VARIABLE && (next is null || !next.IsParItem()) && (xoperator is null || xoperator.Value.ToString() != ".") )
						{
							if (currentitemvalue is null || currentitemvalue.ToString() == "null")
							{
								@currentitemvalue = null;
							}
							else if (currentitemvalue.ToString() == "false")
							{
								@currentitemvalue = Object();
								currentitemvalue.SetValueBool(false);
							}
							else if (currentitemvalue.ToString() == "true")
							{
								@currentitemvalue = Object();
								currentitemvalue.SetValueBool(true);
							}
							else if (!this.IsObject())
							{
								string sname = current.Value.ToString();
								@lastPropObject = @GetPropValue(sname, @vars, @localvars);
								if(lastPropObject.PropType == PT_Empty)
								{
									@currentitemvalue = null;
								}
								else
								{
									@currentitemvalue = @lastPropObject.Value;
									if(currentitemvalue.IsEmpty())
									{
										@currentitemvalue = null;
									}
								}
							
							}
						}
					}
					if(unlemused)
					{
						bool not_empty = currentitemvalue !is null && !currentitemvalue.IsEmptyOrDefault();
						@currentitemvalue = @Object_Bool(!not_empty);
						unlemused = false;
					}
					if (current.IsOperator)
					{
						totalOp++;
						if(current.Value.ToString() == "!")
						{
							unlemused = !unlemused;
							continue;
						}
						if ((this.IsParItem() && current.Value.ToString() == ",") || (this.IsArray() && current.Value.ToString() == "=>" && (waitvalue is null || waitvalue.ToString() == "")) || (this.IsObject() && current.Value.ToString() == ":" && (waitvalue is null || waitvalue.ToString() == "") ))
						{
							if (waitop2 != "")
							{
								if(minuscount % 2 == 1) @lastvalue = @OperatorResult(@lastvalue, Object_Int(-1), "*");
								minuscount = 0;
								@lastvalue = @OperatorResult(@waitvalue2, @lastvalue, waitop2);
								@waitvalue2 = null;
								waitop2 = "";
							}
							if (waitop != "")
							{
								if(minuscount % 2 == 1) @lastvalue = @OperatorResult(@lastvalue, Object_Int(-1), "*");
								minuscount = 0;
								@lastvalue = @OperatorResult(@waitvalue, @lastvalue, waitop);
								@waitvalue = null;
								waitop = "";
							}
							if (current.Value.ToString() == ",")
							{
								if(this.IsObject())
								{
									currentdict.set(waitkey, @lastvalue);
								}
								else if(this.IsArray())
								{
									objects.Add(@lastvalue);
								}
								else
								{
									cr.Result.Add(@lastvalue);
								}
								waitkey = "";
							}
							else
							{
								waitkey = lastvalue.ToString();
							}
							@lastvalue = null;
							@xoperator = null;
							@previtem = @current;
							continue;
						}
						string opstr = current.Value.ToString();
						if(@waitAssigmentObject is null && (opstr == "=" || opstr == "+=" || opstr == "-=" || opstr == "*=" || opstr == "/=" || opstr == "^=" || opstr == "|=" 
							|| opstr == "&=" || opstr == "<<=" || opstr == ">>=" || opstr == "%="))
						{
							if (totalOp <= 1 && (this.BaseDecoder.Attributes.Flags & PDF_AllowAssigment) != 0)
							{
								@waitAssigmentObject = @lastPropObject;
								assigment = opstr;
								@xoperator = null;
								@previtem = null;
							}
							else
							{
								@xoperator = null;
								@previtem = null;
							}
							continue;
						}
						if (opstr == "||" || /*opstr == "|" || */ opstr == "or" || opstr == "&&" || /*opstr == "&" || */ opstr == "and" || opstr == "?")
						{
							if (waitop2 != "")
							{
								if(minuscount % 2 == 1) @lastvalue = @OperatorResult(@lastvalue, Object_Int(-1), "*");
								minuscount = 0;
								@lastvalue = @OperatorResult(@waitvalue2, @lastvalue, waitop2);
								@waitvalue2 = null;
								waitop2 = "";
							}
							if (waitop != "")
							{
								if(minuscount % 2 == 1) @lastvalue = @OperatorResult(@lastvalue, Object_Int(-1), "*");
								minuscount = 0;
								@lastvalue = @OperatorResult(@waitvalue, @lastvalue, waitop);
								@waitvalue = null;
								waitop = "";
							}

							bool state = lastvalue !is null && !lastvalue.IsEmptyOrDefault();
							@xoperator = null;
							if (opstr == "?")
							{
								if (state)
								{
									stopdoubledot = true;
								}
								else
								{
									for (int j = i + 1; j < this.InnerItems.Count; j++)
									{
										InnerItem@ item = this.InnerItems[j];
										if (item.IsOperator && item.Value.ToString() == ":")
										{
											i = j;
											break;
										}
									}
								}
								@lastvalue = null;
								@previtem = @current;
								continue;


							}
							if (opstr == "||" || /*opstr == "|" ||*/ opstr == "or")
							{
								if (state)
								{
									@lastvalue = Object_Bool(true);
									/*if (opstr != "|")
									{*/
										Object@ newobj = Object();
										newobj.SetValueBool(true);
										if (this.IsObject())
										{
											
											currentdict.set(waitkey, @newobj);
										}
										else if(this.IsArray())
										{
											objects.Add(@newobj);
										}
										else
										{
											cr.Result.Add(@newobj);
										}
										return cr;
									//}
								}
								else
								{
									@lastvalue = Object_Bool(false);
								}
							}
							else
							{
								if (!state)
								{
									lastvalue = false;
									/*if (opstr != "&")
									{*/
										Object@ newobj = Object();
										newobj.SetValueBool(false);
										if (this.IsObject())
										{
											
											currentdict.set(waitkey, @newobj);
										}
										else if(this.IsArray())
										{
											objects.Add(@newobj);
										}
										else
										{
											cr.Result.Add(@newobj);
										}
										return cr;
									//}
								}
								else
								{
									@lastvalue = Object_Bool(true);
								}
							}
							@xoperator = null;
							//@xoperator = @current;
						}
						else
						{
							@xoperator = @current;
						}
						@previtem = @current;
						continue;
					}
					else
					{

						if (xoperator !is null)
						{
							if ( PriotiryStop.find(xoperator.Value.ToString()) >= 0)
							{
								if (waitop2 != "")
								{
									if(minuscount % 2 == 1) @lastvalue = @OperatorResult(@lastvalue, Object_Int(-1), "*");
									minuscount = 0;
									@lastvalue = @OperatorResult(@waitvalue2, @lastvalue, waitop2);
									@waitvalue2 = null;
									waitop2 = "";
								}
								if (waitop != "")
								{
									if(minuscount % 2 == 1) @lastvalue = @OperatorResult(@lastvalue, Object_Int(-1), "*");
									minuscount = 0;
									@lastvalue = @OperatorResult(@waitvalue, @lastvalue, waitop);
									@waitvalue = null;
									waitop = "";
								}
							}

							if (next !is null && next.IsParItem())
							{
								if (xoperator.Value.ToString() == ".")
								{
									string name = currentitemvalue.ToString();
									if(!name.IsEmpty())
									{
										if(lastvalue !is null && (lastvalue.IsDictionaryObject() || lastvalue.IsDictionary()))
										{
											if(lastvalue.IsDictionary())
											{
												dictionary dict = lastvalue;
												@lastPropObject = @GetProp(name, dict);
												@lastvalue = @lastPropObject.Value;
											}
											else if(lastvalue.IsDictionaryObject())
											{
												dictionary@ dict = @lastvalue;
												@lastPropObject = @GetProp(name, @dict);
												@lastvalue = @lastPropObject.Value;
											}

										}
										else
										{
											@lastvalue = null;
										}
									}
								}
								else
								{
									if(waitop == "")
									{
										waitop = xoperator.Value.ToString();
										@waititem = @current;
										@waitvalue = @lastvalue;
									}
									else if(waitop2 == "")
									{
										waitop2 = xoperator.Value.ToString();
										@waititem2 = @current;
										@waitvalue2 = @lastvalue;
									}
									@lastvalue = null;
								}
								@xoperator = null;
								@previtem = @current;
								continue;
							}
							if (xoperator.Value.ToString() == ".")
							{
														
								if(this.BaseDecoder.Attributes.Flags & PDF_AllowSubMemberAccess != 0)
								{
									totalOp--;
									string name = currentitemvalue.ToString();
									if(lastvalue !is null && (lastvalue.IsDictionaryObject() || lastvalue.IsDictionary()))
									{
										if(lastvalue.IsDictionary())
										{
											dictionary dict = lastvalue;
											@lastPropObject = @GetProp(name, dict);
											@lastvalue = @lastPropObject.Value;
										}
										else if(lastvalue.IsDictionaryObject())
										{
											dictionary@ dict = @lastvalue;
											@lastPropObject = @GetProp(name, @dict);
											@lastvalue = @lastPropObject.Value;
										}
									}
									else
									{
										@lastvalue = null;
									}
								}
								else
								{
									//@lastvalue = null;
								}
			
							}
							else if (nextop != "." && ((xoperator.Value.ToString() != "+" && xoperator.Value.ToString() != "-") || nextop == "" || (PriotiryStop.find(nextop) >= 0)))
							{
								if(minuscount % 2 == 1) @currentitemvalue = @OperatorResult(@currentitemvalue, Object_Int(-1), "*");
								minuscount = 0;
								Object@ opresult = OperatorResult(@lastvalue, @currentitemvalue, xoperator.Value.ToString());
								@lastvalue = @opresult;
							}
							else
							{
								if(waitop == "")
								{
									waitop = xoperator.Value.ToString();
									@waititem = @current;
									@waitvalue = @lastvalue;
									@lastvalue = @currentitemvalue;
								}
								else if(waitop2 == "")
								{
									waitop2 = xoperator.Value.ToString();
									@waititem2 = @current;
									@waitvalue2 = @lastvalue;
									@lastvalue = @currentitemvalue;
								}
							
								continue;
							}
						}
						else
						{
							@lastvalue = @currentitemvalue;
						}


					}

					@previtem = @current;
				}
				if (waitop2 != "")
				{
					if(minuscount % 2 == 1) @lastvalue = @OperatorResult(@lastvalue, Object_Int(-1), "*");
					minuscount = 0;
					@lastvalue = @OperatorResult(@waitvalue2, @lastvalue, waitop2);
					@waitvalue2 = null;
					waitop2 = "";
				}
				if (waitop != "")
				{
					if(minuscount % 2 == 1) @lastvalue = @OperatorResult(@lastvalue, Object_Int(-1), "*");
					minuscount = 0;
					@lastvalue = @OperatorResult(@waitvalue, @lastvalue, waitop);
					@waitvalue = null;
					waitop = "";
				}
				if (@waitAssigmentObject !is null )
				{
					AssignResult@ assignResult = null;
					if(waitAssigmentObject.PropType != PT_Empty)
					{
						try
						{
							@assignResult = @AssignObjectValue(@waitAssigmentObject, assigment, @lastvalue);
						}
						catch
						{

						}
					}
					switch (this.BaseDecoder.Attributes.AssignReturnType)
					{
						case PIART_RETURN_NULL:
							@lastvalue = null;
							break;
						case PIART_RETRUN_BOOL:
							lastvalue.SetValueBool(assignResult.Success);
							break;
						case PIART_RETURN_ASSIGNVALUE_OR_NULL:
							if (assignResult is null || !assignResult.Success) @lastvalue = null;
							else @lastvalue = @assignResult.AssignedValue;
							break;
						case PIART_RETURN_ASSIGN_VALUE:
							if (assignResult !is null && assignResult.Success) @lastvalue = @assignResult.AssignedValue;
							break;
					}
				}
				if (this.IsObject())
				{
					currentdict.set(waitkey, @lastvalue);
				}
				else if(this.IsArray())
				{
					objects.Add(@lastvalue);
				}
				else
				{
					cr.Result.Add(@lastvalue);
				}
				return cr;
			}
		}	
	}
}
