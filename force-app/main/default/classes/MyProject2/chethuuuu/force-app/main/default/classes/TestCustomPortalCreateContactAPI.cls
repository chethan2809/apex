@IsTest
public class TestCustomPortalCreateContactAPI {

    @isTest
    static void CustomPortalCreateContactAPI()
    {
       String str = '{"middleName":"testm","lastName":"testl","dba":"test","businessStreet":"Test Drive","birthDate":"1998-10-06","socialSecurityNumber":"45456298","industry":"Business Services","loanAmount":1000,"businessCity":"Chattanooga","businessName":"test","mobilePhone":"1234555555","businessPhone":"1234555555","loanPurpose":"Expansion","businessState":"Tennessee","bizTaxId":"123434444","businessCountry":"United States","businessPostalCode":"37421","title":"Partner","firstName":"test","email":"test@gmail.com","legalEntity":"Sole Proprietorship","businessBuildingNumber":"test","bizStartDate":"2017-01-13","industry":"MISCELLANEOUS MANUFACTURING INDUSTRIES"}';

       Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(str);

       test.startTest();
           clcommon.Response response = new CustomPortalCreateContactAPI().invokeAction(null, null, requestMap);
       test.stopTest();
       System.assert(response != null);
    }

    @isTest
    static void CustomPortalCreateContactAPIOtherTitleCheck()
    {
       CAN_Industry_Rating_Profile__c canIndustryRatingProfile = new CAN_Industry_Rating_Profile__c(Description__c = 'BUSINESS SERVICES', Digit_Code__c = '73', Industry_Rating__c = 'B', Excluded_For_Renewal__c = false);
       insert canIndustryRatingProfile;

       String str = '{"middleName":"testm","lastName":"testl","dba":"test","businessStreet":"Test Drive","birthDate":"1998-10-06","socialSecurityNumber":"45456298","industry":"BUSINESS SERVICES","loanAmount":1000,"businessCity":"Chattanooga","businessName":"test","mobilePhone":"1234555555","businessPhone":"1234555555","loanPurpose":"Expansion","businessState":"Tennessee","bizTaxId":"123434444","businessCountry":"United States","businessPostalCode":"37421","title":"Other","firstName":"test","email":"test@gmail.com","legalEntity":"Sole Proprietorship","businessBuildingNumber":"test","bizStartDate":"2017-01-13","industry":"MISCELLANEOUS MANUFACTURING INDUSTRIES"}';

       Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(str);
       clcommon.Response response = new CustomPortalCreateContactAPI().invokeAction(null, null, requestMap);
    }
    
     @isTest
    static void CustomPortalCreateContactAPITitleCheck()
    {
       CAN_Industry_Rating_Profile__c canIndustryRatingProfile = new CAN_Industry_Rating_Profile__c(Description__c = 'BUSINESS SERVICES', Digit_Code__c = '73', Industry_Rating__c = 'B', Excluded_For_Renewal__c = false);
       insert canIndustryRatingProfile;

       String str = '{"middleName":"testm","lastName":"testl","dba":"test","businessStreet":"Test Drive","birthDate":"1998-10-06","socialSecurityNumber":"45456298","industry":"BUSINESS SERVICES","loanAmount":1000,"businessCity":"Chattanooga","businessName":"test","mobilePhone":"1234555555","businessPhone":"1234555555","loanPurpose":"Expansion","businessState":"Tennessee","bizTaxId":"123434444","businessCountry":"United States","businessPostalCode":"37421","title":"CEO","firstName":"test","email":"test@gmail.com","legalEntity":"Sole Proprietorship","businessBuildingNumber":"test","bizStartDate":"2017-01-13","industry":"MISCELLANEOUS MANUFACTURING INDUSTRIES"}';

       Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(str);
       clcommon.Response response = new CustomPortalCreateContactAPI().invokeAction(null, null, requestMap);
    }

    @isTest
    static void CustomPortalCreateContactAPIAgeCheck()
    {
       String str = '{"middleName":"testm","lastName":"testl","dba":"test","businessStreet":"Test Drive","birthDate":"1998-10-06","socialSecurityNumber":"45456298","industry":"BUSINESS SERVICES","loanAmount":1000,"businessCity":"Chattanooga","businessName":"test","mobilePhone":"1234555555","businessPhone":"1234555555","loanPurpose":"Expansion","businessState":"Tennessee","bizTaxId":"123434444","businessCountry":"United States","businessPostalCode":"37421","title":"Partner","firstName":"test","email":"test@gmail.com","legalEntity":"Sole Proprietorship","businessBuildingNumber":"test","bizStartDate":"2020-01-13","industry":"MISCELLANEOUS MANUFACTURING INDUSTRIES"}';

       Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(str);
       clcommon.Response response = new CustomPortalCreateContactAPI().invokeAction(null, null, requestMap);
    }

    @isTest
    static void CustomPortalCreateContactAPIBusinessCountryCheck()
    {
       String str = '{"middleName":"testm","lastName":"testl","dba":"test","businessStreet":"Test Drive","birthDate":"1998-10-06","socialSecurityNumber":"45456298","industry":"BUSINESS SERVICES","loanAmount":1000,"businessCity":"Chattanooga","businessName":"test","mobilePhone":"1234555555","businessPhone":"1234555555","loanPurpose":"Expansion","businessState":"Tennessee","bizTaxId":"123434444","businessCountry":"India","businessPostalCode":"37421","title":"Partner","firstName":"test","email":"test@gmail.com","legalEntity":"Sole Proprietorship","businessBuildingNumber":"test","bizStartDate":"2016-01-13","industry":"MISCELLANEOUS MANUFACTURING INDUSTRIES"}';

       Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(str);
       clcommon.Response response = new CustomPortalCreateContactAPI().invokeAction(null, null, requestMap);
    }

    @isTest
    static void CustomPortalCreateContactAPIIndustryCheck()
    {
       String str = '{"middleName":"testm","lastName":"testl","dba":"test","businessStreet":"Test Drive","birthDate":"1998-10-06","socialSecurityNumber":"45456298","industry":"Prohibited","loanAmount":1000,"businessCity":"Chattanooga","businessName":"test","mobilePhone":"1234555555","businessPhone":"1234555555","loanPurpose":"Expansion","businessState":"Tennessee","bizTaxId":"123434444","businessCountry":"United States","businessPostalCode":"37421","title":"Partner","firstName":"test","email":"test@gmail.com","legalEntity":"Sole Proprietorship","businessBuildingNumber":"test","bizStartDate":"2016-01-13","industry":"MISCELLANEOUS MANUFACTURING INDUSTRIES"}';

       Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(str);
       clcommon.Response response = new CustomPortalCreateContactAPI().invokeAction(null, null, requestMap);
    }
}