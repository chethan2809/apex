import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getBankAccountDetailsByAccountId from '@salesforce/apex/BorrowerBankAccountViewerCtrl.getBankAccountDetailsByAccountId';
import updateBankAccount from '@salesforce/apex/BorrowerBankAccountViewerCtrl.updateBankAccount';
import createBankAccount from '@salesforce/apex/BorrowerBankAccountViewerCtrl.createBankAccount';
import assignBankAccountToApplication from '@salesforce/apex/BorrowerBankAccountViewerCtrl.assignBankAccountToApplication';
import getApplicationById from '@salesforce/apex/BorrowerBankAccountViewerCtrl.getApplicationById';

const NEW_BANK_ACCOUNT_MAP = {
    sObject: "loan__Bank_Account__c",
    Id: undefined,
    loan__Account_Type__c: undefined,
    loan__Active__c: undefined,
    loan__Bank_Account_Number__c: undefined,
    loan__Bank_Name__c: undefined,
    loan__Routing_Number__c: undefined,
    loan__Account__c: undefined
}

const COLUMNS = [
    { label: '', fieldName: 'Liked', type: 'text', initialWidth: 50, cellAttributes:{
        iconName: {fieldName:'nameIcon'}, iconPosition: 'left'
    }},
    { label: 'Name', fieldName: 'Name', type: 'text', initialWidth: 100, cellAttributes:{
        class:{fieldName:'rowColor'}
    }},
    { label: 'Account Type', fieldName: 'loan__Account_Type__c', type: 'picklist', editable: true, initialWidth: 120,
        typeAttributes: { options:{ fieldName: 'typeOptions' }},
        cellAttributes:{ class:{fieldName:'rowColor'}},
    },
    { label: 'Active', fieldName: 'loan__Active__c', type: 'boolean', editable: true, initialWidth: 100, cellAttributes:{
        class:{fieldName:'rowColor'}
    }},
    { label: 'Bank Name', fieldName: 'loan__Bank_Name__c', type: 'text', editable: true, cellAttributes:{
        class:{fieldName:'rowColor'}
    }},
    { label: 'Bank Account Number', fieldName: 'loan__Bank_Account_Number__c', type: 'text', editable: true, cellAttributes:{
        class:{fieldName:'rowColor'}
    }},
    { label: 'Routing Number', fieldName: 'loan__Routing_Number__c', type: 'text', editable: true, cellAttributes:{
        class:{fieldName:'rowColor'}
    }},
    { label: "Link To Application", type: "button", initialWidth: 150,
        typeAttributes: {
            iconName: {fieldName:'actionIconName'},  label: {fieldName:'actionLabel'}, name: 'Link_To_Application',
            title: {fieldName:'actionTitle'}, disabled: {fieldName:'actionDisabled'}, iconPosition: 'left',
            variant: {fieldName:'actionVariant'},
        }
    }
];

export default class BorrowerBankAccountListViewer extends NavigationMixin(LightningElement) {
    @api accountId;
    @api applicationId;
    @track loading = true;
    @track bankAccountDMLError;
    @track showNewBankModal = false;
    tableData = [];
    bankAccountList;
    draftValues = [];
    bankAccountListColumns = COLUMNS;
    disableSaveButton = false;
    applicationName;
    borrowerName;
    currentAppBankAccount;
    bankAccountName;
    isFirstRendered = true;

    renderedCallback() {
        if (this.isFirstRendered && this.currentAppBankAccount) {
            const appBankAccountId = this.currentAppBankAccount;
            this.buildTableData(this.bankAccountList.data, appBankAccountId);
            this.loading = false;
            this.isFirstRendered = false;
        }
    }

    @wire(getApplicationById, { applicationObjId: '$applicationId' })
    wiredApplicationDetail(result) {
        this.applicationDetail = result;
        if (result.data) {
            this.applicationName = result.data.Name;
            this.borrowerName = result.data.genesis__Account__r.Name;
            if(result.data.Bank_Account__c) {
                this.currentAppBankAccount = result.data.Bank_Account__c;
                this.bankAccountName = result.data.Bank_Account__r.Name;
            }
        }
    }

