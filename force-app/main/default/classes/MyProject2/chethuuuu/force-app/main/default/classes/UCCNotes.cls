public class UCCNotes {
    public static UCC_Notes__c createUCCNote(Id parentId, String description, Date createdDate) {
        UCC_Notes__c uccNote = new UCC_Notes__c();
        uccNote.UCC_Filing_Detail__c = parentId;
        uccNote.Description__c = description.left(2000);
        uccNote.UCC_Note_Created_Date__c = createdDate;
        return uccNote;
    }
}