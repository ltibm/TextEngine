namespace HTMLUTIL
{
	string ToAttribute(TextEngine::Text::TextElementAttributesList@ attributes, array<string> exclude = {})
    {
		if (attributes is null || attributes.Count == 0) return "";
		StringBuilder@ sb = StringBuilder();
		for(int i = 0; i < attributes.Count; i++)
		{
			TextEngine::Text::TextElementAttribute@ item = @attributes[i];
			if(exclude.find(item.Name) >= 0) continue;
			if(item.Value.IsEmpty())
			{
				sb.Append(" " + item.Name);
			}
			else
			{
				sb.Append(" " + item.Name + "=\"" + item.Value.Replace("\"", "\\\"") + "\"");
			}
		}
		return sb.ToString();
	}
}