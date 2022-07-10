public class InvestorPayoutJobCaller {

    @TestVisible
    private static LoanOfficeNameDB loanOfficeNameDBInstance = new LoanOfficeNameDB();

    public InvestorPayoutJobCaller() {
    }

    @InvocableMethod(description='InvestorPayOutJob Caller')
    public static void executeInvestorPaymentJob() {
        if(!GeneralHelper.isAsynchronous()){
            Origination_Settings__mdt defaultSetting = CustomMetaDataHelper.defaultOriginationSetting;
            loan.InvestorPayoutJob investorPayoutJob = new loan.InvestorPayoutJob();
            Integer jobSize = defaultSetting.Investor_Payout_Job_Size__c != null? Integer.valueOf(defaultSetting.Investor_Payout_Job_Size__c) : 50;
            ID batchProcessID = Database.executeBatch(investorPayoutJob, jobSize);
        }
    }
}