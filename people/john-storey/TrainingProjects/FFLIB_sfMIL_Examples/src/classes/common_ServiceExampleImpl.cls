public class common_ServiceExampleImpl
    implements common_IServiceExample
{
    public String AServiceMethod(Account acct)
    {
        return JSON.serializePretty(acct, false);
    }
}