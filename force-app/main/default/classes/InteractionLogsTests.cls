@isTest
private class InteractionLogsTests {
    @isTest
    private static void interactionLogMandatoryInformationCheck() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Followup_Date__c = TestUtility.currentSystemDate.AddDays(-10);

        Test.startTest();
            InteractionLogs.interactionLogMandatoryInformationCheck(interactionLogRecord);
        Test.stopTest();

        System.assertEquals('Valid Follow Up Date (Date should be greater than current system date)', CollectionCaseConstants.VALID_FOLLOW_UP_DATE);
    }
    @isTest
    private static void interactionLogMandatoryInformationCheckForDateFields() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Proof_of_Claim_File_By_Date__c = TestUtility.currentSystemDate.AddDays(-10);

        Test.startTest();
            InteractionLogs.interactionLogMandatoryInformationCheck(interactionLogRecord);
        Test.stopTest();

        System.assertEquals('Valid Date (Date should be greater than current system date)', CollectionCaseConstants.VALID_DATE);
    }
    @isTest
    private static void interactionLogMandatoryInformationCheckForSuitFiledDate() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Suit_Filed_Date__c = TestUtility.currentSystemDate.AddDays(-10);

        Test.startTest();
            InteractionLogs.interactionLogMandatoryInformationCheck(interactionLogRecord);
        Test.stopTest();

        System.assertEquals('Valid Date (Date should be greater than current system date)', CollectionCaseConstants.VALID_DATE);
    }

     @isTest
    private static void interactionLogMandatoryInformationCheckBadContactInfo() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Action_Code__c = 'Bad Contact Info';

        Test.startTest();
            InteractionLogs.interactionLogMandatoryInformationCheck(interactionLogRecord);
        Test.stopTest();

        System.assertEquals(null, interactionLogRecord.Followup_Date__c);
    }

    @isTest
    private static void interactionLogMandatoryInformationCheckContactAttempt() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Action_Code__c = 'Contact Attempt';

        Test.startTest();
        	 InteractionLogs.interactionLogMandatoryInformationCheck(interactionLogRecord);
        Test.stopTest();

       System.assertEquals(null, interactionLogRecord.Followup_Date__c);
    }

     @isTest
    private static void interactionLogMandatoryInformationCheckLeftVoicemail() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Action_Code__c = 'Left Voicemail';

        Test.startTest();
        	 InteractionLogs.interactionLogMandatoryInformationCheck(interactionLogRecord);
        Test.stopTest();

         System.assertEquals(null, interactionLogRecord.Followup_Date__c);
    }

     @isTest
    private static void interactionLogMandatoryInformationCheckGatekeeper() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Action_Code__c = 'Gatekeeper';

        Test.startTest();
        	 InteractionLogs.interactionLogMandatoryInformationCheck(interactionLogRecord);
        Test.stopTest();

        System.assertEquals(null, interactionLogRecord.Followup_Date__c);
    }

    @isTest
    private static void interactionLogMandatoryInformationCheckFraud() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Action_Code__c = 'Fraud';

        Test.startTest();
        	 InteractionLogs.interactionLogMandatoryInformationCheck(interactionLogRecord);
        Test.stopTest();

        System.assertEquals(null, interactionLogRecord.Fraud_Alleged_Type__c);
    }

    @isTest
    private static void interactionLogMandatoryInformationCheckMovetoLegalCounsel() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Action_Code__c = 'Move to Legal Counsel';

        Test.startTest();
        	 InteractionLogs.interactionLogMandatoryInformationCheck(interactionLogRecord);
        Test.stopTest();

        System.assertEquals(null, interactionLogRecord.Legal_Counsel_Type__c);
    }

    @isTest
    private static void interactionLogMandatoryInformationCheckReceivershipDissolutionFound() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Action_Code__c = 'Receivership Dissolution Found';

        Test.startTest();
        	 InteractionLogs.interactionLogMandatoryInformationCheck(interactionLogRecord);
        Test.stopTest();

        System.assertEquals(false, interactionLogRecord.Receivership_Dissolution__c);
    }

    @isTest
    private static void interactionLogMandatoryInformationCheckJudgmentAwarded() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Action_Code__c = 'Judgment Awarded';

        Test.startTest();
        	 InteractionLogs.interactionLogMandatoryInformationCheck(interactionLogRecord);
        Test.stopTest();

        System.assertEquals(null, interactionLogRecord.Judgment_Amount__c);
        System.assertEquals(null, interactionLogRecord.Judgment_Date__c);
        System.assertEquals(null, interactionLogRecord.Judgment_Maturity_Date__c);
        System.assertEquals(null, interactionLogRecord.Judgement_Rate_of_Interest__c);
    }

    @isTest
    private static void interactionLogMandatoryInformationMovetoLegalCounsel() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Action_Code__c = 'Move to Legal Counsel';

        Test.startTest();
        	 InteractionLogs.interactionLogMandatoryInformationCheck(interactionLogRecord);
        Test.stopTest();

        System.assertEquals(null, interactionLogRecord.Legal_Counsel_Type__c);
    }

    @isTest
    private static void interactionLogMandatoryInformationCheckDebtConsolidatorFound() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Action_Code__c = 'Debt Consolidator Found';

        Test.startTest();
        	 InteractionLogs.interactionLogMandatoryInformationCheck(interactionLogRecord);
        Test.stopTest();

        System.assertEquals(null, interactionLogRecord.Contact__c);
        System.assertEquals(null, interactionLogRecord.Debt_Consolidator__c);
    }

    @isTest
    private static void interactionLogMandatoryInformationCheckMerchantRetainedAttorney() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Action_Code__c = 'Merchant Retained Attorney';

        Test.startTest();
        	 InteractionLogs.interactionLogMandatoryInformationCheck(interactionLogRecord);
        Test.stopTest();

        System.assertEquals(null, interactionLogRecord.Contact__c);
    }

    @isTest
    private static void subActionCodeCheck() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Followup_Date__c = TestUtility.currentSystemDate.AddDays(-10);

        Test.startTest();
        	 InteractionLogs.subActionCodeCheck(interactionLogRecord); 
        Test.stopTest();

        System.assertEquals('Valid Follow Up Date (Date should be greater than current system date)', CollectionCaseConstants.VALID_FOLLOW_UP_DATE);
    }

    @isTest
    private static void subActionCodeCheckContacted() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = 'Contacted';

        Test.startTest();
        	 InteractionLogs.subActionCodeCheck(interactionLogRecord);
        Test.stopTest();

        System.assertEquals(null, interactionLogRecord.Followup_Date__c);
    }

    @isTest
    private static void subActionCodeCheckRefusalToPay() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = 'Refusal To Pay';

        Test.startTest();
        	 InteractionLogs.subActionCodeCheck(interactionLogRecord);
        Test.stopTest();

        System.assertEquals(null, interactionLogRecord.Followup_Date__c);
    }

    @isTest
    private static void subActionCodeCheckBankruptcyFiled() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = 'Bankruptcy Filed';

        Test.startTest();
        	 InteractionLogs.subActionCodeCheck(interactionLogRecord);
        Test.stopTest();

        System.assertEquals(null, interactionLogRecord.Case_Number__c);
        System.assertEquals(null, interactionLogRecord.Bankruptcy_Chapter__c);
        System.assertEquals(null, interactionLogRecord.Parties_Associated__c);
        System.assertEquals(null, interactionLogRecord.Proof_of_Claim_File_By_Date__c);
    }

   @isTest
    private static void subActionCodeCheckBankruptcyProofofClaimFiled() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = 'Bankruptcy Proof of Claim Filed';

        Test.startTest();
        	 InteractionLogs.subActionCodeCheck(interactionLogRecord);
        Test.stopTest();

        System.assertEquals(null, interactionLogRecord.Bankruptcy_Proof_of_Claim_Filed__c);
        System.assertEquals(null, interactionLogRecord.Proof_of_Claim_Filed_Date__c);
    }

    @isTest
    private static void subActionCodeCheckBankruptcyStatusUpdate() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = 'Bankruptcy Status Update';

        Test.startTest();
        	 InteractionLogs.subActionCodeCheck(interactionLogRecord);
        Test.stopTest();

        System.assertEquals(null, interactionLogRecord.Bankruptcy_Status__c);
    }

    @isTest
    private static void subActionCodeCheckFraudAlleged() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = 'Fraud Alleged';

        Test.startTest();
        	 InteractionLogs.subActionCodeCheck(interactionLogRecord);
        Test.stopTest();

        System.assertEquals(null, interactionLogRecord.Fraud_Alleged_Type__c);
    }

    @isTest
    private static void subActionCodeCheckFraudConfirmed() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = 'Fraud Confirmed';

        Test.startTest();
        	 InteractionLogs.subActionCodeCheck(interactionLogRecord);
        Test.stopTest();

        System.assertEquals(false, interactionLogRecord.Collectable__c);
    }

    @isTest
    private static void subActionCodeCheckMovetoLegalCounsel() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = 'Move to Legal Counsel';

        Test.startTest();
        	 InteractionLogs.subActionCodeCheck(interactionLogRecord);
        Test.stopTest();

        System.assertEquals(null, interactionLogRecord.Legal_Counsel_Type__c);
    }

    @isTest
    private static void subActionCodeCheckSiteInspectionOrdered() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = 'Site Inspection Ordered';

        Test.startTest();
        	 InteractionLogs.subActionCodeCheck(interactionLogRecord);
        Test.stopTest();

        System.assertEquals(false, interactionLogRecord.Demand_Letter_Attached__c);
        System.assertEquals(null, interactionLogRecord.Inspection_Date__c);
    }

    @isTest
    private static void subActionCodeCheckSiteInspectionFindings() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = 'Site Inspection Findings';

        Test.startTest();
        	 InteractionLogs.subActionCodeCheck(interactionLogRecord);
        Test.stopTest();

        System.assertEquals(null, interactionLogRecord.Business_Status__c);
        System.assertEquals(false, interactionLogRecord.Ownership_Change__c);
        System.assertEquals(false, interactionLogRecord.Demand_Letter_Delivered__c);
        System.assertEquals(false, interactionLogRecord.Contact_Made_With_PG__c);
    }

    @isTest
    private static void subActionCodeCheckPreparingSuit() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = 'Preparing Suit';

        Test.startTest();
        	 InteractionLogs.subActionCodeCheck(interactionLogRecord);
        Test.stopTest();

        System.assertEquals(null, interactionLogRecord.Legal_Counsel_Type__c);
    }

    @isTest
    private static void subActionCodeCheckSuitFiled() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = 'Suit Filed';

        Test.startTest();
        	 InteractionLogs.subActionCodeCheck(interactionLogRecord);
        Test.stopTest();

        System.assertEquals(null, interactionLogRecord.Suit_Filed_Date__c);
        System.assertEquals(null, interactionLogRecord.Case_Number__c);
        System.assertEquals(null, interactionLogRecord.Court_Location__c);
        System.assertEquals(null, interactionLogRecord.Legal_Counsel_Type__c);
    }
}