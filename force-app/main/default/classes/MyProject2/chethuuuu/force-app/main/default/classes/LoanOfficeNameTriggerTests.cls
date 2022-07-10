@IsTest
private class LoanOfficeNameTriggerTests {
    @isTest
    private static void loanOfficeNameTrigger() {
        TestUtility.runSetupData();
        loan__Office_Name__c loanOfficeName = TestUtility.createLoanOfficeName();

        loanOfficeName.loan__Current_System_Date__c = TestUtility.currentSystemDate.addDays(2);
        update loanOfficeName;

        list<loan__Office_Name__c> loanOfficeNameList = [
            SELECT Id, loan__Current_System_Date__c
            FROM loan__Office_Name__c
        ];

        System.assertEquals(1, loanOfficeNameList.size());
        System.assertEquals(loanOfficeName.loan__Current_System_Date__c, loanOfficeNameList[0].loan__Current_System_Date__c);
    }
}