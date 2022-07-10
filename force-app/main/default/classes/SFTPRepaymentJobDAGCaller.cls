global class SFTPRepaymentJobDAGCaller extends clcommon.DynamicJob {

    private Date sodDate;
    private static final String JOB_NAME = 'SFTP Repayment ACH Dynamic Job';
    private static final Integer DEFAULT_BATCH_SIZE = 150;

    global SFTPRepaymentJobDAGCaller() {
        this(null);
    }

    public SFTPRepaymentJobDAGCaller(String query) {
        super(JOB_NAME, query);
    }

    global override void doExecute(SchedulableContext sc) {
    }

    global override void doInitialize() {}

    global override String getRuntimeQuery() {
        return 'SELECT Id FROM Document WHERE Id = null';
    }

    global override String getRuntimeQueryForPipelinedExecution(Set<Id> records) {
        return null;
    }

    global override void doStart(Database.BatchableContext bc) {}

    global override void doExecute(Database.BatchableContext BC, List<sObject> scope) {}

    global override void doFinish(Database.BatchableContext bc) {
        SFTPRepaymentJob.execute();
    }
}