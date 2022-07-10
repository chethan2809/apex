public class WasabiSchedulable implements Schedulable {

    private Map<Id, clcommon__Category_Attachment_Association__c > attachmentIToCategoryAsso = new Map<Id, clcommon__Category_Attachment_Association__c >();
    CategoryAttachAssns.RequestType requestType;

    public WasabiSchedulable(Map<Id, clcommon__Category_Attachment_Association__c > attachmentIToCategoryAsso, CategoryAttachAssns.RequestType requestType) {
        this.attachmentIToCategoryAsso = attachmentIToCategoryAsso;
        this.requestType = requestType;
    }

    public void execute(SchedulableContext sc) {
        System.enqueueJob(new WasabiQueueableJob(attachmentIToCategoryAsso, requestType));
        System.abortJob(sc.getTriggerId());
    }
}