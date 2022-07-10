@isTest
private class OriginationHelperTests {

    @isTest
    private static void clProduct() {
        clcommon__CL_Product__c productCL = new clcommon__CL_Product__c();
        productCL.clcommon__Product_Name__c = GeneralConstants.PRODUCT_NAME_DEFAULT;
        productCL.Id = TestUtility.getFakeId(clcommon__CL_Product__c.getSObjectType());

        DBManagerTestsStub clProductDBStubInstance = new DBManagerTestsStub();
        clProductDBStubInstance.genericReturnObject = new List<clcommon__CL_Product__c>{productCL};
        OriginationHelper.clProductDBInstance  = (CLProductDB) Test.createStub(CLProductDB.class, clProductDBStubInstance);

        Test.startTest();
            clcommon__CL_Product__c clProducts = OriginationHelper.clProduct;
        Test.stopTest();

        System.assertEquals(productCL.Id, clProducts.Id);
        System.assertEquals(productCL.clcommon__Product_Name__c, clProducts.clcommon__Product_Name__c);
    }

    @isTest
    private static void clProductException() {

        Exception ex;
        Test.startTest();
            try{
                clcommon__CL_Product__c clProducts = OriginationHelper.clProduct;
            }catch (Exception e){
                ex = e;
            }
        Test.stopTest();

        String exceptionMessage = 'There was no CL product exist in the system';
        System.assertEquals(exceptionMessage, ex.getMessage());
    }

    @isTest
    private static void clCompany() {
        clcommon__Company__c companyCL = new clcommon__Company__c();
        companyCL.clcommon__Company_Name__c = GeneralConstants.COMPANY_NAME;
        companyCL.Id = TestUtility.getFakeId(clcommon__Company__c.getSObjectType());

        DBManagerTestsStub clCompanyDBStubInstance = new DBManagerTestsStub();
        clCompanyDBStubInstance.genericReturnObject = new List<clcommon__Company__c>{companyCL};
        OriginationHelper.clCompanyDBInstance  = (CLCompanyDB) Test.createStub(CLCompanyDB.class, clCompanyDBStubInstance);

        Test.startTest();
            clcommon__Company__c clCompanies = OriginationHelper.clCompany;
        Test.stopTest();

        System.assertEquals(companyCL.Id, clCompanies.Id);
        System.assertEquals(companyCL.clcommon__Company_Name__c, clCompanies.clcommon__Company_Name__c);
    }

    @isTest
    private static void clCompanyException() {

        Exception ex;
        Test.startTest();
            try{
                clcommon__Company__c clCompanies = OriginationHelper.clCompany;
            }catch (Exception e){
                ex = e;
            }
        Test.stopTest();

        String exceptionMessage = 'There was no CL Company exist in the system';
        System.assertEquals(exceptionMessage, ex.getMessage());
    }

    @isTest
    private static void company() {
        genesis__Company__c genesisCompany = new genesis__Company__c();
        genesisCompany.Name = GeneralConstants.COMPANY_NAME;
        genesisCompany.Id = TestUtility.getFakeId(genesis__Company__c.getSObjectType());

        DBManagerTestsStub companyDBStubInstance = new DBManagerTestsStub();
        companyDBStubInstance.genericReturnObject = new List<genesis__Company__c>{genesisCompany};
        OriginationHelper.companyDBInstance  = (CompanyDB) Test.createStub(CompanyDB.class, companyDBStubInstance);

        Test.startTest();
            genesis__Company__c genesisCompanies = OriginationHelper.company;
        Test.stopTest();

        System.assertEquals(genesisCompany.Id, genesisCompanies.Id);
        System.assertEquals(genesisCompany.Name, genesisCompanies.Name);
    }

    @isTest
    private static void companyException() {

        Exception ex;
        Test.startTest();
            try{
                genesis__Company__c genesisCompanies = OriginationHelper.company;
            }catch (Exception e){
                ex = e;
            }
        Test.stopTest();

        String exceptionMessage = 'There was no Origination Company exist in the system';
        System.assertEquals(exceptionMessage, ex.getMessage());
    }

