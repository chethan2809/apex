public class CreatePostSandboxSetupData {

    public static Date systemDate = date.newInstance(2020, 01, 01);
    public static final Set<String> PARTY_TYPES = new Set<String> { 'BORROWER', 'BROKER', 'GUARANTOR', 'CONTACT', 'COMPETITOR' };
    public static final String COMPANY_NAME = 'CAN Capital';
    public static Set<String> feeNames = new Set<String>{
        'Origination Fee', 'Florida Fee', 'Blocked Account Fee', 'Late Fee', 'Returned ACH Fee', 'Site Inspection fee',
        'Loan Modification Fee', 'Skip Tracing Fee', 'Document Request', 'Subordination Fee', 'Attorney Fee',
        'Post-Judgment Interest', 'Convenience Fee', 'Pre Closure Fee'
    };

    public static loan__Fee_Set__c feeSet;
    public static loan__Loan_Product__c loanProduct;
    public static clcommon__CL_Product__c clProduct;
    public static loan__Office_Name__c loanOffice;
    public static clcommon__Company__c clCompany;

    public static void runSetup() {
        if(!GeneralHelper.getOrgInformation.isSandbox && !Test.isRunningTest()) {
            System.debug('====== Cannot run in Production ====');
            return;
        }
        List<loan__Office_Name__c> loanOfficeList = [SELECT Id, loan__Current_System_Date__c FROM loan__Office_Name__c WHERE Name = :COMPANY_NAME];
        List<loan__Loan_Product__c> loanProductList = [SELECT Id FROM loan__Loan_Product__c WHERE Name = :COMPANY_NAME];

        if(loanProductList.isEmpty()) {
            loan.PostInstallManager.createSeedDataOnInstall();
            loanProduct = new loan__Loan_Product__c();
            updateLoanBranch();
            createGenesisBranchLocationAndCompany();
        } else {
            loanProduct = loanProductList.get(0);
            loanOffice = loanOfficeList.get(0);
            systemDate = loanOffice.loan__Current_System_Date__c;
        }

        List<clcommon__Company__c> clCompanyList = [SELECT Id FROM clcommon__Company__c WHERE clcommon__Company_Name__c = :COMPANY_NAME];
        if(clCompanyList.isEmpty()) {
            createCLCompany();
        } else {
            clCompany = clCompanyList.get(0);
        }
        createLoanUserBranchInfo(loanOffice.Id);
        createLoanFeeSet();
        createOtherFees();
        assignFeesToFeeSet();
        createLoanProduct(feeSet.Id);
        createCLProduct();
        createOriginationBaseData();
        setupCustomSettings();

        if(loanProductList.isEmpty()) {
            createCLProductToCompanyAssignment();
            createLoanDayAndMonthProcess(loanOffice.Id, systemDate);
        }
    }

    @future
    public static void createOriginationBaseData() {
        createPaymentSpread();
        createPartType();
        createLegalEntity();
        createDocumentDefinition();
        createConversionMapping();
        createCommissionPlan();
        createCongaTemplate();
        createCongaMergeQuery();
        setupCustomSettings();
        createReciprocalRole();
        createAdditionalPaymentModes();
    }

    private static void updateLoanBranch(){
        loanOffice = [SELECT Id FROM loan__Office_Name__c WHERE Name = :COMPANY_NAME];
        loanOffice.loan__Current_System_Date__c = systemDate;
        update loanOffice;
    }

    private static void createCLCompany() {
        clCompany = new clcommon__Company__c();
        clCompany.clcommon__Company_Name__c = COMPANY_NAME;
        clCompany.clcommon__Branch_Date__c = systemDate;
        insert clCompany;
    }

    private static void createGenesisBranchLocationAndCompany() {

        List<genesis__Branch_Location__c> genesisBranchLocationList = [SELECT Id FROM genesis__Branch_Location__c WHERE Name = :COMPANY_NAME];
        List<loan__Branch_Location__c> loanBranchLocationList = [SELECT Id FROM loan__Branch_Location__c WHERE Name = :COMPANY_NAME];

        genesis__Branch_Location__c genesisBranchLocation = new genesis__Branch_Location__c();

        if(genesisBranchLocationList.isEmpty()){
            genesisBranchLocation = new genesis__Branch_Location__c();
        } else {
            genesisBranchLocation = genesisBranchLocationList.get(0);
        }
        loan__Branch_Location__c loanBranchLocation= loanBranchLocationList.get(0);

        genesisBranchLocation.Name = COMPANY_NAME;
        genesisBranchLocation.genesis__Address_Line_1__c = 'Building 500';
        loanBranchLocation.loan__Address_Line_1__c = 'Building 500';

        genesisBranchLocation.genesis__Address_Line_2__c = '2015 Vaughn Rd NW';
        loanBranchLocation.loan__Address_Line_2__c = '2015 Vaughn Rd NW';

        genesisBranchLocation.genesis__City__c = 'Kennesaw';
        loanBranchLocation.loan__City__c = 'Kennesaw';

        genesisBranchLocation.genesis__State__c = 'GA';
        loanBranchLocation.loan__State__c = 'GA';

        genesisBranchLocation.genesis__Phone__c = '+1 877-500-8282';
        loanBranchLocation.loan__Phone__c = '+1 877-500-8282';

        genesisBranchLocation.genesis__Zip_Code__c = '30144';
        loanBranchLocation.loan__Zip_Code__c = 30144;

        genesisBranchLocation.genesis__Country__c = 'US';
        loanBranchLocation.loan__Country__c = 'US';

        upsert genesisBranchLocation;
        update loanBranchLocation;

        List<genesis__Company__c> genesisCompanyList = [SELECT Id FROM genesis__Company__c WHERE genesis__Default__c = true];

        if(genesisCompanyList.isEmpty()) {
            genesis__Company__c genesisCompany = new genesis__Company__c();
            genesisCompany.Name = COMPANY_NAME;
            genesisCompany.genesis__Default__c = true;
            genesisCompany.genesis__Enabled_Flag__c = true;
            genesisCompany.genesis__Short_Name__c = 'HQ';
            genesisCompany.genesis__Location__c = genesisBranchLocation.Id;
            insert genesisCompany;
        }
    }

    @future
    private static void createLoanDayAndMonthProcess(Id loanOfficeId, Date systemDate) {
        Date startDate = Date.newInstance(systemDate.year(), 01, 01);
        Date endDate = Date.newInstance(systemDate.year(), 12, 31);

        delete [SELECT Id FROM loan__Fiscal_Year__c];

        loan__Fiscal_Year__c loanFiscalYear = new loan__Fiscal_Year__c();
        loanFiscalYear.Name = String.valueOf(systemDate.year());
        loanFiscalYear.loan__Archived__c = false;
        loanFiscalYear.loan__Master_Archive_Object__c = false;
        loanFiscalYear.loan__Start_Date__c = startDate;
        loanFiscalYear.loan__End_Date__c = endDate;
        loanFiscalYear.loan__Status__c = 'Open';
        loanFiscalYear.loan__Summary__c = false;
        insert loanFiscalYear;

        delete [SELECT Id FROM loan__Day_Process__c];

        List<loan__Day_Process__c> dayProcessList = new List<loan__Day_Process__c>();

        while (startDate <= endDate) {
            loan__Day_Process__c dayProcess = new loan__Day_Process__c();
            dayProcess.loan__Date__c = startDate;
            dayProcess.loan__Branch__c = loanOfficeId;
            dayProcessList.add(dayProcess);
            startDate = startDate.addDays(1);
        }
        insert dayProcessList;

        delete [SELECT Id FROM loan__Month_Process__c];
        List<loan__Month_Process__c> monthProcessList = new List<loan__Month_Process__c>();
        Date monthStartDate = Date.newInstance(systemDate.year(), 01, 31);

        while (monthStartDate <= endDate) {
            loan__Month_Process__c monthProcess = new loan__Month_Process__c();
            monthProcess.loan__Last_Day_of_Month__c = monthStartDate;
            monthProcess.loan__Branch__c = loanOfficeId;
            monthProcessList.add(monthProcess);
            monthStartDate = monthStartDate.addMonths(2).toStartOfMonth().addDays(-1);
        }

        insert monthProcessList;
    }

    public static void createLoanUserBranchInfo(Id loanOfficeId) {
        delete [SELECT Id FROM loan__User_Branch_Info__c];
        List<User> userList = [SELECT Id FROM User WHERE IsActive = true AND UserType = 'Standard'];
        List<loan__User_Branch_Info__c> loanUserBranchList = new List<loan__User_Branch_Info__c>();

        for(User userInfo : userList) {
            userInfo.loan__Default_Branch__c = COMPANY_NAME;
            userInfo.loan__Current_Branch__c = COMPANY_NAME;
            userInfo.loan__Current_Branch_s_System_Date__c = systemDate;
            userInfo.TimeZoneSidKey = 'America/New_York';

            loan__User_Branch_Info__c userBranchInfo = new loan__User_Branch_Info__c();
            userBranchInfo.loan__Branch__c = loanOfficeId;
            userBranchInfo.loan__Default_Branch__c = true;
            userBranchInfo.loan__User__c = userInfo.Id;
            loanUserBranchList.add(userBranchInfo);
        }

        insert loanUserBranchList;
        update userList;
    }

    private static void createLoanFeeSet() {
        List<loan__Fee_Set__c> feeSetList = [SELECT Id FROM loan__Fee_Set__c WHERE Name = 'CAN Capital Fee Set'];
        if(feeSetList.isEmpty()) {
            feeSet = new loan__Fee_Set__c();
            feeSet.Name = 'CAN Capital Fee Set';
            feeSet.loan__Fee_Set_Category__c = 'Loan';

            insert feeSet;
        } else {
            feeSet = feeSetList.get(0);
        }
    }

    public static void createOtherFees() {
        Map<String, loan__Fee__c> feeMap = new Map<String, loan__Fee__c>();
        for(loan__Fee__c fee : [SELECT Id, Name FROM loan__Fee__c WHERE Name IN : feeNames]) {
            feeMap.put(fee.Name, fee);
        }
        List<loan__Fee__c> feeList = new List<loan__Fee__c>();
        for(String feeName : feeNames) {
            loan__Fee__c fee = new loan__Fee__c();
            if(feeMap.containsKey(feeName)) {
                fee = feeMap.get(feeName);
            }
            fee.Name = feeName;
            fee.loan__Fee_Category__c = 'Loan';
            fee.loan__Time_of_charge__c = 'Other';
            fee.loan__Amount__c =  0.00;
            fee.loan__Fee_Calculation_Method__c = 'Fixed';
            fee.loan__State__c = 'Active';
            fee.loan__Include_In_Dues__c = true;
            if(feeName == 'Origination Fee') {
                fee.loan__Accrual_Required__c = true;
            }
            feeList.add(fee);
        }

        if(!feeList.isEmpty()) {
            upsert feeList;
        }
    }

    private static void assignFeesToFeeSet() {
        delete [SELECT Id FROM loan__Fee_Junction__c];
        List<loan__Fee_Junction__c> feeJunctionList = new List<loan__Fee_Junction__c>();
        for(loan__Fee__c fee : [SELECT Id FROM loan__Fee__c WHERE Name IN :feeNames]) {
            loan__Fee_Junction__c feeJunction = new loan__Fee_Junction__c();
            feeJunction.loan__Fee_Set__c = feeSet.Id;
            feeJunction.loan__Fee__c = fee.Id;
            feeJunctionList.add(feeJunction);
        }

        insert feeJunctionList;
    }

    public static void createLoanProduct(Id feeSetId) {

        Id recordTypeId = Schema.SObjectType.loan__Loan_Product__c.getRecordTypeInfosByName().get('Flexible Amz Loan Product Record Type').getRecordTypeId();
        loanProduct.RecordTypeId = recordTypeId;
        loanProduct.Name = COMPANY_NAME;
        loanProduct.loan__Interest_Calculation_Method__c = 'Declining Balance';
        loanProduct.loan__Loan_Product_Type__c = 'Flexible Amz Loan';
        loanProduct.loan__Frequency_of_Loan_Payment__c = 'Daily';
        loanProduct.loan__Time_Counting_Method__c = 'Actual Days';
        loanProduct.loan__Actual_Interest_Only_Payments__c = false;
        loanProduct.loan__Accrual_Start_Basis__c = 'Disbursal Date';
        loanProduct.loan__Higher_Investor_Certificate_Rate_Allowed__c = true;
        loanProduct.loan__Payment_Application_Mode__c = 'Current Dues';
        loanProduct.loan__Payment_Application_Order__c = 'Date';
        loanProduct.loan__Add_Fee_Amount_To_Bill__c = true;
        loanProduct.loan__Accrual_Based_Accounting__c = true;
        loanProduct.loan__Accrual_Entry_Frequency__c = 'Daily';
        loanProduct.loan__Accrue_Income_On_Suspended_Account__c = false;
        loanProduct.loan__Status__c = 'Active';
        loanProduct.loan__Move_Across_Months__c = false;
        loanProduct.loan__Business_Hours__c = [SELECT Id FROM BusinessHours WHERE IsActive = true AND IsDefault = true LIMIT 1].get(0).Id;
        loanProduct.loan__Repayment_Billing_Method__c = 'Principal Plus Interest';
        loanProduct.loan__Schedule_Adjustment_Method__c = 'After';
        loanProduct.loan__Create_Summaries__c = true;
        loanProduct.loan__Delinquency_Basis__c = 'Bills';
        loanProduct.loan__Min_Loan_Amount__c = 2500;
        loanProduct.loan__Max_Loan_Amount__c = 325000;
        loanProduct.loan__Min_Number_of_Installments__c = 3;
        loanProduct.loan__Max_Number_of_Installments__c = 1000;
        loanProduct.loan__Default_Number_of_Installments__c = 6;
        loanProduct.loan__Interest_Rate_Type__c	= 'Fixed';
        loanProduct.loan__Floating_Rate_Change_Action__c = 'Keep Same Payment Amount';
        loanProduct.loan__Min_Interest_Rate__c = 1.00;
        loanProduct.loan__Margin_Rate__c = 0.00;
        loanProduct.loan__Max_Interest_Rate__c = 200.00;
        loanProduct.loan__Default_Interest_Rate__c = 39;
        loanProduct.loan__Interest_Period_Calculation__c = null;
        loanProduct.loan__Repayment_Procedure__c = 'Equal Monthly Installments';
        loanProduct.loan__Reschedule_Option_on_Excess_Payment__c = 'Keep Same Payment Amount';
        loanProduct.loan__Principal_Adjustment_Reschedule_Option__c = 'Keep Same Payment Amount';
        loanProduct.loan__Fee_Set__c = feeSetId;
        loanProduct.loan__Funding_in_Tranches__c = true;
        loanProduct.loan__Is_Interest_Posting_Enabled__c = true;
        loanProduct.loan__Interest_Posting_Frequency__c = loanProduct.loan__Frequency_of_Loan_Payment__c;

        upsert loanProduct;
    }

    private static void createCLProduct() {

        List<clcommon__CL_Product__c> clProductList = [SELECT Id FROM clcommon__CL_Product__c WHERE Name = :COMPANY_NAME];
        if(clProductList.isEmpty()) {
            clProduct = new clcommon__CL_Product__c();
        } else {
            clProduct = clProductList.get(0);
        }

        Id recordTypeId = Schema.SObjectType.clcommon__CL_Product__c.getRecordTypeInfosByName().get('Loan').getRecordTypeId();
        clProduct.RecordTypeId = recordTypeId;
        clProduct.clcommon__Product_Name__c = COMPANY_NAME;
        clProduct.loan__Lending_Product__c = loanProduct.Id;
        clProduct.clcommon__Class__c = 'Commercial';

        upsert clProduct;

    }

    private static void createCLProductToCompanyAssignment() {
        delete [SELECT Id FROM clcommon__Company_Product_Assignment__c];
        clcommon__Company_Product_Assignment__c  clProductCompanyAssignment = new clcommon__Company_Product_Assignment__c();
        clProductCompanyAssignment.clcommon__Company__c = [SELECT Id FROM clcommon__Company__c WHERE clcommon__Company_Name__c = :COMPANY_NAME LIMIT 1].Id;
        clProductCompanyAssignment.clcommon__CL_Product__c = clProduct.Id;

        insert clProductCompanyAssignment;
    }

    private static void createPaymentSpread() {
        List<loan__Conditions_On_Spread__c> spreadConditionList = [
            SELECT Id FROM loan__Conditions_On_Spread__c
            WHERE loan__Parameter__c = 'True' AND loan__Operator__c = '=' AND loan__Value__c = 'True'
            LIMIT 1
        ];

        if(spreadConditionList.isEmpty()) {
            loan__Conditions_On_Spread__c spreadCondition = new loan__Conditions_On_Spread__c();
            spreadCondition.loan__Parameter__c = 'True';
            spreadCondition.loan__Operator__c = '=';
            spreadCondition.loan__Value__c = 'True';
            insert spreadCondition;
        }

        String spreadName = 'CAN Payment Spread';
        String spreadOrder = 'Interest, Principal, Fees';

        List<loan__Loan_Payment_Spread__c> paymentSpreadList = [
            SELECT Id, loan__Order_Of_Payment__c FROM loan__Loan_Payment_Spread__c WHERE Name = :spreadName LIMIT 1
        ];

        if(paymentSpreadList.isEmpty()) {
            loan__Loan_Payment_Spread__c paymentSpread = new loan__Loan_Payment_Spread__c();
            paymentSpread.Name = spreadName;
            paymentSpread.loan__Order_Of_Payment__c = spreadOrder;
            insert paymentSpread;
        } else if(paymentSpreadList.get(0).loan__Order_Of_Payment__c != spreadOrder) {
            loan__Loan_Payment_Spread__c paymentSpread = paymentSpreadList.get(0);
            paymentSpread.loan__Order_Of_Payment__c = spreadOrder;
            update paymentSpread;
        }
    }

    public static void createPartType() {
        delete [SELECT Id, Name FROM clcommon__Party_Type__c WHERE Name NOT IN :PARTY_TYPES];
        Map<String, clcommon__Party_Type__c> partyTypeMap = new Map<String, clcommon__Party_Type__c>();
        for(clcommon__Party_Type__c partyType : [SELECT Id, Name FROM clcommon__Party_Type__c WHERE Name IN :PARTY_TYPES]) {
            partyTypeMap.put(partyType.Name, partyType);
        }

        List<clcommon__Party_Type__c> partyTypeList = new List<clcommon__Party_Type__c>();
        for(String name : PARTY_TYPES) {
            if(!partyTypeMap.containsKey(name)) {
                clcommon__Party_Type__c partyType = new clcommon__Party_Type__c();
                partyType.Name = name;
                partyTypeList.add(partyType);
            }
        }
        if(!partyTypeList.isEmpty()) {
            insert partyTypeList;
        }
    }

    public static void createLegalEntity() {
        Set<String> legalEntities = new Set<String> {
            'Individual', 'Corporation', 'Partnership', 'LLC', 'LLP', 'Sole Proprietorship', 'Limited Partnership', 'Other'
        };
        Map<String, clcommon__Legal_Entity__c> legalMap = new Map<String, clcommon__Legal_Entity__c>();
        List<clcommon__Legal_Entity__c> existingLegalEntityList = [SELECT Id, Name, clcommon__Legal_Entity_Type__c FROM clcommon__Legal_Entity__c WHERE Name IN :legalEntities];
        for(clcommon__Legal_Entity__c legalEntity : existingLegalEntityList) {
            legalMap.put(legalEntity.Name, legalEntity);
        }

        List<clcommon__Legal_Entity__c> legalList = new List<clcommon__Legal_Entity__c>();
        for(String name : legalEntities) {
            clcommon__Legal_Entity__c legalEntity = new clcommon__Legal_Entity__c();
            if(legalMap.containsKey(name)) {
                legalEntity = legalMap.get(name);
            }
            legalEntity.Name = name;
            legalEntity.clcommon__Legal_Entity_Type__c = Name;
            legalList.add(legalEntity);
        }
        if(!legalList.isEmpty()) {
            upsert legalList;
        }
    }

    public static void createReciprocalRole() {
        Set<String> reciprocalRolesSet = new Set<String> {
            'Borrower', 'Contact', 'Guarantor', 'Broker', 'Parent', 'Owner', 'Child', 'Grandparent', 'Grandchild',
            'Spouse', 'Owned By', 'Subsidiary', 'Self'
        };
        Map<String, clcommon__Reciprocal_Role__c> reciprocalRoleMap = new Map<String, clcommon__Reciprocal_Role__c>();
        List<clcommon__Reciprocal_Role__c> existingReciprocalRolesList = [SELECT Id, Name FROM clcommon__Reciprocal_Role__c WHERE Name IN :reciprocalRolesSet];
        for(clcommon__Reciprocal_Role__c role : existingReciprocalRolesList) {
            reciprocalRoleMap.put(role.Name, role);
        }

        List<clcommon__Reciprocal_Role__c> reciprocalRolesList = new List<clcommon__Reciprocal_Role__c>();
        for(String name : reciprocalRolesSet) {
            if(!reciprocalRoleMap.containsKey(name)) {
                clcommon__Reciprocal_Role__c reciprocalRole = new clcommon__Reciprocal_Role__c();
                reciprocalRole.Name = name;
                reciprocalRolesList.add(reciprocalRole);
            }
        }
        if(!reciprocalRolesList.isEmpty()) {
            insert reciprocalRolesList;
        }
    }

    public static void createAdditionalPaymentModes() {
        Set<String> paymentModes = new Set<String> {'Fee Refund'};
        Map<String, loan__Payment_Mode__c> paymentModeMap = new Map<String, loan__Payment_Mode__c>();
        List<loan__Payment_Mode__c> existingPaymentModeList = [SELECT Id, Name FROM loan__Payment_Mode__c WHERE Name IN :paymentModes];
        for(loan__Payment_Mode__c paymentMode : existingPaymentModeList) {
            paymentModeMap.put(paymentMode.Name, paymentMode);
        }

        List<loan__Payment_Mode__c> paymentModesList = new List<loan__Payment_Mode__c>();
        for(String name : paymentModes) {
            if(!paymentModeMap.containsKey(name)) {
                loan__Payment_Mode__c paymentMode = new loan__Payment_Mode__c();
                paymentMode.Name = name;
                paymentModesList.add(paymentMode);
            }
        }
        if(!paymentModesList.isEmpty()) {
            insert paymentModesList;
        }
    }

    public static void createDocumentDefinition() {
        Map<String, Map<String, Boolean>> documentByCategory = new Map<String, Map<String, Boolean>> ();
        Map<String, Boolean> applicationDocument = new Map<String, Boolean>();
        applicationDocument.put('Other', true);
        applicationDocument.put('Bank Statements', true);
        applicationDocument.put('Month to Date Banks', true);
        applicationDocument.put('ID Verification', true);
        applicationDocument.put('Competitor Loan Information', true);
        applicationDocument.put('Proof of Ownership', true);
        applicationDocument.put('Tax Lien Statement', true);
        applicationDocument.put('Tax Return', true);
        applicationDocument.put('Voided Check', true);
        applicationDocument.put('Loan Agreement', false);
        applicationDocument.put('Refinance Agreement', false);
        applicationDocument.put('Third Party Release Authorization', false);
        applicationDocument.put('Ocrolus Analytics Report', false);
        applicationDocument.put('WebBank Exception', false);
        applicationDocument.put('Application', false);
        applicationDocument.put('Call Recordings', false);
        documentByCategory.put('Application', applicationDocument);

        Map<String, Boolean> collectionDocument = new Map<String, Boolean>();
        collectionDocument.put('CL Collections', false);
        collectionDocument.put('Collections', false);
        collectionDocument.put('Collections Consumer Credit', false);
        collectionDocument.put('Collections Business Credit', false);
        documentByCategory.put('Collection', collectionDocument);

        Map<String, Boolean> accountDocument = new Map<String, Boolean>();
        accountDocument.put('Experian Business Credit Report', false);
        documentByCategory.put('Account', accountDocument);

        Map<String, Boolean> individualAccountDocument = new Map<String, Boolean>();
        individualAccountDocument.put('Experian Consumer Credit Report', false);
        documentByCategory.put('Individual Account', individualAccountDocument);

        Map<String, clcommon__Document_Definition__c> documentDefinitionMap = new Map<String, clcommon__Document_Definition__c>();
        for(clcommon__Document_Definition__c documentDefinition : [
            SELECT Id, Name FROM clcommon__Document_Definition__c]
        ) {
            documentDefinitionMap.put(documentDefinition.Name, documentDefinition);
        }

        List<clcommon__Document_Definition__c> documentDefinitionList = new List<clcommon__Document_Definition__c>();
        for(String category :documentByCategory.keySet()) {
            Map<String, Boolean> documentByShowPortal = documentByCategory.get(category);
            for(String name : documentByShowPortal.keySet()) {
                clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
                if(documentDefinitionMap.containsKey(name)) {
                    documentDefinition = documentDefinitionMap.get(name);
                }

                documentDefinition.Name = name;
                if(documentByShowPortal.get(name)) {
                    documentDefinition.clcommon__Show_In_Portal__c = 'UPLOAD_VIA_PORTAL';
                }
                documentDefinition.clcommon__Active__c = true;
                documentDefinition.Document_Category__c = category;
                documentDefinitionList.add(documentDefinition);
            }
        }
        if(!documentDefinitionList.isEmpty()) {
            upsert documentDefinitionList;
        }
    }

    public static void createConversionMapping() {
        Set<String> requiredApplicationFields = new Set<String> {
            'Maximum_Funding_Amount__c', 'genesis__Maturity_Date__c', 'genesis__Interest_Rate__c', 'genesis__Account__c', 'Bank_Account__c',
            'Type__c', 'genesis__Payment_Frequency__c', 'Primary_Guarantor__c', 'genesis__Expected_First_Payment_Date__c'
        };

        Map<String, Set<String>> sourceToTargetField = new Map<String, Set<String>>();
        sourceToTargetField.put('Maximum_Funding_Amount__c', new Set<String>{'loan__Loan_Amount__c'});
        sourceToTargetField.put('genesis__Maturity_Date__c', new Set<String>{'loan__Last_Installment_Date__c'});
        sourceToTargetField.put('genesis__Interest_Rate__c', new Set<String>{'loan__Interest_Rate__c'});
        sourceToTargetField.put('genesis__Account__c', new Set<String>{'loan__Account__c'});
        sourceToTargetField.put('Bank_Account__c', new Set<String>{'Bank_Account__c'});
        sourceToTargetField.put('Id', new Set<String>{'Application__c'});
        sourceToTargetField.put('Type__c', new Set<String>{'Type__c'});
        sourceToTargetField.put(
            'genesis__Payment_Frequency__c', new Set<String>{'loan__Frequency_of_Loan_Payment__c', 'loan__Interest_Posting_Frequency__c'}
        );
        sourceToTargetField.put('Origination_Fee_Amount__c', new Set<String>{'Origination_Fee__c'});
        sourceToTargetField.put('Origination_Fee_Percentage__c', new Set<String>{'Origination_Fee_Percentage__c'});
        sourceToTargetField.put('Broker_Contact__c', new Set<String>{'Broker_Contact__c'});
        sourceToTargetField.put('Broker_Account__c', new Set<String>{'Broker_Account__c'});
        sourceToTargetField.put('Primary_Guarantor__c', new Set<String>{'Primary_Contact__c'});
        sourceToTargetField.put('Florida_State_Fee__c', new Set<String>{'Florida_State_Fee__c'});
        sourceToTargetField.put('genesis__Expected_First_Payment_Date__c', new Set<String>{'loan__Expected_Repayment_Start_Date__c'});
        sourceToTargetField.put(
            'genesis__Expected_Start_Date__c',
            new Set<String>{'loan__Expected_Disbursal_Date__c', 'loan__Draw_Period_End_Date__c'}
        );
        sourceToTargetField.put('Broker_Standard_Commission__c', new Set<String>{'Broker_Standard_Commission__c'});
        sourceToTargetField.put('Buy_Rate__c', new Set<String>{'Buy_Rate__c'});
        sourceToTargetField.put('Pricing_Factor__c', new Set<String>{'Pricing_Factor__c'});

        delete [SELECT Id FROM genesis__Conversion_Mapping_Header__c];

        genesis__Conversion_Mapping_Header__c mappingHeader = new genesis__Conversion_Mapping_Header__c();
        mappingHeader.genesis__Product_Type__c = 'LOAN';
        insert mappingHeader;

        List<genesis__Conversion_Mapping__c> conversionMappingList = new List<genesis__Conversion_Mapping__c>();
        for(String sourceField :sourceToTargetField.keySet()) {
            for(String targetField :sourceToTargetField.get(sourceField)) {
                genesis__Conversion_Mapping__c conversionMapping = new genesis__Conversion_Mapping__c();
                conversionMapping.genesis__Conversion_Mapping_Header__c = mappingHeader.Id;
                conversionMapping.genesis__Product_Type__c = 'LOAN';
                conversionMapping.genesis__Required_For_Conversion__c = requiredApplicationFields.contains(sourceField);
                conversionMapping.genesis__Application_Object_Name__c = 'genesis__Applications__c';
                conversionMapping.genesis__Contract_Object_Name__c = 'loan__Loan_Account__c';
                conversionMapping.genesis__Application_Field_Name__c = sourceField;
                conversionMapping.genesis__Contract_Field_Name__c = targetField;
                conversionMappingList.add(conversionMapping);
            }
        }
        insert conversionMappingList;
    }

    public static void createCongaTemplate() {
        Map<String, String> congaTemplateNameToGroup = new Map<String, String>();
        congaTemplateNameToGroup.put('Form 2021 WebBank BLA (Daily)', 'Loan Agreement Daily');
        congaTemplateNameToGroup.put('Form 2021 WebBank BLA (Weekly Payments)', 'Loan Agreement Weekly');
        congaTemplateNameToGroup.put('Certification of Beneficial Owner Form', 'Loan Agreement Common');
        congaTemplateNameToGroup.put('Funds Release Refinance', 'Loan Agreement Renewal');
        congaTemplateNameToGroup.put('Third Party Funds Release Authorization', 'Loan Agreement Competitor');
        congaTemplateNameToGroup.put('Form 2021 SCHEDULE A to WebBank BLA (Daily)', 'Loan Agreement Concurrent Daily');
        congaTemplateNameToGroup.put('Form 2021 SCHEDULE A to WebBank BLA (Weekly)', 'Loan Agreement Concurrent Weekly');
        congaTemplateNameToGroup.put('Certification of Principals and Training Designation Form', 'OpportunityBroker');
        congaTemplateNameToGroup.put('CAN Capital Sales Partner Training', 'OpportunityBroker');
        congaTemplateNameToGroup.put('CAN Capital Referral Agrmnt_MCA-LOAN_NO-NON-COMPETE', 'OpportunityBroker');
        congaTemplateNameToGroup.put('CAN Capital Referral Agrmnt_MCA-LOAN', 'OpportunityBroker');
        congaTemplateNameToGroup.put('ACH Direct Deposit Form', 'OpportunityBroker');
        congaTemplateNameToGroup.put('Program Document', 'OpportunityBroker');
        congaTemplateNameToGroup.put('CL Collections - Accommodation Agreement', 'Collections');
        congaTemplateNameToGroup.put('CL Collections - Assumption of Loan Agreement', 'Collections');
        congaTemplateNameToGroup.put('CL Collections - Settlement Agreement', 'Collections');
        congaTemplateNameToGroup.put('CL Collections - Subordination Agreement_Loan', 'Collections');
        congaTemplateNameToGroup.put('Collections - Accommodation Agreement', 'Collections');
        congaTemplateNameToGroup.put('Collections - PromiseToPay Non ACH', 'Collections');
        congaTemplateNameToGroup.put('Collections - Settlement Agreement', 'Collections');
        congaTemplateNameToGroup.put('PrePayment And Discount Agreement', 'PrePayment');

        Map<String, APXTConga4__Conga_Template__c> congaTemplateMap = new Map<String, APXTConga4__Conga_Template__c>();
        List<APXTConga4__Conga_Template__c> existingCongaTemplates = [
            SELECT Id, APXTConga4__Name__c, APXTConga4__Template_Group__c, APXTConga4__Template_Type__c
            FROM APXTConga4__Conga_Template__c
            WHERE APXTConga4__Name__c
            IN :congaTemplateNameToGroup.keySet()
        ];

        for(APXTConga4__Conga_Template__c congaTemplate : existingCongaTemplates) {
            congaTemplateMap.put(congaTemplate.APXTConga4__Name__c, congaTemplate);
        }

        List<APXTConga4__Conga_Template__c> congaTemplateList = new List<APXTConga4__Conga_Template__c>();
        for(String congaTemplateName : congaTemplateNameToGroup.keySet()) {
            APXTConga4__Conga_Template__c congaTemplate = new APXTConga4__Conga_Template__c();
            if(congaTemplateMap.containsKey(congaTemplateName)) {
                congaTemplate = congaTemplateMap.get(congaTemplateName);
            }
            congaTemplate.APXTConga4__Name__c = congaTemplateName;
            congaTemplate.APXTConga4__Template_Group__c = congaTemplateNameToGroup.get(congaTemplateName);
            congaTemplate.APXTConga4__Template_Type__c = 'Document';
            congaTemplateList.add(congaTemplate);
        }

        if(!congaTemplateList.isEmpty()) {
            upsert congaTemplateList;
        }
    }

    public static void createCongaMergeQuery() {
        delete [SELECT Id FROM APXTConga4__Conga_Merge_Query__c];
        Map<string,String> mapQueries   = new Map<string,String>();
        mapQueries.put('Loan Agreement-A Application',
            'SELECT Primary_Guarantor__r.Name,'
                + ' Primary_Guarantor__r.Title__c,'
                + ' Primary_Guarantor__r.MailingBuildingNumber__c,'
                + ' Primary_Guarantor__r.MailingStreet,'
                + ' Primary_Guarantor__r.MailingCity,'
                + ' Primary_Guarantor__r.MailingState,'
                + ' Primary_Guarantor__r.MailingPostalCode,'
                + ' Primary_Guarantor__r.Email,'
                + ' Primary_Guarantor__r.MobilePhone,'
                + ' genesis__Account__r.id,'
                + ' genesis__Account__r.Name,'
                + ' genesis__Account__r.Merchant_ID__c,'
                + ' genesis__Account__r.Legal_Name__c,'
                + ' genesis__Account__r.State_of_Incorporation_Organization__c,'
                + ' genesis__Account__r.BillingBuildingNumber__c,'
                + ' genesis__Account__r.BillingStreet,'
                + ' genesis__Account__r.BillingCity,'
                + ' genesis__Account__r.BillingState,'
                + ' genesis__Account__r.BillingPostalCode,'
                + ' genesis__Account__r.Doing_Business_As_Name__c,'
                + ' genesis__Account__r.Business_Tax_ID__c'
         + ' FROM genesis__Applications__c WHERE Id = \'{pv0}\'');
        mapQueries.put('Loan Agreement-B Pricing Details',
            'SELECT Selected_Amount__c,'
                + ' Daily_Payment_Amount__c,'
                + ' Weekly_Payment_Amount__c,'
                + ' Number_Of_Daily_Payments__c,'
                + ' Number_Of_Weekly_Payments__c'
          + ' FROM CAN_Pricing_Detail__c WHERE Status__c = \'Accepted\' AND Application__c = \'{pv0}\' ORDER BY LastModifiedDate DESC LIMIT 1');
        mapQueries.put('Loan Agreement-C Parties',
            'SELECT clcommon__Contact__r.Name, clcommon__Contact__r.Title__c'
          + ' FROM clcommon__Party__c WHERE clcommon__Type__r.Name = \'GUARANTOR\' AND clcommon__isPrimary__c = false AND genesis__Application__c = \'{pv0}\'');
        mapQueries.put('Loan Agreement-D Competitors',
            'SELECT clcommon__Account__r.Name, Competitor_Bank_Account_Name__c, Competitor_Bank_Routing_Number__c,'
          +  'Competitor_Bank_Account_Number__c, Competitor_Amount__c, clcommon__Contact__r.Name, clcommon__Contact__r.Title__c'
          + ' FROM clcommon__Party__c WHERE clcommon__Type__r.Name = \'COMPETITOR\' AND genesis__Application__c = \'{pv0}\'');
        mapQueries.put('Loan Agreement-E Beneficial Owner',
          'SELECT clcommon__Contact__r.Name, clcommon__Contact__r.Birthdate, clcommon__Contact__r.MailingBuildingNumber__c, clcommon__Contact__r.MailingStreet,'
          + ' clcommon__Contact__r.MailingCity, clcommon__Contact__r.MailingState, clcommon__Contact__r.MailingPostalCode,'
          + ' clcommon__Contact__r.genesis__SSN__c, clcommon__Contact__r.Other_Identification_Number__c, clcommon__Contact__r.Country_Of_Issuance__c'
          + ' FROM clcommon__Party__c WHERE (Beneficial_Owner_Type__c = \'Beneficial Owner\' OR Beneficial_Owner_Type__c = \'Both\') AND genesis__Application__c = \'{pv0}\'');
          mapQueries.put('Loan Agreement-F Control Person',
          'SELECT clcommon__Contact__r.Name, clcommon__Contact__r.Birthdate, clcommon__Contact__r.MailingBuildingNumber__c, clcommon__Contact__r.MailingStreet,'
          + ' clcommon__Contact__r.MailingCity, clcommon__Contact__r.MailingState, clcommon__Contact__r.MailingPostalCode,'
          + ' clcommon__Contact__r.genesis__SSN__c, clcommon__Contact__r.Other_Identification_Number__c, clcommon__Contact__r.Country_Of_Issuance__c'
          + ' FROM clcommon__Party__c WHERE (Beneficial_Owner_Type__c = \'Control Person\' OR Beneficial_Owner_Type__c = \'Both\') AND genesis__Application__c = \'{pv0}\'');
        mapQueries.put('Broker Agreement-A Opportunities',
            'SELECT Id, Name, Primary_Contact__r.Title__c, Primary_Contact__r.Name'
          + ' FROM Opportunity WHERE Id = \'{pv0}\'');
        mapQueries.put('Collection Agreement-A CL Contract',
            'SELECT Id, Name, loan__Loan_Amount__c, loan__Loan_Balance__c, Application__c, loan__Last_Disbursal_Date__c,'
          + 'loan__Last_Disbursal_Amount__c, Current_Payoff_Amount__c, loan__Pmt_Amt_Cur__c,'
          + 'Total_Unpaid_Due_Amount_To_Current__c, loan__Payment_Amount__c, loan__Principal_Remaining__c, loan__Account__c,'
          + 'loan__Account__r.Name, loan__Account__r.Billingaddress, loan__Account__r.Doing_Business_As_Name__c,'
          + 'loan__Account__r.BillingStreet, loan__Account__r.BillingCity, loan__Account__r.BillingState,'
          + 'loan__Account__r.BillingPostalCode, loan__Account__r.BillingCountry, Outstanding_Repayment_Amount__c,'
          + 'loan__Account__r.State_of_Incorporation_Organization__c, Primary_Contact__c, Primary_Contact__r.Name,'
          + 'Primary_Contact__r.genesis__SSN__c, Primary_Contact__r.Title__c'
          + ' FROM loan__Loan_Account__c WHERE Id = \'{pv0}\'');
        mapQueries.put('Prepayment Discount Agreement CL Contract',
          'SELECT Id, Name, loan__Account__r.Name, loan__Account__r.Doing_Business_As_Name__c, loan__Account__r.Merchant_ID__c, loan__Account__r.Legal_Name__c'
          + ' FROM loan__Loan_Account__c WHERE Id = \'{pv0}\'');
        mapQueries.put('Collection Agreement-A Collection Case',
            'SELECT Id, Name, Collection_Case__c, Collection_Case__r.Bank_Account__c, Collection_Case__r.Contact__c,'
          + 'Collection_Case__r.Contact__r.genesis__SSN__c, Collection_Case__r.Contact__r.Title__c,'
          + 'Collection_Case__r.Account__c, Collection_Case__r.Account__r.State_of_Incorporation_Organization__c,'
          + 'Collection_Case__r.No_missed_payments__c, Collection_Case__r.Contact__r.Name,'
          + 'Collection_Case__r.Account__r.Name, Collection_Case__r.Account__r.Doing_Business_As_Name__c,'
          + 'Collection_Case__r.Account__r.BillingState, Collection_Case__r.Loan_Amount__c,'
          + 'Collection_Case__r.Account__r.BillingBuildingNumber__c, Collection_Case__r.Account__r.BillingStreet,'
          + 'Collection_Case__r.Account__r.BillingCity, Collection_Case__r.Last_Disbursal_Amount__c,'
          + 'Collection_Case__r.Account__r.BillingPostalCode, Collection_Case__r.Account__r.BillingCountry,'
          + 'Collection_Case__r.Total_Unpaid_Due_Amount_To_Current__c, Collection_Case__r.Current_Payoff_Amount__c,'
          + 'Collection_Case__r.Loan_Balance__c, Collection_Case__r.Last_Disbursal_Date__c,'
          + 'Collection_Case__r.Pmt_Amt_Cur__c, Collection_Case__r.Payment_Amount__c, Collection_Case__r.Principal_Remaining__c,'
          + 'Collection_Case__r.Delinquent_amount__c, Collection_Case__r.Contract_Number__c,'
          + 'Collection_Case__r.Total_Outstanding_Repayment_Amount__c,'
          + 'Collection_Case__r.Previous_Installment_Date__c'
          + ' FROM Payment_Arrangements__c WHERE Id = \'{pv0}\'');

        List<APXTConga4__Conga_Merge_Query__c> congaMergeQueryList = new List<APXTConga4__Conga_Merge_Query__c>();

        for(String key :mapQueries.keySet()){
            APXTConga4__Conga_Merge_Query__c congaMergeQuery = new APXTConga4__Conga_Merge_Query__c();
            congaMergeQuery.APXTConga4__Name__c = key;
            congaMergeQuery.APXTConga4__Query__c = mapQueries.get(key);
            congaMergeQueryList.add(congaMergeQuery);
        }
        insert congaMergeQueryList;
    }

    public static void createCommissionPlan() {
        List<loan__Commission_Plan__c> commissionPlanList = [SELECT Id FROM loan__Commission_Plan__c LIMIT 1];

        loan__Commission_Plan__c commissionPlan;
        if(commissionPlanList.isEmpty()) {
            commissionPlan = new loan__Commission_Plan__c();
        } else {
            commissionPlan = commissionPlanList.get(0);
        }
        commissionPlan.loan__Factor__c = 100;
        commissionPlan.loan__Maximum_Commission_Percentage__c = 100;
        commissionPlan.loan__Plan_Description__c = 'Broker Commission';
        commissionPlan.loan__Calculation_Method__c = 'Flat Amount';
        commissionPlan.loan__Commission_Disbursement_Method__c = 'Upfront';
        commissionPlan.loan__Buy_Rate__c = 0;
        commissionPlan.loan__Upfront_Percentage__c = 0;
        commissionPlan.loan__Enabled__c = true;
        commissionPlan.loan__Flat_Amount__c = 0;

        upsert commissionPlan;
    }

    public static void setupCustomSettings() {
        genesis__Org_Parameters__c genesisOrgParameter = genesis__Org_Parameters__c.getOrgDefaults();
        genesisOrgParameter.genesis__Use_Contact_as_Account__c = false;
        genesisOrgParameter.CLX_BrokerPortal_ApplicationBanner__c = true;
        genesisOrgParameter.CLX_Application_Summary_And_Notes_Widget__c = false;
        genesisOrgParameter.CLX_Onboarding_Portal_Secured_Loan__c = true;
        genesisOrgParameter.CLX_BrokerPortal_ApplicationWidget__c = true;
        genesisOrgParameter.CLX_Onboarding_Portal_Add_Co_Borrower__c = true;
        genesisOrgParameter.CLX_BrokerPortal_TaskWidget__c = true;
        genesisOrgParameter.CLX_BrokerPortal_Notification_Banner__c = true;
        genesisOrgParameter.CLX_Onboarding_Portal_Flow__c = 'SMB';
        genesisOrgParameter.genesis__Skip_Holidays__c = true;
        upsert genesisOrgParameter;

        genesis__Custom_Logic_Parameters__c genesisCustomLogic = genesis__Custom_Logic_Parameters__c.getOrgDefaults();
        genesisCustomLogic.genesis__Custom_Contract_Generation_Class__c = 'loan.ContractProcessor';
        upsert genesisCustomLogic;

        loan__Org_Parameters__c loanOrgParameter = loan__Org_Parameters__c.getOrgDefaults();
        loanOrgParameter.loan__Enable_Fractionalization__c = true;
        loanOrgParameter.loan__Skip_Holidays__c = true;
        loanOrgParameter.loan__Batch_size_for_daily_jobs__c = 20;
        loanOrgParameter.loan__Final_Payment_Differ__c = false;
        loanOrgParameter.loan__Adjust_Rounding_in_last_Payment__c = false;
        upsert loanOrgParameter;

        loan__ACH_Parameters__c loanACHParameter = loan__ACH_Parameters__c.getOrgDefaults();
        loanACHParameter.loan__Days_In_Advance_To_Create_File__c = 0;
        loanACHParameter.loan__Organization_Name__c = 'CAN Capital';
        loanACHParameter.loan__ACH_Id__c = 'ach987';
        loanACHParameter.loan__Fed_Tax_Id__c = '453878221';
        loanACHParameter.loan__ACH_File_Type__c = 'TEXT';
        loanACHParameter.loan__Folder_Name__c = 'ACH';
        loanACHParameter.loan__Multiple_Payment_Method_Support__c = true;
        loanACHParameter.loan__Use_Lock_Based_ACH__c = true;
        loanACHParameter.loan__Merge_One_Time_and_Recurring_ACH__c = true;
        upsert loanACHParameter;

        Map<String,Id> congaMergeQueryMap = new Map<String,Id>();
        CAN_Conga_Settings__c canCongaSettings = CAN_Conga_Settings__c.getOrgDefaults();
        List<APXTConga4__Conga_Merge_Query__c> congaMergeQueryList = [SELECT Id, APXTConga4__Name__c FROM APXTConga4__Conga_Merge_Query__c];
        for (APXTConga4__Conga_Merge_Query__c congaMergeQuery : congaMergeQueryList) {
            congaMergeQueryMap.put(congaMergeQuery.APXTConga4__Name__c, congaMergeQuery.Id);
        }
        canCongaSettings.Opportunity_Query__c = congaMergeQueryMap.get('Broker Agreement-A Opportunities');
        canCongaSettings.CL_Contract_Query__c = congaMergeQueryMap.get('Collection Agreement-A CL Contract');
        canCongaSettings.Collection_Case_Query__c = congaMergeQueryMap.get('Collection Agreement-A Collection Case');
        canCongaSettings.Prepayment_CL_Contract__c = congaMergeQueryMap.get('Prepayment Discount Agreement CL Contract');
        canCongaSettings.Conga_Generic_BLA_Parameter__c = '&DS2=1&DS3=1&DS4=1&DS5=1&DS6=1&DS8=0&DS9=1&DS10=1&FP0=1&DefaultLocal=0';
        canCongaSettings.Conga_Sign_BLA_Subject__c = 'You’re almost there! Sign your Business Loan Agreement ASAP to finalize your Working Capital Loan!';
        canCongaSettings.Concurrent_Conga_Expire_Time__c = canCongaSettings.Concurrent_Conga_Expire_Time__c == null? 17 : canCongaSettings.Concurrent_Conga_Expire_Time__c;
        upsert canCongaSettings;

        CAN_General_Settings__c canGeneralSettings = CAN_General_Settings__c.getOrgDefaults();
        canGeneralSettings.Default_Investor_Account_Id__c = createDefaultInvestor();
        canGeneralSettings.Apply_Florida_Fee_for_Concurrent__c = true;
        canGeneralSettings.Apply_Florida_Fee_for_New__c = true;
        canGeneralSettings.Apply_Florida_Fee_for_Renewal__c = true;
        canGeneralSettings.Concurrent_Eligible_Days__c = canGeneralSettings.Concurrent_Eligible_Days__c == null? 90 : canGeneralSettings.Concurrent_Eligible_Days__c;
        canGeneralSettings.APS_Amount_Type__c = 'LAST BILLED AMOUNT';
        canGeneralSettings.CAN_Exclusivity_Period__c = canGeneralSettings.CAN_Exclusivity_Period__c == null? 90 : canGeneralSettings.CAN_Exclusivity_Period__c;
        canGeneralSettings.Disable_AAN__c = true;
        canGeneralSettings.FICO_Auto_Accept_Excptn_Eligible__c = canGeneralSettings.FICO_Auto_Accept_Excptn_Eligible__c == null? 675 : canGeneralSettings.FICO_Auto_Accept_Excptn_Eligible__c;
        canGeneralSettings.Late_fee_job_time__c = '21:0:0';
        canGeneralSettings.Write_Off_Suggestion_Days__c = canGeneralSettings.Write_Off_Suggestion_Days__c == null ? 900 : canGeneralSettings.Write_Off_Suggestion_Days__c;
        canGeneralSettings.Policy_Cap__c = 99.99;
        canGeneralSettings.UCC_Continuation_Days__c = 21;
        canGeneralSettings.UCC_Filing_Eligible_Amount__c = 50000;
        canGeneralSettings.CAN_Renewal_expiration_days_after_payoff__c = canGeneralSettings.CAN_Renewal_expiration_days_after_payoff__c == null ? 10 : canGeneralSettings.CAN_Renewal_expiration_days_after_payoff__c;
        canGeneralSettings.Renewal_Eligible_Days__c = canGeneralSettings.Renewal_Eligible_Days__c == null ? 60 : canGeneralSettings.Renewal_Eligible_Days__c;
        canGeneralSettings.Clawback_Eligible_Days_Daily__c = 30;
        canGeneralSettings.Clawback_Eligible_Days_Weekly__c = 45;
        upsert canGeneralSettings;
    }

    private static Id createDefaultInvestor() {
        Set<String> investorAccountNames = new Set<String>{'Web Bank', 'CAN Capital'};
        List<Account> accountList = [SELECT Id, Name FROM Account WHERE Name IN :investorAccountNames];
        Map<String, Account> investorAccountMap = new Map<String, Account>();
        for(Account investorAccount :accountList) {
            investorAccountMap.put(investorAccount.Name, investorAccount);
        }
        List<Account> accountsForBankAccount = new List<Account>();
        for(String investorAccountName :investorAccountNames) {
            Account investorAccount = new Account();
            if(investorAccountMap.containsKey(investorAccountName)) {
                investorAccount = investorAccountMap.get(investorAccountName);
            } else {
                investorAccount.Name = investorAccountName;
                investorAccount.Type = 'Investor';
                investorAccount.loan__Investor__c = true;
                investorAccount.peer__Investor_Status__c = 'Verified';
                investorAccount.loan__Undeployed_Funds__c = 9999999999999999.00;
                investorAccount.loan__Service_Rate_On_Investment__c = 0;
                investorAccount.loan__Collect_Service_Fees_on__c = 'No Fees';
                investorAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(investorAccount.Type.toUpperCase()).getRecordTypeId();
                accountsForBankAccount.add(investorAccount);
            }
            investorAccountMap.put(investorAccount.Name, investorAccount);
        }

        if(!accountsForBankAccount.isEmpty()) {
            insert accountsForBankAccount;
            createBankAccount(accountsForBankAccount);
        }

        return investorAccountMap.get('Web Bank').Id;
    }

    private static void createBankAccount(List<Account> accountList) {
        List<loan__Bank_Account__c> bankAccountList = new List<loan__Bank_Account__c>();
        for(Account account : accountList) {
            loan__Bank_Account__c bankAccount = new loan__Bank_Account__c();
            bankAccount.loan__Account__c = account.Id;
            bankAccount.loan__Account_Type__c = 'Checking';
            bankAccount.loan__Bank_Account_Number__c = '2000039538172';
            bankAccount.loan__Bank_Name__c = 'Wells Fargo';
            bankAccount.loan__Routing_Number__c = '121000248';
            bankAccount.loan__Active__c = true;
            bankAccount.loan__Account_Usage__c = 'Investor Trust Account; Collections Trust Account; Advance Trust Account; Business Account';
            bankAccountList.add(bankAccount);
        }

        if(!bankAccountList.isEmpty()) { insert bankAccountList; }
    }
}