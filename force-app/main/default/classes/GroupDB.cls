public class GroupDB extends DBManager{

    public List<Group> getAllQueues() {
        return [
            SELECT Id, Name, Type, DeveloperName
            FROM Group
            WHERE Type = 'Queue'
        ];
    }
}