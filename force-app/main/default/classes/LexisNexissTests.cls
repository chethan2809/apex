@isTest
private class LexisNexissTests {
    @isTest
    private static void lexisNexisBIIDNamedCredential() {
        String expectedKey = GeneralHelper.getOrgInformation.isSandbox? 'callout:LexisNexisBIID_Sandbox' : 'callout:LexisNexisBIID_Production';

        Test.startTest();
            String lexisNexisBIID = LexisNexiss.lexisNexisBIIDNamedCredential;
        Test.stopTest();

        System.assertEquals(expectedKey, lexisNexisBIID);
    }

    @isTest
    private static void lexisNexisFraudScoreNamedCredential() {
        String expectedKey = GeneralHelper.getOrgInformation.isSandbox? 'callout:LexisNexisSBA_Sandbox' : 'callout:LexisNexisSBA_Production';

        Test.startTest();
            String lexisNexisBIID = LexisNexiss.lexisNexisSMANamedCredential;
        Test.stopTest();

        System.assertEquals(expectedKey, lexisNexisBIID);
    }

    @isTest
    private static void createLexisNexisBIIDCreditReportDetailTypeNonSoleTest() {
        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-0000000002", "Business_Type__c" : "Corporation"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Credit_Report_Detail__c lexisNexisReport = new Credit_Report_Detail__c();
        lexisNexisReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        lexisNexisReport.Application__c = application.Id;

        Account accountDetail = new Account();
        accountDetail.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountDetail.Legacy_Negative_CAN_History__c = false;
        accountDetail.Legal_Name__c = 'FLASH DRONE';

        Set<String> allBeneficialParties = new Set<String>();
        allBeneficialParties.add('STEVE RYAN');

        Map<Id, Credit_Report_Detail__c> existingCreditReportByApplicationId = new Map<Id, Credit_Report_Detail__c>();
        existingCreditReportByApplicationId.put(application.Id, lexisNexisReport);
        Map<String, UnderWriter_Task__c> underWriterTaskByApplicationIdTaskName = new Map<String, UnderWriter_Task__c>();
        UnderWriter_Task__c underWriterProofOfOwnership = new UnderWriter_Task__c();
        underWriterProofOfOwnership.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        UnderWriter_Task__c underWriterLegalName = new UnderWriter_Task__c();
        underWriterLegalName.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        UnderWriter_Task__c underWriterLegalAddress = new UnderWriter_Task__c();
        underWriterLegalAddress.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        UnderWriter_Task__c underWriterPriorCANHistory = new UnderWriter_Task__c();
        underWriterPriorCANHistory.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        UnderWriter_Task__c underWriterBusinessPhone = new UnderWriter_Task__c();
        underWriterBusinessPhone.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        UnderWriter_Task__c underWriterPrimaryGuarantor = new UnderWriter_Task__c();
        underWriterPrimaryGuarantor.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        UnderWriter_Task__c underWriterAdditionalGuarantors = new UnderWriter_Task__c();
        underWriterAdditionalGuarantors.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        UnderWriter_Task__c underWriterBeneficialOwner = new UnderWriter_Task__c();
        underWriterBeneficialOwner.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'Proof of Ownership', underWriterProofOfOwnership);
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'Legal Name', underWriterLegalName);
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'Legal Address', underWriterLegalAddress);
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'Prior CAN History', underWriterPriorCANHistory);
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'Business Phone', underWriterBusinessPhone);
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'STEVE RYAN', underWriterPrimaryGuarantor);
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'Additional Guarantors', underWriterAdditionalGuarantors);
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'Beneficial Owner', underWriterBeneficialOwner);

        Map<String, Object> responseMap = prepareBIIDData('Non Sole');

        Test.startTest();
            LexisNexiss.createLexisNexisBIIDCreditReportDetail(
                responseMap, accountDetail, existingCreditReportByApplicationId, underWriterTaskByApplicationIdTaskName,
                application, allBeneficialParties
            );
        Test.stopTest();

        System.assertEquals('FLASH DRONE', accountDetail.Legal_Name__c);
    }

    @isTest
    private static void createLexisNexisBIIDCreditReportDetailTypeSoleTest() {
        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-0000000002", "Business_Type__c" : "Sole Proprietorship"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Credit_Report_Detail__c lexisNexisReport = new Credit_Report_Detail__c();
        lexisNexisReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());

        Account accountDetail = new Account();
        accountDetail.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountDetail.Legacy_Negative_CAN_History__c = true;
        accountDetail.Legal_Name__c = 'FLASH DRONE';

        Set<String> allBeneficialParties = new Set<String>();
        allBeneficialParties.add('STEVE RYAN');

        Map<Id, Credit_Report_Detail__c> existingCreditReportByApplicationId = new Map<Id, Credit_Report_Detail__c>();
        Map<String, UnderWriter_Task__c> underWriterTaskByApplicationIdTaskName = new Map<String, UnderWriter_Task__c>();
        UnderWriter_Task__c underWriterProofOfOwnership = new UnderWriter_Task__c();
        underWriterProofOfOwnership.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        UnderWriter_Task__c underWriterLegalName = new UnderWriter_Task__c();
        underWriterLegalName.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        UnderWriter_Task__c underWriterLegalAddress = new UnderWriter_Task__c();
        underWriterLegalAddress.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        UnderWriter_Task__c underWriterPriorCANHistory = new UnderWriter_Task__c();
        underWriterPriorCANHistory.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        UnderWriter_Task__c underWriterBusinessPhone = new UnderWriter_Task__c();
        underWriterBusinessPhone.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        UnderWriter_Task__c underWriterPrimaryGuarantor = new UnderWriter_Task__c();
        underWriterPrimaryGuarantor.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        UnderWriter_Task__c underWriterAdditionalGuarantors = new UnderWriter_Task__c();
        underWriterAdditionalGuarantors.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        UnderWriter_Task__c underWriterBeneficialOwner = new UnderWriter_Task__c();
        underWriterBeneficialOwner.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'Proof of Ownership', underWriterProofOfOwnership);
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'Legal Name', underWriterLegalName);
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'Legal Address', underWriterLegalAddress);
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'Prior CAN History', underWriterPriorCANHistory);
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'Business Phone', underWriterBusinessPhone);
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'STEVE RYAN', underWriterPrimaryGuarantor);
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'Additional Guarantors', underWriterAdditionalGuarantors);
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'Beneficial Owner', underWriterBeneficialOwner);

        Map<String, Object> responseMap = prepareBIIDData('Sole');

        Test.startTest();
            LexisNexiss.createLexisNexisBIIDCreditReportDetail(
                responseMap, accountDetail, existingCreditReportByApplicationId, underWriterTaskByApplicationIdTaskName,
                application, allBeneficialParties
            );
        Test.stopTest();

        System.assertEquals('FLASH DRONE', accountDetail.Legal_Name__c);
    }

    @isTest
    private static void createLexisNexisBIIDCreditReportDetailExceptionTest() {
        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-0000000002", "Business_Type__c" : "Sole Proprietorship"}' , genesis__Applications__c.class
        );

        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Credit_Report_Detail__c lexisNexisReport = new Credit_Report_Detail__c();
        lexisNexisReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        lexisNexisReport.Application__c = application.Id;

        Account accountDetail = new Account();
        accountDetail.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountDetail.Legacy_Negative_CAN_History__c = false;
        accountDetail.Legal_Name__c = 'FLASH DRONE';

        Set<String> allBeneficialParties = new Set<String>();
        allBeneficialParties.add('STEVE RYAN');

        Map<Id, Credit_Report_Detail__c> existingCreditReportByApplicationId = new Map<Id, Credit_Report_Detail__c>();
        existingCreditReportByApplicationId.put(application.Id, lexisNexisReport);
        Map<String, UnderWriter_Task__c> underWriterTaskByApplicationIdTaskName = new Map<String, UnderWriter_Task__c>();
        UnderWriter_Task__c underWriterProofOfOwnership = new UnderWriter_Task__c();
        underWriterProofOfOwnership.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        UnderWriter_Task__c underWriterLegalName = new UnderWriter_Task__c();
        underWriterLegalName.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        UnderWriter_Task__c underWriterLegalAddress = new UnderWriter_Task__c();
        underWriterLegalAddress.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        UnderWriter_Task__c underWriterPriorCANHistory = new UnderWriter_Task__c();
        underWriterPriorCANHistory.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        UnderWriter_Task__c underWriterBusinessPhone = new UnderWriter_Task__c();
        underWriterBusinessPhone.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        UnderWriter_Task__c underWriterPrimaryGuarantor = new UnderWriter_Task__c();
        underWriterPrimaryGuarantor.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        UnderWriter_Task__c underWriterAdditionalGuarantors = new UnderWriter_Task__c();
        underWriterAdditionalGuarantors.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        UnderWriter_Task__c underWriterBeneficialOwner = new UnderWriter_Task__c();
        underWriterBeneficialOwner.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'Proof of Ownership', underWriterProofOfOwnership);
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'Legal Name', underWriterLegalName);
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'Legal Address', underWriterLegalAddress);
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'Prior CAN History', underWriterPriorCANHistory);
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'Business Phone', underWriterBusinessPhone);
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'STEVE RYAN', underWriterPrimaryGuarantor);
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'Additional Guarantors', underWriterAdditionalGuarantors);
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'Beneficial Owner', underWriterBeneficialOwner);

        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('Compliance', new Map<String, Object>());

        Test.startTest();
            LexisNexiss.createLexisNexisBIIDCreditReportDetail(
                responseMap, accountDetail, existingCreditReportByApplicationId, underWriterTaskByApplicationIdTaskName,
                application, allBeneficialParties
            );
        Test.stopTest();

        System.assertEquals('FLASH DRONE', accountDetail.Legal_Name__c);
    }

    @isTest
    private static void createLexisNexisFraudScoreCreditReportDetailTest() {
        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-0000000002", "Business_Type__c" : "Corporation"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Credit_Report_Detail__c lexisNexisReport = new Credit_Report_Detail__c();
        lexisNexisReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        lexisNexisReport.Application__c = application.Id;
        lexisNexisReport.SIC_Code__c = '7656';

        Map<Id, Credit_Report_Detail__c> existingCreditReportByApplicationId = new Map<Id, Credit_Report_Detail__c>();
        existingCreditReportByApplicationId.put(application.Id, lexisNexisReport);
        Map<String, UnderWriter_Task__c> underWriterTaskByApplicationIdTaskName = new Map<String, UnderWriter_Task__c>();
        UnderWriter_Task__c underWriterFraudPointScore = new UnderWriter_Task__c();
        underWriterFraudPointScore.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'FraudPoint Score', underWriterFraudPointScore);

        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> scoreMap = new Map<String, Object>();
        List<Object> scoreList = new List<Object>();
        List<Object> scoreDetailsList = new List<Object>();
        Map<String, Object> scoreListMap = new Map<String, Object>();
        Map<String, Object> scoreDetailsMap = new Map<String, Object>();
        scoreMap.put('Value', 782);
        scoreList.add(scoreMap);
        scoreListMap.put('Score', scoreList);
        scoreDetailsMap.put('Scores', scoreListMap);
        scoreDetailsMap.put('Name', 'BBFM1808_1_0');
        scoreDetailsList.add(scoreDetailsMap);

        responseMap.put('FraudModel', scoreDetailsList);

        Test.startTest();
            LexisNexiss.createLexisNexisFraudScoreCreditReportDetail(
                responseMap, existingCreditReportByApplicationId, underWriterTaskByApplicationIdTaskName, application
            );
        Test.stopTest();

        System.assertEquals('7656', lexisNexisReport.SIC_Code__c);
    }

    @isTest
    private static void createLexisNexisFraudCreditReportDetailLessAlertTest() {
        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-0000000002", "Business_Type__c" : "Corporation"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Credit_Report_Detail__c lexisNexisReport = new Credit_Report_Detail__c();
        lexisNexisReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        lexisNexisReport.Application__c = application.Id;
        lexisNexisReport.SIC_Code__c = '7656';

        Map<Id, Credit_Report_Detail__c> existingCreditReportByApplicationId = new Map<Id, Credit_Report_Detail__c>();
        existingCreditReportByApplicationId.put(application.Id, lexisNexisReport);
        Map<String, UnderWriter_Task__c> underWriterTaskByApplicationIdTaskName = new Map<String, UnderWriter_Task__c>();
        UnderWriter_Task__c underWriterFraudPointScore = new UnderWriter_Task__c();
        underWriterFraudPointScore.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'FraudPoint Score', underWriterFraudPointScore);

        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> scoreMap = new Map<String, Object>();
        List<Object> scoreList = new List<Object>();
        List<Object> scoreDetailsList = new List<Object>();
        Map<String, Object> scoreListMap = new Map<String, Object>();
        Map<String, Object> scoreDetailsMap = new Map<String, Object>();
        scoreMap.put('Value', 100);
        scoreList.add(scoreMap);
        scoreListMap.put('Score', scoreList);
        scoreDetailsMap.put('Scores', scoreListMap);
        scoreDetailsMap.put('Name', 'BBFM1808_1_0');
        scoreDetailsList.add(scoreDetailsMap);

        responseMap.put('FraudModel', scoreDetailsList);

        Test.startTest();
            LexisNexiss.createLexisNexisFraudScoreCreditReportDetail(
                responseMap, existingCreditReportByApplicationId, underWriterTaskByApplicationIdTaskName, application
            );
        Test.stopTest();

        System.assertEquals('7656', lexisNexisReport.SIC_Code__c);
    }

    private static Map<String, Object> prepareBIIDData(String type) {
        Map<String, Object> responseMap = new Map<String, Object> ();
        Map<String, Object> businessVerification = new Map<String, Object>();
        businessVerification.put('Index', 50);
        businessVerification.put('Description', 'Input business name, address and phone verified on a business record.');
        responseMap.put('BusinessVerification', businessVerification);

        List<Object> businessToAuthRepIndexes = new List<Object>();
        Map<String, Object> businessToAuthRepIndexMap = new Map<String, Object>();
        businessToAuthRepIndexMap.put('InputRepNumber', 1);
        businessToAuthRepIndexMap.put('Index', 50);
        businessToAuthRepIndexMap.put('Description', 'The input authorized rep\'s first and last name matches the first and last name of a business contact on record.');

        businessToAuthRepIndexes.add(businessToAuthRepIndexMap);
        responseMap.put('BusinessToAuthorizedRepLinkIndex', businessToAuthRepIndexes);

        Map<String, Object> complianceMap = new Map<String, Object>();
        complianceMap.put('SICCode', '7549');
        complianceMap.put('SICDescription', 'AUTOMOTIVE SERVICES, NEC');
        complianceMap.put('NAICSCode', '811191');
        complianceMap.put('NAICSDescription', 'AUTOMOTIVE OIL CHANGE AND LUBRICATION SHOPS');
        complianceMap.put('TimeOnSOS', '0');
        complianceMap.put('SOSStatus', 'UNKNOWN');
        complianceMap.put('LNStatus', 'ACTIVE');
        complianceMap.put('TimeOnPublicRecord', '426');
        complianceMap.put('County', 'COBB');
        complianceMap.put('BusinessFirstSeenYYYY', '1985');
        complianceMap.put('SOS Filing Name', 'FLASH DRONE');

        Map<String, Object> authRepTitle = new Map<String, Object>();
        authRepTitle.put('AuthorizedRep1', 'OWNER');
        complianceMap.put('AuthorizedRepTitles', authRepTitle);

        responseMap.put('Compliance', complianceMap);

        List<Object> authorizedRepresentativeResult = new List<Object>();
        Map<String, Object> authRepDetails = new Map<String, Object>();
        Map<String, Object> authRepName = new Map<String, Object>();
        Map<String, Object> authRepNameDet = new Map<String, Object>();

        authRepName.put('First', 'STEVE');
        authRepName.put('Last', 'RYAN');
        authRepNameDet.put('Name', authRepName);
        authRepNameDet.put('Sequence', 1);

        authRepDetails.put('InputEcho', authRepNameDet);
        authRepDetails.put('SSNFoundForLexID', true);
        authRepDetails.put('DOBMatchLevel', 8);
        authRepDetails.put('NameAddressSSNSummary', type == 'Sole' ? 12 : 11);
        authRepDetails.put('NameAddressPhoneSummary', 6);
        authRepDetails.put('NameAddressPhoneType', 'P');
        authRepDetails.put('ComprehensiveVerificationIndex', 50);
        authRepDetails.put('PhoneOfNameAddress', '2086606744');

        Map<String, Object> riskIndicatorMap = new Map<String, Object>();
        Map<String, Object> riskIndicatorDetails = new Map<String, Object>();
        List<Object> riskIndicatorList = new List<Object>();
        riskIndicatorMap.put('RiskCode', '16');
        riskIndicatorMap.put('Description', 'The input business TIN is associated with a different business name and address');
        riskIndicatorMap.put('Sequence', 1);
        riskIndicatorList.add(riskIndicatorMap);

        riskIndicatorDetails.put('RiskIndicator', riskIndicatorList);
        authRepDetails.put('RiskIndicators', riskIndicatorDetails);
        authorizedRepresentativeResult.add(authRepDetails);
        responseMap.put('AuthorizedRepresentativeResults', authorizedRepresentativeResult);

        Map<String, Object> companyResults = new Map<String, Object>();
        Map<String, Object> verificationIndicators = new Map<String, Object>();
        verificationIndicators.put('CompanyName', '1');
        verificationIndicators.put('StreetAddress', '1');
        verificationIndicators.put('City', '1');
        verificationIndicators.put('State', '1');
        verificationIndicators.put('Zip', '1');
        verificationIndicators.put('Phone', '1');
        verificationIndicators.put('FEIN', '0');
        companyResults.put('VerificationIndicators', verificationIndicators);

        List<Object> companyRiskList = new List<Object>();
        Map<String, Object> companyRiskIndicatorMap = new Map<String, Object>();
        Map<String, Object> companyRiskIndicatorDetails = new Map<String, Object>();

        companyRiskIndicatorMap.put('RiskCode', '18');
        companyRiskIndicatorMap.put('Description', 'Unable to verify business name on business records, but alternate business name found in business records');
        companyRiskIndicatorMap.put('Sequence', 1);
        companyRiskList.add(companyRiskIndicatorMap);
        companyRiskIndicatorDetails.put('RiskIndicator', companyRiskList);
        companyResults.put('RiskIndicators', companyRiskIndicatorDetails);
        companyResults.put('BusinessVerification', businessVerification);
        companyResults.put('BusinessToAuthorizedRepLinkIndexes', responseMap.get('BusinessToAuthorizedRepLinkIndex'));
        responseMap.put('CompanyResults', companyResults);

        return responseMap;
    }
}