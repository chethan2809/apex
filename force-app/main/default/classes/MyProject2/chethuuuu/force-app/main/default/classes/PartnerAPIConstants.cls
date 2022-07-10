public class PartnerAPIConstants {
    public static final String APPLICATION = 'application';
    public static final String PARTNER_DETAILS = 'partnerDetails';
    public static final String APPLICATION_DETAILS = 'ApplicationDetails';
    public static final String PARTNER_EMAIL = 'partnerEmail';
    public static final String PARTNER_API_KEY = 'partnerAPIKey';
    public static final String PARTNER_DETAIL = 'partnerDetail';
    public static final String PARTNER_INFO = 'partnerInfo';
    public static final String PRICING_DETAILS = 'PricingDetails';
    public static final String PARTNER_API_KEY_DOES_NOT_MATCH = 'Partner API key does not match';
    public static final String PARTNER_USER_DOES_NOT_EXIST = 'Partner user does not exist';
    public static final String INVALID_APPLICATION = 'Invalid application';
    public static final String NO_RECORDS_FOUND = 'No records found in payload';
    public static final String PARTNER_USER_DOES_NOT_HAVE_ACCESS = 'Partner user does not have access to this application';
    public static final String MINIMUM_TERM = 'Minimum Term';

    public static Map<String, String> clContractStatusToApplicationStatus {
        get {
            if(clContractStatusToApplicationStatus == null) {
                clContractStatusToApplicationStatus = new Map<String, String>();
                clContractStatusToApplicationStatus.put(CLContracts.LOAN_STATUS_APPROVED, 'Approved');
                clContractStatusToApplicationStatus.put(CLContracts.LOAN_STATUS_ACTIVE_GOOD_STANDING, 'Funded - Active Pay');
                clContractStatusToApplicationStatus.put(CLContracts.LOAN_STATUS_ACTIVE_BAD_STANDING, 'Funded - In Collections');
                clContractStatusToApplicationStatus.put(CLContracts.LOAN_STATUS_CLOSED_OBLIGATION_MET, 'Funded - Zero Balance');
                clContractStatusToApplicationStatus.put(CLContracts.LOAN_STATUS_CLOSED_WRITTEN_OFF, 'Funded - Write Off');
                clContractStatusToApplicationStatus.put(CLContracts.LOAN_STATUS_ACTIVE_MATURED, 'Funded - In Collections');
                clContractStatusToApplicationStatus.put(CLContracts.LOAN_STATUS_CANCELED, 'Cancelled Application');
                clContractStatusToApplicationStatus.put(CLContracts.LOAN_STATUS_CLOSED_REFINANCED, 'Funded - Zero Balance');
                clContractStatusToApplicationStatus.put(CLContracts.LOAN_STATUS_PARTIAL_APPLICATION, 'Incomplete Application');
                clContractStatusToApplicationStatus.put(CLContracts.LOAN_STATUS_PENDING_APPROVAL, 'Pending Approval');
                clContractStatusToApplicationStatus.put(Applications.STATUS_APPROVED, 'Funded');
            }
            return clContractStatusToApplicationStatus;
        }
        set;
    }

    public static Map<String, String> applicationOverAllStatusToApplicationPartnerAPIStatus {
        get {
            if(applicationOverAllStatusToApplicationPartnerAPIStatus == null) {
                applicationOverAllStatusToApplicationPartnerAPIStatus = new Map<String, String>();
                applicationOverAllStatusToApplicationPartnerAPIStatus.put(Applications.STATUS_NEW_ENTERED, 'Application Submitted');
                applicationOverAllStatusToApplicationPartnerAPIStatus.put(Applications.STATUS_APPLICATION_CREATED, 'Application Submitted');
                applicationOverAllStatusToApplicationPartnerAPIStatus.put(Applications.SCORING, 'Application Submitted');
                applicationOverAllStatusToApplicationPartnerAPIStatus.put(Applications.CONDITIONAL_APPROVAL, 'Approved');
                applicationOverAllStatusToApplicationPartnerAPIStatus.put(Applications.EXCEPTION_REVIEW, 'Approved');
                applicationOverAllStatusToApplicationPartnerAPIStatus.put(Applications.STATUS_DOCS_OUT, 'Docs Out');
                applicationOverAllStatusToApplicationPartnerAPIStatus.put(Applications.STATUS_DOCS_IN, 'Docs In');
                applicationOverAllStatusToApplicationPartnerAPIStatus.put(Applications.STATUS_DUE_DILIGENCE, 'Docs In');
                applicationOverAllStatusToApplicationPartnerAPIStatus.put(Applications.STATUS_READY_TO_FUND, 'Ready to Fund');
                applicationOverAllStatusToApplicationPartnerAPIStatus.put(Applications.STATUS_APPROVED, 'Funded');
                applicationOverAllStatusToApplicationPartnerAPIStatus.put(Applications.STATUS_DECLINED, 'Closed Declined');
            }
            return applicationOverAllStatusToApplicationPartnerAPIStatus;
        }
        set;
    }
}