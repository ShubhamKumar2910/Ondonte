var allJobReq;
var temShiftStaffType;
var temShiftSpecialSkills;

angular.module('cp_app').controller('cp_tempjobs_ctrl', function ($scope, $rootScope, $log, $timeout) {
  debugger;
  var candidateId = $rootScope.candidateId;
  $scope.hasLoaded = false;

 // var myEvents = $rootScope.getAllEvents;
 $scope.temShiftStaffType = temShiftStaffType;
 $scope.temShiftSpecialSkills = temShiftSpecialSkills;
 $scope.selectedStafftype = [];
 $scope.filterCity = "";

 var myEvents = [];
  debugger;
  $rootScope.activeTab = 2;
  $scope.getTempJobs = function () {
    debugger;
    console.log('sjkdhsdhsdhsdk',$scope.events);
    if($scope.events!=undefined){
      $scope.events = [];
    }
//    $scope.events = [];

    CandidateDashboard_Controller.getTempJobs(candidateId,$scope.filterCity,$scope.selectedStafftype, function (result, event) {
      if (event.status) {
        $scope.allTempJobs = result;
        myEvents = result;
        //   $scope.addEvent();
        for (var i = 0; i < myEvents.length; i++) {
          $scope.events.push({
            "id": myEvents[i].shift.Id,
            "title": myEvents[i].shift.city,
           // "title": moment(myEvents[i].shift.Start_DateTime__c).format("hh:mm a")+" - " +moment(myEvents[i].shift.End_DateTime__c).format("hh:mm a"),
            "city":"BGRL",
            "name": myEvents[i].shift.Name,
            "start": myEvents[i].shift.Start_DateTime__c,
            "end": myEvents[i].shift.End_DateTime__c,
            "url": "",
            "DDD": false,
            "AR_Management__c": myEvents[i].shift.Id,
            "Assist_w_Nitrous_Administration__c": myEvents[i].shift.Assist_w_Nitrous_Administration__c,
            "Assisted_Hygiene__c": myEvents[i].shift.Assisted_Hygiene__c,
            "End_DateTime__c": myEvents[i].shift.End_DateTime__c,
            "General_Competency__c": myEvents[i].shift.General_Competency__c,
            "Goal_Oriented_scheduling__c": myEvents[i].shift.Goal_Oriented_scheduling__c,
            "Implants__c": myEvents[i].shift.Implants__c,
            "Insurance_Benefit_Coordination__c": myEvents[i].shift.Insurance_Benefit_Coordination__c,
            "Insurance_Processing__c": myEvents[i].shift.Insurance_Processing__c,
            "Insurance_Verification_and_Pre_Auth__c": myEvents[i].shift.Insurance_Verification_and_Pre_Auth__c,
            "Intraoral_Camera__c": myEvents[i].shift.Intraoral_Camera__c,
            "Invisalign__c": myEvents[i].shift.Invisalign__c,
            "Job_Requisition__c": myEvents[i].shift.Job_Requisition__c,
            "Loupes__c": myEvents[i].shift.Loupes__c,
            "Medicare_Billing__c": myEvents[i].shift.Medicare_Billing__c,
            "Micro_Ultrasonic__c": myEvents[i].shift.Micro_Ultrasonic__c,
            "Practice_Management_Software_Reports__c": myEvents[i].shift.Practice_Management_Software_Reports__c,
            "Prepare_Daily_Deposit__c": myEvents[i].shift.Prepare_Daily_Deposit__c,
            "Prepare_Day_Sheet__c": myEvents[i].shift.Prepare_Day_Sheet__c,
            "Recall_Maintenance__c": myEvents[i].shift.Recall_Maintenance__c,
            "Scan_Imaging__c": myEvents[i].shift.Scan_Imaging__c,
            "Staff_Type__c": myEvents[i].shift.Staff_Type__c,
            "Start_DateTime__c": myEvents[i].shift.Start_DateTime__c,
            "Status__c": myEvents[i].shift.Status__c,
            "Treatment_Plan_to_Goal__c": myEvents[i].shift.Treatment_Plan_to_Goal__c,
            'Treatment_Planning_Software__c': myEvents[i].shift.Treatment_Planning_Software__c,
            "Treatment_Presentation__c": myEvents[i].shift.Treatment_Presentation__c,
            "Types_of_Crowns__c": myEvents[i].shift.Types_of_Crowns__c,
            "Zoom_Bleaching__c": myEvents[i].shift.Zoom_Bleaching__c,
            "Computer_Skills__c": myEvents[i].shift.Computer_Skills__c,
            "backgroundColor": "",
            "RequiredSkills":myEvents[i].skillList,
            "shiftAlreadyAllocated":myEvents[i].shiftAlreadyAllocated,
            "haveShiftOnSameDay":myEvents[i].haveShiftOnSameDay,
           //  "address":myEvents[i].shift.Job_Requisition__r.Street_Address__c
    
          });

          
          if (myEvents[i].shift.Status__c == "Open" && !myEvents[i].shiftAlreadyAllocated) {
            $scope.events[i].backgroundColor = "Boston blue";
          }
          if ( myEvents[i].shiftAlreadyAllocated == true) {
            $scope.events[i].backgroundColor = "green";
          }
          if (myEvents[i].shift.Status__c == "Cancelled") {
            $scope.events[i].backgroundColor = "red";
          }

          
        }
        $scope.hasLoaded = true;
        $scope.$apply();
          $scope.selectedStafftype = [];
          $scope.filterCity = "";
      }
      else {
      }
    }, { escape: false })
  }
  $scope.getTempJobs();


  $scope.selectJobType = function(param){
    var selectedStaffIndex = $scope.selectedStafftype.indexOf(param);
    if(selectedStaffIndex >= 0 ){
      selectedStafftype.push(param);
    }else{
      $scope.selectedStafftype.splice(selectedStaffIndex,1);
    }
  }


  $scope.events = [];

 /*W if (myEvents != null) {
    debugger;
    for (var i = 0; i < myEvents.length; i++) {
      $scope.events.push({
        "id": myEvents[i].shift.Id,
        "title": moment(myEvents[i].shift.Start_DateTime__c).format("hh:mm a")+" - " +moment(myEvents[i].shift.End_DateTime__c).format("hh:mm a"),
        "name": myEvents[i].shift.Name,
        "start": myEvents[i].shift.Start_DateTime__c,
        "end": myEvents[i].shift.End_DateTime__c,
        "url": "",
        "DDD": false,
        "AR_Management__c": myEvents[i].shift.Id,
        "Assist_w_Nitrous_Administration__c": myEvents[i].shift.Assist_w_Nitrous_Administration__c,
        "Assisted_Hygiene__c": myEvents[i].shift.Assisted_Hygiene__c,
        "End_DateTime__c": myEvents[i].shift.End_DateTime__c,
        "General_Competency__c": myEvents[i].shift.General_Competency__c,
        "Goal_Oriented_scheduling__c": myEvents[i].shift.Goal_Oriented_scheduling__c,
        "Implants__c": myEvents[i].shift.Implants__c,
        "Insurance_Benefit_Coordination__c": myEvents[i].shift.Insurance_Benefit_Coordination__c,
        "Insurance_Processing__c": myEvents[i].shift.Insurance_Processing__c,
        "Insurance_Verification_and_Pre_Auth__c": myEvents[i].shift.Insurance_Verification_and_Pre_Auth__c,
        "Intraoral_Camera__c": myEvents[i].shift.Intraoral_Camera__c,
        "Invisalign__c": myEvents[i].shift.Invisalign__c,
        "Job_Requisition__c": myEvents[i].shift.Job_Requisition__c,
        "Loupes__c": myEvents[i].shift.Loupes__c,
        "Medicare_Billing__c": myEvents[i].shift.Medicare_Billing__c,
        "Micro_Ultrasonic__c": myEvents[i].shift.Micro_Ultrasonic__c,
        "Practice_Management_Software_Reports__c": myEvents[i].shift.Practice_Management_Software_Reports__c,
        "Prepare_Daily_Deposit__c": myEvents[i].shift.Prepare_Daily_Deposit__c,
        "Prepare_Day_Sheet__c": myEvents[i].shift.Prepare_Day_Sheet__c,
        "Recall_Maintenance__c": myEvents[i].shift.Recall_Maintenance__c,
        "Scan_Imaging__c": myEvents[i].shift.Scan_Imaging__c,
        "Staff_Type__c": myEvents[i].shift.Staff_Type__c,
        "Start_DateTime__c": myEvents[i].shift.Start_DateTime__c,
        "Status__c": myEvents[i].shift.Status__c,
        "Treatment_Plan_to_Goal__c": myEvents[i].shift.Treatment_Plan_to_Goal__c,
        'Treatment_Planning_Software__c': myEvents[i].shift.Treatment_Planning_Software__c,
        "Treatment_Presentation__c": myEvents[i].shift.Treatment_Presentation__c,
        "Types_of_Crowns__c": myEvents[i].shift.Types_of_Crowns__c,
        "Zoom_Bleaching__c": myEvents[i].shift.Zoom_Bleaching__c,
        "Computer_Skills__c": myEvents[i].shift.Computer_Skills__c,
        "backgroundColor": "",
        "RequiredSkills":myEvents[i].skillList,
        "shiftAlreadyAllocated":myEvents[i].shiftAlreadyAllocated,
        "haveShiftOnSameDay":myEvents[i].haveShiftOnSameDay,
       //  "address":myEvents[i].shift.Job_Requisition__r.Street_Address__c

      });
      if (myEvents[i].shift.Status__c == "Open") {
        $scope.events[i].backgroundColor = "green";
      }
      if ( myEvents[i].shiftAlreadyAllocated == true) {
        $scope.events[i].backgroundColor = "grey";
      }
      if (myEvents[i].shift.Status__c == "Cancelled") {
        $scope.events[i].backgroundColor = "red";
      }
    }
  }  */


  $scope.getTimeFormat = function (param1) {
    debugger;
    var timeString = param1;
    var H = +timeString.substr(0, 2);
    var h = (H % 12) || 12;
    var ampm = H < 12 ? " AM" : " PM";
    timeString = h + timeString.substr(2, 3) + ampm;
    return timeString;
  }

  $scope.applyJob = function () {
    debugger;
    var shiftId = document.getElementById("recId").innerHTML;
    var sDate = document.getElementById("sTime").innerHTML;
    var eDate = document.getElementById("eTime").innerHTML;
    var startDate = document.getElementById("startDate").innerHTML;
    var endDate = document.getElementById("endDate").innerHTML;
    var startDateformat = document.getElementById("startDateformat").innerHTML;
    var endDateFormat = document.getElementById("endDateFormat").innerHTML;

    var sDateArray = startDate.split(" ");
    var eDateArray = endDate.split(" ");

    var startTime = $scope.getTimeFormat(sDateArray[4]);
    var endTime = $scope.getTimeFormat(eDateArray[4]);

    CandidateDashboard_Controller.applyForShift(candidateId, shiftId, sDate, eDate, sDateArray[4], eDateArray[4],startDateformat,endDateFormat, function (result, event) {
      if (event.status) {
        Swal.fire(
          '',
          'Applied successfully!',
          'success'
        )
        $("#myModal").modal('hide');
        $scope.getTempJobs();
      }
      else {
      }
    }, { escape: false })

  }

  $scope.withdrawTempJob = function(){
    var shiftId = document.getElementById("recId").innerHTML;
    CandidateDashboard_Controller.withdrawTempJob(candidateId, shiftId, function (result, event) {
      if (event.status) {
        Swal.fire(
          '',
          'Applied successfully!',
          'success'
        )
        $("#myModal").modal('hide');
        $scope.getTempJobs();
      }
      else {
      }
    }, { escape: false })
    
  }

  $scope.closeShiftPopup = function(){
    $("#myModal").modal('hide');
  }

});