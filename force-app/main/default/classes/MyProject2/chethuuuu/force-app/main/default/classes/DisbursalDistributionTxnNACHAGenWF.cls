public class DisbursalDistributionTxnNACHAGenWF extends loan.FileGenerator {
    private loan__Bank_Account__c bank;
    Long routingHash = 0;
    Integer linecount=0;
    Double blocks =0.0;
    Decimal creditTotal = 0;
    String pMode = 'ACH';
    private static String[] abc = new String[] {'A','B','C','D','E','F','G','H','I','J','K',
                                    'L','M','N','O','P','Q','R','S','T','U','V',
                                    'W','X','Y','Z'};
    loan__Automated_Payment_Configuration__c autoPmtConfig = new loan__Automated_Payment_Configuration__c();

    //requery scope
    private List<loan__Disbursal_Txn_Distribution__c> requeryScope(List<SObject> scope){
        Set<ID> scopeIds = new Set<ID>();
        for(SObject s : scope) {
            scopeIds.add(s.Id);
        }
        List<loan__Disbursal_Txn_Distribution__c> disbTxns = [SELECT Id,loan__Distribution_Amount__c,
                                                            loan__Bank_Account__c,
                                                            loan__Bank_Account__r.loan__Active__c,
                                                            loan__Bank_Account__r.loan__Contact__c,
                                                            loan__Bank_Account__r.loan__Account__c,
                                                            loan__Bank_Account__r.loan__Bank_Name__c,
                                                            loan__Bank_Account__r.loan__Account_Type__c,
                                                            loan__Bank_Account__r.loan__Account_Usage__c,
                                                            loan__Bank_Account__r.loan__Routing_Number__c,
                                                            loan__Bank_Account__r.loan__Bank_Account_Number__c,
                                                            loan__Loan_Disbursal_Transaction__r.loan__Bank_Account__c,
                                                            loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__c,
                                                            loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Name,
                                                            loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__ACH_Bank__c,
                                                            loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__ACH_Bank__r.Name,
                                                            loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__ACH_Bank__r.loan__Routing_Number__c,
                                                            loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__ACH_Bank__r.loan__ACH_Code__c,
                                                            loan__Payment_Mode__r.Name
                                                        FROM loan__Disbursal_Txn_Distribution__c WHERE Id IN :scopeIds];
        Set<Id> loanIds = new Set<Id>();
        try{
            if(loan.CustomSettingsUtil.getACHParameters().loan__Multiple_Payment_Method_Support__c == true){
                if(disbTxns.size()>0){
                    if(disbTxns[0].loan__Payment_Mode__r.Name!=null){
                        pMode = disbTxns[0].loan__Payment_Mode__r.Name;
                    }
                }
                autoPmtConfig = [SELECT Id,loan__Immediate_Destination__c,
                                    loan__Company_Identification__c,
                                    loan__Originating_DFI_Identification__c,
                                    loan__Immediate_Destination_Name__c,
                                    loan__Immediate_Origin__c,
                                    loan__Immediate_Origin_Name__c,
                                    loan__Reference_Code__c,
                                    loan__Trace_Number_Prefix__c,
                                    Company_Name_NACHA__c,
                                    loan__Bank_Account__r.loan__Bank_Account_Number__c,
                                    loan__Bank_Account__r.loan__Account__c,
                                    loan__Bank_Account__r.loan__Account__r.Name,
                                    loan__Bank_Account__r.loan__Account_Type__c,
                                    loan__Bank_Account__r.loan__Account_usage__c,
                                    loan__Bank_Account__r.loan__Bank_name__c,
                                    loan__Bank_Account__r.loan__ACH_Code__c,
                                    loan__Bank_Account__r.loan__Contact__c,
                                    loan__Bank_Account__r.loan__Contact__r.Name,
                                    loan__Bank_Account__r.loan__Routing_Number__c
                                FROM loan__Automated_Payment_Configuration__c
                                WHERE loan__Active__c = true
                                    AND loan__Bank_Account__r.loan__Account_usage__c INCLUDES  (:loan.FractionalizationConstants.ADVANCE_TRUST_ACCOUNT)
                                    AND loan__Bank_account__r.loan__Active__c = true
                                    AND loan__Payment_Mode__r.Name =:pMode
                                    AND loan__Event__c INCLUDES (:loan.LoanConstants.LOAN_DISBURSAL) LIMIT 1];
            }else{
                bank = [SELECT Id,Name,
                            loan__Bank_Name__c,
                            loan__ACH_Code__c,
                            loan__Account__c,
                            loan__Account__r.Name,
                            loan__Account_Type__c,
                            loan__Account_Usage__c,
                            loan__Bank_Account_Number__c,
                            loan__Contact__c,loan__Contact__r.Name,
                            loan__Routing_Number__c
                            FROM loan__Bank_Account__c
                            WHERE loan__Account_Usage__c INCLUDES (:loan.FractionalizationConstants.ADVANCE_TRUST_ACCOUNT)
                                AND loan__Active__c = true LIMIT 1];
            }

        }catch(Exception e){
            throw new peer.MarketplaceException('Advance Trust Account is not available');
        }
        for(loan__Disbursal_Txn_Distribution__c disbDist: disbTxns){
            loanIds.add(disbDist.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__c);
        }

        String objectCacheName = 'disbursementDistribuionForACH' + pMode;
        mfiflexUtil.ExecutionContext ec = mfiflexUtil.ExecutionContext.getExecContext();
        mfiflexUtil.ObjectCache dsbOC = ec.getObject(objectCacheName);
        if(dsbOC == null) {
            dsbOC = ec.createObject(objectCacheName,
                                    'loan__Disbursal_Txn_Distribution__c', loan.CustomSettingsUtil.getOrgParameters().loan__Namespace_Prefix__c);

            String addFieldsString =  'Id, loan__Distribution_Amount__c '
                                    + ', loan__Bank_Account__c '
                                    + ', loan__Bank_Account__r.loan__Active__c '
                                    + ', loan__Bank_Account__r.loan__Contact__c '
                                    + ', loan__Bank_Account__r.loan__Account__c '
                                    + ', loan__Bank_Account__r.loan__Contact__r.name '
                                    + ', loan__Bank_Account__r.loan__Account__r.name '
                                    + ', loan__Bank_Account__r.loan__Bank_Name__c '
                                    + ', loan__Bank_Account__r.loan__Account_Type__c '
                                    + ', loan__Bank_Account__r.loan__Account_Usage__c '
                                    + ', loan__Bank_Account__r.loan__Routing_Number__c '
                                    + ', loan__Bank_Account__r.loan__Bank_Account_Number__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Name '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__ACH_Drawer_Name__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__ACH_Relationship_Type__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Bank_Account__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Bank_Account__r.loan__Account__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Bank_Account__r.loan__Account_Type__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Bank_Account__r.loan__Account_Usage__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Bank_Account__r.loan__Active__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Bank_Account__r.loan__Bank_Account_Number__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Bank_Account__r.loan__Bank_Name__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Bank_Account__r.loan__Contact__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Bank_Account__r.loan__Routing_Number__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Borrower_ACH__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Borrower_ACH__r.loan__Account__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Borrower_ACH__r.loan__Account_Type__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Borrower_ACH__r.loan__Account_Usage__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Borrower_ACH__r.loan__Active__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Borrower_ACH__r.loan__Bank_Account_Number__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Borrower_ACH__r.loan__Bank_Name__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Borrower_ACH__r.loan__Contact__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Borrower_ACH__r.loan__Routing_Number__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__ACH_Account_Number__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Loan_Amount__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Account__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Account__r.Name '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Contact__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Contact__r.Name '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__ACH_Bank__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__ACH_Bank__r.Name '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__ACH_Bank__r.loan__ACH_Code__c '
                                    + ', loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__ACH_Bank__r.loan__Routing_Number__c ';
            dsbOC.addFields(addFieldsString);

            dsbOC.addNamedParameter('disIds', scopeIds);
            dsbOC.setWhereClause('Id IN :disIds');
        }
        dsbOC.executeQuery();
        return (List<loan__Disbursal_Txn_Distribution__c>) dsbOC.getRecords();
    }

    public override String getSimpleFileName() {
        if(loan.CustomSettingsUtil.getACHParameters().loan__Multiple_Payment_Method_Support__c == true){
            return 'Loan_Disbursals_'+pMode;
        }
        return 'Loan_Disbursals';
    }

    public override List<String> getEntries(loan.TransactionSweepToACHState state, List<SObject> scope) {
        system.debug(loggingLevel.Error,'----:'+'inside entries');
        List<String> retVal = new List<String>();
        List<loan__Disbursal_Txn_Distribution__c> disbursalDistributions = requeryScope(scope);
        List<SObject> objects = new List<SObject>();

        for(loan__Disbursal_Txn_Distribution__c dTxn : disbursalDistributions){
            loan__Loan_Account__c loanAccount = dTxn.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r;
            loan__Bank_Account__c borrBank = new loan__Bank_Account__c();
            if(dTxn.loan__Bank_Account__c != null){
                borrBank = dTxn.loan__Bank_Account__r;
            }else if(dTxn.loan__Loan_Disbursal_Transaction__r.loan__Bank_Account__c != null){
                borrBank = dTxn.loan__Loan_Disbursal_Transaction__r.loan__Bank_Account__r;
            }else if(dTxn.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Borrower_ACH__r != null){
                borrBank = loanAccount.loan__Borrower_ACH__r;
            }else{
                addToInvalidScope(dTxn,'Bank Details are missing.');
            }

            if(borrBank.id!=null && (borrBank.loan__Routing_Number__c != null || borrBank.loan__Bank_Account_Number__c !=null || dTxn.loan__Distribution_Amount__c != null || borrBank.loan__Account_Type__c != null) ){
                addToValidScope(dTxn);
                objects.add(generateEntryDetailRecord(dTxn));
            }
            else{
                 addToInvalidScope(dTxn,'Borrower Ach routing no, Loan account ACH Account number or Distribution amount is missing');
            }
        }
        filegen.CreateSegments segments = new filegen.CreateSegments(objects);
        retVal = segments.retString();
        for(String line:retVal){
            line = line+'\n';
            addEntry(line);
        }
        return retVal;
    }

    public override String getHeader(loan.TransactionSweepToACHState state, List<SObject> scope) {
        String header = '';
        List<String> retVal = new List<String>();
        List<SObject> headerRecs = new List<SObject>();
        headerRecs.add(generateFileHeaderRecord(state));
        headerRecs.add(generateBatchHeaderRecord());
        filegen.CreateSegments segments =new filegen.CreateSegments(headerRecs);
        retVal = segments.retString();
        header =retVal[0]+'\r\n';
        header+=retVal[1] + '\r\n';
        return header;

    }

    public override String getTrailer(loan.TransactionSweepToACHState state, LIST<SObject> scope) {
        String achFileTrailerContent = '';
        List<String> retVal = new List<String>();
        List<SObject> trailerRecs = new List<SObject>();
        trailerRecs.add(generateBatchControlRecord(scope));
        trailerRecs.add(generateFileControlRecord(scope));
        filegen.CreateSegments segments =new filegen.CreateSegments(trailerRecs);
        retVal = segments.retString();

        for(String s : retVal){
            achFileTrailerContent = achFileTrailerContent + s + '\r\n';
        }
        Integer fillersToAdd = Integer.valueOf( blocks * 10 ) - linecount;

        achFileTrailerContent = achFileTrailerContent.subString( 0 , achFileTrailerContent.length() - 2 );

        //fillers are added to make number of characters in generated file multiple of 940
        for(Integer i = 0 ; i < fillersToAdd ; i++ ) {
            achFileTrailerContent = achFileTrailerContent + '\r\n'+ rightPadString('', 94,'9');
        }

        return achFileTrailerContent + '\r\n';
        //return 'TRAILER';
    }
    //File header

    private filegen__File_Header_Record__c generateFileHeaderRecord(loan.TransactionSweepToACHState state){

        Datetime currentSystemDateTime = new loan.GlobalLoanUtilFacade().getCurrentSystemDateTime();
        Date csd = Date.newInstance(currentSystemDateTime.year(), currentSystemDateTime.month(), currentSystemDateTime.day());
        String hour = (currentSystemDateTime.hour()>=10?String.valueOf(currentSystemDateTime.hour()):'0'+currentSystemDateTime.hour());
        String minute = (currentSystemDateTime.minute()>=10?String.valueOf(currentSystemDateTime.minute()):'0'+currentSystemDateTime.minute());
        String myTime = hour + minute;

        filegen__File_Header_Record__c fHR = new filegen__File_Header_Record__c();
        String immediateDestination ='';
        String immediateOrigin = '';
        Integer counter= 0;
        String immediateDestinationName = '';
        String referenceCode = '';
        String immediateOriginName = '';
        Map<String,Integer> countMap = (Map<String,Integer>)state.o2;

        if(loan.CustomSettingsUtil.getACHParameters().loan__Multiple_Payment_Method_Support__c == true){
            if(autoPmtConfig.loan__Immediate_Destination__c!=null){
                immediateDestination = loan.StringUtils.leftPadString( '' +autoPmtConfig.loan__Immediate_Destination__c,9,'0');
            }
            if(autoPmtConfig.loan__Immediate_origin__c!=null){
                immediateOrigin = autoPmtConfig.loan__Immediate_origin__c;
            }
            if(countMap.get(pMode)==null){
                countMap.put(pMode,0);
                state.o2 = countMap;
            }
            counter =countMap.get(pMode);
            if(autoPmtConfig.loan__Immediate_Destination_Name__c!=null){
                immediateDestinationName = autoPmtConfig.loan__Immediate_Destination_Name__c ;
            }
            if(autoPmtConfig.loan__Immediate_Origin_Name__c!=null){
                immediateOriginName = autoPmtConfig.loan__Immediate_Origin_Name__c;
            }
            if(autoPmtConfig.loan__Reference_Code__c!=null){
                referenceCode = autoPmtConfig.loan__Reference_Code__c;
            }
        }else{
            if(loan.CustomSettingsUtil.getACHParameters().loan__Immediate_Destination__c!= null){
                immediateDestination =loan.StringUtils.leftPadString(''+loan.CustomSettingsUtil.getACHParameters().loan__Immediate_Destination__c ,9,'0');
            }else{
                immediateDestination = String.valueOf(bank.loan__Routing_Number__c);
                if(immediateDestination.length()<9){
                    immediateDestination = loan.StringUtils.leftPadString(''+bank.loan__Routing_Number__c,9,'0');
                }
            }
            immediateorigin = (loan.CustomSettingsUtil.getACHParameters().loan__Fed_Tax_Id__c!=null?loan.CustomSettingsUtil.getACHParameters().loan__Fed_Tax_Id__c:'');
            counter = state.counter;
            if(bank != null && bank.loan__Bank_Name__c != null){
                immediateDestinationName = bank.loan__Bank_Name__c;
            }
            else{
                immediateDestinationName = '';
            }

            immediateOriginName = loan.CustomSettingsUtil.getACHParameters().loan__Organization_Name__c;
            referenceCode = loan.CustomSettingsUtil.getACHParameters().loan__ACH_Id__c;
        }

        fHR.filegen__Immediate_Destination__c = immediateDestination;
        fHR.filegen__Immediate_Origin__c = immediateOrigin;
        fHR.filegen__Creation_Date__c = csd;
        fHR.filegen__Creation_Time__c = myTime;
        fHR.filegen__ID_Modifier__c = abc[counter] ;
        fHR.filegen__Immediate_Destination_Name__c = immediateDestinationName;
        fHR.filegen__Immediate_Origin_Name__c = immediateOriginName;
        fHR.filegen__Reference_Code__c = referenceCode;
        return fHR;
    }

    //Batch Header
     private filegen__Batch_Header_Record__c generateBatchHeaderRecord(){
        Datetime currentSystemDateTime = new loan.GlobalLoanUtilFacade().getCurrentSystemDateTime();
        Date csd = Date.newInstance(currentSystemDateTime.year(), currentSystemDateTime.month(), currentSystemDateTime.day());
        filegen__Batch_Header_Record__c bHR = new filegen__Batch_Header_Record__c();
        String companyName = '';
        String companyIdentification = '';
        String originatingDFIIdentification = '';

        if(loan.CustomSettingsUtil.getACHParameters().loan__Multiple_Payment_Method_Support__c == true){
            if(autoPmtConfig.Company_Name_NACHA__c!=null){
                companyName = autoPmtConfig.Company_Name_NACHA__c;
            }
            if(autoPmtConfig.loan__Company_Identification__c!=null){
                companyIdentification = autoPmtConfig.loan__Company_Identification__c;
            }
            if(autoPmtConfig.loan__Originating_DFI_Identification__c!=null){
                originatingDFIIdentification = loan.StringUtils.leftPadString(''+autoPmtConfig.loan__Originating_DFI_Identification__c,8,'0');
            }
        }else{
            companyName = loan.CustomSettingsUtil.getACHParameters().loan__Organization_Name__c;
            if(bank !=null && bank.loan__ACH_Code__c!=null){
                companyIdentification = bank.loan__ACH_Code__c;
            }
            else{
                companyIdentification = '';
            }
            String banksRoutingNo ='';
            if( loan.CustomSettingsUtil.getACHParameters().loan__Originating_DFI_Identification__c!= null){
                banksRoutingNo =loan.StringUtils.leftPadString(''+loan.CustomSettingsUtil.getACHParameters().loan__Originating_DFI_Identification__c ,8,'0');
            }else{
                banksRoutingNo = String.valueOf(bank.loan__Routing_Number__c);
            }
            if(banksRoutingNo.length()<9){
                banksRoutingNo=loan.StringUtils.leftPadString(''+banksRoutingNo ,9,'0');
            }
            originatingDFIIdentification = banksRoutingNo;
        }
        bHR.filegen__Service_Class_Code__c = '220';
        bHR.filegen__Company_Name__c = companyName;
        bHR.filegen__Company_Discretionary_Data__c = 'ACH_PAYMENTS';
        bHR.filegen__Company_Identification__c = companyIdentification;

        bHR.filegen__SEC_Code__c = 'PPD';
        bHR.filegen__Company_Entry_Description__c = 'PAYMENT';
        bHR.filegen__Company_Descriptive_Date__c = csd;
        bHR.filegen__Effective_Entry_Date__c = csd;
        bHR.filegen__Originating_DFI_Identification__c = originatingDFIIdentification;
        bHR.filegen__Batch_Number__c = '0000123';
        return bHR;
    }

    //Entry Detail
    private filegen__Entry_Detail_Record__c generateEntryDetailRecord(loan__Disbursal_Txn_Distribution__c disbursalDistTxn){

        filegen__Entry_Detail_Record__c eDR = new filegen__Entry_Detail_Record__c();
        loan__Loan_Account__c loanAccount = disbursalDistTxn.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r;
        loan__Bank_Account__c borrBank = new loan__Bank_Account__c();

        if(disbursalDistTxn.loan__Bank_Account__c!=null){
            borrBank = disbursalDistTxn.loan__Bank_Account__r;
        }else if(disbursalDistTxn.loan__Loan_Disbursal_Transaction__r.loan__Bank_Account__c!=null){
            borrBank = disbursalDistTxn.loan__Loan_Disbursal_Transaction__r.loan__Bank_Account__r;
        }else{
            borrBank = loanAccount.loan__Borrower_ACH__r;
        }

        if(loan.LoanConstants.ACCOUNT_TYPE_SAVING.equalsIgnoreCase(borrBank.loan__Account_Type__c)
            || loan.LoanConstants.ACCOUNT_TYPE_SAVINGS.equalsIgnoreCase(borrBank.loan__Account_Type__c) ){
            eDR.filegen__Transaction_Code__c = '32';
        }else if(loan.LoanConstants.ACCOUNT_TYPE_CHECKING.equalsIgnoreCase(borrBank.loan__Account_Type__c)){
            eDR.filegen__Transaction_Code__c = '22';
        }
        String customerName = '';
        if(disbursalDistTxn.loan__Bank_Account__r != null) {
            if(disbursalDistTxn.loan__Bank_Account__r.loan__Account__c !=null) {
                customerName = disbursalDistTxn.loan__Bank_Account__r.loan__Account__r.name;
            } else if(disbursalDistTxn.loan__Bank_Account__r.loan__Contact__c != null) {
                customerName = disbursalDistTxn.loan__Bank_Account__r.loan__Contact__r.name;
            }
        }else if(loanAccount.loan__ACH_Relationship_Type__c == null || loanAccount.loan__ACH_Relationship_Type__c == loan.LoanConstants.ACH_RELATIONSHIP_TYPE_PRIMARY){
            if(loanAccount.loan__Account__c != null){
                customerName = loanAccount.loan__Account__r.Name;
            }
            else if(loanAccount.loan__Contact__c != null){
                customerName = loanAccount.loan__Contact__r.Name;
            }
        }else{
            customerName = loanAccount.loan__ACH_Drawer_Name__c;
        }

        String customerRoutingNo = '';
        if(borrBank.loan__Routing_Number__c != null){
            customerRoutingNo = String.valueOf(borrBank.loan__Routing_Number__c);
        }

        if(customerRoutingNo.length()<9){
            customerRoutingNo=loan.StringUtils.leftPadString(''+customerRoutingNo,9,'0');
        }

        eDR.filegen__RDFI_Identification__c = customerRoutingNo;
        String checkDigit = '';
        if(borrBank.loan__Routing_Number__c != null && borrBank.loan__Routing_Number__c.length() >=8 ){
            checkDigit = borrBank.loan__Routing_Number__c.substring(8);
        }
        eDR.filegen__Check_Digit__c = checkDigit;
        eDR.filegen__RDFI_Account_Number__c = borrBank.loan__Bank_Account_Number__c != null ?borrBank.loan__Bank_Account_Number__c:'';
        eDR.filegen__Amount__c = disbursalDistTxn.loan__Distribution_Amount__c != null ?String.valueOf(disbursalDistTxn.loan__Distribution_Amount__c.setScale(2)):'';
        String customerLoanName = loan.StringUtils.rightPadString(loanAccount.Name.replace('-','0'),15, ' ');
        eDR.filegen__Individual_Identification_Number__c = customerLoanName;
        eDR.filegen__Individual_Name__c = customerName;
        eDR.filegen__Addenda_Record_Indicator__c='0';
        String tracePrefix = '';
        String traceNum = '';
        if(loan.CustomSettingsUtil.getACHParameters().loan__Multiple_Payment_Method_Support__c == true){
            if(autoPmtConfig.loan__Trace_Number_Prefix__c!=null){
                tracePrefix = autoPmtConfig.loan__Trace_Number_Prefix__c;
            }
        }else{
            if(loan.CustomSettingsUtil.getACHParameters().loan__Trace_Number_prefix__c!=null){
                tracePrefix = loan.CustomSettingsUtil.getACHParameters().loan__Trace_Number_Prefix__c;
            }
        }

        if( tracePrefix != null){
            traceNum = String.valueOf(tracePrefix+disbursalDistTxn.Name.subString(6));
        }else{
            traceNum = loan.StringUtils.leftPadString((disbursalDistTxn.Name.subString(7)),15, '0');
        }
        eDR.filegen__Trace_Number__c = traceNum;

        Integer customerHashNo = 0;
        if(borrBank != null && borrBank.loan__Routing_Number__c != null && borrBank.loan__Routing_Number__c.length() >=8){
            customerHashNo = Double.valueOf( borrBank.loan__Routing_Number__c.substring(0,8) ).intValue();
        }
        routingHash = routingHash + customerHashNo;
        creditTotal = creditTotal + (disbursalDistTxn.loan__Distribution_Amount__c != null ?disbursalDistTxn.loan__Distribution_Amount__c.setScale(2):0);

        return eDR;
    }

    //Batch Control
    private filegen__Batch_Control_Record__c generateBatchControlRecord(LIST<SObject> scope){
        filegen__Batch_Control_Record__c bCR = new filegen__Batch_Control_Record__c();

        bCR.filegen__Service_Class_Code__c = '220';
        bCR.filegen__Entry_Addenda_Count__c = String.valueOf(getValidScope().size());
        bCR.filegen__Entry_Hash__c = String.valueOf(routingHash);
        bCR.filegen__Total_Credit_Entry_Dollar_Amount__c = String.valueOf(Integer.valueOf(creditTotal.setScale(2)*100));
        String companyIdentification = '';
        String originatingDFIIdentification = '';

        if(loan.CustomSettingsUtil.getACHParameters().loan__Multiple_Payment_Method_Support__c == true){
            if(autoPmtConfig.loan__company_identification__c!=null){
                companyIdentification = autoPmtConfig.loan__Company_Identification__c;
            }
            if(autoPmtConfig.loan__originating_DFI_Identification__c!=null){
                originatingDFIIdentification =loan.StringUtils.leftPadString(''+ autoPmtConfig.loan__Originating_DFI_Identification__c,8,'0');
            }
        }else{
            if(bank != null && bank.loan__ACH_Code__c != null){
                companyIdentification = String.valueOf(bank.loan__ACH_Code__c);
            }
            String banksRoutingNo ='';
            if( loan.CustomSettingsUtil.getACHParameters().loan__Originating_DFI_Identification__c!= null){
                banksRoutingNo =loan.StringUtils.leftPadString(''+loan.CustomSettingsUtil.getACHParameters().loan__Originating_DFI_Identification__c ,8,'0');
            }else{
                banksRoutingNo = String.valueOf(bank.loan__Routing_Number__c);
            }
            if(banksRoutingNo.length()<9){
                banksRoutingNo=loan.StringUtils.leftPadString(''+banksRoutingNo ,9,'0');
            }
            originatingDFIIdentification = banksRoutingNo;
        }

        bCR.filegen__Company_Identification__c = companyIdentification;

        bCR.filegen__Originating_DFI_Identification__c = originatingDFIIdentification;
        bCR.filegen__Batch_Number__c = '0000123';
        return bCR;
    }

    //File Control
    private filegen__File_Control_Record__c generateFileControlRecord(LIST<SObject> scope){
        filegen__File_Control_Record__c fCR = new filegen__File_Control_Record__c();

        linecount = getValidScope().size()+4;
        blocks = math.ceil((double.valueOf(linecount))/10);
        fCR.filegen__Batch_Count__c = '000001';
        fCR.filegen__Block_Count__c = String.valueOf(Integer.valueOf(blocks));
        fCR.filegen__Entry_Addenda_Count__c = String.valueOf(getValidScope().size());
        fCR.filegen__Entry_Hash__c = String.valueOf(routingHash);
        fCR.filegen__Total_Credit_Entry_Dollar_Amount_in_Fi__c = String.valueOf(Integer.valueOf(creditTotal.setScale(2)*100));
        return fCR;
    }

    String rightPadString(String str, Integer size, String padString) {
        if (str == null) {
            return null;
        }
        Integer len = str.length();

        if(len>size){
            //If string length is greater than 'size', truncate
            return str.mid(0,size);
        }
        return str.rightPad(size,padString);
    }
}