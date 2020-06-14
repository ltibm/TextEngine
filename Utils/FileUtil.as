namespace FILEUTIL
{
	string ReadAllText(string file)
    {
		StringBuilder@ builder = StringBuilder();
		::File@ pFile = g_FileSystem.OpenFile(file, OpenFile::READ);
		if(pFile is null ||!pFile.IsOpen()) return "";  
		string cline = "";
		int iline = 0;
		
		while(!pFile.EOFReached())
		{

			//pFile.ReadLine(cline);
			builder.Append(pFile.ReadCharacter());
		}	

		pFile.Close();
		
		return builder.ToString();
	}
	bool Exists(string file)
	{
		::File@ pFile = g_FileSystem.OpenFile(file, OpenFile::READ);
		if(pFile is null ||!pFile.IsOpen()) return false;
		pFile.Close();
		return true;
	}
	bool Delete(string file)
	{
		if(!Exists(file)) return false;
		g_FileSystem.RemoveFile(file);
		return true;
	}
	void SaveAllText(string file, string content)
	{
		::File@ pFile = g_FileSystem.OpenFile(file, OpenFile::WRITE);
		if(pFile is null || !pFile.IsOpen()) return;
		pFile.Write(content);
		pFile.Close();
	}
}