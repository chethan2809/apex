@IsTest(isParallel=true)
private class CaseDBTests
{
    private static CaseDB caseDBInstance = new CaseDB();

    @IsTest
    private static void getCaseDetailsByIdTests()
    {
        Account account = TestUtility.createAccount();

        Case newCase = new Case();
        newCase.Description = 'Test Requested';
        newCase.Subject = 'Test Subject';
        newCase.AccountId = account.Id;
        newCase.Type = 'Fund Release Request';
        insert newCase;

        Test.startTest();
            Case caseRecord = caseDBInstance.getCaseDetailsById(newCase.Id, account.Id);
        Test.stopTest();

        System.assert(caseRecord != null);
    }
}