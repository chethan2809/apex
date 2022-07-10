@isTest
private class CCCDUpdateCollectionStatusAPITests {

    @isTest
    private static void testUpdateCollectionStatus(){
        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        collect__Loan_Account__c collContract = new collect__Loan_Account__c();
        collContract.Id = TestUtility.getFakeId(collect__Loan_Account__c.getSObjectType());
        collContract.collect__External_ID__c = testExternalId;

        DBManagerTestsStub collectionContractDBStubInstance = new DBManagerTestsStub();
        collectionContractDBStubInstance.genericReturnObject = new List<collect__Loan_Account__c>{collContract};
        CCCDUpdateCollectionStatusAPI.collectionContractDBInstance = (CollectionContractDB) Test.createStub(CollectionContractDB.class, collectionContractDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CCCDUpdateCollectionStatusAPI.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Test.startTest();
            clcommon.Response response = new CCCDUpdateCollectionStatusAPI().invokeAction('', null, new Map<String, Object>{
                'contractId' => JSON.deserializeUntyped(JSON.serialize(collContract.Id)),
                'collectionStatus' => 'Active – Legal Internal',
                'collectionSubStatus' => 'Accommodation'
            });
        Test.stopTest();

        System.assertEquals('SUCCESS', response.status);
        System.assertEquals(0, errorLogDBStubInstance.forInsertSObjects.size());
        System.assertEquals(1, collectionContractDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void testUpdateCollectionStatusException(){
        Id contractId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CCCDUpdateCollectionStatusAPI.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Exception ex;
        clcommon.Response response;
        Test.startTest();
        try{
            response = new CCCDUpdateCollectionStatusAPI().invokeAction('', null, new Map<String, Object>{
                'contractId' => JSON.deserializeUntyped(JSON.serialize(contractId)),
                'collectionStatus' => 'Active – Legal Internal',
                'collectionSubStatus' => 'Accommodation'
            });
        }catch(Exception e){
            ex = e;
        }
        Test.stopTest();

        System.assertEquals('ERROR', response.status);
        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }
}