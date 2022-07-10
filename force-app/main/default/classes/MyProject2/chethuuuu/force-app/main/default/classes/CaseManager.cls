public class CaseManager {
    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();
    @TestVisible
    private static CaseDB caseDBInstance = new CaseDB();

    public static void createFundingReleaseCase(Set<Id> applicationIds) {

        for(genesis__Applications__c application : applicationDBInstance.getApplicationsByIds(applicationIds)){
            Case newCase = new Case();
            if(GeneralHelper.queueByNameMap.containsKey(GeneralConstants.FUND_RELEASE_TEAM_QUEUE)) {
                newCase.ownerId = GeneralHelper.queueByNameMap.get(GeneralConstants.FUND_RELEASE_TEAM_QUEUE).Id;
            }
            newCase.Description = 'Amount Requested = '+ application.genesis__Loan_Amount__c + ', Amount Eligible = ' + application.Renewal_Concurrent_LoanAccount__r.Concurrent_Eligible_Amount__c;
            newCase.Subject = 'Funding Release Request for ' + application.Name;
            newCase.Application__c = application.Id;
            newCase.Type = GeneralConstants.CASE_TYPE_FUND_RELEASE_REQUEST;
            caseDBInstance.addInsert(newCase);
        }

        caseDBInstance.executeInserts();
    }
}