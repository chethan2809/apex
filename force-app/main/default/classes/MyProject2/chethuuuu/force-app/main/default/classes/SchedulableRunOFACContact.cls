public with sharing class SchedulableRunOFACContact implements Schedulable {

    public string sQuery;
    public void execute(SchedulableContext sc) {
		  BatchRunOFACContact oBatch = new BatchRunOFACContact(sQuery);
		  database.executebatch(oBatch, 1);
	  }
}