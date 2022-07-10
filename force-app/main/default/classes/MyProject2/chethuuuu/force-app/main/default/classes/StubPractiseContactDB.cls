public class StubPractiseContactDB extends DBManager{
    public List<Contact> getContactsByAccountIds(Set<Id> accountIds){
        return [Select id,FirstName,LastName,Email from Contact Where AccountId IN: accountIds];
    }
}