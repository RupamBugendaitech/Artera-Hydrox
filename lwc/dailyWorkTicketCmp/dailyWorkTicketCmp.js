import { api, LightningElement, track, wire } from 'lwc';
import getTicketsDetailsById from '@salesforce/apex/dailyWorkJobTicketCtr.getTicketsDetailsById'; 
import getJobStatusByJobId from '@salesforce/apex/dailyWorkJobTicketCtr.getJobStatusByJobId';
import { updateRecord } from 'lightning/uiRecordApi';
import { createRecord } from 'lightning/uiRecordApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import ID_FIELD from '@salesforce/schema/Job_Ticket__c.Id';
import START_TIME from '@salesforce/schema/Job_Ticket__c.Start_Time__c';
import END_TIME from '@salesforce/schema/Job_Ticket__c.End_Time__c';
import STATUS from '@salesforce/schema/Job_Ticket__c.Status__c';
import NOTES from '@salesforce/schema/Job_Ticket__c.Notes__c';
import TCK_DETAIL_OBJ from '@salesforce/schema/Job_Ticket_Detail__c';
import ID from '@salesforce/schema/Job_Ticket_Detail__c.Id';
import TICKET_ID from '@salesforce/schema/Job_Ticket_Detail__c.Job_Ticket__c';
import UNIT_ITEM from '@salesforce/schema/Job_Ticket_Detail__c.Unit_Item__c';
import QUANTITY from '@salesforce/schema/Job_Ticket_Detail__c.Quantity__c';
// import { fireEvent } from 'c/pubSub';
// import pubsub from 'c/pubsub' ; 
// import { fireEvent } from 'c/pubsub';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
// import fileSelectorStyle from '@salesforce/resourceUrl/fileSelectorStyle';
import {CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';



export default class DailyWorkTicketCmp extends NavigationMixin(LightningElement) {

    @track selectedAllocation = {};
    @api recordId;
    @api jobId;
    @track detailsArray;
    @track btnBool = false;
    @track bottomCmp = false;
    @track bottomBtnBool = false;
    @track Status;
    @track projectId;
    @track JobTicket;
    @track StartTime;
    @track EndTime;
    @track Location;
    @track Notes;
    @track Job;
    @track haveTickets;
    @track Id;
    @track objToBeInserted = [];
    @track recordList = [];
    @track lineItemList = [];
    @track index = 1;
    @track lineItem = UNIT_ITEM;
    @track quanity = QUANTITY;
    @track showDelete = false;
    @track isModalNewJob = false;
    @track isModalEditTkt = false;
    @track isLookupUsed = false;
    @track defaultLookupId;
    spinnerStatus = false; 
    @track openModal = false;
    @track selectedRecId;
    @track lineItemId;

    get acceptedFormats() {
        return ['.pdf', '.png', '.docx', '.JPEG', '.HEIF'];
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files.length;
        const evt = new ShowToastEvent({
            title: 'SUCCESS',
            message: uploadedFiles + ' File(s) uploaded  successfully',
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }



    rec = {
        LineItem: this.lineItem,
        Quantity: this.quantity,
        key: 1,
        ShowDel: this.showDelete
    }


    // This method will fire the event and pass strText as a payload.
     // call first time 
     connectedCallback() {
       
        this.pushFirstObj(); 

    }

    get modalCreateTicket() {
        return this.isModalNewJob ? "slds-modal slds-modal_small slds-scrollable--x slds-fade-in-open" : "slds-modal";

    }
    get modalBackdropCreateTicket() {
        return this.isModalNewJob ? "slds-backdrop slds-p-around_medium slds-scrollable--x slds-modal_small slds-backdrop_open" : "slds-backdrop";
    }
    get modalEditTicket() {
        return this.isModalEditTkt ? "slds-modal slds-modal_small slds-scrollable--x  slds-fade-in-open" : "slds-modal";

    }
    get modalBackdropEditTicket() {
        return this.isModalEditTkt ? "slds-backdrop slds-p-around_medium slds-scrollable--x slds-modal_small slds-backdrop_open" : "slds-backdrop";
    }

    pushFirstObj() {
        this.recordList.push(JSON.parse(JSON.stringify(this.rec)));
    }

    @wire(CurrentPageReference) objpageReference;

    _wiredJobTickets;
    @wire(getTicketsDetailsById, { recordId: '$recordId' })
    wireTicketDetails( wireResult ) {
        const { data, error } = wireResult;
        this._wiredJobTickets = wireResult;
        if (data) { 
            this.detailsArray =JSON.parse(data); 
            this.JobTicket = this.detailsArray.Name;
            this.btnBool = this.detailsArray.btnBool;
            this.haveTickets = this.detailsArray.haveTickets;
            this.StartTime = this.detailsArray.StartTime;
            this.EndTime = this.detailsArray.EndTime;
            this.Location = this.detailsArray.Location;
            this.JobId = this.detailsArray.Job;
            this.Notes = this.detailsArray.Notes;
            this.Status = this.detailsArray.Status;
            this.Id = this.detailsArray.Id; 
            this.lineItemList  = this.detailsArray.LineItems;
            this.projectId = this.detailsArray.Project;
            this.spinnerStatus = true;
            getJobStatusByJobId({ recordId: this.jobId })
                .then((res)=>{
                    // this.btnBool = res; 
                    this.btnBool        = res.btnBool;
                    this.bottomCmp      = res.bottomCmp;
                    this.bottomBtnBool  = res.bottomBtnBool;
                })
                .catch((err)=>{ 
                    this.btnBool = false;
                })
            
            
        } else {
            this.error = error;
            this.spinnerStatus = true;

        }
    }

    // for adding new row
    addRow() {
        this.rec.ShowDel = true;
        this.index++;
        var i = this.index;
        this.rec.key = i;
        this.recordList.push(JSON.parse(JSON.stringify(this.rec))); 
    }


    // for removing row 
    removeRow(event) {
        var selectedRow = event.currentTarget;
        var key = selectedRow.dataset.id;
        if (this.recordList.length > 1) {
            this.recordList.splice(key, 1);
            this.index--;
        } else if (this.recordList.length == 1) {
            this.recordList = [];
            this.index = 1;
        }
    } 

    showNewLineItemModal(event) {
        this.isModalNewJob = true;
        this.lineItemId = null;
        // this.defaultLookupId = null;
        this.resetAllLookupIds();

    }

    showEditLineItemModal(event) {
        let fetchId = event.target.dataset.id; 
        this.isModalEditTkt = true; 
        this.lineItemList.forEach(item=>{
            if(item.Id === fetchId){
                this.defaultLookupId = item.UnitId;
                this.selectedRecId = item.Id;
                this.selectedAllocation = {...item};
            } 
        })  
    }

    closeNewLineItemModal() {
        this.isModalNewJob = false; 
        this.recordList = []; 
        this.rec.key = 1;
        this.recordList.push(JSON.parse(JSON.stringify(this.rec))); 
        this.index = 1;        
        this.template.querySelector("[data-field='NQuantity']").value = '0'; 
        this.defaultLookupId = null; 
    }
    closeEditModal() {
        this.isModalEditTkt = false;
        this.selectedRecId = null;        
        this.resetAllLookupIds();        
    }

    handleQuantityChange(event) { 
        let selectedRow = event.currentTarget; 
        let key = selectedRow.dataset.id;  
        this.recordList[key].Quantity = event.target.value;  
    } 
 
 
    resetAllLookupIds() {
      this.defaultLookupId = '';      
    }

    
    handleLineItemValues(event){
        let typeAction = event.target.dataset.type;  

        if(typeAction=='New'){
            if (event.detail != undefined) {        
                this.lineItemId = event.detail; 
            } 
        }else if(typeAction =='Edit'){             
            this.defaultLookupId = event.detail;                            
        }
    }

  
    handleSaveLineItems(event) {  
        this.spinnerStatus = false;
        let readyToInsert = true; 
 
        let nQty       = this.template.querySelector("[data-field='NQuantity']").value; 
        let nLineItem  = this.lineItemId;  

        const fields = {}; 
        fields[TICKET_ID.fieldApiName] = this.recordId;
        fields[UNIT_ITEM.fieldApiName] = nLineItem;
        fields[QUANTITY.fieldApiName]  = nQty;
        
        const recordInput = { apiName: TCK_DETAIL_OBJ.objectApiName, fields };
 

        
            if (readyToInsert == true) { 
                if(nLineItem != null && nQty != ''){

                createRecord(recordInput)
                .then(result => {
                    const toastEvent = new ShowToastEvent({
                        title: "Success",
                        message: "Line Items Created Successfully.",
                        variant: "success",
                    });
                    dispatchEvent(toastEvent);
                    this.defaultLookupId = null;
                }).catch(error => {
                    const toastEvent = new ShowToastEvent({
                        title: "Error",
                        message: "Something wrong, Please Try Again.",
                        variant: "error",
                    });
                    dispatchEvent(toastEvent);
                }).finally(()=>{
                    this.spinnerStatus = true;
                    this.closeNewLineItemModal();
                    return refreshApex(this._wiredJobTickets);                    
                })
            }else{
                this.spinnerStatus = true;
                const toastEvent = new ShowToastEvent({
                    title: "Error",
                    message: "Please Fill All Data.",
                    variant: "error",
                });
                dispatchEvent(toastEvent);
            }
             
            }
         
            
    }


    handleClick(event) {
        this.spinnerStatus = false;
        let readyToInsert = true; 
        let sTime  = this.template.querySelector("[data-field='StartTime']");
        let eTime  = this.template.querySelector("[data-field='EndTime']");
        let eNotes = this.template.querySelector("[data-field='Notes']");
        let eStatus = event.target.value;

        if(eStatus =='Completed'){ 
            if (sTime.value==null || eTime.value==null) {
                readyToInsert = false;
                this.spinnerStatus = true;
                const toastEvent = new ShowToastEvent({
                    title: "Error",
                    message: "Start Time and End Time are Required.",
                    variant: "error",
                });
                dispatchEvent(toastEvent);
            }
        }
        
        // let tktStatus = this.haveTickets;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[START_TIME.fieldApiName] = sTime.value;
        fields[END_TIME.fieldApiName] = eTime.value;
        fields[STATUS.fieldApiName] = eStatus;
        fields[NOTES.fieldApiName] = eNotes.value;
        
        const recordInput = { fields };
        
        if (readyToInsert == true) {
               updateRecord(recordInput)                        
                        .then(() => {
                            const toastEvent = new ShowToastEvent({
                                title: "Success",
                                message: "Ticket Updated Successfully.",
                                variant: "success",
                            });
                            dispatchEvent(toastEvent);
                        })
                        .catch(error => {
                            const toastEvent = new ShowToastEvent({
                                title: "Error",
                                message: "Something wrong, Please Try Again.",
                                variant: "error",
                            });
                            dispatchEvent(toastEvent);
                        })
                        .finally(()=>{
                            this.spinnerStatus = true;  
                            return refreshApex(this._wiredJobTickets);
                        });                

            } 
            
            // window.location.reload();

    }

    handleEditLineItem(event){ 
        this.spinnerStatus = false;        
        let qty    = this.template.querySelector("[data-field='EQuantity']");
        let unitId = this.defaultLookupId; 
        const fields = {};
        fields[ID.fieldApiName]           = this.selectedRecId;
        fields[QUANTITY.fieldApiName]     = qty.value;
        fields[UNIT_ITEM.fieldApiName]    = unitId;
        const recordInput = { fields };  
        updateRecord(recordInput) 
                .then(() => {
                        const toastEvent = new ShowToastEvent({
                            title   : "Success",
                            message : "Ticket Detail Updated Successfully.",
                            variant : "success",
                        });
                        dispatchEvent(toastEvent); 
                        return refreshApex(this._wiredJobTickets);
                })
                .catch(error => {
                    const toastEvent = new ShowToastEvent({
                        title   : "Error",
                        message : "Something wrong, Please Try Again.",
                        variant : "error",
                    });
                    dispatchEvent(toastEvent);
                })
                .finally(() => {
                    this.spinnerStatus = true;
                    this.closeEditModal(); 
                    this.resetAllLookupIds();
                    return refreshApex(this._wiredJobTickets);
                });
    }    
    
    deleteLineItem(event){
        let recId = event.target.dataset.id;        
        this.spinnerStatus = false;
        deleteRecord(recId)
            .then(() => { 
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Ticket Detail Deleted Successfully',
                        variant: 'success',
                    }),
                );
            })
            .catch(error => { 
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Something Please Try Agian',
                        variant: 'error',
                    }),
                );
            })
            .finally(() => { 
                this.spinnerStatus = true;  
                return refreshApex(this._wiredJobTickets);
 
            });
    }


    handleBack() {
       

        let componentDef = {
            componentDef: "c:dailyWorkJobTicketCmp",
            attributes: {
                label: 'Navigated',
                recordId: this.JobId,
            }
        };

        let encodedComponentDef = btoa(JSON.stringify(componentDef));

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedComponentDef,
                //url : 'https://powerteamservices239587345--hydroxdev.lightning.force.com/lightning/r/Artera_Resource__c/a1i760000004roDAAQ/view',
            },
        });

        // window.location.reload(url);

    } 

    handleCancel() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Related_Jobs',
            }
        });
    }

   








}