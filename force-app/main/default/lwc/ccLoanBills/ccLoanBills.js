import { LightningElement, wire, api } from 'lwc';
import getBillsList from '@salesforce/apex/CollectionCaseDB.getCLLoanBills';
import getCollectionCaseDetails from '@salesforce/apex/CollectionCaseDB.getCollectionCaseDetails';
import getTotalCount from '@salesforce/apex/CollectionCaseDB.getTotalCount';
import { getBillColumns } from 'c/ccDataTableConfig';

export default class CcLoanBills extends LightningElement {
    @api recordId;
    columns = getBillColumns();
    rowLimit = 10;
    rowOffSet = 0;
    error;
    collectionList;
    billsList = [];
    clContractId;
    totalRows = 0;
    tblName = 'loan__Loan_account_Due_Details__c';
    whereClauseFieldName = 'loan__Loan_Account__c';
    loadMoreStatus;
    enableInfiniteLoading = true;
    sortBy;
    sortDirection;
    accordianSection = '';
    accordianTitle = 'Show Filters'
    paymentSatisfied = undefined;
    selectedPaymentSatisfied = 'All';
    paymentAmount = null;
    dueAmount = null;
    startDate = null;
    endDate = null;
    validationErrorMessage = '';
    disableApplyButton = true;
    filters = '';
    isApplyFilter = false;
    isChanged = false;

