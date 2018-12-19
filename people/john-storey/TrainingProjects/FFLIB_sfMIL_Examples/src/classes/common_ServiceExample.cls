public class common_ServiceExample
{
    private static common_IServiceExample service()
    {
        return (common_IServiceExample) fflibext_Application.Service.newInstance(common_IServiceExample.class);
    }

    public static String AServiceMethod(Account acct)
    {
        return service().AServiceMethod(acct);
    }
}