    @wire(getBankAccountDetailsByAccountId, { accountId: '$accountId' })
    wiredBankAccountList(result) {
        this.bankAccountList = result;
        if (result.data) {
            if(result.data.length > 0) {
                const appBankAccountId = this.currentAppBankAccount;
                this.buildTableData(result.data, appBankAccountId);
            }
            this.loading = false;
        }
    }

    get accountTypeOptions() {
        return [
            { label: '--None--', value: '' },
            { label: 'Checking', value: 'Checking' },
            { label: 'Saving', value: 'Saving' },
        ];
    }

    get bankAccountMap() {
        return NEW_BANK_ACCOUNT_MAP;
    }

    get accountUsageOptions() {
        return [
            { label: 'Investor Trust Account', value: 'Investor Trust Account' },
            { label: 'Collections Trust Account', value: 'Collections Trust Account' },
            { label: 'Advance Trust Account', value: 'Advance Trust Account' },
            { label: 'Business Account', value: 'Business Account' },
            { label: 'Tax Withholding Account', value: 'Tax Withholding Account' },
            { label: 'Borrower/Investor Account', value: 'Borrower/Investor Account' },
            { label: 'Broker Account', value: 'Broker Account' }
        ];
    }

    get isError() {
        return this.errors.length > 0;
    }

    get isLoading() {
        if (this.isError) {
            return false;
        }
        return this.loading;
    }

    get errors() {
        let errors = [];

        if (this.bankAccountList.error) {
            errors = errors.concat(this.bankAccountList.error);
        }

        if (this.applicationDetail.error) {
            errors = errors.concat(this.applicationDetail.error);
        }

        if (errors.length > 0) {
            console.error(JSON.stringify(errors, null, 2));
        }
        return errors;
    }

    onAccountTypeChange(event) {
        this.bankAccountMap.loan__Account_Type__c = event.target.value;
    }

    onAccountNumberChange(event) {
        this.bankAccountMap.loan__Bank_Account_Number__c = event.target.value;
    }

    onBankNameChange(event) {
        this.bankAccountMap.loan__Bank_Name__c = event.target.value;
    }

    onRoutingNumberChange(event) {
        this.bankAccountMap.loan__Routing_Number__c = event.target.value;
    }

    onIsActiveChange(event) {
        this.bankAccountMap.loan__Active__c = event.target.checked;
    }

    onAccountUsageChange(event) {
        var options;
        event.target.value.forEach((row) => {
            if(options) {
                options += ';' + row;
            } else {
                options = row;
            }
        });
        this.bankAccountMap.loan__Account_Usage__c = options;
    }

    handleRowAction(event) {
        this.loading = true;
        const actionName = event.detail.action.name;
        if(actionName == 'Link_To_Application') {
            const bankAccountId = event.detail.row.Id;
            this.assignBankAccountHandler(bankAccountId);
        }
    }

    async assignBankAccountHandler(bankAccountId) {
        await assignBankAccountToApplication({ applicationObjId: this.applicationId, bankAccountObjId: bankAccountId })
            .then(result => {
                if (result == 'Success') {
                    refreshApex(this.applicationDetail).then(function(result) {
                        this.buildTableData(this.bankAccountList.data, bankAccountId);
                        this.showToastMessage('Bank Account linked successfully', null, 'success');
                    }.bind(this)).catch(function (error) {
                        this.showToastMessage('Refresh failed', error.body.message, 'error');
                    });
                } else {
                    this.showToastMessage('Bank Account linking failed', result, 'error');
                }
            })
            .catch(error => {
                this.bankAccountDMLError = error;
            });
    }

