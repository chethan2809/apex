import { LightningElement, wire, api } from 'lwc';
import getChargesList from '@salesforce/apex/CollectionCaseDB.getCLLoanCharges';
import getCollectionCaseDetails from '@salesforce/apex/CollectionCaseDB.getCollectionCaseDetails';
import getTotalCount from '@salesforce/apex/CollectionCaseDB.getTotalCount';
import { getChargesColumns } from 'c/ccDataTableConfig';
import getAllFeeTypes from '@salesforce/apex/CollectionCaseDB.getAllFeeTypes';
export default class CcLoanCharges extends LightningElement {
    @api recordId;
    columns = getChargesColumns();
    rowLimit = 10;
    rowOffSet = 0;
    error;
    collectionList;
    chargesList = [];
    clContractId;
    clContractName;
    totalRows = 0;
    tblName = 'loan__Charge__c';
    whereClauseFieldName = 'loan__Loan_Account__c';
    loadMoreStatus;
    enableInfiniteLoading = true;
    sortBy;
    sortDirection;
    chargeTypes;
    accordianSection = '';
    accordianTitle = 'Show Filters';
    selectedChargePaid = 'All';
    chargePaid = undefined;
    selectedChargeType = '';
    paidAmount = 0.00;
    dueAmount = 0.00;
    startDate = null;
    endDate = null;
    validationErrorMessage = '';
    disableApplyButton=true;
    filters = '';
    isApplyFilter = false;
    recordsDisplayStatus = '';
    isModelOpen = false;
    isChanged = false;

