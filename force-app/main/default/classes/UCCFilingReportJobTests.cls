@isTest
private class UCCFilingReportJobTests {
    @TestSetup
    static void makeData(){
        TestUtility.runSetupData();
        Account accountRecord = TestUtility.createAccount();
        Opportunity opportunityRecord = TestUtility.createOpportunity();
        clcommon__CL_Product__c clProduct = TestUtility.createCLProduct();
    }

    @isTest
    private static void uccFilingReportJob() {

        GeneralHelper.currentSystemDate = Date.newInstance(2017, 01, 06);

        Account accountRecord = [
            SELECT Id
            FROM Account
            LIMIT 1
        ];
        accountRecord.UCC_Order_Number__c = '12345';
        update accountRecord;

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Order_Id__c = '123456789';
        uccFiling.Approved__c = true;
        uccFiling.UCC_Reports_Pulled__c = false;
        uccFiling.Order_Status__c = GeneralConstants.UCC_ORDER_STATUS_COMPLETED;
        uccFiling.Account__c = accountRecord.Id;
        insert uccFiling;

        Exception ex;

        System.Test.startTest();
            try {
                UCCFilingReportJob.execute();
            }
            catch(Exception e) {
                ex = e;
            }
        System.Test.stopTest();

        list<UCC_Filing_Detail__c> actualUCCFilingList = [
            SELECT Id, UCC_Reports_Pulled__c
            FROM UCC_Filing_Detail__c
            WHERE Id = :uccFiling.Id
        ];

        System.assertEquals(1, actualUCCFilingList.size());
        System.assertEquals(false, actualUCCFilingList.get(0).UCC_Reports_Pulled__c);
    }

    @isTest
    private static void uccFilingReportJobCheckBatchSizeException() {

        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.UCC_Report_Batch_Size__c = null;
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;
        Exception ex;

        System.Test.startTest();
            try {
                UCCFilingReportJob.execute();
            }
            catch(Exception e) {
                ex = e;
            }
        System.Test.stopTest();

        TestUtility.assertException(ex);
        System.assertEquals(ex.getMessage(), 'UCC_Report_Batch_Size__c is null');

    }
}