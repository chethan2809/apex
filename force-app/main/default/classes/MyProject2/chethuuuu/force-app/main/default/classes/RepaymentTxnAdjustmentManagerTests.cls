@isTest(isParallel=true)
private class RepaymentTxnAdjustmentManagerTests {

    private static EmailDB emailDBInstance = new EmailDB();

    @isTest
    private static void sendReversalTransactionNotification() {
        loan__Repayment_Transaction_Adjustment__c reversalTransaction = new loan__Repayment_Transaction_Adjustment__c();
        reversalTransaction.Id = TestUtility.getFakeId(loan__Repayment_Transaction_Adjustment__c.getSObjectType());

        DBManagerTestsStub repaymentTransactionDBStubInstance = new DBManagerTestsStub();
        repaymentTransactionDBStubInstance.genericReturnObject = new List<loan__Repayment_Transaction_Adjustment__c>{reversalTransaction};
        RepaymentTxnAdjustmentManager.RepaymentTxnAdjustmentDBInstance = (RepaymentTxnAdjustmentDB) Test.createStub(RepaymentTxnAdjustmentDB.class, repaymentTransactionDBStubInstance);

        Set<Id> reversalTransactionIds = new Set<Id>();
        reversalTransactionIds.add(reversalTransaction.Id);

        EmailTemplate template = new EmailTemplate();
        template.Subject = 'Your application has been denied';
        template.Body = 'test body';

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Contact primaryContact = (Contact) JSON.deserialize(
            '{ "Name" : "Test Primary"}' ,
            Contact.class
        );
        primaryContact.Id = TestUtility.getFakeId(Contact.getSObjectType());
        primaryContact.FirstName = 'Test First';
        primaryContact.LastName = 'Test Last';
        primaryContact.Email = 'Test@sample.com';

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);

        User queueCollector = new User();
        queueCollector.Id = TestUtility.getFakeId(User.getSObjectType());
        queueCollector.FirstName = 'Test';
        queueCollector.LastName = 'Collector';
        queueCollector.Email = 'collector@collector.com';
        queueCollector.Title = 'Collection Manager';
        queueCollector.Phone = '9876543210';

        loan__Loan_Account__c loanAccount = (loan__Loan_Account__c) JSON.deserialize(
            '{ "Name" : "LAI-000000", "Id" : "aBj6w000000GtIv"}' ,
            loan__Loan_Account__c.class
        );
        loanAccount.loan__Last_Accrual_Date__c = GeneralHelper.currentSystemDate;
        loanAccount.Primary_Contact__c = primaryContact.Id;
        loanAccount.Primary_Contact__r = primaryContact;
        loanAccount.loan__Disbursed_Amount__c = 5000;
        loanAccount.loan__Disbursal_Date__c = Date.newInstance(2020, 02, 21);

        loan__Loan_Payment_Transaction__c loanPayment = (loan__Loan_Payment_Transaction__c) JSON.deserialize(
            '{ "Name" : "Test LoanPayment", "loan__Loan_Account__c" : "aBj6w000000GtIv"}' ,
            loan__Loan_Payment_Transaction__c.class
        );
        loanPayment.Id = TestUtility.getFakeId(loan__Loan_Payment_Transaction__c.getSObjectType());
        loanPayment.loan__Payment_Mode__c = TestUtility.getFakeId(loan__Payment_Mode__c.getSObjectType());
        loanPayment.loan__Transaction_Amount__c = 5000;
        loanPayment.loan__Loan_Account__r  = loanAccount;
        loanPayment.loan__Skip_Validation__c = true;
        loanPayment.loan__Cleared__c = true;

        List<loan__Repayment_Transaction_Adjustment__c> repaymentTransactionList = new List<loan__Repayment_Transaction_Adjustment__c>();
        loan__Repayment_Transaction_Adjustment__c repaymentTransaction = (loan__Repayment_Transaction_Adjustment__c) JSON.deserialize(
            '{ "Name" : "Test Reversal", "loan__Loan_Payment_Transaction__c" : "loanPayment.Id"}' ,
            loan__Repayment_Transaction_Adjustment__c.class
        );
        repaymentTransaction.Id = TestUtility.getFakeId(loan__Repayment_Transaction_Adjustment__c.getSObjectType());
        repaymentTransaction.loan__Reason_Code__c = 'NSF';
        repaymentTransaction.loan__Transaction_Creation_Date__c = Date.today();
        repaymentTransaction.loan__Loan_Payment_Transaction__r = loanPayment;

