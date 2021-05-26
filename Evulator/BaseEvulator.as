namespace TextEngine
{
	namespace Evulator
	{
		BaseEvulator@ LastEvulator = null;
	    abstract class BaseEvulator
		{
			private dictionary@ localVars;
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
			EvulatorOptions@ Options
			{
				get
				{
					return this.Evulator.EvulatorTypes.Options;
				}
			}
			BaseEvulator()
			{
			  
			}
			protected TextEngine::ParDecoder::ParDecode@ CreatePardecode(string text, bool decode = true)
			{
				auto@ pd = @TextEngine::ParDecoder::ParDecode(text);
				@pd.CustomData = @any(@this.Evulator.ParAttributes);
				@pd.OnGetAttributes = function(item){
					TextEngine::ParDecoder::ParDecodeAttributes@ attr = null;
					item.CustomData.retrieve(@attr);
					return @attr;
				};
				if (decode) pd.Decode();
				return pd;
			}
			TextEngine::Text::TextEvulateResult@ Render(TextEngine::Text::TextElement@ tag, dictionary@ vars)
			{
				return null;
			}
			void RenderFinish(TextEngine::Text::TextElement@ tag, dictionary@ vars, TextEngine::Text::TextEvulateResult@ latestResult)
			{
			}
			Object@ EvulatePar(TextEngine::ParDecoder::ParDecode@ pardecoder, dictionary@ additionalparams = null)
			{
				TextEngine::ParDecoder::ComputeResult@ er = null;
				if(additionalparams is null)
				{
					@er = pardecoder.Items.Compute(Object_DictionaryObject(@this.Evulator.GlobalParameters), null, @Object_DictionaryList(@this.Evulator.LocalVariables));
				}
				else
				{
					DictionaryList@ di = @DictionaryList();
					di.Add(@this.Evulator.GlobalParameters);
					di.Add(@additionalparams);
					@er = pardecoder.Items.Compute(Object_DictionaryList(@this.Evulator.GlobalParameters), null, @Object_DictionaryList(@this.Evulator.LocalVariables));
				}
				return er.Result[0];
			}
			Object@ EvulateText(string text, dictionary@ additionalparams = null)
			{
				TextEngine::ParDecoder::ParDecode@ pardecoder = @this.CreatePardecode(text);
				return this.EvulatePar(@pardecoder, @additionalparams);
			}
			void SetEvulator(TextEngine::Text::TextEvulator@ evulator)
			{
				@this.Evulator = @evulator;
			}
			Object@ EvulateAttribute(TextEngine::Text::TextElementAttribute@ attribute, dictionary@ additionalparams = null)
			{
				if (@attribute is null || attribute.Value.IsEmpty()) return null;
				if(@attribute.ParData is null)
				{
					@attribute.ParData =  @this.CreatePardecode(attribute.Value);
				}
				return this.EvulatePar(@attribute.ParData, @additionalparams);
				
			}
			bool ConditionSuccess(TextEngine::Text::TextElement@ tag, string attr = "*", dictionary@ vars = null)
			{
				TextEngine::ParDecoder::ParDecode@ pardecoder = null;
				if((attr.IsEmpty() || attr=="*") && tag.NoAttrib)
				{
					if (tag.Value.IsEmpty()) return true;
					
					@pardecoder = @tag.ParData;
					if(@pardecoder is null)
					{
						@pardecoder = @this.CreatePardecode(tag.Value);
						@tag.ParData = @pardecoder;
					}
			
				}
				else
				{
					if(attr == "*") attr = "c";
					auto@ cAttr = @tag.ElemAttr.GetByName(attr);
					if (@cAttr is null || cAttr.Value.IsEmpty()) return true;
					@pardecoder = cAttr.ParData;
					if(@pardecoder is null)
					{
						@pardecoder = @this.CreatePardecode(cAttr.Value);
						@cAttr.ParData = @pardecoder;
					}
	 
				}
				Object@ res = this.EvulatePar(@pardecoder);
				if(res is null || res.IsEmptyOrDefault())
				{
														
					return false;
				}
				return true;
			}
			protected void CreateLocals()
			{
				if (@this.localVars !is null) return;
				@this.localVars = @dictionary();
				this.Evulator.LocalVariables.Add(@this.localVars);
			}
			protected void DestroyLocals()
			{
				if (@this.localVars is null) return;
				this.Evulator.LocalVariables.Remove(@this.localVars);
				@this.localVars = null;
			}
			protected void SetLocal(string name, Object@ value)
			{
				this.localVars.set(name, value);
			}
			protected Object@ GetLocal(string name)
			{
				Object@ obj;
				this.localVars.get(name, @obj);
				return obj;
			}			
			
		}
	}
}
