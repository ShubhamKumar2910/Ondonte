import { LightningElement, api, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class ResumeUploaderViaPopup extends LightningElement {

    @api recordId;

    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpenFirstChild = true;
    @track isModalOpenSecondChild = false;
    
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpenFirstChild = false;
    }

    handleChild(event){
        debugger;
        console.log(event.detail.key1);
        if(event.detail.key1 == true){
            this.isModalOpenFirstChild = false;
            this.isModalOpenSecondChild = true;
        }
    }

    handleSecondChild(event){
        if(event.detail == true){
            this.isModalOpenSecondChild = false;
            this.dispatchEvent(new CloseActionScreenEvent());
        }
        
    }
}