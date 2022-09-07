import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getJobDetailsByJobId from '@salesforce/apex/dailyWorkJobTicketCtr.getJobDetailsByJobId';
import getJobStatusByJobId from '@salesforce/apex/dailyWorkJobTicketCtr.getJobStatusByJobId';
import getAllJobTicketsByJobId from '@salesforce/apex/dailyWorkJobTicketCtr.getAllJobTicketsByJobId';
import getJobDetails from '@salesforce/apex/dailyWorkJobTicketCtr.getJobDetails';
import getAllJobAllocationsByJobId from '@salesforce/apex/dailyWorkJobTicketCtr.getAllJobAllocationsByJobId';
import getAllJobTicketsAllocationDetailsById from '@salesforce/apex/dailyWorkJobTicketCtr.getAllJobTicketsAllocationDetailsById';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import ID_FIELD from '@salesforce/schema/Artera_Job_Allocation__c.Id';
import START_TIME from '@salesforce/schema/Artera_Job_Allocation__c.Start_Time__c';
import END_TIME from '@salesforce/schema/Artera_Job_Allocation__c.End_Time__c';
import LUNCH_TIME from '@salesforce/schema/Artera_Job_Allocation__c.Lunch_Time__c';
import JOB_STATUS from '@salesforce/schema/Artera_Job__c.Status__c';
import JOB_ID from '@salesforce/schema/Artera_Job__c.Id';

import APPROVE from '@salesforce/schema/Artera_Job__c.Approve_Ticket__c';
import TRUCK_VALUE from '@salesforce/schema/Artera_Job__c.Truck_Changed_by_Operator__c';
import SIGNED_BY from '@salesforce/schema/Artera_Job__c.Signed_By__c';
import PER_DIEM from '@salesforce/schema/Artera_Job_Allocation__c.Per_Diem__c';


