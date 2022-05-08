global class ScheduleBatchForBulkInvoice implements Schedulable{
    global void execute(SchedulableContext sc) {
        BatchForForwardingBulkInvoice updateLeadStatus = new BatchForForwardingBulkInvoice(null);
        database.executeBatch(updateLeadStatus);
    }
}