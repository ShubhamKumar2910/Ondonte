import { LightningElement,api,wire,track} from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import getAccountList from '@salesforce/apex/CandidatePrefLocation_Controller.getAccountList';
import getContacts from '@salesforce/apex/CandidatePrefLocation_Controller.getContacts';
import saveRecords from '@salesforce/apex/CandidatePrefLocation_Controller.savePrefLocation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { CloseActionScreenEvent } from 'lightning/actions';
import displayContactRecord from '@salesforce/apex/CandidatePrefLocation_Controller.displayContactRecord';
import { deleteRecord } from 'lightning/uiRecordApi';




const columns = [{
    label: 'First Name',
    fieldName: 'FirstName'
},
{
    label: 'Last Name',
    fieldName: 'LastName'
},
{
    label: 'Email',
    fieldName: 'Email',
    type: 'email'
},
{
    label: 'Phone',
    fieldName: 'phone',
    type: 'phone'
}

];
export default class LdsPicklist extends LightningElement {

    picklistValues;
    lstSelected = [];
    @track lstOptions = [];
    @track prefLocations ;
    @track isFormOpen = false;
    @api recordId;
    @wire (displayContactRecord) getContact;

    debugger;
    @wire (displayContactRecord) wiredAccounts({data,error}){
        if (data) {
        console.log('data----'+data); 
        this.prefLocations = data;
        console.log('prefLocations--'+prefLocations);
        } else if (error) {
        console.log(error);
        }
   }
    wiredPicklist({ error, data }){
        
        if(data){
            
            this.picklistValues = data.values;
           /* this.lstOptions.push({
                label: objPicklist.label,
                value: objPicklist.value
            }); */
            console.log(' data ', data.values);
            this.error = undefined;
        }
        if(error){
            this.picklistValues = undefined;
            this.error = error;
        }
    }

    handleValueChange(event){
        console.log(JSON.stringify(event.detail));
    }
    @track accountId = '';
    @track contacts;
    @track columns = columns;
    //  invoke apex method with wire property and fetch picklist options.
    // pass 'object information' and 'picklist field API name' method params which we need to fetch from apex
    @wire(getAccountList) accounts;
    onValueSelection(event) {
        // eslint-disable-next-line no-alert
        const selectedAccount = event.target.value;
        this.accountId = event.target.value;
        if (selectedAccount != null) {
            
            getContacts({
                    accountId: selectedAccount
                })
                .then(result => {
                    this.picklistValues = result;
                    result.forEach(objPicklist => {
                        this.lstOptions.push({
                                               label: objPicklist.Name,
                                               value: objPicklist.Id
                                           });
                       }); 
                       console.log(lstOptions);
                    
                    
                    // eslint-disable-next-line no-console
                    console.log('result' + JSON.stringify(result) + selectedAccount);
                })
                .catch(error => {
                    this.error = error;
                });
        }
    }

    handleChange(event) {
        this.lstSelected = event.detail.value;
        
    }

    openFormHandler(){
        this.isFormOpen = true;
    }

    syncBtn() {
        
        debugger;
        this.showload = true;
        saveRecords({cityList: this.lstSelected ,countyId: this.accountId,recordId: this.recordId})
            .then(result => {
                const event = new ShowToastEvent({
                    title: 'Success!',
                    message: 'Record {0} created! Successfully!',
                  
                });
                this.lstSelected = [];
                this.prefLocations = '';
                this.template.querySelector("c-candidate-availablity").handleSuccess();
                this.dispatchEvent(event);
                var responseCode = JSON.parse(result).code;
                var responseMsg = JSON.parse(result).msg;
                var responseData = JSON.parse(result).data;

                this.dispatchEvent(evt);
                if(responseCode === '0'){
                    this.showload = false;
                }else{
                    this.showload = false;
                }
                this.isFormOpen = false;
            })
            .catch(error => {
                this.error = error;
                this.isFormOpen = false;
                const event = new ShowToastEvent({
                    title: 'error!',
                    message: this.error,
                  
                });
            });  
    }
    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
      }

      getSelectedLocations(){ 

      }

      handleContactDelete(event){
          debugger;
        this.recordId = event.target.value;
        //window.console.log('recordId# ' + this.recordId);
        deleteRecord(this.recordId) 
        .then(() =>{
   
           const toastEvent = new ShowToastEvent({
               title:'Record Deleted',
               message:'Record deleted successfully',
               variant:'success',
           })
           this.dispatchEvent(toastEvent);
   
           return refreshApex(this.getContact);
           
        })
        .catch(error =>{
            window.console.log('Unable to delete record due to ' + error.body.message);
        });
     } 
}