public with sharing class core_HttpRequestFactory
{
    public static HttpRequest buildHttpRequest(
        String HTTPMethod,
        String protocol,
        String host,
        String path,
        Map<String, String> parameterMap,
        Map<String, String> headerMap,
        String body,
        core_ICalloutAuthorizationable authorization
    )
    {
        String query = '';

        if (parameterMap != null)
        {
            for ( String paramKey : parameterMap.keySet() )
            {
                if ( String.isEmpty(query) )
                {
                    query += '?';
                }
                else
                {
                    query += '&';
                }
                query += paramKey + '=' + parameterMap.get(paramKey);
            }
        }

        HttpRequest req = new HttpRequest();

        req.setMethod( HTTPMethod );

        req.setEndpoint( protocol + '://' + host + path + query );

        if ( string.isNotBlank( body ))
        {
            req.setBody( body );
        }

        if (headerMap != null)
        {
            for ( String headerKey : headerMap.keySet() )
            {
                req.setHeader(headerKey, headerMap.get( headerKey ) );
            }
        }

        if (authorization != null)
        {
            authorization.setAuthorization(req);
        }

        return req;
    }
}