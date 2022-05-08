$(document).ready(function() {
    let currentShifts = []; // Calender Shifts
    let selectedEvent;
    let filterCity = '';
    let selectedStafftype = [];
    let contactId = candidateId;
    let selectedJobType = [];
    let selectedSkillType = [];
    debugger;

    var staffType = [];
    if(temShiftStaffType != "" && temShiftStaffType != undefined){
        var result = "";
        for (var i = 0; i < temShiftStaffType.length; i++) {
            var input = "<span><input type='checkbox' name='canStafftype' value='" + temShiftStaffType[i] + "'/>&nbsp;&nbsp;";
            var cbLabel = "<label>" + temShiftStaffType[i] + "</label>&nbsp;&nbsp;&nbsp;&nbsp;</spam>";
            $("#canStafftype").append(input + cbLabel);
        }
        //  document.getElementById('canStafftype').innerHTML = result;
    }
    if(temShiftSpecialSkills != "" && temShiftSpecialSkills != undefined){
        var result = "";
        for (var i = 0; i < temShiftSpecialSkills.length; i++) {
            var input = "<span><input type='checkbox' name='SkillType' value='" + temShiftSpecialSkills[i] + "'/>&nbsp;&nbsp;";
            var cbLabel = "<label>" + temShiftSpecialSkills[i] + "</label>&nbsp;&nbsp;&nbsp;&nbsp;</spam>";
            $("#canSkilltype").append(input + cbLabel);
        }
        //  document.getElementById('canStafftype').innerHTML = result;
    }


    selectedVal = function(){
        var checkboxes = document.querySelectorAll('input[name="canStafftype"]:checked')

        $('input[name="canStafftype"]:checked').each(function() {
            console.log(this.value);
            selectedJobType.push(this.value);
         });
         
        $('input[name="SkillType"]:checked').each(function() {
            console.log(this.value);
            selectedSkillType.push(this.value);
         });
    
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
                    /* $.each(currentShifts, function(i,shift) {
                        if (shift.id === event.id) {
                            currentShifts[i].start = event.start._d.getTime();
                            currentShifts[i].end = event.end._d.getTime();
                            console.log(currentShifts[i]);
                            dirtyShiftId.add(currentShifts[i].id)
                        }   
                    });
                    $("#upsert-shifts").show(); */
                }
            },
            eventClick: function (event, jsEvent, view) {
                debugger;
                selectedEvent = event;
                event.city ==undefined?$("#modal-heading-01").text(event.title):$("#modal-heading-01").text(event.title);



                // $("#modal-heading-01").text(event.title+"    "+event.city)
                $("#shift-no").text(event.shiftNumber);  
                $("#shift-status").text(event.status);
                $("#shift").text(event);
                $("#shift-st").text(event.startTime);
                $("#shift-et").text(event.endTime);
                $("#shift-city").text(event.city); 
                $("#shift-no").attr("href", window.location.origin+'/'+event.id);
                $("#shift-staff").text(event.staffType!= undefined?event.staffType.replaceAll(";"," "):event.staffType); 
                $("#skill-staff").text(event.skillType!= undefined?event.skillType.replaceAll(";"," "):event.skillType); 
                $("#event-modal").show();
                $("#delete-event").hide();
                if(event.haveShiftOnSameDay){
                    $("#save-event").hide();    
                    $("#delete-event").hide();
                    if(event.shiftAlreadyAllocated){
                        $("#delete-event").show();
                    }
                }else{
                    $("#save-event").show();
                }
               


                document.getElementById("recId").innerHTML = event.id;
                document.getElementById("startDate").innerHTML = event.start._d;
                document.getElementById("endDate").innerHTML = event.end._d;
                document.getElementById("startDateformat").innerHTML = event.start._d.getTime();
                document.getElementById("endDateFormat").innerHTML = event.end._d.getTime();
                document.getElementById("sTime").innerHTML = moment(event.start._d).format('MM/DD/YYYY'); 
                document.getElementById("eTime").innerHTML = moment(event.end._d).format('MM/DD/YYYY'); 

            },
            closeEventPopUp: function(){
                $("#event-modal").hide(); 
            },
            dayClick: function (date, jsEvent, view) {
                jsEvent.preventDefault();
                debugger;
                /* $("#start-date").val(moment(date._d).format("YYYY-MM-DD"));
                $("#end-date").val(moment(date._d).format("YYYY-MM-DD"));
                $("#slot-modal").show(); */
                
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
                debugger;      
                 if(event.shiftAlreadyAllocated == true) {
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
              
                var tooltip = '<div class="tooltipevent" style="background:#f4a52e;padding: 5px;position:absolute;z-index:10001;border: solid 1px;"><div><b>Shift No: </b>'+calEvent.shiftNumber+'</div><div style=""><b> Location: </b>' + calEvent.city + '</div><div><b>Start Time: </b>'+calEvent.startTime+'</div><div><b>End Time : </b>'+calEvent.endTime+'</div><div><b>Staff Type : </b>'+calEvent.staffType+'</div><div><b>Skill Type : </b>'+calEvent.skillType+'</div>';
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

    let initCal = () => {
        debugger;
        //if(contactId !== '') {
        	currentShifts = [];
        	selectedEvent = undefined;
         	allShifts = [];            
             $("#spinner").show();
             selectedVal();
             var filterCity = document.getElementById("city-input").value ;

            CandidateDashboard_Controller.getTempJobs(contactId,filterCity,selectedJobType,selectedSkillType, function (result, event) {

                console.log(result);
                debugger;
                //$('#calendar-card').hide();
                if(event.status && result && result.length > 0) {       // title: moment(result[i].shift.Start_DateTime__c).format("HH:mm")+' - '+moment(result[i].shift.End_DateTime__c).format("HH:mm"),
                    debugger;
                    $(result).each(function(i, e) {
                        let shift = {id: result[i].shift.Id, city: result[i].shift.City__c, staffType: result[i].shift.Staff_Type__c, skillType: result[i].shift.Special_Skills__c, title: result[i].shift.City__c+' '+moment(result[i].shift.Start_DateTime__c).format("HH:mm")+' - '+moment(result[i].shift.End_DateTime__c).format("HH:mm"), shiftNumber: result[i].shift.Name, start: result[i].shift.Start_DateTime__c, end:result[i].shift.End_DateTime__c, status: result[i].shift.Status__c, startTime: moment(result[i].shift.Start_DateTime__c).format("HH:mm"), endTime: moment(result[i].shift.End_DateTime__c).format("HH:mm"),haveShiftOnSameDay: result[i].haveShiftOnSameDay,shiftAlreadyAllocated: result[i].shiftAlreadyAllocated};
                        if(shift.status === "Allocated" || shift.status === "Not Available" || shift.status === "Assigned")
                            shift.editable = false;
                        allShifts.push(shift);
                    });
					currentShifts = allShifts;
                    selectedJobType = [];
                    selectedSkillType=[];
                    $("#spinner").hide();


                    configureCalendar();
                    
                    
                }else {
                    configureCalendar();
                    
                    
                }
                $("#spinner").hide();
            },{escape:false}); 
        /* }else {
            alert('Please pass candidate ID');
        } */
    }

    initCal();
    $(".close-modal").click(function(){
        console.log(selectedEvent);
        $('#event-modal').hide();
    });

    let getTimeFormat = (param1) =>{ 
        debugger;
        var timeString = param1;
        var H = +timeString.substr(0, 2);
        var h = (H % 12) || 12;
        var ampm = H < 12 ? " AM" : " PM";
        timeString = h + timeString.substr(2, 3) + ampm;
        return timeString;
      }

    $("#save-event").click(function(){
        console.log(selectedEvent);
        debugger;
        $("#spinner").show();
        var shiftId = document.getElementById("recId").innerHTML;
        var sDate = document.getElementById("sTime").innerHTML;
        var eDate = document.getElementById("eTime").innerHTML;
        var startDate = document.getElementById("startDate").innerHTML;
        var endDate = document.getElementById("endDate").innerHTML;
        var startDateformat = document.getElementById("startDateformat").innerHTML;
        var endDateFormat = document.getElementById("endDateFormat").innerHTML;
    
        var sDateArray = startDate.split(" ");
        var eDateArray = endDate.split(" ");
    
        var startTime = getTimeFormat(sDateArray[4]);
        var endTime = getTimeFormat(eDateArray[4]);

        CandidateDashboard_Controller.applyForShift(candidateId, shiftId, sDate, eDate, sDateArray[4], eDateArray[4],startDateformat,endDateFormat, function (result, event) {

                console.log(result);
                debugger;
                if(event.status) {
                    debugger;
                    $("#spinner").hide();
                    $("#event-modal").hide(); 

                    initCal();                    
                    
                }else {
                    initCal();                    
                    
                }
                $("#spinner").hide();
                $("#event-modal").hide(); 

            },{escape:false}); 
        /* }else {
            alert('Please pass candidate ID');
        } */
    });

    appplyFilter =  function(){
        initCal();
    }
   
    withdrawApln = function(){
        var shiftId = document.getElementById("recId").innerHTML;
        $("#spinner").show();

        CandidateDashboard_Controller.withdrawTempJob(candidateId, shiftId, function (result, event) {
          if (event.status) {
           
            $("#event-modal").hide(); 

            initCal();
          }
          $("#spinner").hide();
        }, { escape: false })
       

      }
    
});