public class outlookEventResponse {
    
    public String webLink{get;set;}
    public String originalEndTimeZone{get;set;}
    public String transactionId{get;set;}
    public static outlookEventResponse parse(String json) {
        return (outlookEventResponse) System.JSON.deserialize(json, outlookEventResponse.class);
    }
}