    @isTest
    private static void partyTypeToId() {
        clcommon__Party_Type__c partyType = new clcommon__Party_Type__c();
        partyType.Name = GeneralConstants.PARTY_TYPE_BORROWER;
        partyType.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());

        DBManagerTestsStub partyTypeDBStubInstance = new DBManagerTestsStub();
        partyTypeDBStubInstance.genericReturnObject = new List<clcommon__Party_Type__c>{partyType};
        OriginationHelper.partyTypeDBInstance = (PartyTypeDB) Test.createStub(PartyTypeDB.class, partyTypeDBStubInstance);

        Test.startTest();
            Map<String, Id> partyTypeMap = OriginationHelper.partyTypeToId;
        Test.stopTest();

        System.assertEquals(1, partyTypeMap.size());
        System.assertEquals(partyType.Id, partyTypeMap.get(GeneralConstants.PARTY_TYPE_BORROWER));
    }

    @isTest
    private static void documentDefinitionList() {
        clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
        documentDefinition.clcommon__Active__c = true;
        documentDefinition.Id = TestUtility.getFakeId(clcommon__Document_Definition__c.getSObjectType());

        DBManagerTestsStub documentDefinitionDBStubInstance = new DBManagerTestsStub();
        documentDefinitionDBStubInstance.genericReturnObject = new List<clcommon__Document_Definition__c> {documentDefinition};
        OriginationHelper.documentDefinitionDBInstance = (DocumentDefinitionDB) Test.createStub(DocumentDefinitionDB.class, documentDefinitionDBStubInstance);

        Test.startTest();
            List<clcommon__Document_Definition__c> documentDefinitionList = OriginationHelper.documentDefinitionList;
        Test.stopTest();

        System.assertEquals(1, documentDefinitionList.size());
        System.assertEquals(documentDefinition.Id, documentDefinitionList.get(0).Id);
        System.assertEquals(documentDefinition.clcommon__Active__c, documentDefinitionList.get(0).clcommon__Active__c);
    }

    @isTest
    private static void legalNameToId() {
        clcommon__Legal_Entity__c legalEntity = new clcommon__Legal_Entity__c();
        legalEntity.Name = GeneralConstants.LEGAL_TYPE_CORPORATION;
        legalEntity.Id = TestUtility.getFakeId(clcommon__Legal_Entity__c.getSObjectType());

        DBManagerTestsStub legalEntityDBStubInstance = new DBManagerTestsStub();
        legalEntityDBStubInstance.genericReturnObject = new List<clcommon__Legal_Entity__c>{legalEntity};
        OriginationHelper.legalEntityDBInstance = (LegalEntityDB) Test.createStub(LegalEntityDB.class, legalEntityDBStubInstance);

        Test.startTest();
            Map<String, Id> legalEntityMap = OriginationHelper.legalNameToId;
        Test.stopTest();

        System.assertEquals(1, legalEntityMap.size());
        System.assertEquals(legalEntity.Id, legalEntityMap.get(GeneralConstants.LEGAL_TYPE_CORPORATION));
    }

    @isTest
    private static void legalEntityMap() {
        clcommon__Legal_Entity__c legalEntity = new clcommon__Legal_Entity__c();
        legalEntity.Id = TestUtility.getFakeId(clcommon__Legal_Entity__c.getSObjectType());

        DBManagerTestsStub legalEntityDBStubInstance = new DBManagerTestsStub();
        legalEntityDBStubInstance.genericReturnObject = new List<clcommon__Legal_Entity__c> {legalEntity};
        OriginationHelper.legalEntityDBInstance = (LegalEntityDB) Test.createStub(LegalEntityDB.class, legalEntityDBStubInstance);

        Test.startTest();
            Map<Id, clcommon__Legal_Entity__c> legalEntityIdMap = OriginationHelper.legalEntityMap;
        Test.stopTest();

        System.assertEquals(1, legalEntityIdMap.size());
        System.assertEquals(legalEntity, legalEntityIdMap.get(legalEntity.Id));
    }

    @isTest
    private static void maxAmountAndMaxTermByCriteria() {
        CAN_Max_Amount_And_Max_Term_Mapping__c canMaxAmountMaxTerm = new CAN_Max_Amount_And_Max_Term_Mapping__c();
        canMaxAmountMaxTerm.Loan_Type__c = 'New';
        canMaxAmountMaxTerm.Industry_Rating__c = 'A+ Medical';
        canMaxAmountMaxTerm.SC4_Tier__c = 'TIER 1';
        canMaxAmountMaxTerm.Pricing_Type__c = 'Direct New';

        DBManagerTestsStub maxAmountAndMaxTermMappingDBStubInstance = new DBManagerTestsStub();
        maxAmountAndMaxTermMappingDBStubInstance.genericReturnObject = new List<CAN_Max_Amount_And_Max_Term_Mapping__c> {canMaxAmountMaxTerm};
        OriginationHelper.maxAmountAndMaxTermMappingDBInstance = (MaxAmountAndMaxTermMappingDB) Test.createStub(MaxAmountAndMaxTermMappingDB.class, maxAmountAndMaxTermMappingDBStubInstance);

        String key = canMaxAmountMaxTerm.Pricing_Type__c + canMaxAmountMaxTerm.Loan_Type__c + canMaxAmountMaxTerm.Industry_Rating__c + canMaxAmountMaxTerm.SC4_Tier__c;

        Test.startTest();
            Map<String, CAN_Max_Amount_And_Max_Term_Mapping__c> canMaxAmountMaxTermMap = OriginationHelper.maxAmountAndMaxTermByCriteria;
        Test.stopTest();

        System.assertEquals(1, canMaxAmountMaxTermMap.size());
        System.assertEquals(canMaxAmountMaxTerm, canMaxAmountMaxTermMap.get(key));
    }

    @isTest
    private static void pricingMatrixDetailByCriteria() {
        CAN_Pricing_Matrix_Detail__c canPricingMatrixDetail = new CAN_Pricing_Matrix_Detail__c();
        canPricingMatrixDetail.Term__c = 6;
        canPricingMatrixDetail.Loan_Type__c = 'New';
        canPricingMatrixDetail.SC4_Tier__c = 'TIER 1';
        canPricingMatrixDetail.Industry_Rating__c = 'A+ Medical';
        canPricingMatrixDetail.Pricing_Type__c = 'Direct New';

        DBManagerTestsStub pricingMatrixDetailDBStubInstance = new DBManagerTestsStub();
        pricingMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_Pricing_Matrix_Detail__c> {canPricingMatrixDetail};
        OriginationHelper.pricingMatrixDetailDBInstance = (PricingMatrixDetailDB) Test.createStub(PricingMatrixDetailDB.class, pricingMatrixDetailDBStubInstance);

        String key = canPricingMatrixDetail.Pricing_Type__c + canPricingMatrixDetail.Term__c + canPricingMatrixDetail.Loan_Type__c +
                        + canPricingMatrixDetail.SC4_Tier__c + canPricingMatrixDetail.Industry_Rating__c;

        Test.startTest();
            Map<String, CAN_Pricing_Matrix_Detail__c> canPricingMatrixDetailMap = OriginationHelper.pricingMatrixDetailByCriteria;
        Test.stopTest();

        System.assertEquals(1, canPricingMatrixDetailMap.size());
        System.assertEquals(canPricingMatrixDetail, canPricingMatrixDetailMap.get(key));
    }

    @isTest
    private static void gavMatrixDetailByCriteria() {
        CAN_GAV_Matrix_Detail__c canGAVMatrixDetail = new CAN_GAV_Matrix_Detail__c();
        canGAVMatrixDetail.GAV__c = 14.00;
        canGAVMatrixDetail.Term__c = 6;
        canGAVMatrixDetail.Industry_Rating__c = 'A+ Medical';
        canGAVMatrixDetail.SC4_Tier__c = 'TIER 1';

        DBManagerTestsStub gavMatrixDetailDBStubInstance = new DBManagerTestsStub();
        gavMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_GAV_Matrix_Detail__c> {canGAVMatrixDetail};
        OriginationHelper.gavMatrixDetailDBInstance = (GAVMatrixDetailDB) Test.createStub(GAVMatrixDetailDB.class, gavMatrixDetailDBStubInstance);

        String key = canGAVMatrixDetail.Term__c + canGAVMatrixDetail.SC4_Tier__c + canGAVMatrixDetail.Industry_Rating__c;

        Test.startTest();
            Map<String, CAN_GAV_Matrix_Detail__c> canGAVMatrixDetailMap = OriginationHelper.gavMatrixDetailByCriteria;
        Test.stopTest();

        System.assertEquals(1, canGAVMatrixDetailMap.size());
        System.assertEquals(canGAVMatrixDetail, canGAVMatrixDetailMap.get(key));
    }

    @isTest
    private static void canIndustryProfile() {
        CAN_Industry_Rating_Profile__c canIndustryProfile = new CAN_Industry_Rating_Profile__c();
        canIndustryProfile.Description__c = 'COMMUNICATIONS';

        DBManagerTestsStub industryRatingProfileDBStubInstance = new DBManagerTestsStub();
        industryRatingProfileDBStubInstance.genericReturnObject = new List<CAN_Industry_Rating_Profile__c> {canIndustryProfile};
        OriginationHelper.industryRatingProfileDBInstance = (IndustryRatingProfileDB) Test.createStub(IndustryRatingProfileDB.class, industryRatingProfileDBStubInstance);

        Test.startTest();
            Map<String, CAN_Industry_Rating_Profile__c> canIndustryProfileMap = OriginationHelper.canIndustryProfile;
        Test.stopTest();

        System.assertEquals(1, canIndustryProfileMap.size());
        System.assertEquals(canIndustryProfile, canIndustryProfileMap.get(canIndustryProfile.Description__c));
    }

    @isTest
    private static void canIndustryProfileSicDescription() {
        CAN_Industry_Rating_Profile__c canIndustryProfileSicDescription = new CAN_Industry_Rating_Profile__c();
        canIndustryProfileSicDescription.Digit_Code__c = '48';

        DBManagerTestsStub industryRatingProfileDBStubInstance = new DBManagerTestsStub();
        industryRatingProfileDBStubInstance.genericReturnObject = new List<CAN_Industry_Rating_Profile__c> {canIndustryProfileSicDescription};
        OriginationHelper.industryRatingProfileDBInstance = (IndustryRatingProfileDB) Test.createStub(IndustryRatingProfileDB.class, industryRatingProfileDBStubInstance);

        Test.startTest();
            Map<String, CAN_Industry_Rating_Profile__c> canIndustryProfileSicDescriptionMap = OriginationHelper.canIndustryProfileSicDescription;
        Test.stopTest();

        System.assertEquals(1, canIndustryProfileSicDescriptionMap.size());
        System.assertEquals(canIndustryProfileSicDescription, canIndustryProfileSicDescriptionMap.get(canIndustryProfileSicDescription.Digit_Code__c));
    }

    @isTest
    private static void competitorAccountNames() {
        Account accountRecord = new Account();
        accountRecord.Name = 'Account Name';
        accountRecord.Additional_Names__c = 'Additional 1, Additional 2';
        set<String> validSet = new set<String>{'ACCOUNTNAME', 'ADDITIONAL1', 'ADDITIONAL2'};

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {accountRecord};
        OriginationHelper.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Test.startTest();
            set<String> competitorAccountNamesSet = OriginationHelper.competitorAccountNames;
        Test.stopTest();

        System.assertEquals(3, competitorAccountNamesSet.size());
        System.assertEquals(competitorAccountNamesSet, validSet);
    }
}