public class LoanRenewalEligibilityJob implements Schedulable, Database.Batchable<SObject> {
    @TestVisible
    private static Origination_Settings__mdt defaultLoanRenewalSetting = CustomMetaDataHelper.defaultOriginationSetting;
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    public LoanRenewalEligibilityJob(){}

    public Database.Querylocator start(Database.BatchableContext bc) {
        Decimal percentageLimit = 50;
        Integer renewalEligibleDays = CustomSettingsHelper.generalSettings != null
            && CustomSettingsHelper.generalSettings.Renewal_Eligible_Days__c != null ?
                Integer.ValueOf(CustomSettingsHelper.generalSettings.Renewal_Eligible_Days__c) : 60;

        return Database.getQueryLocator([
            SELECT Id, Name, loan__Account__c, loan__Principal_Paid__c, Broker_Contact__c, Broker_Contact__r.AccountId,
                loan__Account__r.Name, Application__c, Application__r.Annual_Volume__c, Application__r.Primary_Guarantor__c,
                Application__r.Primary_Guarantor__r.AccountId, Application__r.OwnerId, Application__r.Sales_Rep__c,
                Application__r.Underwriter__c
            FROM loan__Loan_Account__c
            WHERE loan__Invalid_Data__c = false
               AND Percentage_Paid__c >= :percentageLimit
                AND (
                    Latest_Missed_Payment_Date__c = null
                    OR (Latest_Missed_Payment_Date__c > :GeneralHelper.currentSystemDate.addDays(-33)
                        AND Latest_Missed_Payment_Date__c <= :GeneralHelper.currentSystemDate
                        )
                    )
                AND (
                        (loan__Frequency_of_Loan_Payment__c = :GeneralConstants.FREQUENCY_DAILY AND Latest_Number_Of_Missed_Payments__c <= 5)
                    OR
                        (loan__Frequency_of_Loan_Payment__c = :GeneralConstants.FREQUENCY_WEEKLY AND Latest_Number_Of_Missed_Payments__c < 1)
                    )
                AND loan__Account__r.Is_Exclude_From_Auto_Renewal_Process__c = false
                AND loan__Account__r.Legacy_Negative_CAN_History__c = false
                AND ( Last_Auto_Renewal_Close_Date__c = NULL
                    OR Last_Auto_Renewal_Close_Date__c <= :GeneralHelper.currentSystemDate.addDays(-renewalEligibleDays)
                    )
                AND loan__Loan_Status__c IN :CLContracts.LOAN_ACTIVE_STATUSES
        ]);
    }

    public void execute(Database.BatchableContext bC, List<loan__Loan_Account__c> contractList) {
        if(!contractList.isEmpty()) {
            try {
                LoanRenewalEligibilityManager.createRenewalOpportunity(contractList);
            } catch(Exception e) {
                Error_Log__c errorLog = ErrorLogs.createErrorLog(
                    'LoanRenewalEligibilityJob Failed', e.getMessage() + e.getStackTraceString(),  JSON.serialize(contractList),
                    contractList.get(0).Id, ErrorLogs.ERROR, null, false
                );
                errorLogDBInstance.addInsert(errorLog);
            }
            errorLogDBInstance.executeInserts();
        }
    }

    public void execute(SchedulableContext sc) {
        if (defaultLoanRenewalSetting.Loan_Renewal_Batch_Size__c == null) {
            throw new LoanRenewalEligibilityJobException('Loan_Renewal_Batch_Size__c is null');
        }
        Database.executeBatch(this, Integer.ValueOf(defaultLoanRenewalSetting.Loan_Renewal_Batch_Size__c));
    }

    public static void execute() {
        LoanRenewalEligibilityJob loanRenewalEligibilityJobJobInstance = new LoanRenewalEligibilityJob();
        loanRenewalEligibilityJobJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext BC) {

    }

    private class LoanRenewalEligibilityJobException extends Exception {}
}