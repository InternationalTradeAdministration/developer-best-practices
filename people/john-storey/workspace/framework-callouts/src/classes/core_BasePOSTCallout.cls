/**
 *  core_BasePOSTCallout
 */
public abstract class core_BasePOSTCallout
    extends core_BaseCallout
{
    protected override CALLOUT_METHODS getMethod()
    {
        return CALLOUT_METHODS.POST;
    }

    private string postRequestBody = null;

    protected override String getPostRequestBody()
    {
        return postRequestBody;
    }

    protected void addPostRequestBodyLine( String postRequestLine )
    {
        if ( string.isBlank( this.postRequestBody ) )
        {
            this.postRequestBody = postRequestLine;
        }
        else
        {
            this.postRequestBody = '\n' + postRequestLine;
        }
    }

    protected void addPostRequestBody( Object postRequest )
    {
        if ( postRequest != null )
        {
            this.postRequestBody = JSON.serialize(postRequest, true);
        }
    }
}