    @wire(getAllFeeTypes)
    getFeeType({error,data}){
        if(data){
            let options = [];
            options.push({ label: '--None--', value: '--None--' });
            for(let key in data){
                options.push({ label: data[key].Name, value: data[key].Name });
            }

            this.chargeTypes = options;
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
            this.clContractName = this.collectionList[0].Contract_Number__c;
            if(this.clContractId){
                this.getTotalRecordCount();
                this.getChargesRecords();
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

    getChargesRecords() {
        this.isChanged = !this.isChanged;
        return getChargesList({ loanAccountId: this.clContractId, limitSize: this.rowLimit, offset: this.rowOffSet, filters: this.filters, isChanged: this.isChanged })
            .then(result => {
                if(this.isApplyFilter){
                    this.chargesList = result;
                    this.isApplyFilter = false;
                } else{
                    if(this.chargesList.length > 0){
                        let updatedRecords = [...this.chargesList, ...result];
                        this.chargesList = updatedRecords;
                    }else {
                        this.chargesList = result;
                        console.log('Result:'+JSON.stringify(this.chargesList));
                    }
                }

                if(this.chargesList.length == 0){
                    this.loadMoreStatus = 'No records to display';
                } else {
                    this.loadMoreStatus = '';
                }

                let chargesArray = [];
                for (let row of this.chargesList) {
                    const flattenedRow = {}
                    let rowKeys = Object.keys(row);
                    rowKeys.forEach((rowKey) => {
                        const singleNodeValue = row[rowKey];
                        if(singleNodeValue.constructor === Object){
                            this._flatten(singleNodeValue, flattenedRow, rowKey);
                        }else{
                            flattenedRow[rowKey] = singleNodeValue;
                        }
                    });
                    chargesArray.push(flattenedRow);
                }

                this.chargesList  = chargesArray;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.chargesList = undefined;
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
            this.getChargesRecords()
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
        let parseData = JSON.parse(JSON.stringify(this.chargesList));
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
        this.chargesList = parseData;
    }

    _flatten(nodeValue, flattenedRow, nodeName){
        let rowKeys = Object.keys(nodeValue);
        rowKeys.forEach((key) => {
            let finalKey = nodeName + '.'+ key;
            flattenedRow[finalKey] = nodeValue[key];
        })
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

    /* handleClick(event){
        this.chargePaid = event.target.checked;
        this.enableDisableApplyButton();
    } */

    handleChargePaidChange(event){
        if(event.detail.value == 'Yes'){
            this.selectedChargePaid = 'Yes';
            this.chargePaid = true;
        }
        else if(event.detail.value == 'No'){
            this.selectedChargePaid = 'No';
            this.chargePaid = false;
        }
        else {
            this.selectedChargePaid = 'All';
            this.chargePaid = undefined;
        }
        this.enableDisableApplyButton();
    }

    handleChargeTypeChange(event){
        this.selectedChargeType = event.target.value;
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
            this.validationErrorMessage = 'End Date cannot be greater than Start Date!';
            validationDiv.classList.remove('slds-hide');
            this.disableApplyButton = true;
        } else {
            endDateElement.classList.remove('invalid');
            validationDiv.classList.add('slds-hide');
            this.validationErrorMessage = '';
            this.enableDisableApplyButton();
        }
    }

    handlePaidAmountChange(event){
        this.paidAmount = event.target.value;
        this.enableDisableApplyButton();
    }

    handleDueAmountChange(event){
        this.dueAmount = event.target.value;
        this.enableDisableApplyButton();
    }

    handleApplyClick(event){
        this.filters = '';
        const validationDiv = this.template.querySelector('[data-name="validation-div"]');
        if(this.startDate == null && this.endDate == null && (this.selectedChargeType == '' && this.selectedChargeType != '--None--') && this.paidAmount == 0 && this.dueAmount == 0 && this.selectedChargePaid == ''){
            this.disableApplyButton = true;
            this.validationErrorMessage = 'Atleast one filter field value required to apply the filter';
            validationDiv.classList.remove('slds-hide');
        }else{
            this.disableApplyButton = false;
            this.validationErrorMessage = '';
            validationDiv.classList.add('slds-hide');
            this.generatingFilters();
            /*  if(this.filters != ''){*/
                this.isApplyFilter = true;
                this.chargesList = [];
                this.rowLimit = 10;
                this.rowOffSet = 0;
                this.loadMoreStatus = '';
                this.getChargesRecords();
            /* } else if(this.filters == '' && this.selectedChargeType == '--None--'){
                this.isApplyFilter = true;
                this.getChargesRecords();
            } */
        }
    }

    handleClearClick(){
        this.isApplyFilter = false;
        this.filters = '';
        this.chargesList = [];
        this.loadMoreStatus = '';
        this.template.querySelector('lightning-input[data-name="startDate"]').value = '';
        this.template.querySelector('lightning-input[data-name="endDate"]').value = '';
        this.template.querySelector('lightning-combobox[data-name="chargePaid"]').value = 'All';
        this.template.querySelector('lightning-combobox[data-name="chargeType"]').value = '';
        this.template.querySelector('lightning-input[data-name="paidAmount"]').value = '';
        this.template.querySelector('lightning-input[data-name="dueAmount"]').value = '';
        this.rowLimit = 10;
        this.rowOffSet = 0;
        this.chargePaid = undefined;
        this.selectedChargeType = '';
        this.paidAmount = 0.00;
        this.dueAmount = 0.00;
        this.startDate = null;
        this.endDate = null;
        const validationDiv = this.template.querySelector('[data-name="validation-div"]');
        validationDiv.classList.add('slds-hide');
        this.validationErrorMessage = '';
        const endDateElement = this.template.querySelector('lightning-input[data-name="endDate"]');
        endDateElement.classList.remove('invalid');
        //this.enableDisableApplyButton();
        this.template.querySelectorAll('lightning-input').forEach(element => {
            element.reportValidity();
            element.setCustomValidity('');
        });
        this.getChargesRecords();
    }

    enableDisableApplyButton(){
        if((this.startDate == null || this.startDate == '') && (this.endDate == null || this.endDate == '') &&
        (this.selectedChargeType == '' && this.selectedChargeType != '--None--') && this.paidAmount == 0 && this.dueAmount == 0  && this.selectedChargePaid == ''){
            this.disableApplyButton = true;
        } else{
            this.disableApplyButton = false;
        }
    }

    generatingFilters(){
        console.log('Start Date:'+this.startDate);
        console.log('End Date:'+this.endDate);
        if(this.startDate != null && this.endDate != null){
            this.filters = ' AND loan__Date__c >=' + this.startDate + ' AND loan__Date__c <=' + this.endDate +'';
        }

        if(this.startDate != null && this.endDate == null){
            this.filters = ' AND loan__Date__c >=' + this.startDate;
        }

        if(this.endDate != null && this.startDate == null){
            this.filters = ' AND loan__Date__c <=' + this.endDate;
        }

        if(this.chargePaid != undefined){
            if(this.filters != ''){
                this.filters = this.filters + ' AND loan__Paid__c = '+ this.chargePaid;
            } else{
                this.filters = ' AND loan__Paid__c = '+ this.chargePaid;
            }
        }

        if(this.selectedChargeType != '' && this.selectedChargeType != '--None--'){
            if(this.filters != ''){
                this.filters = this.filters + ' AND loan__Fee__r.Name = \''+ this.selectedChargeType + '\'';
            } else{
                this.filters = ' AND loan__Fee__r.Name = \''+ this.selectedChargeType + '\'';
            }
        }

        if(this.paidAmount != 0){
            if(this.filters != ''){
                this.filters = this.filters + ' AND loan__Paid_Amount__c >= '+ this.paidAmount;
            } else{
                this.filters = ' AND loan__Paid_Amount__c >= '+ this.paidAmount;
            }
        }

        if(this.dueAmount != 0){
            if(this.filters != ''){
                this.filters = this.filters + ' AND loan__Total_Amount_Due__c >= '+ this.dueAmount;
            } else{
                this.filters = ' AND loan__Total_Amount_Due__c >= '+ this.dueAmount;
            }
        }

        console.log('Filters:'+this.filters);
    }

    handleNewClick(event){
        this.isModelOpen = true;
    }

    closeNewChargePopup(event){
        if(event.detail == 'Close Popup'){
            this.isModelOpen = false;
            setTimeout(() => {
                this.handleClearClick();
            },5000);
        }
    }
}