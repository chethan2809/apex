@IsTest(isParallel=true)
private class LeadsTests
{
    private static Lead leadRecord;

    @IsTest
    private static void leadMandatoryMerchantInformationCheckTest()
    {
        Map<String, String> leadMap = new Map<String, String>();
        leadMap.put('LastName','Test Lead');
        leadMap.put('Lead_Type__c','Merchant');
        leadMap.put('LeadSource','Merchant Phone');
        leadMap.put('Status',Leads.CLOSED_CONVERTED);
        String jsonString = JSON.serialize(leadMap);
        leadRecord = (Lead) JSON.deserialize(jsonString, Lead.class);

        Test.startTest();
        Leads.leadMandatoryInformationCheck(leadRecord, Leads.CLOSED_CONVERTED);
        Test.stopTest();

        System.assertEquals(Leads.mandatoryCheck, false);
    }

    @IsTest
    private static void leadMandatoryMerchantInformationLeadSourceCheckTest()
    {
        Map<String, String> leadMap = new Map<String, String>();
        leadMap.put('LastName','Test Lead');
        leadMap.put('LeadSource', null);
        String jsonString = JSON.serialize(leadMap);
        leadRecord = (Lead) JSON.deserialize(jsonString, Lead.class);

        Test.startTest();
        Leads.leadMandatoryInformationCheck(leadRecord, Leads.CLOSED_CONVERTED);
        Test.stopTest();

        System.assertEquals(Leads.mandatoryCheck, false);
    }

    @IsTest
    private static void leadMandatoryBrokerInformationCheckTest()
    {
        Map<String, String> leadMap = new Map<String, String>();
        leadMap.put('LastName','Test Lead');
        leadMap.put('Email', null);
        leadMap.put('Lead_Type__c','Broker');
        leadMap.put('LeadSource','Broker Phone');
        leadMap.put('Status',Leads.CLOSED_CONVERTED);
        String jsonString = JSON.serialize(leadMap);
        leadRecord = (Lead) JSON.deserialize(jsonString, Lead.class);

        Test.startTest();
        Leads.leadMandatoryInformationCheck(leadRecord, Leads.CLOSED_CONVERTED);
        Test.stopTest();

        System.assertEquals(Leads.mandatoryCheck, false);
    }

    @IsTest
    private static void leadMandatoryMerchantEmailInformationCheckTest()
    {
        Map<String, String> leadMap = new Map<String, String>();
        leadMap.put('LastName','Test Lead');
        leadMap.put('Lead_Type__c','Merchant');
        leadMap.put('LeadSource','Email');
        leadMap.put('Broker_Contact__c', null);
        leadMap.put('PostalCode', '12345678998');
        leadMap.put('Postal_Code__c', '12345678998');
        leadMap.put('Status',Leads.CLOSED_CONVERTED);
        String jsonString = JSON.serialize(leadMap);
        leadRecord = (Lead) JSON.deserialize(jsonString, Lead.class);

        Test.startTest();
        Leads.leadMandatoryInformationCheck(leadRecord, Leads.CLOSED_CONVERTED);
        Test.stopTest();

        System.assertEquals(Leads.mandatoryCheck, false);
    }

    @IsTest
    private static void leadRecordFieldsAssignMerchantTest()
    {
        Map<String, String> leadMap = new Map<String, String>();
        leadMap.put('LastName','Test Lead');
        leadMap.put('Lead_Type__c','Merchant');
        leadMap.put('Status',Leads.CLOSED_CONVERTED);
        String jsonString = JSON.serialize(leadMap);
        leadRecord = (Lead) JSON.deserialize(jsonString, Lead.class);

        Contact contact = TestUtility.createContact();

        Test.startTest();
        Leads.leadRecordFieldsAssign(leadRecord, new List<Contact> {contact});
        Test.stopTest();

        System.assert(leadRecord.RecordTypeId != null);
    }

    @IsTest
    private static void leadRecordFieldsAssignBrokerTest()
    {
        Map<String, String> leadMap = new Map<String, String>();
        leadMap.put('LastName','Test Lead');
        leadMap.put('Lead_Type__c','Broker');
        leadMap.put('Status',Leads.CLOSED_CONVERTED);
        String jsonString = JSON.serialize(leadMap);
        leadRecord = (Lead) JSON.deserialize(jsonString, Lead.class);

        Contact contact = TestUtility.createContact();

        Test.startTest();
        Leads.leadRecordFieldsAssign(leadRecord, new List<Contact> {contact});
        Test.stopTest();

        System.assert(leadRecord.RecordTypeId != null);
    }

    @IsTest
    private static void leadMerchantQualificationCriteriaTest()
    {
        leadRecord = testDataPrepare();

        Test.startTest();
        Leads.leadQualificationCriteria(leadRecord, Leads.CLOSED_CONVERTED);
        Test.stopTest();

        System.assertEquals(Leads.qualifyCheck, false);
    }

    @IsTest
    private static void leadBrokerQualificationCriteriaTest()
    {
        Map<String, String> makeMap = new Map<String, String>();
        makeMap.put('Lead_Type__c','Broker');
        makeMap.put('LeadSource','Broker Phone');
        makeMap.put('Tax_ID__c', null);
        makeMap.put('Status',Leads.CLOSED_CONVERTED);
        String jsonString = JSON.serialize(makeMap);
        leadRecord = (Lead) JSON.deserialize(jsonString, Lead.class);

        Test.startTest();
        Leads.leadQualificationCriteria(leadRecord, Leads.CLOSED_CONVERTED);
        Test.stopTest();

        System.assertEquals(Leads.qualifyCheck, null);
    }

    private static Lead testDataPrepare()
    {
        Map<String, String> leadMap = TestUtility.getLeadMap();
        leadMap.put('Lead_Type__c','Merchant');
        leadMap.put('LeadSource','Broker Portal');
        leadMap.put('Status','Leads.CLOSED_CONVERTED');
        leadMap.put('Broker_Email__c','Test2Company@example.com');
        leadMap.put('Title__c','Other');
        leadMap.put('Industry','Real Estate');
        leadMap.put('Country','United State');
        leadMap.put('How_much_do_you_Need__c',null);
        leadMap.put('Biz_Start_Date__c','2019-12-12');
        leadMap.put('DOB__c','2009-12-12');
        leadMap.put('Tax_ID__c', null);
        leadMap.put('Broker_Contact__c', null);
        leadMap.put('Portal_Lead_Converted__c', 'false');
        leadMap.put('Status',Leads.CLOSED_CONVERTED);
        String jsonString = JSON.serialize(leadMap);
        leadRecord = (Lead) JSON.deserialize(jsonString, Lead.class);
        return leadRecord;
    }
}