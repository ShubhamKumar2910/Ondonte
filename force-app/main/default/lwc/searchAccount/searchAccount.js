import { LightningElement ,wire} from 'lwc';
import { fireEvent } from 'c/pubsub';


export default class SearchAccount extends LightningElement {
    selectedAccount = "";
    handleAccountSelection(event){
        debugger;
        this.selectedAccount = event.target.value;
        const selectEvent = new CustomEvent('accselection', {
            detail: event.target.value
        });
       this.dispatchEvent(selectEvent);
    }

}