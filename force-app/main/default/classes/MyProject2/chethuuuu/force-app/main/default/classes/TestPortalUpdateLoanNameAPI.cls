@isTest(isParallel=true)
private class TestPortalUpdateLoanNameAPI
{
    @isTest
    static void TestPortalUpdateLoanName()
    {
        Account testAccount = new Account(Name = 'Test Broker Account Name');
        Insert testAccount;
        TestUtility.runSetupData();
        loan__Loan_Account__c clContract = TestUtility.createContract();
        test.startTest();
        clcommon.Response response = new PortalUpdateLoanNameAPI().invokeAction('', null, new Map<String, Object>{
                'editLoanName' => JSON.serialize(testAccount),
                'loanId' => clContract.Id
        }); 
        test.stopTest();
        system.assertEquals('SUCCESS',response.Status);
    }
}