export default class DailyWorkJobTicketCmp extends NavigationMixin(LightningElement) {
    @track selectedAllocation = {};
    @track isModalOpen = false;
    @track isTruckModalOpen = false;
    @track isEmailModalOpen = false;
    @api signedBy;
    @track retrieveStatus = false;
    @track currDate = false;
    @track showMsg = '';
    spinnerStatus = false;

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: PER_DIEM })
    getAllPerDiemValues;

    get modalClass() {
        return this.isModalOpen ? "slds-modal slds-modal_small slds-fade-in-open" : "slds-modal";
    }
    get modalBackdropClass() {
        return this.isModalOpen ? "slds-backdrop slds-backdrop_open" : "slds-backdrop";
    }
    get truckModalClass() {
        return this.isTruckModalOpen ? "slds-modal slds-modal_small slds-fade-in-open" : "slds-modal";
    }
    get truckModalBackdropClass() {
        return this.isTruckModalOpen ? "slds-backdrop slds-backdrop_open" : "slds-backdrop";
    }
    get editModalClass() {
        return this.isEmailModalOpen ? "slds-modal slds-modal_small slds-fade-in-open" : "slds-modal";
    }
    get editModalBackdropClass() {
        return this.isEmailModalOpen ? "slds-backdrop slds-backdrop_open" : "slds-backdrop";
    }

    @track jobData = {};
    @api recordId;
    @track isChecked;
    @track signedByHere;
    @track upStatus;
    @track truckAvailablity;
    @track showBtn = true;
    @track btnBool = false;
    @track bottomCmp = false;
    @track bottomBtnBool = false;
    @track getJobTickets;
    @track isShowResultForTickets = true;
    @track showSearchedValuesForTickets = false;
    @track getJobAllocations;
    @track getJobDetails;
    @track isShowResultForAllocations = true;
    @track showSearchedValuesForAllocations = false;

    @track selectedRecId;

    @track EName;
    @track TruckName;
    @track Email;
    @track EStartTime;
    @track EEndTime;
    @track EPerDiem;
    @track ELunchTime;
    fldsItemValues = [];


    closeModal() {
        this.isModalOpen = false;
        this.selectedRecId = null;
        this.template.querySelector("[data-field='ELunchTime']").value = '';
        this.template.querySelector("[data-field='EStartTime']").value = '';
        this.template.querySelector("[data-field='EEndTime']").value = '';
        this.template.querySelector("[data-field='EPerDiem']").value = '';

        this.EEndTime = '';
        this.ELunchTime = '';
        this.EStartTime = '';
        this.EPerDiem = '';
    }
    closeTruckModal(){
        this.isTruckModalOpen = false;
        this.selectedRecId = null;

    }
    closeEditModal(){
        this.isEmailModalOpen = false;
        this.selectedRecId = null;

    }

    connectedCallback() {
        console.log('inside connected');
        return refreshApex(this._wiredJobTicketDetails, this._wiredJobAllocation, this._wiredJobDetails);
    }

    renderedCallback() {
        console.log('inside render');
        return refreshApex(this._wiredJobTicketDetails, this._wiredJobAllocation, this._wiredJobDetails);

    }

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
    
    _wiredJobDetails;
    @wire(getJobDetailsByJobId, { recordId: '$recordId' })
    wireJobDetails(wireResult) {
        const { data, error } = wireResult;
        this._wiredJobDetails = wireResult;
        if (data) {
            this.jobData = data;
            // this.truckAvailablity = this.jobData.trackname;
            let chkBox = this.template.querySelector(".checkbox");
            if (data.Approve_Ticket__c == true) {
                chkBox.checked = true;
            }
            // console.log(this.truckAvailablity, 'truck');
        } else {
            this.jobData = {};
        }

    }
    _wiredJobDetails;
    @wire(getJobDetails, { recordId: '$recordId' })
    wireJobDetails(wireResult) {
        const { data, error } = wireResult;
        this._wiredJobDetails = wireResult;
        if (data) {
            this.getJobDetails = JSON.parse(data);
          
           
        } else {

           console.log('error', error);
        }

    }




    _wiredJobAllocation;
    @wire(getAllJobAllocationsByJobId, { recordId: '$recordId' })
    wireJobAllocation(wireResult) {
        const { data, error } = wireResult;
        this._wiredJobAllocation = wireResult;
        if (data) {
            //// console.log(data);
            if (data.length > 0 && this.isShowResultForAllocations) {
                this.getJobAllocations = JSON.parse(data);
                this.isChecked = this.getJobAllocations[0].isChecked;
                this.signedByHere = this.getJobAllocations[0].SignedBy;
                this.upStatus = this.getJobAllocations[0].upStatus;
                this.currDate = this.getJobAllocations[0].okForComplete; 
                //this.btnBool = this.getJobAllocations[0].btnBool; 
                // console.log('Bool Btn '+this.btnBool);
                // if(this.upStatus.trim() == 'Pending Payroll Approval'){
                //     this.showBtn = false;
                // } 
                this.spinnerStatus = true;
                //// console.log(this.getJobAllocations);
                this.showSearchedValuesForAllocations = true;
                getJobStatusByJobId({ recordId: this.recordId })
                .then((res)=>{ 
                    this.btnBool        = res.btnBool;
                    this.bottomCmp      = res.bottomCmp;
                    this.bottomBtnBool  = res.bottomBtnBool; 
                })
                .catch((err)=>{ 
                    this.btnBool = false;
                })
            } else if (data.length == 0) {
                this.getJobAllocations = [];
                this.spinnerStatus = true;
                this.isShowResultForAllocations = false;
                this.showSearchedValuesForAllocations = false;
            }
            this.spinnerStatus = true;
        } else if (error) {
            this.error = error;
            this.spinnerStatus = true;
            this.isShowResultForAllocations = false;
            this.showSearchedValuesForAllocations = false;
        }
    }

    _wiredJobTicketDetails;
    @wire(getAllJobTicketsByJobId, { recordId: '$recordId' })
    wireJobTicket(wireRes) {
        const { error, data } = wireRes;
        this._wiredJobTicketDetails = wireRes;
        if (data) {
            this.getJobTickets = JSON.parse(data); 
            if (this.getJobTickets.length > 0 && this.isShowResultForTickets) {
                this.getJobTickets = JSON.parse(data);
                this.showSearchedValuesForTickets = true;
                this.spinnerStatus = true;
            }
            else if (this.getJobTickets.length == 0) {
                this.getJobTickets = [];
                this.showSearchedValuesForTickets = false;
                this.isShowResultForTickets = false;
                this.spinnerStatus = true;
            }
            this.spinnerStatus = true;
        } else if (error) {
            this.spinnerStatus = true;
            this.getJobTickets = [];
            this.showSearchedValuesForTickets = false;
            this.isShowResultForTickets = false;
        }
    }




    showModal(event) {
        //var fetchId = event.target.dataset.id;
        // this.getJobAllocations.forEach(item=>{
        //     if(item.Id === fetchId){
        //         this.selectedAllocation = {...item};
        //     } 
        // })

        this.selectedRecId = event.target.dataset.id;
        this.EName = event.target.dataset.name;
        this.ELunchTime = event.target.dataset.lunch;
        this.EStartTime = event.target.dataset.start;
        this.EEndTime = event.target.dataset.end;
        this.EPerDiem = event.target.dataset.per;
        this.isModalOpen = true;

    }
    showTruckEditModal(event) {

        this.selectedRecId = event.target.dataset.id;
        this.TruckName = event.target.dataset.trackname;
        console.log(this.selectedRecId,this.TruckName, 'truck rec id');
        this.isTruckModalOpen = true;

    }
    showEmailEditModal(event) {

        this.selectedRecId = event.target.dataset.id;
        this.Email = event.target.dataset.contactEmail;
        console.log(this.selectedRecId,this.Email, 'Email rec id');
        this.isEmailModalOpen = true;
       

    }


    onSaveSignature(event) {
        this.signedByHere = '';
    }


    updateValue(event) {

        this.signedByHere = this.template.querySelector("[data-field='SignedBy']").value;
    }

    saveHandleAction(event) {
        this.fldsItemValues = event.detail.draftValues;
        const inputsItems = this.fldsItemValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });

        // // console.log(inputsItems + 'input items');
        const promises = inputsItems.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(res => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Records Updated Successfully!!',
                    variant: 'success'
                })
            );
            this.fldsItemValues = [];
            return this.refresh();
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'An Error Occured!!',
                    variant: 'error'
                })
            );
        }).finally(() => {
            this.fldsItemValues = [];
        });
    }


    handleSaveJob() {
        this.spinnerStatus = false;

        let signedByCust = this.template.querySelector("[data-field='SignedBy']").value;
        let approveTicket;
        if (this.template.querySelector(".checkbox").checked == true) {
            approveTicket = true;
        } else {
            approveTicket = false;
        }

        const fields = {};
        fields[JOB_ID.fieldApiName] = this.recordId;
        fields[APPROVE.fieldApiName] = approveTicket;
        fields[SIGNED_BY.fieldApiName] = signedByCust;
        const recordInput = { fields };
        //// console.log(JSON.stringify(fields));
        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Job Allocation Updated',
                        variant: 'success'
                    })
                );
                this.spinnerStatus = true;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            })
            .finally(() => {
                this.spinnerStatus = true;

            });



        // fields[JOB_STATUS.fieldApiName] = 'Pending Supervisor Approval';


    }

    handleCompleteJob() {
        let checkAllocation = this.getJobAllocations; 
        
        if (checkAllocation == false) {
            // this.spinnerStatus = true;
            readyToInsert = false;
            const toastEvent = new ShowToastEvent({
                title: "Error",
                message: "For Completing Job Ticket, One Allocation Required.",
                variant: "error",
            });
            dispatchEvent(toastEvent);
        }

        if(this.upStatus == 'Pending Supervisor Approval'){
            
            if(this.currDate){
 
            //// console.log(this.recordId, ' rec id');
            getAllJobTicketsAllocationDetailsById({ recordId: this.recordId })
                .then((res) => { 
                    this.retrieveStatus = res.trim();
                    // console.log(this.retrieveStatus, 'result 2');
                    
                    if (this.retrieveStatus=='success') {

                        //// console.log('inside if');
                        let signedByCust = this.template.querySelector("[data-field='SignedBy']").value;
                        let approveTicket;
                        if (this.template.querySelector(".checkbox").checked == true) {
                            approveTicket = true;
                        } else {
                            approveTicket = false;
                        }

                        const fields = {};
                        fields[JOB_ID.fieldApiName] = this.recordId;
                        fields[APPROVE.fieldApiName] = approveTicket;
                        fields[SIGNED_BY.fieldApiName] = signedByCust;
                        fields[JOB_STATUS.fieldApiName] = this.upStatus;
                        const recordInput = { fields };
    
                        updateRecord(recordInput)
                        .then(() => {
                            const toastEvent = new ShowToastEvent({
                                title: "Success",
                                message: "Status Updated Successfully.",
                                variant: "success",
                            });
                            dispatchEvent(toastEvent);
                            setTimeout(() => {
                                this.handleBack()
                            }, 2000);
                        })
                        .catch(error => {
                                const toastEvent = new ShowToastEvent({
                                    title: "Error",
                                    message: "Something wrong, Please Try Again.",
                                    variant: "error",
                                });
                                dispatchEvent(toastEvent);
                        })
                        .finally(() => {
                                
                            });
                    } else { 
                        if(this.retrieveStatus =='error'){
                            this.showMsg = 'All Job tickets Status should be Completed, Start Time and End Time Should be Filled.';
                        }else if(this.retrieveStatus =='error1'){
                            this.showMsg = 'All Job tickets Status should be Completed.';
                        }else if(this.retrieveStatus =='error2'){
                            this.showMsg = 'Start Time and End Time Should be Filled in All Job Allocations.';
                        }
                        const toastEvent = new ShowToastEvent({
                            title: "Error",
                            message: this.showMsg,
                            variant: "error",
                        });
                        dispatchEvent(toastEvent);
                    }
                    // } else {
                    //     //// console.log('inside else');
                    //     const toastEvent = new ShowToastEvent({
                    //         title: "Error",
                    //         message: "Atleast one Job Allocation is required",
                    //         variant: "error",
                    //     });
                    //     dispatchEvent(toastEvent);
                    // }
                }).catch((error) => {
                    // console.log(error);
                })

            } else {
            console.log('inside false');

                const toastEvent = new ShowToastEvent({
                    title: "Error",
                    message: "you cannot update this Job as it's in the future",
                    variant: "error",
                });
                dispatchEvent(toastEvent);
            }


            }

    }

