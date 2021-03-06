//Author: Lt.
//https://steamcommunity.com/id/ibmlt
namespace TextEngine
{
	namespace Text
	{
	    class TextEvulator
		{
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
			private TextElement@ elements;
			TextElement@ Elements
			{
				get { return elements; }
				set { @elements = @value; }
			}
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
			private bool throwExceptionIFPrevIsNull;
			bool ThrowExceptionIFPrevIsNull 
			{ 
				get const
				{
					return throwExceptionIFPrevIsNull;
				}					
				set
				{
					throwExceptionIFPrevIsNull = value;
				}
			}
			private int depth;
			private int Depth 
			{ 
				get const
				{
					return depth;
				}					
				set
				{
					depth = value;
				}
			}
			private char lefttag = '{';
			char LeftTag 
			{ 
				get const
				{
					return lefttag;
				}
				set
				{
					lefttag = value;
				}
			}
			private char righttag  = '}';
			char RightTag 
			{ 
				get const
				{
					return righttag;
				}
				set
				{
					righttag = value;
				}
			}
			private string noParseTag = "noparse";
			string NoParseTag
			{
				get const
				{
					return noParseTag;
				}
				set
				{
					noParseTag = value;
				}
			}
			private bool noParseEnabled;
			bool NoParseEnabled 
			{
				get const
				{
					return noParseEnabled;
				}
				set
				{
					noParseEnabled = value;
				}
			}
			private char paramchar  = '%';
			char ParamChar 
			{ 
				get const
				{
					return paramchar;
				}
				set
				{
					paramchar = value;
				}
			}
			private dictionary aliasses;
			dictionary &Aliasses
			{
				get
				{
					return aliasses;
				}
				set
				{
					aliasses = value;
				}
			}
			private dictionary@ globalParameters;
			dictionary@ GlobalParameters
			{
				get const
				{
					return globalParameters;
				}
				set
				{
					@globalParameters = @value;
				}
			}
			private dictionary@ defineParameters;
			dictionary@ DefineParameters
			{
				get const
				{
					return defineParameters;
				}
				set
				{
					@defineParameters = @value;
				}
			}
			private DictionaryList@ localVariables;
			DictionaryList@ LocalVariables
			{
				get const
				{
					return localVariables;
				}
				set
				{
					@localVariables = @value;
				}
			}
			private bool paramNoAttrib;
			bool ParamNoAttrib
			{
				get const
				{
					return paramNoAttrib;
				}
				set
				{
					paramNoAttrib = value;
				}
			}
			private bool decodeAmpCode;
			bool DecodeAmpCode
			{
				get const
				{
					return decodeAmpCode;
				}
				set
				{
					decodeAmpCode = value;
				}
			}
			private bool allowParseCondition;
			bool AllowParseCondition
			{
				get const
				{
					return allowParseCondition;
				}
				set
				{
					allowParseCondition = value;
				}
			}
			private TextEngine::Evulator::EvulatorTypes@ evulatorTypes;
			TextEngine::Evulator::EvulatorTypes@ EvulatorTypes
			{
				get const
				{
					return evulatorTypes;
				}
				set
				{
					@evulatorTypes = @value;
				}
			}
			private bool supportExclamationTag;
			bool SupportExclamationTag
			{
				get const
				{
					return supportExclamationTag;
				}
				set
				{
					supportExclamationTag = value;
				}
			}
			private bool supportCDATA;
			bool SupportCDATA
			{
				get const
				{
					return supportCDATA;
				}
				set
				{
					supportCDATA = value;
				}
			}			
			private bool allowXMLTag;
			bool AllowXMLTag
			{
				get const
				{
					return allowXMLTag;
				}
				set
				{
					allowXMLTag = value;
				}
			}			
			private bool trimMultipleSpaces;
			bool TrimMultipleSpaces
			{
				get const
				{
					return trimMultipleSpaces;
				}
				set
				{
					trimMultipleSpaces = value;
				}
			}
			private bool trimStartEnd;
			bool TrimStartEnd
			{
				get const
				{
					return trimStartEnd;
				}
				set
				{
					trimStartEnd = value;
				}
			}
			private dictionary ampMaps;
			dictionary &AmpMaps
			{
				get
				{
					return ampMaps;
				}
				set
				{
					ampMaps = value;
				}
			}
			private TextElementInfos@ tagInfos;
			TextElementInfos@ TagInfos
			{
				get
				{
					return tagInfos;
				}
				set
				{
					@tagInfos = @value;
				}
			}		
			private bool isParseMode;
			bool IsParseMode
			{
				get const
				{
					return isParseMode;
				}
				set
				{
					isParseMode = value;
				}
			}
			private dictionary@ customDataDictionary;
			dictionary@ CustomDataDictionary
			{
				get
				{
					return customDataDictionary;
				}
			}
			private dictionary charMap;
			dictionary &CharMap
			{
				get
				{
					return charMap;
				}
				set
				{
					charMap = value;
				}
			}
			private any@ customDataSingle;
			any@ CustomDataSingle
			{
				get
				{
					return customDataSingle;
				}
				set
				{
					@customDataSingle = @value;
				}
			}	
			private bool allowCharMap;
			bool AllowCharMap
			{
				get const
				{
					return allowCharMap;
				}
				set
				{
					allowCharMap = value;
				}
			}
			void ApplyXMLSettings()
			{
				this.SupportCDATA = true;
				this.SupportExclamationTag = true;
				this.LeftTag = '<';
				this.RightTag = '>';
				this.AllowXMLTag = true;
				this.TrimStartEnd = true;
				this.NoParseEnabled = false;
				this.DecodeAmpCode = true;
				this.TrimMultipleSpaces = true;
			}
			TextEvulator(string text = "", bool isfile = false)
			{
				@this.customDataDictionary = @dictionary();
				@this.TagInfos = @TextElementInfos();
				@this.LocalVariables = @DictionaryList();
				@this.DefineParameters = @dictionary();
				this.LocalVariables.Add(@this.DefineParameters);
				@this.EvulatorTypes = @TextEngine::Evulator::EvulatorTypes();
				@this.Elements = TextElement();
				this.Elements.ElemName = "#document";
				this.Elements.ElementType = Document;
				if (isfile)
				{
					this.Text = FILEUTIL::ReadAllText(text);
				}
				else
				{
					this.Text = text;
				}
				this.InitStockTagOptions();
				this.InitEvulator();
				this.InitAmpMaps();
			}
			void OnTagClosed(TextElement@ element)
			{
				if (!this.AllowParseCondition || !this.IsParseMode || !((element.GetTagFlags() & TEF_ConditionalTag) != TEF_NONE)) return;
				element.Parent.EvulateValue(element.Index, element.Index + 1);

			}
			void InitStockTagOptions()
			{
				//* default flags;
				this.TagInfos["*"].Flags = TEF_NONE;
				this.TagInfos["elif"].Flags =  TEF_AutoClosedTag;
				this.TagInfos["else"].Flags = TEF_AutoClosedTag;
				this.TagInfos["return"].Flags = TEF_AutoClosedTag;
				this.TagInfos["break"].Flags = TEF_AutoClosedTag;
				this.TagInfos["continue"].Flags = TEF_AutoClosedTag;
				this.TagInfos["include"].Flags = TEF_AutoClosedTag | TEF_ConditionalTag;
				this.TagInfos["cm"].Flags = TEF_AutoClosedTag;
				this.TagInfos["set"].Flags = TEF_AutoClosedTag | TEF_ConditionalTag;
				this.TagInfos["unset"].Flags = TEF_AutoClosedTag | TEF_ConditionalTag;
				this.TagInfos["if"].Flags = TEF_NoAttributedTag | TEF_ConditionalTag;
			}
			void InitEvulator()
			{
				@this.EvulatorTypes.Param = @TextEngine::Evulator::ParamEvulator();
				@this.EvulatorTypes.GeneralType = @TextEngine::Evulator::GeneralEvulator();
				@this.EvulatorTypes.Text = @TextEngine::Evulator::TexttagEvulator();
				@this.EvulatorTypes["if"] = @TextEngine::Evulator::IfEvulator();
				@this.EvulatorTypes["include"] = @TextEngine::Evulator::IncludeEvulator();
				@this.EvulatorTypes["for"] = @TextEngine::Evulator::ForEvulator();
				@this.EvulatorTypes["switch"] = @TextEngine::Evulator::SwitchEvulator();
				@this.EvulatorTypes["return"] = @TextEngine::Evulator::ReturnEvulator();
				@this.EvulatorTypes["break"] = @TextEngine::Evulator::BreakEvulator();
				@this.EvulatorTypes["continue"] = @TextEngine::Evulator::ContinueEvulator();
				@this.EvulatorTypes["noprint"] = @TextEngine::Evulator::NoPrintEvulator();
				@this.EvulatorTypes["set"] = @TextEngine::Evulator::SetEvulator();
				@this.EvulatorTypes["unset"] = @TextEngine::Evulator::UnsetEvulator();

			}
			void InitAmpMaps()
			{
				this.AmpMaps.set("nbsp", " ");
				this.AmpMaps.set("amp", "&");
				this.AmpMaps.set("quot", "\"");
				this.AmpMaps.set("lt", "<");
				this.AmpMaps.set("gt", ">");
			}
			void Parse()
			{
				TextEvulatorParser@ parser = TextEvulatorParser(@this);
				parser.Parse(@this.Elements, this.Text);
			}
			void Parse(TextElement@ baselement, string text)
			{
				TextEvulatorParser@ parser = TextEvulatorParser(@this);
				parser.Parse(@baselement, text);
			}
			void SaveToFile(string file)
			{
				FILEUTIL::SaveAllText(file, this.Elements.Inner(true));
			}
		}
	}
}
