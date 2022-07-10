@isTest
private class TestCCBPDashBoardAPI {

    @testSetup static void dataSetup() {
        Account acc=TestUtility.createAccount();
        contact con=TestUtility.createContact();
        TestUtility.runSetupData();
        genesis__Applications__c genApp=TestUtility.createApplication();
        genApp.Type__c =PortalConstants.LOAN_TYPE_NEW;
        update genApp;
        clcommon__Party_Type__c partyType =new clcommon__Party_Type__c(Name = GeneralConstants.PARTY_TYPE_BROKER);
        insert partyType;
        clcommon__Party__c genParty= new clcommon__Party__c(genesis__Application__c=genApp.Id,clcommon__Type__c=partyType.Id,clcommon__Account__c=acc.id,clcommon__Contact__c=con.id); 
        insert genParty;
    }

    @isTest
    private static void CCBPDashBoardAPI(){
        Map<String,Object> temvar= new Map<String,Object>{
        PortalConstants.RADIO_FILTER=> PortalConstants.RECENT
        };

        Test.startTest();
            clcommon.Response response = new CCBPDashBoardAPI().invokeAction('', null, new Map<String, Object>{
                PortalConstants.SELECTED_STATUS  =>  JSON.serialize(temvar)
            });
        Test.stopTest();

        System.assert(response != null);
    }

    @isTest
    private static void CCBPDashBoardAPINotAll(){
        Map<String,Object> temvar = new Map<String,Object>{
        PortalConstants.RADIO_FILTER=> 'All'
        };

        Test.startTest();
            clcommon.Response response = new CCBPDashBoardAPI().invokeAction('', null, new Map<String, Object>{
                PortalConstants.SELECTED_STATUS  =>  JSON.serialize(temvar)
            });
        Test.stopTest();

        System.assert(response != null);
    }

    @isTest
    private static void CCBPDashBoardAPIAll(){
        Map<String,Object> temvar= new Map<String,Object>{
        PortalConstants.RADIO_FILTER=> 'NotAll'
        };

        Test.startTest();
            clcommon.Response response = new CCBPDashBoardAPI().invokeAction('', null, new Map<String, Object>{
                PortalConstants.SELECTED_STATUS  =>  JSON.serialize(temvar)
            });
        Test.stopTest();

        System.assert(response != null);
    }

    @isTest
    private static void CCBPDashBoardAPIFunded(){
        Map<String,Object> temvar= new Map<String,Object>{
        PortalConstants.RADIO_FILTER=> 'Funded'
        };

        Test.startTest();
            clcommon.Response response = new CCBPDashBoardAPI().invokeAction('', null, new Map<String, Object>{
                PortalConstants.SELECTED_STATUS  =>  JSON.serialize(temvar)
            });
        Test.stopTest();

        System.assert(response != null);
    }

    @isTest
    private static void CCBPDashBoardAPIClosedDeclined(){
        Map<String,Object> temvar= new Map<String,Object>{
        PortalConstants.RADIO_FILTER=> 'Closed Declined'
        };

        Test.startTest();
            clcommon.Response response = new CCBPDashBoardAPI().invokeAction('', null, new Map<String, Object>{
                PortalConstants.SELECTED_STATUS  =>  JSON.serialize(temvar)
            });
        Test.stopTest();

        System.assert(response != null);
    }

    @isTest
    private static void CCBPDashBoardAPISearchBrokerPortalStatus(){
        genesis__Applications__c app=[Select Id from genesis__Applications__c Limit 1];
        Account acc =[select Id from account limit 1];
        Map<String,Object> temvar= new Map<String,Object>{
        PortalConstants.BROKER_PORTAL_STATUS=> 'NotAll',
        PortalConstants.APPLICATION => app.Id,
        PortalConstants.ACCOUNT => acc.Id,
        PortalConstants.START_DATE_FILTER => '2000-03-11',
        PortalConstants.END_DATE_FILTER => '2000-04-11',
        PortalConstants.MINIMUM_AMOUNT => '1000',
        PortalConstants.MAXIMUM_AMOUNT => '2000'

        };

        Test.startTest();
            clcommon.Response response = new CCBPDashBoardAPI().invokeAction('', null, new Map<String, Object>{
                PortalConstants.SEARCH_DETAILS  =>  JSON.serialize(temvar)
            });
        Test.stopTest();

        System.assert(response != null);
    }

    @isTest
    private static void CCBPDashBoardAPIException(){
        Map<String,Object> temvar= new Map<String,Object>{
        PortalConstants.RADIO_FILTER=> 'NotAll'
        };

        Test.startTest();
            clcommon.Response response = new CCBPDashBoardAPI().invokeAction('', null, new Map<String, Object>{
                PortalConstants.SELECTED_STATUS  =>  temvar
            });
        Test.stopTest();

        System.assert(response != null);
    }

    @isTest
    private static void CCBPDashBoardAPISearchBrokerPortalStatusonly(){
        genesis__Applications__c app=[Select Id from genesis__Applications__c Limit 1];
        Account acc =[select Id from account limit 1];
        Map<String,Object> temvar= new Map<String,Object>{
        PortalConstants.BROKER_PORTAL_STATUS=> 'NotAll'
        };

        Test.startTest();
            clcommon.Response response = new CCBPDashBoardAPI().invokeAction('', null, new Map<String, Object>{
                PortalConstants.SEARCH_DETAILS  =>  JSON.serialize(temvar)
            });
        Test.stopTest();

        System.assert(response != null);
    }
}