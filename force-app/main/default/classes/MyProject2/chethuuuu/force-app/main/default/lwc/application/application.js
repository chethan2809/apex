import { LightningElement,track } from 'lwc';

export default class Application extends LightningElement {
    firstname="Anusha";
    lastname="";
    Dob="";
    onchangeevent(event){
        this.firstname=event.target.value;
        this.lastname=event.target.value;
    }
}