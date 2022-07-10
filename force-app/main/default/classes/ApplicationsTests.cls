@isTest(isParallel=true)
private class ApplicationsTests {

    @isTest
    static void createApplication() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        loan__Loan_Product__c loanProduct = new loan__Loan_Product__c();
        loanProduct.loan__Default_Number_of_Installments__c = 6;
        loanProduct.loan__Frequency_of_Loan_Payment__c = GeneralConstants.FREQUENCY_DAILY;

        clcommon__CL_Product__c clProduct = new clcommon__CL_Product__c();
        clProduct.Id = TestUtility.getFakeId(clcommon__CL_Product__c.getSObjectType());
        clProduct.loan__Lending_Product__r = loanProduct;
        OriginationHelper.clProduct = clProduct;

        clcommon__Company__c clCompany = new clcommon__Company__c();
        clCompany.Id = TestUtility.getFakeId(clcommon__Company__c.getSObjectType());
        OriginationHelper.clCompany = clCompany;

        genesis__Company__c company = new genesis__Company__c();
        company.Id = TestUtility.getFakeId(genesis__Company__c.getSObjectType());
        OriginationHelper.company = company;

        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id opportunityId = TestUtility.getFakeId(Opportunity.getSObjectType());

        Test.startTest();
            genesis__Applications__c actualApplication = Applications.createApplication(
                accountId, 1000, opportunityId, GeneralConstants.LOAN_TYPE_NEW
            );
        Test.stopTest();

