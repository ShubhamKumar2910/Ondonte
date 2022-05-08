import { LightningElement,api } from 'lwc';

export default class PartialSearchComp extends LightningElement {

    @api
    exposeCheckboxes(){
        let elements =  this.template.querySelectorAll('.searchCustomCheckbox');
        let subQuery = '';

        for(let i=0;i<elements.length;i++){
            if(elements[i].checked){
                subQuery += elements[i].name +' = true And '
            }
        }

        console.log("SubQuery",subQuery);
        return subQuery;
    }
}