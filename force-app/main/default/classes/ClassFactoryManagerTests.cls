@isTest
private class ClassFactoryManagerTests {

    private static ClassFactoryManager classFactoryManagerInstance = new ClassFactoryManager();

    @isTest
    private static void newClassInstance() {

        Test.startTest();
            Object actualObject = classFactoryManagerInstance.newClassInstance('ClassFactoryManager');
        Test.stopTest();

       System.assert(actualObject != null);
    }
}