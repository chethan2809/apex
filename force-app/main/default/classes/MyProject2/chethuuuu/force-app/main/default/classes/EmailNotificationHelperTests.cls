@isTest
private class EmailNotificationHelperTests {

    @TestSetup
    static void makeData(){

        TestUtility.runSetupData();
        Account account = TestUtility.createAccount();
        Contact contact = TestUtility.createContact();
        loan__Bank_Account__c loanBankAccount = TestUtility.createBankAccount();
    }

    @isTest
    private static void sendEmailNotificationTestMethod(){

        String notificationType = 'Personal Address';
        String loanStatus = 'Active - Good Standing';
        List<EmailTemplate> notificationTemplates = new List<EmailTemplate>();

        Account accnt = [SELECT id,Name,BillingBuildingNumber__c,BillingStreet,BillingCity,
                                BillingState,BillingCountry,BillingPostalCode,Phone
                         FROM Account
                         LIMIT 1];
        accnt.phone = '9999999999';

        Contact con = [SELECT Id,Name,Account.Name,MailingBuildingNumber__c,MailingCity,MailingState,
                                MailingCountry,MobilePhone,Email,MailingPostalCode,MailingStreet
                       FROM Contact
                       LIMIT 1];
        con.AccountId = accnt.Id;
        con.Account = accnt;
        con.MobilePhone = '9989033885';
        con.MailingPostalCode = '500001';
        con.MailingBuildingNumber__c = '04301';
        con.MailingCity = 'MailingCity';
        con.MailingState = 'MailingState';
        con.MailingCountry = 'MailingCountry';
        con.MailingStreet = 'MailingStreet';
        update con;

        loan__Bank_Account__c loanBankAcc = [SELECT Id,loan__Bank_Name__c,
                                                    loan__Account_Type__c
                                             FROM loan__Bank_Account__c
                                             LIMIT 1];

        clcommon__Address__c editedBusinessAddress = new clcommon__Address__c();
        editedBusinessAddress.genesis__Active__c = false;
        editedBusinessAddress.clcommon__Address_Line_2__c = 'Test Address';
        editedBusinessAddress.clcommon__Street_Address__c = 'Test Street Address';
        editedBusinessAddress.clcommon__City__c = 'Test City';
        editedBusinessAddress.clcommon__State_Province__c = 'Test State Province';
        editedBusinessAddress.clcommon__Country__c = 'Test Country';
        editedBusinessAddress.clcommon__Zip_Code__c = '500001';
        Insert editedBusinessAddress;

        System.RunAs(new User(Id = UserInfo.getUserId()))
        {
            List<String> queueNames = new List<String>{PortalConstants.UNDER_WRITER_QUEUE_NAME,PortalConstants.COLLECTIONS_TEAM_QUEUE_NAME};
            List<Group> existingGroupsList = [SELECT Id,DeveloperName
                                              FROM Group
                                              WHERE Type = 'Queue'
                                              AND DeveloperName
                                              IN:queueNames];
            Map<String,Group> groupMap = new Map<String,Group>();
            List<Group> groupsList = new List<Group>();
                for(Group gp: existingGroupsList){
                    groupMap.put(gp.DeveloperName,gp);
            }

            for(String devName: queueNames){
                if(!groupMap.containsKey(devName)){
                    Group testGroup = new Group(Name = devName,DeveloperName = devName, Type='Queue');
                    groupsList.add(testGroup);
                }
            }

            if(!groupsList.isEmpty())
                insert groupsList;

            List<User> queueMemberUserList = new List<User>();
            User user = new User();
            user.ProfileID = [Select Id From Profile Where Name='System Administrator'].Id;
            user.EmailEncodingKey = 'ISO-8859-1';
            user.LanguageLocaleKey = 'en_US';
            user.TimeZoneSidKey = 'America/New_York';
            user.LocaleSidKey = 'en_US';
            user.FirstName = 'first';
            user.LastName = 'last';
            user.Username = TestUtility.generateFakeName() + '@example.com';
            user.CommunityNickname = 'testUser123';
            user.Alias = 't1';
            user.Email = 'no@email.com';
            user.IsActive = true;
            insert user;
            queueMemberUserList.add(user);

            User user1 = new User();
            user1.ProfileID = [SELECT Id
                               FROM Profile
                               WHERE Name = 'System Administrator'].Id;
            user1.EmailEncodingKey = 'ISO-8859-1';
            user1.LanguageLocaleKey = 'en_US';
            user1.TimeZoneSidKey = 'America/New_York';
            user1.LocaleSidKey = 'en_US';
            user1.FirstName = 'first 1';
            user1.LastName = 'last 1';
            user1.Username = TestUtility.generateFakeName() + '@example.com';
            user1.CommunityNickname = 'testUser1234';
            user1.Alias = 't1';
            user1.Email = 'no@email.com';
            user1.IsActive = true;
            insert user1;
            queueMemberUserList.add(user1);

            List<Group> existingGroupsLists = [SELECT Id,DeveloperName
                                               FROM Group
                                               WHERE Type = 'Queue'
                                               AND DeveloperName
                                               IN:queueNames];

            List<GroupMember> grMembers = new List<GroupMember>();
            GroupMember member1 = new GroupMember(UserOrGroupId = user.id,GroupId = existingGroupsLists[0].id);
            GroupMember member2 = new GroupMember(UserOrGroupId = user1.id,GroupId = existingGroupsLists[1].id);
            grMembers.add(member1);
            grMembers.add(member2);
            insert grMembers;

            EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'DumyName';
            validEmailTemplate.DeveloperName = PortalConstants.CONTACT_INFO_CHANGE_NOTIFICATION_TEMPLATE;
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();
            validEmailTemplate.body = '{{CONTACT_NAME}}';
            validEmailTemplate.subject = '[Account Name]';
            validEmailTemplate.HtmlValue = '{{CREDIT_REPORT_MESSAGE}}';
            notificationTemplates.add(validEmailTemplate);

            EmailTemplate validEmailTemplate1 = new EmailTemplate();
            validEmailTemplate1.isActive = true;
            validEmailTemplate1.Name = 'DumyName1';
            validEmailTemplate1.DeveloperName = PortalConstants.BANK_ACCOUNT_CHANGE_NOTIFICATION_TEMPLATE;
            validEmailTemplate1.TemplateType = 'text';
            validEmailTemplate1.FolderId = UserInfo.getUserId();
            validEmailTemplate1.body = '{{CONTACT_NAME}}';
            validEmailTemplate1.subject = '[Account Name]';
            validEmailTemplate1.HtmlValue = '{{CREDIT_REPORT_MESSAGE}}';
            notificationTemplates.add(validEmailTemplate1);

            insert notificationTemplates;
        }

        List<String> templateNames = new List<String>{PortalConstants.CONTACT_INFO_CHANGE_NOTIFICATION_TEMPLATE,PortalConstants.BANK_ACCOUNT_CHANGE_NOTIFICATION_TEMPLATE};
        List<String> queueName = new List<String>{PortalConstants.UNDER_WRITER_QUEUE_NAME,PortalConstants.COLLECTIONS_TEAM_QUEUE_NAME};

        Test.startTest();
            EmailNotificationHelper.sendEmailNotification(notificationType,loanStatus,con,'OldAddress',con,accnt,accnt,editedBusinessAddress,loanBankAcc,loanBankAcc,'OldPhone');
            EmailNotificationHelper.sendEmailNotification(notificationType,'Active - Bad Standing',con,'OldAddress',con,accnt,accnt,editedBusinessAddress,loanBankAcc,loanBankAcc,'OldPhone');
            EmailNotificationHelper.sendEmailNotification('Business Address','Active - Bad Standing',con,'OldAddress',con,accnt,accnt,editedBusinessAddress,loanBankAcc,loanBankAcc,'OldPhone');
            EmailNotificationHelper.sendEmailNotification('Personal Phone','Active - Bad Standing',con,'OldAddress',con,accnt,accnt,editedBusinessAddress,loanBankAcc,loanBankAcc,'OldPhone');
            EmailNotificationHelper.sendEmailNotification('Business Phone','Active - Bad Standing',con,'OldAddress',con,accnt,accnt,editedBusinessAddress,loanBankAcc,loanBankAcc,'OldPhone');
            EmailNotificationHelper.sendEmailNotification('Bank Account','Active - Bad Standing',con,'OldAddress',con,accnt,accnt,editedBusinessAddress,loanBankAcc,loanBankAcc,'OldPhone');
            EmailNotificationHelper.sendEmailNotification('Contact_Information_Change_Notification_to_Under_Writer_and_Collection_Agent','Active - Bad Standing',con,'OldAddress',con,accnt,accnt,editedBusinessAddress,loanBankAcc,loanBankAcc,'OldPhone');
            EmailNotificationHelper.sendEmailNotification('Bank_Account_Change_Notification_to_Under_Writer_and_Collection_Agent','Active - Bad Standing',con,'OldAddress',con,accnt,accnt,editedBusinessAddress,loanBankAcc,loanBankAcc,'OldPhone');
        Test.stopTest();

        System.assertEquals('9999999999', accnt.phone);
        System.assertEquals(PortalConstants.BANK_ACCOUNT_CHANGE_NOTIFICATION_TEMPLATE,notificationTemplates[1].DeveloperName);
    }

