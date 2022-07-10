@isTest(isParallel=true)
private class ExperianCalloutParserTests {

    @isTest
    private static void experianCalloutParserTestMethod(){

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Account accnt = new Account();
        accnt.Id = TestUtility.getFakeId(Account.getSObjectType());
        accnt.Name = 'Parker Hannifin Corp';
        accnt.BillingBuildingNumber__c = '17';
        accnt.BillingStreet = 'Charles Street';
        accnt.BillingCity = 'Ohio!#%$';
        accnt.BillingState = 'NH';
        accnt.BillingPostalCode = '123456';
        accnt.AnnualRevenue = 1200;
        accnt.Phone = '1234567890';
        accnt.Fax = '123456';
        accnt.Sic = '12345';
        accnt.Business_Tax_ID__c = '12345678';

        Contact con = (Contact) JSON.deserialize(
            '{"Name" : "JOHN BOSS"}' , Contact.class
        );
        con.Id = TestUtility.getFakeId(Contact.getSObjectType());
        con.Accountid = accnt.Id;
        con.Account = accnt;
        con.MailingBuildingNumber__c = '17';
        con.FirstName = 'John';
        con.LastName = 'Boss';
        con.Birthdate = GeneralHelper.currentSystemDate;
        con.genesis__SSN__c = 'St. Peter!#%$';
        con.ints__Driver_License__c = '123456';
        con.Email = 'Tets@yopmail.com';

        list<object> premierAttributes = new list<object>();
        Map<string,object> formulatePremierAttributesObj = new Map<string,object>();
        formulatePremierAttributesObj.put('id','ALL7170');
        formulatePremierAttributesObj.put('id','IQT9426');
        formulatePremierAttributesObj.put('id','REV3423');
        formulatePremierAttributesObj.put('id','REV0416');
        formulatePremierAttributesObj.put('id','MTA2387');
        formulatePremierAttributesObj.put('id','MTA0317');
		formulatePremierAttributesObj.put('id','IQF9410');
        formulatePremierAttributesObj.put('id','ALL8320');
        premierAttributes.add(formulatePremierAttributesObj);

        Map<string,object> processMap4 = new Map<string,object>();
        processMap4.put('value',premierAttributes);

        Map<String, Object> processMap = new Map<String, Object>();

  		List<Object> ssnInfoList = new List<Object>();
        Map<String, Object> processMap1 = new Map<String, Object>();
        processMap1.put('number','SSNNumber');
        ssnInfoList.add(processMap1);

        List<Object> infoMessageList = new List<Object>();
        Map<String, Object> processMap2 = new Map<String, Object>();
        processMap1.put('messageNumber','07');
        infoMessageList.add(processMap2);

        List<Object> personalAddressList = new List<Object>();
        Map<String, Object> processMap3 = new Map<String, Object>();
        processMap3.put('streetPrefix','streetPrefix');
        processMap3.put('streetName','streetName');
        processMap3.put('streetSuffix','streetSuffix');
        processMap3.put('city','city');
        processMap3.put('state','state');
        processMap3.put('zipCode','zipCode');
        personalAddressList.add(processMap3);

        Map<String, Object> ttyResponse = new Map<String, Object>();
        ttyResponse.put('ttyResponse','ttyResponse');

        Map<String, Object> tty = new Map<String, Object>();
        tty.put('tty',ttyResponse);

        List<Object> riskModelList = new List<Object>();

        Map<String, Object> riskModelMap = new Map<String, Object>();
        riskModelMap.put('modelIndicator','AF');
        riskModelMap.put('score','score');

        riskModelList.add(riskModelMap);

        Map<String, Object> personalInformation = new Map<String, Object>();
        List<Object> namelist = new List<Object>();
        Map<String, Object> nameMap = new Map<String, Object>();
        nameMap.put('firstName','firstName');
        nameMap.put('lastName','lastName');
        namelist.add(nameMap);
        personalInformation.put('name',namelist);

        Map<String, Object> dob = new Map<String, Object>();
        Map<String, Object> dobDetails = new Map<String, Object>();
        dobDetails.put('year','year');
        dobDetails.put('month','month');
        dobDetails.put('date','date');
        personalInformation.put('dob',dobDetails);

        List<Object> tradeLineList = new List<Object>();

        Map<String, Object> tradeLineMap = new Map<String, Object>();
        tradeLineMap.put('openOrClosedText','Closed');
        tradeLineList.add(tradeLineMap);

        Map<String, Object> accountCreditPremierProfilePdf = new Map<String, Object>();
        accountCreditPremierProfilePdf.put('bin','binValue');
        accountCreditPremierProfilePdf.put('subcode','subcode');
        accountCreditPremierProfilePdf.put('modelCode','000224');
        accountCreditPremierProfilePdf.put('comments','instanceName');

        Map<String, Object> accountCreditAggregates = new Map<String, Object>();
        accountCreditAggregates.put('bin','binvalue');
        accountCreditAggregates.put('subcode','subcode');
        accountCreditAggregates.put('extraAggs','true');

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        response.setStatus('OK');
        response.setBody( '{"creditProfile": [{"s": "a", "i": 1}]}');

        HttpResponse response1 = new HttpResponse();
        response1.setHeader('Content-Type', 'application/json');
        response1.setStatusCode(200);
        response1.setStatus('OK');
        response1.setBody('{"responseMessage":[{"bin": "a", "reliabilityCode": 1}],"results":[{"bin": "a", "reliabilityCode": 86}]}');

        HttpResponse response2 = new HttpResponse();
        response2.setHeader('Content-Type', 'application/json');
        response2.setStatusCode(200);
        response2.setStatus('OK');
        response2.setBody('{"results":{"businessFacts": {"fileEstablishedDate":"2021-01-01","businessType":"businessType"},"businessHeader":{"legalBusinessName":"legalBusinessName","taxId":"taxId","address":{"street":"street","city":"city","state":"state","zip":"zip","zipExtension":"zipExtension"}},"expandedCreditSummary":{"allTradelineCount":"allTradelineCount"}},"requestId":"requestId"}');
        API_Detail__mdt apiDetails = Experians.experianConsumerAPIDetails;

        Test.startTest();
            ExperianCalloutParser experianCall = new ExperianCalloutParser(con, accnt, apiDetails);
            experianCall.consumerRequestBody();
            experianCall.preparePrimaryApplicant();
            experianCall.prepareApplicantDetails();
            experianCall.getPermissiblePurpose();
            experianCall.prepareName();
            experianCall.prepareSsn();
            experianCall.prepareAddress();
            experianCall.prepareRequestor();
            experianCall.prepareAddOns();
            experianCall.prepareRiskModels();
            experianCall.prepareModelIndicator();
            experianCall.prepareInfoId();
            experianCall.responseParse(response);
            experianCall.businessRequestBody();
            experianCall.businessResponseBody(response1);
            experianCall.businessPremierProfilesResponseBody(response2);
            experianCall.formulatePremierAttributes(premierAttributes,processMap4);
            experianCall.businessPremierProfilesPDFResponseBody(response2);
            experianCall.businessAggregatesResponseBody(response2);
            experianCall.formulateTTY(tty,processMap);
            experianCall.formulateRiskModel(riskModelList,processMap);
            experianCall.formulateTradeLineList(tradeLineList,processMap);
            experianCall.formulateSsnInformation(ssnInfoList,processMap1);
            experianCall.formulateInfoMessage(infoMessageList,processMap2);
            experianCall.formulatePersonalAddress(personalAddressList,processMap3);
            experianCall.formulatePersonalInformation(personalInformation,processMap);
            experianCall.businessPremierProfilesRequestBody(accountCreditPremierProfilePdf);
            experianCall.businessPremierProfilesPDFRequestBody(accountCreditPremierProfilePdf);
            experianCall.businessAggregatesRequestBody(accountCreditAggregates);
        Test.stopTest();

        System.assert(con != Null);
        System.assert(accnt != Null);
    }

