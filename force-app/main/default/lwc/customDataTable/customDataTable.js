import { LightningElement, track, wire } from "lwc";
const DELAY = 300;

// importing Apex Class
import retriveCons from "@salesforce/apex/LWCExampleController.getContacts";

export default class CustomHTMLDatatable extends LightningElement {
    // reactive variables
    @track data = [];
    @track error;
    @track bShowModal = false;
    @track selectedCons;
    @track recordsToDisplay;
    @track scoreClassToBeUpdated = "scoreClass";

    // opening the modal
    openModal() {
            this.bShowModal = true;
        }
        // closeing the modal
    closeModal() {
        this.bShowModal = false;
    }

    // Getting Contacts using Wire Service
    @wire(retriveCons)
    contacts(result) {
        if (result.data) {
            this.data = [{
                    Name: "Vignesh Naik",
                    score: 80,
                    email: "vignesh.naik@utilitarianlab.com",
                    interview_Availability: true,
                    status: "Active",
                    desired_pay: 100,
                    city: "Austin",
                    State: "Texas",
                    Website: "home",
                    Balance: "tel",
                    Phone: "555-610-6679"
                },
                {
                    Name: "Aakash Jain",
                    score: 20,
                    email: "aakash.jain@utilitarianlab.com",
                    interview_Availability: false,
                    status: "Active",
                    desired_pay: 100,
                    city: "Austin",
                    State: "Texas",
                    Website: "work",
                    Balance: "tel",
                    Phone: "+420 276 285 602"
                },
                {
                    Name: "Shubham Kumar",
                    score: 60,
                    email: "shubham.kumar@utilitarianlab.com",
                    interview_Availability: true,
                    status: "Active",
                    desired_pay: 100,
                    city: "Austin",
                    State: "Texas",
                    Website: "home",
                    Balance: "tel",
                    Phone: "555-610-6679"
                },
                {
                    Name: "Derek August",
                    score: 90,
                    email: "derek.august@utilitarianlab.com",
                    interview_Availability: false,
                    status: "Active",
                    desired_pay: 100,
                    city: "Austin",
                    State: "Texas",
                    Website: "home",
                    Balance: "tel",
                    Phone: "555-610-6679"
                },
                {
                    Name: "Mark Tall",
                    score: 40,
                    email: "mark.tall@utilitarianlab.com",
                    interview_Availability: false,
                    status: "Active",
                    desired_pay: 100,
                    city: "Austin",
                    State: "Texas",
                    Website: "home",
                    Balance: "tel",
                    Phone: "555-610-6679"
                },
                {
                    Name: "Andrew Simons",
                    score: 10,
                    email: "andrew.simons@utilitarianlab.com",
                    interview_Availability: true,
                    status: "Active",
                    desired_pay: 100,
                    city: "Austin",
                    State: "Texas",
                    Website: "home",
                    Balance: "tel",
                    Phone: "555-610-6679"
                },
                {
                    Name: "Rick John",
                    score: 65,
                    email: "rick.john@utilitarianlab.com",
                    interview_Availability: false,
                    status: "Active",
                    desired_pay: 100,
                    city: "Austin",
                    State: "Texas",
                    Website: "home",
                    Balance: "tel",
                    Phone: "555-610-6679"
                },
                {
                    Name: "Stevee Aime",
                    score: 77,
                    email: "stevee.aime@utilitarianlab.com",
                    interview_Availability: true,
                    status: "Active",
                    desired_pay: 100,
                    city: "Austin",
                    State: "Texas",
                    Website: "home",
                    Balance: "tel",
                    Phone: "555-610-6679"
                },
                {
                    Name: "tel:0",
                    score: 80,
                    email: "aakash.jain@utilitarianlab.com",
                    interview_Availability: true,
                    status: "Active",
                    desired_pay: 100,
                    city: "Austin",
                    State: "Texas",
                    Website: "home",
                    Balance: "tel",
                    Phone: "555-610-6679"
                },
                {
                    Name: "tel:1",
                    score: 91,
                    email: "aakash.jain@utilitarianlab.com",
                    interview_Availability: true,
                    status: "Active",
                    desired_pay: 100,
                    city: "Austin",
                    State: "Texas",
                    Website: "work",
                    Balance: "tel",
                    Phone: "+420 276 285 602"
                },
                {
                    Name: "tel:0",
                    score: 53,
                    email: "aakash.jain@utilitarianlab.com",
                    interview_Availability: false,
                    status: "Active",
                    desired_pay: 100,
                    city: "Austin",
                    State: "Texas",
                    Website: "home",
                    Balance: "tel",
                    Phone: "555-610-6679"
                },
                {
                    Name: "tel:0",
                    score: 73,
                    email: "aakash.jain@utilitarianlab.com",
                    interview_Availability: false,
                    status: "Active",
                    desired_pay: 100,
                    city: "Austin",
                    State: "Texas",
                    Website: "home",
                    Balance: "tel",
                    Phone: "555-610-6679"
                },
                {
                    Name: "tel:0",
                    score: 87,
                    email: "aakash.jain@utilitarianlab.com",
                    interview_Availability: true,
                    status: "Active",
                    desired_pay: 100,
                    city: "Austin",
                    State: "Texas",
                    Website: "home",
                    Balance: "tel",
                    Phone: "555-610-6679"
                },
                {
                    Name: "tel:0",
                    score: 45,
                    email: "aakash.jain@utilitarianlab.com",
                    interview_Availability: true,
                    status: "Active",
                    desired_pay: 100,
                    city: "Austin",
                    State: "Texas",
                    Website: "home",
                    Balance: "tel",
                    Phone: "555-610-6679"
                },
                {
                    Name: "tel:0",
                    score: 49,
                    email: "aakash.jain@utilitarianlab.com",
                    interview_Availability: true,
                    status: "Active",
                    desired_pay: 100,
                    city: "Austin",
                    State: "Texas",
                    Website: "home",
                    Balance: "tel",
                    Phone: "555-610-6679"
                },
                {
                    Name: "tel:0",
                    score: 69,
                    email: "aakash.jain@utilitarianlab.com",
                    interview_Availability: false,
                    status: "Active",
                    desired_pay: 100,
                    city: "Austin",
                    State: "Texas",
                    Website: "home",
                    Balance: "tel",
                    Phone: "555-610-6679"
                }
            ];
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.data = undefined;
        }
    }

