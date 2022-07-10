public class EISRenewalBatchJob implements Schedulable, Database.Batchable<sObject>
{
    @TestVisible
    private static Origination_Settings__mdt defaultEISRenewalSetting = CustomMetaDataHelper.defaultOriginationSetting;
    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();
    @TestVisible
    private static CLContractDB clContractDBInstance = new CLContractDB();

    public EISRenewalBatchJob(){}

    public Database.QueryLocator start (database.BatchableContext BC)
    {
        Decimal percentageLimit = 50;
        Id accountId;
        Integer renewalEligibleDays = CustomSettingsHelper.generalSettings != null
            && CustomSettingsHelper.generalSettings.Renewal_Eligible_Days__c != null ?
                Integer.ValueOf(CustomSettingsHelper.generalSettings.Renewal_Eligible_Days__c) : 60;

        return Database.getQueryLocator([
            SELECT Id, Name, Phone, Business_Tax_ID__c, BillingStreet, BillingCity, BillingState, Last_Date_of_Activity__c,
                BillingPostalCode, Last_Business_Credit_Pull__c, Sic, Customer_Since__c, Legacy_Percent_Paid__c, Legacy_Current_Balance__c,
                clcommon__Legal_Entity_Type__c, Industry, clcommon__Email__c, BillingAddress, BillingCountry, Is_Exclusivity__c,
                Doing_Business_As_Name__c, AnnualRevenue, BillingBuildingNumber__c, clcommon__Legal_Entity_Type__r.Name,
                Fax, Legacy_Average_Bounced_Number_12M__c, Legacy_Average_Bounced_Number_1M__c, Legacy_Ever_Paid_Days__c,
                Legacy_Renewal_Eligible__c, Legacy_Renewal_Application_Created_Date__c, Migrated_Date__c, loan__Borrower__c,
                Type, AccountSource, Business_Name__c, Legacy_Payment_Frequency__c, Legacy_Number_of_Current_Missed_Payments__c,
                Legacy_Latest_Missed_Payment_Date__c, OwnerId, Broker_Account__c, Broker_Contact__c, Legacy_GAV__c,
                Current_Active_Contract_Number__c, Legacy_Negative_CAN_History__c, Migrated_From__c, Legacy_Active_Contract__c
            FROM Account
            WHERE Legacy_Renewal_Eligible__c = true
                AND Legacy_Negative_CAN_History__c = false
                AND Is_Exclude_From_Auto_Renewal_Process__c = false
                AND ( Auto_Renewed_App_Declined_Date__c = null
                    OR Auto_Renewed_App_Declined_Date__c <= :GeneralHelper.currentSystemDate.addDays(-renewalEligibleDays)
                    )
                AND Legacy_Active_Contract__c = true
                AND Migrated_Date__c != null
                AND Migrated_From__c = 'EIS'
                AND loan__Borrower__c = true
                AND Type = :Accounts.BORROWER
        ]);
    }

    public void execute (Database.BatchableContext BC , List<Account> eisAccountList) {
        for(Account account : eisAccountList) {
            EISRenewalManager.createRenewalApplication(account);
        }
    }

    public void execute(SchedulableContext sc) {
        if (defaultEISRenewalSetting.EIS_Renewal_Batch_Size__c == null) {
            throw new EISRenewalBatchJobException('EIS_Renewal_Batch_Size__c is null');
        }
        Database.executeBatch(this, Integer.ValueOf(defaultEISRenewalSetting.EIS_Renewal_Batch_Size__c));
    }

    public static void execute() {
        EISRenewalBatchJob eisRenewalBatchJobInstance = new EISRenewalBatchJob();
        eisRenewalBatchJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext BC){
    }

    private class EISRenewalBatchJobException extends Exception {}
}