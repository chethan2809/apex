@isTest
private class FinCenControllerTests {
    @isTest
    private static void getFinCenReportRecord() {
        Folder folderDetail = new Folder();
        folderDetail.Name = GeneralConstants.FOLDER_FINCEN_REPORT;
        folderDetail.Id = TestUtility.getFakeId(Folder.getSObjectType());

        Document documentFinCenReport = new Document();
        documentFinCenReport.Id = TestUtility.getFakeId(Document.getSObjectType());
        documentFinCenReport.Name = 'FINCEN_REPORT_12';
        documentFinCenReport.DeveloperName = 'FINCEN_REPORT_12';

        DBManagerTestsStub documentDBStubInstance = new DBManagerTestsStub();
        documentDBStubInstance.genericReturnObject = new List<Document> {documentFinCenReport};
        FinCenController.documentDBInstance = (DocumentDB) Test.createStub(DocumentDB.class, documentDBStubInstance);
        List<Document> documentList;

        Test.startTest();
            documentList = FinCenController.getFinCenReportRecord();
        Test.stopTest();

        System.assertEquals('FINCEN_REPORT_12', documentList.get(0).Name);
    }

    @isTest
    private static void readTextDocumentContent() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        GeneralHelper.currentSystemDateTime = DateTime.newInstance(GeneralHelper.currentSystemDate, DateTime.Now().Time());
        String encodedContentOfDocument = 'dHJhY2tpbmdfbnVtYmVyCWxhc3RfbmFtZQlmaXJzdF9uYW1lCW1pZGRsZV9uYW1lCXN1ZmZpeAlhbGlhc19sYXN0X25hbWUJYWxpYXNfZmlyc3RfbmFtZQlhbGlhc19taWRkbGVfbmFtZQlhbGlhc19zdWZmaXgJbnVtYmVyCW51bWJlcl90eXBlCWRvYglzdHJlZXQJY2l0eQlzdGF0ZQl6aXAJY291bnRyeQlwaG9uZQozMDUwNTIJVHJvaWFubwlBbmR5CQkJCQkJTkEJMTExMTExMTExCVBhc3Nwb3J0CTEwLzI5LzE5ODYJMzQwIFdlc3RvdmVyIERyaXZlCVdvb2RzdG9jawlHQQkzMDE4OAlVUwlOQQozMDUwNTIJVHJvaWFubwlBbmR5CQkJCQkJTkEJMTExMTExMTExCVBhc3Nwb3J0CTEwLzI5LzE5ODYJMzQwIFdlc3RvdmVyIERyaXZlCVdvb2RzdG9jawlHQQkzMDE4OAlVUwlOQQozMDUwNTIJSGFsZXkJQW5uYQkJCQkJCU5BCTEyMzEyMTIzNAkJMTAvMjkvMTk4NgkzNDIgV2VzdG92ZXIgRHJpdmUJV29vZHN0b2NrCUdBCTMwMTg4CUZSCU5BCjMwNTA1MglTbWl0aAlGYXllCQkJCQkJTkEJMzIxMzIzMjE0CVBhc3Nwb3J0CTEwLzI5LzE5ODYJMzIwIFdlc3RvdmVyIERyCVdvb2RzdG9jawlHQQkzMDE4OAlGUglOQQozMDUwNjEJRG9lCU5hdGhhbgkJCUhlcm5hbmRlegladW55CQlOQQk2NjYxODM5MDMJU1NOL0lUSU4JMDEvMDEvMTk2Mgk4NjUyIE1BSU4gU1QJSG9sdG9uCU1JCTQ5NDI1OTYxNglVUwlOQQozMDUwNjEJRG9lCU5hdGhhbgkJCVRhcnJyaW8JWnVuaWxkYQkJTkEJNjY2MTgzOTAzCVNTTi9JVElOCTAxLzAxLzE5NjIJODY1MiBNQUlOIFNUCUhvbHRvbglNSQk0OTQyNTk2MTYJVVMJTkEKMzA1MDYxCVdyaWdodAlKaW1teQlKaW0JCQkJCU5BCTY2NjQwNTQ1MAlTU04vSVRJTgkwNS8yOC8xOTU0CTc4NjY5IEZORUpIUiBURVIJQVNIQlVSTglWQQkyMDE0NwlVUwlOQQozMDUwNjEJQW1hcm8JSmFtZXMJCQkJCQlOQQk2NjY0Mjk3ODkJU1NOL0lUSU4JMDkvMjMvMTk3MQk3NjcgRSAzN1RICVdpY2hpdGEJS1MJNjcyMjYJVVMJTkEKMzA1MDYxCUhvZGdlcwlWaW5uaWUJCQlUYXJyaW8JRW5yaXF1ZQkJTkEJNjY2NzkzNDkyCVNTTi9JVElOCTA2LzExLzE5NTAJMzAyNyBNQUxBQglMb3MgQW5nZWxlcwlDQQk5MDA2MwlVUwlOQQozMDUwNjEJSG9kZ2VzCVZpbm5pZQkJCVRhcnJpbwlFbnJpcXVlCQlOQQk2NjY3OTM0OTIJU1NOL0lUSU4JMDYvMTEvMTk1MAkzMDI3IE1BTEFCCUxvcyBBbmdlbGVzCUNBCTkwMDYzCVVTCU5BCgp0cmFja2luZ19udW1iZXIJYnVzaW5lc3NfbmFtZQlkYmFfbmFtZQludW1iZXIJbnVtYmVyX3R5cGUJaW5jb3Jwb3JhdGVkCXN0cmVldAljaXR5CXN0YXRlCXppcAljb3VudHJ5CXBob25lCjMwNTA2MQlTVVJHRVJZIENFTlRFUgkJNzgzOTYwNTc5CUVJTglOQQk2NjMgQlJZQU5UIEJMVkQJUm9jayBIaWxsCU5DCTI5NzMyCVVTCU5BCjMwNTA2MQlTVVJHRVJZIENFTlRFUgkJNzgzOTYwNTc5CUVJTglOQQk2NjMgQlJZQU5UIEJMVkQJUm9jayBIaWxsCU5DCTI5NzMyCVVTCU5BCjMwNTA2MQlRVVJFCUZvb3RiYWxsQUkJNzMwNDAwNzI4CUVJTglOQQkxNTU1IFJPQ0tEQUxFIElORFVTVFIJQ29ueWVycwlHQQkzMDAxMglVUwlOQQozMDUwNjEJQ0FOIENhcGl0YWwJQ2FwaXRhbCBBY2Nlc3MgTmV0d29ya3MJCQlOQQkxNCBPSEVOUlkgQVZFCUFzaGV2aWxsZQlOQwkyODgwMQlVUwlOQQozMDUwNjEJQ0FOIENhcGl0YWwJQ2FwaXRhbCBBY2Nlc3MgTmV0d29ya3MJCQlOQQkxNCBPSEVOUlkgQVZFCUFzaGV2aWxsZQlOQwkyODgwMQlVUwlOQQozMDUwNjEJQ0FOIENhcGl0YWwJQ2FwaXRhbCBBY2Nlc3MgTmV0d29ya3MJCQlOQQkxNCBPSEVOUlkgQVZFCUFzaGV2aWxsZQlOQwkyODgwMQlVUwlOQQozMDUwNjEJR2liYnMJTWF0dCBHaWJicwkJCU5BCTIwMTUgVmF1Z2huIFJvYWQJS2VubmVzYXcJR0EJMzAxNDQJVVMJTkEKMzA1MDYxCUJ1c2luZXNzIExvYW5zIFIgVXMJCQkJTkEJMzQyIFdlc3RvdmVyIERyaXZlCU5BCUdBCTMwMTg4CVVTCU5BCg==';

