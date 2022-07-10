@isTest(isParallel=true)
public class TestUtility {
    public static Date currentSystemDate = Date.newInstance(2020, 1, 1);
    public static final String COMPANY_NAME = 'CAN Capital';
    public static Map<String, Integer> sObjectNameToRecordCountMap = new Map<String, Integer>();
    public static clcommon__CL_Product__c clProduct;
    public static loan__Loan_Product__c loanProduct;
    public static loan__Office_Name__c loanOffice;

    public static String generateFakeName() {
        String getAPIName = 'FAKE_NAME';
        Integer recordCount = 50;
        if (sObjectNameToRecordCountMap.containsKey(getAPIName)) {
            recordCount = sObjectNameToRecordCountMap.get(getAPIName);
        }
        recordCount++;
        sObjectNameToRecordCountMap.put(getAPIName, recordCount);

        String hashString = recordCount + '' + DateTime.now() + DateTime.now().millisecond();
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));

        return 'FAKE' + EncodingUtil.convertToHex(hash);
    }

    public static void assertNullException(Exception ex) {
        System.assertEquals(
        null,
        ex,
        (ex != null)
            ? ex.getMessage() + ' ' + Ex.getStackTraceString()
            : 'Null Exception'
        );
    }

    public static void assertException(Exception ex) {
        System.assertNotEquals(null, ex);
    }

    public static String getFakeId(Schema.SObjectType sot) {
        String getAPIName = sot.getDescribe().getName();
        Integer recordCount = 50;
        if (sObjectNameToRecordCountMap.containsKey(getAPIName)) {
            recordCount = sObjectNameToRecordCountMap.get(getAPIName);
        }
        recordCount++;
        sObjectNameToRecordCountMap.put(getAPIName, recordCount);

        String result = String.valueOf(recordCount++);
        String prefix;
        if (getAPIName == 'Knowledge__DataCategorySelection') {
            prefix = '02o290';
        } else {
            prefix = sot.getDescribe().getKeyPrefix();
        }
        return prefix + '0'.repeat(12 - result.length()) + result;
    }

    public static Contact generateBorrowerContact() {
        Account guarantorAccount = new Account();
        guarantorAccount.Name = 'guarantor Acc';
        insert guarantorAccount;
        Contact contactRec = new Contact();
        contactRec.FirstName = 'Borrower Contact';
        contactRec.LastName = 'Test Borrower';
        contactRec.Contact_Type__c = 'Borrower';
        contactRec.AccountId = guarantorAccount.Id;
        contactRec.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(contactRec.Contact_Type__c.toUpperCase()).getRecordTypeId();
        insert contactRec;
        return contactRec;
    }

    public static Contact generateContact() {
        Contact contactRecord = new Contact();
        contactRecord.FirstName = 'Test First';
        contactRecord.LastName = 'TestC' + generateFakeName();
        contactRecord.Contact_Type__c = 'Guarantor';
        contactRecord.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(contactRecord.Contact_Type__c.toUpperCase()).getRecordTypeId();
        return contactRecord;
    }

    public static void runSetupData() {
        loan.TestHelper.systemDate = currentSystemDate;
        loan.testHelper.createSeedDataForTesting();
        List<loan__ACH_Parameters__c> achParameters = [
            SELECT Id
            FROM loan__ACH_Parameters__c
        ];
        if (achParameters.isEmpty()) {
            insert generateACHParameters();
        }
        loan.testHelper2.createFileGenMetadata();
        loanOffice = createLoanOfficeName();
        clProduct = createCLProduct();
        loanProduct = createLoanProduct();

        CreatePostSandboxSetupData.setupCustomSettings();
        CreatePostSandboxSetupData.createLegalEntity();
    }

    public static loan__ACH_Parameters__c generateACHParameters() {
        loan__ACH_Parameters__c achParameter = new loan__ACH_Parameters__c();
        achParameter.loan__Days_In_Advance_To_Create_File__c = 1;
        achParameter.loan__Multiple_Payment_Method_Support__c = true;
        achParameter.loan__ACH_Return_Filegen__c = 'CustomACHReturnFileParser';
        achParameter.loan__Debit_Payment_on_Previous_Working_Day__c = true;
        achParameter.loan__Loan_Payment_Creation_Job_Batch_Size__c = 50;
        achParameter.loan__Lock_Period_for_Loan_Payments__c = 1;
        achParameter.loan__Merge_One_Time_and_Recurring_ACH__c = true;
        achParameter.loan__Organization_Name__c = GeneralConstants.COMPANY_NAME;
        achParameter.loan__Use_Lock_Based_ACH__c = false;
        return achParameter;
    }

    public static loan__Bank_Account__c createBankAccount() {
        Contact borrowerContact = createBankContact();
        Account borrowerAccount = createAccount();

        loan__Bank_Account__c bankAccount = generateBankAccount(
            borrowerContact.Id, borrowerAccount.Id
        );
        insert bankAccount;

        return bankAccount;
    }

    public static loan__Bank_Account__c generateBankAccount(
        Id contactId, Id accountId
    ) {
        loan__Bank_Account__c bankAccount = new loan__Bank_Account__c();
        bankAccount.loan__Account__c = accountId;
        bankAccount.loan__Account_Type__c = 'Saving';
        bankAccount.loan__Bank_Account_Number__c = '1234567890';
        bankAccount.verify_bank_account_number__c = bankAccount.loan__Bank_Account_Number__c;
        bankAccount.loan__Bank_Name__c = 'CAN Capital';
        bankAccount.loan__Contact__c = contactId;
        bankAccount.loan__Routing_Number__c = '123456789';
        return bankAccount;
    }

    public static genesis__Applications__c createApplication() {
        Opportunity newOpportunity = createOpportunity();

        genesis__Applications__c application = generateApplication(
            clProduct.Id, newOpportunity.Primary_Contact__c, newOpportunity.AccountId, newOpportunity.Id
        );
        insert application;

        return application;
    }

    public static Lead createLead() {
        Lead leadRecord = generateLead();
        insert leadRecord;
        return leadRecord;
    }

    public static contact createBrokerContact() {
        Account brokerAccount = new Account();
        brokerAccount.Name = 'Lead Broker';
        brokerAccount.Type = Leads.BROKER;
        brokerAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(brokerAccount.Type.toUpperCase()).getRecordTypeId();
        insert brokerAccount;
        Contact contactRecord = new Contact();
        contactRecord.FirstName = 'Broker';
        contactRecord.LastName = 'Test Broker';
        contactRecord.AccountId = brokerAccount.Id;
        contactRecord.Contact_Type__c = 'Broker';
        contactRecord.loan__Contact_Type__c = GeneralConstants.PARTY_TYPE_BROKER;
        contactRecord.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(contactRecord.Contact_Type__c.toUpperCase()).getRecordTypeId();
        insert contactRecord;
        return contactRecord;
    }

    public static contact createContact() {
        Contact contactRecord = generateContact();
        insert contactRecord;
        return contactRecord;
    }

    public static Contact createBankContact () {
        Contact contactRecord = new Contact();
        contactRecord.FirstName = 'Bank';
        contactRecord.LastName = 'Test Bank';
        contactRecord.Contact_Type__c = 'Guarantor';
        contactRecord.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(contactRecord.Contact_Type__c.toUpperCase()).getRecordTypeId();
        insert contactRecord;
        return contactRecord;
    }

    public static Account createBorrowerAccount() {
        Account accountRecord = new Account();
        accountRecord.Name = 'Borrower Account Test';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '975876024';
        accountRecord.Biz_Start_Date__c = currentSystemDate.addYears(-10);
        accountRecord.Type = 'Borrower';
        accountRecord.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(accountRecord.Type.toUpperCase()).getRecordTypeId();
        insert accountRecord;
        return accountRecord;
    }

    public static Account createOppAccount() {
        Contact brokerContact = createBrokerContact();
        Account accountRecord = new Account();
        accountRecord.Name = 'Opp Account Test';
        accountRecord.Broker_Account__c = brokerContact.AccountId;
        accountRecord.Broker_Contact__c = brokerContact.Id;
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '075898984';
        accountRecord.Biz_Start_Date__c = currentSystemDate.addYears(-10);
        accountRecord.Type = 'Borrower';
        accountRecord.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(accountRecord.Type.toUpperCase()).getRecordTypeId();
        insert accountRecord;
        return accountRecord;
    }

    public static Account createAccount() {
        Account accountRecord = generateAccount();
        insert accountRecord;
        return accountRecord;
    }

    public static Account createGuarantorAccount() {
        Account accountRecord = new Account();
        accountRecord.Name = 'Guarantor Account Test';
        accountRecord.Type = 'Guarantor';
        accountRecord.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(accountRecord.Type.toUpperCase()).getRecordTypeId();
        insert accountRecord;
        return accountRecord;
    }

    public static Lead generateLead() {
        Lead leadRecord = new Lead();
        leadRecord.LastName = generateFakeName();
        leadRecord.Company = 'Test Company';
        leadRecord.LeadSource = 'Merchant Phone';
        return leadRecord;
    }

    public static Map<String, String> getLeadMap()
    {
        Map<String, String> leadMap = new Map<String, String>();
        leadMap.put('LastName','Test Lead');
        leadMap.put('Company','Test Company');
        leadMap.put('Email','TestCompany@example.com');
        leadMap.put('Biz_Structure__c','Partnership');
        leadMap.put('MobilePhone','9973337738');
        leadMap.put('Tax_ID__c','87873');
        leadMap.put('Title__c','CEO');
        leadMap.put('Biz_Start_Date__c', '2016-10-10');
        leadMap.put('DOB__c', '1986-10-10');
        leadMap.put('Title','CEO');
        leadMap.put('Industry','Business Services');
        leadMap.put('Country','United States');
        leadMap.put('How_much_do_you_Need__c','5000');
        return leadMap;
    }

    public static Account generateAccount() {
        Account accountRecord = new Account();
        accountRecord.Name = generateFakeName();
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = currentSystemDate.addYears(-10);
        accountRecord.Type = Accounts.GUARANTOR;
        accountRecord.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(accountRecord.Type.toUpperCase()).getRecordTypeId();
        return accountRecord;
    }

    public static Opportunity createOpportunity() {
        Account borrowerAccount = createOppAccount();

        Account guarantorAccount = new Account();
        guarantorAccount.Name = 'Contact Opp Test Opp Contact';
        guarantorAccount.clcommon__Legal_Entity_type__c = OriginationHelper.legalNameToId.get(GeneralConstants.LEGAL_TYPE_INDIVIDUAL);
        guarantorAccount.Type = 'Guarantor';
        insert guarantorAccount;

        Contact guarantorContact = new Contact();
        guarantorContact.FirstName = 'Contact Opp';
        guarantorContact.LastName = 'Test Opp Contact';
        guarantorContact.Contact_Type__c = GeneralConstants.PARTY_TYPE_GUARANTOR;
        guarantorContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(guarantorContact.Contact_Type__c.toUpperCase()).getRecordTypeId();
        guarantorContact.AccountId = guarantorAccount.Id;
        insert guarantorContact;

        Opportunity newOpportunity = generateOpportunity(guarantorContact.Id, borrowerAccount.Id);
        insert newOpportunity;

        return newOpportunity;
    }

    public static Opportunity generateOpportunity(
        Id contactId, Id accountId
    ) {
        Opportunity bankAccount = new Opportunity();
        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Name = 'Test Opportunity';
        opportunityRecord.AccountId = accountId;
        opportunityRecord.Primary_Contact__c = contactId;
        opportunityRecord.StageName = 'App Submitted';
        opportunityRecord.Sub_Status__c = 'Score Pending';
        opportunityRecord.CloseDate = System.today().addMonths(2).addDays(19);
        return opportunityRecord;
    }

    public static genesis__Applications__c generateApplication(
        Id productId, Id contactId, Id accountId, Id opportunityId
    ) {
        Id recordTypeId = Schema.SObjectType.genesis__Applications__c.getRecordTypeInfosByName().get('Loan').getRecordTypeId();

        genesis__Applications__c application = new genesis__Applications__c();
        application.RecordTypeId = recordTypeId;
        application.genesis__Collateral_Value__c = 6700;
        application.genesis__Customer_Cash_Available__c = 1500;
        application.genesis__Days_Convention__c = '30/360';
        application.genesis__Estimated_Selling_Price__c = 6700;
        application.genesis__Expected_Close_Date__c = currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = currentSystemDate.addMonths(12);
        application.genesis__Fees_Amount__c = 0;
        application.genesis__Financed_Amount__c = 10000;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Landing_Sequence__c = 3;
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Other_Financed_fees__c = 0;
        application.genesis__Payment_Frequency__c = 'WEEKLY';
        application.genesis__Product_Type__c = 'LOAN';
        application.genesis__Sales_Division__c = 'DIRECT';
        application.genesis__Status__c = Applications.STATUS_NEW_ENTERED;
        application.genesis__Tax_Amount__c = 0;
        application.genesis__Term__c = 12;
        application.genesis__Warranty_Amount__c = 0;
        application.SIC_Code__c = '073';
        application.genesis__CL_Product__c = productId;
        application.Primary_Guarantor__c = contactId;
        application.genesis__Account__c = accountId;
        application.Maximum_Funding_Amount__c = 12000;
        application.Opportunity__c = opportunityId;
        application.Partner_Pricing_Secure_Link__c = 'www.example.com';

        return application;
    }

    public static loan__Loan_Account__c createContract() {
        genesis__Applications__c application = createApplication();
        loan__Bank_Account__c bankAccount = createBankAccount();

        loan__Loan_Account__c contract = generateContract(
            application,
            loanProduct,
            bankAccount
        );
        contract.loan__Branch__c = loanOffice.Id;
        contract.loan__Fee_Set__c = createFeeSet().Id;
        contract.loan__Loan_Purpose__c = createLoanPurpose().Id;
        insert contract;

        return contract;
    }

    public static loan__Loan_Disbursal_Transaction__c createLoanDisbursalTransaction() {
        loan__Loan_Account__c contract = createContract();
        loan__Payment_Mode__c paymentMode = createPaymentMode('ACH');

        loan__Loan_Disbursal_Transaction__c disbursalTransaction = generateLoanDisbursalTransaction(
            contract, paymentMode.Id, currentSystemDate
        );
        insert disbursalTransaction;

        return disbursalTransaction;
    }


    public static loan__Loan_Disbursal_Transaction__c generateLoanDisbursalTransaction(
        loan__Loan_Account__c loanAccount, Id paymentModeId, Date disbursalDate
    ) {
        loan__Loan_Disbursal_Transaction__c disbursalTransaction = new loan__Loan_Disbursal_Transaction__c();
        disbursalTransaction.loan__Disbursal_Date__c = disbursalDate;
        disbursalTransaction.loan__Disbursed_Amt__c = loanAccount.loan__Loan_Amount__c;
        disbursalTransaction.loan__Loan_Account__c = loanAccount.Id;
        disbursalTransaction.loan__Mode_of_Payment__c = paymentModeId;
        return disbursalTransaction;
    }


    public static loan__Loan_Account__c generateContract(
        genesis__Applications__c application,
        loan__Loan_Product__c loanProduct,
        loan__Bank_Account__c bankAccount
    ) {
        Id recordTypeId = Schema.SObjectType.loan__Loan_Account__c.getRecordTypeInfosByName().get('Loan').getRecordTypeId();

        loan__Loan_Account__c contract = new loan__Loan_Account__c();
        contract.RecordTypeId = recordTypeId;
        contract.loan__Loan_Product_Name__c = loanProduct.Id;
        contract.loan__Account__c = application.genesis__Account__c;
        contract.Application__c = application.Id;
        contract.loan__Loan_Amount__c = 10000;
        contract.loan__Principal_Remaining__c = 10000;
        contract.loan__Payment_Amount__c = 860.52;
        contract.loan__Pmt_Amt_Cur__c = 860.52;
        contract.loan__Loan_Status__c = 'Approved';
        contract.loan__First_Installment_Date__c = currentSystemDate.addMonths(1);
        contract.loan__Expected_Repayment_Start_Date__c = currentSystemDate.addMonths(1);
        contract.loan__Expected_Disbursal_Date__c = currentSystemDate;
        contract.loan__Last_Accrual_Date__c = currentSystemDate;
        contract.loan__Accrue_Past_Maturity__c = true;
        contract.loan__Contractual_Interest_Rate__c = 6;
        contract.loan__Disbursal_Amount__c = 10000;
        contract.loan__Interest_estimated__c = 326.26;
        contract.loan__Interest_Only_Period__c = 0;
        contract.loan__Interest_Rate__c = 6;
        contract.loan__Last_Installment_Date__c = currentSystemDate.addYears(1);
        contract.loan__Maturity_Date_Current__c = currentSystemDate.addYears(1);
        contract.loan__Next_Installment_Date__c = currentSystemDate.addMonths(1);
        contract.loan__Number_of_Installments__c = 12;
        contract.loan__Oldest_Due_Date__c = currentSystemDate.addMonths(1);
        contract.loan__Overdue_Interest_Rate__c = 12;
        contract.loan__Term_Cur__c = 12;
        contract.Bank_Account__c = bankAccount.Id;
        contract.loan__Disbursal_Date__c = currentSystemDate;

        return contract;
    }

    public static loan__Loan_account_Due_Details__c generateLoanAccountDueDetail(
        Id loanAccountId, Decimal dueAmount, Date dueDate, Decimal paidPrincipal, Decimal paidInterest, Boolean paymentSatisfied
    ) {
        loan__Loan_account_Due_Details__c dueDetail = new loan__Loan_account_Due_Details__c();
        dueDetail.loan__Due_Amt__c = dueAmount;
        dueDetail.loan__Due_Date__c = dueDate;
        dueDetail.loan__Payment_Date__c = dueDate;
        dueDetail.loan__Transaction_Date__c = dueDate;
        dueDetail.loan__Transaction_Creation_Date__c = dueDate;
        dueDetail.loan__Principal_Billed__c = paidPrincipal;
        dueDetail.loan__Interest_Billed__c = paidInterest;
        dueDetail.loan__DD_Primary_Flag__c = true;
        dueDetail.loan__Payment_Satisfied__c = paymentSatisfied;
        return dueDetail;
    }

    public static loan__Loan_Payment_Transaction__c generateLoanPaymentTransaction(Id loanAccountId, Decimal amount, Id paymentModeId) {
        loan__Loan_Payment_Transaction__c loanPayment = new loan__Loan_Payment_Transaction__c();
        loanPayment.loan__Payment_Mode__c = paymentModeId;
        loanPayment.loan__Transaction_Amount__c = amount;
        loanPayment.loan__Transaction_Date__c = GeneralHelper.currentSystemDate.addDays(1);
        loanPayment.loan__Transaction_Time__c = System.now();
        loanPayment.loan__Loan_Account__c  = loanAccountId;
        loanPayment.loan__Skip_Validation__c = true;
        loanPayment.loan__Cleared__c = true;
        return loanPayment;
    }

    public static clcommon__CL_Product__c createCLProduct() {
        loan__Loan_Product__c loanProduct = createLoanProduct();

        clcommon__CL_Product__c product = generateCLProduct(loanProduct.Id);
        insert product;

        return product;
    }

    public static clcommon__CL_Product__c generateCLProduct(Id lendingProductId) {
        clcommon__CL_Product__c clProduct = new clcommon__CL_Product__c();
        clProduct.loan__Lending_Product__c = lendingProductId;
        clProduct.clcommon__Product_Name__c = 'Test';
        clProduct.clcommon__Class__c = 'Commercial';
        return clProduct;
    }

    public static loan__Loan_Product__c createLoanProduct() {
        List<loan__Loan_Product__c> clProductList = [
            SELECT
                Id,
                loan__Min_Interest_Rate__c,
                loan__Max_Interest_Rate__c,
                loan__Funding_in_Tranches__c,
                loan__Default_Number_of_Installments__c,
                loan__Frequency_of_Loan_Payment__c
            FROM loan__Loan_Product__c
            WHERE Name = :COMPANY_NAME
            LIMIT 1
        ];

        if (!clProductList.isEmpty()) {
            return clProductList[0];
        }

        loan__Office_Name__c loanOffice = createLoanOfficeName();

        assignUserBranch(UserInfo.getUserId(), loanOffice);

        String name = COMPANY_NAME;
        createFeeJunction();

        loan__Loan_Product__c loanProduct = loan.TestHelper.createLoanProduct(
            name,
            loanOffice,
            createMFAccount(),
            createCurrency(),
            createFeeSet()
        );
        loanProduct.loan__Default_Number_of_Installments__c=6;
        loanProduct.loan__Frequency_of_Loan_Payment__c = 'Daily';
        update loanProduct;

        return loanProduct;
    }

    public static void createOtherFees() {
        Set<String> feeNames = new Set<String> {'Origination Fee'};
        Map<String, loan__Fee__c> feeMap = new Map<String, loan__Fee__c>();
        for(loan__Fee__c fee : [SELECT Id, Name FROM loan__Fee__c WHERE Name IN : feeNames]) {
            feeMap.put(fee.Name, fee);
        }
        List<loan__Fee__c> feeList = new List<loan__Fee__c>();
        for(String feeName : feeNames)
        {
            if(!feeMap.containsKey(feeName)) {
                loan__Fee__c fee = new loan__Fee__c();
                fee.Name = feeName;
                fee.loan__Fee_Category__c = 'Loan';
                fee.loan__Time_of_charge__c = 'Other';
                fee.loan__Amount__c =  0.00;
                fee.loan__Fee_Calculation_Method__c = 'Fixed';
                feeList.add(fee);
            }
        }
        insert feeList;
    }

    public static void assignFeesToFeeSet(Id feeSetId) {
        delete [SELECT Id FROM loan__Fee_Junction__c];
        Set<String> feeNames = new Set<String>{'Late Fee', 'NSF Fee', 'Origination Fee'};
        List<loan__Fee_Junction__c> feeJunctionList = new List<loan__Fee_Junction__c>();
        for(loan__Fee__c fee : [SELECT Id FROM loan__Fee__c WHERE Name IN :feeNames]) {
            loan__Fee_Junction__c feeJunction = new loan__Fee_Junction__c();
            feeJunction.loan__Fee_Set__c = feeSetId;
            feeJunction.loan__Fee__c = fee.Id;
            feeJunctionList.add(feeJunction);
        }

        insert feeJunctionList;
    }

    public static loan__Office_Name__c createLoanOfficeName() {
        List<loan__Office_Name__c> offices = [
            SELECT Id, Name
            FROM loan__Office_Name__c
            WHERE Name = :GeneralConstants.COMPANY_NAME
            LIMIT 1
        ];
        if (!offices.isEmpty()) {
            return offices[0];
        }

        loan__MF_Account__c mfAccount = createMFAccount();
        RecordType rootBranch = [
            SELECT Id
            FROM RecordType
            WHERE
                DeveloperName = 'Root_Branch'
                AND SObjectType = 'loan__Office_Name__c'
            LIMIT 1
        ];

        loan__Office_Type__c officeType = new loan__Office_Type__c();
        officeType.Name = 'XXXBTForTest';
        officeType.loan__Office_Type_Short_Code__c = 'TestSC';
        insert officeType;

        loan__Office_Name__c office = generateLoanOfficeName(
            GeneralConstants.COMPANY_NAME,
            '1',
            mfAccount.Id,
            officeType.Id,
            rootBranch.Id,
            currentSystemDate
        );
        insert office;

        office.Name = GeneralConstants.COMPANY_NAME;
        update office;

        createDayProcess(office.Id);

        return office;
    }

    public static loan__Office_Name__c generateLoanOfficeName(
        String name, String shortName, Id mfAccountId, Id officeTypeId, Id recordTypeId, Date systemDate
    ) {
        loan__Office_Name__c office = new loan__Office_Name__c();
        office.Name = name;
        office.loan__Office_Short_Name__c = shortName;
        office.loan__Cash_Account__c = mfAccountId;
        office.loan__Check_Account__c = mfAccountId;
        office.loan__Bank_Account_Checks__c = mfAccountId;
        office.loan__Inward_Check_Clearance_Account__c = mfAccountId;
        office.loan__Outward_Check_Clearance_Account__c = mfAccountId;
        office.loan__Profit_and_Loss_Account__c = mfAccountId;
        office.loan__Loan_Schedule_tied_to_Meeting_Schedule__c = false;
        office.loan__Mark_Suspended_After_Days__c = 180;
        office.loan__Days_in_advance_to_create_Collection_Rep__c = 1;
        office.loan__Office_Type__c = officeTypeId;
        office.loan__Current_System_Date__c = systemDate;
        office.loan__Write_Off_Suggestion_Days__c = 90;
        office.recordTypeId = recordTypeId;
        return office;
    }

    public static void createDayProcess(Id officeId) {
        Date startDate = Date.newInstance(currentSystemDate.year(), 01, 01);
        Date endDate = Date.newInstance(currentSystemDate.year(), 12, 31);

        delete [SELECT Id FROM loan__Fiscal_Year__c];

        loan__Fiscal_Year__c loanFiscalYear = new loan__Fiscal_Year__c();
        loanFiscalYear.Name = String.valueOf(currentSystemDate.year());
        loanFiscalYear.loan__Archived__c = false;
        loanFiscalYear.loan__Master_Archive_Object__c = false;
        loanFiscalYear.loan__Start_Date__c = startDate;
        loanFiscalYear.loan__End_Date__c = endDate;
        loanFiscalYear.loan__Status__c = 'Open';
        loanFiscalYear.loan__Summary__c = false;
        insert loanFiscalYear;

        List<loan__Day_Process__c> dayProcessList = new List<loan__Day_Process__c>();
        dayProcessList.add(
            generateDayProcess(officeId, currentSystemDate.addDays(-1), true, true)
        );
        dayProcessList.add(
            generateDayProcess(officeId, currentSystemDate, true, false)
        );
        dayProcessList.add(
            generateDayProcess(officeId, currentSystemDate.addDays(1), false, false)
        );

        insert dayProcessList;
    }

    public static loan__Day_Process__c generateDayProcess(
        Id officeId, Date dayProcessDate, Boolean isDayStarted, Boolean isDayEnded
    ) {
        loan__Day_Process__c loanDayProcess = new loan__Day_Process__c();
        loanDayProcess.loan__Branch__c = officeId;
        loanDayProcess.loan__Date__c = dayProcessDate;
        loanDayProcess.loan__Day_Started__c = isDayStarted;
        loanDayProcess.loan__Day_Ended__c = isDayEnded;
        return loanDayProcess;
    }

    public static genesis__Company__c createCompany() {
        List<genesis__Company__c> companyList = [
            SELECT Id
            FROM genesis__Company__c
            WHERE Name = :GeneralConstants.COMPANY_NAME
            LIMIT 1
        ];
        if (!companyList.isEmpty()) {
            return companyList[0];
        }

        genesis__Company__c company = genesis.TestHelper.createCompany();
        company.genesis__Short_Name__c = '1';
        company.Name = GeneralConstants.COMPANY_NAME;
        update company;

        return company;
    }

    public static loan__Currency__c createCurrency() {
        List<loan__Currency__c> currencyList = [
            SELECT Id
            FROM loan__Currency__c
            LIMIT 1
        ];
        if (!currencyList.isEmpty()) {
            return currencyList[0];
        }

        return loan.TestHelper.createCurrency();
    }

    public static loan__MF_Account__c createMFAccount() {
        return createMFAccount('XXXAccountForTest', '10000 - ASSETS');
    }

    public static loan__MF_Account__c createMFAccount(
        String name, String accountType
    ) {
        List<loan__MF_Account__c> mfAccountList = [
            SELECT Id, loan__Account_Type__c
            FROM loan__MF_Account__c
            WHERE loan__Account_Type__r.Name = :accountType
            LIMIT 1
        ];

        if (!mfAccountList.isEmpty()) {
            return mfAccountList[0];
        }

        return loan.TestHelper.createMFAccount(name, accountType);
    }

    public static loan__Fee__c createFee() {
        List<loan__Fee__c> feeList = [SELECT Id FROM loan__Fee__c LIMIT 1];
        if (!feeList.isEmpty()) {
            return feeList[0];
        }

        loan__Currency__c curr = createCurrency();
        loan__MF_Account__c mfAccount = createMFAccount();

        loan__Fee__c fee = new loan__Fee__c();
        fee.Name = 'SampleFee';
        fee.loan__State__c = 'Active';
        fee.loan__Fee_Calculation_Method__c = 'Fixed';
        fee.loan__Amount__c = 100;
        fee.loan__Currency__c = curr.Id;
        fee.loan__Fee_Category__c = 'Loan';
        fee.loan__Time_of_charge__c = 'Time of First Repayment';
        fee.loan__Income_Account__c = mfAccount.Id;
        fee.loan__Fee_Expense_Account__c = mfAccount.Id;
        fee.loan__Fee_Prepay_Account__c = mfAccount.Id;
        fee.loan__Fee_Unearned_Income_Account__c = mfAccount.Id;
        insert fee;

        return fee;
    }

    public static loan__Fee_Set__c createFeeSet() {
        List<loan__Fee_Set__c> feeSetList = [
            SELECT Id
            FROM loan__Fee_Set__c
            LIMIT 1
        ];
        if (!feeSetList.isEmpty()) {
            return feeSetList[0];
        }

        loan__Fee_Set__c feeSet = new loan__Fee_Set__c();
        feeSet.name = 'FakeFEE';
        feeSet.loan__Fee_Set_Category__c = 'Loan';
        insert feeSet;

        return feeSet;
    }

    public static loan__Fee_Junction__c createFeeJunction() {
        List<loan__Fee_Junction__c> feeJunctionList = [
            SELECT Id
            FROM loan__Fee_Junction__c
            LIMIT 1
        ];

        if (!feeJunctionList.isEmpty()) {
            return feeJunctionList[0];
        }

        loan__Fee__c dummyFee = createFee();
        loan__Fee_Set__c dummyFeeSet = createFeeSet();

        loan__Fee_Junction__c feeJunction = new loan__Fee_Junction__c();
        feeJunction.loan__Fee__c = dummyFee.Id;
        feeJunction.loan__Fee_Set__c = dummyFeeSet.Id;
        insert feeJunction;

        return feeJunction;
    }

    public static loan__Loan_Purpose__c createLoanPurpose() {
        List<loan__Loan_Purpose__c> loanPurposeList = [
            SELECT Id
            FROM loan__Loan_Purpose__c
            LIMIT 1
        ];

        if (!loanPurposeList.isEmpty()) {
            return loanPurposeList[0];
        }

        return loan.TestHelper.createLoanPurpose();
    }

    public static void assignUserBranch(
        Id userId,
        loan__Office_Name__c loanOffice
    ) {
        List<loan__User_Branch_Info__c> userBranchList = [
            SELECT Id
            FROM loan__User_Branch_Info__c
            WHERE loan__Branch__c = :loanOffice.Id AND loan__User__c = :UserId
        ];

        if (userBranchList.isEmpty()) {
            loan__User_Branch_Info__c userBranch = new loan__User_Branch_Info__c();
            userBranch.loan__User__c = UserId;
            userBranch.loan__Branch__c = loanOffice.Id;
            insert userBranch;
        }

        List<User> currentUsers = [
            SELECT Id
            FROM User
            WHERE Id = :UserId AND loan__Current_Branch__c = :loanOffice.Name
        ];

        if (currentUsers.isEmpty()) {
            User userRecord = new User(Id = UserId);
            userRecord.loan__Current_Branch__c = loanOffice.Name;
            userRecord.loan__Default_Branch__c = loanOffice.Name;
            update userRecord;
        }
    }

    public static loan__Payment_Mode__c generatePaymentMode(String name) {
        loan__Payment_Mode__c paymentMode = new loan__Payment_Mode__c();
        paymentMode.Name = name;
        return paymentMode;
    }

    public static loan__Payment_Mode__c createPaymentMode(String name) {
        loan__Payment_Mode__c paymentMode = generatePaymentMode(name);
        insert paymentMode;
        return paymentMode;
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
            'Borrower', 'Contact', 'Guarantor', 'Broker'
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

    public static loan__Repayment_Schedule__c generateRepaymentSchedule(
        Id loanAccountId, Date dueDate, Decimal principalDue, Decimal interestDue
    ) {
        loan__Repayment_Schedule__c repaymentSchedule = new loan__Repayment_Schedule__c();
        repaymentSchedule.loan__Loan_Account__c = loanAccountId;
        repaymentSchedule.loan__Due_Principal__c = principalDue;
        repaymentSchedule.loan__Due_Interest__c = interestDue;
        repaymentSchedule.loan__Due_Amount__c = principalDue + interestDue;
        repaymentSchedule.loan__Due_Date__c = dueDate;
        repaymentSchedule.loan__Is_Archived__c = false;
        repaymentSchedule.loan__isPaid__c = false;
        repaymentSchedule.loan__Is_Billed__c = false;
        return repaymentSchedule;
    }
}