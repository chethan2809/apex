public class LexisNexiss {
    public static final String VERIFICATION_TYPE_AUTOMATED = 'AUTOMATED';
    public static final String VERIFICATION_TYPE_MANUAL = 'MANUAL';
    public static final String VERIFICATION_TYPE_FAILED = 'FAILED';
    public static final String VERIFICATION_TYPE_OFAC_WATCHLIST = 'OFAC/WATCHLIST';
    public static final String STATUS_ACTIVE = 'ACTIVE';
    public static final String TASK_TYPE_PROOF_OF_OWNERSHIP = 'Proof of Ownership';
    public static final String TASK_TYPE_FRAUD_POINT_SCORE = 'FraudPoint Score';
    public static final String TASK_TYPE_LEGAL_NAME = 'Legal Name';
    public static final String TASK_TYPE_LEGAL_ADDRESS = 'Legal Address';
    public static final String TASK_TYPE_PRIOR_CAN_HISTORY = 'Prior CAN History';
    public static final String TASK_TYPE_BUSINESS_PHONE = 'Business Phone';
    public static final String PARTY_TYPE_PRIMARY_GUARANTOR = 'Primary Guarantor';
    public static final String PARTY_TYPE_ADDITIONAL_GUARANTORS = 'Additional Guarantors';
    public static final String PARTY_TYPE_BENEFICIAL_OWNER = 'Beneficial Owner';

    public static String lexisNexisBIIDNamedCredential {
        get {
            if(lexisNexisBIIDNamedCredential == null) {
                lexisNexisBIIDNamedCredential = GeneralHelper.getOrgInformation.isSandbox? 'callout:LexisNexisBIID_Sandbox' : 'callout:LexisNexisBIID_Production';
            }
            return lexisNexisBIIDNamedCredential;
        }
        set;
    }

    public static String lexisNexisSMANamedCredential {
        get {
            if(lexisNexisSMANamedCredential == null) {
                lexisNexisSMANamedCredential = GeneralHelper.getOrgInformation.isSandbox? 'callout:LexisNexisSBA_Sandbox' : 'callout:LexisNexisSBA_Production';
            }
            return lexisNexisSMANamedCredential;
        }
        set;
    }

    public static Credit_Report_Detail__c createLexisNexisBIIDCreditReportDetail(
        Map<String, Object> businessInstantIdProfile, Account accountDetail,
        Map<Id, Credit_Report_Detail__c> existingCreditReportByApplicationId,
        Map<String, UnderWriter_Task__c> underWriterTaskByApplicationIdTaskName, genesis__Applications__c application,
        Set<String> allBeneficialParties
    ) {
        Credit_Report_Detail__c creditReport;

        if(validateLexisNexisBID(businessInstantIdProfile)) {
            if(existingCreditReportByApplicationId.containsKey(application.Id)) {
                creditReport = existingCreditReportByApplicationId.get(application.Id);
            } else {
                creditReport = new Credit_Report_Detail__c();
                creditReport.Type__c = GeneralConstants.CREDIT_REPORT_TYPE_LEXIS_NEXIS;
                creditReport.Application__c = application.Id;
            }
        }
        String businessType = application.Business_Type__c;

        setComplianceFields((Map<String, Object>) businessInstantIdProfile.get('Compliance'), creditReport);
        checkIsGuarantorIdentityVerified(
            businessInstantIdProfile, creditReport, underWriterTaskByApplicationIdTaskName, application.Id, allBeneficialParties
        );
        checkIsProofOfOwnershipVerified(businessInstantIdProfile, businessType, creditReport,
            underWriterTaskByApplicationIdTaskName, application.Id
        );
        checkIsLegalNameAndAddressVerified(businessInstantIdProfile, application, underWriterTaskByApplicationIdTaskName, accountDetail);
        checkIsBusinessPhoneVerified(businessInstantIdProfile, application, underWriterTaskByApplicationIdTaskName);
        checkIsPriorCanHistory(underWriterTaskByApplicationIdTaskName, application.Id, accountDetail);

        return creditReport;
    }

    public static Credit_Report_Detail__c createLexisNexisFraudScoreCreditReportDetail(
        Map<String, Object> fraudPointProfile, Map<Id, Credit_Report_Detail__c> existingCreditReportByApplicationId,
        Map<String, UnderWriter_Task__c> underWriterTaskByApplicationIdTaskName, genesis__Applications__c application
    ) {
        Credit_Report_Detail__c creditReport;
        Origination_Settings__mdt defaultFraudAlertSetting = CustomMetaDataHelper.defaultOriginationSetting;

        if(existingCreditReportByApplicationId.containsKey(application.Id)) {
            creditReport = existingCreditReportByApplicationId.get(application.Id);
            setFraudPointScore((Map<String, Object>) fraudPointProfile, creditReport, application.Id);
        }

        UnderWriter_Task__c underWriterTask =
            underWriterTaskByApplicationIdTaskName.get(application.Id + TASK_TYPE_FRAUD_POINT_SCORE);
        if(creditReport != null && creditReport.Fraud_Point_Score__c != null
            && Integer.valueOf(creditReport.Fraud_Point_Score__c) > defaultFraudAlertSetting.Fraud_Point_Score__c
        ) {
            underWriterTask.Verification_Type__c = VERIFICATION_TYPE_AUTOMATED;
            underWriterTask.IsCompleted__c = true;
        } else {
            underWriterTask.Verification_Type__c = VERIFICATION_TYPE_MANUAL;
            underWriterTask.IsCompleted__c = false;
        }

        return creditReport;
    }

    public static void setComplianceFields(Map<String, Object> complianceMap, Credit_Report_Detail__c creditReport) {
        if(!complianceMap.isEmpty() && creditReport != null) {
            creditReport.SIC_Code__c = checkContainsValue(complianceMap, 'SICCode');
            creditReport.Business_First_Seen_YYYY__c = checkContainsValue(complianceMap, 'BusinessFirstSeenYYYY');
        }
    }

    public static void checkIsProofOfOwnershipVerified(
        Map<String, Object> businessInstantIdProfile, String businessType, Credit_Report_Detail__c creditReport,
        Map<String, UnderWriter_Task__c> underWriterTaskByApplicationIdTaskName, Id applicationId
    ) {
        Boolean isVerified = true;
        Set<String> authorizedRepLinkIndexes = new Set<String> {'0', '10', '20', '30'};

        List<Object> businessToAuthorizedRepIndex = checkContainsList(businessInstantIdProfile, 'BusinessToAuthorizedRepLinkIndex');
        Map<String, Object> businessVerificationMap = checkContainsMap(businessInstantIdProfile, 'BusinessVerification');
        Map<String, Object> complianceMap = checkContainsMap(businessInstantIdProfile, 'Compliance');
        Map<String, Object> authorizedRepTitlesMap = checkContainsMap(complianceMap, 'AuthorizedRepTitles');
        String businessVerificationCode = checkContainsValue(businessVerificationMap, 'Index');

        if(creditReport == null) {
            isVerified = false;

        } else {
            if(creditReport.Is_Guarantor_Identity_Verified__c == false) {
                isVerified = false;
            } else {
                String authorizedRepTitle = getReplaceStringWhiteSpaces(authorizedRepTitlesMap, 'AuthorizedRep1');
                String authRepIndex = getAuthorizedRepIndex(businessToAuthorizedRepIndex);

                if(String.isBlank(businessVerificationCode) || authorizedRepLinkIndexes.contains(businessVerificationCode)
                    || String.isBlank(authRepIndex) || authorizedRepLinkIndexes.contains(authRepIndex)
                ) {
                    isVerified = false;
                }

                if(CustomMetaDataHelper.stipsProofOfOwnershipMappingByAuthRep.containsKey(authorizedRepTitle)
                    && !checkIsVerifiedOnRepTitle(CustomMetaDataHelper.stipsProofOfOwnershipMappingByAuthRep.get(authorizedRepTitle), businessType)) {
                        isVerified = false;
                }
            }
            creditReport.Is_Proof_Of_Ownership_Verified__c = isVerified;
            creditReport.Business_Verification_Index__c = Integer.valueOf(businessVerificationCode);
        }

        UnderWriter_Task__c underWriterTask = underWriterTaskByApplicationIdTaskName.get(applicationId + TASK_TYPE_PROOF_OF_OWNERSHIP);
        underWriterTask.Verification_Type__c = (isVerified == true ? VERIFICATION_TYPE_AUTOMATED : VERIFICATION_TYPE_MANUAL);
        underWriterTask.IsCompleted__c = isVerified;
    }

    public static void checkIsGuarantorIdentityVerified(Map<String, Object> businessInstantIdProfile,
        Credit_Report_Detail__c creditReport, Map<String, UnderWriter_Task__c> underWriterTaskByApplicationIdTaskName, Id applicationId,
        Set<String> allBeneficialParties
    ) {
        Boolean isVerified = false;
        List<UnderWriter_Task__c> underWriterTaskList = new List<UnderWriter_Task__c>();
        List<String> notVerifiedGuarantors = new List<String>();
        List<Object> authorizedRepresentativeValues = checkContainsList(businessInstantIdProfile, 'AuthorizedRepresentativeResults');
        for (Object authRepObj : authorizedRepresentativeValues) {
            Map<String, Object> authRepMap = (Map<String, Object>) authRepObj;
            Map<String, Object> repNameMap = (Map<String, Object>) ((Map<String, Object>) authRepMap.get('InputEcho')).get('Name');
            String taskName = String.valueOf(applicationId) + String.valueOf(repNameMap.get('First')).toUpperCase() +
                ' ' + String.valueOf(repNameMap.get('Last')).toUpperCase();
            UnderWriter_Task__c underWriterTask = underWriterTaskByApplicationIdTaskName.get(taskName);
            if(!checkComprehensiveVerification(authRepMap) || !checkRiskIndicatorValues(authRepMap)) {
                notVerifiedGuarantors.add(repNameMap.get('First') + ' ' + repNameMap.get('Last'));
                if(underWriterTask != null) {
                    underWriterTask.Verification_Type__c = VERIFICATION_TYPE_MANUAL;
                    underWriterTask.IsCompleted__c = false;
                }
            } else {
                if(underWriterTask != null) {
                    underWriterTask.Verification_Type__c = VERIFICATION_TYPE_AUTOMATED;
                    underWriterTask.IsCompleted__c = true;
                }
            }
        }

        if(creditReport != null) {
            if(!authorizedRepresentativeValues.isEmpty() && notVerifiedGuarantors.isEmpty()) {
                creditReport.Is_Guarantor_Identity_Verified__c = true;
            } else {
                creditReport.Is_Guarantor_Identity_Verified__c = isVerified;
                creditReport.Guarantors_Whose_Identity_Not_Verified__c =
                    notVerifiedGuarantors.isEmpty() ? null : String.join(notVerifiedGuarantors, ', ');
            }
        } else {
            for (String contactName : allBeneficialParties) {
                String taskName = String.valueOf(applicationId) + contactName;
                UnderWriter_Task__c underWriterTask = underWriterTaskByApplicationIdTaskName.get(taskName);
                if(underWriterTask != null) {
                    underWriterTask.Verification_Type__c = VERIFICATION_TYPE_MANUAL;
                    underWriterTask.IsCompleted__c = false;
                }
            }
        }
    }

    public static void setFraudPointScore(Map<String, Object> fraudPointModel, Credit_Report_Detail__c creditReport, Id applicationId) {
        List<Object> modelList = checkContainsList(fraudPointModel, 'FraudModel');
        List<Object> scoreList;

        if(modelList != null) {
            for (Object modelDetail : modelList) {
                Map<String, Object> modelDetailMap = (Map<String, Object>) modelDetail;
                Map<String, Object> scoresMap = (Map<String, Object>) modelDetailMap.get('Scores');
                scoreList = (List<Object>) scoresMap.get('Score');

                for (Object scoreDetail : scoreList) {
                    Map<String, Object> scoreDetailMap = (Map<String, Object>) scoreDetail;
                    creditReport.Fraud_Point_Score__c = String.valueOf(scoreDetailMap.get('Value'));
                }
            }
        }
    }

    public static void checkIsLegalNameAndAddressVerified(Map<String, Object> businessInstantIdProfile,
        genesis__Applications__c application, Map<String, UnderWriter_Task__c> underWriterTaskByApplicationIdTaskName, Account accountDetail
    ) {
        Map<String, Object> businessVerificationMap = checkContainsMap(businessInstantIdProfile, 'BusinessVerification');

        String businessVerificationCode = checkContainsValue(businessVerificationMap, 'Index');
        String verificationType = '';

        UnderWriter_Task__c underWriterLegalName = underWriterTaskByApplicationIdTaskName.get(application.Id + TASK_TYPE_LEGAL_NAME);
        UnderWriter_Task__c underWriterLegalAddress = underWriterTaskByApplicationIdTaskName.get(application.Id + TASK_TYPE_LEGAL_ADDRESS);

        Map<String, Object> companyMap = checkContainsMap(businessInstantIdProfile, 'CompanyResults');
        Map<String, Object> companyRiskIndicator = checkContainsMap(companyMap, 'RiskIndicators');
        List<Object> companyRiskIndicatorList = checkContainsList(companyRiskIndicator, 'RiskIndicator');
        Map<String, Object> verificationIndicatorMap = checkContainsMap(businessVerificationMap, 'VerificationIndicators');
        Set<String> companyRiskIndicatorValues = getCompanyRiskIndicatorValues(companyRiskIndicatorList);
        Map<String, Object> complianceMap = checkContainsMap(businessInstantIdProfile, 'Compliance');

        if(companyMap.isEmpty() && companyRiskIndicator.isEmpty() && verificationIndicatorMap.isEmpty() && complianceMap.isEmpty()) {
            verificationType = VERIFICATION_TYPE_MANUAL;

        } else {
            verificationType = VERIFICATION_TYPE_AUTOMATED;
            Set<String> authorizedRepLinkIndexes = new Set<String> {'0', '10', '20', '30'};
            List<UnderWriter_Task__c> underWriterList = new List<UnderWriter_Task__c>();


            if(String.isBlank(businessVerificationCode) || authorizedRepLinkIndexes.contains(businessVerificationCode)) {
                verificationType = VERIFICATION_TYPE_MANUAL;

            } else if(application.Business_Type__c == GeneralConstants.LEGAL_TYPE_SOLE_PROP) {
                verificationType =
                    checkVerificationIndicators(
                        businessVerificationCode, complianceMap, verificationIndicatorMap, companyRiskIndicatorValues, 'sole', accountDetail);

            } else {
                verificationType =
                    checkVerificationIndicators(
                        businessVerificationCode, complianceMap, verificationIndicatorMap,companyRiskIndicatorValues, 'others', accountDetail);
            }
        }
        underWriterLegalName.Verification_Type__c = verificationType;
        underWriterLegalName.IsCompleted__c = (verificationType == VERIFICATION_TYPE_AUTOMATED);
        underWriterLegalAddress.Verification_Type__c = verificationType;
        underWriterLegalAddress.IsCompleted__c = (verificationType == VERIFICATION_TYPE_AUTOMATED);
    }

    public static void checkIsBusinessPhoneVerified(Map<String, Object> businessInstantIdProfile,
        genesis__Applications__c application, Map<String, UnderWriter_Task__c> underWriterTaskByApplicationIdTaskName
    ) {
        Map<String, Object> companyMap = checkContainsMap(businessInstantIdProfile, 'CompanyResults');
        Map<String, Object> companyRiskIndicator = checkContainsMap(companyMap, 'RiskIndicators');
        List<Object> companyRiskIndicatorList = checkContainsList(companyRiskIndicator, 'RiskIndicator');
        String verificationType = VERIFICATION_TYPE_MANUAL;
        UnderWriter_Task__c underWriterTask = underWriterTaskByApplicationIdTaskName.get(application.Id + TASK_TYPE_BUSINESS_PHONE);

        if(underWriterTaskByApplicationIdTaskName.get(application.Id + TASK_TYPE_LEGAL_NAME).Verification_Type__c ==
            VERIFICATION_TYPE_AUTOMATED
        ) {
            for (Object riskCodeObj : companyRiskIndicatorList) {
                Map<String, Object> riskCodeMap = (Map<String, Object>) riskCodeObj;
                String riskCode = String.valueOf(riskCodeMap.get('RiskCode'));

                if(CustomMetaDataHelper.fincenBusinessPhoneVerificationByPhoneCode.containsKey(riskCode)) {
                    verificationType = CustomMetaDataHelper.fincenBusinessPhoneVerificationByPhoneCode.get(riskCode).Verification_Type__c;
                }
            }
        } else {
            verificationType = VERIFICATION_TYPE_MANUAL;
        }
        underWriterTask.Verification_Type__c = verificationType;
        underWriterTask.IsCompleted__c = (verificationType == VERIFICATION_TYPE_AUTOMATED);
    }

    public static void checkIsPriorCanHistory(
        Map<String, UnderWriter_Task__c> underWriterTaskByApplicationIdTaskName, Id applicationId, Account accountDetail
    ) {
        UnderWriter_Task__c underWriterTask = underWriterTaskByApplicationIdTaskName.get(applicationId + TASK_TYPE_PRIOR_CAN_HISTORY);
        if(accountDetail.Legacy_Negative_CAN_History__c) {
            underWriterTask.Verification_Type__c = VERIFICATION_TYPE_MANUAL;
            underWriterTask.IsCompleted__c = false;
        } else {
            underWriterTask.Verification_Type__c = VERIFICATION_TYPE_AUTOMATED;
            underWriterTask.IsCompleted__c = true;
        }
    }

    public static String getAuthorizedRepIndex(List<Object> businessToAuthorizedRepIndex) {
        for (Object authRepIndexObj : businessToAuthorizedRepIndex) {
            Map<String, Object> authRepIndexMap = (Map<String, Object>) authRepIndexObj;
            if(authRepIndexMap.get('InputRepNumber') == '1') {
                return String.valueOf(authRepIndexMap.get('Index'));
            }
        }
        return null;
    }

    public static Boolean checkComprehensiveVerification(Map<String, Object> authRepMap) {
        if(!authRepMap.containsKey('ComprehensiveVerificationIndex') || !authRepMap.containsKey('NameAddressSSNSummary')) {
            return false;
        }

        if((String.valueOf(authRepMap.get('ComprehensiveVerificationIndex')) == '40'
                || String.valueOf(authRepMap.get('ComprehensiveVerificationIndex')) == '50'
            )
            && String.valueOf(authRepMap.get('NameAddressSSNSummary')) == '12'
        ) {
            return true;
        }
        return false;
    }

    public static Boolean checkRiskIndicatorValues(Map<String, Object> authRepMap) {
        Map<String, Object> riskIndicatorMap = checkContainsMap(authRepMap, 'RiskIndicators');
        List<Object> riskIndicatorValues = checkContainsList(riskIndicatorMap, 'RiskIndicator');
        for (Object riskCodeObj : riskIndicatorValues) {
            Map<String, Object> riskCodeMap = (Map<String, Object>) riskCodeObj;
            String riskCode = String.valueOf(riskCodeMap.get('RiskCode'));

            if(CustomMetaDataHelper.stipsGuarantorIdentityMappingByRiskCode.containsKey(riskCode)
                && !CustomMetaDataHelper.stipsGuarantorIdentityMappingByRiskCode.get(riskCode).Is_Verified__c
            ) {
                return false;
            }
        }

        return true;
    }

    public static Boolean checkIsVerifiedOnRepTitle(STIPS_Proof_Of_Ownership_Mapping__mdt proofOfOwnershipRepTitle, String businessType) {
        if(businessType == GeneralConstants.LEGAL_TYPE_CORPORATION) {
            return proofOfOwnershipRepTitle.Corporation__c;
        } else if(businessType == GeneralConstants.LEGAL_TYPE_LLC) {
            return proofOfOwnershipRepTitle.LLC__c;
        }
        else if(businessType == GeneralConstants.LEGAL_TYPE_LLP) {
            return proofOfOwnershipRepTitle.LLP__c;
        }
        else if(businessType == GeneralConstants.LEGAL_TYPE_PARTNERSHIP) {
            return proofOfOwnershipRepTitle.Partnership__c;
        }
        else if(businessType == GeneralConstants.LEGAL_TYPE_LIMITED_PARTNERSHIP) {
            return proofOfOwnershipRepTitle.Limited_Partnership__c;
        }
        else if(businessType == GeneralConstants.LEGAL_TYPE_SOLE_PROP) {
            return proofOfOwnershipRepTitle.Sole_Proprietorship__c;
        }
        else if(businessType == GeneralConstants.LEGAL_TYPE_OTHERS) {
            return proofOfOwnershipRepTitle.Other__c;
        }
        return false;
    }

    public static Set<String> getCompanyRiskIndicatorValues(List<Object> riskIndicatorList) {
        Set<String> riskIndicatorInCompany = new Set<String>();
        for (Object riskIndicatorObj : riskIndicatorList) {
            Map<String, Object> riskIndicatorMap = (Map<String, Object>) riskIndicatorObj;
            riskIndicatorInCompany.add(String.valueOf(riskIndicatorMap.get('RiskCode')));
        }
        return riskIndicatorInCompany;
    }

    public static String checkVerificationIndicators(
        String businessVerificationCode, Map<String, Object> complianceMap, Map<String, Object> verificationIndicatorMap,
        Set<String> companyRiskIndicatorValues, String type, Account accountDetail
    ) {
        if(type == 'sole') {
            if((businessVerificationCode == '40' || businessVerificationCode == '50')
                && (String.valueOf(verificationIndicatorMap.get('CompanyName')) == '1'
                && String.valueOf(verificationIndicatorMap.get('StreetAddress')) == '1'
                || String.valueOf(verificationIndicatorMap.get('City')) == '1' || String.valueOf(verificationIndicatorMap.get('State')) == '1'
                || String.valueOf(verificationIndicatorMap.get('Zip')) == '1')
            ) {
                return getBusinessLegalNameVerified(companyRiskIndicatorValues);
            }
        } else {
            if((businessVerificationCode == '40' || businessVerificationCode == '50')
                && complianceMap.get('SOS Filing Name') != null
                && accountDetail.Legal_Name__c == String.valueOf(complianceMap.get('SOS Filing Name'))
                && (String.valueOf(verificationIndicatorMap.get('StreetAddress')) == '1' || String.valueOf(verificationIndicatorMap.get('City')) == '1'
                || String.valueOf(verificationIndicatorMap.get('State')) == '1' || String.valueOf(verificationIndicatorMap.get('Zip')) == '1')
            ) {
                return getBusinessLegalNameVerified(companyRiskIndicatorValues);
            }
        }
        return VERIFICATION_TYPE_MANUAL;
    }

    public static String getBusinessLegalNameVerified(Set<String> companyRiskIndicatorValues) {
        for (String riskCode : companyRiskIndicatorValues) {
            if(CustomMetaDataHelper.fincenLegalNameAddressByNameAddressCode.containsKey(riskCode)) {
                return CustomMetaDataHelper.fincenLegalNameAddressByNameAddressCode.get(riskCode).Verification_Type__c;
            }
        }
        return VERIFICATION_TYPE_MANUAL;
    }

    public static String checkContainsValue(Map<String, Object> valueMap, String key) {
        if(valueMap != null && valueMap.containsKey(key) && valueMap.get(key) != null) {
            return String.valueOf(valueMap.get(key));
        } else {
            return null;
        }
    }

    public static Map<String, Object> checkContainsMap(Map<String, Object> valueMap, String key) {
        if(valueMap != null && valueMap.containsKey(key) && valueMap.get(key) != null) {
            return (Map<String, Object>) valueMap.get(key);
        } else {
            return new Map<String, Object>();
        }
    }

    public static List<Object> checkContainsList(Map<String, Object> valueMap, String key) {
        if(valueMap != null && valueMap.containsKey(key) && valueMap.get(key) != null) {
            return (List<Object>) valueMap.get(key);
        } else {
            return new List<Object>();
        }
    }

    private static String getReplaceStringWhiteSpaces(Map<String, Object> valueMap, String key) {
        if(valueMap != null && valueMap.containsKey(key) && valueMap.get(key) != null) {
              return String.valueOf(valueMap.get(key)).replaceAll('\\s+', ' ');
        } else {
            return null;
        }
    }

    public static Boolean validateLexisNexisBID(Map<String, Object> lexisNexisResponse) {
        if((!lexisNexisResponse.containsKey('AuthorizedRepresentativeResults') || lexisNexisResponse.get('AuthorizedRepresentativeResults') == null)
            && (!lexisNexisResponse.containsKey('BusinessToAuthorizedRepLinkIndex') || lexisNexisResponse.get('BusinessToAuthorizedRepLinkIndex') == null)
            && (!lexisNexisResponse.containsKey('BusinessVerification') || lexisNexisResponse.get('BusinessVerification') == null)
        ) {
            return false;
        }
        return true;
    }

    private class LexisNexissException extends Exception {}
}