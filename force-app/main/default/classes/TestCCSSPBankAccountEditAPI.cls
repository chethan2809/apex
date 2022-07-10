@isTest
private class TestCCSSPBankAccountEditAPI {

    @isTest
    private static void customPortalSubmitConsentAPI(){
        Account account = TestUtility.createAccount();

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CCSSPBankAccountEditAPI.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Case caseRecord = new Case();
        caseRecord.Id = TestUtility.getFakeId(Case.getSObjectType());

        DBManagerTestsStub caseDBStubInstance = new DBManagerTestsStub();
        caseDBStubInstance.genericReturnObject = new List<Case>{caseRecord};
        CCSSPBankAccountEditAPI.caseDBInstance = (CaseDB) Test.createStub(CaseDB.class, caseDBStubInstance);

        Test.startTest();
            clcommon.Response response = new CCSSPBankAccountEditAPI().invokeAction('', null, new Map<String, Object>{
                'accountId' => account.Id,
                'bankName' =>'bankName',
                'accountNumber' =>'123456789',
                'accountType' =>'Saving',
                'routingNumber' =>'092853894858'
            });
        Test.stopTest();

        System.assert(response != null);
    }

    @isTest
    private static void customPortalSubmitConsentAPIException(){
        Contact contact = TestUtility.createContact();

        Test.startTest();
            clcommon.Response response = new CCSSPBankAccountEditAPI().invokeAction('', null, new Map<String, Object>{
                'accountId' => contact.Id,
                'bankName' =>'bankName',
                'accountNumber' =>'123456789',
                'accountType' =>'Savings',
                'routingNumber' =>'092853894858'
            });
        Test.stopTest();

        System.assert(response != null);
        System.assertEquals('Failed', response.Status);
    }
}