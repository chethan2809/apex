@isTest(isParallel=true)
private class FolderDBTests {

    private static FolderDB folderDBInstance = new FolderDB();

    @isTest
    private static void getAllFolder() {

        Test.startTest();
            List<Folder> folderList = folderDBInstance.getAllFolder();
        Test.stopTest();

        System.assert(folderList != null);
    }
}