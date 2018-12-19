/**
 *  core_BaseGETCallout
 */
public abstract class core_BaseGETCallout
    extends core_BaseCallout
{
    protected override CALLOUT_METHODS getMethod()
    {
        return CALLOUT_METHODS.GET;
    }

    protected override String getPostRequestBody()
    {
        return null;
    }
}