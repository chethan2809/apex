public class LoanConcurrentEligibilityJob implements Schedulable, Database.Batchable<SObject> {
    @TestVisible
    public static Origination_Settings__mdt defaultLoanConcurrentSetting = CustomMetaDataHelper.defaultOriginationSetting;
    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();
    @TestVisible
    private static OpportunityDB opportunityDBInstance = new OpportunityDB();

    public LoanConcurrentEligibilityJob(){}

    public Database.Querylocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator([
            SELECT Id,loan__Loan_Status__c,Number_Of_Missed_Payments__c,loan__Principal_Paid__c,
                loan__Account__c, loan__Account__r.Concurrent_Eligible_Amount__c, loan__Disbursal_Date__c,
                loan__Account__r.Name, Application__r.Primary_Guarantor__c
            FROM loan__Loan_Account__c
            WHERE loan__Account__r.Concurrent_Eligible_Amount__c > 0
                AND loan__Account__r.Concurrent_Eligible__c = false
        ]);
    }

    public void execute(Database.BatchableContext bc, List<loan__Loan_Account__c> contractList) {
        for(loan__Loan_Account__c loanAccount : contractList) {
            Account accountRecord = new Account(Id = loanAccount.loan__Account__c);
            Integer disbursedDays = loanAccount.loan__Disbursal_Date__c.daysBetween(GeneralHelper.currentSystemDate);
            if(loanAccount.loan__Loan_Status__c == CLContracts.LOAN_STATUS_ACTIVE_GOOD_STANDING && disbursedDays <= 90
                && loanAccount.Number_Of_Missed_Payments__c < 3 && loanAccount.loan__Account__r.Concurrent_Eligible_Amount__c >= 5000
            ) {
                accountRecord.Concurrent_Eligible__c = true;
                Opportunity opportunityRecord = new Opportunity();
                opportunityRecord.Name = loanAccount.loan__Account__r.Name;
                opportunityRecord.StageName = PortalConstants.LEAD_INITIAL_STAGE_NAME;
                opportunityRecord.CloseDate = GeneralHelper.currentSystemDate.addYears(1);
                opportunityRecord.AccountId = loanAccount.loan__Account__c;
                opportunityRecord.Requested_Loan_Amount__c = loanAccount.loan__Account__r.Concurrent_Eligible_Amount__c;
                opportunityRecord.Primary_Contact__c = loanAccount.Application__r.Primary_Guarantor__c;
                opportunityRecord.Sub_Status__c = 'Score Pending';
                opportunityRecord.Type = GeneralConstants.LOAN_TYPE_CONCURRENT;
                opportunityDBInstance.addInsert(opportunityRecord);
            } else{
                accountRecord.Concurrent_Eligible_Amount__c = 0;
            }
            accountDBInstance.addUpdate(accountRecord);
        }
        accountDBInstance.executeUpdates();
        opportunityDBInstance.executeInserts();
   }

    public void execute(SchedulableContext sc) {
        if (defaultLoanConcurrentSetting.Loan_Concurrent_Batch_Size__c == null) {
            throw new LoanConcurrentEligibilityJobException('Loan_Concurrent_Batch_Size__c is null');
        }
        Database.executeBatch(this, Integer.ValueOf(defaultLoanConcurrentSetting.Loan_Concurrent_Batch_Size__c));
    }

    public void finish(Database.BatchableContext BC) {

    }

    private class LoanConcurrentEligibilityJobException extends Exception {}

}