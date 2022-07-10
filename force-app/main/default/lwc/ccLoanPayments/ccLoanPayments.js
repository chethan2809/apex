import { LightningElement, wire, api } from 'lwc';
import getPaymentsList from '@salesforce/apex/CollectionCaseDB.getCLLoanPayments';
import getCollectionCaseDetails from '@salesforce/apex/CollectionCaseDB.getCollectionCaseDetails';
import getAllPaymentTypes from '@salesforce/apex/CollectionCaseDB.getAllPaymentTypes';
import getTotalCount from '@salesforce/apex/CollectionCaseDB.getTotalCount';
import PAYMENT_TYPE from '@salesforce/schema/loan__Loan_Payment_Transaction__c.loan__Payment_Type__c';
import { getPaymentColumns } from 'c/ccDataTableConfig';

export default class CcLoanPayments extends LightningElement {
    @api recordId;
    columns = getPaymentColumns();
    rowLimit = 10;
    rowOffSet = 0;
    error;
    collectionList;
    paymentsList = [];
    clContractId;
    totalRows = 0;
    tblName = 'loan__Loan_Payment_Transaction__c';
    whereClauseFieldName = 'loan__Loan_Account__c';
    loadMoreStatus;
    enableInfiniteLoading = true;
    sortBy;
    sortDirection;
    defaultRecordTypeId;
    paymentTypes;
    accordianSection = '';
    accordianTitle = 'Show Filters'
    paymentSatisfied = true;
    selectedPaymentType = '';
    transactionAmount = 0.00;
    startDate = null;
    endDate = null;
    validationErrorMessage = '';
    disableApplyButton=true;
    filters = '';
    isApplyFilter = false;
    recordsDisplayStatus = '';

    @wire(getAllPaymentTypes)
    getPaymentType({error, data}){
        if(data){
            let options = [];
            options.push({ label: '--None--', value: '--None--' });
            for(let key in data){
                options.push({ label: data[key], value: data[key] });
            }
            this.paymentTypes = options;
        }else if(error){
            this.error = JSON.stringify(error);
        }
    };

    @wire(getCollectionCaseDetails, {collectionCaseId: '$recordId'})
    wiredContract({
        error,
        data
    }) {
        if (data) {
            this.collectionList = data;
            this.clContractId = this.collectionList[0].CL_Contract_Id__c;
            if(this.clContractId){
                this.getPaymentRecords();
                this.getTotalRecordCount();
            }
        } else if (error) {
            this.error = error;
        }
    }

    getPaymentRecords() {
        if(this.isApplyFilter){
            this.rowLimit = 10;
            this.rowOffSet = 0;
        }

        return getPaymentsList({ loanAccountId: this.clContractId, limitSize: this.rowLimit, offset: this.rowOffSet, filters: this.filters })
            .then(result => {
                if(this.isApplyFilter){
                    this.paymentsList = result;
                    this.isApplyFilter = false;
                } else{
                    let updatedRecords = [...this.paymentsList, ...result];
                    this.paymentsList = updatedRecords;
                }

                if(this.paymentsList.length == 0){
                    this.loadMoreStatus = 'No records to display';
                } else {
                    this.loadMoreStatus = '';
                }

                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.paymentsList = undefined;
            });
    }

    getTotalRecordCount() {
        return getTotalCount({ genericId: this.clContractId, tblName: this.tblName, whereClauseFieldName: this.whereClauseFieldName })
        .then(result => {
            this.totalRows = result;
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.totalRows = 0;
        });
    }

