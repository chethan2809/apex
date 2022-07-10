@isTest
private class CustomMetaDataHelperTests {

    @isTest
    private static void apiDetailsByName() {
        API_Detail__mdt apiDetails = API_Detail__mdt.getInstance('Experian_Business_API_Sandbox');
        String expectedKey = apiDetails.DeveloperName;

        Test.startTest();
            Map<String, API_Detail__mdt> apiDetailsNameMap = CustomMetaDataHelper.apiDetailsByName;
        Test.stopTest();

        System.assertEquals(apiDetails, apiDetailsNameMap.get(expectedKey));
    }

    @isTest
    private static void canCutOffMatrixScoreMap() {
        CAN_Score_Cut_Off_Matrix__mdt canScoreCutOff = CAN_Score_Cut_Off_Matrix__mdt.getInstance('Renewal_TIER1');
        String expectedKey = canScoreCutOff.DeveloperName;

        Test.startTest();
            Map<String, CAN_Score_Cut_Off_Matrix__mdt> canScoreCutOffMap = CustomMetaDataHelper.canCutOffMatrixScoreMap;
        Test.stopTest();

        System.assertEquals(canScoreCutOff, canScoreCutOffMap.get(expectedKey));
    }

    @isTest
    private static void defaultOriginationSetting() {
        Origination_Settings__mdt originationSetting = Origination_Settings__mdt.getInstance('Default');

        Test.startTest();
            Origination_Settings__mdt originationSettings = CustomMetaDataHelper.defaultOriginationSetting;
        Test.stopTest();

        System.assertEquals(originationSetting, originationSettings);
    }

    @isTest
    private static void defaultGeneralSetting() {
        General_Setting__mdt generalSetting = General_Setting__mdt.getInstance('Default');

        Test.startTest();
            General_Setting__mdt generalSettings = CustomMetaDataHelper.defaultGeneralSetting;
        Test.stopTest();

        System.assertEquals(generalSetting, generalSettings);
    }

    @isTest
    private static void defaultExperianReport() {
        Experian_Default_Credit_Report__mdt experianDefaultReport = Experian_Default_Credit_Report__mdt.getInstance('Experian_Default_Credit_Report');

        Test.startTest();
        Experian_Default_Credit_Report__mdt experianDefaultReports = CustomMetaDataHelper.defaultExperianReport;
        Test.stopTest();

        System.assertEquals(experianDefaultReport, experianDefaultReports);
    }

    @isTest
    private static void declineCodeMap() {
        List<AAN_Decline_Code_Mapping__mdt> declineCode = AAN_Decline_Code_Mapping__mdt.getAll().Values();
        String expectedKey = declineCode.get(0).masterLabel;

        Test.startTest();
            Map<String, AAN_Decline_Code_Mapping__mdt> declineCodeMap = CustomMetaDataHelper.declineCodeMap;
        Test.stopTest();

        System.assertEquals(declineCode.get(0), declineCodeMap.get(expectedKey));
    }

    @isTest
    private static void stipsProofOfOwnershipMappingByAuthRep() {
        List<STIPS_Proof_Of_Ownership_Mapping__mdt> proofOfOwnership = STIPS_Proof_Of_Ownership_Mapping__mdt.getAll().Values();
        String expectedKey = proofOfOwnership.get(0).Authorized_Rep_Title__c;

        Test.startTest();
            Map<String, STIPS_Proof_Of_Ownership_Mapping__mdt> proofOfOwnershipMap = CustomMetaDataHelper.stipsProofOfOwnershipMappingByAuthRep;
        Test.stopTest();

        System.assertEquals(proofOfOwnership.get(0), proofOfOwnershipMap.get(expectedKey));
    }

    @isTest
    private static void stipsGuarantorIdentityMappingByRiskCode() {
        List<STIPS_Guarantor_Identity_Mapping__mdt> guarantorIdentity = STIPS_Guarantor_Identity_Mapping__mdt.getAll().Values();
        String expectedKey = guarantorIdentity.get(0).Risk_Code__c;

        Test.startTest();
            Map<String, STIPS_Guarantor_Identity_Mapping__mdt> guarantorIdentityMap = CustomMetaDataHelper.stipsGuarantorIdentityMappingByRiskCode;
        Test.stopTest();

        System.assertEquals(guarantorIdentity.get(0), guarantorIdentityMap.get(expectedKey));
    }

