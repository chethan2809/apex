public class Tasks {

    public static final String ACTIVITY_OUTCOME_EMAIL = 'Email';
    public static final String ACTIVITY_OUTCOME_CALLBACK_SCHEDULED = 'Callback Scheduled';
    public static final String ACTIVITY_OUTCOME_DO_NOT_CALL = 'Do Not Call';
    public static final String ACTIVITY_OUTCOME_IN_MARKET = 'In Market';
    public static final String ACTIVITY_OUTCOME_LEFT_MESSAGE = 'Left Message';
    public static final String ACTIVITY_OUTCOME_NO_ANSWER_NO_VM = 'No Answer/No VM';
    public static final String ACTIVITY_OUTCOME_NOT_INTERESTED = 'Not Interested';
    public static final String ACTIVITY_OUTCOME_OPEN_OPP_IN_PROGRESS = 'Open Opp In Progress';
    public static final String ACTIVITY_OUTCOME_OUT_OF_BUSINESS = 'Out of Business';
    public static final String ACTIVITY_OUTCOME_OUT_OF_MARKET = 'Out Of Market';
    public static final String ACTIVITY_OUTCOME_CUSTOMER_SERVICE = 'Customer Service';
    public static final String ACTIVITY_OUTCOME_DOES_NOT_QUALIFY = 'Does Not Qualify';
    public static final String ACTIVITY_OUTCOME_CONSENT_FOR_CREDIT_PULL = 'Consent For Credit Pull';
    public static final String ACTIVITY_OUTCOME_CALL_TRANSFER = 'Call Transfer';
    public static final String ACTIVITY_OUTCOME_FRONT_DESK_RESPONSE = 'Front Desk Response';
    public static final String ACTIVITY_OUTCOME_GHOST_0R_SPAM = 'Ghost Call / SPAM Call';
    public static final String ACTIVITY_OUTCOME_WRONG_NUMBER = 'Wrong Number';
    public static final String CASE_ESCALATION_ACTION_COMPLETED_NOTIFICATION = 'Case_Escalation_Action_Completed_Notification';
    public static final String OUTCOME_OUT_OF_MARKET = 'Out Of Market';
    public static final String TASK_SUB_TYPE_CALL  = 'Call';

    public static Task createTask(collect__Collection_Activity__c collectionActivity) {
        Task newTask = new Task();
        newTask.subject = System.Label.Supervisor_Task_Subject;
        newTask.WhatId = collectionActivity.Id;
        newTask.OwnerId = collectionActivity.collect__Account_Manager__c;
        newTask.Collection_Contract__c = collectionActivity.collect__Dev_Contract__c;
        newTask.Priority = 'Normal';
        newTask.Status = 'Open';
        return newTask;
    }

    public static void setActivityOutcomeByCallDisposition (Task taskObj) {
        if (taskObj.CallDisposition.contains(Tasks.ACTIVITY_OUTCOME_EMAIL))
        {
            taskObj.Activity_Outcome__c = Tasks.ACTIVITY_OUTCOME_EMAIL;
        }
        else if (taskObj.CallDisposition.contains(Tasks.ACTIVITY_OUTCOME_CALLBACK_SCHEDULED))
        {
            taskObj.Activity_Outcome__c = Tasks.ACTIVITY_OUTCOME_CALLBACK_SCHEDULED;
        }
        else if (taskObj.CallDisposition.contains(Tasks.ACTIVITY_OUTCOME_DO_NOT_CALL))
        {
            taskObj.Activity_Outcome__c = Tasks.ACTIVITY_OUTCOME_DO_NOT_CALL;
        }
        else if (taskObj.CallDisposition.contains(Tasks.ACTIVITY_OUTCOME_IN_MARKET))
        {
            taskObj.Activity_Outcome__c = Tasks.ACTIVITY_OUTCOME_IN_MARKET;
        }
        else if (taskObj.CallDisposition.contains(Tasks.ACTIVITY_OUTCOME_LEFT_MESSAGE))
        {
            taskObj.Activity_Outcome__c = Tasks.ACTIVITY_OUTCOME_LEFT_MESSAGE;
        }
        else if (taskObj.CallDisposition.contains(Tasks.ACTIVITY_OUTCOME_NO_ANSWER_NO_VM))
        {
            taskObj.Activity_Outcome__c = Tasks.ACTIVITY_OUTCOME_NO_ANSWER_NO_VM;
        }
        else if(taskObj.CallDisposition.contains(Tasks.ACTIVITY_OUTCOME_NOT_INTERESTED))
        {
            taskObj.Activity_Outcome__c = Tasks.ACTIVITY_OUTCOME_NOT_INTERESTED;
        }
        else if(taskObj.CallDisposition.contains(Tasks.ACTIVITY_OUTCOME_OPEN_OPP_IN_PROGRESS))
        {
            taskObj.Activity_Outcome__c = Tasks.ACTIVITY_OUTCOME_OPEN_OPP_IN_PROGRESS;
        }
        else if(taskObj.CallDisposition.contains(Tasks.ACTIVITY_OUTCOME_OUT_OF_BUSINESS))
        {
            taskObj.Activity_Outcome__c = Tasks.ACTIVITY_OUTCOME_OUT_OF_BUSINESS;
        }
        else if(taskObj.CallDisposition.contains(Tasks.ACTIVITY_OUTCOME_OUT_OF_MARKET))
        {
            taskObj.Activity_Outcome__c = Tasks.ACTIVITY_OUTCOME_OUT_OF_MARKET;
        }
        else if(taskObj.CallDisposition.contains(Tasks.ACTIVITY_OUTCOME_CUSTOMER_SERVICE))
        {
            taskObj.Activity_Outcome__c = Tasks.ACTIVITY_OUTCOME_CUSTOMER_SERVICE;
        }
        else if(taskObj.CallDisposition.contains(Tasks.ACTIVITY_OUTCOME_DOES_NOT_QUALIFY))
        {
            taskObj.Activity_Outcome__c = Tasks.ACTIVITY_OUTCOME_DOES_NOT_QUALIFY;
        }
        else if(taskObj.CallDisposition.contains(Tasks.ACTIVITY_OUTCOME_CONSENT_FOR_CREDIT_PULL))
        {
            taskObj.Activity_Outcome__c = Tasks.ACTIVITY_OUTCOME_CONSENT_FOR_CREDIT_PULL;
        }
        else if(taskObj.CallDisposition.contains(Tasks.ACTIVITY_OUTCOME_CALL_TRANSFER))
        {
            taskObj.Activity_Outcome__c = Tasks.ACTIVITY_OUTCOME_CALL_TRANSFER;
        }
        else if(taskObj.CallDisposition.contains(Tasks.ACTIVITY_OUTCOME_FRONT_DESK_RESPONSE))
        {
            taskObj.Activity_Outcome__c = Tasks.ACTIVITY_OUTCOME_FRONT_DESK_RESPONSE;
        }
        else if(taskObj.CallDisposition.contains(Tasks.ACTIVITY_OUTCOME_GHOST_0R_SPAM))
        {
            taskObj.Activity_Outcome__c = Tasks.ACTIVITY_OUTCOME_GHOST_0R_SPAM;
        }
        else if(taskObj.CallDisposition.contains(Tasks.ACTIVITY_OUTCOME_WRONG_NUMBER))
        {
            taskObj.Activity_Outcome__c = Tasks.ACTIVITY_OUTCOME_WRONG_NUMBER;
        }
        else{
            taskObj.Activity_Outcome__c = null;
        }
    }
}