//https://www.youtube.com/watch?v=XKD9UxvdbVU&list=RDjLNrvmXboj8&index=3
$(document).ready(function() {

    let currentShifts = [];
    let selectedEvent;
    let contactId = candidateId;
    let allShifts = [];
    let dirtyShiftId = new Set();
    
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
        $('#calendar').fullCalendar({
            header: {
                left: 'prev,next today',
                center: 'title',
                right: 'month,agendaWeek,agendaDay'
            },
            themeSystem: "standard",
            defaultDate: new Date(),
            navLinks: true,
            editable: true,
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
                selectedEvent = event;
                $("#modal-heading-01").text(event.title);
                $("#shift-no").text(event.shiftNumber);
                $("#shift-status").text(event.status);
                $("#shift-st").text(event.startTime);
                $("#shift-et").text(event.endTime);
                $("#shift-no").attr("href", window.location.origin+'/'+event.id);
                $("#event-modal").show();
                $("#not_avail_msg").show();
                $("#delete-event").show();
                if(event.status == "Allocated") {
                    $("#not_avail_msg").hide();
                    $("#delete-event").hide();
                }

            },
            dayClick: function (date, jsEvent, view) {
                jsEvent.preventDefault();
                debugger;
                $("#start-date").val(moment(date._d).format("YYYY-MM-DD"));
                $("#end-date").val(moment(date._d).format("YYYY-MM-DD"));
                $("#slot-modal").show();
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
                if(event.status === 'Assigned') {
                    element.find(".fc-content").css('background-color', '#15c05c');
                    element.find(".fc-day-grid-event").css('border-color','#15c05c !important');
                    element.find(".fc-bg").css('border','1px solid #15c05c');
                    element.find(".fc-day-grid-event").css('background-color','#15c05c !important');
                    element.css('border', '#15c05c');
                }else if(event.status === 'Not Available') {
                    element.find(".fc-content").css('background-color', 'red');
                    element.find(".fc-day-grid-event").css('border-color','red !important');
                    element.find(".fc-bg").css('border','1px solid red');
                    element.find(".fc-day-grid-event").css('background-color','red !important');
                    element.css('border', 'red');
                }else if(event.status === 'Allocated') {
                    element.find(".fc-content").css('background-color', '#4a4a4a');
                    element.find(".fc-bg").css('border','1px solid #4a4a4a');
                    element.find(".fc-day-grid-event").css('border-color','#4a4a4a !important');
                    element.find(".fc-day-grid-event").css('background-color','#4a4a4a !important');
                    element.css('border', '#4a4a4a');
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
                debugger;
                var tooltip = '<div class="tooltipevent" style="background:#f4a52e;padding: 5px;position:absolute;z-index:10001;border: solid 1px;"><span> <b>Status: </b>' + calEvent.status + '</span></div>';
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
    $("#profile-pic").prop("src",profilePicUrl !== '' ? profilePicUrl : "https://www.pngfind.com/pngs/m/610-6104451_image-placeholder-png-user-profile-placeholder-image-png.png");
    $("#profile-pic").show();
    let initCal = () => {
        if(contactId !== '') {
        	currentShifts = [];
        	selectedEvent = undefined;
         	allShifts = [];
        	dirtyShiftId = new Set();
            $("#spinner").show();
            CP_SchedulePlannerController.getInit(contactId,function(result, event) {
                console.log(result);
                debugger;
                //$('#calendar-card').hide();
                if(event.status && result && result.length > 0) {
                    $(result).each(function(i, e) {
                        let shift = {id: result[i].Id, title: moment(result[i].Start_DateTime__c).format("HH:mm")+' - '+moment(result[i].End_DateTime__c).format("HH:mm"), shiftNumber: result[i].Name, start: result[i].Start_DateTime__c, end:result[i].End_DateTime__c, status: result[i].Status__c, startTime: moment(result[i].Start_DateTime__c).format("HH:mm"), endTime: moment(result[i].End_DateTime__c).format("HH:mm")};
                        if(shift.status === "Allocated" || shift.status === "Not Available" || shift.status === "Assigned")
                            shift.editable = false;
                        allShifts.push(shift);
                    });
					currentShifts = allShifts;

                    

                    configureCalendar();
                    $("#no-shifts").hide();
                    //$("#calendar-container").show();
                }else {
                    configureCalendar();
                    $("#no-shifts").show();
                    //$("#calendar-container").hide();
                }
                $("#spinner").hide();
            },{escape:false});
        }else {
            alert('Please pass candidate ID');
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
            
            let slotName = moment(startDate).format('DD-MMM-YYYY') + ' - ' + moment(endDate).format('DD-MMM-YYYY');
            startTime = getUTC(startDateText+' '+startTime);
            endTime = getUTC(endDateText+' '+endTime);
            startDate = getUTC(startDateText);
            endDate = getUTC(endDateText);

            //call apex here
            let slot__c = {Contact__c : candidateId, Name: slotName, Start_Date__c: startDate, End_Date__c: endDate, Created_From_Autosync__c :false};
            let selection = {};
            //TODO: handle other validations here.
            let selectedFrequency = $('input[name="shift-type"]:checked').val();
            let isForEachError = false;
            if(selectedFrequency === "weekly") {
                let selectedWeekdays = [];
                $('input[name="weekday"]:checked').each(function() {
                    let selectedWeekDay = $(this).val();
                    let dayStartTime,dayEndTime;
                    if(selectedWeekDay === "Sun") {
                        dayStartTime = $("#sunday-start-time").val();
                        dayEndTime = $("#sunday-end-time").val();
                        let allDaySunday = $("#sunday-allday")[0].checked;
                        if(allDaySunday == false && (dayStartTime === "" || dayEndTime === "")) {
                            $("#slot-error-pannel").text("ERROR: Please select StartTime and EndTime for Sunday.");
                            $("#slot-error-pannel").show();
                            isForEachError = true;
                            return false;
                        }else if(allDaySunday) {
                            dayStartTime = getUTC(startDateText+' '+"00:00");
                            dayEndTime = getUTC(startDateText+' '+"23:59");
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
                    }else if(selectedWeekDay === "Mon") {
						dayStartTime = $("#monday-start-time").val();
                        dayEndTime = $("#monday-end-time").val();
                        let allDayMonday = $("#monday-allday")[0].checked;
                        if(allDayMonday == false && (dayStartTime === "" || dayEndTime === "")) {
                            $("#slot-error-pannel").text("ERROR: Please select StartTime and EndTime for Monday.");
                            $("#slot-error-pannel").show();
                            isForEachError = true;
                            return false;
                        }else if(allDayMonday) {
                            dayStartTime = getUTC(startDateText+' '+"00:00");
                            dayEndTime = getUTC(startDateText+' '+"23:59");
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
                    }else if(selectedWeekDay === "Tue") {
						dayStartTime = $("#tuesday-start-time").val();
                        dayEndTime = $("#tuesday-end-time").val();
                        let allDayTuesday = $("#tuesday-allday")[0].checked;
                        if(allDayTuesday == false && (dayStartTime === "" || dayEndTime === "")) {
                            $("#slot-error-pannel").text("ERROR: Please select StartTime and EndTime for Tuesday.");
                            $("#slot-error-pannel").show();
                            isForEachError = true;
                            return false;
                        }else if(allDayTuesday) {
                            dayStartTime = getUTC(startDateText+' '+"00:00");
                            dayEndTime = getUTC(startDateText+' '+"23:59");
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
                    }else if(selectedWeekDay === "Wed") {
						dayStartTime = $("#wednesday-start-time").val();
                        dayEndTime = $("#wednesday-end-time").val();
                        let allDay = $("#wednesday-allday")[0].checked;
                        if(allDay == false && (dayStartTime === "" || dayEndTime === "")) {
                            $("#slot-error-pannel").text("ERROR: Please select StartTime and EndTime for Wednesday.");
                            $("#slot-error-pannel").show();
                            isForEachError = true;
                            return false;
                        }else if(allDay) {
                            dayStartTime = getUTC(startDateText+' '+"00:00");
                            dayEndTime = getUTC(startDateText+' '+"23:59");
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
                    }else if(selectedWeekDay === "Thu") {
						dayStartTime = $("#thrusday-start-time").val();
                        dayEndTime = $("#thrusday-end-time").val();
                        let allDay = $("#thrusday-allday")[0].checked;
                        if(allDay == false && (dayStartTime === "" || dayEndTime === "")) {
                            $("#slot-error-pannel").text("ERROR: Please select StartTime and EndTime for Thrusday.");
                            $("#slot-error-pannel").show();
                            isForEachError = true;
                            return false;
                        }else if(allDay) {
                            dayStartTime = getUTC(startDateText+' '+"00:00");
                            dayEndTime = getUTC(startDateText+' '+"23:59");
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
                    }else if(selectedWeekDay === "Fri") {
						dayStartTime = $("#friday-start-time").val();
                        dayEndTime = $("#friday-end-time").val();
                        let allDay = $("#friday-allday")[0].checked;
                        if(allDay == false && (dayStartTime === "" || dayEndTime === "")) {
                            $("#slot-error-pannel").text("ERROR: Please select StartTime and EndTime for Friday.");
                            $("#slot-error-pannel").show();
                            isForEachError = true;
                            return false;
                        }else if(allDay) {
                            dayStartTime = getUTC(startDateText+' '+"00:00");
                            dayEndTime = getUTC(startDateText+' '+"23:59");
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
                    }else if(selectedWeekDay === "Sat") {
						dayStartTime = $("#saturday-start-time").val();
                        dayEndTime = $("#saturday-end-time").val();
                        let allDay = $("#saturday-allday")[0].checked;
                        if(allDay == false && (dayStartTime === "" || dayEndTime === "")) {
                            $("#slot-error-pannel").text("ERROR: Please select StartTime and EndTime for Saturday.");
                            $("#slot-error-pannel").show();
                            isForEachError = true;
                            return false;
                        }else if(allDay) {
                            dayStartTime = getUTC(startDateText+' '+"00:00");
                            dayEndTime = getUTC(startDateText+' '+"23:59");
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
                    }
                    if(selectedWeekDay && dayStartTime && dayEndTime)
                    	selectedWeekdays.push({day: selectedWeekDay, startTime:dayStartTime, endTime:dayEndTime });
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
            $("#spinner").show();
            CP_SchedulePlannerController.createSlot(slot__c, startTime, endTime, JSON.stringify(selection), function(result, event) {
                if(event.status) {
                    debugger;
                    if(result) {
                        if(result === 'SUCCESS') {
                            //Revert buttons 
                            initCal();
                            alert('Candidate availability udpated successfully!');
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
            $("#slot-error-pannel").text("ERROR: Please fill all necessary details.");
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
        }
    });
    
    $("#delete-event").click(function() {
        debugger;
        if(selectedEvent) {
            if(selectedEvent.id) {
                $("#spinner").show();
                CP_SchedulePlannerController.markNotAvailable(selectedEvent.id, function(result, event) {
                    if(event.status) {
                        selectedEvent.status = 'Not Available';
                        $("#calendar").fullCalendar('updateEvent',selectedEvent);
                    }else {
                        alert('Something went wrong, please contact system admin.');
                    }
                    $('#event-modal').hide();
                    $("#spinner").hide();
                });
            }else {
                //$("#calendar").fullCalendar('removeEvents',selectedEvent._id);
                $('#event-modal').hide();
            }
        }
    });

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
        
        $("#sunday-allday").prop('checked', false);
        $("#monday-allday").prop('checked', false);
        $("#tuesday-allday").prop('checked', false);
        $("#wednesday-allday").prop('checked', false);
        $("#thrusday-allday").prop('checked', false);
        $("#friday-allday").prop('checked', false);
        $("#saturday-allday").prop('checked', false);
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
            CP_SchedulePlannerController.upsertShifts(shiftsToUpdate, function(result, event) {
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