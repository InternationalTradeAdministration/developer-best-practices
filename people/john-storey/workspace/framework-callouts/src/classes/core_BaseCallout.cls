/**
 *  core_BaseCallout
 *
 *  The base class used for all callouts
 */
public abstract class core_BaseCallout
{
    public enum CALLOUT_METHODS
    {
        POST, GET
    }

    private map<String, String> headerMap = new map<String, String>();

    protected core_ICalloutAuthorizationable auth = null;

    protected boolean isDebugOn = false;

    protected abstract String getPath();

    protected abstract map<string, String> getParamMap();

    protected abstract CALLOUT_METHODS getMethod();

    protected abstract String getPostRequestBody();

    public abstract core_BaseCallout execute();

    protected abstract String getHost();

    protected virtual String getProtocol()
    {
        return 'https';
    }

    public virtual core_BaseCallout setAuthorization( core_ICalloutAuthorizationable auth )
    {
        this.auth = auth;
        return this;
    }

    public map<String, String> getHeaderMap()
    {
        return this.headerMap;
    }

    public String getProtocolAndHost()
    {
        return getProtocol() + '://' + getHost();
    }

    private HttpRequest getRequest()
    {
        if ( isDebugOn )
        {
            System.debug( 'url == ' + getProtocolAndHost() + getPath() );
            System.debug( 'paramMap == ' + getParamMap() );
            System.debug( 'headerMap == ' + getHeaderMap() );
            System.debug( 'postRequestBody == ' + getPostRequestBody() );
        }

        string HTTPMethod = getMethod() == null ? CALLOUT_METHODS.GET.name() : getMethod().name();

        return
            core_HttpRequestFactory.buildHttpRequest(
                HTTPMethod,
                getProtocol(),
                getHost(),
                getPath(),
                getParamMap(),
                getHeaderMap(),
                getPostRequestBody(),
                auth
            );
    }

    protected virtual HttpResponse executeCallout()
    {
        Http h = new Http();

        HttpResponse resp = h.send( getRequest() );

        return resp;
    }

    public core_BaseCallout debug()
    {
        this.isDebugOn = true;
        return this;
    }

    public abstract CalloutResponse getResponse();

    public interface CalloutResponse
    {
        integer getTotalNumberOfRecordsFound();
    }
}