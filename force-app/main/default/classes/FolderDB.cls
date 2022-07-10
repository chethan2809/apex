public class FolderDB extends DBManager {
    public List<Folder> getAllFolder() {
        return [
            SELECT Id, Name
            FROM Folder
        ];
    }
}