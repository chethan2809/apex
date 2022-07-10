public class UnderWriterTaskManager {

    @TestVisible
    private static PartyDB partyDBInstance = new PartyDB();
    @TestVisible
    private static UnderWriterTaskDB underWriterTaskDBInstance = new UnderWriterTaskDB();

    public static void createUnderWriterTasks(List<genesis__Applications__c> applicationList) {
        Set<Id> applicationIds = new Map<Id, genesis__Applications__c>(applicationList).keySet();

        Map<String, UnderWriter_Task_Category_Mapping__mdt> underWriterTaskCategoryMap =
            CustomMetaDataHelper.underWriterTaskCategoryMapping;

        for(clcommon__Party__c party : partyDBInstance.getGuarantorsAndContactBeneficialOwnersByApplicationIds(applicationIds)) {
            String contactName;
            if (party.clcommon__Contact__c != null && (party.clcommon__Contact__r.FirstName != null || party.clcommon__Contact__r.LastName != null)) {
                contactName = party.clcommon__Contact__r.FirstName.toUpperCase() + ' ' + party.clcommon__Contact__r.LastName.toUpperCase();
            }
            UnderWriter_Task__c taskDetail = UnderWriterTasks.createUnderWriterTask(
                party.genesis__Application__c, contactName, UnderWriterTasks.PERSONAL_GUARANTOR, 0
            );
            underWriterTaskDBInstance.addInsert(taskDetail);
        }

        for(genesis__Applications__c applicationRecord : applicationList) {
            for(UnderWriter_Task_Category_Mapping__mdt underWriterTaskCategoryRecord : underWriterTaskCategoryMap.values()) {
                UnderWriter_Task__c taskDetail = UnderWriterTasks.createUnderWriterTask(
                    applicationRecord.Id, underWriterTaskCategoryRecord.MasterLabel, underWriterTaskCategoryRecord.Category__c, underWriterTaskCategoryRecord.Order__c
                );
                underWriterTaskDBInstance.addInsert(taskDetail);
            }
        }

        underWriterTaskDBInstance.executeInserts();
    }
}