        repaymentTransactionList.add(repaymentTransaction);

        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.Id = TestUtility.getFakeId(EmailTemplate.getSObjectType());
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'name';
        validEmailTemplate.DeveloperName = 'unique_name_addSomethingSpecialHere';
        validEmailTemplate.FolderId = UserInfo.getUserId();
        validEmailTemplate.body = '{{CONTACT_NAME}}{{TRANSACTION_DATE}}{{TRANSACTION_AMOUNT}}{{CAN_CAPITAL_EMPLOYEE_NAME}}{{CAN_CAPITAL_EMPLOYEE_TITLE}}{{CAN_CAPITAL_EMPLOYEE_EMAIL}}{{CAN_CAPITAL_EMPLOYEE_PHONE}}';
        validEmailTemplate.subject = '{{CONTACT_NAME}}';
        validEmailTemplate.HtmlValue = '{{CONTACT_NAME}}{{TRANSACTION_DATE}}{{TRANSACTION_AMOUNT}}{{CAN_CAPITAL_EMPLOYEE_NAME}}{{CAN_CAPITAL_EMPLOYEE_TITLE}}{{CAN_CAPITAL_EMPLOYEE_EMAIL}}{{CAN_CAPITAL_EMPLOYEE_PHONE}}';

        collect__Queue_Contract__c queueContract = (collect__Queue_Contract__c) JSON.deserialize(
            '{ "Name" : "LAI-000000", "collect__Loan_Account_Id__c" : "aBj6w000000GtIv", "collect__Collector__c" : "Test Collector"}' ,
            collect__Queue_Contract__c.class
        );
        queueContract.Id = TestUtility.getFakeId(collect__Queue_Contract__c.getSObjectType());
        queueContract.collect__User__c = queueCollector.Id;
        queueContract.collect__User__r = queueCollector;

        loan__Office_Name__c loanOfficeName = new loan__Office_Name__c();
        loanOfficeName.Id = loanOfficeName.Id = TestUtility.getFakeId(loan__Office_Name__c.getSObjectType());

        loan__User_Branch_Info__c userBranchInfo = new loan__User_Branch_Info__c();
        userBranchInfo.Id = TestUtility.getFakeId(loan__User_Branch_Info__c.getSObjectType());

        DBManagerTestsStub loanOfficeNameDBInstance = new DBManagerTestsStub();
        loanOfficeNameDBInstance.genericReturnObject = new List<loan__Office_Name__c>{loanOfficeName};
        UserManager.loanOfficeNameDBInstance = (LoanOfficeNameDB) Test.createStub(LoanOfficeNameDB.class, loanOfficeNameDBInstance);

        DBManagerTestsStub userBranchInfoDBInstance = new DBManagerTestsStub();
        userBranchInfoDBInstance.genericReturnObject = new List<loan__Office_Name__c>{loanOfficeName};
        UserManager.userBranchInfoDBInstance = (UserBranchInfoDB) Test.createStub(UserBranchInfoDB.class, userBranchInfoDBInstance);

        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.DeveloperName = 'Default';
        originationSettings.MasterLabel = originationSettings.DeveloperName;
        originationSettings.Derron_Hardy_Email__c = 'testunique@cancapital.com';
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;

        DBManagerTestsStub queueContractDBInstance = new DBManagerTestsStub();
        queueContractDBInstance.genericReturnObject = new List<collect__Queue_Contract__c>{queueContract};
        RepaymentTxnAdjustmentManager.queueContractDBInstance = (QueueContractDB) Test.createStub(QueueContractDB.class, queueContractDBInstance);

        String fromAddress = 'test1@example.com';
        String subject = 'Dummy Subject';
        String htmlTextBody = '<b>Dummy Html Text Body</b><br/>';
        List<String> toAddress = new List<String>{'test@example.com'};

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = Emails.getEmailMessageSetup(
            toAddress, null, fromAddress, subject, htmlTextBody, true,
            new Map<String, Blob>{'a' => Blob.valueOf('a')}, null
        );
        emailList.add(email);