    loadMoreData(event) {
        const { target } = event;
        if(this.rowOffSet < this.totalRows){
            target.isLoading = true;
            this.loadMoreStatus = '';
            this.rowOffSet = this.rowOffSet + this.rowLimit;
            this.enableInfiniteLoading = true;
            this.getPaymentRecords()
                .then(()=> {
                    target.isLoading = false;
                });
        } else {
            target.isLoading = false;
            this.loadMoreStatus = 'No more data to load';
            this.enableInfiniteLoading = false;
        }
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.paymentsList));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.paymentsList = parseData;
    }

    handleClick(event){
        this.paymentSatisfied = event.target.checked;
        this.enableDisableApplyButton();
    }

    handlePaymentTypeChange(event){
        if(event.target.value == '--None--'){
            this.selectedPaymentType = '';
        }else{
            this.selectedPaymentType = event.target.value;
        }

        this.enableDisableApplyButton();
    }

    handleDateChange(event){
        if(event.target.name == 'startDate'){
            this.startDate = event.target.value;
            this.template.querySelector('lightning-input[data-name="endDate"]').value = this.startDate;
            this.endDate = this.startDate;
        } else if(event.target.name == 'endDate'){
            this.endDate = event.target.value;
        }

        const endDateElement = this.template.querySelector('lightning-input[data-name="endDate"]');
        const validationDiv = this.template.querySelector('[data-name="validation-div"]');
        if(this.endDate < this.startDate){
            endDateElement.classList.add('invalid');
            endDateElement.classList.remove('slds-is-open');
            this.validationErrorMessage = 'Payment End Date cannot be greater than Payment Start Date!';
            validationDiv.classList.remove('slds-hide');
            this.disableApplyButton = true;
        } else {
            endDateElement.classList.remove('invalid');
            validationDiv.classList.add('slds-hide');
            this.validationErrorMessage = '';
            this.enableDisableApplyButton();
        }
    }

    handleAmountChange(event){
        this.transactionAmount = event.target.value;
        this.enableDisableApplyButton();
    }

    handleApplyClick(event){
        this.filters = '';
        const validationDiv = this.template.querySelector('[data-name="validation-div"]');
        if(this.startDate == '' && this.endDate == '' && this.paymentSatisfied == undefined
        && this.selectedPaymentType == '' && this.transactionAmount == 0){
            this.disableApplyButton = true;
            this.validationErrorMessage = 'Atleast one filter field value required to apply the filter';
            validationDiv.classList.remove('slds-hide');
        }else{
            this.disableApplyButton = false;
            this.validationErrorMessage = '';
            validationDiv.classList.add('slds-hide');
            this.generatingFilters();
            if(this.filters != ''){
                this.isApplyFilter = true;
                this.getPaymentRecords();
            }
        }
    }

    handleClearClick(){
        this.isApplyFilter = false;
        this.filters = '';
        this.paymentsList = [];
        this.loadMoreStatus = '';
        this.paymentSatisfied = true;
        this.template.querySelector('lightning-input[data-name="startDate"]').value = '';
        this.template.querySelector('lightning-input[data-name="endDate"]').value = '';
        this.template.querySelector('lightning-input[data-name="paymentSatisfied"]').checked = true;
        this.template.querySelector('lightning-combobox[data-name="paymentType"]').value = '';
        this.template.querySelector('lightning-input[data-name="transactionAmount"]').value = '';
        this.rowLimit = 10;
        this.rowOffSet = 0;
        this.selectedPaymentType = '';
        this.transactionAmount = 0.00;
        this.startDate = null;
        this.endDate = null;
        const validationDiv = this.template.querySelector('[data-name="validation-div"]');
        validationDiv.classList.add('slds-hide');
        this.validationErrorMessage = '';
        const endDateElement = this.template.querySelector('lightning-input[data-name="endDate"]');
        endDateElement.classList.remove('invalid');
        this.enableDisableApplyButton();
        this.template.querySelectorAll('lightning-input').forEach(element => {
            element.reportValidity();
            element.setCustomValidity('');
        });
        this.getPaymentRecords();
    }

    handleToggleSection(event) {
        if(event.detail.openSections == ''){
            this.accordianTitle = 'Show Filters';
            this.accordianSection ='';
        }else{
            this.accordianSection ='Filters';
            this.accordianTitle = 'Hide Filters';
        }
    }

    enableDisableApplyButton(){
        if(this.startDate == null && this.endDate == null && this.paymentSatisfied == undefined
        && this.selectedPaymentType == '' && this.transactionAmount == 0){
            this.disableApplyButton = true;
        } else{
            this.disableApplyButton = false;
        }
    }

    generatingFilters(){
        if(this.startDate != null && this.endDate != null){
            this.filters = ' AND loan__Transaction_Date__c >=' + this.startDate + ' AND loan__Transaction_Date__c <=' + this.endDate +'';
        }

        if(this.startDate != null && this.endDate == null){
            this.filters = ' AND loan__Transaction_Date__c >=' + this.startDate;
        }

        if(this.endDate != null && this.startDate == null){
            this.filters = ' AND loan__Transaction_Date__c <=' + this.endDate;
        }

        if(this.paymentSatisfied != undefined){
            if(this.filters != ''){
                this.filters = this.filters + ' AND loan__Cleared__c = '+ this.paymentSatisfied;
            } else{
                this.filters = ' AND loan__Cleared__c = '+ this.paymentSatisfied;
            }
        }

        if(this.selectedPaymentType != ''){
            if(this.filters != ''){
                this.filters = this.filters + ' AND loan__Payment_Type__c = \''+ this.selectedPaymentType + '\'';
            } else{
                this.filters = ' AND loan__Payment_Type__c = \''+ this.paymentSatselectedPaymentTypeisfied + '\'';
            }
        }

        if(this.transactionAmount != 0){
            if(this.filters != ''){
                this.filters = this.filters + ' AND loan__Transaction_Amount__c >= '+ this.transactionAmount;
            } else{
                this.filters = ' AND loan__Transaction_Amount__c >= '+ this.transactionAmount;
            }
        }
    }
}