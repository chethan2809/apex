@isTest
private class ClawbackTriggerHandlerTests {

    private static ClawbackTriggerHandler clawbackTriggerHandlerInstance = new ClawbackTriggerHandler();

    @isTest
    private static void afterInsert() {

        Clawback__c clawback = new Clawback__c();
        clawback.Id = TestUtility.getFakeId(Clawback__c.getSObjectType());
        clawback.Clawback_Amount__c = 1000;

        Map<Id, Clawback__c> newClawbackMap = new Map<Id, Clawback__c>();
        newClawbackMap.put(clawback.Id, clawback);

        Test.startTest();
            clawbackTriggerHandlerInstance.afterInsert(newClawbackMap);
        Test.stopTest();

        system.assertEquals(clawback, newClawbackMap.get(clawback.Id));
    }
}