    @wire(getCollectionCaseDetails, {collectionCaseId: '$recordId'})
    wiredContract({
        error,
        data
    }) {
        if (data) {
            this.collectionList = data;
            this.clContractId = this.collectionList[0].CL_Contract_Id__c;
            if(this.clContractId){
                this.getTotalRecordCount();
                this.getBillRecords();
            }
        } else if (error) {
            this.error = error;
        }
    }

    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
            { label: 'All', value: 'All' }
        ];
    }

    getBillRecords() {
        this.isChanged = !this.isChanged;
        return getBillsList({ loanAccountId: this.clContractId, limitSize: this.rowLimit, offset: this.rowOffSet, filters: this.filters, isChanged: this.isChanged })
            .then(result => {
                if(this.isApplyFilter){
                    this.billsList = result;
                    this.isApplyFilter = false;
                } else{
                    let updatedRecords = [...this.billsList, ...result];
                    this.billsList = updatedRecords;
                }

                if(this.billsList.length == 0){
                    this.loadMoreStatus = 'No records to display';
                } else {
                    this.loadMoreStatus = '';
                }
            })
            .catch(error => {
                this.error = error;
                this.billsList = undefined;
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
            this.getBillRecords()
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
        let parseData = JSON.parse(JSON.stringify(this.billsList));
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
        this.billsList = parseData;
    }

    /* handleClick(event){
        this.paymentSatisfied = event.target.checked;
        this.enableDisableApplyButton();
    } */

    handlePaymentSatisfiecChange(event){
        if(event.detail.value == 'Yes'){
            this.selectedPaymentSatisfied = 'Yes';
            this.paymentSatisfied = true;
        }
        else if(event.detail.value == 'No'){
            this.selectedPaymentSatisfied = 'No';
            this.paymentSatisfied = false;
        }
        else {
            this.selectedPaymentSatisfied = 'All';
            this.paymentSatisfied = undefined;
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
            this.validationErrorMessage = 'Due End Date cannot be greater than Due Start Date!';
            validationDiv.classList.remove('slds-hide');
            this.disableApplyButton = true;
        } else {
            endDateElement.classList.remove('invalid');
            validationDiv.classList.add('slds-hide');
            this.validationErrorMessage = '';
            this.enableDisableApplyButton();
        }
    }

    handlePaymentAmountChange(event){
        console.log('pmt Amt:'+event.target.value);
        if(event.target.value != null){
            this.paymentAmount = event.target.value;
        }
        this.enableDisableApplyButton();
    }

    handleDueAmountChange(event){
        this.dueAmount = event.target.value;
        this.enableDisableApplyButton();
    }

    handleApplyClick(event){
        this.filters = '';
        const validationDiv = this.template.querySelector('[data-name="validation-div"]');
        if(this.startDate == '' && this.endDate == '' && this.transactionAmount == 0 && this.selectedPaymentSatisfied == ''){
            this.disableApplyButton = true;
            this.validationErrorMessage = 'Atleast one filter field value required to apply the filter';
            validationDiv.classList.remove('slds-hide');
        }else{
            this.disableApplyButton = false;
            this.validationErrorMessage = '';
            validationDiv.classList.add('slds-hide');
            this.generatingFilters();
            console.log('Filters:'+this.filters);
            this.isApplyFilter = true;
            this.billsList = [];
            this.rowLimit = 10;
            this.rowOffSet = 0;
            this.loadMoreStatus = '';
            this.getBillRecords();
        }
    }

    handleClearClick(){
        this.isApplyFilter = false;
        this.filters = '';
        this.billsList = [];
        this.rowLimit = 10;
        this.rowOffSet = 0;
        this.loadMoreStatus = '';
        this.paymentSatisfied = undefined;
        this.template.querySelector('lightning-input[data-name="startDate"]').value = '';
        this.template.querySelector('lightning-input[data-name="endDate"]').value = '';
        this.template.querySelector('lightning-combobox[data-name="paymentSatisfied"]').value = 'All';
        this.template.querySelector('lightning-input[data-name="paymentAmount"]').value = '';
        this.template.querySelector('lightning-input[data-name="dueAmount"]').value = '';
        this.paymentAmount = null;
        this.dueAmount = null;
        this.startDate = null;
        this.endDate = null;
        const validationDiv = this.template.querySelector('[data-name="validation-div"]');
        validationDiv.classList.add('slds-hide');
        this.validationErrorMessage = '';
        const endDateElement = this.template.querySelector('lightning-input[data-name="endDate"]');
        endDateElement.classList.remove('invalid');
        this.template.querySelectorAll('lightning-input').forEach(element => {
            element.reportValidity();
            element.setCustomValidity('');
        });
        this.getBillRecords();
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
        if(this.startDate == null && this.endDate == null && this.dueAmount == null && this.paymentAmount == null && this.selectedPaymentSatisfied == ''){
            this.disableApplyButton = true;
        } else{
            this.disableApplyButton = false;
        }
    }

    generatingFilters(){
        if(this.startDate != null && this.endDate != null){
            this.filters = ' AND loan__Due_Date__c >=' + this.startDate + ' AND loan__Due_Date__c <=' + this.endDate +'';
        }

        if(this.startDate != null && this.endDate == null){
            this.filters = ' AND loan__Due_Date__c >=' + this.startDate;
        }

        if(this.endDate != null && this.startDate == null){
            this.filters = ' AND loan__Due_Date__c <=' + this.endDate;
        }

        if(this.paymentSatisfied != undefined){
            if(this.filters != ''){
                this.filters = this.filters + ' AND loan__Payment_Satisfied__c = '+ this.paymentSatisfied;
            } else{
                this.filters = ' AND loan__Payment_Satisfied__c = '+ this.paymentSatisfied;
            }
        }

        if(this.dueAmount != null && this.dueAmount != 0){
            if(this.filters != ''){
                this.filters = this.filters + ' AND loan__Due_Amt__c >= '+ this.dueAmount;
            } else{
                this.filters = ' AND loan__Due_Amt__c >= '+ this.dueAmount;
            }
        }

        if(this.paymentAmount != null && this.paymentAmount != 0){
            if(this.filters != ''){
                this.filters = this.filters + ' AND loan__Payment_Amt__c >= '+ this.paymentAmount;
            } else{
                this.filters = ' AND loan__Payment_Amt__c >= '+ this.paymentAmount;
            }
        }
    }
}