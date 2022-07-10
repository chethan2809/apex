trigger accountTrigger4 on Account (After insert) {
    List<Contact> contactList=new List<Contact>();
    for(Account acctObj:Trigger.New){
        Contact contObj=new Contact();
        contObj.Lastname='Test of Account-Contact';
        contObj.AccountId=acctObj.id;
        contactList.add(contObj);
        System.debug(contactList);
    }
insert contactList;
}