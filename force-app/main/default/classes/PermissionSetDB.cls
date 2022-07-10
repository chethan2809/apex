public class PermissionSetDB extends DBManager
{
	public List<PermissionSet> getPermissionSetsByNames(Set<String> permissionSetNames)
    {
        return [
            SELECT Id, Name
            FROM PermissionSet
            WHERE Name IN :permissionSetNames
        ];
    }
}