namespace TextEngine
{
	namespace Evulator
	{
	    abstract class EvulatorHandler
		{
			bool OnRenderPre(TextEngine::Text::TextElement@ tag, dictionary@ vars) { return true; }
			void OnRenderPost(TextEngine::Text::TextElement@ tag, dictionary@ vars, TextEngine::Text::TextEvulateResult@ result) { }
			bool OnRenderFinishPre(TextEngine::Text::TextElement@ tag, dictionary@ vars, TextEngine::Text::TextEvulateResult@ result) { return true; }
			void OnRenderFinishPost(TextEngine::Text::TextElement@ tag, dictionary@ vars, TextEngine::Text::TextEvulateResult@ result) { }
		}
	}
}
