global class LoanPaymentTxnNACHAGenWF extends loan.FileGenerator {

    private loan__Bank_Account__c bank;
    Long routingHash = 0;
    Integer linecount = 0;
    Double blocks = 0.0;
    //Decimal creditTotal = 0;
    Decimal debitTotal = 0;
    Map<id,loan__Loan_Payment_Transaction__c> pmtsMap = new Map<id,loan__Loan_Payment_Transaction__c>();
    private static String[] abc = new String[] {'A','B','C','D','E','F','G','H','I','J','K',
                                    'L','M','N','O','P','Q','R','S','T','U','V',
                                    'W','X','Y','Z'};
    String pMode = 'ACH';
    loan__Automated_Payment_Configuration__c autoPmtConfig = new loan__Automated_Payment_Configuration__c();

    @TestVisible
    private List<loan__Loan_Payment_Transaction__c> requeryScope(List<SObject> scope) {
        Set<ID> ids = new Set<ID>();
        for (SObject s : scope) {
            ids.add(s.Id);
        }

        List<loan__Loan_Payment_Transaction__c> loanPmts = [SELECT Id,
                                                            Name,
                                                            loan__Transaction_Amount__c,
                                                            loan__Loan_Account__c,
                                                            loan__Loan_Account__r.loan__ACH_Bank__c,
                                                            loan__Loan_Account__r.loan__ACH_Bank__r.Name,
                                                            loan__Loan_Account__r.loan__ACH_Bank__r.loan__ACH_Code__c,
                                                            loan__Loan_Account__r.loan__ACH_Bank__r.loan__Routing_Number__c,
                                                            loan__Payment_Mode__r.Name
                                                      FROM loan__Loan_Payment_Transaction__c
                                                      WHERE Id in:ids
                                                     ];

        try {
            if(loan.CustomSettingsUtil.getACHParameters().loan__Multiple_Payment_Method_Support__c == true) {
                if(loanPmts.size() > 0) {
                    if(loanPmts[0].loan__Payment_Mode__r.Name != null) {
                        pMode = loanPmts[0].loan__Payment_Mode__r.Name;
                    }
                }

                autoPmtConfig = [SELECT Id,
                                        loan__Immediate_Destination__c,
                                        loan__Company_Identification__c,
                                        loan__Originating_DFI_Identification__c,
                                        loan__Immediate_Destination_Name__c,
                                        loan__Immediate_Origin__c,
                                        loan__Immediate_Origin_Name__c,
                                        loan__Reference_Code__c,
                                        loan__Trace_Number_Prefix__c,
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
                                     AND loan__Bank_Account__r.loan__Account_usage__c INCLUDES (:loan.FractionalizationConstants.COLLECTIONS_TRUST_ACCOUNT)
                                     AND loan__Bank_account__r.loan__Active__c = true
                                     AND loan__Payment_Mode__r.Name = :pMode
                                     AND loan__Event__c INCLUDES (:loan.LoanConstants.LOAN_PAYMENT)
                                 LIMIT 1
                                ];
            }
            else {
                bank = [SELECT Id,
                               Name,
                               loan__Bank_Account_Number__c,
                               loan__Account__c,
                               loan__Account__r.Name,
                               loan__Account_Type__c,
                               loan__Account_Usage__c,
                               loan__Bank_Name__c,
                               loan__ACH_Code__c,
                               loan__Contact__c,
                               loan__Contact__r.Name,
                               loan__Routing_Number__c
                        FROM loan__Bank_Account__c
                        WHERE loan__Account_Usage__c INCLUDES (:loan.FractionalizationConstants.COLLECTIONS_TRUST_ACCOUNT)
                            AND loan__Active__c = true
                        LIMIT 1
                       ];
            }
        }
        catch(Exception e) {
            throw new peer.MarketplaceException('Collections Trust Account Is not available');
        }

        for(loan__Loan_Payment_Transaction__c pmt : loanPmts) {
            pmtsMap.put(pmt.id,pmt);
        }

        List<loan__Loan_Payment_Transaction__c> payments = [Select Id,Name,
                                                            loan__Transaction_Amount__c,
                                                            loan__Loan_Account__c,
                                                            Loan__loan_account__r.Name,
                                                            Loan__loan_account__r.loan__ACH_Relationship_Type__c,
                                                            Loan__loan_account__r.loan__Borrower_ACH__c,
                                                            Loan__loan_account__r.loan__Borrower_ACH__r.loan__Account__c,
                                                            Loan__loan_account__r.loan__Borrower_ACH__r.loan__Account_Type__c,
                                                            Loan__loan_account__r.loan__Borrower_ACH__r.loan__Account_Usage__c,
                                                            Loan__loan_account__r.loan__Borrower_ACH__r.loan__Active__c,
                                                            Loan__loan_account__r.loan__Borrower_ACH__r.loan__Bank_Account_Number__c,
                                                            Loan__loan_account__r.loan__Borrower_ACH__r.loan__Bank_Name__c,
                                                            Loan__loan_account__r.loan__Borrower_ACH__r.loan__Contact__c,
                                                            Loan__loan_account__r.loan__Borrower_ACH__r.loan__Routing_Number__c,
                                                            loan__Automated_Payment_Setup__c,
                                                            Loan__autoMated_paYment_Setup__r.loan__Bank_Account__r.Name,
                                                            Loan__autoMated_paYment_Setup__r.loan__Bank_Account__r.loan__ACH_Code__c,
                                                            Loan__autoMated_paYment_Setup__r.loan__Bank_Account__r.loan__Routing_Number__c,
                                                            Loan__autoMated_paYment_Setup__r.loan__Bank_Account__r.loan__Account__c,
                                                            Loan__autoMated_paYment_Setup__r.loan__Bank_Account__r.loan__Account_Type__c,
                                                            Loan__autoMated_paYment_Setup__r.loan__Bank_Account__r.loan__Account_Usage__c,
                                                            Loan__autoMated_paYment_Setup__r.loan__Bank_Account__r.loan__Active__c,
                                                            Loan__autoMated_paYment_Setup__r.loan__Bank_Account__r.loan__Bank_Account_Number__c,
                                                            Loan__autoMated_paYment_Setup__r.loan__Bank_Account__r.loan__Bank_name__c,
                                                            Loan__autoMated_paYment_Setup__r.loan__Bank_Account__r.loan__Contact__c,
                                                            Loan__loan_account__r.loan__Loan_Amount__c,
                                                            Loan__loan_account__r.loan__Account__c,
                                                            Loan__loan_account__r.loan__Account__r.Name,
                                                            Loan__loan_account__r.loan__Contact__c,
                                                            Loan__loan_account__r.loan__Contact__r.Name,
                                                            Loan__loan_account__r.loan__ACH_On__c,
                                                            Loan__loan_account__r.loan__ACH_Debit_Amount__c,
                                                            Loan__loan_account__r.loan__Ach_Debit_Day__c,
                                                            Loan__loan_account__r.loan__ACH_Drawer_Name__c,
                                                            Loan__loan_account__r.loan__ACH_End_Date__c,
                                                            Loan__loan_account__r.loan__ACH_Frequency__c,
                                                            Loan__loan_account__r.loan__ACH_Frequency_Cycle__c,
                                                            Loan__loan_account__r.loan__ACH_Next_Debit_Date__c,
                                                            Loan__loan_account__r.loan__ACH_Start_Date__c,
                                                            Loan__loan_account__r.loan__OT_ACH_Debit_Date__c,
                                                            Loan__loan_account__r.loan__OT_ACH_Drawer_Address1__c,
                                                            Loan__loan_account__r.loan__OT_ACH_Drawer_Address2__c,
                                                            Loan__loan_account__r.loan__OT_ACH_Drawer_City__c,
                                                            Loan__loan_account__r.loan__OT_ACH_Drawer_Name__c,
                                                            Loan__loan_account__r.loan__OT_ACH_Drawer_State__c,
                                                            Loan__loan_account__r.loan__OT_ACH_Drawer_Zip__c,
                                                            Loan__loan_account__r.loan__OT_ACH_Fee_Amount__c,
                                                            Loan__loan_account__r.loan__OT_ACH_Payment_Amount__c,
                                                            Loan__loan_account__r.loan__OT_ACH_Relationship_Type__c,
                                                            Loan__loan_account__r.loan__OT_Borrower_ACH__c,
                                                            Loan__loan_account__r.loan__OT_Borrower_ACH__r.loan__Account__c,
                                                            Loan__loan_account__r.loan__OT_Borrower_ACH__r.loan__Account_Type__c,
                                                            Loan__loan_account__r.loan__OT_Borrower_ACH__r.loan__Account_Usage__c,
                                                            Loan__loan_account__r.loan__OT_Borrower_ACH__r.loan__Active__c,
                                                            Loan__loan_account__r.loan__OT_Borrower_ACH__r.loan__Bank_Account_Number__c,
                                                            Loan__loan_account__r.loan__OT_Borrower_ACH__r.loan__Bank_Name__c,
                                                            Loan__loan_account__r.loan__OT_Borrower_ACH__r.loan__Contact__c,
                                                            Loan__loan_account__r.loan__OT_Borrower_ACH__r.loan__Routing_Number__c
                                                    From loan__Loan_Payment_Transaction__c
                                                    WHERE ID in :ids
                                                    ORDER BY Name ASC];

        return payments;
    }

    global override String getSimpleFileName() {
        if(loan.CustomSettingsUtil.getACHParameters().loan__Multiple_Payment_Method_Support__c == true) {
            return 'Loan_Payments_' + pMode;
        }
        return 'Loan_Payments';
    }

    global override List<String> getEntries(loan.TransactionSweepToACHState state, List<SObject> scope) {
        List<String> retVal = new List<String>();
        List<loan__Loan_Payment_Transaction__c> pmts = requeryScope(scope);
        List<SObject> objects = new List<SObject>();

        for(loan__Loan_Payment_Transaction__c pmt : pmts) {
            if(loan.CustomSettingsUtil.getACHParameters().loan__Multiple_Payment_Method_Support__c == true) {
                if(pmt.loan__Automated_Payment_Setup__c==null
                    || pmt.loan__Automated_payment_Setup__r.loan__Bank_Account__r.loan__Routing_Number__c == null
                    || pmt.loan__Automated_Payment_Setup__r.loan__Bank_Account__r.loan__Bank_Account_Number__c == null) {

                    addToInvalidScope(pmtsMap.get(pmt.id),'Payment Setup or Borrower Ach routing no, ACH Account number is missing');
                }
                else {
                    addToValidScope(pmtsMap.get(pmt.id));
                    objects.add(generateEntryDetailRecord(pmt.loan__Loan_Account__r,pmt));
                }
            }
            else {
                if(pmt.loan__Loan_Account__r.loan__ACH_On__c == true) {
                    if(pmt.loan__Loan_Account__r.loan__Borrower_ACH__r.loan__Routing_Number__c == null
                        || pmt.loan__Loan_Account__r.loan__Borrower_ACH__r.loan__Bank_Account_Number__c == null) {

                        addToInvalidScope(pmtsMap.get(pmt.id),'Borrower Ach routing no, Loan account ACH Account number is missing');
                    }
                    else {
                        addToValidScope(pmtsMap.get(pmt.id));
                        objects.add(generateEntryDetailRecord(pmt.loan__Loan_Account__r,pmt));
                    }
                }
                else {
                    if(pmt.loan__Loan_Account__r.loan__OT_Borrower_ACH__r.loan__Routing_Number__c == null
                        || pmt.loan__Loan_Account__r.loan__OT_Borrower_ACH__r.loan__Bank_Account_Number__c == null) {

                        addToInvalidScope(pmtsMap.get(pmt.id),'One time Borrower Ach routing no,one time Loan account ACH Account number is missing');
                    }
                    else {
                        addToValidScope(pmtsMap.get(pmt.id));
                        objects.add(generateEntryDetailRecord(pmt.loan__Loan_Account__r,pmt));
                    }
                }
            }
        }

        filegen.CreateSegments segments = new filegen.CreateSegments(objects);
        retVal = segments.retString();
        for(String line : retVal) {
            line = line+'\n';
            addEntry(line);
        }

        return retVal;
    }

    global override String getHeader(loan.TransactionSweepToACHState state, List<SObject> scope) {

        String header = '';
        List<String> retVal = new List<String>();
        List<SObject> headerRecs = new List<SObject>();

        if(getValidScope().size() > 0) {
            headerRecs.add(generateFileHeaderRecord(state));
            headerRecs.add(generateBatchHeaderRecord());
            filegen.CreateSegments segments = new filegen.CreateSegments(headerRecs);
            retVal = segments.retString();

            header = retVal[0] + '\r\n';
            header += retVal[1] + '\r\n';
        }

        return header;
    }

    global override String getTrailer(loan.TransactionSweepToACHState state, LIST<SObject> scope) {

        String achFileTrailerContent = '';
        List<String> retVal = new List<String>();
        List<SObject> trailerRecs = new List<SObject>();
        if(getValidScope().size() > 0) {
            trailerRecs.add(generateBatchControlRecord(scope));
            trailerRecs.add(generateFileControlRecord(scope));
            filegen.CreateSegments segments = new filegen.CreateSegments(trailerRecs);
            retVal = segments.retString();

            for(String s : retVal) {
                achFileTrailerContent = achFileTrailerContent + s + '\r\n';
            }

            Integer fillersToAdd = Integer.valueOf(blocks * 10) - linecount;
            achFileTrailerContent = achFileTrailerContent.subString(0, achFileTrailerContent.length() - 2);

            //fillers are added to make number of characters in generated file multiple of 940
            for(Integer i = 0; i < fillersToAdd; i++) {
                achFileTrailerContent = achFileTrailerContent + '\r\n'+ rightPadString('', 94, '9');
            }
            achFileTrailerContent = achFileTrailerContent + '\r\n';
        }

        return achFileTrailerContent;
    }

    //File header

    private filegen__File_Header_Record__c generateFileHeaderRecord(loan.TransactionSweepToACHState state) {
        Date systemDate = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
        Datetime calendarDateTime = Datetime.now();
        Datetime currentSystemDateTime = Datetime.newInstance(systemDate.year(),
                                                                systemDate.month(),
                                                                systemDate.day(),
                                                                calendarDateTime.hour(),
                                                                calendarDateTime.minute(),
                                                                calendarDateTime.second());
        //get System Date Time.
        Date csd = Date.newInstance(currentSystemDateTime.year(), currentSystemDateTime.month(), currentSystemDateTime.day());

        String hour = (currentSystemDateTime.hour() >= 10 ? String.valueOf(currentSystemDateTime.hour()) : '0' + currentSystemDateTime.hour());
        String minute = (currentSystemDateTime.minute() >= 10 ? String.valueOf(currentSystemDateTime.minute()) : '0' + currentSystemDateTime.minute());
        String myTime = hour + minute;

        filegen__File_Header_Record__c fHR = new filegen__File_Header_Record__c();
        String immediateDestination = '';
        String immediateOrigin = '';
        Integer counter= 0;
        String immediateDestinationName = '';
        String referenceCode = '';
        String immediateOriginName = '';
        Map<String,Integer> countMap = (Map<String,Integer>)state.o2;

        if(loan.CustomSettingsUtil.getACHParameters().loan__Multiple_Payment_Method_Support__c == true) {
            if(autoPmtConfig.loan__Immediate_Destination__c != null) {
                immediateDestination = Loan.sTringUtils.leftPadString('' + autoPmtConfig.loan__Immediate_Destination__c, 9, '0');
            }

            if(autoPmtConfig.loan__Immediate_origin__c != null) {
                immediateOrigin = autoPmtConfig.loan__Immediate_origin__c;
            }

            if(countMap.get(pMode) == null) {
                countMap.put(pMode,0);
                state.o2 = countMap;
            }
            counter =countMap.get(pMode);
            if(autoPmtConfig.loan__Immediate_Destination_Name__c != null) {
                immediateDestinationName = autoPmtConfig.loan__Immediate_Destination_Name__c ;
            }

            if(autoPmtConfig.loan__Immediate_Origin_Name__c != null) {
                immediateOriginName = autoPmtConfig.loan__Immediate_Origin_Name__c;
            }

            if(autoPmtConfig.loan__Reference_Code__c != null) {
                referenceCode = autoPmtConfig.loan__Reference_Code__c;
            }
        }
        else {
            if(loan.CustomSettingsUtil.getACHParameters().loan__Immediate_Destination__c != null) {
                immediateDestination = Loan.sTringUtils.leftPadString('' + loan.CustomSettingsUtil.getACHParameters().loan__Immediate_Destination__c, 9, '0');
            }
            else {
                immediateDestination = String.valueOf(bank.loan__Routing_Number__c);
                if(immediateDestination.length() < 9) {
                    immediateDestination = Loan.sTringUtils.leftPadString('' + bank.loan__Routing_Number__c, 9, '0');
                }
            }
            immediateorigin = (loan.CustomSettingsUtil.getACHParameters().loan__Fed_Tax_Id__c != null ? loan.CustomSettingsUtil.getACHParameters().loan__Fed_Tax_Id__c : '');
            counter = state.counter;

            if(bank != null && bank.loan__Bank_Name__c != null) {
                immediateDestinationName = bank.loan__Bank_Name__c;
            }
            else {
                immediateDestinationName = '';
            }

            immediateOriginName = loan.CustomSettingsUtil.getACHParameters().loan__Organization_Name__c;
            referenceCode = loan.CustomSettingsUtil.getACHParameters().loan__ACH_Id__c;
        }

        fHR.filegen__Immediate_Destination__c = immediateDestination;
        fHR.filegen__Immediate_Origin__c = immediateOrigin;
        fHR.filegen__Creation_Date__c = csd;
        fHR.filegen__Creation_Time__c = myTime;
        fHR.filegen__ID_Modifier__c = abc[counter];
        fHR.filegen__Immediate_Destination_Name__c = immediateDestinationName;
        fHR.filegen__Immediate_Origin_Name__c = immediateOriginName;
        fHR.filegen__Reference_Code__c = referenceCode;

        return fHR;
    }

     //Batch Header
    private filegen__Batch_Header_Record__c generateBatchHeaderRecord() {
        Date systemDate = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
        Datetime calendarDateTime = Datetime.now();
        Datetime currentSystemDateTime = Datetime.newInstance(systemDate.year(),
                                                                systemDate.month(),
                                                                systemDate.day(),
                                                                calendarDateTime.hour(),
                                                                calendarDateTime.minute(),
                                                                calendarDateTime.second());

        //get System Date Time.
        Date csd = Date.newInstance(currentSystemDateTime.year(), currentSystemDateTime.month(), currentSystemDateTime.day());

        //Date to be appeared in File header
        Date advanceDebitDate;

        //If Payment is getting debited on Previous day
        Integer daysInAdvanceToCreateFile = (Integer)loan.CustomSettingsUtil.getACHParameters().loan__Days_In_Advance_To_Create_File__c;
        if (daysInAdvanceToCreateFile == null) {
            daysInAdvanceToCreateFile = 0;
        }
        if(loan.CustomSettingsUtil.getACHParameters().loan__Debit_Payment_on_Previous_Working_Day__c) {
            advanceDebitDate = loan.HolidayUtil.INSTANCE.getNextWorkingDate(csd.addDays(daysInAdvanceToCreateFile));
        } else {
            advanceDebitDate = csd.addDays(daysInAdvanceToCreateFile);
        }

        filegen__Batch_Header_Record__c bHR = new filegen__Batch_Header_Record__c();
        String companyName = '';
        String companyIdentification = '';
        String originatingDFIIdentification = '';

        if(loan.CustomSettingsUtil.getACHParameters().loan__Multiple_Payment_Method_Support__c == true) {
            companyName = loan.CustomSettingsUtil.getACHParameters().loan__Organization_Name__c;

            if(autoPmtConfig.loan__Company_Identification__c != null) {
                companyIdentification = autoPmtConfig.loan__Company_Identification__c;
            }

            if(autoPmtConfig.loan__Originating_DFI_Identification__c != null) {
                originatingDFIIdentification = Loan.sTringUtils.leftPadString('' + autoPmtConfig.loan__Originating_DFI_Identification__c, 8, '0');
            }
        } else {
            companyName = loan.CustomSettingsUtil.getACHParameters().loan__Organization_Name__c;
            if(bank !=null && bank.loan__ACH_Code__c != null) {
                companyIdentification = bank.loan__ACH_Code__c;
            }
            else {
                companyIdentification = '';
            }

            String banksRoutingNo ='';
            if(loan.CustomSettingsUtil.getACHParameters().loan__Originating_DFI_Identification__c != null) {
                banksRoutingNo = Loan.sTringUtils.leftPadString('' + loan.CustomSettingsUtil.getACHParameters().loan__Originating_DFI_Identification__c, 8, '0');
            }
            else {
                banksRoutingNo = String.valueOf(bank.loan__Routing_Number__c);
            }

            if(banksRoutingNo.length() < 9) {
                banksRoutingNo=Loan.sTringUtils.leftPadString('' + banksRoutingNo, 9, '0');
            }
            originatingDFIIdentification = banksRoutingNo;
        }
        bHR.filegen__Service_Class_Code__c = '200';
        bHR.filegen__Company_Name__c = companyName;
        bHR.filegen__Company_Discretionary_Data__c = 'ACH_PAYMENTS';
        bHR.filegen__Company_Identification__c = companyIdentification;
        bHR.filegen__SEC_Code__c = 'CCD';
        bHR.filegen__Company_Entry_Description__c = 'PAYMENT';
        bHR.filegen__Company_Descriptive_Date__c = advanceDebitDate;
        bHR.filegen__Effective_Entry_Date__c = advanceDebitDate;
        bHR.filegen__Originating_DFI_Identification__c = originatingDFIIdentification;
        bHR.filegen__Batch_Number__c = '0000123';

        return bHR;
    }

    //Batch Control
    private filegen__Batch_Control_Record__c generateBatchControlRecord(LIST<SObject> scope) {
        filegen__Batch_Control_Record__c bCR = new filegen__Batch_Control_Record__c();

        bCR.filegen__Service_Class_Code__c = '200';
        bCR.filegen__Entry_Addenda_Count__c = String.valueOf(getValidScope().size());
        bCR.filegen__Entry_Hash__c = String.valueOf(routingHash);
        bCR.filegen__Total_Debit_Entry_Dollar_Amount__c = String.valueOf(Integer.valueOf(debitTotal.setScale(2)*100));
        String companyIdentification = '';
        String originatingDFIIdentification = '';

        if(loan.CustomSettingsUtil.getACHParameters().loan__Multiple_Payment_Method_Support__c == true) {
            if(autoPmtConfig.loan__company_identification__c != null) {
                companyIdentification = autoPmtConfig.loan__Company_Identification__c;
            }

            if(autoPmtConfig.loan__originating_DFI_Identification__c != null) {
                originatingDFIIdentification = Loan.sTringUtils.leftPadString('' + autoPmtConfig.loan__Originating_DFI_Identification__c, 8, '0');
            }
        }else {
            throw new peer.MarketplaceException('Multiple Payment Method Support is disabled. Contact CL Support.');
        }

        bCR.filegen__Company_Identification__c = companyIdentification;
        bCR.filegen__Originating_DFI_Identification__c = originatingDFIIdentification;
        bCR.filegen__Batch_Number__c = '0000123';
        return bCR;
    }

    //File Control
    private filegen__File_Control_Record__c generateFileControlRecord(LIST<SObject> scope) {
        filegen__File_Control_Record__c fCR = new filegen__File_Control_Record__c();

        linecount = getValidScope().size() + 4;
        blocks = math.ceil((double.valueOf(linecount))/10);
        fCR.filegen__Batch_Count__c = '000001';
        fCR.filegen__Block_Count__c = String.valueOf(Integer.valueOf(blocks));
        fCR.filegen__Entry_Addenda_Count__c = String.valueOf(getValidScope().size());
        fCR.filegen__Entry_Hash__c = String.valueOf(routingHash);
        fCR.filegen__total_debit_entry_dollar_amount_in_fil__c = String.valueOf(Integer.valueOf(debitTotal.setScale(2)*100));

        return fCR;
    }

    //Entry Detail
    private filegen__Entry_Detail_Record__c generateEntryDetailRecord(loan__Loan_Account__c loanAccount,loan__Loan_Payment_Transaction__c pmt) {
        filegen__Entry_Detail_Record__c eDR = new filegen__Entry_Detail_Record__c();
        String transactionCode = '';
        String customerName = '';
        String customerRoutingNumber = '';
        String checkDigit = '';
        Integer routingHashNo = 0;
        String tracePrefix = '';
        String traceNum = '';
        String rDFIAccountNumber = '';

        if(loan.CustomSettingsUtil.getACHParameters().loan__Multiple_Payment_Method_Support__c == true) {
            if(loan.LoanConstants.ACCOUNT_TYPE_SAVING.equalsIgnoreCase(pmt.loan__Automated_Payment_Setup__r.loan__Bank_Account__r.loan__Account_Type__c)
                || loan.LoanConstants.ACCOUNT_TYPE_SAVINGS.equalsIgnoreCase(pmt.loan__Automated_Payment_Setup__r.loan__Bank_Account__r.loan__Account_Type__c)) {
                transactionCode = '37';
            }
            else if(loan.LoanConstants.ACCOUNT_TYPE_CHECKING.equalsIgnoreCase(pmt.loan__Automated_Payment_Setup__r.loan__Bank_Account__r.loan__Account_Type__c)) {
                transactionCode = '27';
            }

            if(pmt.loan__Automated_Payment_Setup__r.loan__Bank_Account__c != null
                && pmt.loan__Automated_Payment_Setup__r.loan__Bank_Account__r.loan__Routing_Number__c != null) {
                customerRoutingNumber = pmt.loan__Automated_Payment_Setup__r.loan__Bank_Account__r.loan__Routing_Number__c;

                if(pmt.loan__Automated_Payment_Setup__r.loan__Bank_Account__r.loan__Routing_Number__c.length() > 8) {
                    checkDigit = pmt.loan__Automated_Payment_Setup__r.loan__Bank_Account__r.loan__Routing_Number__c.subString(8);
                    routingHashNo = Double.valueOf(pmt.loan__Automated_Payment_Setup__r.loan__Bank_Account__r.loan__Routing_Number__c.subString(0,8)).intValue();
                }
            }
            if(loanAccount.loan__Account__c != null) {
                customerName = loanAccount.loan__Account__r.Name;
            }
            else if(loanAccount.loan__Contact__c != null) {
                customerName = loanAccount.loan__Contact__r.Name;
            }

            if(pmt.loan__Automated_Payment_Setup__r.loan__Bank_Account__r.loan__Bank_Account_Number__c != null) {
                rDFIAccountNumber = pmt.loan__Automated_Payment_Setup__r.loan__Bank_Account__r.loan__Bank_Account_Number__c;
            }

            if( autoPmtConfig.loan__Trace_Number_Prefix__c != null) {
                tracePrefix = autoPmtConfig.loan__Trace_Number_Prefix__c;
                traceNum = String.valueOf( tracePrefix + pmt.Name.right(7) );
            }
            else {
                traceNum = Loan.sTringUtils.leftPadString((pmt.Name.subString(7)),15, '0');
            }
        }
        else {
            throw new peer.MarketplaceException('Multiple Payment Method Support is disabled. Contact CL Support.');
        }

        if(customerRoutingNumber.length() < 9) {
            customerRoutingNumber = Loan.sTringUtils.leftPadString('' + customerRoutingNumber, 9, '0');
        }

        String customerLoanName = Loan.sTringUtils.rightPadString(loanAccount.Name.replace('-','0'),15, ' ');
        eDR.filegen__Individual_Identification_Number__c = customerLoanName;
        eDR.filegen__Individual_Name__c = customerName;
        eDR.filegen__Addenda_Record_Indicator__c='0';
        eDR.filegen__Trace_Number__c = traceNum;
        eDR.filegen__Transaction_Code__c = transactionCode;
        eDR.filegen__RDFI_Identification__c = customerRoutingNumber;
        eDR.filegen__Check_Digit__c = checkDigit;
        eDR.filegen__RDFI_Account_Number__c = rDFIAccountNumber;


        Decimal transactionAmount = 0;
        eDR.filegen__Amount__c = '';
        if(pmt.loan__Transaction_Amount__c != null) {
            transactionAmount = pmt.loan__Transaction_Amount__c.setScale(2);
            edr.filegen__Amount__c = String.valueOf(transactionAmount);
            debitTotal += transactionAmount;
        }

        routingHash = routingHash + routingHashNo;
        return eDR;
    }

    String rightPadString(String str, Integer size, String padString) {
        if (str == null) {
            return null;
        }

        Integer len = str.length();

        if(len > size) {
            //If string length is greater than 'size', truncate
            return str.mid(0,size);
        }

        return str.rightPad(size,padString);
    }
}