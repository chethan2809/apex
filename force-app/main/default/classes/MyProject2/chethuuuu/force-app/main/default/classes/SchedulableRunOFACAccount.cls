public with sharing class SchedulableRunOFACAccount implements Schedulable {

    public string sQuery;
    public void execute(SchedulableContext sc) {
		BatchRunOFACAccount oBatch = new BatchRunOFACAccount(sQuery);
		database.executebatch(oBatch, 1);
	  }
}