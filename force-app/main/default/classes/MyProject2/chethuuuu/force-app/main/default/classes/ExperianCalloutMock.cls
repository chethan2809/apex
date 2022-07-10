@isTest
public class ExperianCalloutMock {
    public class ExperianBusinessSuccessResponse implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setStatus('SUCCESS');

            if(request.getEndpoint().endsWith('oauth2/v1/token')) {
                experianBusinessTokenSuccessResponse(response);
            } else if(request.getEndpoint().endsWith('/search')) {
                experianBusinessSearchSuccessResponse(response);
            } else if(request.getEndpoint().endsWith('/reports/premierprofiles')) {
                experianPremierProfileSuccessResponse(response);
            } else if(request.getEndpoint().endsWith('/reports/premierprofiles/pdf')) {
                experianPremierProfilePDFSuccessResponse(response);
            } else if(request.getEndpoint().endsWith('/aggregates')) {
                experianCreditAggregateSuccessResponse(response);
            }
            return response;
        }

        public HttpResponse experianBusinessTokenSuccessResponse(HttpResponse response){

            Map<String, Object> responseBody = new Map<String, Object>();
            responseBody.put('issued_at', '1627296131626');
            responseBody.put('expires_in', '1800');
            responseBody.put('token_type', 'Bearer');
            responseBody.put('access_token', 'eyJraWQiOiJFSmpTMXJQQjdJODBHWjgybmNsSlZPQkF3V3B3ZTVYblNKZUdSZHdpcEY1IiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiJjYW51YXRhcGkiLCJFbWFpbCI6InNhbmRib3hfZXhwX2J1c2luZXNzX2FwaUBjYW5jYXBpdGFsLmNvbSIsIkZpcnN0TmFtZSI6InVhdCIsImlzcyI6IkVYUEVSSUFOIiwiTGFzdE5hbWUiOiJzYW5kYm94IiwiZXhwIjoxNjI3Mjk3OTMyLCJpYXQiOjE2MjcyOTYxMzIsImp0aSI6IjEwYTBhOTFkLWExNTAtNGZiYy1iYjkyLWY1NGVhZjVhMzc2ZSJ9.LxJySXDZdDXkvujufmoo3cL9aX66h699POD5xikITm6KJPTER-JSbAp5CUYNG2oiYBotZcborALrBkkkM3NR3oWuVXzFkpe_o-LsSzl9t8B1npRV8el4EK4Wu9jM7QinzVk41cLnmcDnXCbPne9licoNGt6SRdGDwXLrNLhdiBEsTDX2CNEZbQiQ_TKGG1HMLs8JPUdO9BZTP77FfTLjcc5AQqpOiif065bsTrcfhEs9GPbhY08j05XjFiJFxqC9C1acz-GAD--PwuphyQhZZCPAJIk4yfPcxjY5y0HHRuXLEzPLoIiNjgAww6viOH2cLjw2P1a3P42J7j4E6aifBA');
            responseBody.put('refresh_token', '2T4MPcLShAqbM0ACBHAGBbslwmdAQUih');

            response.setBody(JSON.serialize(responseBody));

            return response;
        }

        public HttpResponse experianBusinessSearchSuccessResponse(HttpResponse response) {

            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setStatus('SUCCESS');

            Map<String, Object> responseBody = new Map<String, Object>();
            Map<String, Object> resultMap = new Map<String, Object>();
            Map<String, Object> addressMap = new Map<String, Object>();
            addressMap.put('street', '2050 N SMOKEY LN');
            addressMap.put('city', 'NOGALES');
            addressMap.put('state', 'AZ');
            addressMap.put('zip', '85621');
            addressMap.put('zipExtension', '2121');

            resultMap.put('bin', '808438010');
            resultMap.put('reliabilityCode', 100);
            resultMap.put('businessName', 'DELTA FRESH, L.L.C');
            resultMap.put('phone', '15202811996');
            resultMap.put('address', addressMap);
            resultMap.put('numberOfTradelines', 6);
            resultMap.put('financialStatementIndicator', false);
            resultMap.put('keyFactsIndicator', true);
            resultMap.put('inquiryIndicator', true);
            resultMap.put('bankDataIndicator', false);
            resultMap.put('governmentDataIndicator', false);
            resultMap.put('executiveSummaryIndicator', true);
            resultMap.put('uccIndicator', true);
            resultMap.put('matchingNameAndAddress', null);
            List<Object> resultList = new List<Object>();
            resultList.add((Object) resultMap);

            responseBody.put('requestId', 'rrt-05859d1a12b5ade31-b-ea-17960-39809846-1');
            responseBody.put('comments', 'uat');
            responseBody.put('success', true);
            responseBody.put('results', resultList);

            response.setBody(JSON.serialize(responseBody));
            return response;
        }

        public HttpResponse experianPremierProfileSuccessResponse(HttpResponse response) {

            Map<String, Object> responseBody = new Map<String, Object>();
            Map<String, Object> resultMap = new Map<String, Object>();
            Map<String, Object> addressMap = new Map<String, Object>();
            Map<String, Object> businessFactsMap = new Map<String, Object>();
            Map<String, Object> businessHeaderMap = new Map<String, Object>();

            Map<String, Object> bankruptcyDetailMap = new Map<String, Object>();
            Map<String, Object> taxLienMap = new Map<String, Object>();
            Map<String, Object> judgementLienMap = new Map<String, Object>();
            List<Object> taxLienList = new List<Object>();
            List<Object> bankruptcyDetailList = new List<Object>();
            List<Object> judgementDetailsList = new List<Object>();
            bankruptcyDetailMap.put('dateFiled', '2020-12-23');
            bankruptcyDetailMap.put('legalType', 'BANKRUPTCY');
            bankruptcyDetailMap.put('legalAction', 'CHAPTER 11 DISCHARGED');
            bankruptcyDetailMap.put('documentNumber', '1511940');
            bankruptcyDetailMap.put('filingLocation', 'DELAWARE FEDERAL BANK COURT-WILMINGTON');
            bankruptcyDetailMap.put('assetAmount', null);
            bankruptcyDetailMap.put('customerDisputeIndicator', false);
            bankruptcyDetailMap.put('exemptAmount', null);
            bankruptcyDetailMap.put('liabilityAmount', null);
            bankruptcyDetailMap.put('owner', null);
            bankruptcyDetailList.add(bankruptcyDetailMap);

            taxLienMap.put('documentNumber', '201400144415');
            taxLienMap.put('filingLocation', 'DELAWARE FEDERAL BANK COURT-WILMINGTON');
            taxLienMap.put('legalAction', 'LIEN');
            taxLienMap.put('liabilityAmount', 34534);
            taxLienMap.put('dateFiled', '2017-05-05');
            taxLienMap.put('legalType', 'UNIFORM COMMERCIAL CODE (UCC) FINANCE STATEMENT');
            taxLienList.add(taxLienMap);
            judgementLienMap.put('documentNumber', '201400144415');
            judgementLienMap.put('filingLocation', 'DELAWARE FEDERAL BANK COURT-WILMINGTON');
            judgementLienMap.put('legalAction', 'FILED');
            judgementLienMap.put('liabilityAmount', 34534);
            judgementLienMap.put('dateFiled', '2017-05-05');
            judgementLienMap.put('legalType', 'UNIFORM COMMERCIAL CODE (UCC) FINANCE STATEMENT');
            judgementDetailsList.add(judgementLienMap);

            resultMap.put('bankruptcyDetail', bankruptcyDetailList);
            resultMap.put('taxLienDetail', taxLienList);
            resultMap.put('judgmentDetail', judgementDetailsList);

            businessFactsMap.put('fileEstablishedDate', TestUtility.currentSystemDate);
            businessHeaderMap.put('taxId', '02811996');
            businessHeaderMap.put('legalBusinessName', 'DELTA FRESH, L.L.C.');

            addressMap.put('street', '2050 N SMOKEY LN');
            addressMap.put('city', 'NOGALES');
            addressMap.put('state', 'AZ');
            addressMap.put('zip', '85621');
            addressMap.put('zipExtension', '2121');
            businessHeaderMap.put('address', addressMap);

            Map<String, Object> expandedCreditSummaryMap = new Map<String, Object>();
            expandedCreditSummaryMap.put('allTradelineCount', 6);
            resultMap.put('businessFacts', businessFactsMap);
            resultMap.put('businessHeader', businessHeaderMap);
            resultMap.put('expandedCreditSummary', expandedCreditSummaryMap);

            responseBody.put('requestId', 'rrt-0795fac7f6e1074e7-c-ea-17904-40803886-1');
            responseBody.put('success', true);
            responseBody.put('comments', 'uat');
            responseBody.put('results', resultMap);

            response.setBody(JSON.serialize(responseBody));

            return response;
        }

        public HttpResponse experianCreditAggregateSuccessResponse(HttpResponse response) {

            Map<String, Object> responseBody = new Map<String, Object>();
            Map<String, Object> resultMap = new Map<String, Object>();
            resultMap.put('TTO077', '152');
            resultMap.put('TTC058', '0');
            resultMap.put('CLO015', '0');
            resultMap.put('DMO013', '6531');

            responseBody.put('requestId', 'rrt-08b9add057229b787-d-ea-17997-44054738-1');
            responseBody.put('success', true);
            responseBody.put('bin', '808438010');
            responseBody.put('results', resultMap);
            responseBody.put('comments', 'uat');

            response.setBody(JSON.serialize(responseBody));

            return response;
        }

        public HttpResponse experianPremierProfilePDFSuccessResponse(HttpResponse response) {

            Map<String, Object> responseBody = new Map<String, Object>();
            Map<String, Object> resultMap = new Map<String, Object>();
            responseBody.put('requestId', 'rrt-05859d1a12b5ade31-b-ea-17960-40024506-1');
            responseBody.put('success', true);
            responseBody.put('comments','uat');
            responseBody.put('results', 'JVBERi0xLjQKMSAwIG9iago8PAovVGl0bGUgKP7');

            response.setBody(JSON.serialize(responseBody));

            return response;
        }
    }

    public class ExperianConsumerSuccessResponse implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setStatus('SUCCESS');

            if(request.getEndpoint().endsWith('oauth2/v1/token')) {
                experianConsumerTokenSuccessResponse(response);
            } else if(request.getEndpoint().endsWith('/credit-profile/v1/decision-services')) {
                experianConsumerAPISuccessResponse(response);
            }
            return response;
        }

        public HttpResponse experianConsumerTokenSuccessResponse(HttpResponse response) {

            Map<String, Object> responseBody = new Map<String, Object>();
            responseBody.put('issued_at', '1627296131626');
            responseBody.put('expires_in', '1800');
            responseBody.put('token_type', 'Bearer');
            responseBody.put('access_token', 'eyJraWQiOiJFSmpTMXJQQjdJODBHWjgybmNsSlZPQkF3V3B3ZTVYblNKZUdSZHdpcEY1IiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiJjYW51YXRhcGkiLCJFbWFpbCI6InNhbmRib3hfZXhwX2J1c2luZXNzX2FwaUBjYW5jYXBpdGFsLmNvbSIsIkZpcnN0TmFtZSI6InVhdCIsImlzcyI6IkVYUEVSSUFOIiwiTGFzdE5hbWUiOiJzYW5kYm94IiwiZXhwIjoxNjI3Mjk3OTMyLCJpYXQiOjE2MjcyOTYxMzIsImp0aSI6IjEwYTBhOTFkLWExNTAtNGZiYy1iYjkyLWY1NGVhZjVhMzc2ZSJ9.LxJySXDZdDXkvujufmoo3cL9aX66h699POD5xikITm6KJPTER-JSbAp5CUYNG2oiYBotZcborALrBkkkM3NR3oWuVXzFkpe_o-LsSzl9t8B1npRV8el4EK4Wu9jM7QinzVk41cLnmcDnXCbPne9licoNGt6SRdGDwXLrNLhdiBEsTDX2CNEZbQiQ_TKGG1HMLs8JPUdO9BZTP77FfTLjcc5AQqpOiif065bsTrcfhEs9GPbhY08j05XjFiJFxqC9C1acz-GAD--PwuphyQhZZCPAJIk4yfPcxjY5y0HHRuXLEzPLoIiNjgAww6viOH2cLjw2P1a3P42J7j4E6aifBA');
            responseBody.put('refresh_token', '2T4MPcLShAqbM0ACBHAGBbslwmdAQUih');

            response.setBody(JSON.serialize(responseBody));

            return response;
        }

        public HttpResponse experianConsumerAPISuccessResponse(HttpResponse response) {

            Map<String, Object> responseBody = new Map<String, Object>();
            Map<String, Object> creditProfileMap = new Map<String, Object>();
            Map<String, Object> premierAttrMap = new Map<String, Object>();
            Map<String, Object> tradeLineMap = new Map<String, Object>();
            Map<String, Object> riskModelMap = new Map<String, Object>();
            Map<String, Object> totalTradeMap = new Map<String, Object>();
            Map<String, Object> pastDueMap = new Map<String, Object>();
            Map<String, Object> summaryMap = new Map<String, Object>();
            Map<String, Object> ttyResponseMap = new Map<String, Object>();
            List<Object> tradeLineList = new List<Object>();
            List<Object> riskModelList = new List<Object>();
            List<Object> attributesList = new List<Object>();
            List<Object> summaryList = new List<Object>();
            List<Object> creditProfileList = new List<Object>();

            Map<String, Object> attr1 = new Map<String, Object> ();
            attr1.put('id', 'ALL7170');
            attr1.put('value', '000000271');
            Map<String, Object> attr2 = new Map<String, Object> ();
            attr2.put('id', 'IQT9426');
            attr2.put('value', '000000271');
            Map<String, Object> attr3 = new Map<String, Object> ();
            attr3.put('id', 'REV3423');
            attr3.put('value', '000000271');
            Map<String, Object> attr4 = new Map<String, Object> ();
            attr4.put('id', 'REV0416');
            attr4.put('value', '000000271');
            Map<String, Object> attr5 = new Map<String, Object> ();
            attr5.put('id', 'MTA2387');
            attr5.put('value',  '000000271');
            Map<String, Object> attr6 = new Map<String, Object> ();
            attr6.put('id', 'MTA0317');
            attr6.put('value',  '000000271');
            Map<String, Object> attr7 = new Map<String, Object> ();
            attr7.put('id', 'IQF9410');
            attr7.put('value',  '000000271');
            Map<String, Object> attr8 = new Map<String, Object> ();
            attr8.put('id', 'ALL8320');
            attr8.put('value',  '000000271');

            List<Object> premierAttrList = new List<Object>();
            premierAttrList.add(attr1);
            premierAttrList.add(attr2);
            premierAttrList.add(attr3);
            premierAttrList.add(attr4);
            premierAttrList.add(attr5);
            premierAttrList.add(attr6);
            premierAttrList.add(attr7);
            premierAttrList.add(attr8);
            creditProfileMap.put('premierAttributes', premierAttrList);

            tradeLineMap.put('accountNumber', '7100140031239443');
            tradeLineMap.put('accountType', '47');
            tradeLineMap.put('amount1', '00095000');
            tradeLineMap.put('amount1Qualifier', 'L');
            tradeLineMap.put('balanceDate', '09282019');
            tradeLineMap.put('delinquencies30Days', '00');
            tradeLineMap.put('delinquencies60Days', '00');
            tradeLineMap.put('delinquencies90to180Days', '00');
            tradeLineMap.put('derogCounter', '00');
            tradeLineMap.put('ecoa', '1');
            tradeLineMap.put('evaluation', 'P');
            tradeLineMap.put('kob', 'BB');
            tradeLineMap.put('monthsHistory', '18');
            tradeLineMap.put('openDate', '12092017');
            tradeLineMap.put('openOrClosed', 'C');
            tradeLineMap.put('paymentHistory', 'B00000000000000000');
            tradeLineMap.put('revolvingOrInstallment', 'R');
            tradeLineMap.put('status', '12');
            tradeLineMap.put('statusDate', '09012019');
            tradeLineMap.put('subscriberCode', '3174842');
            tradeLineMap.put('subscriberName', 'MECHANICS BANK');
            tradeLineMap.put('terms', 'REV');
            tradeLineList.add(tradeLineMap);
            creditProfileMap.put('tradeline', tradeLineList);
            riskModelMap.put('evaluation', 'P');
            riskModelMap.put('modelIndicator', 'FB');
            riskModelMap.put('score', '0845');
            riskModelList.add(riskModelMap);
            creditProfileMap.put('riskModel', riskModelList);

            totalTradeMap.put('id', 'totalTradeItems');
            totalTradeMap.put('value', '006');
            attributesList.add(totalTradeMap);
            pastDueMap.put('id', 'pastDueAmount');
            pastDueMap.put('value', '00000000');
            attributesList.add(pastDueMap);
            summaryMap.put('summaryType', 'Profile Summary');
            summaryMap.put('attributes', attributesList);
            summaryList.add(summaryMap);
            creditProfileMap.put('summaries', summaryList);

            creditProfileList.add(creditProfileMap);

            ttyResponseMap.put('ttyResponse', 'TBD3 APM 1571570    GAMBLE,JAMES 666523727;CA-310 SUMMIT PLACE DR/ATLANTA GA \r\n30350;RM-FB;RM-AF;SHIELD;VERIFY-RM/Y2/DM/RM;V-07;PARSED;SSRV-APIC;\r\nIPADDR-198.143.32.11;SSOUSERID-UATSANDBOx ExP CONSUMER ExPRESS \r\nAPI@CANCAPITAL.COM;Q-APS00002021070808325207CICSISP0APIX0000000;DEFBILL;RM-A2;\r\nRR-BOTH;\r\n \r\n \r\nPAGE 1   DATE  7-08-2021  TIME  3:32:52  V001  TGA1\r\n \r\n JAMES GAMBLE                     SS: 666-52-3727 \r\n 310 SUMMIT PLACE DR              DOB: 08/29/33\r\n ATLANTA GA 303502418\r\n RPTD: 4-15 TO 8-20 U 2X\r\n LAST SUB: 1600838  \r\n \r\n ---------------------------- FRAUD SHIELD SUMMARY ----------------------------\r\n INPUT SSN ISSUED 1960-1976\r\n FROM  4-01-21 INQ COUNT FOR SSN=0\r\n FROM  4-01-21 INQ COUNT FOR ADDRESS=0\r\n \r\n ------------------------------ PROFILE SUMMARY -------------------------------\r\n                                                                CNT 00/00/00/00\r\n PUBLIC RECORDS-------0  PAST DUE AMT--------$0  INQUIRIES---1  SATIS ACCTS---6\r\n INST/OTH BAL-------N/A  SCH/EST PAY--------$30  INQS/6 MO---0  NOW DEL/DRG---0\r\n R ESTATE BAL-------N/A  R ESTATE PAY-------N/A  TRADELINE---6  WAS DEL/DRG---0\r\n TOT REV BAL-------$364  TOT REV AVAIL------97%  PAID ACCT---1  OLD TRADE--7-03\r\n \r\n ------------------------------- SCORE SUMMARY --------------------------------\r\n FICO BANKRUPTCY MODEL                =   845    SCORE FACTORS: 32, 14, 08\r\n FICO CLASSIC RISK 8                  =   808    SCORE FACTORS: 32, 19, 14, 08\r\n PREM 1.2 ATTR                        =          SCORE FACTORS: NONE\r\n \r\n ----------------------------------- TRADES -----------------------------------\r\n SUBSCRIBER                 OPEN    AMT-TYP1    AMT-TYP2 ACCTCOND   PYMT STATUS\r\n SUB#   KOB TYP TRM ECOA BALDATE     BALANCE   PYMT LEVEL MOS REV  PYMT HISTORY\r\n ACCOUNT #               LAST PD   MONTH PAY    PAST DUE  MAXIMUM    BY MONTH\r\n \r\n MECHANICS BANK            12-17   $95,000-L                 PAID     CURR ACCT\r\n 3174842 BB CLS LOC   1  9-28-19                  9-19       (18) B000000000000\r\n 7100140031239443                                                  00000\r\n \r\n JPMCB CARD                12-06   $10,000-L    $2,400-H     OPEN     CURR ACCT\r\n 1233910 BC CRC REV   2  6-12-21      $309        6-21       (99) CCCCCCCCCCCCC\r\n 467363060                  7-19       $10                         CCCCCCCCCCCC\r\n \r\n SYNCB/QVC                  7-19    $2,000-L      $320-H     OPEN     CURR ACCT\r\n 1600619 FF CHG REV   1  6-11-21       $55        6-21       (21) CCCCCCCCCCCCC\r\n C13C6044783                4-21       $20                         CCCCCCCC\r\n \r\n DILLARDS DEPT STORE        7-03    $1,023-H                 OPEN     CURR ACCT\r\n 3378879 DC CHG REV   1  5-28-21        $0        5-21       (99) 00CC00C000-C0\r\n 7164438                    4-21                                   CCCCC0CCC0C-\r\n \r\n +++++ MORE\r\n \r\nTBD3 APM 1571570    GAMBLE,JAMES 666523727;CA-310 SUMMIT PLACE DR/ATLANTA GA \r\n \r\n \r\nPAGE 2   DATE  7-08-2021  TIME  3:32:52  V001  TGA1\r\n \r\n SUBSCRIBER                 OPEN    AMT-TYP1    AMT-TYP2 ACCTCOND   PYMT STATUS\r\n SUB#   KOB TYP TRM ECOA BALDATE     BALANCE   PYMT LEVEL MOS REV  PYMT HISTORY\r\n ACCOUNT #               LAST PD   MONTH PAY    PAST DUE  MAXIMUM    BY MONTH\r\n \r\n FOLEYS                     8-03      $504-H                 OPEN     CURR ACCT\r\n 3346613 DC CHG REV   1  5-07-21        $0        5-21       (99) 00C00CC0C-000\r\n 18630                      3-21                                   --CC0C0C0000\r\n \r\n SYNCB/HOME SHOPPING        4-20    $2,000-L       $90-H     OPEN     CURR ACCT\r\n 1600838 DV CHG REV   1  4-21-21        $0        4-21       (10) 0CCCCCCCCC\r\n CW3J8660023                4-21                      \r\n \r\n --------------------------------- INQUIRIES ----------------------------------\r\n AT&T MOBILITY           8-27-20  3947689 UW                \r\n \r\n END -- EXPERIAN\r\n \r\n');
            responseBody.put('tty', ttyResponseMap);
            responseBody.put('creditProfile', (Object) creditProfileList);

            response.setBody(JSON.serialize(responseBody));

            return response;
        }
    }

    public class ExperianConsumerFrozenResponse implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setStatus('SUCCESS');

            if(request.getEndpoint().endsWith('oauth2/v1/token')) {
                experianConsumerTokenFrozenResponse(response);
            } else if(request.getEndpoint().endsWith('/credit-profile/v1/decision-services')) {
                experianConsumerAPIFrozenResponse(response);
            }
            return response;
        }

        public HttpResponse experianConsumerTokenFrozenResponse(HttpResponse response) {

            Map<String, Object> responseBody = new Map<String, Object>();
            responseBody.put('issued_at', '1627296131626');
            responseBody.put('expires_in', '1800');
            responseBody.put('token_type', 'Bearer');
            responseBody.put('access_token', 'eyJraWQiOiJFSmpTMXJQQjdJODBHWjgybmNsSlZPQkF3V3B3ZTVYblNKZUdSZHdpcEY1IiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiJjYW51YXRhcGkiLCJFbWFpbCI6InNhbmRib3hfZXhwX2J1c2luZXNzX2FwaUBjYW5jYXBpdGFsLmNvbSIsIkZpcnN0TmFtZSI6InVhdCIsImlzcyI6IkVYUEVSSUFOIiwiTGFzdE5hbWUiOiJzYW5kYm94IiwiZXhwIjoxNjI3Mjk3OTMyLCJpYXQiOjE2MjcyOTYxMzIsImp0aSI6IjEwYTBhOTFkLWExNTAtNGZiYy1iYjkyLWY1NGVhZjVhMzc2ZSJ9.LxJySXDZdDXkvujufmoo3cL9aX66h699POD5xikITm6KJPTER-JSbAp5CUYNG2oiYBotZcborALrBkkkM3NR3oWuVXzFkpe_o-LsSzl9t8B1npRV8el4EK4Wu9jM7QinzVk41cLnmcDnXCbPne9licoNGt6SRdGDwXLrNLhdiBEsTDX2CNEZbQiQ_TKGG1HMLs8JPUdO9BZTP77FfTLjcc5AQqpOiif065bsTrcfhEs9GPbhY08j05XjFiJFxqC9C1acz-GAD--PwuphyQhZZCPAJIk4yfPcxjY5y0HHRuXLEzPLoIiNjgAww6viOH2cLjw2P1a3P42J7j4E6aifBA');
            responseBody.put('refresh_token', '2T4MPcLShAqbM0ACBHAGBbslwmdAQUih');

            response.setBody(JSON.serialize(responseBody));

            return response;
        }

        public HttpResponse experianConsumerAPIFrozenResponse(HttpResponse response) {
            Map<String, Object> responseBody = new Map<String, Object>();
            Map<String, Object> creditProfileMap = new Map<String, Object>();
            Map<String, Object> statementMap = new Map<String, Object>();
            Map<String, Object> ttyResponseMap = new Map<String, Object>();
            List<Object> creditProfileList = new List<Object>();
            List<Object> statementList = new List<Object>();

            statementMap.put('statementText', 'FILE FROZEN');
            statementList.add((Object) statementMap);
            creditProfileMap.put('statement', statementList);
            creditProfileList.add(creditProfileMap);

            ttyResponseMap.put('ttyResponse', 'TBD3 APM 1571570    GAMBLE,JAMES 666523727;CA-310 SUMMIT PLACE DR/ATLANTA GA \r\n30350;RM-FB;RM-AF;SHIELD;VERIFY-RM/Y2/DM/RM;V-07;PARSED;SSRV-APIC;\r\nIPADDR-198.143.32.11;SSOUSERID-UATSANDBOx ExP CONSUMER ExPRESS \r\nAPI@CANCAPITAL.COM;Q-APS00002021070808325207CICSISP0APIX0000000;DEFBILL;RM-A2;\r\nRR-BOTH;\r\n \r\n \r\nPAGE 1   DATE  7-08-2021  TIME  3:32:52  V001  TGA1\r\n \r\n JAMES GAMBLE                     SS: 666-52-3727 \r\n 310 SUMMIT PLACE DR              DOB: 08/29/33\r\n ATLANTA GA 303502418\r\n RPTD: 4-15 TO 8-20 U 2X\r\n LAST SUB: 1600838  \r\n \r\n ---------------------------- FRAUD SHIELD SUMMARY ----------------------------\r\n INPUT SSN ISSUED 1960-1976\r\n FROM  4-01-21 INQ COUNT FOR SSN=0\r\n FROM  4-01-21 INQ COUNT FOR ADDRESS=0\r\n \r\n ------------------------------ PROFILE SUMMARY -------------------------------\r\n                                                                CNT 00/00/00/00\r\n PUBLIC RECORDS-------0  PAST DUE AMT--------$0  INQUIRIES---1  SATIS ACCTS---6\r\n INST/OTH BAL-------N/A  SCH/EST PAY--------$30  INQS/6 MO---0  NOW DEL/DRG---0\r\n R ESTATE BAL-------N/A  R ESTATE PAY-------N/A  TRADELINE---6  WAS DEL/DRG---0\r\n TOT REV BAL-------$364  TOT REV AVAIL------97%  PAID ACCT---1  OLD TRADE--7-03\r\n \r\n ------------------------------- SCORE SUMMARY --------------------------------\r\n FICO BANKRUPTCY MODEL                =   845    SCORE FACTORS: 32, 14, 08\r\n FICO CLASSIC RISK 8                  =   808    SCORE FACTORS: 32, 19, 14, 08\r\n PREM 1.2 ATTR                        =          SCORE FACTORS: NONE\r\n \r\n ----------------------------------- TRADES -----------------------------------\r\n SUBSCRIBER                 OPEN    AMT-TYP1    AMT-TYP2 ACCTCOND   PYMT STATUS\r\n SUB#   KOB TYP TRM ECOA BALDATE     BALANCE   PYMT LEVEL MOS REV  PYMT HISTORY\r\n ACCOUNT #               LAST PD   MONTH PAY    PAST DUE  MAXIMUM    BY MONTH\r\n \r\n MECHANICS BANK            12-17   $95,000-L                 PAID     CURR ACCT\r\n 3174842 BB CLS LOC   1  9-28-19                  9-19       (18) B000000000000\r\n 7100140031239443                                                  00000\r\n \r\n JPMCB CARD                12-06   $10,000-L    $2,400-H     OPEN     CURR ACCT\r\n 1233910 BC CRC REV   2  6-12-21      $309        6-21       (99) CCCCCCCCCCCCC\r\n 467363060                  7-19       $10                         CCCCCCCCCCCC\r\n \r\n SYNCB/QVC                  7-19    $2,000-L      $320-H     OPEN     CURR ACCT\r\n 1600619 FF CHG REV   1  6-11-21       $55        6-21       (21) CCCCCCCCCCCCC\r\n C13C6044783                4-21       $20                         CCCCCCCC\r\n \r\n DILLARDS DEPT STORE        7-03    $1,023-H                 OPEN     CURR ACCT\r\n 3378879 DC CHG REV   1  5-28-21        $0        5-21       (99) 00CC00C000-C0\r\n 7164438                    4-21                                   CCCCC0CCC0C-\r\n \r\n +++++ MORE\r\n \r\nTBD3 APM 1571570    GAMBLE,JAMES 666523727;CA-310 SUMMIT PLACE DR/ATLANTA GA \r\n \r\n \r\nPAGE 2   DATE  7-08-2021  TIME  3:32:52  V001  TGA1\r\n \r\n SUBSCRIBER                 OPEN    AMT-TYP1    AMT-TYP2 ACCTCOND   PYMT STATUS\r\n SUB#   KOB TYP TRM ECOA BALDATE     BALANCE   PYMT LEVEL MOS REV  PYMT HISTORY\r\n ACCOUNT #               LAST PD   MONTH PAY    PAST DUE  MAXIMUM    BY MONTH\r\n \r\n FOLEYS                     8-03      $504-H                 OPEN     CURR ACCT\r\n 3346613 DC CHG REV   1  5-07-21        $0        5-21       (99) 00C00CC0C-000\r\n 18630                      3-21                                   --CC0C0C0000\r\n \r\n SYNCB/HOME SHOPPING        4-20    $2,000-L       $90-H     OPEN     CURR ACCT\r\n 1600838 DV CHG REV   1  4-21-21        $0        4-21       (10) 0CCCCCCCCC\r\n CW3J8660023                4-21                      \r\n \r\n --------------------------------- INQUIRIES ----------------------------------\r\n AT&T MOBILITY           8-27-20  3947689 UW                \r\n \r\n END -- EXPERIAN\r\n \r\n');
            responseBody.put('tty', ttyResponseMap);
            responseBody.put('creditProfile', (Object) creditProfileList);

            response.setBody(JSON.serialize(responseBody));

            return response;
        }
    }
}