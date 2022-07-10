public class AutoWriteOffJob implements Schedulable, Database.Batchable<SObject>, Database.Stateful {

    @TestVisible
    private static Origination_Settings__mdt defaultAutoWriteOffSetting = CustomMetaDataHelper.defaultOriginationSetting;
    private List<loan__Loan_Account__c> clContractList = new List<loan__Loan_Account__c>();

    public AutoWriteOffJob() {
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Integer missedPaymentsForDaily = CustomSettingsHelper.generalSettings != null
            && CustomSettingsHelper.generalSettings.Missed_Payments_For_Daily_Auto_WriteOff__c != null ?
                Integer.ValueOf(CustomSettingsHelper.generalSettings.Missed_Payments_For_Daily_Auto_WriteOff__c) : 60;

        Integer missedPaymentsForWeekly = CustomSettingsHelper.generalSettings != null
            && CustomSettingsHelper.generalSettings.Missed_Payments_For_Weekly_Auto_WriteOff__c != null ?
                Integer.ValueOf(CustomSettingsHelper.generalSettings.Missed_Payments_For_Weekly_Auto_WriteOff__c) : 12;

        Integer reCheckMissedPaymentsForDaily = CustomSettingsHelper.generalSettings != null
            && CustomSettingsHelper.generalSettings.Missed_Payments_For_Daily_Auto_WriteOff__c != null ?
                Integer.ValueOf(CustomSettingsHelper.generalSettings.Missed_Payments_For_Daily_Auto_WriteOff__c) : -1;

        Integer reCheckMissedPaymentsForWeekly = CustomSettingsHelper.generalSettings != null
            && CustomSettingsHelper.generalSettings.Missed_Payments_For_Weekly_Auto_WriteOff__c != null ?
                Integer.ValueOf(CustomSettingsHelper.generalSettings.Missed_Payments_For_Weekly_Auto_WriteOff__c) : -1;

        return Database.getQueryLocator ([
            SELECT Id, Name, loan__Fee_Set__c, Future_Payable_Interest_Amount__c, Auto_WriteOff_Date__c, loan__Last_Installment_Date__c,
                Latest_Number_Of_Missed_Payments__c, loan__Frequency_of_Loan_Payment__c
            FROM loan__Loan_Account__c
            WHERE loan__Invalid_Data__c = false
                AND loan__Loan_Status__c NOT IN :CLContracts.LOAN_INACTIVE_STATUSES
                AND Latest_Number_Of_Missed_Payments__c != null
                AND(
                    (
                        Auto_WriteOff_Date__c = null
                        AND (
                            (loan__Frequency_of_Loan_Payment__c = :GeneralConstants.FREQUENCY_DAILY AND Latest_Number_Of_Missed_Payments__c > :missedPaymentsForDaily)
                            OR
                            (loan__Frequency_of_Loan_Payment__c = :GeneralConstants.FREQUENCY_WEEKLY AND Latest_Number_Of_Missed_Payments__c > :missedPaymentsForWeekly)
                        )
                    )
                    OR
                    (
                        Auto_WriteOff_Date__c != null
                        AND Auto_WriteOff_Date__c > :GeneralHelper.currentSystemDate
                        AND (
                            (loan__Frequency_of_Loan_Payment__c = :GeneralConstants.FREQUENCY_DAILY AND Latest_Number_Of_Missed_Payments__c < :reCheckMissedPaymentsForDaily)
                            OR
                            (loan__Frequency_of_Loan_Payment__c = :GeneralConstants.FREQUENCY_WEEKLY AND Latest_Number_Of_Missed_Payments__c < :reCheckMissedPaymentsForWeekly)
                        )
                    )
                    OR
                    (
                        Auto_WriteOff_Date__c != null
                        AND Auto_WriteOff_Date__c <= :GeneralHelper.currentSystemDate
                    )
                )
        ]);
    }

    public void execute(Database.BatchableContext bc, List<loan__Loan_Account__c> contractList) {
        AutoWriteOffManager.setContractFieldsWhenAutoWriteOffEligible(contractList);
        clContractList.addAll(contractList);
    }

    public void execute(SchedulableContext sc) {
        if (defaultAutoWriteOffSetting.Auto_WriteOff_Job_Size__c == null) {
            throw new AutoWriteOffJobException('Auto_WriteOff_Job_Size__c is null');
        }
        Database.executeBatch(this, Integer.ValueOf(defaultAutoWriteOffSetting.Auto_WriteOff_Job_Size__c));
    }

    public static void execute() {
        AutoWriteOffJob autoWriteOffJobInstance = new AutoWriteOffJob();
        autoWriteOffJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext bc) {
        AutoWriteOffManager.handleAutoWriteOff(clContractList);
    }

    private class AutoWriteOffJobException extends Exception {}
}