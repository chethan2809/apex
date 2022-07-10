@IsTest(isParallel=true)
private class LeadTriggerHandlerTests
{
    private static LeadTriggerHandler leadTriggerHandler = new LeadTriggerHandler();
    private static Lead leadRecord;

    @IsTest
    private static void beforeAndAfterUpdateTests()
    {
        Map<String, String> makeMap = new Map<String, String>();
        makeMap.put('LeadSource', 'Merchant Phone');
        makeMap.put('Lead_Type__c', Leads.BROKER);
        makeMap.put('IsConverted', 'true');
        makeMap.put('Broker_Email__c', 'Hawaii@Yopmail.com');
        makeMap.put('State__c', 'Hawaii');
        makeMap.put('State', 'Hawaii');
        String jsonString = JSON.serialize(makeMap);
        leadRecord = (Lead) JSON.deserialize(jsonString, Lead.class);

        Test.startTest();
        leadTriggerHandler.beforeInsert(new List<Lead> {leadRecord});
        leadTriggerHandler.beforeUpdate(new List<Lead> {leadRecord});
        leadTriggerHandler.afterUpdate(new List<Lead> {leadRecord});
        Test.stopTest();

        System.assertEquals('HI', leadRecord.State);
    }

    @IsTest
    private static void afterUpdateBrokerTests()
    {
        Map<String, String> makeMap = new Map<String, String>();
        makeMap.put('LeadSource', 'Merchant Phone');
        makeMap.put('Lead_Type__c', Leads.BROKER);
        makeMap.put('IsConverted', 'true');
        String jsonString = JSON.serialize(makeMap);
        leadRecord = (Lead) JSON.deserialize(jsonString, Lead.class);

        Test.startTest();
        leadTriggerHandler.afterUpdate(new List<Lead> {leadRecord});
        Test.stopTest();

        System.assert(leadRecord.Lead_Type__c == Leads.BROKER);
    }

    @IsTest
    private static void afterUpdatePortalLeadTests()
    {
        Map<String, String> makeMap = new Map<String, String>();
        makeMap.put('Lead_Type__c', Leads.MERCHANT);
        makeMap.put('LeadSource','Broker Phone');
        makeMap.put('Portal_Lead_Converted__c','false');
        String jsonString = JSON.serialize(makeMap);
        leadRecord = (Lead) JSON.deserialize(jsonString, Lead.class);

        Test.startTest();
        leadTriggerHandler.afterUpdate(new List<Lead> {leadRecord});
        Test.stopTest();

        System.assert(leadRecord.Lead_Type__c == Leads.MERCHANT);
    }
}