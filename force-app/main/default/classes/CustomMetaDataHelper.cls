public class CustomMetaDataHelper {

    public static Map<String, API_Detail__mdt> apiDetailsByName {
        get {
            if(apiDetailsByName == null) {
                apiDetailsByName = API_Detail__mdt.getAll();
            }
            return apiDetailsByName;
        }
        set;
    }

    public static Map<String, CAN_Score_Cut_Off_Matrix__mdt> canCutOffMatrixScoreMap {
        get {
            if(canCutOffMatrixScoreMap == null) {
                canCutOffMatrixScoreMap = CAN_Score_Cut_Off_Matrix__mdt.getAll();
            }
            return canCutOffMatrixScoreMap;
        }
        set;
    }

    public static Map<String, can_max_pricing_matrix_by_term__mdt> canMaxPricingMatrixByTermMap {
        get {
            if(canMaxPricingMatrixByTermMap == null) {
                canMaxPricingMatrixByTermMap = can_max_pricing_matrix_by_term__mdt.getAll();
            }
            return canMaxPricingMatrixByTermMap;
        }
        set;
    }

    public static Origination_Settings__mdt defaultOriginationSetting  {
        get {
            if(defaultOriginationSetting == null) {
                Map<String, Origination_Settings__mdt> defaultMap = Origination_Settings__mdt.getAll();

                if(defaultMap.isEmpty()) {
                    throw new CustomMetaDataHelperException('There was no Default Origination Setting found');
                }
                defaultOriginationSetting = defaultMap.get('Default');
            }
            return defaultOriginationSetting;
        }
        set;
    }

    public static General_Setting__mdt defaultGeneralSetting{
        get {
            if (defaultGeneralSetting == null) {
                Map<String, General_Setting__mdt> defaultMap = General_Setting__mdt.getAll();

                if(defaultMap.isEmpty()) {
                    throw new CustomMetaDataHelperException('There was no Default General Setting found');
                }
                defaultGeneralSetting = defaultMap.get('Default');
            }
            return defaultGeneralSetting;
        }
        set;
    }

    public static Experian_Default_Credit_Report__mdt defaultExperianReport{
        get {
            if (defaultExperianReport == null) {
                String defaultReportName = 'Experian_Default_Credit_Report';
                Map<String, Experian_Default_Credit_Report__mdt> defaultMap = Experian_Default_Credit_Report__mdt.getAll();
                if(defaultMap.isEmpty() || !defaultMap.containsKey(defaultReportName)) {
                    throw new CustomMetaDataHelperException('There was no Experian Default Credit Report found');
                }
                defaultExperianReport = defaultMap.get(defaultReportName);
            }
            return defaultExperianReport;
        }
        set;
    }

    public static Map<String, AAN_Decline_Code_Mapping__mdt> declineCodeMap {
        get {
            if(declineCodeMap == null) {
                declineCodeMap = new Map<String, AAN_Decline_Code_Mapping__mdt>();
                for(AAN_Decline_Code_Mapping__mdt declineMetadata : AAN_Decline_Code_Mapping__mdt.getAll().values()) {
                    declineCodeMap.put(declineMetadata.masterLabel, declineMetadata);
                }
            }
            return declineCodeMap;
        }
        set;
    }

    public static Map<String, Credit_Score_Factor_Reason_Mapping__mdt> reasonCodeMap {
        get {
            if(reasonCodeMap == null) {
                reasonCodeMap = new Map<String, Credit_Score_Factor_Reason_Mapping__mdt>();
                for(Credit_Score_Factor_Reason_Mapping__mdt reasonCodeMetadata : Credit_Score_Factor_Reason_Mapping__mdt.getAll().values()) {
                    reasonCodeMap.put(reasonCodeMetadata.masterLabel, reasonCodeMetadata);
                }
            }
            return reasonCodeMap;
        }
        set;
    }

    public static Map<String, STIPS_Proof_Of_Ownership_Mapping__mdt> stipsProofOfOwnershipMappingByAuthRep {
        get {
            if(stipsProofOfOwnershipMappingByAuthRep == null) {
                stipsProofOfOwnershipMappingByAuthRep = new Map<String, STIPS_Proof_Of_Ownership_Mapping__mdt>();
                for(STIPS_Proof_Of_Ownership_Mapping__mdt stipsMetadata : STIPS_Proof_Of_Ownership_Mapping__mdt.getAll().values()) {
                    stipsProofOfOwnershipMappingByAuthRep.put(stipsMetadata.Authorized_Rep_Title__c, stipsMetadata);
                }
            }
            return stipsProofOfOwnershipMappingByAuthRep;
        }
        set;
    }

    public static Map<String, STIPS_Guarantor_Identity_Mapping__mdt> stipsGuarantorIdentityMappingByRiskCode {
        get {
            if(stipsGuarantorIdentityMappingByRiskCode == null) {
                stipsGuarantorIdentityMappingByRiskCode = new Map<String, STIPS_Guarantor_Identity_Mapping__mdt>();
                for(STIPS_Guarantor_Identity_Mapping__mdt stipsMetadata : STIPS_Guarantor_Identity_Mapping__mdt.getAll().values()) {
                    stipsGuarantorIdentityMappingByRiskCode.put(stipsMetadata.Risk_Code__c, stipsMetadata);
                }
            }
            return stipsGuarantorIdentityMappingByRiskCode;
        }
        set;
    }

    public static Map<String, Fincen_Legal_Name_Address__mdt> fincenLegalNameAddressByNameAddressCode {
        get {
            if(fincenLegalNameAddressByNameAddressCode == null) {
                fincenLegalNameAddressByNameAddressCode = new Map<String, Fincen_Legal_Name_Address__mdt>();
                for(Fincen_Legal_Name_Address__mdt fincenLegalName : Fincen_Legal_Name_Address__mdt.getAll().values()) {
                    fincenLegalNameAddressByNameAddressCode.put(fincenLegalName.Name_and_Address_Code__c, fincenLegalName);
                }
            }
            return fincenLegalNameAddressByNameAddressCode;
        }
        set;
    }

    public static Map<String, Fincen_Legal_Business_Phone__mdt> fincenBusinessPhoneVerificationByPhoneCode {
        get {
            if(fincenBusinessPhoneVerificationByPhoneCode == null) {
                fincenBusinessPhoneVerificationByPhoneCode = new Map<String, Fincen_Legal_Business_Phone__mdt>();
                for(Fincen_Legal_Business_Phone__mdt phoneVerification : Fincen_Legal_Business_Phone__mdt.getAll().values()) {
                    fincenBusinessPhoneVerificationByPhoneCode.put(phoneVerification.Phone_Code__c, phoneVerification);
                }
            }
            return fincenBusinessPhoneVerificationByPhoneCode;
        }
        set;
    }

    public static Map<String, UnderWriter_Task_Category_Mapping__mdt> underWriterTaskCategoryMapping {
        get {
            if(underWriterTaskCategoryMapping == null) {
                underWriterTaskCategoryMapping = UnderWriter_Task_Category_Mapping__mdt.getAll();
            }
            return underWriterTaskCategoryMapping;
        }
        set;
    }

    public static Wasabi_Setting__mdt defaultWasabiSetting {
        get {
            if(defaultWasabiSetting == null) {
                Map<String, Wasabi_Setting__mdt> defaultMap = Wasabi_Setting__mdt.getAll();

                if(defaultMap.isEmpty()) {
                    throw new CustomMetaDataHelperException('There was no Default Wasabi Setting found');
                }
                if(GeneralHelper.getOrgInformation.isSandbox) {
                    defaultWasabiSetting = defaultMap.get('Sandbox_Default');
                } else {
                    defaultWasabiSetting = defaultMap.get('Production_Default');
                }
            }
            return defaultWasabiSetting;
        }
        set;
    }

    public static Map<String, WebBank_Calculations_Tier_Mapping__mdt> webBankCalculationsTierMappingMap {
        get {
            if(webBankCalculationsTierMappingMap == null) {
                webBankCalculationsTierMappingMap = WebBank_Calculations_Tier_Mapping__mdt.getAll();
            }
            return webBankCalculationsTierMappingMap;
        }
        set;
    }

    public static Map<String, State_Name_Vs_State_Code_Mapping__mdt> stateVsStateCodeMap {
        get {
            if(stateVsStateCodeMap == null) {
                stateVsStateCodeMap = State_Name_Vs_State_Code_Mapping__mdt.getAll();
            }
            return stateVsStateCodeMap;
        }
        set;
    }

    public static Map<String, Default_Portal_Owner_Mapping__mdt> defaultPortalOwnerMap {
        get {
            if(defaultPortalOwnerMap == null) {
                defaultPortalOwnerMap = Default_Portal_Owner_Mapping__mdt.getAll();
            }
            return defaultPortalOwnerMap;
        }
        set;
    }

    public static Map<String, Manual_Run_Jobs__mdt> manualRunJobsByJobName {
        get {
            if(manualRunJobsByJobName == null) {
                manualRunJobsByJobName = Manual_Run_Jobs__mdt.getAll();
            }
            return manualRunJobsByJobName;
        }
        set;
    }

    public static Ocrolus_Setting__mdt defaultOcrolusSetting {
        get {
            if(defaultOcrolusSetting == null) {
                Map<String, Ocrolus_Setting__mdt> defaultMap = Ocrolus_Setting__mdt.getAll();

                if(defaultMap.isEmpty()) {
                    throw new CustomMetaDataHelperException('There was no Default Ocrolus Setting found');
                }
                defaultOcrolusSetting = defaultMap.get('Default');
            }
            return defaultOcrolusSetting;
        }
        set;
    }

    public static Map<String, ReturnCode_By_Action_Mapping__mdt> returnCodeByActionMapping {
        get {
            if(returnCodeByActionMapping == null) {
                returnCodeByActionMapping = ReturnCode_By_Action_Mapping__mdt.getAll();
            }
            return returnCodeByActionMapping;
        }
        set;
    }

    public static Map<String, StateId_To_Return_Fee_Mapping__mdt> amountByStateIDMapping {
        get {
            if(amountByStateIDMapping == null) {
                amountByStateIDMapping = StateId_To_Return_Fee_Mapping__mdt.getAll();
            }
            return amountByStateIDMapping;
        }
        set;
    }

    public static EIS_Default_Ocrolus_Report__mdt defaultEISOcrolusReport{
        get {
            if (defaultEISOcrolusReport == null) {
                String defaultReportName = 'EIS_Default_Ocrolus_Report';
                Map<String, EIS_Default_Ocrolus_Report__mdt> defaultMap = EIS_Default_Ocrolus_Report__mdt.getAll();
                if(defaultMap.isEmpty() || !defaultMap.containsKey(defaultReportName)) {
                    throw new CustomMetaDataHelperException('There was no EIS Ocrolus Default Report found');
                }
                defaultEISOcrolusReport = defaultMap.get(defaultReportName);
            }
            return defaultEISOcrolusReport;
        }
        set;
    }

    public static UCC_Setting__mdt defaultuccSetting {
        get {
            UCC_Setting__mdt uccSetting;
            if(defaultuccSetting == null) {
                uccSetting = [SELECT Id, DeveloperName, Filer_Contact_Fax__c,
                            Filer_Contact_Name__c, Filer_Contact_Phone__c, Filer_Mail_Address__c, Filer_Organization_Name__c,
                            Filer_PostalCode__c, Filer_State__c, Secured_City__c, Secured_Country__c, Secured_MailAddress__c,
                            Secured_Organization_Name__c, Secured_postalCode__c, Secured_State__c, Florida_Collateral_Text__c,
                            NJ_Collateral_Text__c, Non_NJ_Collateral_Text__c, Filer_City__c
                            FROM UCC_Setting__mdt where DeveloperName = 'Default'];

                if(uccSetting == null) {
                    throw new CustomMetaDataHelperException('There was no Default UCC Setting found');
                }
            }
            return uccSetting;
        }
        set;
    }

    public static Map<String, JurisdictionID_To_Name_Mapping__mdt> jurisdictionIDToNameMapping {
        get {
            if(jurisdictionIDToNameMapping == null) {
                jurisdictionIDToNameMapping = JurisdictionID_To_Name_Mapping__mdt.getAll();
            }
            return jurisdictionIDToNameMapping;
        }
        set;
    }

    public static Map<String, Compumail_Template_ID_mapping__mdt> compuMailTemplateIDMapping {
        get {
            if(compuMailTemplateIDMapping == null) {
                compuMailTemplateIDMapping = Compumail_Template_ID_mapping__mdt.getAll();
            }
            return compuMailTemplateIDMapping;
        }
        set;
    }

    private class CustomMetaDataHelperException extends Exception {}
}