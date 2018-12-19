public interface aaa_IClassWithStatic
{
    String getClassName();
    String getMagicNumber();
    void setMagicNumber(String mn);
}


public class aaa_ApplicationFactory
{
    public static aaa_IClassWithStatic newInstance(String token)
    {
        aaa_IClassWithStatic actual_class = null;

        if ('one'.equalsIgnoreCase(token))
            actual_class = (aaa_IClassWithStatic) Type.forName('aaa_ClassOne').newInstance();

        else if ('two'.equalsIgnoreCase(token))
            actual_class = (aaa_IClassWithStatic) Type.forName('aaa_ClassTwo').newInstance();

        if (actual_class == null) throw new ApplicationFactoryException('The specified token is not implemented -- ' + token);
        
        return actual_class;
    }

    public class ApplicationFactoryException
        extends Exception
    {}
}


public class aaa_ClassOne
	implements aaa_IClassWithStatic
{
	public static String getClassName()
    {
        return 'aaa_ClassOne';
    }
    
    private String magicNumber = '';

    public String getMagicNumber()
    {
        return magicNumber;
    }
    
    public void setMagicNumber(String mn)
    {
        magicNumber = mn;
    }
}


public class aaa_ClassTwo
	implements aaa_IClassWithStatic
{
	public static String getClassName()
    {
        return 'aaa_ClassTwo';
    }
    
    private String magicNumber = '';

    public String getMagicNumber()
    {
        return magicNumber;
    }
    
    public void setMagicNumber(String mn)
    {
        magicNumber = mn;
    }
}


@isTest
private class aaa_Consumer
{
	@isTest
    static void test()
    {
        aaa_IClassWithStatic x = aaa_ApplicationFactory.newInstance('one');
        x.setMagicNumber('42');
        System.assertEquals('aaa_ClassOne', x.getClassName());
        System.assertEquals('42', x.getMagicNumber());
        
        x = aaa_ApplicationFactory.newInstance('two');
        x.setMagicNumber('77');
        System.assertEquals('aaa_ClassTwo', x.getClassName());
        System.assertEquals('77', x.getMagicNumber());
        
        aaa_IClassWithStatic y = aaa_ApplicationFactory.newInstance('two');
        y.setMagicNumber('5');
        System.assertEquals('aaa_ClassTwo', y.getClassName());
        System.assertEquals('5', y.getMagicNumber());
        System.assertEquals('77', x.getMagicNumber());
    }
}