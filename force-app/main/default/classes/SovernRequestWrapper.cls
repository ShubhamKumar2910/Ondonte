public class SovernRequestWrapper {
	public String DocumentAsBase64String;	//JVBERi0xLjQKJeLjz9MKMyAwIG9iaiA8PC9D
	public String DocumentLastModified;	//2022-01-24
	public boolean OutputHtml;
	public boolean OutputRtf;
	public boolean OutputPdf;
	public boolean OutputCandidateImage;
	public String Configuration;	//
	public cls_SkillsData[] SkillsData;
	public String NormalizerData;	//
	public cls_GeocodeOptions GeocodeOptions;
	public cls_IndexingOptions IndexingOptions;
	class cls_SkillsData {
	}
	class cls_GeocodeOptions {
		public boolean IncludeGeocoding;
		public String Provider;	//
		public String ProviderKey;	//
		public cls_PostalAddress PostalAddress;
		public cls_GeoCoordinates GeoCoordinates;
	}
	class cls_PostalAddress {
		public String CountryCode;	//
		public String PostalCode;	//
		public String Region;	//
		public String Municipality;	//
		public String AddressLine;	//
	}
	class cls_GeoCoordinates {
		public Integer Latitude;	//0
		public Integer Longitude;	//0
	}
	class cls_IndexingOptions {
		public String IndexId;	//
		public String DocumentId;	//
		public cls_UserDefinedTags[] UserDefinedTags;
	}
	class cls_UserDefinedTags {
	}
	public static SovernRequestWrapper parse(String json){
		return (SovernRequestWrapper) System.JSON.deserialize(json, SovernRequestWrapper.class);
	}

	static void testParse() {
		String json=		'{'+
		'"DocumentAsBase64String" :  "JVBERi0xLjQKJeLjz9MKMyAwIG9iaiA8PC9D",'+
		'"DocumentLastModified" :  "2022-01-24",'+
		'"OutputHtml" :  false,'+
		'"OutputRtf" :  false,'+
		'"OutputPdf" :  false,'+
		'"OutputCandidateImage" :  false,'+
		'"Configuration" :  "",'+
		'"SkillsData" :  ['+
		'""],'+
		'"NormalizerData" :  "",'+
		'"GeocodeOptions" :  {'+
		'"IncludeGeocoding" :  false,'+
		'"Provider" :  "",'+
		'"ProviderKey" :  "",'+
		'"PostalAddress" :  {'+
		'"CountryCode" :  "",'+
		'"PostalCode" :  "",'+
		'"Region" :  "",'+
		'"Municipality" :  "",'+
		'"AddressLine" :  ""},'+
		'"GeoCoordinates" :  {'+
		'"Latitude" :  0,'+
		'"Longitude" :  0}},'+
		'"IndexingOptions" :  {'+
		'"IndexId" :  "",'+
		'"DocumentId" :  "",'+
		'"UserDefinedTags" :  ['+
		'""]}}';
		SovernRequestWrapper obj = parse(json);
		System.assert(obj != null);
	}
}