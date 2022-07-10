@isTest
private class CCCDCollectionActivitiesAPITests {

    @isTest
    private static void testCollectionActivitiesActionTypeCreateAndEdit(){
        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CCCDCollectionActivitiesAPI.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Id testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        collect__Loan_Account__c collContract = new collect__Loan_Account__c();
        collContract.Id = TestUtility.getFakeId(collect__Loan_Account__c.getSObjectType());
        collContract.collect__External_ID__c = testExternalId;

        collect__Collection_Activity__c collActivity = new collect__Collection_Activity__c();
        collActivity.Id = TestUtility.getFakeId(collect__Collection_Activity__c.getSObjectType());

        DBManagerTestsStub collectionActivitiesDBStubInstance = new DBManagerTestsStub();
        collectionActivitiesDBStubInstance.genericReturnObject = new List<collect__Collection_Activity__c>{collActivity};
        CCCDCollectionActivitiesAPI.collectionActivitiesDBInstance = (CollectionActivitiesDB) Test.createStub(CollectionActivitiesDB.class, collectionActivitiesDBStubInstance);

        Map<String, Object> collectionActivityMap = paramsMapActionTypeCreate();

        Test.startTest();
            clcommon.Response response = new CCCDCollectionActivitiesAPI().invokeAction('', null, collectionActivityMap);
        Test.stopTest();

        System.assertEquals('SUCCESS', response.status);
        System.assertEquals(0, errorLogDBStubInstance.forInsertSObjects.size());
        System.assertEquals(1, collectionActivitiesDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void testCollectionActivitiesActionTypeisSupervisorTrue(){

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CCCDCollectionActivitiesAPI.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Id testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        collect__Loan_Account__c collContract = new collect__Loan_Account__c();
        collContract.Id = TestUtility.getFakeId(collect__Loan_Account__c.getSObjectType());
        collContract.collect__External_ID__c = testExternalId;

        collect__Collection_Activity__c collActivity = new collect__Collection_Activity__c();
        collActivity.Id = TestUtility.getFakeId(collect__Collection_Activity__c.getSObjectType());

        DBManagerTestsStub collectionActivitiesDBStubInstance = new DBManagerTestsStub();
        collectionActivitiesDBStubInstance.genericReturnObject = new List<collect__Collection_Activity__c>{collActivity};
        CCCDCollectionActivitiesAPI.collectionActivitiesDBInstance = (CollectionActivitiesDB) Test.createStub(CollectionActivitiesDB.class, collectionActivitiesDBStubInstance);

        Map<String, Object> collectionActivityMap = paramsMapActionTypeEdit(collContract.Id, collActivity.Id);
        collectionActivityMap.put('isSupervisor', true);
        collectionActivityMap.put('isCompleted', true);

        Test.startTest();
            clcommon.Response response = new CCCDCollectionActivitiesAPI().invokeAction('', null, collectionActivityMap);
        Test.stopTest();

        System.assertEquals('SUCCESS', response.status);
        System.assertEquals(0, errorLogDBStubInstance.forInsertSObjects.size());
        System.assertEquals(1, collectionActivitiesDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void testCollectionActivitiesActionTypeisSupervisorFalse(){
        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CCCDCollectionActivitiesAPI.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Id testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        collect__Loan_Account__c collContract = new collect__Loan_Account__c();
        collContract.Id = TestUtility.getFakeId(collect__Loan_Account__c.getSObjectType());
        collContract.collect__External_ID__c = testExternalId;

        collect__Collection_Activity__c collActivity = new collect__Collection_Activity__c();
        collActivity.Id = TestUtility.getFakeId(collect__Collection_Activity__c.getSObjectType());

        DBManagerTestsStub collectionActivitiesDBStubInstance = new DBManagerTestsStub();
        collectionActivitiesDBStubInstance.genericReturnObject = new List<collect__Collection_Activity__c>{collActivity};
        CCCDCollectionActivitiesAPI.collectionActivitiesDBInstance = (CollectionActivitiesDB) Test.createStub(CollectionActivitiesDB.class, collectionActivitiesDBStubInstance);

        Map<String, Object> collectionActivityMap = paramsMapActionTypeEdit(collContract.Id, collActivity.Id);
        collectionActivityMap.put('isSupervisor', false);

        Test.startTest();
            clcommon.Response response = new CCCDCollectionActivitiesAPI().invokeAction('', null, collectionActivityMap);
        Test.stopTest();

        System.assertEquals('SUCCESS', response.status);
        System.assertEquals(0, errorLogDBStubInstance.forInsertSObjects.size());
        System.assertEquals(1, collectionActivitiesDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void testCollectionActivitiesException(){
        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CCCDCollectionActivitiesAPI.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Id testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        collect__Loan_Account__c collContract = new collect__Loan_Account__c();
        collContract.Id = TestUtility.getFakeId(collect__Loan_Account__c.getSObjectType());
        collContract.collect__External_ID__c = testExternalId;

        collect__Collection_Activity__c collActivity = new collect__Collection_Activity__c();
        collActivity.Id = TestUtility.getFakeId(collect__Collection_Activity__c.getSObjectType());

        DBManagerTestsStub collectionActivitiesDBStubInstance = new DBManagerTestsStub();
        collectionActivitiesDBStubInstance.genericReturnObject = new List<collect__Collection_Activity__c>{collActivity};
        CCCDCollectionActivitiesAPI.collectionActivitiesDBInstance = (CollectionActivitiesDB) Test.createStub(CollectionActivitiesDB.class, collectionActivitiesDBStubInstance);

        Map<String, Object> collectionActivityMap = paramsMapActionTypeEdit(collContract.Id, collActivity.Id);

        Exception ex;
        clcommon.Response response;
        Test.startTest();
        try{
            response = new CCCDCollectionActivitiesAPI().invokeAction('', null, collectionActivityMap);
        }catch(Exception e){
            ex = e;
        }
        Test.stopTest();

        System.assertEquals('ERROR', response.status);
        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }

    private static Map<String, Object> paramsMapActionTypeEdit(Id loanAccountId, Id collActivityId){
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Date judgementEntered = GeneralHelper.currentSystemDate;
        Date oldestDueDate = GeneralHelper.currentSystemDate.addDays(20);
        Date demandLetterSent = GeneralHelper.currentSystemDate.addDays(10);

        Map<String, Object> paramMap = new Map<String, Object>();
        paramMap.put('loanAccountId', loanAccountId);
        paramMap.put('loanContractName', 'Test Contract');
        paramMap.put('proofOfClaim', true);
        paramMap.put('judgementEntered', judgementEntered);
        paramMap.put('oldestDueDate', oldestDueDate);
        paramMap.put('demandLetterSent', demandLetterSent);
        paramMap.put('daysPastDue', 100);
        paramMap.put('debitConsolidator', 'Test Debit');
        paramMap.put('attorneyAssigned', 'Bender Commercial Law');
        paramMap.put('judgementAmount', 2000);
        paramMap.put('courtNumber', '100');
        paramMap.put('bankruptcyChapter', '11');
        paramMap.put('legalDepartmentContact', 'Ed Dietz');
        paramMap.put('hasAttorney', 'Test Attorney');
        paramMap.put('caseNumber', '1234');
        paramMap.put('actionText', 'Message');
        paramMap.put('caseStatus', 'Active - Legal Internal');
        paramMap.put('caseSubStatus', 'New Matter - Legal Review');
        paramMap.put('actionType', 'Edit Activity');
        paramMap.put('activityId', collActivityId);
        return paramMap;
    }

    private static Map<String, Object> paramsMapActionTypeCreate(){
        Id collActivityId = TestUtility.getFakeId(collect__Collection_Activity__c.getSObjectType());
        Id collContractId = TestUtility.getFakeId(collect__Loan_Account__c.getSObjectType());

        Map<String, Object> paramMap = paramsMapActionTypeEdit(collContractId, collActivityId);
        paramMap.put('actionType', 'Create Activity');
        return paramMap;
    }
}