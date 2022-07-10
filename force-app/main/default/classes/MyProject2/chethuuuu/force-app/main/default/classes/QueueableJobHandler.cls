public class QueueableJobHandler {

    public QueueableJobHandler() {}

    public void executeExperianConsumerQueueableJob(List<genesis__Applications__c> listOfApplications) {
        if(Limits.getQueueableJobs() == 1) {
            System.schedule(
                'ExperianConsumerSchedulable ' + String.valueOf(Math.random()), GeneralHelper.getAsyncCronExpression(),
                new ExperianConsumerSchedulable(listOfApplications)
            );
        } else {
            System.enqueueJob(new ExperianConsumerQueueableJob(listOfApplications));
        }
    }

    public void executeExperianBusinessQueueableJob(List<genesis__Applications__c> listOfApplications) {
        if(Limits.getQueueableJobs() == 1) {
            System.schedule(
                'ExperianBusinessSchedulable ' + String.valueOf(Math.random()), GeneralHelper.getAsyncCronExpression(),
                new ExperianBusinessSchedulable(listOfApplications)
            );
        } else {
            System.enqueueJob(new ExperianBusinessQueueableJob(listOfApplications));
        }
    }

    public void executeLexisNexisBIIDQueueableJob(List<genesis__Applications__c> listOfApplications) {
        if(Limits.getQueueableJobs() == 1) {
            System.schedule(
                'LexisNexisBIIDSchedulable ' + String.valueOf(Math.random()), GeneralHelper.getAsyncCronExpression(),
                new LexisNexisBIIDSchedulable(listOfApplications)
            );
        } else {
            System.enqueueJob(new LexisNexisBIIDQueueableJob(listOfApplications));
        }
    }

    public void executeLexisNexisFraudScoreQueueableJob(List<genesis__Applications__c> listOfApplications) {
        if(Limits.getQueueableJobs() == 1) {
            System.schedule(
                'LexisNexisFraudScoreSchedulable ' + String.valueOf(Math.random()), GeneralHelper.getAsyncCronExpression(),
                new LexisNexisFraudScoreSchedulable(listOfApplications)
            );
        } else {
            System.enqueueJob(new LexisNexisFraudScoreQueueableJob(listOfApplications));
        }
    }

    public void executeCANScoringQueueableJob(List<genesis__Applications__c> listOfApplications) {
        if(Limits.getQueueableJobs() == 1) {
            System.schedule(
                'CANScoringSchedulable ' + String.valueOf(Math.random()), GeneralHelper.getAsyncCronExpression(),
                new CANScoringSchedulable(listOfApplications)
            );
        } else {
            System.enqueueJob(new CANScoringQueueableJob(listOfApplications));
        }
    }

    public void executeOcrolusQueueableJob(List<genesis__Applications__c> listOfApplications) {
        if(Limits.getQueueableJobs() == 1) {
            System.schedule(
                'OcrolusSchedulable ' + String.valueOf(Math.random()), GeneralHelper.getAsyncCronExpression(),
                new OcrolusSchedulable(listOfApplications)
            );
        } else {
            System.enqueueJob(new OcrolusQueueableJob(listOfApplications));
        }
    }

    public void executeWasabiQueueableJob(Map<Id, clcommon__Category_Attachment_Association__c > attachmentIToCategoryAsso, CategoryAttachAssns.RequestType requestType) {
        if(Limits.getQueueableJobs() == 1) {
            System.schedule(
                'WasabiSchedulable ' + String.valueOf(Math.random()), GeneralHelper.getAsyncCronExpression(),
                new WasabiSchedulable(attachmentIToCategoryAsso, requestType)
            );
        } else {
            System.enqueueJob(new WasabiQueueableJob(attachmentIToCategoryAsso, requestType));
        }
    }

    public void executeSFTPScoringRawDataQueueableJob(List<Credit_Report_Detail__c> reportList, Map<Id, Map<String, String>> responseMapByCreditReportDetail, Map<Id, Id> contactIdAccountIdToApplicationId) {
        if(Limits.getQueueableJobs() == 1) {
            System.schedule(
                'SFTPScoringRawDataSchedule ' + String.valueOf(Math.random()), GeneralHelper.getAsyncCronExpression(),
                new SFTPScoringRawDataSchedulable(reportList, responseMapByCreditReportDetail, contactIdAccountIdToApplicationId)
            );
        } else {
            System.enqueueJob(new SFTPScoringRawDataQueueableJob(reportList, responseMapByCreditReportDetail, contactIdAccountIdToApplicationId));
        }
    }

    public void executeUCCValidateApproveFilingQueueableJob(List<UCC_Filing_Detail__c> uccFilingList) {
        if(Limits.getQueueableJobs() == 1) {
            System.schedule(
                'UCCValidateApproveFilingSchedule ' + String.valueOf(Math.random()), GeneralHelper.getAsyncCronExpression(),
                new UCCValidateApproveFilingSchedulable(uccFilingList)
            );
        } else {
            System.enqueueJob(new UCCValidateApproveFilingQueueableJob(uccFilingList));
        }
    }

    public void executeUCCFilingReportQueueableJob(List<UCC_Filing_Detail__c> uccFilingList) {
        if(Limits.getQueueableJobs() == 1) {
            System.schedule(
                'UCCFilingReportSchedulable ' + String.valueOf(Math.random()), GeneralHelper.getAsyncCronExpression(),
                new UCCFilingReportSchedulable(uccFilingList)
            );
        } else {
            System.enqueueJob(new UCCFilingReportQueueableJob(uccFilingList));
        }
    }

    public void executeDataMerchQueueableJob(List<genesis__Applications__c> listOfApplications) {
        if(Limits.getQueueableJobs() == 1) {
            System.schedule(
                'DataMerchSchedulable ' + String.valueOf(Math.random()), GeneralHelper.getAsyncCronExpression(),
                new DataMerchSchedulable(listOfApplications)
            );
        } else {
            System.enqueueJob(new DataMerchQueueableJob(listOfApplications));
        }
    }
}