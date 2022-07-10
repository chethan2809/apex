@isTest(isParallel=true)
public class ExperianCallOutTests {
    @Future(Callout=true)
    public static void getAccessTokenfuturemethod(){
        API_Detail__mdt apiDetails = Experians.experianConsumerAPIDetails;
        Test.setMock(HttpCalloutMock.class, new MockExperianCallOut());
        ExperianCallOut.getAccessToken(apiDetails);
    }

    @isTest
    public static void getAccessTokenTestMethod(){

		getAccessTokenfuturemethod();
    }

    @Future(Callout=true)
    public static void requestExperianBusinessSearchFutureMethod(){

        Account accountObj = new Account();
        accountObj.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountObj.Name = 'Parker Hannifin Corp';
        accountObj.BillingBuildingNumber__c = '17';
        accountObj.BillingStreet = 'Charles Street';
        accountObj.BillingCity = 'Ohio!#%$';
        accountObj.BillingState = 'NH';
        accountObj.BillingPostalCode = '123456';
        accountObj.AnnualRevenue = 1200;
        accountObj.Phone = '1234567890';
        accountObj.Fax = '123456';
        accountObj.Sic = '12345';
        accountObj.Business_Tax_ID__c = '12345678';

        Test.setMock(HttpCalloutMock.class, new MockExperianCallOut());
        ExperianCallOut.requestExperianBusinessSearch(accountObj,'Experian_Biz_Search_API_Sandbox');

        System.assert(accountObj != Null);
    }

    @isTest
    public static void requestExperianBusinessSearchTestMethod(){

        requestExperianBusinessSearchFutureMethod();
    }

    @Future(Callout=true)
    public static void requestExperianConsumerCreditCheckFutureMethod(){

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Account accountObj = new Account();
        accountObj.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountObj.Name = 'Parker Hannifin Corp';
        accountObj.BillingBuildingNumber__c = '17';
        accountObj.BillingStreet = 'Charles Street';
        accountObj.BillingCity = 'Ohio!#%$';
        accountObj.BillingState = 'NH';
        accountObj.BillingPostalCode = '123456';
        accountObj.AnnualRevenue = 1200;
        accountObj.Phone = '1234567890';
        accountObj.Fax = '123456';
        accountObj.Sic = '12345';
        accountObj.Business_Tax_ID__c = '12345678';

        Contact con = (Contact) JSON.deserialize(
            '{"Name" : "JOHN BOSS"}' , Contact.class
        );
        con.Id = TestUtility.getFakeId(Contact.getSObjectType());
        con.Accountid = accountObj.Id;
        con.Account = accountObj;
        con.MailingBuildingNumber__c = '17';
        con.FirstName = 'John';
        con.LastName = 'Boss';
        con.Birthdate = GeneralHelper.currentSystemDate;
        con.genesis__SSN__c = 'St. Peter!#%$';
        con.ints__Driver_License__c = '123456';
        con.Email = 'Tets@yopmail.com';

        Test.setMock(HttpCalloutMock.class, new MockExperianCallOut());
        ExperianCallOut.requestExperianConsumerCreditCheck(con,'Experian_Biz_Search_API_Sandbox');

        System.assert(con != Null);
    }
    @isTest
    public static void requestExperianConsumerCreditCheckTestMethod(){

        requestExperianConsumerCreditCheckFutureMethod();
    }
    @Future(Callout=true)
    public static void requestExperianBusinessPremierProfileCreditCheckFutureMethod(){

        Account accountObj = new Account();
        accountObj.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountObj.Name = 'Parker Hannifin Corp';
        accountObj.BillingBuildingNumber__c = '17';
        accountObj.BillingStreet = 'Charles Street';
        accountObj.BillingCity = 'Ohio!#%$';
        accountObj.BillingState = 'NH';
        accountObj.BillingPostalCode = '123456';
        accountObj.AnnualRevenue = 1200;
        accountObj.Phone = '1234567890';
        accountObj.Fax = '123456';
        accountObj.Sic = '12345';
        accountObj.Business_Tax_ID__c = '12345678';

        Map<String, Object> accountCreditPremierProfile = new Map<String, Object>();
        accountCreditPremierProfile.put('bin','bin');

        Test.setMock(HttpCalloutMock.class, new MockExperianCallOut());
        ExperianCallOut.requestExperianBusinessPremierProfileCreditCheck(accountObj,accountCreditPremierProfile,'Experian_Biz_Search_API_Sandbox');

        System.assert(accountObj != Null);
    }

    @isTest
    public static void requestExperianBusinessPremierProfileCreditCheckTestMethod(){
        requestExperianBusinessPremierProfileCreditCheckFutureMethod();
    }
    @Future(Callout=true)
    public static void requestExperianBusinessPremierProfilePdfCreditCheckFutureMethod(){

        Account accountObj = new Account();
        accountObj.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountObj.Name = 'Parker Hannifin Corp';
        accountObj.BillingBuildingNumber__c = '17';
        accountObj.BillingStreet = 'Charles Street';
        accountObj.BillingCity = 'Ohio!#%$';
        accountObj.BillingState = 'NH';
        accountObj.BillingPostalCode = '123456';
        accountObj.AnnualRevenue = 1200;
        accountObj.Phone = '1234567890';
        accountObj.Fax = '123456';
        accountObj.Sic = '12345';
        accountObj.Business_Tax_ID__c = '12345678';

        Map<String, Object> accountCreditPremierProfile = new Map<String, Object>();
        accountCreditPremierProfile.put('bin','bin');

        Test.setMock(HttpCalloutMock.class, new MockExperianCallOut());
        ExperianCallOut.requestExperianBusinessPremierProfilePdfCreditCheck(accountObj,accountCreditPremierProfile,'Experian_Biz_Search_API_Sandbox');

        System.assert(accountObj != Null);
    }
    @isTest
    public static void requestExperianBusinessPremierProfilePdfCreditCheckTestMethod(){
			requestExperianBusinessPremierProfilePdfCreditCheckFutureMethod();
    }
    @Future(Callout=true)
    public static void requestExperianBusinessAggregatesFutureMethod(){

        Account accountObj = new Account();
        accountObj.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountObj.Name = 'Parker Hannifin Corp';
        accountObj.BillingBuildingNumber__c = '17';
        accountObj.BillingStreet = 'Charles Street';
        accountObj.BillingCity = 'Ohio!#%$';
        accountObj.BillingState = 'NH';
        accountObj.BillingPostalCode = '123456';
        accountObj.AnnualRevenue = 1200;
        accountObj.Phone = '1234567890';
        accountObj.Fax = '123456';
        accountObj.Sic = '12345';
        accountObj.Business_Tax_ID__c = '12345678';

        Map<String, Object> accountCreditPremierProfile = new Map<String, Object>();
        accountCreditPremierProfile.put('bin','bin');

        Test.setMock(HttpCalloutMock.class, new MockExperianCallOut());
        ExperianCallOut.requestExperianBusinessAggregates(accountObj,accountCreditPremierProfile,'Experian_Biz_Search_API_Sandbox');

        System.assert(accountObj != Null);
    }
    @isTest
    public static void requestExperianBusinessAggregatesTestMethod(){
        	requestExperianBusinessAggregatesFutureMethod();
    }
}