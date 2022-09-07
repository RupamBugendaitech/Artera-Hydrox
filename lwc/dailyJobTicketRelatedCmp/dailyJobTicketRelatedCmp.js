import { LightningElement, wire, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { refreshApex } from "@salesforce/apex";
import getAllJobRecordsByUserId from "@salesforce/apex/dailyJobTicketRelatedCtrl.getAllJobRecordsByUserId";
import getJobsByFilter from "@salesforce/apex/dailyJobTicketRelatedCtrl.getJobsByFilter";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class DailyJobTicketRelatedCmp extends NavigationMixin(
  LightningElement
) {
  error;
  @api isLoaded = false;
  spinnerStatus = false;

  @track getJobRecords = [];
  @track searchByDate = null;
  @track defaultDate;
  @track isEModalOpenJob = false;

  @track activeModeType = "Active";
  @track bufferedDataMainAll;
  @track bufferedDataMainActive;

  connectedCallback() {
    console.log('Called');
    return refreshApex(this._wireJobRecordsActive, this._wireJobRecordsAll);
  }
  renderedCallback() {
    console.log('Called 2');
    return refreshApex(this._wireJobRecordsActive, this._wireJobRecordsAll);
  }

  get editModalClassJob(){
    return this.isEModalOpenJob
    ? "slds-modal slds-modal_small slds-fade-in-open slds-scrollable_y"
    : "slds-modal";
  }

  get editModalBackdropClassJobDetails() {
    return this.isEModalOpenJob
      ? "slds-backdrop slds-p-around_medium slds-modal_small slds-backdrop_open"
      : "slds-backdrop";
  }

  editShowModalJob(event) {
    this.isEModalOpenJob = true;
  }

  editCloseModalJobDetails(){
    this.isEModalOpenJob = false;
    this.refreshValues();
  }

  showAccidentFields = false;
    toggleAccidentFields() {
        this.showAccidentFields = !this.showAccidentFields;
    }

    refreshValues() {
      this.template.querySelector(".leave-start-date").value = null ;
      this.template.querySelector(".leave-end-date").value = null ;
      this.template.querySelector(".leave-end-date").value = null ;
      this.template.querySelector(".leave-reason").value = '' ;
      this.template.querySelector(".leave-Resource").value = '';
      this.template.querySelector(".leave-half").value = false;
     
  }
   

  

  _wireJobRecordsAll;
  @wire(getAllJobRecordsByUserId, { filter: "All" })
  wiredRelatedJobRecordsByUserIdAll(wireRes1) {
    const { data, error } = wireRes1;
    this._wireJobRecordsAll = wireRes1;
    if (data) {
      this.bufferedDataMainAll = JSON.parse(data);
      if (this.activeModeType == "All") {
        this.getJobRecords = this.bufferedDataMainAll;
      }
      console.log(this.bufferedDataMainAll);
      this.spinnerStatus = true;
    } else if (error) {
      this.error = error;
      this.getJobRecords = undefined;
      this.bufferedDataMainAll = [];
    }
  }

  _wireJobRecordsActive;
  @wire(getAllJobRecordsByUserId, { filter: "Active" })
  wiredRelatedJobRecordsByUserIdMy(wireRes) {
    const { data, error } = wireRes;
    this._wireJobRecordsActive = wireRes;
    if (data) {
      this.bufferedDataMainActive = JSON.parse(data);
      if (this.activeModeType == "Active") {
        this.getJobRecords = this.bufferedDataMainActive;
      }
      this.spinnerStatus = true;
      console.log(this.getJobRecords);
    } else if (error) {
      this.error = error;
      this.getJobRecords = undefined;
      this.bufferedDataMainActive = [];
    }
  }

  handleRefresh() {
    this.spinnerStatus = false;
    this.searchByDate = null;
    this.template.querySelector(".searchDate").value = this.searchByDate;

    getJobsByFilter({ filter: "Active", searchByDate: null })
      .then((data) => {
        if (data) {
          if (data != "No") {
            this.bufferedDataMainActive = JSON.parse(data);
            if (this.activeModeType == "Active") {
              this.getJobRecords = this.bufferedDataMainActive;
            }
            this.spinnerStatus = true;
          } else if (data == "No") {
            this.getJobRecords = [];
            this.spinnerStatus = true;
          }
        }
      })
      .catch(() => {
        this.error = error;
        this.spinnerStatus = true;
      })
    getJobsByFilter({ filter: "All", searchByDate: null })
      .then((data) => {
        if (data) {
          if (data != "No") {
            this.bufferedDataMainAll = JSON.parse(data);
            if (this.activeModeType == "All") {
              this.getJobRecords = this.bufferedDataMainAll;
            }
            this.spinnerStatus = true;
          } else if (data == "No") {
            this.getJobRecords = [];
            this.spinnerStatus = true;
          }
        }
      })
      .catch(() => {
        this.error = error;
        this.spinnerStatus = true;
      }).finally(() => {
    this.refreshValues();

      });
  }

  handleLeaveCreated(){
    const toastEvent = new ShowToastEvent({
        message: 'Leave has been requested',
        variant: 'success',
        mode: 'dismissable'
    });
    this.dispatchEvent(toastEvent);
    this.isEModalOpenJob = false;

    this.handleRefresh();

  }

  handleToggleJobs(event) {
    this.spinnerStatus = false;
    this.searchByDate = null;
    this.defaultDate = null;
    this.template.querySelector(".searchDate").value = this.searchByDate;

    let label = event.target.value;
    if (label == "Show Active Jobs") {
      this.activeModeType = "Active";
      // this.getJobRecords  = this.bufferedDataMainActive;
      getJobsByFilter({ filter: "Active", searchByDate: null })
      .then((data) => {
        if (data) {
          if (data != "No") {
            this.bufferedDataMainActive = JSON.parse(data);
            if (this.activeModeType == "Active") {
              this.getJobRecords = this.bufferedDataMainActive;
            }
            this.spinnerStatus = true;
          } else if (data == "No") {
            this.getJobRecords = [];
            this.spinnerStatus = true;
          }
        }
      })
      .catch(() => {
        this.error = error;
        this.spinnerStatus = true;
      }).finally(() => {
        return refreshApex(this._wireJobRecordsActive, this._wireJobRecordsAll);
      });
    } else {
      this.activeModeType = "All";
      this.getJobRecords = this.bufferedDataMainAll;
      getJobsByFilter({ filter: "All", searchByDate: null })
      .then((data) => {
        if (data) {
          if (data != "No") {
            this.bufferedDataMainAll = JSON.parse(data);
            if (this.activeModeType == "All") {
              this.getJobRecords = this.bufferedDataMainAll;
            }
            this.spinnerStatus = true;
          } else if (data == "No") {
            this.getJobRecords = [];
            this.spinnerStatus = true;
          }
        }
      })
      .catch(() => {
        this.error = error;
        this.spinnerStatus = true;
      }).finally(() => {
        return refreshApex(this._wireJobRecordsActive, this._wireJobRecordsAll);
      });
    }
  }

  handleDate(event) {
    this.spinnerStatus = false;

    let filterDate = event.target.value;
    let curFilter = this.activeModeType;

    if (filterDate != null) {
      this.searchByDate = filterDate;
    } else if (filterDate == null) {
      this.searchByDate = null;
    }

    if (this.searchByDate == null) {
      if (curFilter == "All") {
        this.getJobRecords = this.bufferedDataMainAll;
      } else {
        this.getJobRecords = this.bufferedDataMainActive;
      }
      this.spinnerStatus = true;
    } else {
      getJobsByFilter({ filter: curFilter, searchByDate: this.searchByDate })
        .then((data) => {
          if (data) {
            if (data != "No") {
              this.getJobRecords = JSON.parse(data);
              this.spinnerStatus = true;
            } else if (data == "No") {
              this.getJobRecords = [];
              this.spinnerStatus = true;
            }
          }
        })
        .catch(() => {
          this.error = error;
          this.spinnerStatus = true;
        });
    }
  }

  handleClick(event) {
    // console.log(event.currentTarget.dataset.id);
    let componentDef = {
      componentDef: "c:dailyWorkJobTicketCmp",
      attributes: {
        label: "Navigated",
        recordId: event.currentTarget.dataset.id
      }
    };

    let encodedComponentDef = btoa(JSON.stringify(componentDef));
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: "/one/one.app#" + encodedComponentDef
      }
    });
  }
}