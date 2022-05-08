public without sharing class GooglePublicDetailWrapper {
    public String sub;	
	public String name;	
	public String given_name;
	public String family_name;
	public String picture;	
	public String email;	
	public boolean email_verified;
	public String locale;	
	public static GooglePublicDetailWrapper parse(String json){
		return (GooglePublicDetailWrapper) System.JSON.deserialize(json, GooglePublicDetailWrapper.class);
	}

	/* static testMethod void testParse() {
		String json=		'{'+
		'  "sub": "104040785521062562114",'+
		'  "name": "Prithvi Shiroor",'+
		'  "given_name": "Prithvi",'+
		'  "family_name": "Shiroor",'+
		'  "picture": "https://lh3.googleusercontent.com/a-/AOh14GhlnvXTQ4d8-PQX0BbmpVeIpTJqW0aXPKkLn-0vhQ\u003ds96-c",'+
		'  "email": "prinz.deagle@gmail.com",'+
		'  "email_verified": true,'+
		'  "locale": "en"'+
		'}';
		fromJSON obj = parse(json);
		System.assert(obj != null);
	} */
    
}