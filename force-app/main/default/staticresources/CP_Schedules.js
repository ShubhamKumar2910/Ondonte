angular.module('cp_app').controller('cp_schdl_ctrl', function($scope,$rootScope) {
    debugger;
    $scope.candidateSchedules = [];
    $scope.ApplicationSchedules = [];
    console.log($rootScope);
    $rootScope.activeTab = 3;
    $scope.getAllEvents = function(){
        debugger;
        $scope.showSpinner = true;
        CandidateDashboard_Controller.getAllEvents($rootScope.candidateId, function (result, event) {

            if (event.status && result != null) {
                $scope.allEvents = result;
                for(var i=0;i< $scope.allEvents.length; i++){
                    if($scope.allEvents[i].WhoId != null){
                        $scope.candidateSchedules.push($scope.allEvents[i]);
                    }else{
                        $scope.ApplicationSchedules.push($scope.allEvents[i]);
                    }
                }
            }
            else {
            }
            $scope.showSpinner = false;
            $scope.$apply();
        }, { escape: false })
    }
});