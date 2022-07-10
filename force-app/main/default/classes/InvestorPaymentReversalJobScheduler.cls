public class InvestorPaymentReversalJobScheduler implements Schedulable {

    @TestVisible
    private static LoanOfficeNameDB loanOfficeNameDBInstance = new LoanOfficeNameDB();
    public static Origination_Settings__mdt defaultSetting = CustomMetaDataHelper.defaultOriginationSetting;

    public InvestorPaymentReversalJobScheduler() {
    }

    public void execute(SchedulableContext sc) {
        Set<Id> branchIds = new Set<ID>();
        Set<loan__Office_Name__c> loanOfficeSet = new Set<loan__Office_Name__c>{};
        for(loan__Office_Name__c loanOffice : loanOfficeNameDBInstance.getLoanOfficeName()){
            branchIds.add(loanOffice.Id);
            loanOfficeSet.add(loanOffice);
        }
        Date currentSystemDate = GeneralHelper.currentSystemDate;
        String query = loan.ProcessJobQueryUtil.getInvestorPaymentReversalJobQuery(branchIds,currentSystemDate);
        Integer jobSize = defaultSetting.Investor_Payout_Reversal_Job_Size__c != null? Integer.valueOf(defaultSetting.Investor_Payout_Reversal_Job_Size__c) : 50;
        loan.InvestorPayoutReversalJob investorPayoutReversalJob = new loan.InvestorPayoutReversalJob(query, currentSystemDate, loanOfficeSet);
        ID batchProcessID = Database.executeBatch(investorPayoutReversalJob, jobSize);
    }
}