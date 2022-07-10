@IsTest
private class CaseManagerTests
{
    @TestSetup
    static void makeData() {
        TestUtility.runSetupData();
        TestUtility.createLegalEntity();
        TestUtility.createDocumentDefinition();

        genesis__Applications__c application = TestUtility.createApplication();
    }

    @IsTest
    private static void createFundingReleaseCaseTests()
    {
        loan__Loan_Product__c loanProduct = new loan__Loan_Product__c();
        loanProduct.Name = 'CAN Capital';
        loanProduct.loan__Default_Number_of_Installments__c = 6;
        loanProduct.loan__Frequency_of_Loan_Payment__c = 'WEEKLY';
        insert loanProduct;

        clcommon__CL_Product__c productCL = new clcommon__CL_Product__c();
        productCL.clcommon__Product_Name__c = GeneralConstants.PRODUCT_NAME_DEFAULT;
        productCL.loan__Lending_Product__c = loanProduct.Id;
        insert productCL;

        genesis__Company__c company = new genesis__Company__c();
        company.Name = 'CAN Capital';
        company.genesis__Short_Name__c = 'CAN';
        insert company;

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        clcommon__Company__c clCompany = new clcommon__Company__c();
        clCompany.clcommon__Company_Name__c = 'CAN Capital';
        clCompany.clcommon__Branch_Date__c = GeneralHelper.currentSystemDate;
        insert clCompany;

        genesis__Applications__c application = [SELECT Id, genesis__Payment_Frequency__c, Annual_Volume__c, Total_Competitors_Amount__c, Sales_Rep__c
            FROM genesis__Applications__c];
        application.genesis__Payment_Frequency__c = 'WEEKLY';
        application.Sales_Rep__c = UserInfo.getUserId();
        application.Total_Competitors_Amount__c = 3333;
        application.Annual_Volume__c = 2444;
        update application;

        Test.startTest();
            CaseManager.createFundingReleaseCase(new Set<Id> {application.Id});
        Test.stopTest();
    }
}