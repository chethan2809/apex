public class EISDataToCLSDataConvertBatchJob implements Schedulable, Database.Batchable<sObject>
{
    @TestVisible
    private static Origination_Settings__mdt defaultEISRenewalSetting = CustomMetaDataHelper.defaultOriginationSetting;
    @TestVisible
    private static CLContractDB clContractDBInstance = new CLContractDB();

    public EISDataToCLSDataConvertBatchJob(){}

    public Database.QueryLocator start (database.BatchableContext BC)
    {
        return Database.getQueryLocator([
            SELECT Id, Name, Phone, Business_Tax_ID__c, BillingStreet, BillingCity, BillingState, Last_Date_of_Activity__c,
                BillingPostalCode, Last_Business_Credit_Pull__c, Sic, Customer_Since__c, Legacy_Percent_Paid__c, Legacy_Current_Balance__c,
                clcommon__Legal_Entity_Type__c, Industry, clcommon__Email__c, BillingAddress, BillingCountry,Migrated_From__c,
                Doing_Business_As_Name__c, AnnualRevenue, BillingBuildingNumber__c, clcommon__Legal_Entity_Type__r.Name,
                Fax, Legacy_Average_Bounced_Number_12M__c, Legacy_Average_Bounced_Number_1M__c, Legacy_Ever_Paid_Days__c,
                Legacy_Renewal_Eligible__c, Legacy_Renewal_Application_Created_Date__c, Migrated_Date__c, loan__Borrower__c,
                Type, AccountSource, Business_Name__c, Legacy_Payment_Frequency__c, Legacy_Number_of_Current_Missed_Payments__c,
                Legacy_Latest_Missed_Payment_Date__c, OwnerId, Broker_Account__c, Broker_Contact__c, Legacy_GAV__c, Current_Active_Contract_Number__c,
                EIS_To_CLS_Converted__c
            FROM Account
            WHERE Migrated_From__c = 'EIS'
                AND Migrated_Date__c != null
                AND Type = 'Borrower'
                AND loan__Borrower__c = true
                AND AccountSource = 'EIS'
                AND EIS_To_CLS_Converted__c = false
        ]);
    }

    public void execute (Database.BatchableContext BC , List<Account> eisAccountList) {
        for(Account account : eisAccountList)
        {
            EISDataToCLSDataManager.convertToCLSDataModel(account);
        }
    }

    public void execute(SchedulableContext sc) {
        if (defaultEISRenewalSetting.EIS_To_CLS_Convert_Batch_Size__c == null) {
            throw new EISDataToCLSDataConvertBatchJobException('EIS_To_CLS_Convert_Batch_Size__c is null');
        }
        Database.executeBatch(this, Integer.ValueOf(defaultEISRenewalSetting.EIS_To_CLS_Convert_Batch_Size__c));
    }

    public static void execute() {
        EISDataToCLSDataConvertBatchJob eisToCLSConvertBatchJobInstance = new EISDataToCLSDataConvertBatchJob();
        eisToCLSConvertBatchJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext BC){
    }

    private class EISDataToCLSDataConvertBatchJobException extends Exception {}
}