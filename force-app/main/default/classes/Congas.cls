public class Congas {
    public static final String CONGA_LOAN_AGREEMENT_COMMON = 'Loan Agreement Common';
    public static final String CONGA_LOAN_AGREEMENT_COMPETITOR = 'Loan Agreement Competitor';
    public static final String CONGA_LOAN_AGREEMENT_CONCURRENT_DAILY = 'Loan Agreement Concurrent Daily';
    public static final String CONGA_LOAN_AGREEMENT_CONCURRENT_WEEKLY = 'Loan Agreement Concurrent Weekly';
    public static final String CONGA_LOAN_AGREEMENT_DAILY = 'Loan Agreement Daily';
    public static final String CONGA_LOAN_AGREEMENT_WEEKLY = 'Loan Agreement Weekly';
    public static final String CONGA_LOAN_AGREEMENT_RENEWAL = 'Loan Agreement Renewal';

    public static Set<String> buildApplicationTemplateGroupNames(genesis__Applications__c application) {
        Set<String> eligibleTemplateGroups = new Set<String>();
        eligibleTemplateGroups.add(CONGA_LOAN_AGREEMENT_COMMON);
        if(application.Total_Competitors_Amount__c > 0) {
            eligibleTemplateGroups.add(CONGA_LOAN_AGREEMENT_COMPETITOR);
        }

        if(application.Type__c == GeneralConstants.LOAN_TYPE_CONCURRENT) {
            eligibleTemplateGroups.add(
                application.genesis__Payment_Frequency__c == GeneralConstants.FREQUENCY_DAILY ?
                    CONGA_LOAN_AGREEMENT_CONCURRENT_DAILY : CONGA_LOAN_AGREEMENT_CONCURRENT_WEEKLY
            );
        } else {
            eligibleTemplateGroups.add(
                application.genesis__Payment_Frequency__c == GeneralConstants.FREQUENCY_DAILY ?
                    CONGA_LOAN_AGREEMENT_DAILY : CONGA_LOAN_AGREEMENT_WEEKLY
            );
            if(application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL) {
                eligibleTemplateGroups.add(CONGA_LOAN_AGREEMENT_RENEWAL);
            }
        }

        return eligibleTemplateGroups;
    }
}