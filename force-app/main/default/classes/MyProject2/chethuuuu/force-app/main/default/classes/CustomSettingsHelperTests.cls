@isTest
private class CustomSettingsHelperTests {

    @isTest
    private static void generalSettings() {
        CAN_General_Settings__c canGeneralSettingsInstance = CAN_General_Settings__c.getOrgDefaults();

        Test.startTest();
            CAN_General_Settings__c canGeneralSettings = CustomSettingsHelper.generalSettings;
        Test.stopTest();

        System.assertEquals(canGeneralSettingsInstance, canGeneralSettings);
    }

    @isTest
    private static void congaSettings() {
        CAN_Conga_Settings__c expectedCongaSettings = CAN_Conga_Settings__c.getOrgDefaults();

        Test.startTest();
            CAN_Conga_Settings__c congaSettings = CustomSettingsHelper.congaSettings;
        Test.stopTest();

        System.assertEquals(expectedCongaSettings, congaSettings);
    }

    @isTest
    private static void loanOrgParameters() {
        loan__Org_Parameters__c expectedLoanOrgParameters = loan__Org_Parameters__c.getOrgDefaults();

        Test.startTest();
            loan__Org_Parameters__c loanOrgParameters = CustomSettingsHelper.loanOrgParameters;
        Test.stopTest();

        System.assertEquals(expectedLoanOrgParameters, loanOrgParameters);
    }
}