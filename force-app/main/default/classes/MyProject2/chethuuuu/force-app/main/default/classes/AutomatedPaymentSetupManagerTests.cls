@isTest
private class AutomatedPaymentSetupManagerTests {
    @isTest
    static void updateAPSFieldIfAutoWriteOff() {
        loan__Loan_Account__c clContract = new loan__Loan_Account__c();
        clContract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        clContract.Is_Auto_Write_Off_Batch__c = true;

        loan__Automated_Payment_Setup__c newAPSRecord = new loan__Automated_Payment_Setup__c();
        newAPSRecord.loan__Type__c = 'RECURRING';
        newAPSRecord.loan__CL_Contract__c = clContract.Id;
        newAPSRecord.loan__Active__c = false;
        newAPSRecord.Id = TestUtility.getFakeId(loan__Automated_Payment_Setup__c.getSObjectType());
        List<loan__Automated_Payment_Setup__c> newAPSList = new List<loan__Automated_Payment_Setup__c>{newAPSRecord};

        Map<Id, List<loan__Automated_Payment_Setup__c>> contractIdByAPSList = new Map<Id, List<loan__Automated_Payment_Setup__c>> ();
        contractIdByAPSList.put(clContract.Id, newAPSList);

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{clContract};
        AutomatedPaymentSetupManager.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        Test.startTest();
            List<loan__Loan_Account__c> clContractShellList = AutomatedPaymentSetupManager.updateAPSFieldIfAutoWriteOff(contractIdByAPSList);
        Test.stopTest();

        System.assertEquals(1, clContractShellList.size());
        System.assertEquals(false, clContractShellList.get(0).Is_Auto_Write_Off_Batch__c);
    }
}