    buildTableData(resultData, currentBankAccountId) {
        this.tableData = JSON.parse(JSON.stringify(resultData));
        this.tableData.forEach((row) => {
            row.typeOptions = this.accountTypeOptions;
            if(row.Id === currentBankAccountId) {
                row.nameIcon = 'action:approval';
                row.rowColor = "slds-text-color_success";
                row.actionIconName = 'action:approval';
                row.actionLabel = 'Linked';
                row.actionDisabled = true;
                row.actionTitle = 'Already Linked';
                row.actionVariant = 'base';
            } else {
                row.rowColor = 'slds-text-color_weak';
                row.actionIconName = 'utility:link';
                row.actionLabel = 'Link';
                row.actionDisabled = false;
                row.actionTitle = 'Link this bank account to current Application';
                row.actionVariant = 'success';
            }
        });
    }

    onUpdateBankAccount(event) {
        this.loading = true;
        var updatedRows = event.detail.draftValues;
        var updatedBankAccountList = [];
        updatedRows.forEach((bankAccountRow) => {
            updatedBankAccountList.push(bankAccountRow);
        });

        updateBankAccount({ bankObjectList: updatedRows })
            .then(result => {
                if (result == 'Success') {
                    this.draftValues = [];
                    refreshApex(this.bankAccountList).then(function(result) {
                        this.showToastMessage('Bank Account updated Successfully', null, 'success');
                    }.bind(this)).catch(function (error) {
                        this.showToastMessage('Refresh failed', error.body.message, 'error');
                    });
                } else {
                    this.showToastMessage('Bank Account updated Failed', result, 'error');
                }
            })
            .catch(error => {
                this.bankAccountDMLError = error;
            });
    }

    handleCreateBankAccount() {
        this.showNewBankModal = true;
        this.disableSaveButton = false;
    }

    handleSaveNewBankAccount() {
        this.loading = true;
        if(this.validateForm()) {
            this.disableSaveButton = true;
            this.bankAccountMap.Id = null;
            this.bankAccountMap.loan__Account__c = this.accountId;
            createBankAccount({ bankObjectMap: this.bankAccountMap })
                .then(result => {
                    if (result == 'Success') {
                        this.closeModal();
                        refreshApex(this.bankAccountList).then(function(result) {
                            this.showToastMessage('Bank Account created successfully', result, 'success');
                        }.bind(this)).catch(function (error) {
                            this.showToastMessage('Refresh failed', error.body.message, 'error');
                        });
                    } else {
                        this.disableSaveButton = false;
                        this.showToastMessage('Bank Account creation failed', result, 'error');
                    }
                })
                .catch(error => {
                    this.disableSaveButton = false;
                    this.bankAccountDMLError = error;
                });
        } else {
            this.loading = false;
        }
    }

    validateForm() {
        return [...this.template.querySelectorAll("lightning-input, lightning-combobox, lightning-dual-listbox")]
            .reduce((validSoFar, inputComponent) => {
                inputComponent.setCustomValidity('');
                if(!inputComponent.checkValidity()) {
                    validSoFar = false;
                }
                if (inputComponent.name == 'RoutingNumber' && inputComponent.value && inputComponent.value.length  != 9) {
                    inputComponent.setCustomValidity('Routing Number should be 9 digit numeric value');
                    validSoFar = false;
                }
                inputComponent.reportValidity();
                return validSoFar;
            }, true);
    }

    setCustomValidity(inputComponent) {
        inputComponent.setCustomValidity('This field is required. Please complete this field in order to proceed');
        return inputComponent.checkValidity();
    }

    showToastMessage(title, message, variant) {
        this.loading = false;
        const displayMode = (variant == 'success')? 'dismissable' : 'sticky';
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: displayMode
        }));
    }

    closeModal() {
        this.resetInputFields();
        this.showNewBankModal = false;
    }

    backToApplication() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.applicationId,
                objectApiName: 'genesis__Applications__c',
                actionName: 'view'
            }
        });
    }

    resetInputFields() {
        for (let key in this.bankAccountMap) {
            this.bankAccountMap[key] = undefined;
        }
    }
}