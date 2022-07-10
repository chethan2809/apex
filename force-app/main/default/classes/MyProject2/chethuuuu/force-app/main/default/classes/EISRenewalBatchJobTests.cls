@istest
private class EISRenewalBatchJobTests {
    @TestSetup
    static void makeData(){
        TestUtility.runSetupData();
        Account account = TestUtility.createAccount();
    }

    @isTest
    private static void EISRenewalBatchJob(){
        Account account = [SELECT Id, Name, Phone, Business_Tax_ID__c, BillingStreet, BillingCity, BillingState, Last_Date_of_Activity__c,
        BillingPostalCode, Last_Business_Credit_Pull__c, Sic, Customer_Since__c, Legacy_Percent_Paid__c, Legacy_Current_Balance__c,
        clcommon__Legal_Entity_Type__c, Industry, clcommon__Email__c, BillingAddress, BillingCountry, Legacy_Active_Contract__c,
        Doing_Business_As_Name__c, AnnualRevenue, BillingBuildingNumber__c, clcommon__Legal_Entity_Type__r.Name,
        Fax, Legacy_Average_Bounced_Number_12M__c, Legacy_Average_Bounced_Number_1M__c, Legacy_Ever_Paid_Days__c,
        Legacy_Renewal_Eligible__c, Legacy_Renewal_Application_Created_Date__c, Migrated_Date__c, loan__Borrower__c,
        Type, AccountSource, Business_Name__c, Legacy_Payment_Frequency__c, Legacy_Number_of_Current_Missed_Payments__c,
        Legacy_Latest_Missed_Payment_Date__c, OwnerId, Broker_Account__c, Broker_Contact__c FROM Account LIMIT 1];

        account.Legacy_Renewal_Eligible__c = true;
        account.Auto_Renewed_App_Declined_Date__c = null;
        account.Legacy_Negative_CAN_History__c = false;
        account.Migrated_Date__c = date.newInstance(2021, 1, 1);
        account.Migrated_From__c = 'EIS';
        account.Legacy_Percent_Paid__c = 60;
        account.Legacy_Latest_Missed_Payment_Date__c = GeneralHelper.currentSystemDate;
        account.Legacy_Payment_Frequency__c = 'DAILY';
        account.Legacy_Number_of_Current_Missed_Payments__c = 5;
        account.loan__Borrower__c = true;
        account.Type = GeneralConstants.PARTY_TYPE_BORROWER;
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(account.Type).getRecordTypeId();
        account.Is_Exclude_From_Auto_Renewal_Process__c = false;
        account.Legacy_Active_Contract__c = true;
        update account;

        Exception ex;

        Test.startTest();
        try{
            EISRenewalBatchJob.execute();
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();

         list<Account> updatedAccount = [
            SELECT Id
            FROM Account
            LIMIT 1
        ];

        System.assertEquals(1, updatedAccount.size());
        System.assertEquals(account.id, updatedAccount.get(0).id);
}

    @isTest
    private static void EISRenewalBatchJobCheckBatchSizeException() {

        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.EIS_Renewal_Batch_Size__c = null;
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;
        Exception ex;

        Test.startTest();
            try {
                EISRenewalBatchJob.execute();
            }
            catch(Exception e){
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertException(ex);
        System.assertEquals(ex.getMessage(), 'EIS_Renewal_Batch_Size__c is null');

    }

}