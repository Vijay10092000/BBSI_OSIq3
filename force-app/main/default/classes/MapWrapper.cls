public class MapWrapper {
    
    private Map<Object, Object> theMap;

    public MapWrapper()
    {
        theMap = new Map<Object, Object>();
    }

    // Expose Map methods from your wrapper here, I'll do get() and values() as an example
    public Object gvalue(Object key)
    {
        return theMap.get(key);
    }
    
    public void put(Object key, object inMap)
    {
        theMap.put(key, inMap);
    }
 
    public Object values {
		get{
			return theMap.get('helpmap');
		}
	}
    
    public Object HelpResourceMap {
		get{
			return theMap.get('helpmap');
		}
	}
    // Etc, etc...

}