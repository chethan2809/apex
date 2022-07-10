/*
 * Created by Dileep Grandhi
*/
global class CLXSSPTransactionSummaryAPI implements clcommon.PortalCustomRemoteAPI1 {
	public static CLContractDB clContractDBInstance = new CLContractDB();
	public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

	global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> params) {
		clcommon.Response res = new clcommon.Response();
		Date currSystemDate = GeneralHelper.currentSystemDate;
		List<Sobject> mapList = new List<Sobject>();
		List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
		String loanId;
		Date fromDate;
		Date endDate = currSystemDate;
		String orderByValue = 'loan__Transaction_Date__c desc';
		String dateLiterals;
		if (params.containskey('loanId') && params.get('loanId') != null) {
			loanId = String.valueOf(params.get('loanId'));
			List<loan__Loan_Account__c> contractList = clContractDBInstance.getLoanAccountsByIds(new Set<Id>{loanId});
			if(!contractList.isEmpty()){
				Boolean isValidAccount = PortalSecurityUtil.validateUserByBorrowerAccountId(contractList[0].loan__Account__c);
				if(isValidAccount){
					if (params.containskey('orderBy') && params.get('orderBy') != null) {
						orderByValue = String.valueOf(params.get('orderBy'));
					}
					
					if (params.containskey('loanId') && params.get('loanId') != null) {
						loanId = String.valueOf(params.get('loanId'));
						List<loan__Loan_Account__c> loanContract = new List<loan__Loan_Account__c>();
						if(fromDate == null) {
							loanContract = [Select Id,
											Name,
											loan__Accrual_Start_Date__c
											FROM loan__Loan_Account__c WHERE id=:loanId];
							fromDate = loanContract[0].loan__Accrual_Start_Date__c;
						}

					}else{
						res = new clcommon.Response();
						res.status = clcommon.Constants.ERROR;
						res.errorCode = clcommon.Constants.API_EXCEPTION;
						res.errorMessage = PortalConstants.SOMETHING_WENT_WRONG_MESSAGE;
						return res;
					}

					if(params.containskey('recentTransaction') && params.get('recentTransaction') != null) {
						dateLiterals = String.valueof(params.get('recentTransaction'));
						Date rangeStartDate = computeDateValue(dateLiterals,currSystemDate);
						List<loan__Loan_Payment_Transaction__c> lptList = fetchTransactionInDateRange(loanId, rangeStartDate, currSystemDate, orderByValue);
						respList = getResponseList(lptList);
						res = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
						res.status = 'SUCCESS';
					}
					else if(params.containskey('range') && params.get('range') != null) {

						try{

							if (params.containskey('fromDate') && params.get('fromDate') != null) {
								fromDate = Date.valueof(String.valueOf(params.get('fromDate')));
							}
							if (params.containskey('endDate') && params.get('endDate') != null) {
								endDate= Date.valueof(String.valueOf(params.get('endDate')));

							}

							List<loan__Loan_Payment_Transaction__c> lptList = fetchTransactionInDateRange(loanId, fromDate, endDate, orderByValue);
							respList = getResponseList(lptList);
							res = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
							res.status = 'SUCCESS';

						}catch(Exception e) {
							res = new clcommon.Response();
							res.status = clcommon.Constants.ERROR;
							res.errorCode = clcommon.Constants.API_EXCEPTION;
							res.errorMessage = PortalConstants.SOMETHING_WENT_WRONG_MESSAGE;
						}
					}else{
						try{
							List<loan__Loan_Payment_Transaction__c> lptList = fetchTransactionInDateRange(loanId, fromDate, currSystemDate, orderByValue);
							respList = getResponseList(lptList);
							res = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
							res.status = 'SUCCESS';

						}catch(Exception e) {
							res = new clcommon.Response();
							res.status = clcommon.Constants.ERROR;
							res.errorCode = clcommon.Constants.API_EXCEPTION;
							res.errorMessage = PortalConstants.SOMETHING_WENT_WRONG_MESSAGE;
						}
					}
				}
			}
		}
		return res;
	}

public List<loan__Loan_Payment_Transaction__c> fetchTransactionInDateRange(String loanId,Date startDate,Date endDate,String orderByValue){
	String queryStr ='';
	if(orderByValue != null && orderByValue != '')
		queryStr = 'select Id, Name, loan__Payment_Type__c, loan__Payment_Mode__r.Name, Transaction_Date_For_Portal__c, loan__Transaction_Amount__c,loan__Cleared__c,loan__Balance__c from loan__Loan_Payment_Transaction__c  where loan__Loan_Account__c= :loanId AND loan__Transaction_Date__c>=:startDate AND  loan__Transaction_Date__c<=:endDate order by ' + orderByValue;
	else
		queryStr = 'select Id, Name, loan__Payment_Type__c, loan__Payment_Mode__r.Name, Transaction_Date_For_Portal__c, loan__Transaction_Amount__c,loan__Cleared__c,loan__Balance__c from loan__Loan_Payment_Transaction__c  where loan__Loan_Account__c= :loanId AND loan__Transaction_Date__c>=:startDate AND  loan__Transaction_Date__c<=:endDate';
	List<loan__Loan_Payment_Transaction__c> lpts = Database.query(queryStr);
	return lpts;
}

public Date computeDateValue(String queryParameter,Date currDate){
	Date returnDateValue;
	if('LAST_WEEK'.equals(queryParameter))
		returnDateValue = currDate.addDays(-7);
	else if('LAST_MONTH'.equals(queryParameter))
		returnDateValue = currDate.addDays(-30);
	else if('LAST_90_DAYS'.equals(queryParameter))
		returnDateValue = currDate.addDays(-90);
	else if('LAST_30_DAYS'.equals(queryParameter))
		returnDateValue = currDate.addDays(-30);
	else if('LAST_180_DAYS'.equals(queryParameter))
		returnDateValue = currDate.addDays(-180);

	return returnDateValue;
}

public List<clcommon.PortalCustomRemoteActionRecord> getResponseList(List<loan__Loan_Payment_Transaction__c> lpts){

	List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
	for(loan__Loan_Payment_Transaction__c iterLpt:lpts) {
		SObject iter = (Sobject) iterLpt;
		respList.add(new clcommon.PortalCustomRemoteActionRecord(iter));
	}
	return respList;
}

}