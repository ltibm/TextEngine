namespace TextEngine
{
	namespace ParDecoder
	{
		class ParFormatItem
		{
			private ParFormatType itemType;
			ParFormatType ItemType
			{
				get
				{
					return this.itemType;
				}
				set
				{
					this.itemType = value;
				}
			}

			private string itemText;
			string ItemText
			{
				get
				{
					return this.itemText;
				}
				set
				{
					this.itemText = value;
					@this.ParData = null;
				}
			}
			private ParDecode@ parData;
			ParDecode@ ParData
			{
				get
				{
					return @this.parData;
				}
				set
				{
					@this.parData = @value;
				}
			}
		}
	}
}
