public withOut sharing class MatchingAlgorithm {
   
    public static double getMatchPercentage(dateTime candidateStartTime,dateTime candidateEndTime,dateTime shiftStartTime,dateTime shiftEndTime){
        double totalMiutes = 0;
        double totalShiftMinutes = (shiftEndTime.getTime()-shiftStartTime.getTime())/60000;
            if(candidateStartTime.getTime() >= shiftStartTime.getTime()){
                if(candidateEndTime.getTime() >= shiftEndTime.getTime()){
                    totalMiutes = (shiftEndTime.getTime()-candidateStartTime.getTime())/60000;
                    if(totalMiutes > 0){
                        return (totalMiutes/totalShiftMinutes)*100;
                    }else{
                        return 0;
                    }
                    
                }else if(candidateEndTime.getTime() <= shiftEndTime.getTime()){
                    totalMiutes = (candidateEndTime.getTime()-candidateStartTime.getTime())/60000;
                    if(totalMiutes > 0){
                        return (totalMiutes/totalShiftMinutes)*100;

                    }else{
                        return 0;
                    }
                }
            }else if(candidateStartTime.getTime() <= shiftStartTime.getTime()){
                if(candidateEndTime.getTime() >= shiftEndTime.getTime()){
                    totalMiutes = (shiftEndTime.getTime()-shiftStartTime.getTime())/60000;
                    if(totalMiutes > 0){
                        return (totalMiutes/totalShiftMinutes)*100;
                    }else{
                        return 0;
                    }
                }else if(candidateEndTime.getTime() <= shiftEndTime.getTime()){
                    totalMiutes = (candidateEndTime.getTime()-shiftStartTime.getTime())/60000;
                    if(totalMiutes > 0){
                        return (totalMiutes/totalShiftMinutes)*100;
                    }else{
                        return 0;
                    }
                }
            }
        return null;
    } 

    
}