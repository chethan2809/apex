public class UserPackageLicenseDB extends DBManager {
    public List<UserPackageLicense> getLicensesByPackageNameSpacePrefixAndUserIds(Set<String> packageNameSpacePrefix, Set<Id> userIds) {
        return [
            SELECT Id, PackageLicenseId, UserId
            FROM UserPackageLicense
            WHERE PackageLicense.NamespacePrefix IN :packageNameSpacePrefix
                AND userId IN :userIds
        ];
    }
}