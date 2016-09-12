@RestResource(urlMapping='/GetStatementOfAccountsPdf/*')
global class StatementOfAccountsSenderRest {

    @HttpGet
    global static void StatementOfAccountsSenderRest() {
        RestRequest req = RestContext.request;
        Map<String, String> params = req.params;
        PageReference pdfPage = new PageReference( AccountReportController.SOA_REPORT_LINK );
        for( String key : params.keySet() ) {
            pdfPage.getParameters().put( key, params.get(key) );
        }

        RestContext.response.addHeader( 'Content-Type', 'text/plain' );
        RestContext.response.responseBody = Blob.valueOf( EncodingUtil.base64Encode( pdfPage.getContentAsPdf() ) );
    }

    //Call this method from Batch Apex, it returds PDF body
    global static Blob createStatementOfAccountsReport( String pageParams, String sessionId ) {
        String addr = System.Url.getSalesforceBaseUrl().ToExternalForm() + '/services/apexrest/GetStatementOfAccountsPdf' + '/' + pageParams;
        HttpRequest req = new HttpRequest();
        req.setEndpoint( addr );
        req.setMethod( 'GET' );
        req.setTimeout( 60000 );
        req.setHeader( 'Authorization', 'OAuth ' + sessionId );

        Http http = new Http();
        HttpResponse response = http.send( req );
        return EncodingUtil.base64Decode( response.getBody() );
    }

}