import { LightningElement, wire, api } from 'lwc';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import collectionsFileUpload from '@salesforce/apex/CollectionsFileUpload.collectionsFileUpload';
import getCollectionCaseDetails from '@salesforce/apex/CollectionCaseDB.getCollectionCaseDetails';
import getDocumentCategories from '@salesforce/apex/CollectionCaseDB.getDocumentDefinitions';
import getAllWasabiFileFromCollectionCase from '@salesforce/apex/CollectionCaseDB.getAllWasabiFileFromCollectionCase';
import getWasabiFileFromCollectionCase from '@salesforce/apex/CollectionCaseDB.getWasabiFileFromCollectionCase';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { getFileColumns } from 'c/ccDataTableConfig';

export default class FileUpload extends LightningElement {
    @api recordId;
    mapData = [];
    resultFileList = [];
    columns = getFileColumns();
    collectionList;
    clContractId;
    applicationName;
    filesTitle = 'Files';
    docCategoryList;
    defaultSelectedValue = 'All';
    isLoaded = false;
    isChanged = false;
    sortBy;
    sortDirection;

    @wire(getCollectionCaseDetails, {collectionCaseId: '$recordId'})
    wiredContract({
        error,
        data
    }) {
        if (data) {
            console.log('data : ' + JSON.stringify(data));
            this.collectionList = data;
            this.clContractId = this.collectionList[0].CL_Contract_Id__c;
            this.applicationName = this.collectionList[0].Contract_Application_Name__c;
            if(this.clContractId) {
                this.documentCategories();
                this.getAllFileRecords();
            }
        } else if (error) {
            this.error = error;
        }
    }

    documentCategories() {
        getDocumentCategories()
            .then(result => {
                let options = [];
                options.push({ label: 'All', value: 'All' });
                for(let key in result) {
                    options.push({label : result[key].Name, value : result[key].Name});
                }
                this.docCategoryList = options;
            })
            .catch(error => {
                this.docCategoryList = undefined;
            }
        );
    }

    handleUploadFinished(event) {
        this.isLoaded = true;
        console.log('fileData -> ' + JSON.stringify(event.detail.files) + ' recordId -> ' + this.recordId);
        collectionsFileUpload({listOfFiles: JSON.stringify(event.detail.files), parentId: this.recordId}).then(result=>{
            this.mapData = null;
            let title = 'Files uploaded successfully!! Will take a Moment to show File link. Please Wait!!';
            this.toastSuccess(title);
            setTimeout(() => {
                this.getAllFileRecords();
            }, 12000);
        })
        .catch(error => {
            this.toastError(error);
            this.isLoaded = false;
        });
    }

    handleDocumentCategoryChange() {
        let docCatComboBox = this.template.querySelector("[data-name='docCategory']");
        let docCategory = docCatComboBox ? docCatComboBox.value : null;
        if(docCategory == null || docCategory == 'All') {
            this.getAllFileRecords();
        } else {
            this.getFileRecords();
        }
    }

    getAllFileRecords() {
        let collectionCaseIds = [];
        collectionCaseIds.push(this.recordId.slice(0, -3));
        let applicationNameList = [];
        applicationNameList.push(this.applicationName);
        this.resultFileList = [];
        this.isChanged = !this.isChanged;
        getAllWasabiFileFromCollectionCase({ collectionCase: collectionCaseIds, applicationNames : applicationNameList, isChanged : this.isChanged})
            .then(result => {
                console.log('result -> ' + JSON.stringify(result));
                this.resultFileList = result;
                this.filesTitle = 'Files' + ' (' + this.resultFileList.length + ')';
                this.isLoaded = false;
                getRecordNotifyChange([{recordId: this.recordId}]);
            })
            .catch(error => {
                console.log('error -> ' + JSON.stringify(error));
                this.isLoaded = false;
            });
    }

    getFileRecords() {
        let collectionCaseIds = [];
        collectionCaseIds.push(this.recordId.slice(0, -3));
        let applicationNameList = [];
        applicationNameList.push(this.applicationName);
        let docCatComboBox = this.template.querySelector("[data-name='docCategory']");
        let docCategory = docCatComboBox ? docCatComboBox.value : null;
        this.isChanged = !this.isChanged;
        this.resultFileList = [];
        getWasabiFileFromCollectionCase({ documentCategory : docCategory, collectionCase: collectionCaseIds,
                applicationNames : applicationNameList, isChanged : this.isChanged})
            .then(result => {
                console.log('result -> ' + JSON.stringify(result));
                this.resultFileList = result;
                this.filesTitle = 'Files' + ' (' + this.resultFileList.length + ')';
                getRecordNotifyChange([{recordId: this.recordId}]);
            })
            .catch(error => {
                console.log('error -> ' + JSON.stringify(error));
            });
    }

    toastSuccess(title){
        const toastEvent = new ShowToastEvent({
            title,
            variant:"success"
        })
        this.dispatchEvent(toastEvent)
    }

    toastError(title){
        const toastEvent = new ShowToastEvent({
            title,
            variant:"error"
        })
        this.dispatchEvent(toastEvent)
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.resultFileList));
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
        this.resultFileList = parseData;
    }
}