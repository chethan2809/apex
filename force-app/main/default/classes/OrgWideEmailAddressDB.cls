public class OrgWideEmailAddressDB extends DBManager{

    public List<OrgWideEmailAddress> getAllOrgWideEmailAddressList(){

        return [SELECT Id, Address
                FROM OrgWideEmailAddress
               ];
    }
}