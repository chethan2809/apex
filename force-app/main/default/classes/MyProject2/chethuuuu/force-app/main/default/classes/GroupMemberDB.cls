public class GroupMemberDB extends DBManager {
    public List<GroupMember> getAllLowBalanceQueueUsers() {
        return [
            SELECT UserOrGroupId
            FROM GroupMember
            WHERE GroupId IN (SELECT Id FROM Group WHERE Name ='LOW BALANCE' AND Type = 'Queue')
        ];
    }

    public List<GroupMember> getAllHighBalanceQueueUsers() {
        return [
            SELECT UserOrGroupId
            FROM GroupMember
            WHERE GroupId IN (SELECT Id FROM Group WHERE Name ='HIGH BALANCE' AND Type = 'Queue')
        ];
    }
}