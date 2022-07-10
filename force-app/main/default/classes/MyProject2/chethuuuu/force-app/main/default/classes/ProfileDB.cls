public class ProfileDB extends DBManager
{
    public List<Profile> getProfileIdByNames(Set<String> profileName)
    {
        return [
            SELECT Id, Name
            FROM Profile
            WHERE Name IN :profileName
        ];
    }


    public List<Profile> getAllProfiles()
    {
        return [
            SELECT Id, Name
            FROM Profile
        ];
    }
}