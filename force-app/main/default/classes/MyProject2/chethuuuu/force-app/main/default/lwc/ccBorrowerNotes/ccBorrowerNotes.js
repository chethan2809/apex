import { LightningElement, wire, api } from 'lwc';
import getCollectionCaseDetails from '@salesforce/apex/CollectionCaseDB.getCollectionCaseDetails';
import getNotesByAccountIds from '@salesforce/apex/ccBorrowerNotesController.getNotesByAccountIds';

export default class CcBorrowerNotes extends LightningElement {

    @api recordId;
    collectionList;
    borrowerNotesList;
    notesCount = 0;
    error;
    showDialog = false;
    @wire(getCollectionCaseDetails, { collectionCaseId: '$recordId' })
    wiredContract({
        error,
        data
    }) {
        if (data) {
            this.collectionList = data;
            this.borrowerAccountId = this.collectionList[0].Account__c;
            if (this.borrowerAccountId) {
                this.getBorrowerNotesRecords();
            }
        } else if (error) {
            this.error = error;
        }
    }

    getBorrowerNotesRecords() {
        return getNotesByAccountIds({ borrowerAccountId: this.borrowerAccountId })
            .then(result => {
                this.notesCount = result.length;
                let element = this.template.querySelector('.container');
                if(this.notesCount > 3){
                    element.classList.add('auto-scroll');
                }else {
                    element.classList.remove('auto-scroll');
                }
                this.borrowerNotesList = result;
                console.log('Notes:'+JSON.stringify(this.borrowerNotesList));
            })
            .catch(error => {
                this.error = error;
                this.borrowerNotesList = undefined;
            });
    }

    handleNewClick() {
        this.showDialog = true;
    }

    closeModel() {
        this.showDialog = false;
    }
}