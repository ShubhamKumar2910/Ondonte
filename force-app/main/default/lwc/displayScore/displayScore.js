import { api, LightningElement, track } from 'lwc';

export default class DisplayScore extends LightningElement {
    @api score;
    @track scoreClassToBeUpdated = 'scoreClass';
    connectedCallback() {
        debugger;

       /* if (this.score >= 80) {
         //   this.template.querySelector('[data-id="divblock"]').className = 'class1';

            //this.template.querySelector('[data-id="divblock"]').scoreClassToBeUpdated = 'dotAboveAverage';
         
            this.template.querySelector('.changeClass').classList.add('dotAboveAverage');
            // this.scoreClassToBeUpdated = 'dotAboveAverage';
        } else if (this.score >= 50 && this.score < 80) {
            //this.scoreClassToBeUpdated = 'dotAverage';
            this.template.querySelector('.changeClass').className='dotAverage';
        } else {
            //this.scoreClassToBeUpdated = 'dotBelowAverage';
            this.template.querySelector('.changeClass').className='dotBelowAverage';
        } */
        
       
    }  
    noSelection(){
        debugger;
        
        let popup = this.template.querySelector('.popover-wrapper');
        if (this.score >= 80) {          
            this.template.querySelector('.popover-wrapper').classList.add('dotAboveAverage');
           } else if (this.score >= 50 && this.score < 80) {
               this.template.querySelector('.popover-wrapper').classList.add('dotAverage');
           } else {
              this.template.querySelector('.popover-wrapper').classList.add('dotBelowAverage');
           }
        }
    
}