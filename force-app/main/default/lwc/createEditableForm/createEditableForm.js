import { LightningElement, api, track } from 'lwc';
import resumeParser from '@salesforce/apex/ResumeParseClass.resumeParser';

export default class  CreateEditableForm extends LightningElement {
    @track objects = [];
    @track error;
    @api isModalOpenSecondChild;

    @track data = [
        {name: 'General Details' [{id: 1, type: 'CS', FirstName : 'Ajeet', LastName : 'Kumar' }] },
        {name: 'Educational details' [{id: 2, type: 'EC', Candidate: 'candidate1', CourseName: 'Networking', End_Year : '2024',  StartYear: '2020' }] },
        {name: 'Employment History'[{id: 3, type: 'MEC', EmployerName: 'UtilitarianLab', Duration : '', job_title : 'Developer', Enddate : '27/07/2030', Start_Date : '1/01/2020'  }] },
        
    ];
    
    connectedCallback(){
        resumeParser()
            .then(result => {
                //this.objects = result;
                alert(' Result ==> ' + this.objects);
                for(let key in result) {
                    // Preventing unexcepted data
                    if (result.hasOwnProperty(key)) { // Filtering the data in the loop
                        this.objects.push({value:result[key], key:key});
                    }
                }
            })
            .catch(error => {
                this.error = error;
            });
    
    }

    handleaccordion(event){
        const openSections = event.detail.openSections;

        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    
    }

    closeModalPop() {
        //this.isModalOpenNew = false;
        const event = new CustomEvent('secondchild', {
            // detail contains only primitives
            detail: true });
            this.dispatchEvent(event);
    }

}