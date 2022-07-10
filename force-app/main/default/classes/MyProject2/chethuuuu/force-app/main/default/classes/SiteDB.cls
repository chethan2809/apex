public class SiteDB extends DBManager {
    public List<Site> getAllSiteDetails() {
        return [
            SELECT GuestUserId, Name, Subdomain, UrlPathPrefix
            FROM Site
        ];
    }
}