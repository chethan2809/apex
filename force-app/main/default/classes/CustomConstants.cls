public class CustomConstants{

    public static String APPLICATION_ID = 'applicationId'; 
    public static String BORROWER = 'BORROWER';
    public static String CO_BORROWER = 'CO-BORROWER';
    public static String COSIGNER = 'COSIGNER';
    public static String HYPOTHECATOR = 'HYPOTHECATOR';
    public static String INDIVIDUAL = 'Individual'; 
    public static String REJECTED = 'REJECTED';
    public static String NEWCHECKLISTGENERATED = 'NEW - CHECKLIST GENERATED';
    public static String BORROWERAGECHECK = 'Applicant is under legal age of 18 to enter into contract';
    public static String COBORROWERAGECHECK = 'Co-Applicant is under legal age of 18 to enter into contract';
    public static String BORROWERCITIZENSHIPCHECK = 'Applicant is neither a Citizen nor a Permanent Resident of United States.';
    public static String COBORROWERCITIZENSHIPCHECK = 'Co-Applicant is neither a Citizen nor a Permanent Resident of United States.';
    public static String FACT_ACTIVE_DUTY = 'FACTAActiveDuty';
    public static String SERVICE_MEMBER = 'Service Member';
    public static String ACTIVE_DUTY = 'Active Duty';
    public static String INSIDER = 'Insider';
    public static String RETIRED = 'Retired';
    public static String MILITARY_ENLISTED = 'Military Enlisted';
    public static String MILITARY_OFFICER = 'Military officer';
    public static String CREDIT_DISABILITY = 'CreditDisability';
    public static String CREDIT_LIFE = 'CreditLife';
    public static String GAP = 'GAP';
    public static String INVOLUNTARY = 'Involuntary';
    public static String WAIVE_PROTECTION = 'WaiveProtection';
    public static String NO_PAYMENT_PROTECTION = 'NoPaymentProtection';
    public static String RELIEVE_LENDER_PROTECTION = 'RelieveLenderProtection';
    public static String PORTAL_STAGE = 'portalStage';
    public static String PORTAL_SUB_STAGE = 'portalSubstage';
    public static String NEWSUBMITTED = 'NEW-SUBMITTED';
    public static String CONSUMER_UNSECURED = 'Consumer Unsecured';
    public static String CONSUMER_SECURED = 'Consumer Secured';
    public static String PROOF_OF_INCOME = 'Proof of Income';
    public static String SUPPORTING_DOC = 'Supporting documents for Other Income';
    public static String STATUS_NEW_SCORECARD_GENERATED = 'NEW - SCORECARD GENERATED';
    public static String MINIMUM = 'Minimum';
    public static String MAXIMUM = 'Maximum';
    public static String AVERAGE = 'Average';
    //Portal constants
    public static String RETURN_MESSAGE = 'Something went wrong.';
    
    //Citizenship Country
    public static final String CITIZENSHIP_COUNTRY = 'US,USA,United States,United States of America,UNITED STATES,UNITED STATES OF AMERICA';
    
    //CL Products for Credit pull
    public static List<String> MLAProducts = new List<String>{'Consumer Secured Refinance','Consumer Secured Savings/CD Secured','Consumer Credit Card','Consumer Unsecured Loan'};
    public static List<String> nonMLAProducts = new List<String>{'Consumer Secured Purchase'};
    public static String CONSUMER_SECURED_PURCHASE = 'Consumer Secured Purchase';
    public static String CONSUMER_SECURED_REFINANCE = 'Consumer Secured Refinance';
    public static String CONSUMER_SECURED_SAVINGS_CD = 'Consumer Secured Savings/CD Secured';
    public static String CONSUMER_CREDIT_CARD = 'Consumer Credit Card';
    public static String CONSUMER_UNSECURED_LOAN = 'Consumer Unsecured Loan';
    
    //Credit insrance Constants
    public static String JOINT = 'Joint';
    public static String SINGLE = 'Single';
    public static String IUI = 'IUI';
    public static String LIFE = 'Life';
    public static String DISABILITY = 'Disability';
    public static String GAP_INSURANCE = 'GAP Insurance';
    public static String CDI_JOInt = 'Credit Life & Disability & IUI -Joint';
    public static String CDI_SINGLE = 'Credit Life & Disability & IUI -Single';
    public static String DLI_SINGLE = 'Disability & Life & IUI -Single';
    public static String DLI_JOINT = 'Disability & Life & IUI -Joint';
    public static String ILD_JOINT = 'IUI & Life & Disability -Joint';
    public static String ILD_SINGLE = 'IUI & Life & Disability -Single';
    public static String CD_JOINT = 'Credit Life & Disability -Joint';
    public static String CD_SINGLE = 'Credit Life & Disability -Single';
    public static String DL_JOINT = 'Disability & Life -Joint';
    public static String DL_SINGLE = 'Disability & Life -Single';
    public static String DI_JOINT = 'Disability & IUI -Joint';
    public static String DI_SINGLE = 'Disability & IUI -Single';
    public static String ID_JOINT = 'IUI & Disability -Joint';
    public static String ID_SINGLE = 'IUI & Disability -Single';
    public static String CI_JOINT = 'Credit Life & IUI -Joint';
    public static String CI_SINGLE = 'Credit Life & IUI -Single';
    public static String IL_JOINT = 'IUI & Life -Joint';
    public static String IL_SINGLE = 'IUI & Life -Single';
    public static String DISABILITY_JOINT = 'Disability -Joint';
    public static String DISABILITY_SINGLE = 'Disability -Single';
    public static String CREDIT_LIFE_JOINT = 'Credit Life -Joint';
    public static String CREDIT_LIFE_SINGLE = 'Credit Life -Single';
    
}