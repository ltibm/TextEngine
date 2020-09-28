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
			//public static EvulatorTypes StaticTypes { get; private set; } = new EvulatorTypes();
			//public static List<string> GlobalFunctions { get; set; } = new List<string>();

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
			ComputeResult@ Compute(dictionary@ vars = null, InnerItem@ sender = null, Object@ localvars = null)
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
						dictionary@ varnew = null;
						if (lastvalue !is null && lastvalue.IsDictionaryObject())
						{
							@varnew = @lastvalue;
						}
						else
						{
							@varnew = @vars;
						}
						if (prevvalue != "")
						{
							Object@ tempvalue = Object();
							if (paritem.ParName == "(")
							{
				
								if(varnew !is null && varnew.exists(prevvalue))
								{
									if(!tempvalue.SetValueByDictionary(varnew, prevvalue))
									{
										varnew.get(prevvalue, @tempvalue);
									}
								}
								if(tempvalue.IsFunction())
								{
									ObjectFunctionHandler@ func = @tempvalue;
									@currentitemvalue = @func(@subresult.Result);
								}
								else
								{
									@currentitemvalue = null;
								}
							}
							else if(paritem.ParName == "[")
							{
								if(varnew !is null && varnew.exists(prevvalue))
								{
									
									if(!tempvalue.SetValueByDictionary(varnew, prevvalue))
									{
										
										varnew.get(prevvalue, @tempvalue);
									}
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
										@currentitemvalue = @list[indis];
									}
									else
									{
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
									
									}
								}
								else
								{
									@currentitemvalue = null;
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
						dictionary@ varnew = null;
						if (lastvalue !is null && lastvalue.IsDictionaryObject())
						{
							@varnew = @lastvalue;
						}
						else
						{
							if (localvars !is null && (localvars.IsDictionaryObject() || localvars.IsDictionaryList()) && current.InnerType == TYPE_VARIABLE && (next is null || !next.IsParItem()) && (xoperator is null || xoperator.Value.ToString() != ".") && !this.IsObject() )
							{
								string sname = current.Value.ToString();
								dictionary@ local = null;
								if(localvars.IsDictionaryObject())
								{
									@local = @localvars;
								}
								else if(localvars.IsDictionaryList())
								{
									DictionaryList@ list = localvars;
									@local = @list.GetDictionaryIfKeyExists(sname);
								}
				
								if(local !is null && local.exists(sname))
								{
									@varnew = @local;
								}
								else
								{
									@varnew = @vars;
								}
							}
							else
							{
								@varnew = @vars;
							}
							
						}
						if(!current.IsOperator && current.InnerType == TYPE_VARIABLE &&  next !is null && next.IsParItem())
						{
							@currentitemvalue = null;
						}
						else
						{
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
								if(varnew is null || !varnew.exists(sname))
								{
									@currentitemvalue = null;
								}
								else
								{
									@currentitemvalue = Object();
									if(!currentitemvalue.SetValueByDictionary(varnew, sname))
									{
										varnew.get(sname, @currentitemvalue);
									}
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
						if(current.Value.ToString() == "!")
						{
							unlemused = !unlemused;
							continue;
						}
						if ((this.IsParItem() && current.Value.ToString() == ",") || (this.IsArray() && current.Value.ToString() == "=>" && (waitvalue is null || waitvalue.ToString() == "")) || (this.IsObject() && current.Value.ToString() == ":" && (waitvalue is null || waitvalue.ToString() == "") ))
						{
							if (waitop2 != "")
							{
								@lastvalue = @OperatorResult(@waitvalue2, @lastvalue, waitop2);
								@waitvalue2 = null;
								waitop2 = "";
							}
							if (waitop != "")
							{
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
						if (opstr == "||" || opstr == "|" || opstr == "or" || opstr == "&&" || opstr == "&" || opstr == "and" || opstr == "?")
						{
							if (waitop2 != "")
							{
								@lastvalue = @OperatorResult(@waitvalue2, @lastvalue, waitop2);
								@waitvalue2 = null;
								waitop2 = "";
							}
							if (waitop != "")
							{
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
							if (opstr == "||" || opstr == "|" || opstr == "or")
							{
								if (state)
								{
									@lastvalue = Object_Bool(true);
									if (opstr != "|")
									{
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
									}
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
									if (opstr != "&")
									{
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
									}
								}
								else
								{
									@lastvalue = Object_Bool(true);
								}
							}
							@xoperator = @current;
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
									@lastvalue = @OperatorResult(@waitvalue2, @lastvalue, waitop2);
									@waitvalue2 = null;
									waitop2 = "";
								}
								if (waitop != "")
								{
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
									if(lastvalue !is null && (lastvalue.IsDictionaryObject() || lastvalue.IsDictionary()))
									{
										if(lastvalue.IsDictionary())
										{
											dictionary dict = lastvalue;
											if(!lastvalue.SetValueByDictionary(dict, name))
											{
												dict.get(name, @lastvalue);
											}
										}
										else if(lastvalue.IsDictionaryObject())
										{
											dictionary@ dict = @lastvalue;
											if(!lastvalue.SetValueByDictionary(dict, name))
											{
												dict.get(name, @lastvalue);
											}
										}

									}
									else
									{
										@lastvalue = null;
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
														
								string name = currentitemvalue.ToString();
								if(lastvalue !is null && (lastvalue.IsDictionaryObject() || lastvalue.IsDictionary()))
								{
									if(lastvalue.IsDictionary())
									{
										dictionary dict = lastvalue;
										if(!lastvalue.SetValueByDictionary(dict, name))
										{
											dict.get(name, @lastvalue);
										}
									}
									else if(lastvalue.IsDictionaryObject())
									{
										dictionary@ dict = @lastvalue;
										if(!lastvalue.SetValueByDictionary(dict, name))
										{
											dict.get(name, @lastvalue);
										}
									}
								}
								else
								{
									@lastvalue = null;
								}
							}
							else if (nextop != "." && ((xoperator.Value.ToString() != "+" && xoperator.Value.ToString() != "-") || nextop == "" || (PriotiryStop.find(nextop) >= 0)))
							{
								
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
					@lastvalue = @OperatorResult(@waitvalue2, @lastvalue, waitop2);
					@waitvalue2 = null;
					waitop2 = "";
				}
				if (waitop != "")
				{
					@lastvalue = @OperatorResult(@waitvalue, @lastvalue, waitop);
					@waitvalue = null;
					waitop = "";
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
