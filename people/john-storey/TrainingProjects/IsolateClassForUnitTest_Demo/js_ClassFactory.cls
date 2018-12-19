public class js_ClassFactory
{
    private static Map<Type, Type> objectMap = new Map<Type, Type>();
    private static Map<Type, Object> mock_objectMap = new Map<Type, Object>();

    static
    {
        objectMap.put('js_OtherClass', js_OtherClass.Class);
    }

    public static Object newInstance(Type t)
    {
        if (mock_objectMap.containsKey(t))
        {
            return mock_objectMap.get(t);
        }

        if (objectMap.containsKey(t))
        {
            return objectMap.get(t).newInstance();
        }

        throw new js_ClassFactoryException('Factory does not support \'' + t + '\'');
    }

    public static void setMock(Type t, Object mockObject)
    {
        mock_objectMap.put(t, mockObject);
    }

    public class js_ClassFactoryException
        extends Exception
    {
        // Creates throwable Exception
    }
}