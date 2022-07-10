public virtual class DBManager {
    @TestVisible
    private Set<SObject> forInserts = new Set<SObject>();

    @TestVisible
    private Map<Id, SObject> forUpdates = new Map<Id, SObject>();

    @TestVisible
    private Set<SObject> forUpserts = new Set<SObject>();

    @TestVisible
    private Map<Id, SObject> forDeletes = new Map<Id, SObject>();

    public virtual DBManager addInsert(SObject sObjectRecord) {
        forInserts.add(sObjectRecord);
        return this;
    }

    public virtual DBManager addInserts(List<SObject> sObjectList) {
        forInserts.addAll(sObjectList);
        return this;
    }

    public virtual DBManager addUpdate(SObject sObjectRecord) {
        forUpdates.put((Id) sObjectRecord.get('Id'), sObjectRecord);
        return this;
    }

    public virtual DBManager addUpdates(List<SObject> sObjectList) {
        convertSObjectListToMap(forUpdates, sObjectList);
        return this;
    }

    public virtual DBManager addUpdates(Map<Id, SObject> sObjectMap) {
        forUpdates.putAll(sObjectMap);
        return this;
    }

    public virtual DBManager addUpsert(SObject sObjectRecord) {
        forUpserts.add(sObjectRecord);
        return this;
    }

    public virtual DBManager addUpserts(List<SObject> sObjectList) {
        forUpserts.addAll(sObjectList);
        return this;
    }

    public virtual DBManager addDelete(SObject sObjectRecord) {
        forDeletes.put((Id) sObjectRecord.get('Id'), sObjectRecord);
        return this;
    }

    public virtual DBManager addDeletes(List<SObject> sObjectList) {
        convertSObjectListToMap(forDeletes, sObjectList);
        return this;
    }

    public virtual DBManager addDeletes(Map<Id, SObject> sObjectMap) {
        forDeletes.putAll(sObjectMap);
        return this;
    }

    public virtual DBManager executeInserts() {
        if (!forInserts.isEmpty()) {
            List<SObject> localList = new List<SObject>(forInserts);
            forInserts = new Set<SObject>();
            insert localList;
        }
        return this;
    }

    public virtual DBManager executeUpdates() {
        if (!forUpdates.isEmpty()) {
            System.debug('00forUpdates'+forUpdates);
            Map<Id, SObject> localMap = new Map<Id, SObject>(forUpdates);
            forUpdates = new Map<Id, SObject>();
            List<SObject> localList = localMap.values();
            System.debug('00localList'+localList);
            update localList;
        }
        return this;
    }

    public virtual DBManager executeUpserts() {
        if (!forUpserts.isEmpty()) {
            List<SObject> localList = new List<SObject>(
                handleUpsertSObjectsDuplicates(forUpserts)
            );
            forUpserts = new Set<SObject>();
            upsert localList;
        }
        return this;
    }

    public virtual DBManager executeDeletes() {
        if (!forDeletes.isEmpty()) {
            Map<Id, SObject> localMap = new Map<Id, SObject>(forDeletes);
            forDeletes = new Map<Id, SObject>();
            List<SObject> localList = localMap.values();
            delete localList;
        }
        return this;
    }

    private void convertSObjectListToMap(Map<Id, SObject> sObjectMap, List<SObject> sObjectList) {
        for (SObject sObjectRecord : sObjectList) {
        sObjectMap.put((Id) sObjectRecord.get('Id'), sObjectRecord);
        }
    }

    private Set<SObject> handleUpsertSObjectsDuplicates(Set<SObject> sObjectList) {
        Map<Id, SObject> sObjectMap = new Map<Id, SObject>();
        Set<SObject> localSObjects = new Set<SObject>();
        for (SObject sObjectRecord : sObjectList) {
            if (sObjectRecord.get('Id') != null) {
                sObjectMap.put((Id) sObjectRecord.get('Id'), sObjectRecord);
            } else {
                localSObjects.add(sObjectRecord);
            }
        }
        localSObjects.addAll(sObjectMap.values());
        return localSObjects;
    }

    public virtual PartialResult executePartialInserts() {
        if (!forInserts.isEmpty()) {
            List<SObject> localList = new List<SObject>(forInserts);
            forInserts = new Set<SObject>();
            List<Database.SaveResult> saveResults = Database.insert(localList, false);
            return new PartialResult(localList, saveResults);
        }
        return new PartialResult();
    }

    public virtual PartialResult executePartialUpdates() {
        if (!forUpdates.isEmpty()) {
            Map<Id, SObject> localList = new Map<Id, SObject>(forUpdates);
            forUpdates = new Map<Id, SObject>();
            List<Database.SaveResult> saveResults = Database.update(localList.values(), false);
            return new PartialResult(localList.values(), saveResults);
        }
        return new PartialResult();
    }

    public virtual PartialResult executePartialUpserts() {
        if (!forUpserts.isEmpty()) {
            List<SObject> localList = new List<SObject>(handleUpsertSObjectsDuplicates(forUpserts));
            forUpserts = new Set<SObject>();
            List<Database.UpsertResult> upsertResults = Database.upsert(localList, false);
            return new PartialResult(localList, upsertResults);
        }
        return new PartialResult();
    }

    public class PartialResult {
        public List<SObject> sObjectList;
        public List<Database.SaveResult> saveResults;
        public List<Database.UpsertResult> upsertResults;

        public PartialResult(List<SObject> sObjectList, List<Database.SaveResult> saveResults) {
            this.sObjectList = sObjectList;
            this.saveResults = saveResults;
        }

        public PartialResult(List<SObject> sObjectList, List<Database.UpsertResult> upsertResults) {
            this.sObjectList = sObjectList;
            this.upsertResults = upsertResults;
        }

        public PartialResult() {
            this.sObjectList = new List<SObject>();
            this.saveResults = new List<Database.SaveResult>();
            this.upsertResults = new List<Database.UpsertResult>();
        }
    }
}