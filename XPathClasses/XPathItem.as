namespace TextEngine
{
	namespace XPathClasses
	{
		XPathItem@ Parse_XPathItemNew(string xpath)
		{
            bool expisparexp = false;
            XPathItem@ pathitem = XPathItem();
            XPathBlock@ curblock = XPathBlock();
            StringBuilder@ curstr = StringBuilder();
            IXPathBlockContainer@ current = pathitem;
            XPathBlocksList@ blocks = XPathBlocksList();
            current.XPathBlockList.Add(@blocks);
            XPathExpressionsList@ curexp = curblock.XPathExpressions;
            for (uint i = 0; i < xpath.Length(); i++)
            {
   				char cur = xpath[i];
				char next = '\0';
				if(i + 1 < xpath.Length())
				{
					next = xpath[i + 1];
				}
                if(cur == '|' ||cur == ')' || cur == '(')
                {
                    if (curblock.BlockName.IsEmpty())
                    {
                        curblock.BlockName = curstr.ToString();
                    }
                    if (!curblock.BlockName.IsEmpty() || curblock.IsAttributeSelector)
                    {
                        blocks.Add(@curblock);
                    }
                    curstr.Clear();
                }
				
				if(cur == '[')
				{
					if(curblock.XPathExpressions.Count == 0)
					{
						curblock.BlockName = curstr.ToString();
						curstr.Clear();
					}
					int newi = 0;
					XPathExpression@ newexp = null;
					@newexp = @Parse_XPathExpression(xpath, i, newi);
					i = newi;
					if(!curblock.BlockName.IsEmpty())
					{
						curblock.XPathExpressions.Add(@newexp);
					}
					else
					{
						curexp.Add(@newexp);
					}
					continue;
				}
                else if (cur == '|' || cur == '(')
                {
                    IXPathList@ lastitem = current.XPathBlockList.Last();
                    if (lastitem !is null)
                    {
                        if (!lastitem.Any())
                        {
                           current.XPathBlockList.RemoveAt(current.XPathBlockList.Count - 1);
                        }
                    }

                    @curblock = @XPathBlock();
                    @curexp = @curblock.XPathExpressions;
                    if (cur == '(')
                    {
						XPathPar@ xpar = XPathPar();
                        @xpar.Parent = @current;
                        current.XPathBlockList.Add(@xpar);
                        @current = @xpar;
                    }
                    else
                    {
                        current.XPathBlockList.Add(@XPathOrItem());
                    }
                    @blocks = @XPathBlocksList();
                    current.XPathBlockList.Add(@blocks);
                    continue;
                }
                else if(cur == ')')
                {
                    IXPathList@ lastitem = current.XPathBlockList.Last();
                    if (lastitem !is null)
                    {
                        if (!lastitem.Any())
                        {
                           current.XPathBlockList.RemoveAt(current.XPathBlockList.Count - 1);
                        }
                    }
					@curexp = cast<XPathPar@>(current).XPathExpressions;
                    @current = @current.Parent;
                    expisparexp = true;
                    if (current is null)
                    {
                       // throw new Exception("Syntax error");
					   return null;
                    }
                    @blocks = @XPathBlocksList();
                    current.XPathBlockList.Add(@blocks);
                    @curblock = @XPathBlock();
                    continue;
                }
                else if (cur == '/')
                {
					if (curblock.BlockName.IsEmpty())
					{
						curblock.BlockName = curstr.ToString();
					}
					if (curblock.BlockName.IsEmpty())
					{
						if(next == '/')
						{
							curblock.BlockType = XPathBlockScanAllElem;
							i += 1;
						}
					}
                    else
                    {

                        blocks.Add(@curblock);
                        @curblock = @XPathBlock();
                        if (next == '/')
                        {
                            curblock.BlockType = XPathBlockScanAllElem;
                        }
                        curstr.Clear();
                    }
                    if(expisparexp)
                    {
                        @curexp = @curblock.XPathExpressions;
                        expisparexp = false;
                    }
                    continue;
                }
                else if (cur == '@')
                {
                    if (curblock.BlockName.IsEmpty())
                    {
                        curblock.IsAttributeSelector = true;
                    }
                    else
                    {
						return null;
                       // throw new Exception("Syntax Error");
                    }
                    continue;
                }
                curstr.Append(cur);
            }
			if(curblock.BlockName.IsEmpty())
			{
				curblock.BlockName = curstr.ToString();
			}
			if (!curblock.BlockName.IsEmpty() || curblock.IsAttributeSelector)
			{
				blocks.Add(@curblock);
			}
            IXPathList@ sonitem = current.XPathBlockList.Last();
            if (sonitem !is null)
            {
                if (!sonitem.Any())
                {
                    current.XPathBlockList.RemoveAt(current.XPathBlockList.Count - 1);
                }
            }
            return @pathitem;
		}
		XPathItem@ Parse_XPathItem(string xpath)
		{
			XPathItem@ pathitem =  XPathItem();
			XPathBlock@ curblock =  XPathBlock();
			XPathExpression@ curexp = null;
			StringBuilder@ curstr = StringBuilder();
			for (uint i = 0; i < xpath.Length(); i++)
			{
				char cur = xpath[i];
				char next = '\0';
				if(i + 1 < xpath.Length())
				{
					next = xpath[i + 1];
				}
				if(cur == '[')
				{
					if(curblock.XPathExpressions.Count == 0)
					{
						curblock.BlockName = curstr.ToString();
						curstr.Clear();
					}
					int newi = 0;
					@curexp = @Parse_XPathExpression(xpath, i, newi);
					i = newi;
					curblock.XPathExpressions.Add(@curexp);
					@curexp = @null;
					continue;
				}
				else if(cur == '/')
				{
					if (curblock.BlockName.IsEmpty())
					{
						curblock.BlockName = curstr.ToString();
					}
					if (curblock.BlockName.IsEmpty())
					{
						if(next == '/')
						{
							curblock.BlockType = XPathBlockScanAllElem;
							i += 1;
						}
					}
					else
					{
						pathitem.XPathBlocks.Add(curblock);
						@curblock = XPathBlock();
						if(next == '/')
						{
							curblock.BlockType = XPathBlockScanAllElem;
						}
						curstr.Clear();
					}
					continue;
				}
				else if(cur == '@')
				{
					if (curblock.BlockName.IsEmpty())
					{
						curblock.IsAttributeSelector = true;
					}
					else
					{
						return null;
						//throw new Exception("Syntax Error");
					}
					continue;
				}
				curstr.Append(cur);
			}
			if(curblock.BlockName.IsEmpty())
			{
				curblock.BlockName = curstr.ToString();
			}
			if (!curblock.BlockName.IsEmpty() || curblock.IsAttributeSelector)
			{
				pathitem.XPathBlocks.Add(@curblock);
			}
			return @pathitem;
		}
		class XPathItem : IXPathBlockContainer
		{
			private XPathBlocksList@ blocks = @XPathBlocksList();
			XPathBlocksList@ XPathBlocks
			{
				get const
				{
					return @blocks;
				}
				set
				{
					@blocks = @value;
				}
			}
			private XPathBlocksContainer@ xpathBlockList;
			XPathBlocksContainer@ XPathBlockList
			{
				get const
				{
					return xpathBlockList;
				}
				set
				{
					@xpathBlockList = @value;
				}
			}
			private IXPathBlockContainer@ parent;
			IXPathBlockContainer@ Parent
			{
				get const
				{
					return parent;
				}
				set
				{
					@parent = @value;
				}
			}
			XPathItem()
			{
				@this.XPathBlockList = XPathBlocksContainer();
				//@this.blocks = @XPathBlocksList();
			}
			bool IsXPathPar()
			{
				return true;
			}
		}
	}
}
