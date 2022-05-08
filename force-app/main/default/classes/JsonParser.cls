public class JsonParser{
        public String expires_on{get;set;}
        public String not_before{get;set;}
        public String ext_expires_in{get;set;}
        public String resource{get;set;}
        public String expires_in{get;set;}
        public String access_token{get;set;}
        public String scope{get;set;}
        public String refresh_token{get;set;}
        public String token_type{get;set;}
        
        public static JsonParser parse(String json) {
            return (JsonParser) System.JSON.deserialize(json, JsonParser.class);
        }
    }