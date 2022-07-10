public class UnderWriterTasks {

    public static final String PERSONAL_GUARANTOR = 'Personal Guarantor Verification';

    public static UnderWriter_Task__c createUnderWriterTask(Id applicationId, String taskName, String category, Decimal order) {
        UnderWriter_Task__c taskDetail = new UnderWriter_Task__c();
        taskDetail.Application__c = applicationId;
        taskDetail.Task_Name__c = taskName;
        taskDetail.Category__c = category;
        taskDetail.Order__c = order;
        return taskDetail;
    }
}