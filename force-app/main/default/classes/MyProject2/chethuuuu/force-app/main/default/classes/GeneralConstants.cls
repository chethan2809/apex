public class GeneralConstants {
    public static final String COMPANY_NAME = 'CAN Capital';
    public static final String PRODUCT_TYPE_LOAN = 'LOAN';
    public static final String PRODUCT_NAME_DEFAULT = 'CAN Capital';
    public static final String PRODUCT_TYPE_MCA = 'Merchant Cash Advance';
    public static final String PRODUCT_TYPE_FLEXIBLE_AMZ_LOAN = 'Flexible Amz Loan';


    public static final String FREQUENCY_DAILY = 'DAILY';
    public static final String FREQUENCY_WEEKLY = 'WEEKLY';

    public static final String PARTY_TYPE_BORROWER = 'BORROWER';
    public static final String PARTY_TYPE_GUARANTOR = 'GUARANTOR';
    public static final String PARTY_TYPE_BROKER = 'BROKER';
    public static final String PARTY_TYPE_CONTACT = 'CONTACT';
    public static final String PARTY_TYPE_COMPETITOR = 'COMPETITOR';

    public static final String MERCHANT = 'Merchant';
    public static final String BROKER = 'Broker';

    public static final String APPLICATION_ID = 'applicationId';

    public static final String DOCUMENT_TYPE_LOAN_AGREEMENT = 'Loan Agreement';
    public static final String DOCUMENT_TYPE_CL_COLLECTIONS = 'CL Collections';
    public static final String DOCUMENT_TYPE_COLLECTIONS = 'Collections';
    public static final String DOCUMENT_TYPE_COLLECTIONS_CONSUMER_CREDIT = 'Collections Consumer Credit';
    public static final String DOCUMENT_TYPE_COLLECTIONS_BUSINESS_CREDIT = 'Collections Business Credit';
    public static final String DOCUMENT_TYPE_EXPERIAN_BUSINESS_REPORT = 'Experian Business Credit Report';
    public static final String DOCUMENT_TYPE_EXPERIAN_CONSUMER_REPORT = 'Experian Consumer Credit Report';
    public static final String DOCUMENT_TYPE_OTHERS = 'Other';
    public static final String DOCUMENT_TYPE_BANK_STATEMENTS = 'Bank Statements';
    public static final String DOCUMENT_STATUS_SUBMITTED = 'SUBMITTED';
    public static final String DOCUMENT_TYPE_OCROLUS_ANALYTICS_REPORT = 'Ocrolus Analytics Report';

    public static final String PAYMENT_MODE_ACH = 'ACH';
    public static final String PAYMENT_MODE_REFINANCING = 'Refinancing';

    public static final String CREDIT_REPORT_TYPE_EXPERIAN_CONSUMER = 'Experian Consumer';
    public static final String CREDIT_REPORT_TYPE_EXPERIAN_BUSINESS = 'Experian Business';
    public static final String CREDIT_REPORT_TYPE_LEXIS_NEXIS = 'Lexis Nexis';
    public static final String CREDIT_REPORT_TYPE_CAN_SCORING = 'CAN Scoring';
    public static final String CREDIT_REPORT_TYPE_DATA_MERCH = 'Data Merch';

    public static final String LOAN_TYPE_NEW = 'New';
    public static final String LOAN_TYPE_RENEWAL = 'Renewal';
    public static final String LOAN_TYPE_CONCURRENT = 'Concurrent';

    public static final String DEFAULT_SIC_CODE = '9999';
    public static final String LEGAL_TYPE_SOLE_PROP = 'Sole Proprietorship';
    public static final String LEGAL_TYPE_CORPORATION = 'Corporation';
    public static final String LEGAL_TYPE_INDIVIDUAL = 'Individual';
    public static final String LEGAL_TYPE_LLC = 'LLC';
    public static final String LEGAL_TYPE_LLP = 'LLP';
    public static final String LEGAL_TYPE_PARTNERSHIP = 'Partnership';
    public static final String LEGAL_TYPE_LIMITED_PARTNERSHIP = 'Limited Partnership';
    public static final String LEGAL_TYPE_OTHERS = 'Others';
    public static final String LEGAL_TYPE_OTHER = 'Other';

    public static final String WIRE_PAYMENT_STATUS_IN_PROGRESS = 'In Progress';

    public static final String MERCHANT_USER_PROFILE_NAME = 'BorrowerOLB';
    public static final String BROKER_USER_PROFILE_NAME = 'BrokerCommunityPlus';

    public static final String FOLDER_FUNDING_STATEMENT = 'Funding Statement';
    public static final String FOLDER_PURCHASE_STATEMENT = 'Purchase Statement';
    public static final String FOLDER_ACH_OUTBOUND = 'ACH Outbound';
    public static final String FOLDER_ACH_INBOUND = 'ACH Inbound';
    public static final String FOLDER_PROCESSED_ACH_OUTBOUND = 'ACH Outbound Processed';
    public static final String FOLDER_PROCESSED_ACH_INBOUND = 'ACH Inbound Processed';
    public static final String FOLDER_ACH_RETURN = 'ACH Returns';
    public static final String FOLDER_FINCEN_REPORT = 'FinCen Report';

    public static final String ORIGINATION_FEE = 'Origination Fee';
    public static final String FLORIDA_FEE = 'Florida Fee';
    public static final String BLOCKED_ACCOUNT_FEE = 'Blocked Account Fee';
    public static final String LATE_FEE = 'Late Fee';
    public static final String RETURNED_ACH_FEE = 'Returned ACH Fee';
    public static final String PRE_CLOSURE_FEE = 'Pre Closure Fee';

    public static final String FUND_RELEASE_TEAM_QUEUE = 'Fund_Release_Team';

    public static final String COMPLIANCE_TEAM_QUEUE = 'Compliance_Team';

    public static final String CUSTOMER_CARE = 'Customer_Care';

    public static final String CASE_TYPE_FUND_RELEASE_REQUEST = 'Fund Release Request';
    public static final String CUSTOMER_CARE_REQUEST = 'Customer Care';

    public static final String USER_TYPE_STANDARD = 'Standard';
    public static final String TIME_ZONE_AMERICA_NEW_YORK = 'America/New_York';

    public static final String CAN_APP_SUPPORT_EMAIL_ADDRESS = 'appsupport@cancapital.com';
    public static final String CAN_PARTNER_SALES_EMAIL_ADDRESS = 'partnersales@cancapital.com';
    public static final String CAN_NO_REPLY_EMAIL_ADDRESS = 'noreply@cancapital.com';
    public static final String CAN_SALESFORCE_NOTIFICATION_EMAIL_ADDRESS = 'salesforcenotifications@cancapital.com';
    public static final String CAN_NO_REPLY_AAN_EMAIL_ADDRESS = 'noreply-aan@cancapital.com';

    public static final String CREDIT_REPORT_SOURCE_TYPE_COLLECTIONS = 'Collections';
    public static final String CREDIT_REPORT_SOURCE_TYPE_APPLICATIONS = 'Applications';

    public static final String UCC_STATUS_ACTIVE = 'Active';
    public static final String UCC_STATUS_TERMINATED = 'Terminated';
    public static final String UCC_STATUS_NO_UCC = 'No UCC';
    public static final String OVERRIDE_UCC_STATUS_EXPIRE = 'Expire';
    public static final String OVERRIDE_UCC_STATUS_NONE = 'None';
    public static final Set<String> GET_FAILED_RESPONSE = new Set<String> {'faultstring'};
    public static final String UCC_ORDER_STATUS_COMPLETED = 'C';

    public static final String CONTENT_DOCUMENT_NOTE_TYPE = 'SNOTE';
}