    @isTest
    private static void sendMerchantEmailNotificationTestMethod(){

        Account accnt = [SELECT Id,Name
                       	 FROM Account
                         LIMIT 1];

        Contact con = [SELECT Id,Name,Account.Name,Accountid,Email
                       FROM Contact
                       LIMIT 1];
        con.AccountId = accnt.Id;
        con.Account = accnt;
        con.Email = 'test@test.com';
        update con;

        case cs = new case();
        cs.AccountId = accnt.Id;
        cs.Type = PortalConstants.CASE_TYPE_BUSINESS_ADDRESS_CHANGE;
        cs.Status = 'OPEN';
        insert cs;

        Map<Id, Id> caseIdsMap = new Map<Id, Id>();
        List<Contact> contactList = new List<Contact>();
        Map<Id, Id> guarantorAccountIdsMap = new Map<Id, Id>();

        List<EmailTemplate> validEmailTemplateList = new List<EmailTemplate>();
        EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'DumyName1';
            validEmailTemplate.DeveloperName = PortalConstants.NOTIFICATION_TO_MERCHANT_BANK_ACCOUNT_CHANGE;
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();
            validEmailTemplate.body = '{{CONTACT_NAME}}';
            validEmailTemplate.subject = '[Account Name]';
            validEmailTemplate.HtmlValue = '{{CREDIT_REPORT_MESSAGE}}';
            validEmailTemplateList.add(validEmailTemplate);

        EmailTemplate validEmailTemplate1 = new EmailTemplate();
            validEmailTemplate1.isActive = true;
            validEmailTemplate1.Name = 'DumyName2';
            validEmailTemplate1.DeveloperName = PortalConstants.NOTIFICATION_TO_MERCHANT_BUSINESS_ADDRESS_CHANGE;
            validEmailTemplate1.TemplateType = 'text';
            validEmailTemplate1.FolderId = UserInfo.getUserId();
            validEmailTemplate1.body = '{{CONTACT_NAME}}';
            validEmailTemplate1.subject = '[Account Name]';
            validEmailTemplate1.HtmlValue = '{{CREDIT_REPORT_MESSAGE}}';
            validEmailTemplateList.add(validEmailTemplate1);

        System.RunAs(new User(Id = UserInfo.getUserId()))
        {
            insert validEmailTemplateList;
        }
        caseIdsMap.put(cs.AccountId,cs.Id);
        contactList.add(con);
        guarantorAccountIdsMap.put(accnt.Id,accnt.Id);

        Test.startTest();
            EmailNotificationHelper.sendMerchantEmailNotification(caseIdsMap,contactList,guarantorAccountIdsMap);

            cs.Type = PortalConstants.CASE_TYPE_BANK_ACCOUNT_CHANGE;
            update cs;
            EmailNotificationHelper.sendMerchantEmailNotification(caseIdsMap,contactList,guarantorAccountIdsMap);

            cs.Type = PortalConstants.CASE_TYPE_BANK_ACCOUNT_CHANGE;
            cs.Status = PortalConstants.NEW_CASE;
            update cs;
            EmailNotificationHelper.sendMerchantEmailNotification(caseIdsMap,contactList,guarantorAccountIdsMap);

            cs.Status = PortalConstants.APPROVED_CASE;
            update cs;
            EmailNotificationHelper.sendMerchantEmailNotification(caseIdsMap,contactList,guarantorAccountIdsMap);

            cs.Status = PortalConstants.REJECTED_CASE;
            update cs;
            EmailNotificationHelper.sendMerchantEmailNotification(caseIdsMap,contactList,guarantorAccountIdsMap);

            cs.Type = PortalConstants.CASE_TYPE_BUSINESS_ADDRESS_CHANGE;
            cs.Status = PortalConstants.NEW_CASE;
            update cs;
            EmailNotificationHelper.sendMerchantEmailNotification(caseIdsMap,contactList,guarantorAccountIdsMap);

            cs.Status = PortalConstants.APPROVED_CASE;
            update cs;
            EmailNotificationHelper.sendMerchantEmailNotification(caseIdsMap,contactList,guarantorAccountIdsMap);

            cs.Status = PortalConstants.REJECTED_CASE;
            update cs;
            EmailNotificationHelper.sendMerchantEmailNotification(caseIdsMap,contactList,guarantorAccountIdsMap);
        Test.stopTest();

        System.assertEquals(PortalConstants.NOTIFICATION_TO_MERCHANT_BANK_ACCOUNT_CHANGE, validEmailTemplateList[0].DeveloperName);
        System.assertEquals('[Account Name]', validEmailTemplate.subject);
    }
}