public virtual class core_KeyValueHeaderCalloutAuth
    implements core_ICalloutAuthorizationable
{
    private string accessKey = '';

    public void setAccessKey(string value)
    {
        this.accessKey = value;
    }

    public String getAuthorizationHash()
    {
        return EncodingUtil.base64Encode( Blob.valueOf( this.accessKey + ':' + this.secretKey ) );
    }

    private string secretKey = '';

    public void setSecretKey(String value)
    {
        this.secretKey = value;
    }

    public void setAuthorization(HttpRequest request)
    {
        if (request != null)
        {
            request.setHeader('Authorization', 'Basic ' + getAuthorizationHash());
        }
        else
        {
            system.debug( System.LoggingLevel.WARN, 'An HttpRequest is required.');
        }
    }
}