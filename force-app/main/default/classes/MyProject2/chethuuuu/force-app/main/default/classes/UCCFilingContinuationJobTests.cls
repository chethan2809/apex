@isTest
public class UCCFilingContinuationJobTests {
    @TestSetup
    static void makeData(){
        TestUtility.runSetupData();
        Account accountRecord = TestUtility.createAccount();
    }

    @isTest
    private static void UCCFilingContinuationJobTest(){

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Account accountRecord = [
            SELECT Id, UCC_Expiration_Date__c, Is_UCC_Continuation_Eligible__c, UCC_Status__c, Legacy_Active_Contract__c,
            Override_UCC_status__c, Collections_status__c, Number_Of_Days_To_Expire_UCC__c
            FROM Account LIMIT 1
        ];
        Id currentUserId = userinfo.getUserId();

        User userRecord = [
            SELECT Id, UserRoleId, loan__Current_Branch_s_System_Date__c
            FROM User
            WHERE Id = :currentUserId
        ];
        userRecord.loan__Current_Branch_s_System_Date__c = GeneralHelper.currentSystemDate;
        update userRecord;

        accountRecord.UCC_Status__c = GeneralConstants.UCC_STATUS_ACTIVE;
        accountRecord.Legacy_Active_Contract__c = true;
        accountRecord.Override_UCC_status__c = GeneralConstants.OVERRIDE_UCC_STATUS_NONE;
        accountRecord.UCC_Expiration_Date__c = GeneralHelper.currentSystemDate.addDays(-20);
        accountRecord.Collections_status__c = 'Accommodation';
        update accountRecord;

        Exception ex;

        Test.startTest();
        try{
            UCCFilingContinuationJob.execute();
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();

        list<Account> actualAccount = [
            SELECT Id, UCC_Status__c
            FROM Account
            WHERE Id = :accountRecord.Id
        ];

        System.assertEquals(1, actualAccount.size());
    }

    @isTest
        private static void uccFilingContinuationJobCheckBatchSizeException() {

            Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
            originationSettings.UCC_Continuation_Batch_Size__c = null;
            CustomMetaDataHelper.defaultOriginationSetting = originationSettings;

        Exception ex;

        Test.startTest();
        try{
            UCCFilingContinuationJob.execute();
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();

        TestUtility.assertException(ex);
        System.assertEquals(ex.getMessage(), 'UCC_Continuation_Batch_Size__c is null');
    }

    @isTest
    private static void uccFilingContinuationJobCheckCatchBlock() {

        Account accountRecord = [SELECT Id, UCC_Expiration_Date__c, Is_UCC_Continuation_Eligible__c
            FROM Account LIMIT 1
        ];

        UCC_Filing_Detail__c uccFilingDetail = new UCC_Filing_Detail__c();
        uccFilingDetail.Order_Id__c = '123456789';
        uccFilingDetail.Account__c = accountRecord.Id;
        insert uccFilingDetail;

        Exception ex;

        Test.startTest();
        try{
            UCCFilingContinuationJob.execute();
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();
    }
}