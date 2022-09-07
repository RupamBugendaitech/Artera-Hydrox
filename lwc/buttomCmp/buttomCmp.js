import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ButtomCmp extends LightningElement {
showToast() {
    const event = new ShowToastEvent({
        title: 'Get Help',
        message:
            'RecordID',
    });
    this.dispatchEvent(event);
}}