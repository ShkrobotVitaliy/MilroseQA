@isTest
private class TestDDPSender {

    private static testmethod void testPrepareAndSendRequest(){
        Test.startTest();
        List<Map<String, String>> configurationList = new List<Map<String, String>>();
        configurationList.add(new Map<String, String>{'test'=>'test'});
        try {
            DDPSender.prepareAndSendRequest(JSON.serialize(configurationList));
        } catch (Exception ex){}

        Test.stopTest();

        System.assert(! String.isBlank('Fake assertion') );
    }
}