import { LightningElement, wire, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import QUEUE_FIELD from '@salesforce/schema/Collection_Case__c.Case_Queue__c';
import COLLECTOR_FIELD from '@salesforce/schema/Collection_Case__c.OwnerId';
import getCollectionsQueueUsers from '@salesforce/apex/CollectionCaseDB.getCollectionsQueueUsers';
import manualCollectorAssignment from '@salesforce/apex/CollectorAssignmentManager.manualCollectorAssignment';
export default class CcCollectorAssignment extends LightningElement {
    @api recordId;
    userList;
    @wire(getRecord, {recordId: '$recordId', fields: [QUEUE_FIELD, COLLECTOR_FIELD]})
    collectionCase;
    disableSaveButton = false;

    get queue(){
        return getFieldValue(this.collectionCase.data, QUEUE_FIELD);
    }

    @wire(getCollectionsQueueUsers, {queue: '$queue'})
    wiredCollectors({error, data}) {
        if (data) {
            let options = [];
            options.push({ label: '--None--', value: '--None--' });
            for(let key in data) {
                options.push({label : data[key].Name, value : data[key].Id});
            }
            this.userList = options;
        } else if (error) {
            this.error = error;
            console.log('error -' + JSON.stringify(error));
        }
    }

    get collectorId(){
        return getFieldValue(this.collectionCase.data, COLLECTOR_FIELD);
    }

    get options() {
        return [
            {label: 'LOW BALANCE', value: 'LOW BALANCE'},
            {label: 'HIGH BALANCE', value: 'HIGH BALANCE'}
        ];
    }

    queueChangeHandler(event) {
        this.template.querySelector("[data-id='Collector']").value = '--None--';
        getCollectionsQueueUsers({queue : event.detail.value}).then(result => {
            let options = [];
            options.push({ label: '--None--', value: '--None--' });
            for(let key in result) {
                options.push({label : result[key].Name, value : result[key].Id});
            }
            this.userList = options;
        }).catch(error => {
            console.log('error -' + JSON.stringify(error));
        });
    }


    changeCollector() {
        let queueComboBox = this.template.querySelector("[data-id='Queue']");
        let selectedQueue = queueComboBox ? queueComboBox.value : null;
        let CollectorComboBox = this.template.querySelector("[data-id='Collector']");
        let selectedCollectorId = CollectorComboBox ? CollectorComboBox.value : null;
        this.disableSaveButton = true;
        console.log('selectedQueue -' + selectedQueue);
        console.log('selectedCollectorId -' + selectedCollectorId);
        if(selectedCollectorId == this.collectorId && selectedQueue == this.queue) {
            const evt = new ShowToastEvent({
                title: 'Nothing to Save', message: 'No Changes Done', variant: 'Warning'
            });
            this.dispatchEvent(evt);
            this.disableSaveButton = false;
            return;
        }
        if((selectedCollectorId == null || selectedQueue == null) ||
            (selectedCollectorId == '--None--')
        ) {
            const evt = new ShowToastEvent({
                title: 'Not Allowed', message: 'Please Select Valid Queue and Collector', variant: 'Warning'
            });
            this.dispatchEvent(evt);
            this.disableSaveButton = false;
            return;
        }

        manualCollectorAssignment({collectionCaseId : this.recordId, selectedQueue : selectedQueue,
        selectedCollectorId : selectedCollectorId}).then(result => {
            const evt = new ShowToastEvent({
                title: 'Record Updated', message: 'Updated successfully', variant: 'success'
            });
            this.dispatchEvent(evt);
            this.disableSaveButton = false;
            this.closeModal();
            getRecordNotifyChange([{recordId: this.recordId}]);
        }).catch(error => {
            const evt = new ShowToastEvent({
                title: 'Record Updated Failed', message: JSON.stringify(error), variant: 'error'
            });
            this.dispatchEvent(evt);
            this.disableSaveButton = false;
        });
    }

    closeModal(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}