    @isTest
    private static void formulateSsnInformationWithEmpty () {
        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());

        Contact contactRecord = (Contact) JSON.deserialize(
            '{"Name" : "JOHN BOSS"}' , Contact.class
        );
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.AccountId = accountRecord.Id;
        contactRecord.Account = accountRecord;

        Map<String, Object> processMap = new Map<String, Object>();

        ExperianCalloutParser experianCall = new ExperianCalloutParser(contactRecord, accountRecord);
        List<Object> ssnInfoList = new List<Object>();

        Test.startTest();
            Map<String, Object> processedMap = experianCall.formulateSsnInformation(ssnInfoList,processMap);
        Test.stopTest();

        System.assertEquals(true, processedMap.isEmpty());
    }

    @isTest
    private static void formulateSsnInformationWithMultipleSsn () {
        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());

        Contact contactRecord = (Contact) JSON.deserialize(
            '{"Name" : "JOHN BOSS"}' , Contact.class
        );
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.AccountId = accountRecord.Id;
        contactRecord.Account = accountRecord;

        Map<String, Object> processMap = new Map<String, Object>();

        ExperianCalloutParser experianCall = new ExperianCalloutParser(contactRecord, accountRecord);

        List<Object> ssnInfoList = new List<Object>();
        Map<String, Object> ssnMap = new Map<String, Object>();
        ssnMap.put('number','648589437');
        ssnInfoList.add(ssnMap);
        ssnMap = new Map<String, Object>();
        ssnMap.put('number','648589537');
        ssnInfoList.add(ssnMap);
        Test.startTest();
            Map<String, Object> processedMap = experianCall.formulateSsnInformation(ssnInfoList,processMap);
        Test.stopTest();

        System.assertEquals('648589437', processedMap.get('ssnNumber'));
    }
}