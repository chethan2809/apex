@isTest
private class UserTriggerTests {
    @isTest
    private static void userTrigger() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        List<User> currentUsers;
        UserRole userRole = [SELECT Id, DeveloperName
                             FROM UserRole
                             WHERE DeveloperName = 'CEO'
                             LIMIT 1];

        User adminUser = [SELECT Id, UserRoleId
                        FROM User
                        WHERE Profile.Name = 'System Administrator'
                        AND IsActive = true
                        LIMIT 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        System.runAs(adminUser) {
            Account account = new Account(Name='Test Account Name');
            insert account;

            Contact contact = new Contact(LastName = 'Contact Last Name', AccountId = account.Id);
            insert contact;

            User userRecord = new User();
            userRecord.ProfileID =
                [
                    SELECT Id
                    FROM Profile
                    WHERE Name='BrokerCommunityPlus'
                ].Id;
            userRecord.EmailEncodingKey = 'ISO-8859-1';
            userRecord.LanguageLocaleKey = 'en_US';
            userRecord.TimeZoneSidKey = 'America/New_York';
            userRecord.LocaleSidKey = 'en_US';
            userRecord.FirstName = 'first';
            userRecord.LastName = 'last';
            userRecord.Username = TestUtility.generateFakeName() + 'test2@test.com';
            userRecord.CommunityNickname = 'testUser123';
            userRecord.Alias = 't1';
            userRecord.Email = 'no@email.com';
            userRecord.IsActive = true;
            userRecord.ContactId = contact.Id;

            insert userRecord;

            currentUsers = [
                SELECT Id
                FROM User
                WHERE Id = :userRecord.Id
            ];
        }

        System.assertEquals(1, currentUsers.size());
    }
}