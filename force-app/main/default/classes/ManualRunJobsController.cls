public class ManualRunJobsController {

    @AuraEnabled (cacheable=true)
    public static Map<String, Manual_Run_Jobs__mdt> getManualJobsToRun(){
        return CustomMetaDataHelper.manualRunJobsByJobName;
    }

    @AuraEnabled (cacheable=false)
    public static String runManualJob(String jobName, Integer batchSize) {
        try {
            if(jobName == 'clcommon_DataMapperInitiatorJob'){
                String query = clcommon.QueryHelp.getDataMappingInitiatorQuery();
                clcommon.DataMapperInitiatorJob dataMapperInitiatorJobInstance = new clcommon.DataMapperInitiatorJob(query);
                Database.executeBatch(dataMapperInitiatorJobInstance, 1);
            } else if(jobName == 'loan_loanPaymentTransactionCreationJob') {
                LoanPaymentTransactionCreationScheduler jobInstance = new LoanPaymentTransactionCreationScheduler();
                jobInstance.execute(null);
            } else if(jobName == 'loan_LoanPaymentFilegenJob') {
                LoanPaymentFilegenJobScheduler jobInstance = new LoanPaymentFilegenJobScheduler(
                    false, batchSize
                );
                jobInstance.execute(null);
            } else if(jobName == 'loan_DisbursalDistributionFilegenJob') {
                DisbursalDistributionFilegenScheduler jobInstance = new DisbursalDistributionFilegenScheduler();
                jobInstance.execute(null);
            } else if(jobName == 'loan_InvestorPayoutReversalJob') {
                Origination_Settings__mdt defaultJobSetting = new Origination_Settings__mdt();
                defaultJobSetting.Investor_Payout_Reversal_Job_Size__c = batchSize;
                InvestorPaymentReversalJobScheduler.defaultSetting = defaultJobSetting;

                InvestorPaymentReversalJobScheduler jobInstance = new InvestorPaymentReversalJobScheduler();
                jobInstance.execute(null);
            } else {
                jobName = jobName.replace('_', '.');
                ClassFactoryManager classFactory = new ClassFactoryManager();
                Database.executeBatch((Database.Batchable<SObject>) classFactory.newClassInstance(jobName), batchSize);
            }

            return 'Success';
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}