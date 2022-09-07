import { LightningElement, wire, track, api } from "lwc";
import supIco from "@salesforce/resourceUrl/images";

// all custom functions
import getAllJobAllocationsForSupervisorRefreshData from "@salesforce/apex/supervisorCtr.getAllJobAllocationsForSupervisorRefreshData";
import getAllJobAllocationsForSupervisor from "@salesforce/apex/supervisorCtr.getAllJobAllocationsForSupervisor";
import createTicketDetails from "@salesforce/apex/dailyWorkJobTicketCtr.createTicketDetails";
import getSearchListByFilter from "@salesforce/apex/supervisorCtr.getSearchListByFilter";
import approveJobs from "@salesforce/apex/supervisorCtr.approveJobs";
import getRegionList from "@salesforce/apex/dispatcherCtrl.getRegionList";

// all standard functions
import { createRecord } from "lightning/uiRecordApi";
import { deleteRecord } from "lightning/uiRecordApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

// fields for allocations
import ALLOCATION_ID from "@salesforce/schema/Artera_Job_Allocation__c.Id";
import RESOURCE from "@salesforce/schema/Artera_Job_Allocation__c.Artera_Resource__c";
import JOB_ID_All from "@salesforce/schema/Artera_Job_Allocation__c.Job__c";
import PER_DIEM from "@salesforce/schema/Artera_Job_Allocation__c.Per_Diem__c";
import START_TIME from "@salesforce/schema/Artera_Job_Allocation__c.Start_Time__c";
import END_TIME from "@salesforce/schema/Artera_Job_Allocation__c.End_Time__c";
import LUNCH_TIME from "@salesforce/schema/Artera_Job_Allocation__c.Lunch_Time__c";
import PAY_CODE from "@salesforce/schema/Artera_Job_Allocation__c.Paycode__c";

// fields for ticekts
import ID from "@salesforce/schema/Job_Ticket_Detail__c.Id";
import UNIT_ITEM from "@salesforce/schema/Job_Ticket_Detail__c.Unit_Item__c";
import QUANTITY from "@salesforce/schema/Job_Ticket_Detail__c.Quantity__c";
import OPERATOR_HOUR from "@salesforce/schema/Job_Ticket_Detail__c.Operator_Hours__c";
import TRUCK_VALUE from '@salesforce/schema/Artera_Job__c.Truck_Changed_by_Operator__c';
// all objects
import ASSIGNMENT_OBJECT from "@salesforce/schema/Artera_Job_Allocation__c";

// user details
import Id from "@salesforce/user/Id";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import UserNameFld from "@salesforce/schema/User.Name";
import UserProfileFld from "@salesforce/schema/User.Profile.Name";

const fields = [TRUCK_VALUE];

export default class SupervisorCmp extends LightningElement {
  @api recordId;
  @wire(getRecord, { recordId: '$recordId', fields })
  truckValue;

  @track spinnerStatus = false;
  userId = Id;
  currentUserName;
  currentProfileName;

  @track isShowFilter = false;
  // dedicated variables
  @track addAssBtn = false;
  @track editAssBtn = false;
  @track dltAssBtn = false;
  @track addTktBtn = false;
  @track editTktBtn = false;
  @track dltTktBtn = false;
  @track showOpHr = false;
  @track quantityEdit = false;
  @track regionLists = [];
  @track regionNames = [];
  error;

  supIco = supIco + "/images/approval.png";
  @track records; 
  @track bufferedDataMainAll; 
  @track bufferedDataMainMy;
 
  @track activeModeType = "My";
  @track activeIndex = null;
  @track iconType = "utility:chevronright";

  // modals variables
  @track isModalOpenAss = false;
  @track isModalOpen = false;
  @track isModalNewJob = false;

  // other varialbles
  @track isShowResult = true;
  @track showSearchedValues = false;
  @track isModalEditTkt = false;
  @track getAllJobAllocations;
  @track searchKeyword = null;
  @track searchByDate = null;
  @track defaultDate = null;
  @track searchByYard = [];

  // selected rec Ids
  @track selectedJobId;
  @track projectId;
  @track lookpResourceId;
  @track defaultLookupId;
  @track selectedRecId;
  @track Eqty;
  @track Eopehr;
  @track EEmp;
  @track EStartTime;
  @track EEndTime;
  @track EPerDiem;
  @track EPayCode;
  @track ELunchTime;
  @track recordList = [];

  rec = {
    TicketId: this.ticketId,
    LineItem: this.lineItem,
    Quantity: this.quantity,
    key: 1,
    ShowDel: this.showDelete
  };

  // call first time
  connectedCallback() {
    this.pushFirstObj();
    this.getDate();
  }

  @wire(getRegionList)
  wiredRegionList({ error, data }) {
    try {
      if (data) {
        for (var i = 0; i <= data.length; i++) {
          this.regionLists = [
            ...this.regionLists,
            { value: data[i].Id, label: data[i].Name }
          ];
        }
      } else if (error) {
        this.error = error;
      }
    } catch (e) {
      // console.log("error" + e);
    }
  }