    @isTest
    private static void fincenLegalNameAddressByNameAddressCode() {
        List<Fincen_Legal_Name_Address__mdt> fincenLegalName = Fincen_Legal_Name_Address__mdt.getAll().Values();
        String expectedKey = fincenLegalName.get(0).Name_and_Address_Code__c;

        Test.startTest();
            Map<String, Fincen_Legal_Name_Address__mdt> fincenLegalNameMap = CustomMetaDataHelper.fincenLegalNameAddressByNameAddressCode;
        Test.stopTest();

        System.assertEquals(fincenLegalName.get(0), fincenLegalNameMap.get(expectedKey));
    }

    @isTest
    private static void fincenBusinessPhoneVerificationByPhoneCode() {
        List<Fincen_Legal_Business_Phone__mdt> fincenLegalBusinessPhone = Fincen_Legal_Business_Phone__mdt.getAll().Values();
        String expectedKey = fincenLegalBusinessPhone.get(0).Phone_Code__c;

        Test.startTest();
            Map<String, Fincen_Legal_Business_Phone__mdt> fincenLegalBusinessPhoneMap = CustomMetaDataHelper.fincenBusinessPhoneVerificationByPhoneCode;
        Test.stopTest();

        System.assertEquals(fincenLegalBusinessPhone.get(0), fincenLegalBusinessPhoneMap.get(expectedKey));
    }

    @isTest
    private static void underWriterTaskCategoryMapping() {
        UnderWriter_Task_Category_Mapping__mdt underWriterTask = UnderWriter_Task_Category_Mapping__mdt.getInstance('Bank_Statement_Review');
        String expectedKey = underWriterTask.DeveloperName;

        Test.startTest();
            Map<String, UnderWriter_Task_Category_Mapping__mdt> underWriterTaskMap = CustomMetaDataHelper.underWriterTaskCategoryMapping;
        Test.stopTest();

        System.assertEquals(underWriterTask, underWriterTaskMap.get(expectedKey));
    }

    @isTest
    private static void defaultWasabiSettingSandboxDefault() {

        Test.startTest();
        Wasabi_Setting__mdt wasabiSettings = CustomMetaDataHelper.defaultWasabiSetting;
        Test.stopTest();

        System.assert(wasabiSettings != null);
    }

    @isTest
    private static void webBankCalculationsTierMappingMap() {
        WebBank_Calculations_Tier_Mapping__mdt webBankCalculations = WebBank_Calculations_Tier_Mapping__mdt.getInstance('TIER_1');
        String expectedKey = webBankCalculations.DeveloperName;

        Test.startTest();
            Map<String, WebBank_Calculations_Tier_Mapping__mdt> webBankCalculationsMap = CustomMetaDataHelper.webBankCalculationsTierMappingMap;
        Test.stopTest();

        System.assertEquals(webBankCalculations, webBankCalculationsMap.get(expectedKey));
    }

    @isTest
    private static void stateVsStateCodeMap() {
        State_Name_Vs_State_Code_Mapping__mdt stateNameStateCode = State_Name_Vs_State_Code_Mapping__mdt.getInstance('Kansas');
        String expectedKey = stateNameStateCode.DeveloperName;

        Test.startTest();
            Map<String, State_Name_Vs_State_Code_Mapping__mdt> stateNameStateCodeMap = CustomMetaDataHelper.stateVsStateCodeMap;
        Test.stopTest();

        System.assertEquals(stateNameStateCode, stateNameStateCodeMap.get(expectedKey));
    }

    @isTest
    private static void defaultPortalOwnerMap() {
        Default_Portal_Owner_Mapping__mdt defaultPortalOwner = Default_Portal_Owner_Mapping__mdt.getInstance('Default_Merchant_Portal_Owner');
        String expectedKey = defaultPortalOwner.DeveloperName;

        Test.startTest();
            Map<String, Default_Portal_Owner_Mapping__mdt> defaultPortalOwnerMap = CustomMetaDataHelper.defaultPortalOwnerMap;
        Test.stopTest();

        System.assertEquals(defaultPortalOwner, defaultPortalOwnerMap.get(expectedKey));
    }

