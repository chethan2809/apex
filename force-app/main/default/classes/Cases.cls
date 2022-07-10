public class Cases {
    public static Case createCase(String subject, String description, String type, Id ownerId) {
        Case caseObj = new Case();
        caseObj.Subject = subject;
        caseObj.Description = description;
        caseObj.Type = type;
        caseObj.OwnerId = ownerId;
        return caseObj;
    }
}