    // Select the all rows
    allSelected(event) {
        let selectedRows = this.template.querySelectorAll("lightning-input");

        for (let i = 0; i < selectedRows.length; i++) {
            if (selectedRows[i].type === "checkbox") {
                selectedRows[i].checked = event.target.checked;
            }
        }
    }

    showContacts() {
        this.bShowModal = true;

        this.selectedCons = [];

        let selectedRows = this.template.querySelectorAll("lightning-input");

        // based on selected row getting values of the contact
        for (let i = 0; i < selectedRows.length; i++) {
            if (selectedRows[i].checked && selectedRows[i].type === "checkbox") {
                this.selectedCons.push({
                    Name: selectedRows[i].value,
                    Id: selectedRows[i].dataset.id
                });
            }
        }
    }

    record = {};
    pagelinks = [];
    handleClick(event) {
        let label = event.target.label;
        if (label === "First") {
            this.handleFirst();
        } else if (label === "Previous") {
            this.handlePrevious();
        } else if (label === "Next") {
            this.handleNext();
        } else if (label === "Last") {
            this.handleLast();
        }
    }

    connectedCallback() {
        this.isLoading = true;
        this.setRecordsToDisplay();
        debugger;
        if (this.score >= 80) {
            this.scoreClassToBeUpdated = "dotAboveAverage";
        } else if (this.score >= 50 && this.score < 80) {
            this.scoreClassToBeUpdated = "dotAverage";
        } else {
            this.scoreClassToBeUpdated = "dotBelowAverage";
        }
    }
    setRecordsToDisplay() {
        debugger;
        this.totalRecords = 20;
        this.recordsperpage = 5;
        this.pageNo = 1;
        this.totalPages = Math.ceil(this.totalRecords / this.recordsperpage);
        debugger;
        for (let i = 1; i <= this.totalPages; i++) {
            this.pagelinks.push(i);
        }
        this.preparePaginationList();
        this.isLoading = false;
    }
    handleClick(event) {
        let label = event.target.label;
        if (label === "First") {
            this.handleFirst();
        } else if (label === "Previous") {
            this.handlePrevious();
        } else if (label === "Next") {
            this.handleNext();
        } else if (label === "Last") {
            this.handleLast();
        }
    }

    handleNext() {
        this.pageNo += 1;
        this.preparePaginationList();
    }

    handlePrevious() {
        this.pageNo -= 1;
        this.preparePaginationList();
    }

    handleFirst() {
        this.pageNo = 1;
        this.preparePaginationList();
    }

    handleLast() {
        this.pageNo = this.totalPages;
        this.preparePaginationList();
    }

    handlePage(button) {
        debugger;
        this.pageNo = button.target.label;
        this.preparePaginationList();
    }

    preparePaginationList() {
        console.log("this.pageNo-" + this.pageNo);
        let begin = (this.pageNo - 1) * parseInt(this.recordsperpage);
        let end = parseInt(begin) + parseInt(this.recordsperpage);
        debugger;
        this.recordsToDisplay = this.data.slice(begin, end);
        console.log("this.begin-" + begin);
        console.log("this.end-" + end);
        console.log("this.recordsToDisplay-" + this.recordsToDisplay);
        this.startRecord = begin + parseInt(1);
        this.endRecord = end > this.totalRecords ? this.totalRecords : end;
        this.end = end > this.totalRecords ? true : false;

        const event = new CustomEvent("pagination", {
            detail: {
                records: this.recordsToDisplay
            }
        });
        this.dispatchEvent(event);

        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            this.disableEnableActions();
        }, DELAY);
        this.isLoading = false;
    }

    disableEnableActions() {
        let buttons = this.template.querySelectorAll("lightning-button");

        buttons.forEach((bun) => {
            if (bun.label === this.pageNo) {
                bun.disabled = true;
            } else {
                bun.disabled = false;
            }

            if (bun.label === "First") {
                bun.disabled = this.pageNo === 1 ? true : false;
            } else if (bun.label === "Previous") {
                bun.disabled = this.pageNo === 1 ? true : false;
            } else if (bun.label === "Next") {
                bun.disabled = this.pageNo === this.totalPages ? true : false;
            } else if (bun.label === "Last") {
                bun.disabled = this.pageNo === this.totalPages ? true : false;
            }
        });
    }
}