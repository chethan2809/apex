public class BusinessRules {

    public static final String DENIAL_REASON_FICO_SCORE = 'FICO';
    public static final String DENIAL_REASON_OPEN_TRADES = 'Open Trades';
    public static final String DENIAL_REASON_TOTAL_TRADES = 'Total Trades';
    public static final String DENIAL_REASON_BK_RISK_SCORE = 'Bankruptcy Risk Score';
    public static final String DENIAL_REASON_MORTGAGE_DELINQUENCY = 'Mortgage Delinquency';
    public static final String DENIAL_REASON_RECENT_BANKRUPTCY = 'Recent Bankruptcy';
    public static final String DENIAL_REASON_OPEN_BANKRUPTCY = 'Open Bankruptcy';
    public static final String DENIAL_REASON_LIEN_JUDGEMENT = 'Lien/Judgment Balance';
    public static final String DENIAL_REASON_COMPETITOR_STACKING = 'Competitor Stacking';
    public static final String DENIAL_REASON_PROHIBITED_INDUSTRY = 'Prohibited Industry';
    public static final String DENIAL_REASON_TIME_IN_BUSINESS = 'Time in Business';
    public static final String DENIAL_REASON_CAN_RISK_SCORE = 'CAN Model Risk Score';
    public static final String DENIAL_REASON_COMPETITOR_BALANCES = 'Competitor Balance(s)';
    public static final String DENIAL_REASON_BANK_DEPOSITS = 'Bank Deposits (#)';
    public static final String DENIAL_REASON_DEBT_CONSOLIDATOR_PRESENT = 'Debt Consolidator Present';
    public static final String DENIAL_REASON_RECENT_MISSED_PAYMENTS = 'Recent Missed Payments';
    public static final String DENIAL_REASON_OFFERS_EXPIRED = 'Offers Expired';
    public static final String DENIAL_REASON_CLOSED_EXPIRED = 'Closed Expired';
    public static final String DENIAL_REASON_NEGATIVE_HISTORY = 'Negative History with CAN';
    public static final String DENIAL_REASON_NEGATIVE_HISTORY_WITH_COMPETITOR = 'Negative History with Competitor';
    public static final String DENIAL_REASON_BANK_BALANCES = 'Bank Balances';
    public static final String TASK_NAME_OCR_FRAUD_ALERT = 'OCR Fraud Alert';
    public static final String TASK_NAME_EXPERIAN_FRAUD_ALERT = 'Experian Fraud Alert';
    public static final String VERIFICATION_TYPE_AUTOMATED = 'AUTOMATED';
    public static final String VERIFICATION_TYPE_MANUAL = 'MANUAL';
    public static final String FRAUD_ALERT_FRAUD_STATEMENT = 'FRAUD VICTIM ALERT FRAUDULENT';
    public static final String FRAUD_ALERT_SECURITY_STATEMENT = 'SECURITY ALERT';
    public static final String DENIAL_REASON_ACTIVE_APPLICATION_OR_CONTRACT = 'Active Application or Contract Present';
    public static final String DENIAL_REASON_NOT_ELIGIBLE_FOR_MINIMUM_FUNDING = 'Not Eligible For Minimum Funding';
    public static final String DENIAL_REASON_NOT_ELIGIBLE_FOR_RENEWAL_FUNDING = 'Not Eligible For Renewal Funding';
    public static final String DENIAL_REASON_CUSTOMER_NOT_INTERESTED = 'Customer Not Interested';
    public static final String DENIAL_REASON_BANK_ACCOUNTS_REQUIRED = 'Business Bank Account Required';

    public static final Set<String> INELIGIBLE_DENIAL_REASONS_FOR_AUTO_RENEWAL = new Set<String> {
        'Competitor Stacking', 'Bank Deposits (#)', 'Debt Consolidator Present', 'Not Eligible For Minimum Funding',
        'Bank Balances', 'Customer Not Interested', 'Competitor Balance(s)', 'Elevated Risk', 'Incomplete Submission',
        'Information Cannot Be Verified', 'Negative History with Competitor', 'Not Eligible For Minimum Funding',
        'Prohibited Industry', 'Proof of Ownership', 'Recent Missed Payments', 'Business Bank Account Required',
        'Legal Entity Not in Good Standing'
    };

    public static final Set<String> INELIGIBLE_DENIAL_REASONS_FOR_DECLINE_UNTIL_DATE = new Set<String> {
        'Negative History with Competitor', 'Competitor Stacking', 'Debt Consolidator Present',
        'Legal Entity Not in Good Standing', 'Competitor Balance(s)', 'Elevated Risk', 'Excessive Current CAN Balance',
        'Information Cannot Be Verified', 'Prohibited Industry'
    };

    public static void generalDeclineRules(genesis__Applications__c application, loan__Loan_Account__c clContract, Account accountDetail) {
        if(((application.Type__c == GeneralConstants.LOAN_TYPE_NEW || application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL)
            && accountDetail.Legacy_Negative_CAN_History__c == true) || (application.Confirmed_Fraud_Flag__c))
        {
            application.Confirmed_Fraud_Flag__c = false;
            Applications.setDenialReasons(application, DENIAL_REASON_NEGATIVE_HISTORY);
        }

        if(accountDetail.Legacy_Percent_Paid__c < 50 && application.Is_EIS_Renewal__c) {
            Applications.setDenialReasons(application, DENIAL_REASON_NOT_ELIGIBLE_FOR_RENEWAL_FUNDING);
        }

        if(application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL && clContract != null) {
            renewalEligibilityRule(application, clContract, accountDetail);
        }
    }

    public static void renewalEligibilityRule(genesis__Applications__c application, loan__Loan_Account__c clContract, Account accountDetail) {
        Set<String> clContractActiveStatus = new Set<String> {'Active - Good Standing', 'Active - Bad Standing'};
        Set<String> clContractInActiveStatus = new Set<String> {
            'Closed - Obligations met', 'Closed- Written Off', 'Closed - Refinanced', 'Closed - Premature'
        };

        if(clContract.loan__Product_Type__c == GeneralConstants.PRODUCT_TYPE_LOAN
            && (clContract.Percentage_Paid__c < 50 || clContractActiveStatus.contains(clContract.loan__Loan_Status__c))
            && ((clContract.loan__Frequency_of_Loan_Payment__c.equalsIgnoreCase(GeneralConstants.FREQUENCY_DAILY)
                && clContract.Max_Number_Of_Missed_Payments__c > 2)
            || (clContract.loan__Frequency_of_Loan_Payment__c.equalsIgnoreCase(GeneralConstants.FREQUENCY_WEEKLY)
                && clContract.Max_Number_Of_Missed_Payments__c > 1) || accountDetail.Legacy_Negative_CAN_History__c == true)
        ) {
            Applications.setDenialReasons(application, DENIAL_REASON_RECENT_MISSED_PAYMENTS);
        }

        if(clContract.loan__Product_Type__c == GeneralConstants.PRODUCT_TYPE_LOAN
            && clContractInActiveStatus.contains(clContract.loan__Loan_Status__c)
            && ((clContract.loan__Frequency_of_Loan_Payment__c.equalsIgnoreCase(GeneralConstants.FREQUENCY_DAILY)
                && clContract.Max_Number_Of_Missed_Payments__c > 20)
            || (clContract.loan__Frequency_of_Loan_Payment__c.equalsIgnoreCase(GeneralConstants.FREQUENCY_WEEKLY)
                && clContract.Max_Number_Of_Missed_Payments__c > 4) || accountDetail.Legacy_Negative_CAN_History__c == true)
        ){
            Applications.setDenialReasons(application, DENIAL_REASON_RECENT_MISSED_PAYMENTS);
        }

        if(clContract.loan__Product_Type__c == GeneralConstants.PRODUCT_TYPE_MCA
            && (clContractActiveStatus.contains(clContract.loan__Loan_Status__c)
                || clContractInActiveStatus.contains(clContract.loan__Loan_Status__c))
            && (accountDetail.Legacy_Turn_Ratio__c > 1.3 || accountDetail.Legacy_Negative_CAN_History__c == true)
        ) {
            Applications.setDenialReasons(application, DENIAL_REASON_RECENT_MISSED_PAYMENTS);
        }
    }

    public static void experianConsumerDeclineRules(genesis__Applications__c application, Credit_Report_Detail__c creditReport) {
        if(application.Type__c == GeneralConstants.LOAN_TYPE_NEW || application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL) {
            if(Integer.valueOf(creditReport.Personal_FICO_Score__c) < 600) {
                Applications.setDenialReasons(application, DENIAL_REASON_FICO_SCORE);
            }
            if(Integer.valueOf(creditReport.No_Of_Open_Trades__c) < 1) {
                Applications.setDenialReasons(application, DENIAL_REASON_OPEN_TRADES);
            }
            if(Integer.valueOf(creditReport.Total_No_Trades_Count__c) < 3) {
                Applications.setDenialReasons(application, DENIAL_REASON_TOTAL_TRADES);
            }
            if(Integer.valueOf(creditReport.Bankruptcy_Risk_Score__c) < 550) {
                Applications.setDenialReasons(application, DENIAL_REASON_BK_RISK_SCORE);
            }
            if(Integer.valueOf(creditReport.Total_No_Late_Mortgage_Count__c) >= 1){
                Applications.setDenialReasons(application, DENIAL_REASON_MORTGAGE_DELINQUENCY);
            }
            if(creditReport.Is_Recent_Bankruptcy__c) {
                Applications.setDenialReasons(application, DENIAL_REASON_RECENT_BANKRUPTCY);
            }
            if(creditReport.Is_Open_Bankruptcy__c) {
                Applications.setDenialReasons(application, DENIAL_REASON_OPEN_BANKRUPTCY);
            }
        }
    }

    public static void experianBusinessDeclineRules(genesis__Applications__c application, Credit_Report_Detail__c creditReport) {
        if(application.Type__c == GeneralConstants.LOAN_TYPE_NEW || application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL) {
            if(Integer.valueOf(creditReport.Tax_Liens__c) > 175000) {
                Applications.setDenialReasons(application, DENIAL_REASON_LIEN_JUDGEMENT);
            }
            if(Integer.valueOf(creditReport.Judgement_Liens__c) > 175000) {
                Applications.setDenialReasons(application, DENIAL_REASON_LIEN_JUDGEMENT);
            }
            if(creditReport.Is_Recent_Bankruptcy__c) {
                Applications.setDenialReasons(application, DENIAL_REASON_RECENT_BANKRUPTCY);
            }
            if(creditReport.Is_Open_Bankruptcy__c) {
                Applications.setDenialReasons(application, DENIAL_REASON_OPEN_BANKRUPTCY);
            }
        }
        if(application.Type__c == GeneralConstants.LOAN_TYPE_NEW) {
            if(creditReport.Competitor_Judgement__c) {
                Applications.setDenialReasons(application, DENIAL_REASON_NEGATIVE_HISTORY_WITH_COMPETITOR);
            }
        }
    }

    public static void canScoringDeclineRules(genesis__Applications__c application, Credit_Report_Detail__c creditReport) {
        if(application.Type__c == GeneralConstants.LOAN_TYPE_NEW && creditReport.CAN_Scoring__c >= 17.50) {
            Applications.setDenialReasons(application, DENIAL_REASON_CAN_RISK_SCORE);
        } else if(application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL && creditReport.CAN_Scoring__c >= 29.2) {
            Applications.setDenialReasons(application, DENIAL_REASON_CAN_RISK_SCORE);
        }
    }

    public static genesis__Applications__c industryDeclineRulesAndUWTask(genesis__Applications__c application) {
        genesis__Applications__c declineApplication = new genesis__Applications__c(Id = application.Id);
        declineApplication.Decline_Reasons__c = application.Decline_Reasons__c;
        declineApplication.genesis__Status__c = application.genesis__Status__c;

        if(application.Type__c == GeneralConstants.LOAN_TYPE_NEW || application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL) {
            if(application.Industry_Rating__c == 'Prohibited') {
                Applications.setDenialReasons(declineApplication, DENIAL_REASON_PROHIBITED_INDUSTRY);
            }
            if(application.Time_In_Business__c < 3) {
                Applications.setDenialReasons(declineApplication, DENIAL_REASON_TIME_IN_BUSINESS);
            }
        }
        return declineApplication;
    }

    public static void ocrolusDeclineRules(genesis__Applications__c application, CAN_Ocrolus_Report__c ocrolusReport) {
        if(application.Type__c == GeneralConstants.LOAN_TYPE_NEW || application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL) {
            if(ocrolusReport.Number_Of_Competitors__c >=3) {
                Applications.setDenialReasons(application, DENIAL_REASON_COMPETITOR_STACKING);
            }
            if(ocrolusReport.Number_Of_Deposits__c < 3) {
                Applications.setDenialReasons(application, DENIAL_REASON_BANK_DEPOSITS);
            }
            if(ocrolusReport.Is_Debt_Consolidator__c == true) {
                Applications.setDenialReasons(application, DENIAL_REASON_DEBT_CONSOLIDATOR_PRESENT);
            }
            if(ocrolusReport.Offer_GAV_Amount__c <= 0 || application.Annual_Volume__c <= 0) {
                Applications.setDenialReasons(application, DENIAL_REASON_NOT_ELIGIBLE_FOR_MINIMUM_FUNDING);
            }
        }
        if(application.Type__c == GeneralConstants.LOAN_TYPE_NEW) {
            if(ocrolusReport.Max_Daily_Payment__c < 7.5) {
                Applications.setDenialReasons(application, DENIAL_REASON_BANK_BALANCES);
            }
        }
    }

    public static void pricingGenerationDeclineRules(genesis__Applications__c application, CAN_Pricing_Detail__c pricingDetail) {
        if(pricingDetail.Maximum_Amount__c < 2500) {
            Applications.setDenialReasons(application, DENIAL_REASON_NOT_ELIGIBLE_FOR_MINIMUM_FUNDING);
        }
    }

    public static void setUnderWriterTasksVerification(
        Map<String, UnderWriter_Task__c> underWriterTaskByApplicationIdTaskName, CAN_Ocrolus_Report__c ocrolusReport,
        Credit_Report_Detail__c consumerCreditReport, genesis__Applications__c application
    ) {

        if(underWriterTaskByApplicationIdTaskName.containsKey(application.Id + TASK_NAME_OCR_FRAUD_ALERT)) {
            UnderWriter_Task__c underWriterTaskOCRFraudAlert = underWriterTaskByApplicationIdTaskName.get(
                application.Id + TASK_NAME_OCR_FRAUD_ALERT
            );

            if(ocrolusReport.Is_Potential_Fraud__c) {
                underWriterTaskOCRFraudAlert.Verification_Type__c = VERIFICATION_TYPE_MANUAL;
                underWriterTaskOCRFraudAlert.IsCompleted__c = false;
            } else {
                underWriterTaskOCRFraudAlert.Verification_Type__c = VERIFICATION_TYPE_AUTOMATED;
                underWriterTaskOCRFraudAlert.IsCompleted__c = true;
            }
        }

        if(underWriterTaskByApplicationIdTaskName.containsKey(application.Id + TASK_NAME_EXPERIAN_FRAUD_ALERT)) {
            UnderWriter_Task__c underWriterTaskExperianFraudAlert = underWriterTaskByApplicationIdTaskName.get(
                application.Id + TASK_NAME_EXPERIAN_FRAUD_ALERT
            );

            if(consumerCreditReport.Credit_Statement__c != null &&
                (consumerCreditReport.Credit_Statement__c.contains(FRAUD_ALERT_FRAUD_STATEMENT) ||
                    consumerCreditReport.Credit_Statement__c.contains(FRAUD_ALERT_SECURITY_STATEMENT))
            ) {
                underWriterTaskExperianFraudAlert.Verification_Type__c = VERIFICATION_TYPE_MANUAL;
                underWriterTaskExperianFraudAlert.IsCompleted__c = false;
            } else {
                underWriterTaskExperianFraudAlert.Verification_Type__c = VERIFICATION_TYPE_AUTOMATED;
                underWriterTaskExperianFraudAlert.IsCompleted__c = true;
            }
        }
    }

    public static genesis__Applications__c runAutoAcceptExceptionEligible(
        genesis__Applications__c application, Account accountDetail, Credit_Report_Detail__c businessCreditReport,
        Credit_Report_Detail__c consumerCreditReport
    ) {
        genesis__Applications__c applicationShell = new genesis__Applications__c(Id = application.Id);
        applicationShell.Auto_Accept_ExceptionEligible__c = false;
        Integer ficoScoreAcceptExpEligible = Integer.valueOf(CustomSettingsHelper.generalSettings.FICO_Auto_Accept_Excptn_Eligible__c);

        if(consumerCreditReport.Personal_FICO_Score__c >= ficoScoreAcceptExpEligible && application.Time_In_Business__c >= 5
            && consumerCreditReport.Past_Due_Amount__c < 5000  && businessCreditReport.Total_Collection_Amount__c < 5000
        ) {
            if(application.Type__c == GeneralConstants.LOAN_TYPE_NEW) {
                applicationShell.Auto_Accept_ExceptionEligible__c = true;
            } else if(application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL
                && (accountDetail.Number_Of_Bounces_in_Last_60_Days__c == null || accountDetail.Number_Of_Bounces_in_Last_60_Days__c <= 2)
            ) {
                applicationShell.Auto_Accept_ExceptionEligible__c = true;
            }
        }
        return applicationShell;
    }

    public static void dataMerchDeclineRules(genesis__Applications__c application, List<Data_Merch_Note__c> listOfDataMerchNotes) {
        if(application.Type__c == GeneralConstants.LOAN_TYPE_NEW || application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL) {
            for(Data_Merch_Note__c dataMerchNote : listOfDataMerchNotes) {
                Integer daysDiff = dataMerchNote.Added_at__c.daysBetween(GeneralHelper.currentSystemDate);
                if((dataMerchNote.Note_Category__c == 'Default Account' || dataMerchNote.Note_Category__c == 'Slow Pay') && daysDiff <= 1095) {
                    Applications.setDenialReasons(application, DENIAL_REASON_NEGATIVE_HISTORY_WITH_COMPETITOR);
                } else if(dataMerchNote.Note_Category__c == 'Suspicious Activity' && daysDiff <= 9999) {
                    Applications.setDenialReasons(application, DENIAL_REASON_NEGATIVE_HISTORY_WITH_COMPETITOR);
                }
            }
        }
    }

    private class BusinessRulesException extends Exception {}
}