@isTest
private class TasksTests {

    @isTest
    private static void createTask() {
        collect__Collection_Activity__c collectionActivity = new collect__Collection_Activity__c();
        collectionActivity.Id = TestUtility.getFakeId(collectionActivity.getSObjectType());
        collectionActivity.collect__Account_Manager__c = TestUtility.getFakeId(Contact.getSObjectType());

        Test.startTest();
            Task taskCreate = Tasks.createTask(collectionActivity);
        Test.stopTest();

        System.assertEquals(collectionActivity.Id, taskCreate.WhatId);
        System.assertEquals(collectionActivity.collect__Account_Manager__c, taskCreate.OwnerId);
    }

    @isTest
    private static void beforeUpdateForEmail(){

        Task newTask = new Task();
        newTask.Id = TestUtility.getFakeId(Task.getSObjectType());
        newTask.CallDisposition = Tasks.ACTIVITY_OUTCOME_EMAIL;

        Test.startTest();
            Tasks.setActivityOutcomeByCallDisposition(newTask);
        Test.stopTest();

        System.assertEquals(newTask.Activity_Outcome__c, Tasks.ACTIVITY_OUTCOME_EMAIL);
    }

    @isTest
    private static void beforeUpdateForCallbackScheduled(){

        Task newTask = new Task();
        newTask.Id = TestUtility.getFakeId(Task.getSObjectType());
        newTask.CallDisposition = Tasks.ACTIVITY_OUTCOME_CALLBACK_SCHEDULED;

        Test.startTest();
            Tasks.setActivityOutcomeByCallDisposition(newTask);
        Test.stopTest();

        System.assertEquals(newTask.Activity_Outcome__c, Tasks.ACTIVITY_OUTCOME_CALLBACK_SCHEDULED);
    }

    @isTest
    private static void beforeUpdateForDoNotCall(){

        Task newTask = new Task();
        newTask.Id = TestUtility.getFakeId(Task.getSObjectType());
        newTask.CallDisposition = Tasks.ACTIVITY_OUTCOME_DO_NOT_CALL;

        Test.startTest();
            Tasks.setActivityOutcomeByCallDisposition(newTask);
        Test.stopTest();

        System.assertEquals(newTask.Activity_Outcome__c, Tasks.ACTIVITY_OUTCOME_DO_NOT_CALL);
    }

    @isTest
    private static void beforeUpdateForInMarket(){

        Task newTask = new Task();
        newTask.Id = TestUtility.getFakeId(Task.getSObjectType());
        newTask.CallDisposition = Tasks.ACTIVITY_OUTCOME_IN_MARKET;

        Test.startTest();
            Tasks.setActivityOutcomeByCallDisposition(newTask);
        Test.stopTest();

        System.assertEquals(newTask.Activity_Outcome__c, Tasks.ACTIVITY_OUTCOME_IN_MARKET);
    }

    @isTest
    private static void beforeUpdateForLeftMessage(){

        Task newTask = new Task();
        newTask.Id = TestUtility.getFakeId(Task.getSObjectType());
        newTask.CallDisposition = Tasks.ACTIVITY_OUTCOME_LEFT_MESSAGE;

        Test.startTest();
            Tasks.setActivityOutcomeByCallDisposition(newTask);
        Test.stopTest();

        System.assertEquals(newTask.Activity_Outcome__c, Tasks.ACTIVITY_OUTCOME_LEFT_MESSAGE);
    }

    @isTest
    private static void beforeUpdateForNoAnswer(){

        Task newTask = new Task();
        newTask.Id = TestUtility.getFakeId(Task.getSObjectType());
        newTask.CallDisposition = Tasks.ACTIVITY_OUTCOME_NO_ANSWER_NO_VM;

        Test.startTest();
            Tasks.setActivityOutcomeByCallDisposition(newTask);
        Test.stopTest();

        System.assertEquals(newTask.Activity_Outcome__c, Tasks.ACTIVITY_OUTCOME_NO_ANSWER_NO_VM);
    }

    @isTest
    private static void beforeUpdateForNotInterested(){

        Task newTask = new Task();
        newTask.Id = TestUtility.getFakeId(Task.getSObjectType());
        newTask.CallDisposition = Tasks.ACTIVITY_OUTCOME_NOT_INTERESTED;

        Test.startTest();
            Tasks.setActivityOutcomeByCallDisposition(newTask);
        Test.stopTest();

        System.assertEquals(newTask.Activity_Outcome__c, Tasks.ACTIVITY_OUTCOME_NOT_INTERESTED);
    }

    @isTest
    private static void beforeUpdateForOpenOppInProgress(){

        Task newTask = new Task();
        newTask.Id = TestUtility.getFakeId(Task.getSObjectType());
        newTask.CallDisposition = Tasks.ACTIVITY_OUTCOME_OPEN_OPP_IN_PROGRESS;

        Test.startTest();
            Tasks.setActivityOutcomeByCallDisposition(newTask);
        Test.stopTest();

        System.assertEquals(newTask.Activity_Outcome__c, Tasks.ACTIVITY_OUTCOME_OPEN_OPP_IN_PROGRESS);
    }

