app = angular.module('ExampleApp', ['ui.calendar','ui.bootstrap','ui.bootstrap.datetimepicker']);

app.controller('ExampleController', function($scope,$rootScope, $log, uiCalendarConfig, $timeout) {
  $scope.renderCalender = function(calendar) {
    console.log($scope.events)
    uiCalendarConfig.calendars.myCalendar.fullCalendar('removeEventSource', $scope.events)
  };
  $scope.uiCalendarConfig = uiCalendarConfig;
  $scope.events = [{
    "id": "51c54235fb4c960b37000014",
    "title": "Sample Event",
    "start": "2016-01-26T08:00:00+08:00",
    "end": "2016-01-26T10:00:00+08:00",
    "url": "http://google.com/",
    "allDay": false
  }];

  $scope.eventSources = [$scope.events];

  $scope.calendarConfig = {
    selectable: true,
    selectHelper: true,
    editable: true
  };
  
  $scope.eventRender = function( event, element, view ) { 
        element.attr({'tooltip': event.title,
                     'tooltip-append-to-body': true});
        $compile(element)($scope);
    };

  $scope.addEvent = function() {
    $scope.events.push({
      title: $scope.event.Title,
      start: $scope.event.startDate,
      end: $scope.event.endDate
    });
    console.log($scope.pendingRequests);
  };
  $scope.showIt = true;
  $scope.showCal = function() {
    $scope.showIt = !$scope.showIt;
    $scope.showIt && $timeout($scope.renderCalender);
  };


});