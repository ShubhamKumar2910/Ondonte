$(document).ready(function() {

    let currentShifts = [];
    let selectedEvent;
    let reqId = requisitionId;
    let allShifts = [];
    let dirtyShiftId = new Set();

    if(isRDView && isRDView === 'true') {
        $("#external-events").hide();
        $("#external-events").removeClass();
        $("#cal-container-div").removeClass();
        $("#cal-container-div").addClass("slds-col");
    }

    let configureDateFields = () => {
        var dtToday = new Date();
    
        var month = dtToday.getMonth() + 1;
        var day = dtToday.getDate();
        var year = dtToday.getFullYear();
        if(month < 10)
            month = '0' + month.toString();
        if(day < 10)
            day = '0' + day.toString();
        
        var maxDate = year + '-' + month + '-' + day;

        // or instead:
        // var maxDate = dtToday.toISOString().substr(0, 10); 
        $('#start-date').attr('min', maxDate);
        $('#end-date').attr('min', maxDate);
    }

    let configureCalendar = function() {
        //currentShifts = result.eventList;
        $('#calendar').fullCalendar({
            header: {
                left: 'prev,next today',
                center: 'title',
                right: 'month,agendaWeek,agendaDay'
            },
            themeSystem: "standard",
            defaultDate: new Date(),
            navLinks: true,
            editable: false,
            eventLimit: true,
            events: currentShifts,
            dragScroll: true,
            droppable: true,
            weekNumbers: true,
            timezone: 'local',
            displayEventTime: false,
            eventDrop: function (event, delta, revertFunc) {
                debugger;
                //alert(event.title + " was dropped on " + event.start.format());
                if (!confirm("Are you sure about this change? ")) {
                    revertFunc();
                }else {
                    $.each(currentShifts, function(i,shift) {
                        if (shift.id === event.id) {
                            currentShifts[i].start = event.start._d.getTime();
                            currentShifts[i].end = event.end._d.getTime();
                            console.log(currentShifts[i]);
                            dirtyShiftId.add(currentShifts[i].id)
                        }   
                    });
                    $("#upsert-shifts").show();
                }
            },
            eventClick: function (event, jsEvent, view) {
                debugger;
                selectedEvent = event;
                $("#shift-no").text(event.shiftNumber);
                $("#shift-status").text(event.status);
                $("#shift-st").text(event.startTime);
                $("#shift-et").text(event.endTime);
                $("#shift-no").attr("href", window.location.origin+'/'+event.id);
                $("#st-type").empty();
                $("#st-type").append("<b>Requested Staff Type: </b>");
                if(event.staffTypeList && event.staffTypeList.length > 0) {
                    $(event.staffTypeList).each(function(i, e) {
                        $("#st-type").append("<span class='slds-badge .slds-theme_warning'>"+event.staffTypeList[i]+"</span>");
                    });
                }
                $("#sk-type").empty();
                $("#sk-type").append("<b>Requested Special Skills: </b>");
                if(event.specialSkillsList && event.specialSkillsList.length > 0) {
                    $(event.specialSkillsList).each(function(i, e) {
                        $("#sk-type").append("<span class='slds-badge .slds-theme_warning'>"+event.specialSkillsList[i]+"</span>");
                    });
                }
                
                $("#event-modal").show();
                
            },
            dayClick: function (date, jsEvent, view) {
                jsEvent.preventDefault();
                debugger;
                if(!isRDView || isRDView == '' || isRDView === 'false') {
                    $("#start-date").val(moment(date._d).format("YYYY-MM-DD"));
                    $("#end-date").val(moment(date._d).format("YYYY-MM-DD"));
                    $("#slot-modal").show();
                }
            },
            drop: function(date) {                            
                currentShifts.push({accountId : $(this).attr("data-accid"), start : date._i});
                // is the "remove after drop" checkbox checked?
                if ($('#drop-remove').is(':checked')) {
                    // if so, remove the element from the "Draggable Events" list
                    $(this).remove();
                }
            },   
            eventRender: function(event, element) {         
                if(event.status === 'Open') {
                    element.find(".fc-content").css('background-color', '#109949');
                    element.find(".fc-day-grid-event").css('border-color','#109949 !important');
                    element.find(".fc-bg").css('border','1px solid #109949');
                    element.find(".fc-day-grid-event").css('background-color','#109949 !important');
                    element.css('border', '#109949');
                }else if(event.status === 'Cancelled') {
                    element.find(".fc-content").css('background-color', 'red');
                    element.find(".fc-day-grid-event").css('border-color','red !important');
                    element.find(".fc-bg").css('border','1px solid red');
                    element.find(".fc-day-grid-event").css('background-color','red !important');
                    element.css('border', 'red');
                }/*else if(event.status === 'Filled') {
                    element.find(".fc-content").css('background-color', '#4a4a4a');
                    element.find(".fc-bg").css('border','1px solid #4a4a4a');
                    element.find(".fc-day-grid-event").css('border-color','#4a4a4a !important');
                    element.find(".fc-day-grid-event").css('background-color','#4a4a4a !important');
                    element.css('border', '#4a4a4a');
                }*/else if(event.status === "Could not Fill") {
                    element.find(".fc-content").css('background-color', 'red');
                    element.find(".fc-day-grid-event").css('border-color','red !important');
                    element.find(".fc-bg").css('border','1px solid red');
                    element.find(".fc-day-grid-event").css('background-color','red !important');
                    element.css('border', 'red');
                }           
            },
            eventConstraint: {
                start: moment().format('YYYY-MM-DD'),
                end: '2100-01-01' // hard coded goodness unfortunately
            },
            validRange: function(nowDate) {
                return {
                    start: nowDate,
                    end: nowDate.clone().add(6, 'months')
                };
            },
            eventMouseover: function(calEvent, jsEvent) {
                var tooltip = '<div class="tooltipevent" style="background:#f4a52e;padding: 5px;position:absolute;z-index:10001;border: solid 1px;"><span> <b>Staff-Type: </b>' + calEvent.staffTypeList + '</span><br/><span> <b>Special-Skills: </b>'+calEvent.specialSkillsList+'</span></div>';
                var $tooltip = $(tooltip).appendTo('body');

                $(this).mouseover(function(e) {
                    $(this).css('z-index', 10000);
                    $tooltip.fadeIn('500');
                    $tooltip.fadeTo('10', 1.9);
                }).mousemove(function(e) {
                    $tooltip.css('top', e.pageY + 10);
                    $tooltip.css('left', e.pageX + 20);
                });
            },
            eventMouseout: function(calEvent, jsEvent) {
                $(this).css('z-index', 8);
                $('.tooltipevent').remove();
            }
        });
        $("#calendar").fullCalendar('removeEvents'); 
        $("#calendar").fullCalendar('addEventSource', currentShifts);
        //$('#calendar-card').show();
    }

    configureDateFields();
    let initCal = () => {
        if(reqId !== '') {
        	currentShifts = [];
        	selectedEvent = undefined;
         	allShifts = [];
        	dirtyShiftId = new Set();
            $("#spinner").show();
            EditTemporaryJobShiftsExtention.getInit(reqId,function(result, event) {
                console.log(result);
                debugger;
                //$('#calendar-card').hide();
                if(event.status && result && result.shifts && result.shifts.length > 0) {
                    $(result.shifts).each(function(i, e) {
                        let shift = {id: result.shifts[i].Id, title: moment(result.shifts[i].Start_DateTime__c).format("HH:mm")+' - '+moment(result.shifts[i].End_DateTime__c).format("HH:mm"), shiftNumber: result.shifts[i].Name, start: result.shifts[i].Start_DateTime__c, end:result.shifts[i].End_DateTime__c, status: result.shifts[i].Status__c, startTime: moment(result.shifts[i].Start_DateTime__c).format("HH:mm"), endTime: moment(result.shifts[i].End_DateTime__c).format("HH:mm")};
                        shift.staffTypeList = result.shifts[i].Staff_Type__c ? result.shifts[i].Staff_Type__c.split(";") : [];
                        shift.specialSkillsList = result.shifts[i].Special_Skills__c ? result.shifts[i].Special_Skills__c.split(";") : [];
                        if(shift.status === "Could not Fill" || shift.status === "Filled" || shift.status === "Open" || shift.status === "Cancelled")
                            shift.editable = false;
                        allShifts.push(shift);
                    });
					currentShifts = allShifts;

                    configureCalendar();
                    $("#no-shifts").hide();
                    //$("#calendar-container").show();
                }else {
                    configureCalendar();
                    //TODO: show msg here 
                    $("#no-shifts").show();
                    //$("#calendar-container").hide();
                }
                //new shift picks
                $("#Staff_Type__c").empty();
                //$("#Staff_Type__c").append('<option value="none">--None--</option>');
                if(result && result.staff_type && result.staff_type.length > 0) {
                    $(result.staff_type).each(function(i, e) {
                        $("#Staff_Type__c").append('<option value="'+result.staff_type[i]+'">'+result.staff_type[i]+'</option>');
                    });
                }
                $("#Special_Skills__c").empty();
                //$("#Special_Skills__c").append('<option value="none">--None--</option>');
                if(result && result.special_skills && result.special_skills.length > 0) {
                    $(result.special_skills).each(function(i, e) {
                        $("#Special_Skills__c").append('<option value="'+result.special_skills[i]+'">'+result.special_skills[i]+'</option>');
                    });
                }
                $("#spinner").hide();
            },{escape:false});
        }else {
            alert('Please pass job requisition ID');
        }
    }
    initCal(); //invoke init
	$("#edit-slot").hide();

    $("#btn-edit-slot").click(function() {
        $("#slot-modal").show();
    });

    $(".close-info-modal").click(function() {
        $("#info-modal").hide();
    });

    $("#shift-info").click(function() {
        $("#info-modal").show();
    });
	

    $("#create-new-slot").click(function() {
        debugger;
        $("#slot-error-pannel").hide();
        let startDateText = $("#start-date").val();
        let endDateText = $("#end-date").val();
        let startTime = $("#start-time").val();
        let endTime = $("#end-time").val();
        let arrivalTime = $("#arrival-time").val();
        let startDate, endDate;
        if($('input[name="weekday"]:checked').length == 0 && (startTime === "" || endTime === "")) {
            if(startTime > endTime) {
                $("#slot-error-pannel").text("ERROR: Start time cannot preeced end time.");
                $("#slot-error-pannel").show();
                return;
            }
            $("#slot-error-pannel").text("ERROR: Please enter start time and end time.");
            $("#slot-error-pannel").show();
            return;
            
            
        }
        if(startDateText !== "" && endDateText !== "") {
            //Base level validations
            if(startDateText > endDateText) {
                $("#slot-error-pannel").text("ERROR: end date cannot preeced start date.");
                $("#slot-error-pannel").show();
                return;
            }
            if(arrivalTime === undefined || arrivalTime === "")
                arrivalTime = startTime;
            let slotName = moment(startDate).format('DD-MMM-YYYY') + ' - ' + moment(endDate).format('DD-MMM-YYYY');
            startTime = getUTC(startDateText+' '+startTime);
            endTime = getUTC(endDateText+' '+endTime);
            startDate = getUTC(startDateText);
            endDate = getUTC(endDateText);

            //call apex here
            let slot__c = {Job_Requisition__c : reqId, Name: slotName, Start_Date__c: startDate, End_Date__c: endDate, Created_From_Autosync__c :false};
            let selection = {};
            //TODO: handle other validations here.
            let selectedFrequency = $('input[name="shift-type"]:checked').val();
            let isForEachError = false;
            if(selectedFrequency === "weekly") {
                let selectedWeekdays = [];
                $('input[name="weekday"]:checked').each(function() {
                    let selectedWeekDay = $(this).val();
                    let dayStartTime,dayEndTime,dayArrivalTime;
                    if(selectedWeekDay === "Sun") {
                        dayStartTime = $("#sunday-start-time").val();
                        dayEndTime = $("#sunday-end-time").val();
                        dayArrivalTime = $("#sunday-arrival-time").val();
                        let customSunday = $("#sunday-custom")[0].checked;
                        if(customSunday == false) {
                            dayStartTime = getUTC(startDateText+' '+"00:00");
                            dayEndTime = getUTC(startDateText+' '+"23:59");
                        }else if(customSunday && (dayStartTime === "" || dayEndTime === "")) {
                            $("#slot-error-pannel").text("ERROR: Please select StartTime and EndTime for Sunday.");
                            $("#slot-error-pannel").show();
                            isForEachError = true;
                            return false;
                        }else {
                            dayStartTime = getUTC(startDateText+' '+dayStartTime);
                            dayEndTime = getUTC(startDateText+' '+dayEndTime);
                        }
                        //Validation
                        if(dayStartTime > dayEndTime) {
                            $("#slot-error-pannel").text("ERROR: On Sunday's schedule, start-time cannot preeced end-time.");
                            $("#slot-error-pannel").show();
                            return false;
                        }
                        if(dayArrivalTime === undefined || dayArrivalTime === "")
                            dayArrivalTime = dayStartTime;
                    }else if(selectedWeekDay === "Mon") {
						dayStartTime = $("#monday-start-time").val();
                        dayEndTime = $("#monday-end-time").val();
                        dayArrivalTime = $("#monday-arrival-time").val();
                        let customMonday = $("#monday-custom")[0].checked;
                        if(customMonday == false) {
                            dayStartTime = getUTC(startDateText+' '+"00:00");
                            dayEndTime = getUTC(startDateText+' '+"23:59");
                        }else if(customMonday && (dayStartTime === "" || dayEndTime === "")) {
                            $("#slot-error-pannel").text("ERROR: Please select StartTime and EndTime for Monday.");
                            $("#slot-error-pannel").show();
                            isForEachError = true;
                            return false;
                        }else {
                            dayStartTime = getUTC(startDateText+' '+dayStartTime);
                            dayEndTime = getUTC(startDateText+' '+dayEndTime);
                        }
                        
                        //Validation
                        if(dayStartTime > dayEndTime) {
                            $("#slot-error-pannel").text("ERROR: On Monday's schedule, start-time cannot preeced end-time.");
                            $("#slot-error-pannel").show();
                            return false;
                        }
                        if(dayArrivalTime === undefined || dayArrivalTime === "")
                            dayArrivalTime = dayStartTime;
                    }else if(selectedWeekDay === "Tue") {
						dayStartTime = $("#tuesday-start-time").val();
                        dayEndTime = $("#tuesday-end-time").val();
                        dayArrivalTime = $("#tuesday-arrival-time").val();
                        let customTuesday = $("#tuesday-custom")[0].checked;
                        if(customTuesday == false) {
                            dayStartTime = getUTC(startDateText+' '+"00:00");
                            dayEndTime = getUTC(startDateText+' '+"23:59");
                        }else if(customTuesday && (dayStartTime === "" || dayEndTime === "")) {
                            $("#slot-error-pannel").text("ERROR: Please select StartTime and EndTime for Tuesday.");
                            $("#slot-error-pannel").show();
                            isForEachError = true;
                            return false;
                        }else {
                            dayStartTime = getUTC(startDateText+' '+dayStartTime);
                            dayEndTime = getUTC(startDateText+' '+dayEndTime);
                        }
                        
                        //Validation
                        if(dayStartTime > dayEndTime) {
                            $("#slot-error-pannel").text("ERROR: On Tuesday's schedule, start-time cannot preeced end-time.");
                            $("#slot-error-pannel").show();
                            return false;
                        }
                        if(dayArrivalTime === undefined || dayArrivalTime === "")
                            dayArrivalTime = dayStartTime;
                    }else if(selectedWeekDay === "Wed") {
						dayStartTime = $("#wednesday-start-time").val();
                        dayEndTime = $("#wednesday-end-time").val();
                        dayArrivalTime = $("#wednesday-arrival-time").val();
                        let custom = $("#wednesday-custom")[0].checked;
                        if(custom == false) {
                            dayStartTime = getUTC(startDateText+' '+"00:00");
                            dayEndTime = getUTC(startDateText+' '+"23:59");
                        }else if(custom && (dayStartTime === "" || dayEndTime === "")) {
                            $("#slot-error-pannel").text("ERROR: Please select StartTime and EndTime for Wednesday.");
                            $("#slot-error-pannel").show();
                            isForEachError = true;
                            return false;
                        }else {
                            dayStartTime = getUTC(startDateText+' '+dayStartTime);
                            dayEndTime = getUTC(startDateText+' '+dayEndTime);
                        }
                        
                        //Validation
                        if(dayStartTime > dayEndTime) {
                            $("#slot-error-pannel").text("ERROR: On Wednesday's schedule, start-time cannot preeced end-time.");
                            $("#slot-error-pannel").show();
                            return false;
                        }
                        if(dayArrivalTime === undefined || dayArrivalTime === "")
                            dayArrivalTime = dayStartTime;
                    }else if(selectedWeekDay === "Thu") {
						dayStartTime = $("#thrusday-start-time").val();
                        dayEndTime = $("#thrusday-end-time").val();
                        dayArrivalTime = $("#thrusday-arrival-time").val();
                        let custom = $("#thrusday-custom")[0].checked;
                        if(custom == false) {
                            dayStartTime = getUTC(startDateText+' '+"00:00");
                            dayEndTime = getUTC(startDateText+' '+"23:59");
                        }else if(custom && (dayStartTime === "" || dayEndTime === "")) {
                            $("#slot-error-pannel").text("ERROR: Please select StartTime and EndTime for Thrusday.");
                            $("#slot-error-pannel").show();
                            isForEachError = true;
                            return false;
                        }else {
                            dayStartTime = getUTC(startDateText+' '+dayStartTime);
                            dayEndTime = getUTC(startDateText+' '+dayEndTime);
                        }
                        
                        //Validation
                        if(dayStartTime > dayEndTime) {
                            $("#slot-error-pannel").text("ERROR: On Thrusday's schedule, start-time cannot preeced end-time.");
                            $("#slot-error-pannel").show();
                            return false;
                        }
                        if(dayArrivalTime === undefined || dayArrivalTime === "")
                            dayArrivalTime = dayStartTime;
                    }else if(selectedWeekDay === "Fri") {
						dayStartTime = $("#friday-start-time").val();
                        dayEndTime = $("#friday-end-time").val();
                        dayArrivalTime = $("#friday-arrival-time").val();
                        let custom = $("#friday-custom")[0].checked;
                        if(custom == false) {
                            dayStartTime = getUTC(startDateText+' '+"00:00");
                            dayEndTime = getUTC(startDateText+' '+"23:59");
                        }else if(custom && (dayStartTime === "" || dayEndTime === "")) {
                            $("#slot-error-pannel").text("ERROR: Please select StartTime and EndTime for Friday.");
                            $("#slot-error-pannel").show();
                            isForEachError = true;
                            return false;
                        }else {
                            dayStartTime = getUTC(startDateText+' '+dayStartTime);
                            dayEndTime = getUTC(startDateText+' '+dayEndTime);
                        }
                        
                        //Validation
                        if(dayStartTime > dayEndTime) {
                            $("#slot-error-pannel").text("ERROR: On Friday's schedule, start-time cannot preeced end-time.");
                            $("#slot-error-pannel").show();
                            return false;
                        }
                        if(dayArrivalTime === undefined || dayArrivalTime === "")
                            dayArrivalTime = dayStartTime;
                    }else if(selectedWeekDay === "Sat") {
						dayStartTime = $("#saturday-start-time").val();
                        dayEndTime = $("#saturday-end-time").val();
                        dayArrivalTime = $("#saturday-arrival-time").val();
                        let custom = $("#saturday-custom")[0].checked;
                        if(custom == false) {
                            dayStartTime = getUTC(startDateText+' '+"00:00");
                            dayEndTime = getUTC(startDateText+' '+"23:59");
                        }else if(custom && (dayStartTime === "" || dayEndTime === "")) {
                            $("#slot-error-pannel").text("ERROR: Please select StartTime and EndTime for Saturday.");
                            $("#slot-error-pannel").show();
                            isForEachError = true;
                            return false;
                        }else {
                            dayStartTime = getUTC(startDateText+' '+dayStartTime);
                            dayEndTime = getUTC(startDateText+' '+dayEndTime);
                        }
                        
                        //Validation
                        if(dayStartTime > dayEndTime) {
                            $("#slot-error-pannel").text("ERROR: On Saturday's schedule, start-time cannot preeced end-time.");
                            $("#slot-error-pannel").show();
                            return false;
                        }
                        if(dayArrivalTime === undefined || dayArrivalTime === "")
                            dayArrivalTime = dayStartTime;
                    }
                    if(selectedWeekDay && dayStartTime && dayEndTime)
                    	selectedWeekdays.push({day: selectedWeekDay, startTime: dayStartTime, endTime: dayEndTime, arrivalTime: dayArrivalTime});
                });
                console.log('--- SELECTED WEEKDAYS',selectedWeekdays);
                /* if(selectedWeekdays.length === 0) {
                    $("#slot-error-pannel").text("ERROR: Please select days.");
                    $("#slot-error-pannel").show();
                    console.log('ERROR: Please select days.');
                    return;
                } */
                selection.frequency = "WEEKLY";
                selection.frequencies = selectedWeekdays;
            }else if(selectedFrequency === "monthly") {
                let selectedMonthlyFrequency = $('input[name="month-frequency-type"]:checked').val();
                let dayOfMonth;
                let weekOfMonth;
                let dayOfWeek;
                let subFrequency;
                if(selectedMonthlyFrequency === "on-month") {
                    dayOfMonth = $("#day-of-month").val();
                    subFrequency = "ON-MONTH";
                }else if(selectedMonthlyFrequency === "on-week") {
                    weekOfMonth = $("#week-of-month").val();
                    dayOfWeek = $("#day-of-week").val();
                    subFrequency = "ON-WEEK";
                }else {
                    $("#slot-error-pannel").text("ERROR: Please select all the required fields.");
                    $("#slot-error-pannel").show();
                    console.log('ERROR: Please select all the required fields.');
                    return;
                }
                selection.frequency = "MONTHLY";
                selection.subFrequency = subFrequency;
                selection.dayOfMonth = dayOfMonth;
                selection.weekOfMonth = weekOfMonth;
                selection.dayOfWeek = dayOfWeek;

            }
            if(isForEachError)
                return;
            console.log('SELECTION', selection);
            //create candidate shift attributes
            debugger;
            let shift__c = {};
            let No_Of_Required_Candidates__c = $("#No_Of_Required_Candidates__c").val();
            
            if(No_Of_Required_Candidates__c && No_Of_Required_Candidates__c != "" && parseInt(No_Of_Required_Candidates__c) > 0) {
                shift__c.No_Of_Required_Candidates__c = parseInt(No_Of_Required_Candidates__c);
            }else {
                $("#slot-error-pannel").text('ERROR: Please enter "Total Candidates Required"');
                $("#slot-error-pannel").show();
                return;
            }
            let Staff_Type__c = $("#Staff_Type__c").val();
            

            //Multiselect
            if(Staff_Type__c && Staff_Type__c.length > 0) {
                shift__c.Staff_Type__c = Staff_Type__c.join([separator = ';']);
            }else {
                $("#slot-error-pannel").text('ERROR: Please enter "Staff Type"');
                $("#slot-error-pannel").show();
                return;
            }

            let Special_Skills__c = $("#Special_Skills__c").val();
            //Multiselect
            if(Special_Skills__c && Special_Skills__c.length > 0) {
                shift__c.Special_Skills__c = Special_Skills__c.join([separator = ';']);
            }

            console.log(shift__c);
            $("#spinner").show();
            EditTemporaryJobShiftsExtention.createSlot(shift__c, slot__c, startTime, endTime, arrivalTime, JSON.stringify(selection), function(result, event) {
                if(event.status) {
                    debugger;
                    if(result) {
                        if(result === 'SUCCESS') {
                            //Revert buttons 
                            initCal();
                            alert('Job availability udpated successfully!');
                            $("#slot-modal").hide();
                            clearSlotForm();
                        }else if(result === 'ERROR') {
                            alert('Something went wrong, please contact system administrator.');
                        }else {
                            alert(result);
                        }
                    }
                    $("#spinner").hide();
                }
            });
        }else {
            //alert('Please fill all necessary details.');
            $("#slot-error-pannel").text("ERROR: Please enter start date and end date.");
            $("#slot-error-pannel").show();
        }
    });

    let getUTC = (dateVal) => {
        return Date.parse(dateVal)
    }

    $("#select-all-week").change(function() {
        console.log(this.checked);
        if(this.checked) {
            $('input[name="weekday"]').prop('checked',true);
        }else {
            $('input[name="weekday"]').prop('checked',false);
            $('input[name="custom"]').prop('checked',false);
            $(".sutc").hide();
            $(".mtc").hide();
            $(".ttc").hide();
            $(".wtc").hide();
            $(".thtc").hide();
            $(".ftc").hide();
            $(".satc").hide();
        }
    });

    $("#sunday-custom").click(function() {
        if($("#sunday-custom:checked").length === 1) {
            $("#sunday-check").prop('checked', true);
            $(".sutc").show();
        }else {
            $(".sutc").hide();
        }
    });

    $("#monday-custom").click(function() {
        if($("#monday-custom:checked").length === 1) {
            $("#monday-check").prop('checked', true);
            $(".mtc").show();
        }else {
            $(".mtc").hide();
        }
    });

    $("#tuesday-custom").click(function() {
        if($("#tuesday-custom:checked").length === 1) {
            $("#tuesday-check").prop('checked', true);
            $(".ttc").show();
        }else {
            $(".ttc").hide();
        }
    });

    $("#wednesday-custom").click(function() {
        if($("#wednesday-custom:checked").length === 1) {
            $("#wednesday-check").prop('checked', true);
            $(".wtc").show();
        }else {
            $(".wtc").hide();
        }
    });

    $("#thrusday-custom").click(function() {
        if($("#thrusday-custom:checked").length === 1) {
            $("#thrusday-check").prop('checked', true);
            $(".thtc").show();
        }else {
            $(".thtc").hide();
        }
    });

    $("#friday-custom").click(function() {
        if($("#friday-custom:checked").length === 1) {
            $("#friday-check").prop('checked', true);
            $(".ftc").show();
        }else {
            $(".ftc").hide();
        }
    });

    $("#saturday-custom").click(function() {
        if($("#saturday-custom:checked").length === 1) {
            $("#saturday-check").prop('checked', true);
            $(".satc").show();
        }else {
            $(".satc").hide();
        }
    });
    
    /* $("#delete-event").click(function() {
        debugger;
        if(selectedEvent) {
            if(selectedEvent.id) {
                $("#spinner").show();
                EditTemporaryJobShiftsExtention.deleteEvent(selectedEvent.id, function(result, event) {
                    if(event.status) {
                        $("#calendar").fullCalendar('removeEvents',selectedEvent._id);
                    }else {
                        alert('Something went wrong, please contact system admin.');
                    }
                    $('#event-modal').hide();
                    $("#spinner").hide();
                });
            }else {
                $("#calendar").fullCalendar('removeEvents',selectedEvent._id);
                $('#event-modal').hide();
            }
        }
    }); */

    /* $("#update-event").click(function() {
        if(selectedEvent) {
            $("#spinner").show();
            let updatedStatusVal = $("#selected-shift-status").val();
            EditTemporaryJobShiftsExtention.updateEvent(selectedEvent.id, function(result, event) {
                if(event.status) {
                    $("#calendar").fullCalendar('updateEvent',selectedEvent);
                }else {
                    alert('Something went wrong, please contact system admin.');
                }
                $('#event-modal').hide();
                $("#spinner").hide();
            });
        }
    }); */

    $(".close-modal").click(function(){
        console.log(selectedEvent);
        $('#event-modal').hide();
    });

    $(".close-slot-modal").click(function(){
        clearSlotForm();
        $('#slot-modal').hide();
    });

    let clearSlotForm = () => {
        $("#start-date").val("");
        $("#end-date").val("");
        $("#start-time").val("");
        $("#end-time").val("");
        $('input[name="weekday"]').prop('checked', false);
        $("#weekly").prop('checked', true);
        $("#monthly").prop('checked', false);
        $(".monthly-div").hide();
        $(".weekly-div").show();
        $("#select-all-week").prop('checked', false);
        $("#Staff_Type__c").val("");
		
        $("#slot-error-pannel").hide();
		
        $("#sunday-start-time").val("");
        $("#sunday-end-time").val("");
        
        $("#monday-start-time").val("");
        $("#monday-end-time").val("");
        
        $("#tuesday-start-time").val("");
        $("#tuesday-end-time").val("");
        
        $("#wednesday-start-time").val("");
        $("#wednesday-end-time").val("");
        
        $("#thrusday-start-time").val("");
        $("#thrusday-end-time").val("");
        
        $("#friday-start-time").val("");
        $("#friday-end-time").val("");
        
        $("#sunday-start-time").val("");
        $("#sunday-end-time").val("");
        
        $("#sunday-custom").prop('checked', false);
        $("#monday-custom").prop('checked', false);
        $("#tuesday-custom").prop('checked', false);
        $("#wednesday-custom").prop('checked', false);
        $("#thrusday-custom").prop('checked', false);
        $("#friday-custom").prop('checked', false);
        $("#saturday-custom").prop('checked', false);

        $("#sunday-check").prop('checked', false);
        $("#monday-check").prop('checked', false);
        $("#tuesday-check").prop('checked', false);
        $("#wednesday-check").prop('checked', false);
        $("#thrusday-check").prop('checked', false);
        $("#friday-check").prop('checked', false);
        $("#saturday-check").prop('checked', false);
    }

    $("#upsert-shifts").click(function() {
        if(dirtyShiftId.size > 0 && currentShifts.length > 0) {
            
            let shiftsToUpdate = [];
            let shift;
            dirtyShiftId.forEach((shiftID) => {
                shift = currentShifts.find((sft) => {
                    return sft.id === shiftID;
                });

                shiftsToUpdate.push({
                    Id: shift.id,
                    Start_DateTime__c: shift.start,
                    End_DateTime__c: shift.end,
                });
            });
        
        
            console.log('Records to upsert');
            console.log(shiftsToUpdate);
            $("#spinner").show();
            EditTemporaryJobShiftsExtention.upsertShifts(shiftsToUpdate, function(result, event) {
                if(event.status && result === 'SUCCESS') {
                    shiftsToUpdate = new Set();
                    $("#upsert-shifts").hide();
                }else {
                    alert('Something went wrong, please contact ondonte');
                }
                $("#spinner").hide();
            });
        }else {
            alert('Changes not found to update');
            $("#upsert-shifts").hide();
        }
    });


    $("input[type=radio][name=shift-type]").change(function() {
        debugger;
        if (this.value == 'weekly') {
            $(".monthly-div").hide();
            $(".weekly-div").show();
        }
        else if (this.value == 'monthly') {
            $(".weekly-div").hide();
            $(".monthly-div").show();
        }
    });
});