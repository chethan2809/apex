@isTest(isParallel=true)
public class DBManagerTestsStub implements System.StubProvider {
    private Map<Id, SObject> forUpdateSObjectsMap = new Map<Id, SObject>();
    private Map<Id, SObject> forDeleteSObjectsMap = new Map<Id, SObject>();

    public Object genericReturnObject = new List<SObject>();
    public List<SObject> forInsertSObjects = new List<SObject>();
    public List<SObject> forUpsertSObjects = new List<SObject>();

    public List<SObject> forUpdateSObjects {
        get {
            return forUpdateSObjectsMap.values();
        }
        set;
    }

    public List<SObject> forDeleteSObjects {
        get {
            return forDeleteSObjectsMap.values();
        }
        set;
    }

    public DBManager.PartialResult partialInsertResult = new DBManager.PartialResult();
    public DBManager.PartialResult partialUpdateResult = new DBManager.PartialResult();
    public DBManager.PartialResult partialUpsertResult = new DBManager.PartialResult();
    public Set<Integer> partialDmlFailureIndexes = new Set<Integer>();
    public String partialDmlErrorStatusCode = 'INSUFFICIENT_ACCESS';
    public String partialDmlErrorMessage = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';

    @TestVisible
    private DBManagerTestsStub() {
    }

    public Object handleMethodCall(
        Object stubbedObject, String stubbedMethodName,  Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames,
        List<Object> listOfArgs
    ) {
        switch on stubbedMethodName {
            when 'addInsert' {
                SObject singleDML = (SObject) listOfArgs[0];
                forInsertSObjects.add(singleDML);
                return stubbedObject;
            }
            when 'addInserts' {
                List<SObject> listOfSObjects = (List<SObject>) listOfArgs[0];
                forInsertSObjects.addAll(listOfSObjects);
                return stubbedObject;
            }
            when 'addUpdate' {
                handleAddsObjectToMap(forUpdateSObjectsMap, (SObject) listOfArgs[0]);
                return stubbedObject;
            }
            when 'addUpdates' {
                handleAddsObjectListToMap(forUpdateSObjectsMap, listOfParamTypes.get(0).getName(), listOfArgs);
                return stubbedObject;
            }
            when 'addUpsert' {
                SObject singleDML = (SObject) listOfArgs[0];
                forUpsertSObjects.add(singleDML);
                return stubbedObject;
            }
            when 'addUpserts' {
                List<SObject> listOfSObjects = (List<SObject>) listOfArgs[0];
                forUpsertSObjects.addAll(listOfSObjects);
                return stubbedObject;
            }
            when 'addDelete' {
                handleAddsObjectToMap(forDeleteSObjectsMap, (SObject) listOfArgs[0]);
                return stubbedObject;
            }
            when 'addDeletes' {
                handleAddsObjectListToMap(forDeleteSObjectsMap, listOfParamTypes.get(0).getName(), listOfArgs);
                return stubbedObject;
            }
            when 'executeInserts' {
                handleExecuteInsert(listOfArgs);
                return stubbedObject;
            }
            when 'executeUpdates' {
                return stubbedObject;
            }when 'executeUpserts' {
                handleExecuteUpsert();
                return stubbedObject;
            }
            when 'executeDeletes' {
                return stubbedObject;
            }
            when 'executePartialUpdates' {
                handleExecutePartialUpdate();
                return partialUpdateResult;
            }
            when 'executePartialUpserts' {
                handleExecutePartialUpsert();
                return partialUpsertResult;
            }
            when 'executePartialInserts' {
                handleExecutePartialInsert();
                return partialInsertResult;
            }
        }

        switch on returnType.getName() {
            when 'Integer' {
                return ((List<SObject>) genericReturnObject).size();
            }
            when else {
                return genericReturnObject;
            }
        }
    }

    private void handleAddsObjectToMap(Map<Id, SObject> sObjectMap, SObject sObj) {
        ensureIdIsNotNull(sObj);
        sObjectMap.put(sObj.Id, sObj);
    }

    private void handleAddsObjectListToMap(Map<Id, SObject> sObjectMap, String paramType, List<Object> objects) {
        for (Object obj : objects) {
            if (paramType == 'Map') {
                sObjectMap.putAll((Map<Id, SObject>) obj);
            } else {
                for (SObject record : (List<SObject>) obj) {
                    ensureIdIsNotNull(record);
                    sObjectMap.put(record.Id, record);
                }
            }
        }
    }

