public class UCCFilingReportJob  implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts {

    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    public static Origination_Settings__mdt defaultUCCFilingReportSetting = CustomMetaDataHelper.defaultOriginationSetting;

    public UCCFilingReportJob() {}

    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator([
            SELECT Id, Order_ID__c, Order_Status__c, Is_Terminated__c, Terminated_Order_ID__c
            FROM UCC_Filing_Detail__c
            WHERE (Approved__c = true AND UCC_Reports_Pulled__c = false)
                OR (
                        (
                            Is_UCC_Continued__c = true
                            AND Is_UCC_Continuation_Approved__c = true
                            AND UCC_Continuation_Reports_Pulled__c = false
                        )
                    )
                OR (
                    (
                        Is_Terminated__c = true
                        AND Is_UCC_Termination_Approved__c = true
                        AND UCC_Termination_Reports_Pulled__c = false
                    )
                )
        ]);
    }

    public void execute(Database.BatchableContext bc, List<UCC_Filing_Detail__c> uccFilingList) {
        try {
            UCCFilingManager.getUCCOrderStatus(uccFilingList);
        } catch (Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'UCC Filing Report Job Failed', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR, null, false
            );
            errorLogDBInstance.addInsert(errorLog).executeInserts();
        }
    }

    public void execute(SchedulableContext sc) {
        if (defaultUCCFilingReportSetting.UCC_Report_Batch_Size__c == null) {
            throw new UCCFilingReportJobException('UCC_Report_Batch_Size__c is null');
        }
        Database.executeBatch(this, Integer.ValueOf(defaultUCCFilingReportSetting.UCC_Report_Batch_Size__c));
    }

    public static void execute() {
        UCCFilingReportJob uccFilingReportJobInstance = new UCCFilingReportJob();
        uccFilingReportJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext bc) {

    }

    private class UCCFilingReportJobException extends Exception {}
}