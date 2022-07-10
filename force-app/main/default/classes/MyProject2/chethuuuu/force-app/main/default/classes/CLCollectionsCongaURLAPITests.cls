@isTest
private class CLCollectionsCongaURLAPITests {

    @isTest
    private static void invokeActionCongaCollection() {
        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CCCDCollectionActivitiesAPI.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Id testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Id contactId = TestUtility.getFakeId(Contact.getSObjectType());
        Id contractQueryId = TestUtility.getFakeId(APXTConga4__Conga_Merge_Query__c.getSObjectType());

        collect__Loan_Account__c collContract = new collect__Loan_Account__c();
        collContract.Id = TestUtility.getFakeId(collect__Loan_Account__c.getSObjectType());
        collContract.collect__External_ID__c = testExternalId;

        Map<String, Object> congaParamsMap = new Map<String, Object>();
        congaParamsMap.put('contractId', collContract.Id);
        congaParamsMap.put('contractQuery', contractQueryId);
        congaParamsMap.put('externalId', collContract.collect__External_ID__c);
        congaParamsMap.put('contactId', contactId);

        Test.startTest();
            clcommon.Response response = new CLCollectionsCongaURLAPI().invokeAction('', null, congaParamsMap);
        Test.stopTest();

        System.assertEquals('SUCCESS', response.status);
        System.assertEquals(0, errorLogDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void invokeActionCongaCollectionException() {
        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CLCollectionsCongaURLAPI.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Id testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Id contactId = TestUtility.getFakeId(Contact.getSObjectType());
        Id contractQueryId = TestUtility.getFakeId(APXTConga4__Conga_Merge_Query__c.getSObjectType());

        collect__Loan_Account__c collContract = new collect__Loan_Account__c();
        collContract.Id = TestUtility.getFakeId(collect__Loan_Account__c.getSObjectType());
        collContract.collect__External_ID__c = testExternalId;

        Map<String, Object> congaParamsMap = new Map<String, Object>();

        Exception ex;
        clcommon.Response response;
        Test.startTest();
        try{
            response = new CLCollectionsCongaURLAPI().invokeAction('', null, congaParamsMap);
        }catch(Exception e){
            ex = e;
        }
        Test.stopTest();

        System.assertEquals('Failed', response.status);
        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }
}