public class LoanOfficeNameTriggerHandler {
    public void afterUpdate(Map<Id, loan__Office_Name__c> newLoanOfficeNameMap, Map<Id, loan__Office_Name__c> oldLoanOfficeNameMap) {
        Date updatedSystemDate;

        for (loan__Office_Name__c newLoanOfficeName : newLoanOfficeNameMap.values()) {
            loan__Office_Name__c oldLoanOfficeName = oldLoanOfficeNameMap.get(newLoanOfficeName.Id);
            if(newLoanOfficeName.loan__Current_System_Date__c != oldLoanOfficeName.loan__Current_System_Date__c) {
                updatedSystemDate = newLoanOfficeName.loan__Current_System_Date__c;
            }
        }

        if(updatedSystemDate  != null) {
            UserManager.updateCommunityUserDetailsOnSystemDateChange(updatedSystemDate);
        }
    }
}