@isTest
public class CCBPBrokerHierarchyManagerTests {
    @isTest
    public static void testMethods(){
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

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
         System.runAs(adminUser){

		Account account = new Account(Name='Test Account Name');
		insert account;
		Account childAcc = new Account (
			Name = 'childAccount',
            parent = account
		);
        insert childAcc;
 		Contact contact = new Contact(LastName = 'Contact Last Name', AccountId = account.Id);
 		insert contact;

         User user = new User();
         user.ProfileID = [SELECT Id
                           FROM Profile
                           WHERE Name='BrokerCommunityPlus'].Id;
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
         user.ContactId = contact.Id;
         insert user;
             System.debug('&&&&'+user);
             System.debug('&&&&'+user.AccountId);
             System.debug('@@@@'+[Select id,Contactid from User where id =:user.id]);
         	System.debug('<<>>>'+[SELECT Id, Name,
                (SELECT Id, Name FROM ChildAccounts)
            	FROM Account
            	WHERE Id =:account.Id]);
         System.runAs(user){
        CCBPBrokerHierarchyManager.getBrokerUserIds();
        }
         }
    }
}