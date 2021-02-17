namespace TextEngine
{
	namespace Evulator
	{
	    abstract class BaseEvulator
		{
			private TextEngine::Text::TextEvulator@ evulator;
			protected TextEngine::Text::TextEvulator@ Evulator
			{
				get const
				{
					return evulator;
				}
				set
				{
					@evulator = @value;
				}
				
			}
			BaseEvulator()
			{
			  
			}
			TextEngine::Text::TextEvulateResult@ Render(TextEngine::Text::TextElement@ tag, dictionary@ vars)
			{
				return null;
			}
			Object@ EvulateText(string text, dictionary@ additionalparams = null)
			{
				TextEngine::ParDecoder::ParDecode@ pardecoder = TextEngine::ParDecoder::ParDecode(text); 
				pardecoder.Decode();
				if(additionalparams !is null)
				{
					this.Evulator.LocalVariables.Add(@additionalparams);
				}
				TextEngine::ParDecoder::ComputeResult@ er =pardecoder.Items.Compute(@this.Evulator.GlobalParameters, null, @Object_DictionaryList(@this.Evulator.LocalVariables));
				if(additionalparams !is null)
				{
					this.Evulator.LocalVariables.Remove(@additionalparams);
				}
				return er.Result[0];
			}
			void SetEvulator(TextEngine::Text::TextEvulator@ evulator)
			{
				@this.Evulator = @evulator;
			}
			bool ConditionSuccess(TextEngine::Text::TextElement@ tag, string attr = "c")
			{
				string condition =((tag.NoAttrib) ? tag.Value : tag.GetAttribute(attr));
				if (condition.IsEmpty()) return true;
				Object@ res = this.EvulateText(condition);
				if(res is null || res.IsEmptyOrDefault())
				{
					return false;
				}
				return true;
			}
		}
	}
}