        Map<Object, Object> documentDetailsMap = new Map<Object, Object>();
        List<Object> documentList = new List<Object> ();
        documentDetailsMap.put('base64', encodedContentOfDocument);
        documentList.add(documentDetailsMap);

        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.FinCen_Contact_Match_Batch_Size__c = 100;
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;

        CAN_General_Settings__c canGeneralSetting = new CAN_General_Settings__c();
        canGeneralSetting.Active_Days_For_FinCen_Record__c = 30;
        canGeneralSetting.Id = TestUtility.getFakeId(CAN_General_Settings__c.getSObjectType());
        canGeneralSetting.FinCen_Threshold_Value__c = 85;
        canGeneralSetting.FinCen_Eligible_Last_Funded_Date__c = GeneralHelper.currentSystemDate.addDays(-60);
        canGeneralSetting.FinCen_Days_Since_Last_Funded_Date__c = 100;
        CustomSettingsHelper.generalSettings = canGeneralSetting;


        DBManagerTestsStub documentDBStubInstance = new DBManagerTestsStub();
        FinCenRecordMatchManager.documentDBInstance = (DocumentDB) Test.createStub(DocumentDB.class, documentDBStubInstance);

        Test.startTest();
            FinCenController.readTextDocumentContent(documentList);
        Test.stopTest();

        System.assertEquals(1, documentList.size());
    }

    @isTest
    private static void readTextDocumentContentException() {
        String encodedContentOfDocument = 'dHJhY2tpbmdfbnVtYmVyCWxhc3RfbmFtZQlmaXJzdF9uYW1lCW1pZGRsZV9uYW1lCXN1ZmZpeAlhbGlhc19sYXN0X';

        Map<Object, Object> documentDetailsMap = new Map<Object, Object>();
        List<Object> documentList = new List<Object> ();
        documentDetailsMap.put('base64', encodedContentOfDocument);
        documentList.add(documentDetailsMap);

        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.FinCen_Contact_Match_Batch_Size__c = 100;
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;
        Exception ex;

        Test.startTest();
            try {
                FinCenController.readTextDocumentContent(documentList);
            } catch (Exception e) {
                ex = e;
            }
        Test.stopTest();

        System.assertEquals('Script-thrown exception', ex.getMessage());
    }
}