//     handleRefresh() {
//         this.spinnerStatus = false;
// getAllJobAllocationsByJobId({recordId: '$recordId'}).then((data) => {
    
// })
        
//     }

//     handleRefreshJobTickets() {
//         this.spinnerStatus = true;
//         return refreshApex(this._wiredJobDetails, this._wiredJobTicketDetails);

//     }



    handleBack() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Related_Jobs',
            }
        });
    }

    handleClick(event) {
        let componentDef = {
            componentDef: "c:dailyWorkTicketCmp",
            attributes: {
                label: 'Navigated',
                recordId: event.currentTarget.dataset.id,
                jobId: event.currentTarget.dataset.job
            }
        };


        let encodedComponentDef = btoa(JSON.stringify(componentDef));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedComponentDef,
            },
        });

    }

    updateJobAllocationRecord(event) {
        this.spinnerStatus = false;
        let isReadyToInsert = true;
        let recId = event.target.dataset.id;
        let lunchTime = this.template.querySelector("[data-field='ELunchTime']");
        let startTime = this.template.querySelector("[data-field='EStartTime']");
        let endTime  = this.template.querySelector("[data-field='EEndTime']");
        let perDiem  = this.template.querySelector("[data-field='EPerDiem']");

        // if (startTime.value > endTime.value) {
        //     isReadyToInsert = true;
        //     this.dispatchEvent(
        //         new ShowToastEvent({
        //             title: 'Error !!!',
        //             message: 'Start Time Should Be Less Than End Time',
        //             variant: 'error'
        //         })
        //     );

        // }

        if (isReadyToInsert) {
            // console.log(endTime.value+' aa '+startTime.value);
            const fields = {};
            fields[ID_FIELD.fieldApiName] = recId;
            if(startTime.value!= null && startTime.value!=''){
                fields[START_TIME.fieldApiName] = startTime.value;
            }else{
                fields[START_TIME.fieldApiName] = null;
            }
            if(endTime.value!= null && endTime.value!=''){
                fields[END_TIME.fieldApiName] = endTime.value;
            }else{
                fields[END_TIME.fieldApiName] = null;
            }
            if(lunchTime.value==''){
                fields[LUNCH_TIME.fieldApiName] = 0;
            }else{
                fields[LUNCH_TIME.fieldApiName] = lunchTime.value;
            }
             
            fields[PER_DIEM.fieldApiName] = perDiem.value;
            //fields[STATUS.fieldApiName] = 'Completed';
            // console.log(JSON.stringify(fields)); 
            const recordInput = { fields };

            updateRecord(recordInput)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Job Allocation Updated',
                            variant: 'success'
                        })
                    );
                    this.spinnerStatus = true;
                    return refreshApex(this._wiredJobAllocation);
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                })
                .finally(() => {
                    this.spinnerStatus = true;
                    this.closeModal();
                    return refreshApex(this._wiredJobAllocation);
                });
        }


    }



    updateTruckDetails(){
        let truckVal = this.template.querySelector(".truckCheckbox").value = true;

        console.log('truck value', truckVal);


        const toastEvent = new ShowToastEvent({
            title: "success!!",
            message: "Truck number Updated successfully",
            variant: "success"
          });
          this.dispatchEvent(toastEvent);
        this.closeTruckModal();
        return refreshApex(this._wiredJobDetails);
        
    } 
    updateEmail(){
        const toastEvent = new ShowToastEvent({
            title: "success!!",
            message: "Contact email Updated successfully",
            variant: "success"
          });
          this.dispatchEvent(toastEvent);
        this.closeEditModal();
        return refreshApex(this._wiredJobDetails);
    }


    pdfHandler(event){
        let redirectUrl = '/apex/pdffiller_sfree__airslateApp?recordId='+event.currentTarget.dataset.id+'&objectName=Artera_Job__c'+'&buttonId=a0Q02000001p7TIEAY';
       
        const config = {
            type: 'standard__webPage',
            attributes: {
                url: redirectUrl 
            }
        };
        this[NavigationMixin.Navigate](config);
    }


}