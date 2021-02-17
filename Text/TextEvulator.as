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
			private array<string> autoclosedtags;
			array<string> &AutoClosedTags
			{
				get
				{
					return autoclosedtags;
				}
				set
				{
					autoclosedtags = value;
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
			private array<string> conditionalTags;
			array<string>  &ConditionalTags
			{
				get
				{
					return conditionalTags;
				}
				set
				{
					conditionalTags = value;
				}
			}
			private array<string> noAttributedTags;
			array<string>  &NoAttributedTags
			{
				get
				{
					return noAttributedTags;
				}
				set
				{
					noAttributedTags = value;
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
				this.InitNoAttributedTags();
				this.InitEvulator();
				this.InitAutoClosed();
				this.InitAmpMaps();
				this.InitConditionalTags();
			}
			void OnTagClosed(TextElement@ element)
			{
				if (!this.AllowParseCondition || !this.IsParseMode || this.ConditionalTags.find(element.ElemName) < 0) return;
				element.Parent.EvulateValue(element.Index, element.Index + 1);

			}
			private void InitNoAttributedTags()
			{
				this.NoAttributedTags.insertLast("if");
			}
			private void InitConditionalTags()
			{
				this.ConditionalTags.insertLast("if");
				this.ConditionalTags.insertLast("include");
				this.ConditionalTags.insertLast("set");
				this.ConditionalTags.insertLast("unset");
			}
			void InitAutoClosed()
			{
				this.autoclosedtags = {"elif", "else", "return", "break", "continue", "include", "cm", "set", "unset"};
			}
			void InitEvulator()
			{
				@this.EvulatorTypes.Param = @TextEngine::Evulator::ParamEvulator();
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
