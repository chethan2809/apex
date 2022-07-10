public class ClawbackProcessingJob implements Schedulable, Database.Batchable<SObject> {

    @TestVisible
    private static Origination_Settings__mdt defaultClawbackSetting = CustomMetaDataHelper.defaultOriginationSetting;
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    public ClawbackProcessingJob() {}

    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator([
            SELECT Id, Name, loan__Frequency_of_Loan_Payment__c, Latest_Number_Of_Missed_Payments__c, loan__Disbursal_Date__c, Broker_Contact__c,
                Broker_Contact__r.AccountId
            FROM loan__Loan_Account__c
            WHERE (
                    (
                        loan__Frequency_of_Loan_Payment__c = :GeneralConstants.FREQUENCY_DAILY
                        AND Latest_Number_Of_Missed_Payments__c >= 3
                        AND loan__Disbursal_Date__c = :GeneralHelper.currentSystemDate.addDays(
                                -Integer.valueOf(CAN_General_Settings__c.getInstance().Clawback_Eligible_Days_Daily__c)
                            )
                    )
                OR (
                    loan__Frequency_of_Loan_Payment__c = :GeneralConstants.FREQUENCY_WEEKLY
                    AND Latest_Number_Of_Missed_Payments__c >= 2
                    AND loan__Disbursal_Date__c = :GeneralHelper.currentSystemDate.addDays(
                            -Integer.valueOf(CAN_General_Settings__c.getInstance().Clawback_Eligible_Days_Weekly__c)
                        )
                    )
                )
                AND Total_Unpaid_Due_Amount_To_Current__c > 0.0
        ]);
    }

    public void execute(Database.BatchableContext bc, List<loan__Loan_Account__c> loanAccountList) {
        Map<Id, loan__Loan_Account__c> clawbackLoanAccountMap = new Map<Id, loan__Loan_Account__c >();
        Set<Id> brokerAccountIds = new Set<Id>();
        try {
            for(loan__Loan_Account__c loanObj : loanAccountList) {
                clawbackLoanAccountMap.put(loanObj.Id, loanObj);
                if(loanObj.Broker_Contact__c != null) {
                    brokerAccountIds.add(loanObj.Broker_Contact__r.AccountId);
                }
            }
            if(!clawbackLoanAccountMap.isEmpty()) {
                ClawbackUtil.processClawBack(clawbackLoanAccountMap, brokerAccountIds);
            }

        } catch(Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'ClawbackProcessingJob Failed', e.getMessage() + e.getStackTraceString(), null,
                null, ErrorLogs.ERROR, null, false
            );
            errorLogDBInstance.addInsert(errorLog);
        }
        errorLogDBInstance.executeInserts();
    }

    public void execute(SchedulableContext sc) {
        if (defaultClawbackSetting.Clawback_Batch_Size__c == null) {
            throw new ClawbackProcessingJobException('Clawback_Batch_Size__c is null');
        }
        Database.executeBatch(this, Integer.ValueOf(defaultClawbackSetting.Clawback_Batch_Size__c));
    }

    public static void execute() {
        ClawbackProcessingJob clawbackProcessingJobInstance = new ClawbackProcessingJob();
        clawbackProcessingJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext bc) {

    }

    private class ClawbackProcessingJobException extends Exception {}
}