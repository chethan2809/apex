public class Applications {

    public static final String STATUS_NEW_ENTERED = 'NEW ENTERED';
    public static final String STATUS_APPLICATION_CREATED = 'APPLICATION CREATED';
    public static final String STATUS_GUARANTOR_CREDIT_CHECK = 'GUARANTOR CREDIT CHECK';
    public static final String STATUS_GUARANTOR_CREDIT_CHECK_FAILED = 'GUARANTOR CREDIT CHECK FAILED';
    public static final String STATUS_BUSINESS_CREDIT_CHECK = 'BUSINESS CREDIT CHECK';
    public static final String STATUS_BUSINESS_CREDIT_CHECK_FAILED = 'BUSINESS CREDIT CHECK FAILED';
    public static final String STATUS_CAN_SCORING = 'CAN SCORING';
    public static final String STATUS_CAN_SCORING_FAILED = 'CAN SCORING FAILED';
    public static final String STATUS_LEXISNEXIS_CHECK = 'LEXISNEXIS CHECK';
    public static final String STATUS_LEXISNEXIS_CHECK_FAILED = 'LEXISNEXIS CHECK FAILED';
    public static final String STATUS_INDUSTRY_CHECK = 'INDUSTRY CHECK';
    public static final String STATUS_INDUSTRY_CHECK_FAILED = 'INDUSTRY CHECK FAILED';
    public static final String STATUS_BANK_STATEMENT_UPLOAD = 'BANK STATEMENT UPLOAD';
    public static final String STATUS_BANK_STATEMENT_UPLOAD_FAILED = 'BANK STATEMENT UPLOAD FAILED';
    public static final String STATUS_BANK_STATEMENT_PROCESSING = 'BANK STATEMENT PROCESSING';
    public static final String STATUS_BANK_STATEMENT_PROCESSING_FAILED = 'BANK STATEMENT PROCESSING FAILED';
    public static final String STATUS_PRICING_GENERATION = 'PRICING GENERATION';
    public static final String STATUS_PRICING_GENERATION_FAILED = 'PRICING GENERATION FAILED';
    public static final String STATUS_OFFER_SENT = 'OFFER SENT';
    public static final String STATUS_UW_EXCEPTION_REVIEW = 'UW EXCEPTION REVIEW';
    public static final String STATUS_OFFER_ACCEPTED = 'OFFER ACCEPTED';
    public static final String STATUS_DOCS_OUT = 'DOCS OUT';
    public static final String STATUS_DOCS_IN = 'DOCS IN';
    public static final String STATUS_DUE_DILIGENCE = 'DUE DILIGENCE';
    public static final String STATUS_PENDING_DOCS = 'PENDING DOCS';
    public static final String STATUS_MANAGER_ESCALATION = 'MANAGER ESCALATION';
    public static final String STATUS_READY_TO_FUND = 'READY TO FUND';
    public static final String STATUS_CONVERSION_FAILED = 'CONVERSION FAILED';
    public static final String STATUS_FUNDING_IN_PROGRESS = 'FUNDING IN PROGRESS';
    public static final String STATUS_APPROVED = 'CLOSED - APPROVED';
    public static final String STATUS_DECLINED = 'CLOSED - DECLINED';
    public static final String STATUS_DATAMERCH_CHECK = 'DATA MERCH';
    public static final String STATUS_DATAMERCH_CHECK_FAILED = 'DATA MERCH FAILED';
    public static final String CUSTOMER_TYPE_BUSINESS = 'BUSINESS';
    public static final String CUSTOMER_TYPE_GUARANTOR = 'GUARANTOR';
    public static final String TEMPLATE_LOAN_AGREEMENT = 'Assumption of Loan Agreement';
    public static final String CONVERT_RESULT = 'Application is converted to contract successfully';
    public static final String BROKER_CREDIT_INCOMPLETE = 'Broker_Credit_Incomplete';
    public static final String BROKER_CREDIT_INCOMPLETE_TERM_MATRIX = 'Broker_Credit_Incomplete_TermMatrix';
    public static final String CAN_CAPITAL_LOGO = 'CAN_CAPITAL_IMAGE_PURPLE_BG';
    public static final String BROKER_DECLINE_NOTIFICATION = 'Broker_Decline_Notification';
    public static final String SCORING = 'SCORING';
    public static final String CONDITIONAL_APPROVAL = 'CONDITIONAL APPROVAL';
    public static final String EXCEPTION_REVIEW = 'EXCEPTION REVIEW';
    public static final String READY_TO_FUND_NOTIFICATION = 'Ready_To_Fund_Notification';
    public static final Set<String> APP_STATUSES_FOR_CREDIT_CHECK = new Set<String> {
        'NEW ENTERED', 'APPLICATION CREATED', 'CLOSED - DECLINED', 'GUARANTOR CREDIT CHECK FAILED'
    };
    public static final Set<String> APP_ACTIVE_STATUSES = new Set<String> {
        'NEW ENTERED', 'APPLICATION CREATED', 'GUARANTOR CREDIT CHECK', 'BUSINESS CREDIT CHECK', 'BUSINESS CREDIT CHECK FAILED',
        'CAN SCORING', 'CAN SCORING FAILED', 'LEXISNEXIS CHECK', 'LEXISNEXIS CHECK FAILED', 'INDUSTRY CHECK', 'INDUSTRY CHECK FAILED',
        'BANK STATEMENT UPLOAD', 'BANK STATEMENT UPLOAD FAILED', 'BANK STATEMENT PROCESSING', 'PRICING GENERATION', 'PRICING GENERATION FAILED',
        'OFFER SENT', 'UW EXCEPTION REVIEW', 'OFFER ACCEPTED', 'DOCS OUT', 'DATA MERCH', 'DATA MERCH FAILED'
    };
    public static final Set<String> PARTNER_PRICING_ELIGIBLE_STATUSES = new Set<String> {
        STATUS_OFFER_SENT, STATUS_OFFER_ACCEPTED, STATUS_DOCS_OUT
    };
    public static final Set<String> APP_STATUSES_FOR_AUTO_DECLINE_CHECK = new Set<String> {
        'DOCS IN','DUE DILIGENCE','PENDING DOCS', 'READY TO FUND','FUNDING IN PROGRESS','CONVERSION FAILED'
    };

    @TestVisible
    private static LoanCalculatorManager loanCalculatorManagerInstance = new LoanCalculatorManager();

    public static genesis__Applications__c createApplication(Id accountId, Decimal loanAmount, Id opportunityId, String applicationType) {
        Date currentDate = GeneralHelper.currentSystemDate;
        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Product_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
        application.genesis__Status__c = STATUS_NEW_ENTERED;
        application.genesis__Loan_Amount__c = loanAmount;
        application.genesis__Account__c = accountId;
        application.Opportunity__c = opportunityId;
        application.genesis__Term__c = OriginationHelper.clProduct.loan__Lending_Product__r.loan__Default_Number_of_Installments__c;
        application.genesis__Maturity_Date__c = currentDate.addMonths((Integer) application.genesis__Term__c);
        application.genesis__Payment_Frequency__c = OriginationHelper.clProduct.loan__Lending_Product__r.loan__Frequency_of_Loan_Payment__c;
        application.genesis__CL_Product__c = OriginationHelper.clProduct.Id;
        application.genesis__Company__c = OriginationHelper.company.Id;
        application.genesis__CL_Company__c= OriginationHelper.clCompany.Id;
        application.genesis__Calculation_Action__c = 'Calculate Term';
        application.genesis__Interest_Calculation_Method__c = 'Declining Balance';
        application.genesis__Expected_Start_Date__c = GeneralHelper.getBusinessDate(currentDate);
        application.genesis__Expected_Close_Date__c = currentDate.addDays(1);
        application.genesis__Expected_First_Payment_Date__c = getFirstPaymentDateByFrequency(
            application.genesis__Expected_Start_Date__c, application.genesis__Payment_Frequency__c
        );
        application.RecordTypeId = Schema.SObjectType.genesis__Applications__c.getRecordTypeInfosByName().get('Loan').getRecordTypeId();
        application.Type__c = applicationType;
        application.Random_Number__c = Integer.valueof((Math.random() * 100)) + 1;
        return application;
    }

    public static void setApplicationFieldsFromAccount(genesis__Applications__c application, Account accountRecord) {
        if(accountRecord.Sic != null) {
            application.SIC_Code__c = accountRecord.Sic;
        } else {
            application.SIC_Code__c = accountRecord.SIC_Code_2__c;
        }
        application.Business_Start_Date__c = accountRecord.Biz_Start_Date__c;
    }

    public static Date getFirstPaymentDateByFrequency(Date expectedStartDate, String paymentFrequency) {
        return GeneralHelper.getBusinessDate(expectedStartDate.addDays(1));
    }

    public static Boolean isStatusChanged(genesis__Applications__c newApplication, genesis__Applications__c oldApplication) {
        return (newApplication.genesis__Status__c != oldApplication.genesis__Status__c);
    }

    public static String convertApplication(genesis__Applications__c application) {
        genesis.ConvertApplicationCtrl convertApplicationInstance = new genesis.ConvertApplicationCtrl();
        String result = convertApplicationInstance.convertApplication(application.Id);
        if(result == CONVERT_RESULT) {
            application.genesis__Status__c = STATUS_APPROVED;
            return result;
        } else {
            throw new ApplicationsException('Application conversion failed: ' + result);
        }
    }

    public static void setDenialReasons(genesis__Applications__c application, String reason) {
        if(application.Decline_Reasons__c ==  null) {
            application.Decline_Reasons__c = reason;
        } else {
            List<String> declineRules = application.Decline_Reasons__c.split(';');
            if(!declineRules.contains(reason)) {
                application.Decline_Reasons__c += ';' + reason;
            }
        }
        application.genesis__Status__c = Applications.STATUS_DECLINED;
        application.Overall_Status__c = Applications.STATUS_DECLINED;
    }

    public static void cloneDeclineReasons(genesis__Applications__c application, genesis__Applications__c declineApplication) {
        application.Decline_Reasons__c = declineApplication.Decline_Reasons__c;
        application.decline_until_date__c = declineApplication.decline_until_date__c;
        application.genesis__Status__c = Applications.STATUS_DECLINED;
        application.Overall_Status__c = Applications.STATUS_DECLINED;
    }

    public static Map<String, String> appStatusToOverAllStatus {
        get {
            if(appStatusToOverAllStatus == null) {
                appStatusToOverAllStatus = new Map<String, String>();
                appStatusToOverAllStatus.put(Applications.STATUS_NEW_ENTERED, Applications.STATUS_NEW_ENTERED);
                appStatusToOverAllStatus.put(Applications.STATUS_APPLICATION_CREATED, Applications.STATUS_APPLICATION_CREATED);
                appStatusToOverAllStatus.put(Applications.STATUS_GUARANTOR_CREDIT_CHECK, 'SCORING');
                appStatusToOverAllStatus.put(Applications.STATUS_GUARANTOR_CREDIT_CHECK_FAILED, 'SCORING');
                appStatusToOverAllStatus.put(Applications.STATUS_BUSINESS_CREDIT_CHECK, 'SCORING');
                appStatusToOverAllStatus.put(Applications.STATUS_BUSINESS_CREDIT_CHECK_FAILED, 'SCORING');
                appStatusToOverAllStatus.put(Applications.STATUS_CAN_SCORING, 'SCORING');
                appStatusToOverAllStatus.put(Applications.STATUS_CAN_SCORING_FAILED, 'SCORING');
                appStatusToOverAllStatus.put(Applications.STATUS_DATAMERCH_CHECK, 'SCORING');
                appStatusToOverAllStatus.put(Applications.STATUS_DATAMERCH_CHECK_FAILED, 'SCORING');
                appStatusToOverAllStatus.put(Applications.STATUS_LEXISNEXIS_CHECK, 'SCORING');
                appStatusToOverAllStatus.put(Applications.STATUS_LEXISNEXIS_CHECK_FAILED, 'SCORING');
                appStatusToOverAllStatus.put(Applications.STATUS_INDUSTRY_CHECK, 'SCORING');
                appStatusToOverAllStatus.put(Applications.STATUS_INDUSTRY_CHECK_FAILED, 'SCORING');
                appStatusToOverAllStatus.put(Applications.STATUS_BANK_STATEMENT_UPLOAD, 'SCORING');
                appStatusToOverAllStatus.put(Applications.STATUS_BANK_STATEMENT_UPLOAD_FAILED, 'SCORING');
                appStatusToOverAllStatus.put(Applications.STATUS_BANK_STATEMENT_PROCESSING, 'SCORING');
                appStatusToOverAllStatus.put(Applications.STATUS_BANK_STATEMENT_PROCESSING_FAILED, 'SCORING');
                appStatusToOverAllStatus.put(Applications.STATUS_PRICING_GENERATION, 'SCORING');
                appStatusToOverAllStatus.put(Applications.STATUS_PRICING_GENERATION_FAILED, 'SCORING');
                appStatusToOverAllStatus.put(Applications.STATUS_OFFER_SENT, 'CONDITIONAL APPROVAL');
                appStatusToOverAllStatus.put(Applications.STATUS_OFFER_ACCEPTED, 'CONDITIONAL APPROVAL');
                appStatusToOverAllStatus.put(Applications.STATUS_UW_EXCEPTION_REVIEW, 'EXCEPTION REVIEW');
                appStatusToOverAllStatus.put(Applications.STATUS_DOCS_OUT, Applications.STATUS_DOCS_OUT);
                appStatusToOverAllStatus.put(Applications.STATUS_DOCS_IN, Applications.STATUS_DOCS_IN);
                appStatusToOverAllStatus.put(Applications.STATUS_DUE_DILIGENCE, Applications.STATUS_DUE_DILIGENCE);
                appStatusToOverAllStatus.put(Applications.STATUS_PENDING_DOCS, Applications.STATUS_DUE_DILIGENCE);
                appStatusToOverAllStatus.put(Applications.STATUS_MANAGER_ESCALATION, Applications.STATUS_DUE_DILIGENCE);
                appStatusToOverAllStatus.put(Applications.STATUS_READY_TO_FUND, Applications.STATUS_READY_TO_FUND);
                appStatusToOverAllStatus.put(Applications.STATUS_CONVERSION_FAILED, Applications.STATUS_READY_TO_FUND);
                appStatusToOverAllStatus.put(Applications.STATUS_FUNDING_IN_PROGRESS, Applications.STATUS_READY_TO_FUND);
                appStatusToOverAllStatus.put(Applications.STATUS_APPROVED, Applications.STATUS_APPROVED);
                appStatusToOverAllStatus.put(Applications.STATUS_DECLINED, Applications.STATUS_DECLINED);
            }
            return appStatusToOverAllStatus;
        }
        set;
    }

    public static void setApplicationFieldsFromPricingForApplicationFrequency(
        genesis__Applications__c application, CAN_Pricing_Detail__c pricingDetail
    ) {
        pricingDetail.Payment_Frequency__c = application.genesis__Payment_Frequency__c;
        setApplicationFieldsFromPricing(application, pricingDetail);
    }

    public static void setApplicationFieldsFromPricing(
        genesis__Applications__c application, CAN_Pricing_Detail__c pricingDetail
    ) {

        application.genesis__Expected_Start_Date__c = GeneralHelper.getBusinessDate(GeneralHelper.currentSystemDate);
        application.genesis__Expected_First_Payment_Date__c = getFirstPaymentDateByFrequency(
            application.genesis__Expected_Start_Date__c, pricingDetail.Payment_Frequency__c
        );
        if(application.genesis__Expected_Start_Date__c > application.genesis__Expected_Close_Date__c) {
            application.genesis__Expected_Close_Date__c = application.genesis__Expected_Start_Date__c.addDays(1);
        }

        application.genesis__Loan_Amount__c = pricingDetail.Selected_Amount__c;
        application.Maximum_Funding_Amount__c = pricingDetail.Maximum_Amount__c;
        application.genesis__Term__c = pricingDetail.Term__c;
        application.Max_Term__c = pricingDetail.Maximum_Term__c;
        application.Broker_Standard_Commission__c = pricingDetail.Standard_Commission__c;
        application.Buy_Rate__c = pricingDetail.Buy_Rate__c;
        application.Pricing_Factor__c = pricingDetail.Pricing_Factor__c;
        application.Origination_Fee_Percentage__c = pricingDetail.Origination_Fee_Percentage__c;
        application.genesis__Payment_Frequency__c = pricingDetail.Payment_Frequency__c;
        application.GAV__c = pricingDetail.GAV__c;

        Decimal maxRepaymentAmount = application.Maximum_Funding_Amount__c * application.Pricing_Factor__c;
        Decimal repaymentAmount = application.genesis__Loan_Amount__c * application.Pricing_Factor__c;
        Decimal paymentAmount;

        if(application.genesis__Payment_Frequency__c == GeneralConstants.FREQUENCY_DAILY) {
            paymentAmount = repaymentAmount / application.genesis__Term__c / 22;
            application.Max_Payment_Amount__c = maxRepaymentAmount / application.genesis__Term__c / 22;
            application.genesis__Payment_Amount__c = pricingDetail.Daily_Payment_Amount__c;
            application.genesis__Maturity_Date__c = pricingDetail.Daily_End_Date__c;
            application.Contract_Number_of_Payments__c = pricingDetail.Number_Of_Daily_Payments__c;
        } else {
            paymentAmount = repaymentAmount / (application.genesis__Term__c * 365 / 12 / 7).round();
            application.Max_Payment_Amount__c = maxRepaymentAmount / (application.genesis__Term__c * 365 / 12 / 7).round();
            application.genesis__Payment_Amount__c = pricingDetail.Weekly_Payment_Amount__c;
            application.genesis__Maturity_Date__c = pricingDetail.Weekly_End_Date__c;
            application.Contract_Number_of_Payments__c = pricingDetail.Number_Of_Weekly_Payments__c;
        }

        Decimal interestRate = loanCalculatorManagerInstance.getInterestRate(
            application.genesis__Loan_Amount__c, paymentAmount, application.genesis__Expected_Start_Date__c,
            application.genesis__Expected_First_Payment_Date__c, (Integer) application.Contract_Number_of_Payments__c,
            application.genesis__Payment_Frequency__c
        );

        application.genesis__Interest_Rate__c = interestRate;
        application.Total_Repayment_Amount__c = repaymentAmount;
        application.genesis__Total_Estimated_Interest__c = repaymentAmount - application.genesis__Loan_Amount__c;
    }

    public static Boolean hasIncompleteSTIPS(STIPS_Checklist__c stipsCheck) {
        return (
            stipsCheck.Additional_Banks__c
            || stipsCheck.Bank_Verification_Call__c
            || stipsCheck.Borrower_Interview__c
            || stipsCheck.Competitors__c
            || stipsCheck.Federal_Tax_ID__c
            || stipsCheck.Identification__c
            || stipsCheck.Month_to_Date_Bank_Statement__c
            || stipsCheck.Proof_of_Ownership__c
            || stipsCheck.Verification_Call__c
            || stipsCheck.Voided_Check__c
            || stipsCheck.experian_fraud_check__c
            || stipsCheck.business_loan_agreement__c
            || stipsCheck.certification_of_beneficial_owners__c
            || stipsCheck.refinance_agreement__c
            || stipsCheck.third_party_agreement__c
            || stipsCheck.proof_of_business_location__c
        );
    }

    public static String buildApplicationDetailsEmailBody(String body, genesis__Applications__c application, List<Document> documents, STIPS_Checklist__c stipsCheck) {
        body = body.replace('{{APPLICATION_NAME}}', application.Name != null? String.valueOf(application.Name) : '');
        body = body.replace('{{MAX_FUNDING_AMOUNT}}', '$' + String.valueOf(application.Maximum_Funding_Amount__c));
        body = body.replace('{{MAX_TERM}}', String.valueOf(application.Max_Term__c) + ' Months');
        body = body.replace('{{BUY_RATE}}', String.valueOf(application.Buy_Rate__c));
        if(application.Max_Broker_Commission__c != null) {
            body = body.replace('{{MAX_COMMISSION}}', String.valueOf(application.Max_Broker_Commission__c) + '%');
        }
        else{
            body = body.replace('{{MAX_COMMISSION}}', '');
        }
        body = body.replace('{{ORIGINATION_FEE_PERCENTAGE}}', String.valueOf(application.Origination_Fee_Percentage__c) + '%');

        String url = '';
        if(!documents.isEmpty()) {
            if(GeneralHelper.domainUrl.contains('genesisextn.visualforce.com')) {
                url = GeneralHelper.domainUrl.replace('genesisextn.visualforce.com', 'c.documentforce.com/servlet/servlet.ImageServer?');
            } else {
                url = GeneralHelper.domainUrl.replace('.my.salesforce.com', '--c.documentforce.com/servlet/servlet.ImageServer?');
            }
            url += 'id=' + documents[0].Id + '&oid=' + UserInfo.getOrganizationId();
        }

        body = body.replace('{{IMAGE__LOGO}}', url);

        body = body.replace('{{BROKER_PORTAL_LINK}}', GeneralHelper.siteFullURLByName('Partner_Portal'));
        body = buildPartnerPricingSecureLink(application, body);

        body = body.replace('{{STIPS_ITEMS}}', buildSTIPSIncompleteEmailBody(stipsCheck));
        body = buildOfferEmailBody(application, body);

        return body;
    }

    public static String buildPartnerPricingSecureLink(genesis__Applications__c application, String body) {
        if(application.Broker_Account__r.Generate_Secure_Partner_Links__c && application.Type__c == GeneralConstants.LOAN_TYPE_NEW) {
            body = body.replace('{{PARTNER_SECURE_LINK}}', application.Partner_Pricing_Secure_Link__c);
        } else {
            body = body.replace(body.substringBetween('{{PARTNER_PRICING_LINK_START}}','{{PARTNER_PRICING_LINK_END}}'), '');
        }
        body = body.replace('{{PARTNER_PRICING_LINK_START}}', '');
        body = body.replace('{{PARTNER_PRICING_LINK_END}}', '');

        return body;
    }

    public static String buildOfferEmailBody(genesis__Applications__c application, String body) {
        if(application.CAN_Pricing_Details__r.isEmpty()) {
            return body;
        }

        if(application.CAN_Pricing_Details__r.get(0).Maximum_Amount__c >= application.genesis__Requested_Loan_Amount__c
        ) {
            body = body.replace('{{OFFER_APPROVED_STANDARD_START}}', '');
            body = body.replace('{{OFFER_APPROVED_STANDARD_END}}', '');
            body = body.replace(body.substringBetween('{{OFFER_APPROVED_COUNTER_OFFER_START}}', '{{OFFER_APPROVED_COUNTER_OFFER_END}}'), '');
            body = body.replace('{{OFFER_APPROVED_COUNTER_OFFER_START}}', '');
            body = body.replace('{{OFFER_APPROVED_COUNTER_OFFER_END}}', '');
            body = body.replace('{{STANDARD_START}}', '');
            body = body.replace('{{STANDARD_END}}', '');
            body = body.replace(body.substringBetween('{{COUNTER_OFFER_START}}', '{{COUNTER_OFFER_END}}'), '');
            body = body.replace('{{COUNTER_OFFER_START}}', '');
            body = body.replace('{{COUNTER_OFFER_END}}', '');
        } else {
            body = body.replace(body.substringBetween('{{STANDARD_START}}','{{STANDARD_END}}'), '');
            body = body.replace('{{STANDARD_START}}', '');
            body = body.replace('{{STANDARD_END}}', '');
            body = body.replace('{{COUNTER_OFFER_START}}', '');
            body = body.replace('{{COUNTER_OFFER_END}}', '');
            body = body.replace('{{OFFER_APPROVED_COUNTER_OFFER_START}}', '');
            body = body.replace('{{OFFER_APPROVED_COUNTER_OFFER_END}}', '');
            body = body.replace(body.substringBetween('{{OFFER_APPROVED_STANDARD_START}}', '{{OFFER_APPROVED_STANDARD_END}}'), '');
            body = body.replace('{{OFFER_APPROVED_STANDARD_START}}', '');
            body = body.replace('{{OFFER_APPROVED_STANDARD_END}}', '');
        }
        return body;
    }

    public static String buildApplicationDetailsEmailSubject(String subject, genesis__Applications__c application) {
        subject = subject.replace('{{LEGAL_ENTITY_NAME}}', application.genesis__Account__r.Name);
        if(application.Broker_Contact__c != null) {
            subject = subject.replace('{{BROKER_COMPANY_NAME}}', ' - ' + application.Broker_Contact__r.Account.Name);
        }
        else{
            subject = subject.replace('{{BROKER_COMPANY_NAME}}', '');
        }

        if(application.genesis__Account__r.Merchant_ID__c != Null) {
            subject = subject.replace('{{MERCHANT_ID}}', String.valueOf(application.genesis__Account__r.Merchant_ID__c));
        }
        else{
            subject = subject.replace('{{MERCHANT_ID}}', '');
        }
        return subject;
    }

    public static String buildSTIPSIncompleteEmailBody(STIPS_Checklist__c stipsCheck) {
        String stipsCheckItems = '';
        stipsCheckItems += stipsCheck.Federal_Tax_ID__c? '<li>Federal Tax ID</li>' :'';
        stipsCheckItems += stipsCheck.Month_to_Date_Bank_Statement__c? '<li>Month to Date Bank Statement</li>' : '';
        stipsCheckItems += stipsCheck.Borrower_Interview__c? '<li>Additional Information Needed</li>' : '';
        stipsCheckItems += stipsCheck.Proof_of_Ownership__c? '<li>Proof of Ownership</li>' : '';
        stipsCheckItems += stipsCheck.Identification__c? '<li>Driver\'s License or Government Issued ID for ' + (
            String.valueOf(stipsCheck.Guarantors_Whose_Identity_Not_Verified__c) != null ? String.valueOf(stipsCheck.Guarantors_Whose_Identity_Not_Verified__c) : ''
        ) + '</li>' : '';
        stipsCheckItems += stipsCheck.Voided_Check__c? '<li>Voided Check for Acct # ending ' + (
            String.valueOf(stipsCheck.Last_Four_Bank_Account_Number__c) != null ? String.valueOf(stipsCheck.Last_Four_Bank_Account_Number__c) : ''
        ) + '</li>' : '';
        stipsCheckItems += stipsCheck.Competitors__c? '<li>Payoff Letter for Competitors ' + (
            String.valueOf(stipsCheck.Competitor_Names__c) != null ? String.valueOf(stipsCheck.Competitor_Names__c) : ''
        ) + ' (Total payoff must not exceed 50% of the Max Funding Amount)</li>' : '';
        stipsCheckItems += stipsCheck.Additional_Banks__c? '<li>12 months of most recent bank statements, if funding amount > $150,000</li>' : '';
        stipsCheckItems += stipsCheck.Bank_Verification_Call__c? '<li>Bank Verification Call or Decision Logic Signup</li>' : '';
        stipsCheckItems += stipsCheck.Verification_Call__c? '<li>Terms Verification Call if funding >= 175,000</li>' : '';

        stipsCheckItems += stipsCheck.experian_fraud_check__c? '<li>Verification Call (Experian Fraud Alert)</li>' : '';
        stipsCheckItems += stipsCheck.business_loan_agreement__c? '<li>Business Loan Agreement</li>' : '';
        stipsCheckItems += stipsCheck.certification_of_beneficial_owners__c? '<li>Certification of Beneficial Owners Form</li>' : '';
        stipsCheckItems += stipsCheck.refinance_agreement__c? '<li>Refinance Agreement</li>' : '';
        stipsCheckItems += stipsCheck.third_party_agreement__c? '<li>Third Party Agreement</li>' : '';
        stipsCheckItems += stipsCheck.proof_of_business_location__c? '<li>Proof of Business Location</li>' : '';
        return stipsCheckItems;
    }

    public static void validateApplicationRequiredFields(genesis__Applications__c application) {
        if(String.isBlank(application.SIC_Code__c) || application.Business_Start_Date__c == null) {
            CustomError.addError(application, 'SIC code and Business Start Date should not be blank');
        }
    }

    public static void validateApplicationOnCreditCheck(genesis__Applications__c application) {
        if(!APP_STATUSES_FOR_CREDIT_CHECK.contains(application.genesis__Status__c)) {
            CustomError.addError(application, 'Credit Consent is not Checked');
        }
    }

    public static Map<String, List<String>> addEmailAddressToBrokerNotification(genesis__Applications__c application, String salesRepEmailAddress) {
        List<String> toAddresses = new List<String>();
        List<String> ccAddresses = new List<String>();
        Map<String, List<String>> stringToEmailAddressesMap = new Map<String, List<String>>();
        if(application.Broker_Contact__c != null && application.Broker_Contact__r.Email != null) {
            if (application.Type__c == GeneralConstants.LOAN_TYPE_NEW) {
                toAddresses.add(application.Broker_Contact__r.Email);
                if(salesRepEmailAddress != null) {
                    ccAddresses.add(salesRepEmailAddress);
                }
                if(application.Broker_Contact__r.Account != null && application.Broker_Contact__r.Account.Email_cc__c != null) {
                    for(String additionalEmail :application.Broker_Contact__r.Account.Email_cc__c.split(',')) {
                        ccAddresses.add(additionalEmail);
                    }
                }
            } else if(application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL && salesRepEmailAddress != null
            ) {
                toAddresses.add(salesRepEmailAddress);
                if(application.Broker_Contact__r.Account != null && application.Broker_Contact__r.Account.Email_cc__c != null) {
                    for(String additionalEmail :application.Broker_Contact__r.Account.Email_cc__c.split(',')) {
                        ccAddresses.add(additionalEmail);
                    }
                }
            }
        }
        stringToEmailAddressesMap.put('toAddresses', toAddresses);
        stringToEmailAddressesMap.put('ccAddresses', ccAddresses);
        return stringToEmailAddressesMap;
    }

    public static void setConcurrentApplicationFields(genesis__Applications__c application, loan__Loan_Account__c loanAccount) {
        application.Concurrent_Principal_Amount__c = loanAccount.loan__Disbursed_Amount__c + application.genesis__Loan_Amount__c;
        application.Concurrent_Repayment_Amount__c = (application.genesis__Loan_Amount__c * loanAccount.Application__r.Pricing_Factor__c);
        application.Concurrent_Cost_Of_Funds__c = loanAccount.Application__r.Total_Repayment_Amount__c + application.Concurrent_Repayment_Amount__c
                                                    - application.Concurrent_Principal_Amount__c;
        application.Total_Repayment_Amount__c = application.Concurrent_Principal_Amount__c + application.Concurrent_Cost_Of_Funds__c;
        application.genesis__Maturity_Date__c = loanAccount.loan__Last_Installment_Date__c;
        application.genesis__Payment_Amount__c = (application.genesis__Loan_Amount__c * loanAccount.Application__r.Pricing_Factor__c) / loanAccount.Remaining_Number_of_Payments__c;
        application.genesis__Payment_Amount__c += loanAccount.loan__Payment_Amount__c;
        application.Broker_Standard_Commission__c = application.Max_Broker_Commission__c;
        application.Contract_Number_of_Payments__c = loanAccount.loan__Number_of_Installments__c;
    }

    public static void setRenewalApplicationFieldsFromLoanAccount(genesis__Applications__c application, loan__Loan_Account__c loanAccount) {
        application.CLContract__c = null;
        application.Renewal_Concurrent_LoanAccount__c = loanAccount.Id;
        application.Annual_Volume__c = loanAccount.Application__r.Annual_Volume__c;
        application.Sales_Rep__c = loanAccount.Application__r.Sales_Rep__c;
        application.OwnerId = loanAccount.Application__r.OwnerId;
        application.Renewal_Contract_Number__c = loanAccount.Name;
    }

    public static void handleStatusChangedOnBeforeUpdate(
        genesis__Applications__c application, genesis__Applications__c oldApplication,
        Map<String, List<genesis__Applications__c>> applicationByStatusChange
    ) {
        if(isStatusChanged(application, oldApplication)) {
            groupApplicationByStatusChange(application, applicationByStatusChange);
            setApplicationFieldsOnBeforeStatusChanged(application, oldApplication);
        }
    }

    public static void setApplicationFieldsOnBeforeStatusChanged(
        genesis__Applications__c application, genesis__Applications__c oldApplication
    ) {
        application.Last_Status_Update_Date__c = GeneralHelper.currentSystemDateTime;
        application.Overall_Status__c = appStatusToOverAllStatus.get(application.genesis__Status__c);
        if(application.genesis__Status__c == STATUS_APPROVED) {
            application.Contract_Approved_Date__c = GeneralHelper.currentSystemDate;
        }
        if(application.genesis__Status__c == STATUS_DECLINED) {
            application.Application_Declined_Date__c = GeneralHelper.currentSystemDate;
        }
    }

    public static void groupApplicationByStatusChange(
        genesis__Applications__c application, Map<String, List<genesis__Applications__c>> applicationByStatusChange
    ) {
        String status = application.genesis__Status__c;
        if(!applicationByStatusChange.containsKey(status)) {
            applicationByStatusChange.put(status, new List<genesis__Applications__c>());
        }
        applicationByStatusChange.get(status).add(application);
    }

    public static void isConsentChecked(
        genesis__Applications__c application, genesis__Applications__c oldApplication,
        List<genesis__Applications__c> consentApplications
    ) {
        if(application.Credit_Check_Consent__c != oldApplication.Credit_Check_Consent__c
            && application.Credit_Check_Consent__c && application.genesis__Status__c != Applications.STATUS_DECLINED
        ) {
            validateApplicationRequiredFields(application);
            application.genesis__Status__c = Applications.STATUS_GUARANTOR_CREDIT_CHECK;
            consentApplications.add(application);
        }
    }

    public static void isRenewalConcurrentFieldUpdate(
        genesis__Applications__c application, genesis__Applications__c oldApplication,
        Map<Id, genesis__Applications__c> renewalAndConcurrentContractIdToApplication
    ) {
        if(application.Renewal_Concurrent_LoanAccount__c != oldApplication.Renewal_Concurrent_LoanAccount__c
            && application.Renewal_Concurrent_LoanAccount__c != null
        ) {
            if(application.CLContract__c == null) {
                renewalAndConcurrentContractIdToApplication.put(
                    application.Renewal_Concurrent_LoanAccount__c, application
                );
            } else {
                application.Renewal_Concurrent_LoanAccount__c = oldApplication.Renewal_Concurrent_LoanAccount__c;
            }
        }
    }

    public static String buildBrokerDeclineTemplateSubject(genesis__Applications__c application, String emailSubject){
        emailSubject = application.genesis__Account__r.Merchant_ID__c != null || application.genesis__Account__r.Name != null
            ? emailSubject.replace('{{BORROWER_ID}}', (String.valueOf(application.genesis__Account__r.Merchant_ID__c) + '-' + String.valueOf(application.genesis__Account__r.Name)))
            : emailSubject.replace('{{BORROWER_ID}}', '');
        emailSubject = application.Broker_Contact__c != null && application.Broker_Contact__r.Account.Name != null
            ? emailSubject.replace('{{BROKER_ACCOUNT_NAME}}', String.valueOf(application.Broker_Contact__r.Account.Name)) : emailSubject.replace('{{BROKER_ACCOUNT_NAME}}', '');
        return emailSubject;
    }

    public static String buildBrokerDeclineTemplateBody(genesis__Applications__c application, String emailBody){
        emailBody = emailBody.replace('<![CDATA[]]>','');
        emailBody = emailBody.replace('<![CDATA[','');
        emailBody = emailBody.replace(']]>','');
        emailBody = application.genesis__Account__r.Merchant_ID__c != null || application.genesis__Account__r.Name != null
            ? emailBody.replace('{{BORROWER_ID}}', (String.valueOf(application.genesis__Account__r.Merchant_ID__c) + '-' + String.valueOf(application.genesis__Account__r.Name)))
            : emailBody.replace('{{BORROWER_ID}}', '');
        emailBody = application.Decline_Reasons__c != null
            ? emailBody.replace('{{DECLINE_REASON}}', String.valueOf(application.Decline_Reasons__c)) : emailBody.replace('{{DECLINE_REASON}}', '');
        emailBody = application.genesis__Account__r.Business_Name__c != null
            ? emailBody.replace('{{BUSINESS_NAME}}', String.valueOf(application.genesis__Account__r.Business_Name__c)) : emailBody.replace('{{BUSINESS_NAME}}', '');
        emailBody = application.genesis__Account__r.Merchant_ID__c != null
            ? emailBody.replace('{{MERCHANT_ID}}', String.valueOf(application.genesis__Account__r.Merchant_ID__c)) : emailBody.replace('{{MERCHANT_ID}}', '');
        emailBody = application.Name != null
            ? emailBody.replace('{{CONTRACT_NUMBER}}', String.valueOf(application.Name)) : emailBody.replace('{{CONTRACT_NUMBER}}', '');
        emailBody = application.Broker_Contact__c != null && application.Broker_Contact__r.Account.Name != null
            ? emailBody.replace('{{SALES_REP_NAME}}', String.valueOf(application.Broker_Contact__r.Account.Name)) : emailBody.replace('{{SALES_REP_NAME}}', '');

        String dBAAddress = '';
        if(application.genesis__Account__r.BillingStreet != null) {
            dBAAddress += String.valueOf(application.genesis__Account__r.BillingStreet) + ',';
        }
        if(application.genesis__Account__r.BillingCity != null) {
            dBAAddress += String.valueOf(application.genesis__Account__r.BillingCity) + ',';
        }
        if(application.genesis__Account__r.BillingState != null) {
            dBAAddress += String.valueOf(application.genesis__Account__r.BillingState) + ',';
        }
        if(application.genesis__Account__r.BillingPostalCode != null) {
            dBAAddress += String.valueOf(application.genesis__Account__r.BillingPostalCode);
        }
        emailBody = application.genesis__Account__r.BillingStreet != null || application.genesis__Account__r.BillingCity != null
            || application.genesis__Account__r.BillingState != null || application.genesis__Account__r.BillingPostalCode != null
            ? emailBody.replace('{{DBA_ADDRESS}}', dBAAddress) : emailBody.replace('{{DBA_ADDRESS}}', '');
        emailBody = application.genesis__Account__r.Industry != null
            ? emailBody.replace('{{SIC_TYPE}}', application.genesis__Account__r.Industry) : emailBody.replace('{{SIC_TYPE}}', '');
        emailBody = application.Business_Type__c != null
            ? emailBody.replace('{{ENTITY_TYPE}}', String.valueOf(application.Business_Type__c)) : emailBody.replace('{{ENTITY_TYPE}}', '');
        emailBody = application.Business_Start_Date__c != null
            ? emailBody.replace('{{BUSINESS_START_DATE}}', String.valueOf(application.Business_Start_Date__c)) : emailBody.replace('{{BUSINESS_START_DATE}}', '');
        emailBody = application.Primary_Guarantor__c != null && application.Primary_Guarantor__r.Name != null
            ? emailBody.replace('{{GUARANTOR}}', String.valueOf(application.Primary_Guarantor__r.Name)) : emailBody.replace('{{GUARANTOR}}', '');
        return emailBody;
    }

    public static void setFieldsOnBeforeUpdate(genesis__Applications__c application, genesis__Applications__c oldApplication){

        Set<String> uwDecisionStatuses = new Set<String>{
            STATUS_PENDING_DOCS, STATUS_READY_TO_FUND, STATUS_FUNDING_IN_PROGRESS, STATUS_APPROVED, STATUS_DECLINED
        };

        if(application.Underwriter__c != oldApplication.Underwriter__c && application.Underwriter__c != null
            && application.UW_Assigned_Date__c == null
        ) {
            application.UW_Assigned_Date__c = GeneralHelper.currentSystemDateTime;
        }

        if(application.Funding_Audit_Completed__c != oldApplication.Funding_Audit_Completed__c && application.Funding_Audit_Completed__c) {
            application.Funding_Audit_Completed_Date__c = GeneralHelper.currentSystemDateTime;
        }

        if(isStatusChanged(application, oldApplication)) {

            application.Previous_Status__c = oldApplication.genesis__Status__c;

            if(application.genesis__Status__c == STATUS_DOCS_IN && application.Submission_Date__c == null) {
                application.Submission_Date__c = GeneralHelper.currentSystemDateTime;
            } else if(application.genesis__Status__c == STATUS_READY_TO_FUND && application.Sent_to_Funding_Team__c == null) {
                application.Sent_to_Funding_Team__c = GeneralHelper.currentSystemDateTime;
            }

            if(uwDecisionStatuses.contains(application.genesis__Status__c) && application.UW_Decision_Made__c == null
                && application.Submission_Date__c != null
            ) {
                application.UW_Decision_Made__c = GeneralHelper.currentSystemDateTime;
            }
        }

        if(application.Confirmed_Fraud_Flag__c != oldApplication.Confirmed_Fraud_Flag__c && !application.Confirmed_Fraud_Flag__c) {
            application.Fraud_Reason__c = null;
        }

        List<String> declineReasonList = application.Decline_Reasons__c != null ? application.Decline_Reasons__c.split(';') : new List<String>();

        if(application.genesis__Status__c == STATUS_DECLINED && application.Decline_Reasons__c != null
            && (oldApplication.decline_until_date__c == null || oldApplication.decline_until_date__c < GeneralHelper.currentSystemDate)
        ) {
            for(String declineReason : declineReasonList) {
                if(BusinessRules.INELIGIBLE_DENIAL_REASONS_FOR_DECLINE_UNTIL_DATE.contains(declineReason)) {
                    Integer declineUntilDays = Integer.valueOf(CustomSettingsHelper.generalSettings.Decline_Until_Days__c);
                    application.decline_until_date__c = GeneralHelper.currentSystemDate.addDays(declineUntilDays);
                    break;
                }
            }
        }
    }

    public static String buildReadyToFundEmailBody(String body, genesis__Applications__c application, List<Document> documents) {
        body = body.replace('{{CUSTOMER_ACCOUNT_NAME}}', application.genesis__Account__r.Name != null ? String.valueOf(application.genesis__Account__r.Name) : '');
        body = body.replace('{{MERCHANT_ID}}', application.genesis__Account__r.Merchant_ID__c != null ? String.valueOf(application.genesis__Account__r.Merchant_ID__c) : '');
        body = body.replace('{{APPLICATION_NAME}}', application.Name != null? String.valueOf(application.Name) : '');
        body = body.replace('{{FUNDING_AMOUNT}}', '$' + application.genesis__Loan_Amount__c != null ? String.valueOf(application.genesis__Loan_Amount__c) : '');
        body = body.replace('{{COMMISSION_AMOUNT}}', '$' + application.Broker_Commission_Amount__c != null ? String.valueOf(application.Broker_Commission_Amount__c) : '');

        String url = '';
        if(!documents.isEmpty()) {
            if(GeneralHelper.domainUrl.contains('genesisextn.visualforce.com')) {
                url = GeneralHelper.domainUrl.replace('genesisextn.visualforce.com', 'c.documentforce.com/servlet/servlet.ImageServer?');
            } else {
                url = GeneralHelper.domainUrl.replace('.my.salesforce.com', '--c.documentforce.com/servlet/servlet.ImageServer?');
            }
            url += 'id=' + documents[0].Id + '&oid=' + UserInfo.getOrganizationId();
        }

        body = body.replace('{{IMAGE__LOGO}}', url);
        return body;
    }

    public static String buildReadyToFundEmailSubject(String subject, genesis__Applications__c application) {
        subject = subject.replace('{{CUSTOMER_ACCOUNT_NAME}}', application.genesis__Account__r.Name != null ? String.valueOf(application.genesis__Account__r.Name) : '');
        return subject;
    }

    public static void setContractAndAccountFieldsOnRenewalApplicationDecline(
        genesis__Applications__c application, loan__Loan_Account__c loanAccount, Account borrowerAccount
    ) {
        loanAccount.Last_Auto_Renewal_Close_Date__c = GeneralHelper.currentSystemDate;
        loanAccount.Auto_Renewed__c = false;
        borrowerAccount.Is_Exclude_From_Auto_Renewal_Process__c = false;
        borrowerAccount.Auto_Renewed_App_Declined_Date__c = GeneralHelper.currentSystemDate;

        List<String> declineReasonList =
            application.Decline_Reasons__c != null ? application.Decline_Reasons__c.split(';') : new List<String>();

        for(String declineReason : declineReasonList) {
            if(BusinessRules.INELIGIBLE_DENIAL_REASONS_FOR_AUTO_RENEWAL.contains(declineReason)) {
                loanAccount.Auto_Renewed__c = true;
                borrowerAccount.Is_Exclude_From_Auto_Renewal_Process__c = true;
                break;
            }
        }
    }

    public static String buildApplicationEmailTermMatrixBody(String body, genesis__Applications__c application, List<Document> documents, STIPS_Checklist__c stipsCheck)
    {

        Map<Integer, CAN_Pricing_Detail__c> pricingOptionsByTerm = CANPricingDetails.buildPricingOptionsByTerm(application.CAN_Pricing_Details__r);
        String applicationName = application.Name != null ? String.valueOf(application.Name) : '';

        String matrixBody = '<table class="app-details" cols="5">';
        matrixBody += '<tr><td style="font-size:15px" colspan="5">Application Number:&nbsp&nbsp&nbsp&nbsp';
        matrixBody +=  applicationName + '</td></tr>';
        matrixBody += '<tr><td style="font-size:15px" colspan="5">Product:&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp  Working Capital Loan</td></tr>';
        matrixBody += '<tr><td style="font-size:15px" colspan="5">Payment Frequency:&nbsp&nbsp&nbsp&nbsp&nbspDaily / Weekly</td></tr>';
        matrixBody += '<tr height="10px"></tr>';
        matrixBody += '<tr><th style="width:20%">Funding Amount</th>';
        matrixBody += '<th style="width:20%">Term (mo)</th>';
        matrixBody += '<th style="width:20%">Buy Rate</th>';
        matrixBody += '<th style="width:20%">Orig. Fee</th>';
        matrixBody += '<th style="width:20%">Max Commission</th></tr>';

        String maxBrokerCommission = '';
        for(Integer term : pricingOptionsByTerm.keySet()) {
            if (pricingOptionsByTerm.get(term).max_term_broker_commission__c != null){
                 maxBrokerCommission = String.valueOf(Integer.valueOf(pricingOptionsByTerm.get(term).max_term_broker_commission__c));
            }

            matrixBody += '<tr><td align="center">$' + String.valueOf(pricingOptionsByTerm.get(term).Maximum_Amount__c.format()) + '</td>' +
                            '<td align="center">' + String.valueOf(pricingOptionsByTerm.get(term).Term__c) + '</td>' +
                            '<td align="center">' + String.valueOf(pricingOptionsByTerm.get(term).Buy_Rate__c) + '</td>' +
                            '<td align="center">' + String.valueOf(pricingOptionsByTerm.get(term).Origination_Fee_Percentage__c) + '%</td>' +
                            '<td align="center">' + maxBrokerCommission + '%</td>' +
                        '</tr>';

            maxBrokerCommission = '';
        }

        matrixBody += '<tr><td colspan="5" style="font-size:12px">*Funding Amount with Max Commission.</td></tr></table>';

        body = body.replace('{{TERM_MATRIX}}', matrixBody);

        String url = '';
        if(!documents.isEmpty()) {
            if(GeneralHelper.domainUrl.contains('genesisextn.visualforce.com')) {
                url = GeneralHelper.domainUrl.replace('genesisextn.visualforce.com', 'c.documentforce.com/servlet/servlet.ImageServer?');
            } else {
                url = GeneralHelper.domainUrl.replace('.my.salesforce.com', '--c.documentforce.com/servlet/servlet.ImageServer?');
            }
            url += 'id=' + documents[0].Id + '&oid=' + UserInfo.getOrganizationId();
        }

        body = body.replace('{{IMAGE__LOGO}}', url);

        body = body.replace('{{BROKER_PORTAL_LINK}}', GeneralHelper.siteFullURLByName('Partner_Portal'));
        body = buildPartnerPricingSecureLink(application, body);

        body = body.replace('{{STIPS_ITEMS}}', buildSTIPSIncompleteEmailBody(stipsCheck));
        body = buildOfferEmailBody(application, body);

        return body;
    }


    private class ApplicationsException extends Exception {}
}