    @isTest
    private static void beforeUpdateForOutOfBusiness(){

        Task newTask = new Task();
        newTask.Id = TestUtility.getFakeId(Task.getSObjectType());
        newTask.CallDisposition = Tasks.ACTIVITY_OUTCOME_OUT_OF_BUSINESS;

        Test.startTest();
            Tasks.setActivityOutcomeByCallDisposition(newTask);
        Test.stopTest();

        System.assertEquals(newTask.Activity_Outcome__c, Tasks.ACTIVITY_OUTCOME_OUT_OF_BUSINESS);
    }

    @isTest
    private static void beforeUpdateForOutOfMarket(){

        Task newTask = new Task();
        newTask.Id = TestUtility.getFakeId(Task.getSObjectType());
        newTask.CallDisposition = Tasks.ACTIVITY_OUTCOME_OUT_OF_MARKET;

        Test.startTest();
            Tasks.setActivityOutcomeByCallDisposition(newTask);
        Test.stopTest();

        System.assertEquals(newTask.Activity_Outcome__c, Tasks.ACTIVITY_OUTCOME_OUT_OF_MARKET);
    }

    @isTest
    private static void beforeUpdateForCustomerService(){

        Task newTask = new Task();
        newTask.Id = TestUtility.getFakeId(Task.getSObjectType());
        newTask.CallDisposition = Tasks.ACTIVITY_OUTCOME_CUSTOMER_SERVICE;

        Test.startTest();
            Tasks.setActivityOutcomeByCallDisposition(newTask);
        Test.stopTest();

        System.assertEquals(newTask.Activity_Outcome__c, Tasks.ACTIVITY_OUTCOME_CUSTOMER_SERVICE);
    }

    @isTest
    private static void beforeUpdateForDoesNotQualify(){

        Task newTask = new Task();
        newTask.Id = TestUtility.getFakeId(Task.getSObjectType());
        newTask.CallDisposition = Tasks.ACTIVITY_OUTCOME_DOES_NOT_QUALIFY;

        Test.startTest();
            Tasks.setActivityOutcomeByCallDisposition(newTask);
        Test.stopTest();

        System.assertEquals(newTask.Activity_Outcome__c, Tasks.ACTIVITY_OUTCOME_DOES_NOT_QUALIFY);
    }

    @isTest
    private static void beforeUpdateForConsentForCreditPull(){

        Task newTask = new Task();
        newTask.Id = TestUtility.getFakeId(Task.getSObjectType());
        newTask.CallDisposition = Tasks.ACTIVITY_OUTCOME_CONSENT_FOR_CREDIT_PULL;

        Test.startTest();
            Tasks.setActivityOutcomeByCallDisposition(newTask);
        Test.stopTest();

        System.assertEquals(newTask.Activity_Outcome__c, Tasks.ACTIVITY_OUTCOME_CONSENT_FOR_CREDIT_PULL);
    }
    @isTest
    private static void beforeUpdateForCallTransfer(){

        Task newTask = new Task();
        newTask.Id = TestUtility.getFakeId(Task.getSObjectType());
        newTask.CallDisposition = Tasks.ACTIVITY_OUTCOME_CALL_TRANSFER;

        Test.startTest();
            Tasks.setActivityOutcomeByCallDisposition(newTask);
        Test.stopTest();

        System.assertEquals(newTask.Activity_Outcome__c, Tasks.ACTIVITY_OUTCOME_CALL_TRANSFER);
    }

    @isTest
    private static void beforeUpdateForFrontDeskResponse(){

        Task newTask = new Task();
        newTask.Id = TestUtility.getFakeId(Task.getSObjectType());
        newTask.CallDisposition = Tasks.ACTIVITY_OUTCOME_FRONT_DESK_RESPONSE;

        Test.startTest();
            Tasks.setActivityOutcomeByCallDisposition(newTask);
        Test.stopTest();

        System.assertEquals(newTask.Activity_Outcome__c, Tasks.ACTIVITY_OUTCOME_FRONT_DESK_RESPONSE);
    }

    @isTest
    private static void beforeUpdateForGhostOrSpam(){

        Task newTask = new Task();
        newTask.Id = TestUtility.getFakeId(Task.getSObjectType());
        newTask.CallDisposition = Tasks.ACTIVITY_OUTCOME_GHOST_0R_SPAM;

        Test.startTest();
            Tasks.setActivityOutcomeByCallDisposition(newTask);
        Test.stopTest();

        System.assertEquals(newTask.Activity_Outcome__c, Tasks.ACTIVITY_OUTCOME_GHOST_0R_SPAM);
    }

    @isTest
    private static void beforeUpdateForWrongNumber(){

        Task newTask = new Task();
        newTask.Id = TestUtility.getFakeId(Task.getSObjectType());
        newTask.CallDisposition = Tasks.ACTIVITY_OUTCOME_WRONG_NUMBER;

        Test.startTest();
            Tasks.setActivityOutcomeByCallDisposition(newTask);
        Test.stopTest();

        System.assertEquals(newTask.Activity_Outcome__c, Tasks.ACTIVITY_OUTCOME_WRONG_NUMBER);
    }
}