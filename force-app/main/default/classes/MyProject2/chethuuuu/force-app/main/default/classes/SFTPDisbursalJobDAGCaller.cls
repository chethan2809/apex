global class SFTPDisbursalJobDAGCaller extends clcommon.DynamicJob {

    private Date sodDate;
    private static final String JOB_NAME = 'SFTP Disbursal ACH Dynamic Job';
    private static final Integer DEFAULT_BATCH_SIZE = 150;

    global SFTPDisbursalJobDAGCaller() {
        this(null);
    }

    public SFTPDisbursalJobDAGCaller(String query) {
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
        SFTPDisbursalJob.execute();
    }
}