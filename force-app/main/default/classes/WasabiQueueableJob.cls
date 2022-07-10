public class WasabiQueueableJob implements Queueable, Database.AllowsCallouts {

    private Map<Id, clcommon__Category_Attachment_Association__c > attachmentIToCategoryAsso = new Map<Id, clcommon__Category_Attachment_Association__c >();
    CategoryAttachAssns.RequestType requestType;

    public WasabiQueueableJob(Map<Id, clcommon__Category_Attachment_Association__c > attachmentIToCategoryAsso, CategoryAttachAssns.RequestType requestType) {
        this.attachmentIToCategoryAsso = attachmentIToCategoryAsso;
        this.requestType = requestType;
    }

    public void execute(QueueableContext context) {
        WasabiManager.sendToWasabi(attachmentIToCategoryAsso, requestType);
    }
}