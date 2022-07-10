global class CLXPortalAPS {
	
	public static String createAdhocPayment(String contractId, Decimal paymentAmt, Boolean payoffFlg){
		String apsType = 'ONE TIME';
		Decimal apsAmt;
		string contractStatus;
		Decimal todayPayoffAmt;
		String repayAcct = 'Borrower Repayment Account';
		String loanRpyAcctId;
        String responseMsg;
        Id loanAccountId;
		
        //Payment amount check
        if ((paymentAmt <= 0) || (paymentAmt == null)){
            if (payoffFlg == true){
            	responseMsg = CLXConstants.PAYOFF_AMT_RESPONSE;
            }
            else {
                responseMsg = CLXConstants.PAYMENT_AMT_RESPONSE;
            }
        }
        else {
			//Duplicate check
			List<loan__Automated_Payment_Setup__c> portAPS = [SELECT id, loan__Transaction_Amount__c FROM loan__Automated_Payment_Setup__c WHERE loan__CL_Contract__c = :contractId AND loan__Active__c = true AND loan__Type__c = :apsType LIMIT 1];
			if (portAPS.size() > 0){
				apsAmt = portAPS[0].loan__Transaction_Amount__c;
				if (payoffFlg == true){
					if (apsAmt == paymentAmt){
						responseMsg = CLXConstants.PAYOFF_DUP_RESPONSE;
					}
					else {
						responseMsg = CLXConstants.PAYOFF_NOT_RESPONSE;
					}
				}
				else {
					responseMsg = CLXConstants.PAYMENT_DUP_RESPONSE;
				}
			}
			else {
				//Payment amount and Status check against Loan Today Payoff
				List<loan__Loan_Account__c> contractAPS = new List<loan__Loan_Account__c>();
				contractAPS = [SELECT loan__Loan_Status__c, loan__Pay_Off_Amount_As_Of_Today__c,loan__Account__c FROM loan__Loan_Account__c WHERE id = :contractId LIMIT 1];
                if(contractAPS.size() > 0){
                    contractStatus = contractAPS[0].loan__Loan_Status__c;
                    todayPayoffAmt = contractAPS[0].loan__Pay_Off_Amount_As_Of_Today__c;
                    loanAccountId = contractAPS[0].loan__Account__c;
                }
                
				if (contractStatus == 'Active - Good Standing' || contractStatus == 'Active - Bad Standing'){
					//if (paymentAmt <= todayPayoffAmt){
						//Mode of payment fetch
						String modePayStatus = 'ACH';
						loan__Payment_Mode__c modeOfPay = new loan__Payment_Mode__c();
						modeOfPay = [SELECT Id FROM loan__Payment_Mode__c WHERE name = :modePayStatus LIMIT 1];
						String nrmModeOfPay = modeOfPay.Id;
						
						//Repayment Account fetch
						List<loan__Bank_Account__c> loanBankFetch = [SELECT Id FROM loan__Bank_Account__c WHERE loan__Account__c = :loanAccountId  AND loan__Active__c = true LIMIT 1];
						if (loanBankFetch.size() > 0){
							loanRpyAcctId = loanBankFetch[0].Id;
								
							//Date ACHDateVal = getPaymentCutOffDate();
							//String ACHDateValCmp = ACHDateVal.format();
							Date todayDate = Date.today();
							String todayDateCmp = todayDate.format();
							
							if (todayDateCmp == todayDateCmp){
								loan__Automated_Payment_Setup__c PortalAPS = new loan__Automated_Payment_Setup__c();
								PortalAPS.loan__Active__c = true;
								PortalAPS.loan__Actual_Date__c = todayDate;
								PortalAPS.loan__Amount_Type_Split_Factor__c = 1;
								PortalAPS.loan__Bank_Account__c = loanRpyAcctId;
								PortalAPS.loan__CL_Contract__c = contractId;
								PortalAPS.loan__Debit_Date__c = todayDate;
								PortalAPS.loan__Payment_Mode__c = nrmModeOfPay;
								PortalAPS.loan__Type__c = apsType;
								PortalAPS.loan__Setup_Date__c = todayDate;
								PortalAPS.loan__Transaction_Amount__c = paymentAmt;
								insert PortalAPS;
								
								if (payoffFlg == true){
									responseMsg = CLXConstants.PAYOFF_SUC_RESPONSE;
								}
								else {
									responseMsg = CLXConstants.PAYMENT_SUC_RESPONSE;
								}
							}
							else {
								if (payoffFlg == true){
									responseMsg = CLXConstants.PAYOFF_FAIL_RESPONSE;
								}
								else {
									loan__Automated_Payment_Setup__c PortalAPS = new loan__Automated_Payment_Setup__c();
									PortalAPS.loan__Active__c = true;
									PortalAPS.loan__Actual_Date__c = todayDate;
									PortalAPS.loan__Amount_Type_Split_Factor__c = 1;
									PortalAPS.loan__Bank_Account__c = loanRpyAcctId;
									PortalAPS.loan__CL_Contract__c = contractId;
									PortalAPS.loan__Debit_Date__c = todayDate;
									PortalAPS.loan__Payment_Mode__c = nrmModeOfPay;
									PortalAPS.loan__Type__c = apsType;
									PortalAPS.loan__Setup_Date__c = todayDate;
									PortalAPS.loan__Transaction_Amount__c = paymentAmt;
									insert PortalAPS;
									
									responseMsg = CLXConstants.PAYMENT_FAIL_RESPONSE;
								}
							}
						}
						else {
							responseMsg = CLXConstants.REPAY_ACCT_RESPONSE;
						}
							
					/* }
					else {
						responseMsg = CLXConstants.PAYMENT_OVER_RESPONSE;
					} */
				}
				else {
					responseMsg = CLXConstants.PAYMENT_CLOSED_RESPONSE;
				}
			}
        }
		return responseMsg;
	}
    
    public static Date getPaymentCutOffDate(){
        Datetime now = DateTime.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);
        Datetime currentDate = now.addSeconds(offset/1000);
        Date paymentDate;
        CLX_BusinessDays bh = New CLX_BusinessDays('Payment ACH Business Hours');
        if(!bh.isWorkingDay(currentDate)){
            paymentDate = Date.valueOf(bh.getNextWorkingDay(currentDate));
        }
        else{
            paymentDate = Date.valueOf(currentDate);
        }

        return paymentDate;
    }
}