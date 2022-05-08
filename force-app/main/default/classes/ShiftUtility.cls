/**
 * Author: Prithvi
 * Date: 10th Feb
 */
public without sharing class ShiftUtility {
    
    static final String EXCEPTION_MSG = 'Invalid params to create Shift';
    static final Map<String,Integer> UI_TO_APEX_WEEK_MAP = new Map<String,Integer> {'1st'=> 1, '2nd' => 2, '3rd' => 3, '4th' => 4, 'last' => -1};
    static final String SHIFT_STATUS_AVAILABLE = 'Available';
    static final String SHIFT_STATUS_OPEN = 'Open';
    public static final String SHIFT_CANDIDATE_RECORD_TYPE = 'Candidate';
    public static final String SHIFT_CLIENT_RECORD_TYPE = 'Client';
    
    /*
    * Given proper data, this method creates shift records accordingly.
    */
    public static void createShifts(Shift__c shift, Slot__c slot, DateTime startTime, DateTime endTime, String arrivalTime, Map<String, Map<String,Object>> dayOfWeekMap, Boolean isCandidateShift) {

        if(slot == null || dayOfWeekMap == null)
            throw new ShiftException(EXCEPTION_MSG);
        
        Date currentDate = slot.Start_Date__c;
        List<Shift__c> shiftsPerSlot = new List<Shift__c>();
        System.debug(currentDate.daysBetween(slot.End_Date__c));
        String dayOfWeek;
        DateTime dayOfWeekCounterTime = DateTime.newInstance(currentDate.year(), currentDate.month(), currentDate.day(), 0, 0, 0);
        Time reportingTime = !String.isBlank(arrivalTime) ? getArrivalTime(arrivalTime) : null;
        while (currentDate.daysBetween(slot.End_Date__c) >= 0) {
            dayOfWeek = dayOfWeekCounterTime.format('E');
            if(dayOfWeekMap.isEmpty() && startTime != null && endTime != null) {
                startTime = startTime.addDays(1);
                endTime = endTime.addDays(1);
                DateTime shiftStartTime = DateTime.newInstance(dayOfWeekCounterTime.year(), dayOfWeekCounterTime.month(), dayOfWeekCounterTime.day(), startTime.hour(), startTime.minute(), startTime.second());
                DateTime shiftEndTime = DateTime.newInstance(dayOfWeekCounterTime.year(), dayOfWeekCounterTime.month(), dayOfWeekCounterTime.day(), endTime.hour(), endTime.minute(), endTime.second());
                System.debug('--- generic shiftStartTime'+shiftStartTime);
                System.debug('--- generic shiftEndTime'+shiftEndTime);
                if(isCandidateShift)
                    shiftsPerSlot.add(getCandidateShift(Slot.Contact__c, shiftStartTime, shiftEndTime, slot.Id));
                else
                    shiftsPerSlot.add(getRequisitionShift(shift, Slot.Job_Requisition__c, shiftStartTime, shiftEndTime, slot.Id, reportingTime));
            }else if(dayOfWeekMap.containsKey(dayOfWeek) && dayOfWeekMap.get(dayOfWeek).containsKey('startTime') && dayOfWeekMap.get(dayOfWeek).containsKey('endTime')) {
                DateTime startWeekdayTime = (DateTime)dayOfWeekMap.get(dayOfWeek).get('startTime');
                DateTime endWeekdayTime = (DateTime)dayOfWeekMap.get(dayOfWeek).get('endTime');
                DateTime shiftStartTime = DateTime.newInstance(dayOfWeekCounterTime.year(), dayOfWeekCounterTime.month(), dayOfWeekCounterTime.day(), startWeekdayTime.hour(), startWeekdayTime.minute(), startWeekdayTime.second());
                DateTime shiftEndTime = DateTime.newInstance(dayOfWeekCounterTime.year(), dayOfWeekCounterTime.month(), dayOfWeekCounterTime.day(), endWeekdayTime.hour(), endWeekdayTime.minute(), endWeekdayTime.second());
                Time reportingDayTime = dayOfWeekMap.get(dayOfWeek).containsKey('arrivalTime') ? getArrivalTime((String)dayOfWeekMap.get(dayOfWeek).get('arrivalTime')) : null;
                System.debug('--- week specific shiftStartTime'+shiftStartTime);
                System.debug('--- week specific shiftEndTime'+shiftEndTime);
                
                if(isCandidateShift)
                    shiftsPerSlot.add(getCandidateShift(Slot.Contact__c, shiftStartTime, shiftEndTime, slot.Id));
                else
                    shiftsPerSlot.add(getRequisitionShift(shift, Slot.Job_Requisition__c, shiftStartTime, shiftEndTime, slot.Id, reportingDayTime));				
            }
            currentDate = currentDate.addDays(1);
            dayOfWeekCounterTime = dayOfWeekCounterTime.addDays(1);
            
        }
        String responseErrorMessage = ''; //TODO:
        if(!shiftsPerSlot.isEmpty()) {
            Database.SaveResult[] shiftResultList = Database.insert(shiftsPerSlot, false);
            for (Integer i=0; i < shiftResultList.size(); i++) {
                if (!shiftResultList[i].isSuccess()) {
                    // Operation failed, so get all errors   
                    for(Database.Error err : shiftResultList[i].getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Shift__c fields that affected this error: ' + err.getFields());
                        responseErrorMessage += err.getMessage()+'\n';
                    }
                }
            }
            System.debug('--- Shift to insert '+ shiftsPerSlot);
            System.debug('--- Total Shift to insert '+ shiftsPerSlot.size());
            system.debug('--- shiftResultList '+shiftResultList);
        }
        
    }

    private static Time getArrivalTime(String arrivalTime) {
        if(arrivalTime == null || arrivalTime == '' || !arrivalTime.contains(':'))
            return null;
        List<String> arrivalTimeSplit = arrivalTime.split(':');
        if(arrivalTimeSplit != null && arrivalTimeSplit.size() == 2) {
            return Time.newInstance(Integer.valueOf(arrivalTimeSplit[0]), Integer.valueOf(arrivalTimeSplit[1]), 0, 0);
        }
        return null;
    }

    private static Shift__c getCandidateShift(Id candidateId, DateTime startDateTime, DateTime endDateTime, Id slotId) {
        return new Shift__c(Contact__c = candidateId, Start_DateTime__c = startDateTime, End_DateTime__c = endDateTime, RecordTypeId = getCandidateShiftRTId(), Status__c = SHIFT_STATUS_AVAILABLE, Slot__c = slotId);

        //new Shift__c(Status__c = SHIFT_STATUS_AVAILABLE, RecordTypeId = shiftCandidateRTId, Slot__c = slot.Id, Start_DateTime__c = startTime, End_DateTime__c = endTime, Contact__c = slot.Contact__c)
    }

    private static Shift__c getRequisitionShift(Shift__c shift, Id requisitionId, DateTime startDateTime, DateTime endDateTime, Id slotId, Time reportingTime) {
        if(shift == null)
            return new Shift__c(Job_Requisition__c = requisitionId, Start_DateTime__c = startDateTime, End_DateTime__c = endDateTime, RecordTypeId = getClientShiftRTId(), Status__c = SHIFT_STATUS_OPEN, Slot__c = slotId);
        else {
            Shift__c requestedSkillsShift = shift.clone(false,false,false,false);
            requestedSkillsShift.Job_Requisition__c = requisitionId;
            requestedSkillsShift.Start_DateTime__c = startDateTime;
            requestedSkillsShift.End_DateTime__c = endDateTime;
            requestedSkillsShift.RecordTypeId = getClientShiftRTId();
            requestedSkillsShift.Status__c = SHIFT_STATUS_OPEN;
            requestedSkillsShift.Slot__c = slotId;
            requestedSkillsShift.Arrival_Time_Before__c = reportingTime;
            return requestedSkillsShift;
        }
    }
    
    public static void createMonthlyShifts(Shift__c shift, Slot__c slot, DateTime startTime, DateTime endTime, String arrivalTime, Integer dayOfMonth, Boolean isCandidateShift) {
        if(startTime == null || endTime == null || slot == null || dayOfMonth == null)
            throw new ShiftException(EXCEPTION_MSG);
        
        Date today = Date.today();
        Integer monthToStartWith = slot.Start_Date__c.month();
        if(today.year() == slot.Start_Date__c.year() && today.month() == slot.Start_Date__c.month() && today.day() >= dayOfMonth) {
            monthToStartWith++;
        }
        Date currentDate = Date.newInstance(slot.Start_Date__c.year(), monthToStartWith, dayOfMonth);
        startTime = DateTime.newInstance(startTime.year(), startTime.month(), dayOfMonth, startTime.hour(), startTime.minute(), startTime.second());
        endTime = DateTime.newInstance(startTime.year(), startTime.month(), dayOfMonth, endTime.hour(), endTime.minute(), endTime.second());
        
        List<Shift__c> shiftsPerSlot = new List<Shift__c>();
        System.debug(currentDate.daysBetween(slot.End_Date__c));
        Time reportingTime = !String.isBlank(arrivalTime) ? getArrivalTime(arrivalTime) : null;
        while (currentDate.daysBetween(slot.End_Date__c) >= 0) {
            if(currentDate.month() == 2 && Date.isLeapYear(currentDate.year()) && dayOfMonth > 29) {
                continue;
            }else if(currentDate.month() == 2 && !Date.isLeapYear(currentDate.year()) && dayOfMonth > 28) {
                continue;
            }
            //shiftsPerSlot.add(new Shift__c(Status__c = SHIFT_STATUS_AVAILABLE, RecordTypeId = shiftCandidateRTId, Slot__c = slot.Id, Start_DateTime__c = startTime, End_DateTime__c = endTime, Contact__c = slot.Contact__c));
            if(isCandidateShift)
                shiftsPerSlot.add(getCandidateShift(slot.Contact__c, startTime, endTime, slot.Id));
            else
                shiftsPerSlot.add(getRequisitionShift(shift, Slot.Job_Requisition__c, startTime, endTime, slot.Id, reportingTime));

            startTime = startTime.addMonths(1);
            endTime = endTime.addMonths(1);
            currentDate = currentDate.addMonths(1);            
        }
        if(!shiftsPerSlot.isEmpty()) {
            Database.SaveResult[] shiftResultList = Database.insert(shiftsPerSlot, false);
            System.debug('--- shiftResultList '+ shiftResultList);
            System.debug('--- Slots to insert '+ shiftsPerSlot);
            System.debug('--- Total Slots to insert '+ shiftsPerSlot.size());
        }
    }
    
    
    public static void createWeeklyShifts(Shift__c shift, Slot__c slot, DateTime startTime, DateTime endTime, String arrivalTime, String weekOfMonth, String requestedDayOfWeek, Boolean isCandidateShift) {
        if(startTime == null || endTime == null || slot == null || String.isBlank(weekOfMonth) || requestedDayOfWeek == null)
            throw new ShiftException(EXCEPTION_MSG);
        
        Date currentDate = slot.Start_Date__c;
        List<Shift__c> shiftsPerSlot = new List<Shift__c>();
        System.debug(currentDate.daysBetween(slot.End_Date__c));
        String currentDayOfWeek;
        Time reportingTime = !String.isBlank(arrivalTime) ? getArrivalTime(arrivalTime) : null;
        while (currentDate.daysBetween(slot.End_Date__c) >= 0) {
            Integer currentWeek = currentWeekOfMonth(currentDate);
           
            Integer requestedWeek = stringToWeekOfMonth(weekOfMonth);
            if(requestedWeek == -1) {
                requestedWeek = getLastWeekOfMonth(currentDate); 
            }
            currentDayOfWeek = startTime.format('E');
            if(currentDayOfWeek == requestedDayOfWeek && currentWeek == requestedWeek) {
                //shiftsPerSlot.add(new Shift__c(Status__c = SHIFT_STATUS_AVAILABLE, RecordTypeId = shiftCandidateRTId, Slot__c = slot.Id, Start_DateTime__c = startTime, End_DateTime__c = endTime, Contact__c = slot.Contact__c));
                if(isCandidateShift)
                    shiftsPerSlot.add(getCandidateShift(slot.Contact__c, startTime, endTime, slot.Id));
                else
                    shiftsPerSlot.add(getRequisitionShift(shift, Slot.Job_Requisition__c, startTime, endTime, slot.Id, reportingTime));
            }
            startTime = startTime.addDays(1);
            endTime = endTime.addDays(1);
            currentDate = currentDate.addDays(1);            
        }
        if(!shiftsPerSlot.isEmpty()) {
            Database.SaveResult[] shiftResultList = Database.insert(shiftsPerSlot, false);
            System.debug('--- Slots to insert '+ shiftsPerSlot);
            System.debug('--- Total Slots to insert '+ shiftsPerSlot.size());
        }
    }
    
    static Integer stringToWeekOfMonth(String weekOfMonth) {
        return UI_TO_APEX_WEEK_MAP.get(weekOfMonth); 
    }
    
    static Integer getLastWeekOfMonth(Date currentDate) {
        return currentWeekOfMonth(currentDate.addMonths(1).toStartofMonth().addDays(-1)); 
    }
    
    
    public static Integer currentWeekOfMonth(Date currentDate) {
        Integer weekCount = 0;
        Integer startWeekResidue = 0;
        Integer endWeekResidue = 0;
        /*
        Calculating startWeekResidue
        */
        Date dt = currentDate.toStartOfMonth().addDays(-1);
        Date dtFirstWeekend = dt.toStartOfWeek().addDays(6);
        startWeekResidue = dt.daysBetween(dtFirstWeekend); 
        
        /*
        Calculating endWeekResidue
        */
        Date dtLastWeekend = currentDate.toStartOfWeek().addDays(-1);
        endWeekResidue = dtLastWeekend.daysBetween(currentDate);
        /*
        Counting the weeks
        */
        weekCount = (currentDate.day() - (startWeekResidue + endWeekResidue))/7;
        weekCount += (startWeekResidue > 0 ? 1:0)+(endWeekResidue > 0 ? 1:0);
        System.debug(weekCount);
        return weekCount;
    }


    
    private static void createShiftsHelper(Slot__c slot, DateTime startTime, DateTime endTime, List<String> dayOfWeekSet, List<Shift__c> shiftList) {
        if(startTime == null || endTime == null || slot == null || dayOfWeekSet == null || dayOfWeekSet.isEmpty())
            throw new ShiftException(EXCEPTION_MSG);
        Date currentDate = System.today();
        String dayOfWeek;
        while (currentDate.daysBetween(slot.End_Date__c) >= 0) {
            dayOfWeek = startTime.format('E');
            if(dayOfWeekSet.contains(dayOfWeek)) {
                shiftList.add(new Shift__c(Status__c = SHIFT_STATUS_AVAILABLE, RecordTypeId = getCandidateShiftRTId(), Slot__c = slot.Id, Start_DateTime__c = startTime, End_DateTime__c = endTime, Contact__c = slot.Contact__c));
            }
            startTime = startTime.addDays(1);
            endTime = endTime.addDays(1);
            currentDate = currentDate.addDays(1);
            
        }
        
    }

    static Id candidateShiftRecordTypeId;
    public static Id getCandidateShiftRTId() {
        if(candidateShiftRecordTypeId == null) {
            candidateShiftRecordTypeId = Schema.SObjectType.Shift__c.getRecordTypeInfosByName().get(SHIFT_CANDIDATE_RECORD_TYPE).getRecordTypeId();
        }
        return candidateShiftRecordTypeId;
    }

    static Id jobShiftRecordTypeId;
    public static Id getClientShiftRTId() {
        if(jobShiftRecordTypeId == null) 
            jobShiftRecordTypeId = Schema.SObjectType.Shift__c.getRecordTypeInfosByName().get(SHIFT_CLIENT_RECORD_TYPE).getRecordTypeId();
        return jobShiftRecordTypeId;
    }


    
    public static void handleShiftAlignment(List<Id> shiftAlignmentCandidateIdList) {
        Savepoint sp = Database.setSavepoint();
        try {
            System.debug('--- candidate Ids for alignment '+shiftAlignmentCandidateIdList);
            clearUnusedCandidateShifts(shiftAlignmentCandidateIdList);
            List<Contact> candidatesList = [SELECT Id, Preferred_Working_Days__c, Preferred_Start_Time__c, Preferred_End_Time__c, Last_Shift_Synced_On__c FROM Contact WHERE Id IN :shiftAlignmentCandidateIdList];
            shiftAlignmentHelper(candidatesList);
        }catch(Exception e) {
            Database.rollback(sp);
            HandleBusinessException.captureError('ShiftUtility', 'FUTURE:handleShiftAlignment', e);
        }
    }

    public static void handleShiftAlignment(List<Id> shiftAlignmentCandidateIdList, List<Contact> candidatesList) {
        Savepoint sp = Database.setSavepoint();
        try {
            clearUnusedCandidateShifts(shiftAlignmentCandidateIdList);
            shiftAlignmentHelper(candidatesList);
        }catch(Exception e) {
            Database.rollback(sp);
            HandleBusinessException.captureError('ShiftUtility', 'FUTURE:handleShiftAlignment', e);
        }
    }

    private static void clearUnusedCandidateShifts(List<Id> shiftAlignmentCandidateIdList) {
        //Open, Filled, Canceled, or Could not Fill.  For the Candidate they are: Available, Not Available, or Assigned.
        if(shiftAlignmentCandidateIdList.isEmpty())
            throw new ShiftException('Error: Invalid params to process shift alignment');
        List<Shift__c> shiftsToDelete = [SELECT Id FROM Shift__c WHERE Contact__c IN :shiftAlignmentCandidateIdList AND RecordTypeId =:getCandidateShiftRTId() AND Status__c = :SHIFT_STATUS_AVAILABLE];
        if(!shiftsToDelete.isEmpty()) {
            delete shiftsToDelete;
        }
        
        List<Slot__c> emptySlotList = [SELECT Id FROM Slot__c WHERE Contact__c IN:shiftAlignmentCandidateIdList AND Id NOT IN (SELECT Slot__c FROM Shift__c WHERE Contact__c IN:shiftAlignmentCandidateIdList)];
        System.debug('-- unused slots'+emptySlotList);
        if(!emptySlotList.isEmpty()) {
            delete emptySlotList;
            System.debug('-- unused slots deletion successfull'+emptySlotList);
        }
    }

    private static void shiftAlignmentHelper(List<Contact> candidatesList) {
        if(candidatesList == null || candidatesList.isEmpty()) {
            throw new ShiftException('Error: Invalid candidates data');
        }
        List<Shift__c> candidateShiftList = new List<Shift__c>();
        Ondonte_Configuration__c ondonteConfig = Ondonte_Configuration__c.getOrgDefaults();
        if(ondonteConfig == null || ondonteConfig.Number_Of_Future_Days_for_Shifts__c == null || ondonteConfig.Number_Of_Future_Days_for_Shifts__c <= 0)
            throw new ShiftException('Error: Couldn\'t find Ondonte configuration.');

        Date startDay = System.today();
        Date endDay = startDay.addDays(Integer.valueOf(ondonteConfig.Number_Of_Future_Days_for_Shifts__c));

        Map<Id,Slot__c> candidateToSlotMap = new Map<Id,Slot__c>();
        Map<Id,CandidateSlotToShiftWrapper> candidateToShiftMap = new Map<Id,CandidateSlotToShiftWrapper>();
        DateTime startTime, endTime;
        
        for(Contact candidate: candidatesList) {
            if(candidate.Preferred_Working_Days__c != null) {
                List<String> preferredDaysList = candidate.Preferred_Working_Days__c.split(';');
                if(candidate.Preferred_Start_Time__c != null && candidate.Preferred_End_Time__c != null) {
                    startTime = DateTime.newInstance(startDay, candidate.Preferred_Start_Time__c);
                    endTime = DateTime.newInstance(startDay, candidate.Preferred_End_Time__c);
                }else {
                    startTime = DateTime.newInstance(startDay.year(), startDay.month(), startDay.day(), 0, 0, 1);
                    endTime = DateTime.newInstance(startDay.year(), startDay.month(), startDay.day(), 23, 59, 59);
                }
                candidateToShiftMap.put(candidate.Id, new CandidateSlotToShiftWrapper(startTime, endTime, preferredDaysList));
                candidateToSlotMap.put(candidate.Id, new Slot__c(Contact__c = candidate.Id, Name = startDay.format()+' - '+endDay.format(), Start_Date__c = startDay, End_Date__c = endDay, Created_From_Autosync__c = true));
            }
        }

        if(!candidateToSlotMap.isEmpty() && !candidateToShiftMap.isEmpty()) {
            insert candidateToSlotMap.values();
            for(Id candidateId : candidateToSlotMap.keySet()) {
                if(candidateToShiftMap.containsKey(candidateId)) {
                    createShiftsHelper(candidateToSlotMap.get(candidateId), candidateToShiftMap.get(candidateId).startDatetime, candidateToShiftMap.get(candidateId).endDatetime, candidateToShiftMap.get(candidateId).preferredDaysList, candidateShiftList);
                }
            }
            if(!candidateShiftList.isEmpty()) {
                List<Database.SaveResult> shiftInsertResultList = Database.insert(candidateShiftList, false);
                // Iterate through each returned result
                Set<Id> failedCandidateIdSet = new Set<Id>();
                Set<Id> successCandidateIdSet = new Set<Id>();

                for (Integer i=0; i < shiftInsertResultList.size(); i++) {
                    if (shiftInsertResultList[i].isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted account. Account ID: ' + shiftInsertResultList.get(i));
                        successCandidateIdSet.add(candidateShiftList[i].Contact__c);
                    }
                    else {
                        // Operation failed, so get all errors   
                        failedCandidateIdSet.add(candidateShiftList[i].Contact__c);             
                        for(Database.Error err : shiftInsertResultList[i].getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                }
                
                Map<Id,Contact> candidatesToUpdateMap = new Map<Id,Contact>();
                if(!successCandidateIdSet.isEmpty()) {
                    for(Id candidateId : successCandidateIdSet) {
                        candidatesToUpdateMap.put(candidateId, new Contact(Id = candidateId, Last_Shift_Synced_On__c = System.now(), Error_While_Shift_Sync__c = false));
                    }
                }
                
                if(!failedCandidateIdSet.isEmpty()) {
                    for(Id candidateId : failedCandidateIdSet) {
                        if(!candidatesToUpdateMap.containsKey(candidateId))
                            candidatesToUpdateMap.put(candidateId, new Contact(Id = candidateId, Error_While_Shift_Sync__c = true));
                    }
                }
                
                if(!candidatesToUpdateMap.isEmpty())
                    update candidatesToUpdateMap.values();
                
            }
        }
    }

    @Future
    public static void handleShiftAlignmentFuture(List<Id> shiftAlignmentCandidateIdList) {
        handleShiftAlignment(shiftAlignmentCandidateIdList);
    }

    class CandidateSlotToShiftWrapper {
        public DateTime startDatetime;
        public DateTime endDatetime;
        public List<String> preferredDaysList;

        public CandidateSlotToShiftWrapper(DateTime startDatetime, DateTime endDatetime, List<String> preferredDaysList) {
            this.startDatetime = startDatetime;
            this.endDatetime = endDatetime;
            this.preferredDaysList = preferredDaysList;
        }
    }

    public class ShiftException extends Exception{}
}