        System.assertEquals(accountId, actualApplication.genesis__Account__c);
        System.assertEquals(opportunityId, actualApplication.Opportunity__c);
        System.assertEquals(GeneralConstants.LOAN_TYPE_NEW, actualApplication.Type__c);
    }

    @isTest
    static void setApplicationFieldsFromAccount() {

        Account accountRecordOne = new Account();
        accountRecordOne.Sic = '123';
        accountRecordOne.Biz_Start_Date__c = Date.newInstance(2020, 01, 01);

        Account accountRecordTwo = new Account();
        accountRecordTwo.SIC_Code_2__c = '444';
        accountRecordTwo.Biz_Start_Date__c = Date.newInstance(2020, 02, 01);

        genesis__Applications__c applicationOne = new genesis__Applications__c();
        genesis__Applications__c applicationTwo = new genesis__Applications__c();

        Test.startTest();
            Applications.setApplicationFieldsFromAccount(applicationOne, accountRecordOne);
            Applications.setApplicationFieldsFromAccount(applicationTwo, accountRecordTwo);
        Test.stopTest();

        System.assertEquals(accountRecordOne.Sic, applicationOne.SIC_Code__c);
        System.assertEquals(accountRecordOne.Biz_Start_Date__c, applicationOne.Business_Start_Date__c);
        System.assertEquals(accountRecordTwo.SIC_Code_2__c, applicationTwo.SIC_Code__c);
        System.assertEquals(accountRecordTwo.Biz_Start_Date__c, applicationTwo.Business_Start_Date__c);
    }

    @isTest
    static void getFirstPaymentDateByFrequency() {
        Date startDate = Date.newInstance(2020, 01, 02);

        Test.startTest();
            Date actualFirstPaymentDate = Applications.getFirstPaymentDateByFrequency(startDate, GeneralConstants.FREQUENCY_WEEKLY);
        Test.stopTest();

        System.assertEquals(Date.newInstance(2020, 01, 03), actualFirstPaymentDate);
    }

    @isTest
    static void isStatusChanged() {
        genesis__Applications__c newApplication = new genesis__Applications__c();
        newApplication.genesis__Status__c = Applications.STATUS_OFFER_SENT;
        genesis__Applications__c oldApplication = new genesis__Applications__c();
        oldApplication.genesis__Status__c = Applications.STATUS_NEW_ENTERED;

        Test.startTest();
            Boolean isStatusChanged = Applications.isStatusChanged(newApplication, oldApplication);
        Test.stopTest();

        System.assert(isStatusChanged);
    }

    @isTest
    static void setDenialReasons() {

        genesis__Applications__c newApplicationOne = new genesis__Applications__c();
        genesis__Applications__c newApplicationTwo = new genesis__Applications__c();
        newApplicationTwo.Decline_Reasons__c = 'Reason One;Reason Two';

        Test.startTest();
            Applications.setDenialReasons(newApplicationOne, 'Dummy Reason');
            Applications.setDenialReasons(newApplicationTwo, 'Dummy Reason');
        Test.stopTest();

        System.assertEquals(Applications.STATUS_DECLINED, newApplicationOne.genesis__Status__c);
        System.assertEquals(Applications.STATUS_DECLINED, newApplicationOne.Overall_Status__c);
        System.assertEquals('Dummy Reason', newApplicationOne.Decline_Reasons__c);
        System.assertEquals(Applications.STATUS_DECLINED, newApplicationTwo.genesis__Status__c);
        System.assertEquals(Applications.STATUS_DECLINED, newApplicationTwo.Overall_Status__c);
        System.assertEquals('Reason One;Reason Two;Dummy Reason', newApplicationTwo.Decline_Reasons__c);
    }

    @isTest
    static void cloneDeclineReasons() {

        genesis__Applications__c newApplication = new genesis__Applications__c();
        genesis__Applications__c declineApplication = new genesis__Applications__c();
        declineApplication.Decline_Reasons__c = 'Reason One;Reason Two';

        Test.startTest();
            Applications.cloneDeclineReasons(newApplication, declineApplication);
        Test.stopTest();

        System.assertEquals(Applications.STATUS_DECLINED, newApplication.genesis__Status__c);
        System.assertEquals(Applications.STATUS_DECLINED, newApplication.Overall_Status__c);
        System.assertEquals(declineApplication.Decline_Reasons__c, newApplication.Decline_Reasons__c);
    }

    @isTest
    static void appStatusToOverAllStatus() {
        Test.startTest();
            Map<String, String> appStatusToOverAllStatus = Applications.appStatusToOverAllStatus;
        Test.stopTest();

        System.assertEquals(Applications.STATUS_NEW_ENTERED, appStatusToOverAllStatus.get(Applications.STATUS_NEW_ENTERED));
    }

    @isTest
    static void setApplicationFieldsFromPricingForApplicationFrequency() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        pricingDetail.Selected_Amount__c = 1000;
        pricingDetail.Maximum_Amount__c = 1000;
        pricingDetail.Term__c = 12;
        pricingDetail.Pricing_Factor__c = 1.28;

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_WEEKLY;

        LoanCalculatorManagerTestStub loanCalculatorManagerTestStubInstance = new LoanCalculatorManagerTestStub();
        Applications.loanCalculatorManagerInstance = (LoanCalculatorManager) Test.createStub(
            LoanCalculatorManager.class, loanCalculatorManagerTestStubInstance
        );

        Test.startTest();
            Applications.setApplicationFieldsFromPricingForApplicationFrequency(
                application, pricingDetail
            );
        Test.stopTest();

        System.assertEquals(pricingDetail.Selected_Amount__c, application.genesis__Loan_Amount__c);
        System.assertEquals(pricingDetail.Maximum_Amount__c, application.Maximum_Funding_Amount__c);
        System.assertEquals(pricingDetail.Term__c, application.genesis__Term__c);
        System.assertEquals(GeneralConstants.FREQUENCY_WEEKLY, application.genesis__Payment_Frequency__c);
    }

    @isTest
    static void setApplicationFieldsFromPricing() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        pricingDetail.Selected_Amount__c = 1000;
        pricingDetail.Maximum_Amount__c = 1000;
        pricingDetail.Term__c = 12;
        pricingDetail.Pricing_Factor__c = 1.28;

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_WEEKLY;

        LoanCalculatorManagerTestStub loanCalculatorManagerTestStubInstance = new LoanCalculatorManagerTestStub();
        Applications.loanCalculatorManagerInstance = (LoanCalculatorManager) Test.createStub(
            LoanCalculatorManager.class, loanCalculatorManagerTestStubInstance
        );

        Test.startTest();
            Applications.setApplicationFieldsFromPricing(application, pricingDetail);
        Test.stopTest();

        System.assertEquals(pricingDetail.Selected_Amount__c, application.genesis__Loan_Amount__c);
        System.assertEquals(pricingDetail.Maximum_Amount__c, application.Maximum_Funding_Amount__c);
        System.assertEquals(pricingDetail.Term__c, application.genesis__Term__c);
        System.assertEquals(GeneralConstants.FREQUENCY_DAILY, application.genesis__Payment_Frequency__c);
    }

    @isTest
    static void hasIncompleteSTIPS() {

        STIPS_Checklist__c stipsCheck = new STIPS_Checklist__c();
        stipsCheck.Bank_Verification_Call__c = true;

        Test.startTest();
            Boolean hasIncompleteSTIPS = Applications.hasIncompleteSTIPS(stipsCheck);
        Test.stopTest();

        System.assert(hasIncompleteSTIPS);
    }

    @isTest
    static void hasNoIncompleteSTIPS() {

        STIPS_Checklist__c stipsCheck = new STIPS_Checklist__c();

        Test.startTest();
            Boolean hasIncompleteSTIPS = Applications.hasIncompleteSTIPS(stipsCheck);
        Test.stopTest();

        System.assert(!hasIncompleteSTIPS);
    }

    @isTest
    static void buildApplicationDetailsEmailBody() {
        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);

        Document documentRecord = new Document();
        documentRecord.Id = TestUtility.getFakeId(Document.getSObjectType());

        List<Document> documentList = new List<Document>();
        documentList.add(documentRecord);

        Account brokerAccount = new Account();
        brokerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        brokerAccount.New_Max_Broker_Commission__c = 90;

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-00000102", "Max_Broker_Commission__c" : "99"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Maximum_Funding_Amount__c = 12;
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.Max_Term__c = 14;
        application.Buy_Rate__c = 1.26;
        application.Type__c = 'New';
        application.Broker_Account__c = brokerAccount.Id;

        String body = '{{MAX_FUNDING_AMOUNT}} {{PARTNER_PRICING_LINK_START}} {{PARTNER_PRICING_LINK}} {{PARTNER_PRICING_LINK_END}}}';

        STIPS_Checklist__c stipsCheck = new STIPS_Checklist__c();

        Test.startTest();
            body = Applications.buildApplicationDetailsEmailBody(body, application, documentList, stipsCheck);
        Test.stopTest();

        System.assert(body.contains('12'));
    }

    @isTest
    static void buildOfferEmailBodyStandardOffer() {
        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Maximum_Amount__c = 2000;

        List<CAN_Pricing_Detail__c> pricingDetailList = new List<CAN_Pricing_Detail__c>{pricingDetail};
        String jsonPricingDetailList = '{"totalSize" : 1, "done" : true, "records" :' + JSON.serialize(pricingDetailList, false) + '}';

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{"CAN_Pricing_Details__r" : ' + jsonPricingDetailList +
            '}' , genesis__Applications__c.class
        );
        application.genesis__Requested_Loan_Amount__c = 1000;

        String body = '{{OFFER_APPROVED_COUNTER_OFFER_START}} {{STANDARD_START}} {{OFFER_APPROVED_COUNTER_OFFER_END}} {{COUNTER_OFFER_START}} Test {{COUNTER_OFFER_END}}';

        Test.startTest();
            Applications.buildOfferEmailBody(
                application, body
            );
        Test.stopTest();

        System.assert(body.contains('{{STANDARD_START}}'));
    }

    @isTest
    static void buildOfferEmailBodyCounterOffer() {
        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Maximum_Amount__c = 2000;

        List<CAN_Pricing_Detail__c> pricingDetailList = new List<CAN_Pricing_Detail__c>{pricingDetail};
        String jsonPricingDetailList = '{"totalSize" : 1, "done" : true, "records" :' + JSON.serialize(pricingDetailList, false) + '}';

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{"CAN_Pricing_Details__r" : ' + jsonPricingDetailList +
            '}' , genesis__Applications__c.class
        );
        application.genesis__Requested_Loan_Amount__c = 3000;

        String body = '{{COUNTER_OFFER_START}} {{STANDARD_START}} {{STANDARD_END}} {{OFFER_APPROVED_STANDARD_START}} {{OFFER_APPROVED_STANDARD_END}}}';

        Test.startTest();
            Applications.buildOfferEmailBody(
                application, body
            );
        Test.stopTest();

        System.assert(body.contains('{{COUNTER_OFFER_START}}'));
    }

    @isTest
    static void addEmailAddressToBrokerNotification() {
        Account accountRecord = new Account();
        accountRecord.Name = 'Test Account';
        accountRecord.Merchant_ID__c = '12345';
        accountRecord.Email_cc__c = 'additionalmail@test.com, additionalmail2@test.com';

        Opportunity opportunityRecord =  new Opportunity();
        opportunityRecord.Id = TestUtility.getFakeId(Opportunity.getSObjectType());

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.Email = 'BrokerMail@Test.com';
        contactRecord.Account = accountRecord;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.genesis__Account__r = accountRecord;
        application.Broker_Contact__c = contactRecord.Id;
        application.Broker_Contact__r = contactRecord;
        application.Opportunity__c = opportunityRecord.Id;
        application.Opportunity__r = opportunityRecord;
        String salesRepEmailAddress = 'SalesRepMail@Test.com';

        Test.startTest();
            Map<String, List<String>> stringToEmailAddressesMap = Applications.addEmailAddressToBrokerNotification(application, salesRepEmailAddress);
        Test.stopTest();

        System.assert(stringToEmailAddressesMap.containsKey('toAddresses'));
    }

    @isTest
    static void addEmailAddressToBrokerNotificationForRenewalApplication() {
        Account accountRecord = new Account();
        accountRecord.Name = 'Test Account';
        accountRecord.Merchant_ID__c = '12345';
        accountRecord.Email_cc__c = 'additionalmail@test.com, additionalmail2@test.com';

        Opportunity opportunityRecord =  new Opportunity();
        opportunityRecord.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        opportunityRecord.Offer_Notification_To_Broker__c = true;

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.Email = 'BrokerMail@Test.com';
        contactRecord.Account = accountRecord;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;
        application.genesis__Account__r = accountRecord;
        application.Broker_Contact__c = contactRecord.Id;
        application.Broker_Contact__r = contactRecord;
        application.Opportunity__c = opportunityRecord.Id;
        application.Opportunity__r = opportunityRecord;
        String salesRepEmailAddress = 'SalesRepMail@Test.com';

        Test.startTest();
            Map<String, List<String>> stringToEmailAddressesMap = Applications.addEmailAddressToBrokerNotification(application, salesRepEmailAddress);
        Test.stopTest();

        System.assert(stringToEmailAddressesMap.containsKey('toAddresses'));
    }

    @isTest
    static void buildApplicationDetailsEmailSubject() {
        Account accountRecord = new Account();
        accountRecord.Name = 'Test Account';
        accountRecord.Merchant_ID__c = '12345';

        Contact contactRecord = new Contact();
        contactRecord.LastName = 'Test Contact';
        contactRecord.Account = accountRecord;

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Account__r = accountRecord;
        application.Broker_Contact__r = contactRecord;
        String subject = '{{LEGAL_ENTITY_NAME}}';

        Test.startTest();
            subject = Applications.buildApplicationDetailsEmailSubject(subject, application);
        Test.stopTest();

        System.assert(subject.contains(accountRecord.Name));
    }

    @isTest
    static void buildSTIPSIncompleteEmailBody() {

        STIPS_Checklist__c stipsCheck = new STIPS_Checklist__c();
        stipsCheck.Bank_Verification_Call__c = true;
        stipsCheck.Borrower_Interview__c = true;
        stipsCheck.experian_fraud_check__c = true;

        Test.startTest();
            String body = Applications.buildSTIPSIncompleteEmailBody(stipsCheck);
        Test.stopTest();

        System.assert(body.contains('Additional Information Needed'));
    }

    @isTest
    static void validateApplicationRequiredFields() {

        genesis__Applications__c application = new genesis__Applications__c();

        Exception ex;
        Test.startTest();
            try {
                Applications.validateApplicationRequiredFields(application);
            } catch (Exception e) {
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertException(ex);
        System.assert(ex.getMessage().contains('SIC code and Business Start Date should not be blank'));
    }

    @isTest
    static void setConcurrentApplicationFields() {
        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Loan_Amount__c = 1000;
        application.Pricing_Factor__c = 1.26;
        application.Total_Repayment_Amount__c = 1100;
        application.Concurrent_Principal_Amount__c = 500;
        application.genesis__Maturity_Date__c = GeneralHelper.currentSystemDate.addDays(100);

        loan__Loan_Account__c loanAccount = (loan__Loan_Account__c) JSON.deserialize(
            '{ "Remaining_Number_of_Payments__c" : "45"}' , loan__Loan_Account__c.class
        );
        loanAccount.loan__Payment_Amount__c = 100;
        loanAccount.loan__Disbursed_Amount__c = 1000;
        loanAccount.loan__Interest_Rate__c = 20;
        loanAccount.loan__Last_Installment_Date__c = GeneralHelper.currentSystemDate.addDays(100);
        loanAccount.Application__r = application;

        LoanCalculatorManagerTestStub loanCalculatorManagerTestStubInstance = new LoanCalculatorManagerTestStub();
        Applications.loanCalculatorManagerInstance = (LoanCalculatorManager) Test.createStub(
            LoanCalculatorManager.class, loanCalculatorManagerTestStubInstance
        );

        Test.startTest();
            Applications.setConcurrentApplicationFields(application, loanAccount);
        Test.stopTest();

        System.assertEquals(loanAccount.loan__Last_Installment_Date__c, application.genesis__Maturity_Date__c);
    }

    @isTest
    static void setRenewalApplicationFieldsFromLoanAccount() {
        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Loan_Amount__c = 1000;
        application.Annual_Volume__c = 2000;

        loan__Loan_Account__c loanAccount = (loan__Loan_Account__c) JSON.deserialize(
            '{ "Remaining_Number_of_Payments__c" : "45"}' , loan__Loan_Account__c.class
        );
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccount.loan__Payment_Amount__c = 100;
        loanAccount.loan__Disbursed_Amount__c = 1000;
        loanAccount.loan__Interest_Rate__c = 20;
        loanAccount.Application__r = application;

        Test.startTest();
            Applications.setRenewalApplicationFieldsFromLoanAccount(application, loanAccount);
        Test.stopTest();

        System.assertEquals(loanAccount.Id, application.Renewal_Concurrent_LoanAccount__c);
    }

    @isTest
    static void handleStatusChangedOnBeforeUpdate() {
        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);

        genesis__Applications__c newApplication = new genesis__Applications__c();
        newApplication.genesis__Status__c = Applications.STATUS_APPROVED;
        genesis__Applications__c oldApplication = new genesis__Applications__c();
        oldApplication.genesis__Status__c = Applications.STATUS_NEW_ENTERED;

        Map<String, List<genesis__Applications__c>> applicationByStatusChange = new Map<String, List<genesis__Applications__c>>();

        Test.startTest();
            Applications.handleStatusChangedOnBeforeUpdate(newApplication, oldApplication, applicationByStatusChange);
        Test.stopTest();

        System.assert(!applicationByStatusChange.isEmpty());
        System.assertEquals(GeneralHelper.currentSystemDate, newApplication.Contract_Approved_Date__c);
    }

    @isTest
    static void handleStatusChangedOnBeforeUpdateClosedDeclined() {
        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);

        genesis__Applications__c newApplication = new genesis__Applications__c();
        newApplication.genesis__Status__c = Applications.STATUS_DECLINED;
        genesis__Applications__c oldApplication = new genesis__Applications__c();
        oldApplication.genesis__Status__c = Applications.STATUS_NEW_ENTERED;

        Map<String, List<genesis__Applications__c>> applicationByStatusChange = new Map<String, List<genesis__Applications__c>>();

        Test.startTest();
            Applications.handleStatusChangedOnBeforeUpdate(newApplication, oldApplication, applicationByStatusChange);
        Test.stopTest();

        System.assert(!applicationByStatusChange.isEmpty());
        System.assertEquals(GeneralHelper.currentSystemDate, newApplication.Application_Declined_Date__c);
    }

    @isTest
    static void groupApplicationByStatusChange() {

        Map<String, List<genesis__Applications__c>> applicationByStatusChange = new Map<String, List<genesis__Applications__c>>();
        genesis__Applications__c newApplication = new genesis__Applications__c();
        newApplication.genesis__Status__c = Applications.STATUS_APPROVED;

        Test.startTest();
            Applications.groupApplicationByStatusChange(newApplication, applicationByStatusChange);
        Test.stopTest();

        System.assert(!applicationByStatusChange.isEmpty());
        System.assert(applicationByStatusChange.containsKey(Applications.STATUS_APPROVED));
    }

    @isTest
    static void isConsentChecked() {
        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);

        genesis__Applications__c newApplication = new genesis__Applications__c();
        newApplication.genesis__Status__c = Applications.STATUS_APPROVED;
        newApplication.Credit_Check_Consent__c = true;
        newApplication.SIC_Code__c = '123';
        newApplication.Business_Start_Date__c = GeneralHelper.currentSystemDate;

        genesis__Applications__c oldApplication = new genesis__Applications__c();
        oldApplication.genesis__Status__c = Applications.STATUS_NEW_ENTERED;

        List<genesis__Applications__c> consentApplications = new List<genesis__Applications__c>();

        Test.startTest();
            Applications.isConsentChecked(newApplication, oldApplication, consentApplications);
        Test.stopTest();

        System.assert(!consentApplications.isEmpty());
        System.assertEquals(Applications.STATUS_GUARANTOR_CREDIT_CHECK, newApplication.genesis__Status__c);
    }

    @isTest
    static void isRenewalConcurrentFieldUpdate() {

        genesis__Applications__c newApplication = new genesis__Applications__c();
        newApplication.Renewal_Concurrent_LoanAccount__c = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        genesis__Applications__c oldApplication = new genesis__Applications__c();
        oldApplication.Renewal_Concurrent_LoanAccount__c = null;

        Map<Id, genesis__Applications__c> renewalAndConcurrentContractIdToApplication = new Map<Id, genesis__Applications__c>();

        Test.startTest();
            Applications.isRenewalConcurrentFieldUpdate(newApplication, oldApplication, renewalAndConcurrentContractIdToApplication);
        Test.stopTest();

        System.assert(!renewalAndConcurrentContractIdToApplication.isEmpty());
        System.assert(renewalAndConcurrentContractIdToApplication.containsKey(newApplication.Renewal_Concurrent_LoanAccount__c));
    }

    @isTest
    static void buildBrokerDeclineTemplateSubject() {
        Account accountRecord = new Account ();
        accountRecord.Name = 'Test Account';
        accountRecord.Merchant_ID__c = '12345';

        Contact contactRecord = new Contact();
        contactRecord.Account = accountRecord;

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Account__r = accountRecord;
        application.Broker_Contact__c = contactRecord.Id;
        application.Broker_Contact__r = contactRecord;
        String subject = '{{BORROWER_ID}}';

        Test.startTest();
            subject = Applications.buildBrokerDeclineTemplateSubject(application, subject);
        Test.stopTest();

        System.assert(subject.contains(accountRecord.Merchant_ID__c));
    }

    @isTest
    static void buildBrokerDeclineTemplateBody() {
        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);

        Account accountRecord = new Account ();
        accountRecord.Name = 'Test Account';
        accountRecord.Merchant_ID__c = '12345';
        accountRecord.BillingStreet = '173 Charles Street';
        accountRecord.BillingCity = 'Salem';
        accountRecord.BillingState = 'NH';
        accountRecord.BillingPostalCode = '12345';
        accountRecord.Industry = 'Textile Industries';

        Contact contactRecord = (Contact) JSON.deserialize(
            '{ "Name" : "John"}' , Contact.class
        );
        contactRecord.Account = accountRecord;

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-0000000000", "Business_Name__c" : "LLC"}' , genesis__Applications__c.class
        );
        application.genesis__Account__r = accountRecord;
        application.Broker_Contact__r = contactRecord;
        application.Primary_Guarantor__r = contactRecord;
        application.genesis__Status__c = Applications.STATUS_DECLINED;
        application.Business_Start_Date__c = GeneralHelper.currentSystemDate;
        application.Decline_Reasons__c = 'Time In Business';
        String body = '{{MERCHANT_ID}}';

        Test.startTest();
            body = Applications.buildBrokerDeclineTemplateBody(application, body);
        Test.stopTest();

        System.assert(body.contains(accountRecord.Merchant_ID__c));
    }

    @isTest
    static void setFieldsOnBeforeUpdateForDeclineUntil() {

        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);
        CustomSettingsHelper.generalSettings.Decline_Until_Days__c = 30;
        Integer declineUntilDays = Integer.valueOf(CustomSettingsHelper.generalSettings.Decline_Until_Days__c);
        Date currentSystemDate = GeneralHelper.currentSystemDate;
        Date declineUntilDate = currentSystemDate.addDays(declineUntilDays);

        genesis__Applications__c newApplication = new genesis__Applications__c();
        newApplication.genesis__Status__c = Applications.STATUS_DECLINED;
        newApplication.Decline_Reasons__c = 'Competitor Stacking';
        genesis__Applications__c oldApplication = new genesis__Applications__c();

        Test.startTest();
            Applications.setFieldsOnBeforeUpdate(newApplication, oldApplication);
        Test.stopTest();

        System.assertEquals(newApplication.decline_until_date__c,declineUntilDate);
    }

    @isTest
    static void setFieldsOnBeforeUpdateForUnderwriter() {

        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);
        User newUser = new User();
        newUser.Id = TestUtility.getFakeId(User.getSObjectType());
        User oldUser = new User();
        oldUser.Id = TestUtility.getFakeId(User.getSObjectType());

        genesis__Applications__c newApplication = new genesis__Applications__c();
        newApplication.Underwriter__c = newUser.Id;
        genesis__Applications__c oldApplication = new genesis__Applications__c();
        oldApplication.genesis__Status__c = oldUser.Id;

        Test.startTest();
            Applications.setFieldsOnBeforeUpdate(newApplication, oldApplication);
        Test.stopTest();

        System.assert(newApplication.Underwriter__c != null);
    }

    @isTest
    static void setFieldsOnBeforeUpdateForDocsIn() {

        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);

        genesis__Applications__c newApplication = new genesis__Applications__c();
        newApplication.genesis__Status__c = Applications.STATUS_DOCS_IN;
        genesis__Applications__c oldApplication = new genesis__Applications__c();
        oldApplication.genesis__Status__c = Applications.STATUS_NEW_ENTERED;

        Test.startTest();
            Applications.setFieldsOnBeforeUpdate(newApplication, oldApplication);
        Test.stopTest();

        System.assert(newApplication.Submission_Date__c != null);
    }

    @isTest
    static void setFieldsOnBeforeUpdateForReadyToFund() {

        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);

        genesis__Applications__c newApplication = new genesis__Applications__c();
        newApplication.genesis__Status__c = Applications.STATUS_READY_TO_FUND;
        genesis__Applications__c oldApplication = new genesis__Applications__c();
        oldApplication.genesis__Status__c = Applications.STATUS_NEW_ENTERED;

        Test.startTest();
            Applications.setFieldsOnBeforeUpdate(newApplication, oldApplication);
        Test.stopTest();

        System.assert(newApplication.Sent_to_Funding_Team__c != null);
    }

    @isTest
    static void setFeildsonBeforeUpdateForFundingAuditCompleted() {

        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);

        genesis__Applications__c newApplication = new genesis__Applications__c();
        newApplication.Funding_Audit_Completed__c = true;
        genesis__Applications__c oldApplication = new genesis__Applications__c();

        Test.startTest();
            Applications.setFieldsOnBeforeUpdate(newApplication, oldApplication);
        Test.stopTest();

        System.assert(newApplication.Funding_Audit_Completed_Date__c != null);
    }

    @isTest
    static void setFeildsonBeforeUpdateForStatusPendingDocs() {

        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);

        genesis__Applications__c newApplication = new genesis__Applications__c();
        newApplication.genesis__Status__c = Applications.STATUS_PENDING_DOCS;
        newApplication.Submission_Date__c = GeneralHelper.currentSystemDate;
        genesis__Applications__c oldApplication = new genesis__Applications__c();
        oldApplication.genesis__Status__c = Applications.STATUS_NEW_ENTERED;

        Test.startTest();
            Applications.setFieldsOnBeforeUpdate(newApplication, oldApplication);
        Test.stopTest();

        System.assert(newApplication.UW_Decision_Made__c != null);
    }

    @isTest
    static void buildReadyToFundEmailBody() {
        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.Name = 'Magar Industries LLC';
        borrowerAccount.Merchant_ID__c = '3123123';

        Document documentRecord = new Document();
        documentRecord.Id = TestUtility.getFakeId(Document.getSObjectType());

        List<Document> documentList = new List<Document>();
        documentList.add(documentRecord);

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{"Name" : "APP-00000102", "Broker_Commission_Amount__c" : "1200"}' , genesis__Applications__c.class
        );
        application.genesis__Account__r = borrowerAccount;
        application.genesis__Loan_Amount__c = 12000;
        String body = '{{FUNDING_AMOUNT}}';

        Test.startTest();
            body = Applications.buildReadyToFundEmailBody(body, application, documentList);
        Test.stopTest();

        System.assert(body.contains('12000'));
    }

    @isTest
    static void buildReadyToFundEmailSubject() {
        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.Name = 'Magar Industries LLC';

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Account__r = borrowerAccount;
        String subject = '{{CUSTOMER_ACCOUNT_NAME}}';

        Test.startTest();
            subject = Applications.buildReadyToFundEmailSubject(subject, application);
        Test.stopTest();

        System.assert(subject.contains('Magar Industries LLC'));
    }

    @isTest
    static void validateApplicationOnCreditCheck() {

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c = Applications.STATUS_GUARANTOR_CREDIT_CHECK;

        Exception ex;
        Test.startTest();
            try {
                Applications.validateApplicationOnCreditCheck(application);
            } catch (Exception e) {
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertException(ex);
        System.assert(ex.getMessage().contains('Credit Consent is not Checked'));
    }

    @isTest
    static void setContractAndAccountFieldsOnRenewalApplicationDecline() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Status__c = Applications.STATUS_DECLINED;
        application.Decline_Reasons__c = BusinessRules.DENIAL_REASON_CUSTOMER_NOT_INTERESTED;
        application.Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;

        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        Test.startTest();
            Applications.setContractAndAccountFieldsOnRenewalApplicationDecline(application, loanAccount, borrowerAccount);
        Test.stopTest();

        System.assertEquals(GeneralHelper.currentSystemDate, borrowerAccount.Auto_Renewed_App_Declined_Date__c);
    }

    @isTest
    static void setConfirmedFraudFlag() {

        genesis__Applications__c newApplication = new genesis__Applications__c();
        newApplication.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        newApplication.Confirmed_Fraud_Flag__c = false;

        genesis__Applications__c oldApplication = new genesis__Applications__c();
        oldApplication.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        oldApplication.Confirmed_Fraud_Flag__c = true;

        Test.startTest();
            Applications.setFieldsOnBeforeUpdate(newApplication, oldApplication);
        Test.stopTest();

        System.assert(newApplication.Fraud_Reason__c == null);
    }
    @isTest
    private static void buildPartnerPricingSecureLinkTest() {
        genesis__Applications__c genesisApplication = new genesis__Applications__c();
        String body = '{{PARTNER_PRICING_LINK_START}} {{PARTNER_PRICING_LINK}} {{PARTNER_PRICING_LINK_END}}}';

        Test.startTest();
        String buildPartnerPricingSecureLinks = Applications.buildPartnerPricingSecureLink(genesisApplication, body);
        Test.stopTest();

        System.assert(body.contains('{{PARTNER_PRICING_LINK_START}}'));
    }
}