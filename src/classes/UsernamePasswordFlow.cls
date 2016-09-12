public class UsernamePasswordFlow {
    String username;
    String password;
    String clientId;
    String clientSecret;
    String tokenEndpoint;

    public UsernamePasswordFlow(String tokenEndpoint, String username, String password, String clientId, String clientSecret) {
        this.tokenEndpoint = tokenEndpoint;
        this.username = username;
        this.password = password;
        this.clientId = clientId;
        this.clientSecret = clientSecret;
    }

    public String requestAccessToken() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(tokenEndpoint);
        req.setMethod('POST');
        req.setBody(buildHttpQuery(new Map<String, String> {
            'grant_type' => 'password',
            'username' => username,
            'password' => password,
            'client_id' => clientId,
            'client_secret' => clientSecret
        }));

        Http http = new Http();
        HttpResponse resp = http.send(req);

        Map<String, Object> m =
            (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());

        return (String) m.get('access_token');
    }

    static String buildHttpQuery(Map<String, String> queryParams) {
        if (queryParams.isEmpty()) {
            return '';
        }

        String[] params = new String[] {};
        for (String k : queryParams.keySet()) {
            String v = EncodingUtil.urlEncode(queryParams.get(k), 'UTF-8');

            params.add(String.format('{0}={1}', new String[] { k, v }));
        }

        return String.join(params, '&');
    }
}