#include "DictionaryList"
	funcdef Object@ ObjectFunctionHandler(Objects@ parameters);
	enum ObjectType
 	{
		ObjectType_Empty = 0,
		ObjectType_String,
		ObjectType_Bool,
		ObjectType_Int,
		ObjectType_Double,
		ObjectType_IObject,
		ObjectType_Object,
		ObjectType_ObjectList,
		ObjectType_Dictionary,
		ObjectType_DictionaryObject,
		ObjectType_DictionaryList,
		ObjectType_Function
	}
	interface IObject
	{
	}
	Object@ Object_String(string val)
	{
		return @Object(val);
	}
	Object@ Object_Func(ObjectFunctionHandler@ func)
	{
		return Object_Function(@func);
	}
	Object@ Object_Function(ObjectFunctionHandler@ func)
	{
		Object@ obj = Object();
		obj.SetValueFunc(@func);
		return obj;
	}
	Object@ Object_Bool(bool value)
	{
		Object@ obj = Object();
		obj.SetValueBool(value);
		return obj;
	}
	Object@ Object_Int(int value)
	{
		Object@ obj = Object();
		obj.SetValueInt(value);
		return obj;
	}
	Object@ Object_Double(double value)
	{
		Object@ obj = Object();
		obj.SetValueDouble(value);
		return obj;
	}
	Object@ Object_Objects(Objects@ value)
	{
		Object@ obj = Object();
		obj.SetValue(@value);
		return obj;
	}
	Object@ Object_Dictionary(dictionary dict)
	{
		Object@ obj = Object();
		obj.SetValueDictionary(dict);
		return obj;
	}
	Object@ Object_DictionaryObject(dictionary@ dict)
	{
		Object@ obj = Object();
		obj.SetValueDictionaryObject(@dict);
		return obj;
	}
	Object@ Object_DictionaryList(DictionaryList@ dlist)
	{
		Object@ obj = Object();
		obj.SetValueDictionaryList(@dlist);
		return obj;
	}
	class Object
	{
		private ObjectType objectType;
		private any@ storedObject = @any();
		ObjectType ObjectType
		{
			get const
			{
				return objectType;
			}
		}
		Object()
		{
		}
		Object(string obj)
		{
			SetValue(obj);
		}	
		Object(IObject@ obj)
		{
			SetValue(obj);
		}
		Object(Object@ obj)
		{
			SetValue(obj);
		}
		Object(Objects@ obj)
		{
			SetValue(obj);
		}
		void SetValueBool(bool obj)
		{
			this.objectType = ObjectType_Bool;
			storedObject.store(obj);
		}
		void SetValueFunc(ObjectFunctionHandler@ handler)
		{
			this.objectType = ObjectType_Function;
			storedObject.store(@handler);
		}
		void SetValueInt(int obj)
		{				
		
			this.objectType = ObjectType_Int;
			storedObject.store(obj);	
		}
		void SetValueDouble(double obj)
		{				
			this.objectType = ObjectType_Double;
			storedObject.store(obj);	
		}
		void SetValue(string obj)
		{
			this.objectType = ObjectType_String;
			storedObject.store(obj);			
		}
		void SetValue(IObject@ obj)
		{
			this.objectType = ObjectType_IObject;
			storedObject.store(@obj);			
		}
		void SetValue(Object@ obj)
		{
			this.objectType = ObjectType_Object;
			storedObject.store(@obj);			
		}
		void SetValue(Objects@ obj)
		{
			this.objectType = ObjectType_ObjectList;
			storedObject.store(@obj);			
		}
		void SetValueDictionary(dictionary dict)
		{
			this.objectType = ObjectType_Dictionary;
			storedObject.store(dict);	
		}
		void SetValueDictionaryList(DictionaryList@ dict)
		{
			this.objectType = ObjectType_DictionaryList;
			storedObject.store(@dict);	
		}
		void SetValueDictionaryObject(dictionary@ dict)
		{
			this.objectType = ObjectType_DictionaryObject;
			storedObject.store(@dict);	
		}
		bool SetValueByDictionary(dictionary item, string key)
		{

			string s = "";
			bool b = false;
			int i = 0;
			double d = 0;
			dictionary dict;
			dictionary@ dictobj;
			bool state = false;
			Object@ obj = null;
			if (item.get(key, @dictobj) && dictobj !is null)
			{

				this.SetValueDictionaryObject(@dictobj);
			}
			if (item.get(key, @obj) && obj !is null)
			{

				return false;
			}			
			if (item.get(key, dict))
			{
				this.SetValueDictionary(dict);
			}
			else if(item.get(key, s))
			{
				this.SetValue(s);
			}
			else if (item.get(key, i))
			{
				this.SetValueInt(i);
			}
			else if (item.get(key, d))
			{
			
				this.SetValueDouble(d);
			}
			else if (item.get(key, b))
			{
				this.SetValueBool(b);
			}
			else
			{
				return false;
			}
			return true;
		}
		bool opImplConv() const  
		{
			bool obj = false;
			if(this.objectType == ObjectType_Bool)
			{
				storedObject.retrieve(obj);
			}
			return obj;
		}
		int opImplConv() const  
		{
			int obj = 0;
			if(this.objectType == ObjectType_Int)
			{
				storedObject.retrieve(obj);
			}
			else if(this.objectType == ObjectType_Double)
			{
				double d;
				storedObject.retrieve(d);
				obj = int(d);
			}
			return obj;
		}
		double opImplConv() const  
		{
			double obj = 0;
			if(this.objectType == ObjectType_Double)
			{
				storedObject.retrieve(obj);
			}
			else if(this.objectType == ObjectType_Int)
			{
				int d;
				storedObject.retrieve(d);
				obj = double(d);
			}
			return obj;
		}
		string opImplConv() const  
		{
			string obj = "";
			if(this.objectType == ObjectType_String)
			{
				storedObject.retrieve(obj);
			}
			return obj;
		}
		dictionary opImplConv() const
		{
			dictionary dict;
			if(this.objectType != ObjectType_Dictionary) return dict;
			storedObject.retrieve(dict);
			return dict;
		}
		dictionary@ opImplConv()
		{
			dictionary@ dict;
			if(this.objectType != ObjectType_DictionaryObject) return null;
			storedObject.retrieve(@dict);
			return dict;
		}
		DictionaryList@ opImplConv()
		{
			DictionaryList@ dict;
			if(this.objectType != ObjectType_DictionaryList) return null;
			storedObject.retrieve(@dict);
			return dict;
		}
		IObject@ opImplConv()  
		{
			IObject@ obj = null;
			if(this.objectType == ObjectType_IObject)
			{
				storedObject.retrieve(@obj);
			}
			return @obj;
		}
		Object@ opImplConv()  
		{
			IObject@ obj = null;
			if(this.objectType == ObjectType_Object)
			{
				storedObject.retrieve(@obj);
			}
			return @obj;
		}
		Objects@ opImplConv()  
		{
			Objects@ obj = null;
			if(this.objectType == ObjectType_ObjectList)
			{
				storedObject.retrieve(@obj);
			}
			return @obj;
		}
		ObjectFunctionHandler@ opImplConv() const  
		{
			ObjectFunctionHandler@ obj = null;
			if(this.objectType == ObjectType_Function)
			{
				storedObject.retrieve(@obj);
			}
			return @obj;
		}
		bool IsNumericType()
		{
			return this.objectType == ObjectType_Int || this.objectType == ObjectType_Double;
		}
		bool IsString()
		{
			return this.objectType == ObjectType_String;
		}
		bool IsBool()
		{
			return this.objectType == ObjectType_Bool;
		}
		bool IsDictionary()
		{
			return this.objectType == ObjectType_Dictionary;
		}
		bool IsDictionaryObject()
		{
			return this.objectType == ObjectType_DictionaryObject;
		}
		bool IsDictionaryList()
		{
			return this.objectType == ObjectType_DictionaryList;
		}
		bool IsObjects()
		{
			return this.ObjectType == ObjectType_ObjectList;
		}
		bool IsFunction()
		{
			return this.ObjectType == ObjectType_Function;
		}
		string ToString(bool boolistext = false)
		{
			string result = "";
			if(this.objectType == ObjectType_String)
			{
				storedObject.retrieve(result);
				
			}
			else if(this.ObjectType == ObjectType_Bool)
			{
				bool b = false;
				storedObject.retrieve(b);
				if(boolistext)
				{
					if(b)
					{
						result = "true";
					}
					else
					{
						result = "false";
					}
				}
				else
				{
					result = string(b);
				}
			}
			else if(this.ObjectType == ObjectType_Int)
			{
				int i = 0;
				storedObject.retrieve(i);
				result = string(i);
			}
			else if(this.ObjectType == ObjectType_Double)
			{
				double d = 0;
				storedObject.retrieve(d);
				result = string(d);
			}
			return result;
		}
		bool IsEmpty()
		{
			if(this.ObjectType == ObjectType_String)
			{
				string str = this.ToString();
				return str.IsEmpty(); 
			}
			return this.ObjectType == ObjectType_Empty;
		}

		dictionary ToDictionary()
		{
			dictionary dict;
			if(this.ObjectType == ObjectType_Dictionary)
			{
				storedObject.retrieve(dict);
			}

			return dict;
		}
		
		bool ToBool()
		{
			if(this.ObjectType == ObjectType_String)
			{
				string str = this.ToString();
				return str != "0" && !str.IsEmpty(); 
			}
			else if(this.ObjectType == ObjectType_Bool)
			{
				bool b = this;
				return b;
			}
			else if(this.IsNumericType())
			{
				double d = this;
				return d > 0;
			}
			return false;
		}
		bool IsEmptyOrDefault()
		{
			bool rest = false;
			if(this.ObjectType == ObjectType_String || this.ObjectType == ObjectType_Bool || this.IsNumericType())
			{
				rest = this.ToBool();
			}
			else if(this.ObjectType == ObjectType_Dictionary)
			{
				dictionary dict = this.ToDictionary();
				rest = dict.getSize() > 0;
			}
			else if(this.ObjectType == ObjectType_DictionaryObject)
			{
				dictionary@ dict = this;
				rest = dict.getSize() > 0;
			}
			else if(this.ObjectType == ObjectType_DictionaryList)
			{
				DictionaryList@ dict = this;
				rest = dict.Count > 0;
			}
			else if(this.ObjectType == ObjectType_ObjectList)
			{
				Objects@ objList = null;
				storedObject.retrieve(@objList);
				rest = objList !is null && objList.Count > 0;
			}
			else if(this.ObjectType == ObjectType_Function)
			{
				ObjectFunctionHandler@ handler = null;
				storedObject.retrieve(@handler);
				rest = handler !is null;
			}
			return !rest;
		}
		Object@ opAssign(bool obj)
		{
			this.SetValue(obj);
			return this;
		}
		Object@ opAssign(int obj)
		{
			this.SetValue(obj);
			return this;
		}
		Object@ opAssign(double obj)
		{
			this.SetValue(obj);
			return this;
		}		
		Object@ opAssign(string obj)
		{
			this.SetValue(obj);
			return this;
		}				
		bool opEquals(bool obj)
		{
			if(this.ObjectType !=  ObjectType_Bool)
			{
				return false;
			}
			bool b = this;
			return b == obj;
		}		
		bool opEquals(int obj)
		{
			if(this.ObjectType !=  ObjectType_Int)
			{
				return false;
			}
			int i = this;
			return i == obj;
		}
		bool opEquals(double obj)
		{
			if(this.ObjectType !=  ObjectType_Double)
			{
				return false;
			}
			double d = this;
			return d == obj;
		}
		bool opEquals(string obj)
		{
			if(this.ObjectType !=  ObjectType_String)
			{
				return false;
			}
			string s = this.ToString();
			return s == obj;
		}	
	}