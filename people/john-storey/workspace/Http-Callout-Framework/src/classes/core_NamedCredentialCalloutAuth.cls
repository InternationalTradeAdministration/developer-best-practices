public virtual class core_NamedCredentialCalloutAuth
    implements core_ICalloutAuthorizationable
{
    private String identifier = '';

    public String getIdentifier()
    {
        return identifier;
    }

    public core_NamedCredentialCalloutAuth setIdentifier(String value)
    {
        this.identifier = value;
        return this;
    }

    public void setAuthorization(HttpRequest request)
    {
        if (request != null)
        {
            // replace the existing https://www.acme.com -- protocol and host with   callout:namedCredentialIdentifier/pathAndQuery

            Url u = new Url(request.getEndpoint());
            String path = u.getPath();
            String query = u.getQuery();

            String workingUrl = 'callout:' + getIdentifier();

            workingUrl += path.startsWith('/') ? '' : '/';
            workingUrl += path;

            workingUrl += query.startsWith('?') ? '' : '?';
            workingUrl += query;

            system.debug( workingUrl );

            request.setEndpoint( workingUrl );
        }
        else
        {
            system.debug( System.LoggingLevel.WARN, 'An HttpRequest is required.');
        }
    }
}