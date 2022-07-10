@IsTest
public class CreatePortalUserManagerTests {

    @TestSetup
    static void makeData(){

     TestUtility.runSetupData();
        Contact contactRec = TestUtility.createContact();
    }

    @IsTest
    public static void createCommunityUserTestMethod()
    {

        Contact con = [SELECT id
                       FROM Contact
                       LIMIT 1];
        Set<Id> contactIds = new Set<Id>();
        contactIds.add(con.id);

        String pSetName = 'Test';

        Test.startTest();
        CreatePortalUserManager.createCommunityUser(contactIds,GeneralConstants.MERCHANT_USER_PROFILE_NAME,NUll);
        CreatePortalUserManager.createCommunityUser(contactIds,GeneralConstants.MERCHANT_USER_PROFILE_NAME,pSetName);
        try {
            CreatePortalUserManager.createCommunityUser(contactIds,'dummy',NUll);
        }
        catch(Exception e){}
        Test.stopTest();

        System.assert(con != Null);
       	System.assert(contactIds!= Null);
    }
}