    private void ensureIdIsNotNull(SObject record) {
        if (record.get('Id') == null) {
            throw new DBManagerTestsStubException('Object in return list does not have an Id');
        }
    }

    private void handleExecuteInsert(List<Object> listOfArgs) {
        if(!listOfArgs.isEmpty()) {
            SObject listOfSObjects = (SObject) listOfArgs[0];
            forInsertSObjects.add(listOfSObjects);
        }
        for (SObject sobj : forInsertSObjects) {
            validateSObjectId(sobj);
        }
    }

    private void handleExecutePartialInsert() {
        for (SObject sObj : forInsertSObjects) {
            validateSObjectId(sObj);
            Database.SaveResult result = constructSaveResult(forInsertSObjects, sObj);

            partialInsertResult.sObjectList.add(sObj);
            partialInsertResult.saveResults.add(result);
        }
    }

    private void handleExecutePartialUpdate() {
        for (SObject sObj : forUpdateSObjectsMap.values()) {
            Database.SaveResult result = constructSaveResult(forUpdateSObjectsMap.values(), sObj);

            partialUpdateResult.sObjectList.add(sObj);
            partialUpdateResult.saveResults.add(result);
        }
    }

    private Database.SaveResult constructSaveResult(List<SObject> sObjectList,SObject sObj) {
        if (!partialDmlFailureIndexes.contains(sObjectList.indexOf(sObj))) {
            return (Database.SaveResult) JSON.deserialize(
                '{"success": true , "id" : "' +
                sObj.Id +
                '"}',
                Database.SaveResult.class
            );
        } else {
            return (Database.SaveResult) JSON.deserialize(
                '{"success": false , "errors":[{"statusCode":"' +
                partialDmlErrorStatusCode +
                '",' +
                '"message":"' +
                partialDmlErrorMessage +
                '","fields":[]}], "id" : "null"}',
                Database.SaveResult.class
            );
        }
    }

    private void handleExecuteUpsert() {
        for (SObject sObj : forUpsertSObjects) {
            Database.UpsertResult result;
            if (sObj.Id == null) {
                sObj.Id = TestUtility.getFakeId(sObj.getSObjectType());
            }
            if (!partialDmlFailureIndexes.contains(forUpsertSObjects.indexOf(sObj))) {
                result = (Database.UpsertResult) JSON.deserialize(
                '{"success": true , "id" : "' +
                sObj.Id +
                '"}',
                Database.UpsertResult.class
                );
            } else {
                result = (Database.UpsertResult) JSON.deserialize(
                '{"success": false , "errors":[{"statusCode":"' +
                partialDmlErrorStatusCode +
                '",' +
                '"message":"' +
                partialDmlErrorMessage +
                '","fields":[]}], "id" : "null"}',
                Database.UpsertResult.class
                );
            }
        }
    }

    private void handleExecutePartialUpsert() {
        for (SObject sObj : forUpsertSObjects) {
            Database.UpsertResult result;
            if (sObj.Id == null) {
                sObj.Id = TestUtility.getFakeId(sObj.getSObjectType());
            }
            if (!partialDmlFailureIndexes.contains(forUpsertSObjects.indexOf(sObj))) {
                result = (Database.UpsertResult) JSON.deserialize(
                '{"success": true , "id" : "' +
                sObj.Id +
                '"}',
                Database.UpsertResult.class
                );
            } else {
                result = (Database.UpsertResult) JSON.deserialize(
                '{"success": false , "errors":[{"statusCode":"' +
                partialDmlErrorStatusCode +
                '",' +
                '"message":"' +
                partialDmlErrorMessage +
                '","fields":[]}], "id" : "null"}',
                Database.UpsertResult.class
                );
            }
            partialUpsertResult.sObjectList.add(sObj);
            partialUpsertResult.upsertResults.add(result);
        }
    }

    private void validateSObjectId(SObject sObj) {
        if (sObj.Id != null) {
            throw new DBManagerTestsStubException('Object in return list has an Id');
        } else {
            sObj.Id = TestUtility.getFakeId(sObj.getSObjectType());
        }
    }

    private class DBManagerTestsStubException extends Exception {
    }
}