  get regionsList() {
    return this.regionLists;
  }
  get truckVal() {
      return getFieldValue(this.truckValue.data, TRUCK_VALUE);
  }

  getDate() {
    let currentDate = new Date();
    currentDate.setDate(currentDate.getDate());
    const tomorrow = `${currentDate.getFullYear()}-${String(
      currentDate.getMonth() + 1
    ).padStart(2, "0")}-${String(currentDate.getDate()).padStart(2, "0")}`;
    //// console.log('Yes '+ ret);
    this.defaultDate = tomorrow;
  }

  pushFirstObj() {
    this.recordList.push(JSON.parse(JSON.stringify(this.rec)));
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

  @wire(getRecord, { recordId: Id, fields: [UserNameFld, UserProfileFld] })
  userDetails({ error, data }) {
    if (data) {
      this.currentUserName = data.fields.Name.value;
      this.currentProfileName = data.fields.Profile.value.fields.Name.value;
      // this.currentProfileName = 'Hydro-X Payroll';
      // // console.log('Pro '+this.currentProfileName);
      if (this.currentProfileName == "Hydro-X Supervisor") {
        this.isShowFilter = true;
        this.addAssBtn = true;
        this.editAssBtn = true;
        this.dltAssBtn = false;
        this.addTktBtn = true;
        this.editTktBtn = true;
        this.dltTktBtn = true;
        this.activeModeType = "My";
      } else if (this.currentProfileName == "Hydro-X Account Receivables") {
        this.isShowFilter = false;
        this.addAssBtn = false;
        this.editAssBtn = false;
        this.dltAssBtn = false;
        this.addTktBtn = true;
        this.editTktBtn = true;
        this.dltTktBtn = true;
        this.activeModeType = "All";
      } else if (this.currentProfileName == "Hydro-X Admin") {
        this.isShowFilter = false;
        this.addAssBtn = false;
        this.editAssBtn = true;
        this.dltAssBtn = false;
        this.addTktBtn = true;
        this.editTktBtn = true;
        this.dltTktBtn = true;
        this.activeModeType = "All";
      } else if (this.currentProfileName == "Hydro-X Payroll") {
        this.isShowFilter = false;
        this.addAssBtn = false;
        this.editAssBtn = true;
        this.dltAssBtn = false;
        this.addTktBtn = false;
        this.editTktBtn = true;
        this.dltTktBtn = false;
        this.showOpHr = true;
        this.quantityEdit = true;
        this.activeModeType = "All";
      } else {
        this.isShowFilter = false;
        this.addAssBtn = true;
        this.editAssBtn = true;
        this.dltAssBtn = true;
        this.addTktBtn = true;
        this.editTktBtn = true;
        this.dltTktBtn = true;
        this.activeModeType = "All";
      }
    } else if (error) {
      this.error = error;
    }
  }

  // all picklist values
  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA",
    fieldApiName: PER_DIEM
  })
  getAllPerDiemValues;

  // all picklist values
  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA",
    fieldApiName: PAY_CODE
  })
  getAllPayCodeValues;

  // wire function for fetch all jobs
  _wiredJobDataAll;
  @wire(getAllJobAllocationsForSupervisor, { filter: "All" })
  wiredRelatedgetAllResources(wireResultAll) {
    const { data, error } = wireResultAll;
    this._wiredJobDataAll = wireResultAll;
    var actIndex1 = this.activeIndex;
    if (this.activeModeType == "All") {
      if (data) {
        this.activeModeType = "All";
         console.log(data);
        if (data.length > 0 && this.isShowResult) {
          this.records = JSON.parse(data).map(function (
            currentItem,
            index,
            actArray
          ) {
            if (actIndex1 == index) {
              return { ...currentItem, IsOpen: true };
            } else {
              return { ...currentItem, IsOpen: false };
            }
          });
          this.bufferedDataMainAll = this.records;
          this.bufferedDataMainAll = this.records;
          //// console.log(this.records);
          this.showSearchedValues = true;
          this.spinnerStatus = true;
        } else if (data.length == 0) {
          this.getAllJobAllocations = [];
          this.isShowResult = false;
          this.showSearchedValues = false;
          this.spinnerStatus = true;
        }
      } else if (error) {
        this.error = error;
        this.spinnerStatus = true;
      }
    }
  }

  // wire function for fetch my jobs
  _wiredJobDataMy;
  @wire(getAllJobAllocationsForSupervisor, { filter: "My" })
  wiredRelatedgetMyResources(wireResultMy) {
    const { data, error } = wireResultMy;
    this._wiredJobDataMy = wireResultMy;
    var actIndex1 = this.activeIndex;
    if (this.activeModeType == "My") {
      if (data) {
        this.activeModeType = "My";
        if (data.length > 0 && this.isShowResult) {
          this.records = JSON.parse(data).map(function (
            currentItem,
            index,
            actArray
          ) {
            if (actIndex1 == index) {
              return { ...currentItem, IsOpen: true };
            } else {
              return { ...currentItem, IsOpen: false };
            }
          });
          this.bufferedDataMainMy = this.records;
          this.bufferedDataMainMy = this.records;

          this.showSearchedValues = true;
          this.spinnerStatus = true;
        } else if (data.length == 0) {
          this.getAllJobAllocations = [];
          this.isShowResult = false;
          this.showSearchedValues = false;
          this.spinnerStatus = true;
        }
      } else if (error) {
        this.error = error;
        this.spinnerStatus = true;
      }
    }
  }

  get modalClassAss() {
    return this.isModalOpenAss
      ? "slds-modal slds-modal_small slds-fade-in-open"
      : "slds-modal";
  }
  get modalBackdropClassAss() {
    return this.isModalOpenAss
      ? "slds-backdrop slds-p-around_medium slds-modal_small slds-backdrop_open"
      : "slds-backdrop";
  }

  get modalClass() {
    return this.isModalOpen
      ? "slds-modal slds-modal_small slds-fade-in-open"
      : "slds-modal";
  }
  get modalBackdropClass() {
    return this.isModalOpen
      ? "slds-backdrop slds-backdrop_open"
      : "slds-backdrop";
  }

  get modalCreateTicketDetails() {
    return this.isModalNewJob
      ? "slds-modal slds-modal_small  slds-fade-in-open"
      : "slds-modal";
  }

  get modalBackdropCreateTicketDetails() {
    return this.isModalNewJob
      ? "slds-backdrop slds-p-around_medium slds-modal_small slds-backdrop_open"
      : "slds-backdrop";
  }

  get modalEditTicket() {
    return this.isModalEditTkt
      ? "slds-modal slds-modal_small  slds-fade-in-open"
      : "slds-modal";
  }
  get modalBackdropEditTicket() {
    return this.isModalEditTkt
      ? "slds-backdrop slds-p-around_medium slds-modal_small slds-backdrop_open"
      : "slds-backdrop";
  }

  // general functions

  resetAllLookupIds() {
    this.lookupRecord = "";
    this.defaultLookupId = "";
    // this.lookpCustomerId = '';
    // this.lookpRegionId = '';
    // this.lookpSupervisorId = '';
    // this.lookpProjectNoId = '';
    // this.lookpWorkOrderId = '';
  }

  hideAndShow(event) {
    let indx = event.target.dataset.recordId;
    this.activeIndex = indx;
    if (this.records) {
      let recs = JSON.parse(JSON.stringify(this.records));
      let currVal = recs[indx].IsOpen;
      recs[indx].IsOpen = !currVal;
      if (recs[indx].IsOpen == false) {
        this.activeIndex = null;
      }
      this.records = recs;
      if (this.records[indx].IsOpen == true) {
        event.target.iconName = "utility:chevrondown";
      } else {
        event.target.iconName = "utility:chevronright";
      }
    }
  }

  resetAllIcons() {
    let fullData = this.template.querySelector(".ownTable");
    let allIcons = fullData.querySelectorAll(".icnClass");
    let actI = this.activeIndex;
    for (let i = 0; i < allIcons.length; i++) {
      if (actI == i) {
        allIcons[i].iconName = "utility:chevrondown";
      } else {
        allIcons[i].iconName = "utility:chevronright";
      }
    }
  }
  resetAllIconDefault() {
    // console.log('called');
    let fullData = this.template.querySelector(".ownTable");
    let allIcons = fullData.querySelectorAll(".icnClass");
    this.activeIndex = null;
    for (let i = 0; i < allIcons.length; i++) {
      allIcons[i].iconName = "utility:chevronright";
    }
    // console.log('called again');
  }

  resetAllCheckboxes() {
    let fullData = this.template.querySelector(".ownTable");
    let allIcons = fullData.querySelectorAll(".checkbox");
    for (let i = 0; i < allIcons.length; i++) {
      allIcons[i].checked = false;
    }
  }

  handleQuantityChange(event) {
    let selectedRow = event.currentTarget;
    let key = selectedRow.dataset.id;
    this.recordList[key].Quantity = event.target.value;
  }

  handleTicketValues(event) {
    let selectedRow = event.currentTarget;
    let key = selectedRow.dataset.id;
    this.recordList[key].TicketId = event.detail;
  }

  handleLineItemValues(event) {
    let typeAction = event.target.dataset.type;

    if (typeAction == "New") {
      if (event.detail != undefined) {
        let selectedRow = event.currentTarget;
        let key = selectedRow.dataset.id;
        this.recordList[key].LineItem = event.detail;
      }
    } else if (typeAction == "Edit") {
      this.defaultLookupId = event.detail;
    }
  }

  lookupRecord(event) {
    let objName = event.target.sObjectApiName;
    let typeAction = event.target.dataset.type;
    if (typeAction == "New") {
      var selectedRow = event.currentTarget;
      var key = selectedRow.dataset.id;
      if (event.detail.selectedRecord != undefined) {
        this.recordList[key].LineItem = event.detail.selectedRecord.Id;
      }
    } else {
      if (event.detail.selectedRecord != undefined) {
        let currentRecordId = event.detail.selectedRecord.Id;
        if (objName == "Project_Item__c") {
          this.defaultLookupId = currentRecordId;
        } else if (objName == "Artera_Resource__c") {
          this.lookpResourceId = currentRecordId;
        }
      }
    }
  }

  // add new assignment functions
  showModalAssignment(event) {
    this.isModalOpenAss = true;
    let curId = event.target.dataset.recordId;
    this.selectedJobId = curId;
    let jobTilte = event.target.dataset.title;
    this.template.querySelector("[data-field='JobName']").value = jobTilte;
  }

  closeModalAssignment() {
    this.resetAllLookupIds();
    this.isModalOpenAss = false;
    this.selectedJobId = "";
    this.template.querySelector("c-custom-lookup-cmp").handleRemove();
    this.template.querySelector("[data-field='ResourceName']").value = "";
    this.template.querySelector("[data-field='JobName']").value = "";
  }

  saveAssignment(event) {
    this.spinnerStatus = false;
    let anyError = true;
    //// console.log('Active filter  '+this.activeModeType);
    if (
      this.lookpResourceId == "" ||
      this.lookpResourceId == null ||
      this.lookpResourceId == undefined
    ) {
      anyError = false;
      const toastEvent = new ShowToastEvent({
        title: "Error",
        message: "Please Choose Any Resource",
        variant: "error"
      });
      this.dispatchEvent(toastEvent);
    }
    if (anyError) {
      const fields = {};
      fields[JOB_ID_All.fieldApiName] = event.target.dataset.id;
      fields[RESOURCE.fieldApiName] = this.lookpResourceId;

      const recordInput = { apiName: ASSIGNMENT_OBJECT.objectApiName, fields };
      // // console.log(JSON.stringify(fields));
      // // console.log(recordInput+'record Inp');
      createRecord(recordInput)
        .then((details) => {
          const toastEvent = new ShowToastEvent({
            title: "Success",
            message: "Job Assigned Successfully",
            variant: "success"
          });
          this.dispatchEvent(toastEvent);
         
         
        

              this.afterRefreshOperation(false);
          
        })
        .catch((error) => {
          const toastEvent = new ShowToastEvent({
            title: "Not Creates",
            message: "Your Record Not Created, Please Try Again.",
            variant: "error"
          });
          this.dispatchEvent(toastEvent);
        })
        .finally(() => {
          //this.isLookupUsed = false;
          this.spinnerStatus = true;
          this.resetAllIcons();
          this.resetAllLookupIds();
          this.afterRefreshOperation(false);
          this.closeModalAssignment();
        });
    }
  }

  // edit assignments
  showModal(event) {
    this.selectedRecId = event.target.dataset.recordId;
    this.EEmp = event.target.dataset.employee;
    //// console.log('Value '+ typeof(event.target.dataset.start));
    if (event.target.dataset.start != "undefined") {
      this.EStartTime = event.target.dataset.start;
    } else {
      this.EStartTime = "";
    }

    if (event.target.dataset.end != "undefined") {
      this.EEndTime = event.target.dataset.end;
    } else {
      this.EEndTime = "";
    }

    if (event.target.dataset.lunch != "undefined") {
      this.ELunchTime = event.target.dataset.lunch;
    } else {
      this.ELunchTime = 0;
    }

    this.EPerDiem = event.target.dataset.per;
    this.EPayCode = event.target.dataset.paycode;
    this.isModalOpen = true;
  }

  closeModal() {
    this.isModalOpen = false;
    this.selectedRecId = null;
    this.EEmp = "";
    this.ELunchTime = "";
    this.EStartTime = "";
    this.EEndTime = "";
    this.EPerDiem = "";
    this.EPayCode = "";
  }

  updateJobAllocationRecord(event) {
    this.spinnerStatus = false;
    let isReadyToInsert = true;
    let recId = this.selectedRecId;
    let lunchTime = this.template.querySelector("[data-field='ELunchTime']");
    let startTime = this.template.querySelector("[data-field='EStartTime']");
    let endTime = this.template.querySelector("[data-field='EEndTime']");
    let perDiem = this.template.querySelector("[data-field='EPerDiem']");
    let paycode = this.template.querySelector("[data-field='EPayCode']");

    if (isReadyToInsert) {
      const fields = {};
      fields[ALLOCATION_ID.fieldApiName] = recId;
      if (startTime.value != "") {
        fields[START_TIME.fieldApiName] = startTime.value;
      }
      if (endTime.value != "") {
        fields[END_TIME.fieldApiName] = endTime.value;
      }
      if (lunchTime.value != "") {
        fields[LUNCH_TIME.fieldApiName] = lunchTime.value;
      } else {
        fields[LUNCH_TIME.fieldApiName] = 0;
      }

      fields[PER_DIEM.fieldApiName] = perDiem.value;
      if (this.showOpHr) {
        fields[PAY_CODE.fieldApiName] = paycode.value;
      }
      const recordInput = { fields };
      updateRecord(recordInput)
        .then(() => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              message: "Job Allocation Updated",
              variant: "success"
            })
          );
          this.afterRefreshOperation();
          this.closeModal();
        })
        .catch((error) => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error creating record",
              message: error.body.message,
              variant: "error"
            })
          );
        })
        .finally(() => {
          this.afterRefreshOperation();

          this.closeModal();
          this.spinnerStatus = true;
        });
    }
  }

  // delete function
  deleteRecordFun(event) {
    //let indx = event.target.dataset.recordId;
    this.spinnerStatus = false;
    let recId = event.currentTarget.dataset.id;
    let recType = event.currentTarget.dataset.type;
    let recTitle = event.currentTarget.dataset.title;
    //let index = event.currentTarget.dataset.indexId;
    let showMsg;
    if (recType == "Line Item") {
      showMsg = "Job Ticket Detail deleted.";
    } else {
      showMsg = 'Job Assignment "' + recTitle + '" is deleted.';
    }
    deleteRecord(recId)
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: showMsg,
            variant: "success"
          })
        );
        this.afterRefreshOperation(false);
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: error.message,
            variant: "error"
          })
        );
      })
      .finally(() => {
        this.spinnerStatus = true;
        this.resetAllIcons();
        this.resetAllLookupIds();
        this.afterRefreshOperation(false);
      });
  }

  // new tickets
  showNewLineItemModal(event) {
    this.isModalNewJob = true;
    let curId = event.target.dataset.recordId;
    this.selectedJobId = curId;
    this.projectId = event.target.dataset.projectId;
  }

  closeNewLineItemModal() {
    this.isModalNewJob = false;
    this.recordList = [];
    this.rec.key = 1;
    this.recordList.push(JSON.parse(JSON.stringify(this.rec)));
    this.index = 1;
    this.template.querySelector("[data-field='NQuantity']").value = "0";
    this.resetAllLookupIds();
  }

  handleSaveLineItems(event) {
    this.spinnerStatus = false;
    let readyToInsert = true;
    let blankRow = this.recordList;
    let lineItemDataList = [];
    if (blankRow.length > 0) {
      for (let i = 0; i < blankRow.length; i++) {
        if (blankRow[i] !== undefined) {
          if (blankRow[i].LineItem.length == undefined) {
            readyToInsert = false;
          }
          let itemData = new Object();
          // itemData.Job_Ticket__c = blankRow[i].TicketId;
          itemData.Job_Ticket__c = blankRow[i].TicketId;
          itemData.Unit_Item__c = blankRow[i].LineItem;
          itemData.Quantity__c = blankRow[i].Quantity;
          lineItemDataList.push(itemData);
        }
      }
      //// console.log(JSON.stringify(lineItemDataList)+' data');
      if (readyToInsert == true) {
        createTicketDetails({
          lineItemDataListString: JSON.stringify(lineItemDataList)
        })
          .then((result) => {
            const toastEvent = new ShowToastEvent({
              title: "Success",
              message: "Line Items Created Successfully.",
              variant: "success"
            });
            dispatchEvent(toastEvent);
            this.afterRefreshOperation(false);
          })
          .catch((error) => {
            const toastEvent = new ShowToastEvent({
              title: "Error",
              message: "Something wrong, Please Try Again.",
              variant: "error"
            });
            dispatchEvent(toastEvent);
          })
          .finally(() => {
            this.spinnerStatus = true;
            this.closeNewLineItemModal();
            this.afterRefreshOperation(false);
          });
      } else {
        this.spinnerStatus = true;
        const toastEvent = new ShowToastEvent({
          title: "Error",
          message: "Please Fill All Data.",
          variant: "error"
        });
        dispatchEvent(toastEvent);
        // this.afterRefreshOperation();
      }
    } else {
      this.spinnerStatus = true;
      const toastEvent = new ShowToastEvent({
        title: "Error",
        message: "Please Fill All Data.",
        variant: "error"
      });
      dispatchEvent(toastEvent);
      // this.afterRefreshOperation();
    }
  }

  //edit tickets
  showEditLineItemModal(event) {
    this.isModalEditTkt = true;
    this.defaultLookupId = event.target.dataset.line;
    this.Eqty = event.target.dataset.qty;
    this.Eopehr = event.target.dataset.opehr;
    this.projectId = event.target.dataset.projectId;
    this.selectedRecId = event.target.dataset.id;
  }

  closeEditModal() {
    this.isModalEditTkt = false;
    this.selectedRecId = null;
    this.Eqty = null;
    this.Eopehr = null;
    this.defaultLookupId = null;
    this.projectId = null;
    this.resetAllLookupIds();
  }

  handleEditLineItem(event) {
    this.spinnerStatus = false;
    let qty = this.template.querySelector("[data-field='EQuantity']");
    let opehr = this.template.querySelector("[data-field='EOperatorHour']");

    // // console.log('op hr', opehr);
    let unitId = this.defaultLookupId;
    const fields = {};
    fields[ID.fieldApiName] = this.selectedRecId;
    fields[QUANTITY.fieldApiName] = qty.value;
    fields[UNIT_ITEM.fieldApiName] = unitId;
    if (this.showOpHr) {
      fields[OPERATOR_HOUR.fieldApiName] = opehr.value;
    }

    // // console.log(fields, 'fields');

    const recordInput = { fields };
    updateRecord(recordInput)
      .then(() => {
        // // console.log('record');
        this.closeEditModal();
        const toastEvent = new ShowToastEvent({
          title: "Success",
          message: "Ticket Detail Updated Successfully.",
          variant: "success"
        });
        dispatchEvent(toastEvent);
        this.afterRefreshOperation(false);
      })
      .catch((error) => {
        const toastEvent = new ShowToastEvent({
          title: "Error",
          message: "Something wrong, Please Try Again.",
          variant: "error"
        });
        dispatchEvent(toastEvent);
      })
      .finally(() => {
        this.spinnerStatus = true;
        this.closeEditModal();
        this.resetAllLookupIds();
        this.afterRefreshOperation(false);
      });
  }

  handleRegion(event) {
    this.resetAllIconDefault();
    //this.spinnerStatus = false;
    // let filterYard = event.target.value;
    let curFilter = this.activeModeType;
    let actIndex1 = this.activeIndex;

    // console.log(this.activeModeType+' mode');
    this.regionNames = [...event.detail.values];
    if (this.regionNames.length == 0) {
      this.searchByYard = [];
    } else {
      this.searchByYard = [...this.regionNames];
    }
    if (
      this.searchByYard.length == 0 &&
      this.searchKeyword == null &&
      this.searchByDate == null
    ) {
      if (curFilter == "All") {
        this.records = this.bufferedDataMainAll;
      } else {
        this.records = this.bufferedDataMainMy;
      }
      this.spinnerStatus = true;
    } else {
      getSearchListByFilter({
        filter: curFilter,
        searchKey: this.searchKeyword,
        searchByDate: this.searchByDate,
        fRegion: this.searchByYard
      })
        .then((data) => {
          // console.log(data);
          if (data) {
            if (data != "No") {
              this.records = JSON.parse(data).map(function (
                currentItem,
                index,
                actArray
              ) {
                return { ...currentItem, IsOpen: false };
              });
              this.showSearchedValues = true;
              this.spinnerStatus = true;
            } else if (data == "No") {
              this.records = [];
              this.isShowResult = true;
              this.showSearchedValues = false;
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

  // date filter
  handleDate(event) {
    this.resetAllIconDefault();
    this.spinnerStatus = false;
    let filterDate = event.target.value;
    let curFilter = this.activeModeType;

    let rList = this.searchByYard;
    if (filterDate != null) {
      this.searchByDate = filterDate;
    } else if (filterDate == null) {
      this.searchByDate = null;
    }

    if (
      this.searchByYard.length == 0 &&
      this.searchKeyword == null &&
      this.searchByDate == null
    ) {
      if (curFilter == "All") {
        this.records = this.bufferedDataMainAll;
      } else {
        this.records = this.bufferedDataMainMy;
      }
      this.spinnerStatus = true;
      //// console.log('date if date is ', this.searchByDate+' keyword is ', this.searchKeyword);
    } else {
      // console.log('date else date is ',curFilter,' kk ', this.searchByDate+' keyword is ', this.searchKeyword,' kkk ',rList);
      getSearchListByFilter({
        filter: curFilter,
        searchKey: this.searchKeyword,
        searchByDate: this.searchByDate,
        fRegion: rList
      })
        .then((data) => {
          //// console.log(data);
          if (data) {
            if (data != "No") {
              this.records = JSON.parse(data).map(function (
                currentItem,
                index,
                actArray
              ) {
                return { ...currentItem, IsOpen: false };
              }); 
              this.showSearchedValues = true;
              this.spinnerStatus = true;
            } else if (data == "No") {
              this.records = [];
              this.isShowResult = true;
              this.showSearchedValues = false;
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

  // search filter
  handleSearch(event) {
    this.resetAllIconDefault();
    this.spinnerStatus = false;
    let curFilter = this.activeModeType;
    let searchBy = event.target.value;
    let rList = this.searchByYard; 

    if (searchBy.length >= 3) {
      this.searchKeyword = searchBy;
    } else if (searchBy.length < 1) {
      this.searchKeyword = null;
    }

    if (
      this.searchByYard.length == 0 &&
      this.searchKeyword == null &&
      this.searchByDate == null
    ) {
      console.log('yes');
      if (curFilter == "All") {
        this.records = this.bufferedDataMainAll; 
        console.log('1');
      } else {
        this.records = this.bufferedDataMainMy; 
        console.log('2');
      }
      this.spinnerStatus = true;
      //// console.log('search if date is ', this.searchByDate+' keyword is ', this.searchKeyword);
    } else {
      console.log('no');
      //// console.log('serach else date is ', this.searchByDate+' keyword is ', this.searchKeyword);
      getSearchListByFilter({
        filter: curFilter,
        searchKey: this.searchKeyword,
        searchByDate: this.searchByDate,
        fRegion: rList
      })
        .then((data) => {
          //// console.log(data);
          if (data) {
            if (data != "No") {
              this.records = JSON.parse(data).map(function (
                currentItem,
                index,
                actArray
              ) {
                return { ...currentItem, IsOpen: false };
              });
              this.showSearchedValues = true;
              this.spinnerStatus = true;
            } else if (data == "No") {
              this.records = [];
              this.isShowResult = true;
              this.showSearchedValues = false;
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

  // toggle function
  handleToggleJobs(event) {
    this.spinnerStatus = false;

    this.searchKeyword = null;
    this.searchByDate = null;
    this.searchByYard = [];
    this.regionNames = [];
 
    this.template.querySelector(".searchKey").value = this.searchKeyword;
    this.template.querySelector(".searchDate").value = this.searchByDate;
    this.template.querySelector("c-multi-select-picklist").clear();

    this.defaultDate = null;
    let label = event.target.value;
    this.activeIndex = null;
    this.resetAllIcons();
    if (label == "Show My Jobs") {
      this.activeModeType = "My";
      getAllJobAllocationsForSupervisor({ filter: "My" })
        .then((data) => {
          if (data) {
            if (data) {
              this.records = JSON.parse(data);
              this.bufferedDataMainMy = this.records;
              this.showSearchedValues = true;
              this.spinnerStatus = true;
            } else if (data.length == 0) {
              this.getAllJobAllocations = [];
              this.isShowResult = false;
              this.showSearchedValues = false;
              this.spinnerStatus = true;
            }
          } else {
            this.spinnerStatus = true;
          }
        })
        .catch(() => {
          this.error = error;
          this.spinnerStatus = true;
        });
    } else {
      this.activeModeType = "All";
      getAllJobAllocationsForSupervisor({ filter: "All" })
        .then((data) => {
          if (data) {
            if (data) {
              console.log(data);
              this.records = JSON.parse(data);
              this.bufferedDataMainAll = this.records;
              this.showSearchedValues = true;
              this.spinnerStatus = true;
            } else if (data.length == 0) {
              this.getAllJobAllocations = [];
              this.isShowResult = false;
              this.showSearchedValues = false;
              this.spinnerStatus = true;
            }
          } else {
            this.spinnerStatus = true;
          }
        })
        .catch(() => {
          this.error = error;
          this.spinnerStatus = true;
        });
    }
  }

  // approve
  handleApproveAll(event) {
    let allJobIdsList = [];
    this.spinnerStatus = false;
    let parentTable = this.template.querySelector(".ownTable");
    let allCheckBoxes = parentTable.querySelectorAll(".checkbox");
    for (let i = 0; i < allCheckBoxes.length; i++) {
      if (allCheckBoxes[i].checked) {
        allJobIdsList.push(allCheckBoxes[i].dataset.recordId);
      }
    }
    approveJobs({ jobIds: allJobIdsList })
      .then((data) => {
        const toastEvent = new ShowToastEvent({
          title: "Success",
          message: "Job Approved.",
          variant: "success"
        });
        dispatchEvent(toastEvent);
        this.spinnerStatus = true;
        this.afterRefreshOperation(true);
      })
      .catch(() => {
        this.error = error;
        this.spinnerStatus = true;
      })
      .finally(() => {
        this.spinnerStatus = true;
        this.resetAllCheckboxes();
        this.resetAllIconDefault();
        this.afterRefreshOperation(true);
      });
  }

  handleApprove(event) {
    let allJobIdsList = [];
    let redId = event.target.dataset.recordId;
    if (redId != "") {
      allJobIdsList.push(redId);
    }
    this.spinnerStatus = false;
    approveJobs({ jobIds: allJobIdsList })
      .then((data) => {
        this.spinnerStatus = true;
        const toastEvent = new ShowToastEvent({
          title: "Success",
          message: "Job Approved.",
          variant: "success"
        });
        dispatchEvent(toastEvent);
        this.afterRefreshOperation(false);
      })
      .catch(() => {
        this.error = error;
        this.spinnerStatus = true;
      })
      .finally(() => {
        this.spinnerStatus = true;
        this.resetAllCheckboxes();
        this.resetAllIconDefault();
        this.afterRefreshOperation(false);
      });
  }

  handleRefresh() {
    this.spinnerStatus = false;

    let curFilterType = this.activeModeType;
    this.activeIndex = null;
    getAllJobAllocationsForSupervisorRefreshData({ filter: curFilterType })
      .then((data) => {
        if (data) {
          if (data) {
            this.records = JSON.parse(data);
            this.showSearchedValues = true;
            this.spinnerStatus = true;
          } else if (data.length == 0) {
            this.records = [];
            this.getAllJobAllocations = [];
            this.isShowResult = true;
            this.showSearchedValues = false;
            this.spinnerStatus = true;
          }
        } else {
          this.spinnerStatus = true;
        }
      })
      .catch(() => {
        this.error = error;
        this.spinnerStatus = true;
      })
      .finally(() => {
        this.spinnerStatus = true;
        this.resetAllIconDefault();
        this.resetAllIcons();
      });
  }

  // afterRefreshOperation(){
  //     this.spinnerStatus = false;
  //     let curFunction = this.activeModeType;
  //     let actIndex2 = this.activeIndex;

  //     getSearchListByFilter({ filter: curFunction, searchKey: this.searchKeyword, searchByDate: this.searchByDate, fRegion: this.searchByYard })
  //         .then((data) => {

  //             if (data) {
  //                 if (data.length > 0 && this.isShowResult) {
  //                     this.records = JSON.parse(data).map(function (currentItem, index, actArray) {
  //                         if (actIndex2 == index) {
  //                             return { ...currentItem, 'IsOpen': true };
  //                         } else {
  //                             return { ...currentItem, 'IsOpen': false };
  //                         }
  //                     });
  //                     if (curFunction == 'All') {
  //                         this.bufferedDataMainAll = this.records;
  //                     } else {
  //                         this.bufferedDataMainMy = this.records;

  //                     }
  //                     // // console.log(this.records);
  //                     this.showSearchedValues = true;
  //                     this.spinnerStatus = true;
  //                 } else if (data.length == 0) {
  //                     this.records = [];
  //                     this.getAllJobAllocations = [];
  //                     this.isShowResult = true;
  //                     this.showSearchedValues = false;
  //                     this.spinnerStatus = true;
  //                 }
  //             }

  //         })
  //         .catch(() => {
  //             this.error = error;
  //             this.spinnerStatus = true;
  //         }).finally(() => {
  //            this.resetAllIcons();
  //                 this.resetAllIconDefault();

  //             this.spinnerStatus = true;
  //         })
  // }

afterRefreshOperation(needToReset){
    this.spinnerStatus = false;
    let curFunction = this.activeModeType;
    let actIndex2 = this.activeIndex;

    getAllJobAllocationsForSupervisorRefreshData({ filter: curFunction })
    .then((data) => {
      if (data) {
        if (data) {
          this.records = JSON.parse(data).map(function (
            currentItem,
            index,
            actArray
          ) {
            if (actIndex2 == index) {
              return { ...currentItem, IsOpen: true };
            } else {
              return { ...currentItem, IsOpen: false };
            }
          });
          if (curFunction == "All") {
            this.bufferedDataMainAll = this.records;
          } else {
            this.bufferedDataMainMy = this.records;
          }

          this.showSearchedValues = true;
          this.spinnerStatus = true;
        } else if (data.length == 0) {
          this.records = [];
          this.getAllJobAllocations = [];
          this.isShowResult = true;
          this.showSearchedValues = false;
          this.spinnerStatus = true;
        }
      } else {
        this.spinnerStatus = true;
      }
    })
    .catch(() => {
      this.error = error;
      this.spinnerStatus = true;
    }).finally(() => {
        if (needToReset) {
          this.resetAllIconDefault();
        }
        this.afterEditRefresh()
        this.spinnerStatus = true;
      });
}

afterEditRefresh() {
    this.spinnerStatus = false;
    let curFunction = this.activeModeType;
    let actIndex2 = this.activeIndex;

      getSearchListByFilter({
        filter: this.activeModeType,
        searchKey: this.searchKeyword,
        searchByDate: this.searchByDate,
        fRegion: this.searchByYard
      })
        .then((data) => {
          if (data) {
            if (data.length > 0 && this.isShowResult) {
              this.records = JSON.parse(data).map(function (
                currentItem,
                index,
                actArray
              ) {
                if (actIndex2 == index) {
                  return { ...currentItem, IsOpen: true };
                } else {
                  return { ...currentItem, IsOpen: false };
                }
              });
              if (curFunction == "All") {
                this.bufferedDataMainAll = this.records;
              } else {
                this.bufferedDataMainMy = this.records;
              }
              // console.log(this.records);
              this.showSearchedValues = true;
              this.spinnerStatus = true;
            } else if (data.length == 0) {
              this.records = [];
              this.getAllJobAllocations = [];
              this.isShowResult = true;
              this.showSearchedValues = false;
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