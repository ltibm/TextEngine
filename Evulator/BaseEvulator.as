namespace TextEngine
{
	namespace Evulator
	{
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
			BaseEvulator()
			{
			  
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
				if(pardecoder.SurpressError != this.Evulator.SurpressError)
				{
					pardecoder.SurpressError = this.Evulator.SurpressError;
				}
				if(additionalparams !is null)
				{
					this.Evulator.LocalVariables.Add(@additionalparams);
				}
				TextEngine::ParDecoder::ComputeResult@ er = pardecoder.Items.Compute(@this.Evulator.GlobalParameters, null, @Object_DictionaryList(@this.Evulator.LocalVariables));
				if(additionalparams !is null)
				{
					this.Evulator.LocalVariables.Remove(@additionalparams);
				}
				return er.Result[0];
			}
			Object@ EvulateText(string text, dictionary@ additionalparams = null)
			{
				TextEngine::ParDecoder::ParDecode@ pardecoder = TextEngine::ParDecoder::ParDecode(text); 
				pardecoder.Decode();
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
					@attribute.ParData =  @TextEngine::ParDecoder::ParDecode(attribute.Value);
					attribute.ParData.Decode();
				}
				return this.EvulatePar(@attribute.ParData, @additionalparams);
				
			}
			bool ConditionSuccess(TextEngine::Text::TextElement@ tag, string attr = "c")
			{
				TextEngine::ParDecoder::ParDecode@ pardecoder = null;
				if(tag.NoAttrib)
				{
					if (tag.Value.IsEmpty()) return true;
					
					@pardecoder = @tag.ParData;
					if(@pardecoder is null)
					{
						@pardecoder = @TextEngine::ParDecoder::ParDecode(tag.Value);
						pardecoder.Decode();
						@tag.ParData = @pardecoder;
					}
			
				}
				else
				{
					auto@ cAttr = @tag.ElemAttr.GetByName(attr);
					if (@cAttr is null || cAttr.Value.IsEmpty()) return true;
					@pardecoder = cAttr.ParData;
					if(@pardecoder is null)
					{
						@pardecoder = @TextEngine::ParDecoder::ParDecode(cAttr.Value);
						pardecoder.Decode();
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