        User derronHardy = new User();
        derronHardy.Id = TestUtility.getFakeId(User.getSObjectType());
        derronHardy.FirstName = 'Dorren';
        derronHardy.LastName = 'Hardy';
        derronHardy.Email = 'dhardy@cancapital.com';
        derronHardy.Title = 'Collection manager';
        derronHardy.Phone = '9876543210';

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User> { derronHardy };
        RepaymentTxnAdjustmentManager.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        List<Messaging.SendEmailResult> sendEmailResult = emailDbInstance.sendEmail(email);
        Exception ex;
        Test.startTest();
        try{
            RepaymentTxnAdjustmentManager.sendReversalTransactionNotification(reversalTransactionIds);
        }catch(Exception e){
            ex = e;
        }
        Test.stopTest();

        System.assertEquals(0, repaymentTransactionDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void setContractFieldsForReturnACHFee() {

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Contact primaryContact = (Contact) JSON.deserialize(
            '{ "Name" : "Test Primary"}' ,
            Contact.class
        );
        primaryContact.Id = TestUtility.getFakeId(Contact.getSObjectType());
        primaryContact.FirstName = 'Test First';
        primaryContact.LastName = 'Test Last';
        primaryContact.Email = 'Test@sample.com';

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        User collector = new User();
        collector.Id = TestUtility.getFakeId(User.getSObjectType());
        collector.FirstName = 'Test';
        collector.LastName = 'Collector';
        collector.Email = 'collector@collector.com';
        collector.Title = 'Collection Manager';
        collector.Phone = '9876543210';


        loan__Loan_Account__c loanAccount = (loan__Loan_Account__c) JSON.deserialize(
            '{ "Name" : "LAI-000000", "Id" : "aBj6w000000GtIv"}' ,
            loan__Loan_Account__c.class
        );
        loanAccount.loan__Last_Accrual_Date__c = GeneralHelper.currentSystemDate;
        loanAccount.Primary_Contact__c = primaryContact.Id;
        loanAccount.Primary_Contact__r = primaryContact;
        loanAccount.loan__Disbursed_Amount__c = 5000;
        loanAccount.loan__Disbursal_Date__c = Date.newInstance(2020, 02, 21);

        loan__Loan_Payment_Transaction__c loanPayment = (loan__Loan_Payment_Transaction__c) JSON.deserialize(
            '{ "Name" : "Test LoanPayment", "loan__Loan_Account__c" : "aBj6w000000GtIv"}' ,
            loan__Loan_Payment_Transaction__c.class
        );
        loanPayment.Id = TestUtility.getFakeId(loan__Loan_Payment_Transaction__c.getSObjectType());
        loanPayment.loan__Payment_Mode__c = TestUtility.getFakeId(loan__Payment_Mode__c.getSObjectType());
        loanPayment.loan__Transaction_Amount__c = 5000;
        loanPayment.loan__Loan_Account__r  = loanAccount;
        loanPayment.loan__Skip_Validation__c = true;
        loanPayment.loan__Cleared__c = true;

        List<loan__Repayment_Transaction_Adjustment__c> repaymentTransactionList = new List<loan__Repayment_Transaction_Adjustment__c>();
        loan__Repayment_Transaction_Adjustment__c repaymentTransaction = (loan__Repayment_Transaction_Adjustment__c) JSON.deserialize(
            '{ "Name" : "Test Reversal"}' ,
            loan__Repayment_Transaction_Adjustment__c.class
        );
        repaymentTransaction.Id = TestUtility.getFakeId(loan__Repayment_Transaction_Adjustment__c.getSObjectType());
        repaymentTransaction.loan__Reason_Code__c = 'R01';
        repaymentTransaction.loan__Transaction_Creation_Date__c = Date.today();
        repaymentTransaction.loan__Loan_Payment_Transaction__r = loanPayment;
        repaymentTransaction.loan__Adjustment_Txn_Date__c = GeneralHelper.currentSystemDate;

        Map<Id, loan__Repayment_Transaction_Adjustment__c> repaymentTransactionMap = new Map<Id, loan__Repayment_Transaction_Adjustment__c>();
        repaymentTransactionMap.put(repaymentTransaction.Id, repaymentTransaction);

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{loanAccount};
        RepaymentTxnAdjustmentManager.contractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);


        Exception ex;
        Test.startTest();
        try{
            RepaymentTxnAdjustmentManager.setContractFields(repaymentTransactionMap);
        }catch(Exception e){
            ex = e;
        }
        Test.stopTest();

        System.assertEquals(1, clContractDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void setContractFieldsForBlockedAccountFee() {

        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);
        Date achTurnedDate = GeneralHelper.currentSystemDate;

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Contact primaryContact = (Contact) JSON.deserialize(
            '{ "Name" : "Test Primary"}' ,
            Contact.class
        );
        primaryContact.Id = TestUtility.getFakeId(Contact.getSObjectType());
        primaryContact.FirstName = 'Test First';
        primaryContact.LastName = 'Test Last';
        primaryContact.Email = 'Test@sample.com';

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        User collector = new User();
        collector.Id = TestUtility.getFakeId(User.getSObjectType());
        collector.FirstName = 'Test';
        collector.LastName = 'Collector';
        collector.Email = 'collector@collector.com';
        collector.Title = 'Collection Manager';
        collector.Phone = '9876543210';

        loan__Loan_Account__c loanAccount = (loan__Loan_Account__c) JSON.deserialize(
            '{ "Name" : "LAI-000000", "Id" : "aBj6w000000GtIa"}' ,
            loan__Loan_Account__c.class
        );
        loanAccount.loan__Last_Accrual_Date__c = GeneralHelper.currentSystemDate;
        loanAccount.Primary_Contact__c = primaryContact.Id;
        loanAccount.Primary_Contact__r = primaryContact;
        loanAccount.loan__Disbursed_Amount__c = 5000;
        loanAccount.loan__Disbursal_Date__c = Date.newInstance(2020, 02, 21);

        loan__Loan_Payment_Transaction__c loanPayment = (loan__Loan_Payment_Transaction__c) JSON.deserialize(
            '{ "Name" : "Test LoanPayment", "loan__Loan_Account__c" : "aBj6w000000GtIa"}' ,
            loan__Loan_Payment_Transaction__c.class
        );
        loanPayment.Id = TestUtility.getFakeId(loan__Loan_Payment_Transaction__c.getSObjectType());
        loanPayment.loan__Payment_Mode__c = TestUtility.getFakeId(loan__Payment_Mode__c.getSObjectType());
        loanPayment.loan__Transaction_Amount__c = 5000;
        loanPayment.loan__Loan_Account__r  = loanAccount;
        loanPayment.loan__Skip_Validation__c = true;
        loanPayment.loan__Cleared__c = true;

        List<loan__Repayment_Transaction_Adjustment__c> repaymentTransactionList = new List<loan__Repayment_Transaction_Adjustment__c>();
        loan__Repayment_Transaction_Adjustment__c repaymentTransaction = (loan__Repayment_Transaction_Adjustment__c) JSON.deserialize(
            '{ "Name" : "Test Reversal", "loan__Loan_Payment_Transaction__c" : "loanPayment.Id"}' ,
            loan__Repayment_Transaction_Adjustment__c.class
        );
        repaymentTransaction.Id = TestUtility.getFakeId(loan__Repayment_Transaction_Adjustment__c.getSObjectType());
        repaymentTransaction.loan__Reason_Code__c = 'R02';
        repaymentTransaction.loan__Transaction_Creation_Date__c = Date.today();
        repaymentTransaction.loan__Loan_Payment_Transaction__r = loanPayment;
        repaymentTransaction.loan__Adjustment_Txn_Date__c = GeneralHelper.currentSystemDate;

        Map<Id, loan__Repayment_Transaction_Adjustment__c> repaymentTransactionMap = new Map<Id, loan__Repayment_Transaction_Adjustment__c>();
        repaymentTransactionMap.put(repaymentTransaction.Id, repaymentTransaction);

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{loanAccount};
        RepaymentTxnAdjustmentManager.contractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);


        Exception ex;
        Test.startTest();
        try{
            RepaymentTxnAdjustmentManager.setContractFields(repaymentTransactionMap);
        }catch(Exception e){
            ex = e;
        }
        Test.stopTest();

        System.assertEquals(1, clContractDBStubInstance.forUpdateSObjects.size());
    }
}