    @isTest
    private static void manualRunJobsByJobName() {
        Manual_Run_Jobs__mdt manualRunJobs = Manual_Run_Jobs__mdt.getInstance('AANNotificationJob');
        String expectedKey = manualRunJobs.DeveloperName;

        Test.startTest();
            Map<String, Manual_Run_Jobs__mdt> manualRunJobsMap = CustomMetaDataHelper.manualRunJobsByJobName;
        Test.stopTest();

        System.assertEquals(manualRunJobs, manualRunJobsMap.get(expectedKey));
    }

    @isTest
    private static void defaultOcrolusSetting() {
        Ocrolus_Setting__mdt ocrolusSetting = Ocrolus_Setting__mdt.getInstance('Default');

        Test.startTest();
            Ocrolus_Setting__mdt ocrolusSettings = CustomMetaDataHelper.defaultOcrolusSetting;
        Test.stopTest();

        System.assertEquals(ocrolusSetting, ocrolusSettings);
    }

    @isTest
    private static void returnCodeByActionMapping() {
        ReturnCode_By_Action_Mapping__mdt returnCode = ReturnCode_By_Action_Mapping__mdt.getInstance('R01');
        String expectedKey = returnCode.DeveloperName;

        Test.startTest();
            Map<String, ReturnCode_By_Action_Mapping__mdt> returnCodeMap = CustomMetaDataHelper.returnCodeByActionMapping;
        Test.stopTest();

        System.assertEquals(returnCode, returnCodeMap.get(expectedKey));
    }

    @isTest
    private static void amountByStateIDMapping() {
        StateId_To_Return_Fee_Mapping__mdt returnFee = StateId_To_Return_Fee_Mapping__mdt.getInstance('MT');
        String expectedKey = returnFee.DeveloperName;

        Test.startTest();
            Map<String, StateId_To_Return_Fee_Mapping__mdt> returnFeeMap = CustomMetaDataHelper.amountByStateIDMapping;
        Test.stopTest();

        System.assertEquals(returnFee, returnFeeMap.get(expectedKey));
    }

    @isTest
    private static void defaultEISOcrolusReport() {
        EIS_Default_Ocrolus_Report__mdt defaultOcrolusReport = EIS_Default_Ocrolus_Report__mdt.getInstance('EIS_Default_Ocrolus_Report');
        String expectedKey = defaultOcrolusReport.DeveloperName;

        Test.startTest();
            EIS_Default_Ocrolus_Report__mdt defaultEISOcrolusReport = CustomMetaDataHelper.defaultEISOcrolusReport;
        Test.stopTest();

        System.assertEquals(expectedKey, defaultEISOcrolusReport.DeveloperName);
    }

    @isTest
    private static void reasonCodeMap() {
        List<Credit_Score_Factor_Reason_Mapping__mdt> reasonCode = Credit_Score_Factor_Reason_Mapping__mdt.getAll().Values();
        String expectedKey = reasonCode.get(0).masterLabel;

        Test.startTest();
            Map<String, Credit_Score_Factor_Reason_Mapping__mdt> reasonCodeMap = CustomMetaDataHelper.reasonCodeMap;
        Test.stopTest();

        System.assertEquals(reasonCode.get(0), reasonCodeMap.get(expectedKey));
    }

    @isTest
    private static void defaultSICCodeToIndustryRatingMapping() {
        List<DefaultSICCodeToIndustryRatingMapping__mdt> sicCode = DefaultSICCodeToIndustryRatingMapping__mdt.getAll().Values();
        String expectedKey = sicCode.get(0).masterLabel;

        Test.startTest();
            Map<String, DefaultSICCodeToIndustryRatingMapping__mdt> defaultSICCodeToIndustryRatingMapping = CustomMetaDataHelper.defaultSICCodeToIndustryRatingMapping;
        Test.stopTest();

        System.assertEquals(sicCode.get(0), defaultSICCodeToIndustryRatingMapping.get(expectedKey));
    }
}