@isTest
private class LoanOfficeNameDBTests {
    private static LoanOfficeNameDB loanOfficeNameDBInstance = new LoanOfficeNameDB();

    @isTest
    private static void getLoanOfficeName() {

        Test.startTest();
            List<loan__Office_Name__c> loanOfficeNameList = loanOfficeNameDBInstance.getLoanOfficeName();
        Test.stopTest();

        System.assert(loanOfficeNameList != null);
        System.assert(loanOfficeNameList.isEmpty());
    }
}