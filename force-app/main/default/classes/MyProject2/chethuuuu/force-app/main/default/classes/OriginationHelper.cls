public class OriginationHelper {

    @TestVisible
    private static CLProductDB clProductDBInstance = new CLProductDB();
    @TestVisible
    private static CLCompanyDB clCompanyDBInstance = new CLCompanyDB();
    @TestVisible
    private static CompanyDB companyDBInstance = new CompanyDB();
    @TestVisible
    private static PartyTypeDB partyTypeDBInstance = new PartyTypeDB();
    @TestVisible
    private static LegalEntityDB legalEntityDBInstance = new LegalEntityDB();
    @TestVisible
    private static DocumentDefinitionDB documentDefinitionDBInstance = new DocumentDefinitionDB();
    @TestVisible
    private static MaxAmountAndMaxTermMappingDB maxAmountAndMaxTermMappingDBInstance = new MaxAmountAndMaxTermMappingDB();
    @TestVisible
    private static PricingMatrixDetailDB pricingMatrixDetailDBInstance = new PricingMatrixDetailDB();
    @TestVisible
    private static GAVMatrixDetailDB gavMatrixDetailDBInstance = new GAVMatrixDetailDB();
    @TestVisible
    private static IndustryRatingProfileDB industryRatingProfileDBInstance = new IndustryRatingProfileDB();
    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();
    @TestVisible
    static CANMinAndMaxPricingDetailDB minAndMaxPricingDBInstance = new CANMinAndMaxPricingDetailDB();


    public static clcommon__CL_Product__c clProduct {
        get {
            if(clProduct == null) {
                List<clcommon__CL_Product__c> clProducts = clProductDBInstance.getAllProducts();
                if(clProducts.isEmpty()) {
                    throw new OriginationHelperException('There was no CL product exist in the system');
                } else {
                    clProduct = clProducts.get(0);
                }
            }
            return clProduct;
        }
        set;
    }

    public static clcommon__Company__c clCompany {
        get {
            if(clCompany == null) {
                List<clcommon__Company__c> clCompanies = clCompanyDBInstance.getCLCompanies();
                if(clCompanies.isEmpty()) {
                    throw new OriginationHelperException('There was no CL Company exist in the system');
                } else {
                    clCompany = clCompanies.get(0);
                }
            }
            return clCompany;
        }
        set;
    }

    public static genesis__Company__c company {
        get {
            if(company == null) {
                List<genesis__Company__c> companies = companyDBInstance.getCompanies();
                if(companies.isEmpty()) {
                    throw new OriginationHelperException('There was no Origination Company exist in the system');
                } else {
                    company = companies.get(0);
                }
            }
            return company;
        }
        set;
    }

    public static Map<String, Id> partyTypeToId {
        get {
            if(partyTypeToId == null) {
                partyTypeToId = new Map<String, Id>();
                for(clcommon__Party_Type__c partyType : partyTypeDBInstance.getAllPartyTypes()) {
                    partyTypeToId.put(partyType.Name, partyType.Id);
                }
            }
            return partyTypeToId;
        }
        set;
    }

    public static List<clcommon__Document_Definition__c> documentDefinitionList {
        get {
            if(documentDefinitionList == null) {
                documentDefinitionList = documentDefinitionDBInstance.getAllDocumentDefinitions();
            }
            return documentDefinitionList;
        }
        set;
    }

    public static Map<String, clcommon__Document_Definition__c> documentDefinitionByName {
        get {
            if(documentDefinitionByName == null) {
                documentDefinitionByName = new Map<String, clcommon__Document_Definition__c>();
                for(clcommon__Document_Definition__c definition : documentDefinitionList) {
                    documentDefinitionByName.put(definition.Name, definition);
                }
            }
            return documentDefinitionByName;
        }
        set;
    }

    public static Map<String, Id> legalNameToId {
        get {
            if(legalNameToId == null) {
                legalNameToId = new Map<String, Id>();
                for(clcommon__Legal_Entity__c legalEntity : legalEntityDBInstance.getLegalEntity()) {
                    legalNameToId.put(legalEntity.Name, legalEntity.Id);
                }
            }
            return legalNameToId;
        }
        set;
    }

    public static Map<Id, clcommon__Legal_Entity__c> legalEntityMap {
        get {
            if(legalEntityMap == null) {
                legalEntityMap = new Map<Id, clcommon__Legal_Entity__c>(legalEntityDBInstance.getLegalEntity());
            }
            return legalEntityMap;
        }
        set;
    }

    public static Map<String, CAN_Max_Amount_And_Max_Term_Mapping__c> maxAmountAndMaxTermByCriteria {
        get {
            if(maxAmountAndMaxTermByCriteria == null) {
                maxAmountAndMaxTermByCriteria = new Map<String, CAN_Max_Amount_And_Max_Term_Mapping__c>();
                for(CAN_Max_Amount_And_Max_Term_Mapping__c maxAmountAndMaxTerm :
                    maxAmountAndMaxTermMappingDBInstance.getMaxAmountAndMaxTermMappingsByRandomNumber(randomNumber)
                ) {
                    String key = maxAmountAndMaxTerm.Pricing_Type__c + maxAmountAndMaxTerm.Loan_Type__c + maxAmountAndMaxTerm.Industry_Rating__c + maxAmountAndMaxTerm.SC4_Tier__c;
                    maxAmountAndMaxTermByCriteria.put(key, maxAmountAndMaxTerm);
                }
            }
            return maxAmountAndMaxTermByCriteria;
        }
        set;
    }

    public static Map<String, CAN_Min_And_Max_Pricing_Detail__c> minAndMaxPricingByCriteria {
        get {
            if(minAndMaxPricingByCriteria == null) {
                minAndMaxPricingByCriteria = new Map<String, CAN_Min_And_Max_Pricing_Detail__c>();
                for(CAN_Min_And_Max_Pricing_Detail__c minAndMaxPricing :
                    minAndMaxPricingDBInstance.getMinAndMaxPricingMapping()
                ) {
                    String key = minAndMaxPricing.sc4_tier__c + minAndMaxPricing.term__c;
                    minAndMaxPricingByCriteria.put(key, minAndMaxPricing);
                }
            }
            return minAndMaxPricingByCriteria;
        }
        set;
    }

    public static Decimal randomNumber {get;set;}
    private static Decimal existingRandomNumber {get;set;}

    public static Map<String, CAN_Pricing_Matrix_Detail__c> pricingMatrixDetailByCriteria {
        get {
            if(pricingMatrixDetailByCriteria == null || randomNumber != existingRandomNumber) {
                existingRandomNumber = randomNumber;
                pricingMatrixDetailByCriteria = new Map<String, CAN_Pricing_Matrix_Detail__c>();
                for(CAN_Pricing_Matrix_Detail__c pricingMatrixDetail : pricingMatrixDetailDBInstance.getPricingMatrixDetailsByRandomNumber(randomNumber)) {
                    String key = pricingMatrixDetail.Pricing_Type__c + pricingMatrixDetail.Term__c + pricingMatrixDetail.Loan_Type__c +
                        + pricingMatrixDetail.SC4_Tier__c + pricingMatrixDetail.Industry_Rating__c;
                    pricingMatrixDetailByCriteria.put(key, pricingMatrixDetail);
                }
            }
            return pricingMatrixDetailByCriteria;
        }
        set;
    }

    public static Map<String, CAN_GAV_Matrix_Detail__c> gavMatrixDetailByCriteria {
        get {
            if(gavMatrixDetailByCriteria == null || randomNumber != existingRandomNumber) {
                existingRandomNumber = randomNumber;
                gavMatrixDetailByCriteria = new Map<String, CAN_GAV_Matrix_Detail__c>();
                for(CAN_GAV_Matrix_Detail__c gavMatrixDetail : gavMatrixDetailDBInstance.getGAVMatrixDetailsByRandomNumber(randomNumber)) {
                    String key = gavMatrixDetail.Term__c + gavMatrixDetail.SC4_Tier__c + gavMatrixDetail.Industry_Rating__c + gavMatrixDetail.Loan_Type__c;
                    gavMatrixDetailByCriteria.put(key, gavMatrixDetail);
                }
            }
            return gavMatrixDetailByCriteria;
        }
        set;
    }

    public static Map<String, CAN_Industry_Rating_Profile__c> canIndustryProfile {
        get {
            if(canIndustryProfile == null) {
                canIndustryProfile = new Map<String, CAN_Industry_Rating_Profile__c>();
                for(CAN_Industry_Rating_Profile__c canIndustryProfileObject : industryRatingProfileDBInstance.getIndustryProfiles()) {
                    canIndustryProfile.put(canIndustryProfileObject.Description__c, canIndustryProfileObject);
                }
            }
            return canIndustryProfile;
        }
        set;
    }

    public static Map<String, CAN_Industry_Rating_Profile__c> canIndustryProfileSicDescription {
        get {
            if(canIndustryProfileSicDescription == null) {
                canIndustryProfileSicDescription = new Map<String, CAN_Industry_Rating_Profile__c>();
                for(CAN_Industry_Rating_Profile__c canIndustryProfileObject : industryRatingProfileDBInstance.getIndustryProfiles()) {
                    canIndustryProfileSicDescription.put(canIndustryProfileObject.Digit_Code__c, canIndustryProfileObject);
                }
            }
            return canIndustryProfileSicDescription;
        }
        set;
    }

    public static Set<String> competitorAccountNames {
        get {
            if(competitorAccountNames == null) {
                competitorAccountNames = new Set<String>();
                for(Account accountRecord : accountDBInstance.getAllCompetitorAccounts()) {
                    competitorAccountNames.add(accountRecord.Name.replaceAll('\\s', '').toUpperCase());

                    if(accountRecord.Additional_Names__c != null) {
                        String additionalNames = accountRecord.Additional_Names__c.replaceAll('\\s', '').toUpperCase();
                        competitorAccountNames.addAll(additionalNames.split(','));
                    }
                }
            }
            return competitorAccountNames;
        }
        set;
    }

    private class OriginationHelperException extends Exception {}
}