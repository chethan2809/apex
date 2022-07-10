@isTest
public class StubPractiseClass1Test {
	@isTest
    public static void test1(){
        List<Account> accobjs = new List<Account>();
        Account acc = new Account();
        acc.Name = 'TestAccountSatya';
        acc.id = TestUtility.getFakeId(Account.getSObjectType());
        acc.phone = '9290015304';
        
        
        Account acc1 = new Account();
        acc1.Name = 'TestTest';
        acc1.id = TestUtility.getFakeId(Account.getSObjectType()).replace('AAA', 'BBB');
        acc1.phone = '8888888888';
        
        accobjs.add(acc);
        accobjs.add(acc1);
        
        DBManagerTestsStub stubPractiseAccountDBStubInstance = new DBManagerTestsStub();
        stubPractiseAccountDBStubInstance.genericReturnObject = accobjs;
        StubPractiseClass1.stubPractiseAccountDBInstance = (StubPractiseAccountDB) Test.createStub(StubPractiseAccountDB.class, stubPractiseAccountDBStubInstance);
        
        Contact con = new Contact();
		con.FirstName = 'MyFirstName';
		con.LastName = 'MyLastName';
		con.Email = 'TestMyTest@Test.com';
		con.Id = TestUtility.getFakeId(Contact.getSObjectType());
		con.AccountId = acc.id;
		con.Account = acc;
		
        DBManagerTestsStub stubPractiseContactDBStubInstance = new DBManagerTestsStub();
		stubPractiseContactDBStubInstance.genericReturnObject = new List<Contact>{con};
		StubPractiseClass1.stubPractiseContactDBInstance = (StubPractiseContactDB) Test.createStub(StubPractiseContactDB.class, stubPractiseContactDBStubInstance);
		
        Test.startTest();
        	StubPractiseClass1.getAccountByIds(new Set<Id>{acc.id});
        System.debug('After Update');
        acc.phone = '999999999';
        con.Email = 'Satya@Test.com';
        	StubPractiseClass1.getAccountByIds(new Set<Id>{acc.id});
        System.debug('After adding acc1');
        StubPractiseClass1.getAccountByIds(new Set<Id>{acc1.id});
        Test.stopTest();
    }
}