public class SovernResponeWrapper{
	public class ResumeData {
		public ContactInformation ContactInformation;
		public PersonalAttributes PersonalAttributes;
		public Education Education;
		public EmploymentHistory EmploymentHistory;
		public List<SkillsData> SkillsData;
		public List<Certifications> Certifications;
		public List<LanguageCompetencies> LanguageCompetencies;
		public String QualificationsSummary;
		public ResumeMetadata ResumeMetadata;
	}

	public class Findings {
		public String QualityCode;
		public String Message;
	}

	public Info Info;
	public Value Value;

	public class Certifications {
		public String Name;
		public Boolean MatchedFromList;
		public Boolean IsVariation;
	}

	public class ParsingResponse {
		public String Code;
		public String Message;
	}

	public class WebAddresses {
		public String Address;
		public String Type;
	}

	public class EducationDetails {
		public String Id;
		public String Text;
		public Name SchoolName;
		public String SchoolType;
		public HighestDegree Degree;
		public List<String> Majors;
		public LastEducationcdate LastEducationcdate;
	}

	public class Findings_Z {
		public String QualityCode;
		public List<SectionIdentifiers> SectionIdentifiers;
		public String Message;
	}

	public class ResumeMetadata {
		public List<FoundSections> FoundSections;
		public List<ResumeQuality> ResumeQuality;
		public ReservedData ReservedData;
		public String PlainText;
		public String DocumentLanguage;
		public String DocumentCulture;
		public String ParserSettings;
		public String DocumentLastModified;
	}

	public class Location_Z {
		public String CountryCode;
		public List<String> Regions;
		public String Municipality;
	}

	public class ContactInformation_Z {
		public Location_Y Location;
	}

	public class SkillsData {
		public String Root;
		public List<Taxonomies> Taxonomies;
	}

	public class SubTaxonomies {
		public String SubTaxonomyId;
		public String SubTaxonomyName;
		public Integer PercentOfOverall;
		public Integer PercentOfParent;
		public List<Skills> Skills;
	}

	public class CustomerDetails {
		public String AccountId;
		public String Name;
		public String IPAddress;
		public String Region;
		public Double CreditsRemaining;
		public Integer CreditsUsed;
		public String Expirationcdate;
		public Integer MaximumConcurrentRequests;
	}

	public class Name {
		public String Raw;
		public String Normalized;
	}

	public class ExperienceSummary {
		public String Description;
		public Integer MonthsOfWorkExperience;
		public Integer MonthsOfManagementExperience;
		public String ExecutiveType;
		public Integer AverageMonthsPerEmployer;
		public Integer FulltimeDirectHirePredictiveIndex;
		public String ManagementStory;
		public String CurrentManagementLevel;
		public Integer ManagementScore;
	}

	public class ResumeMetadata_Z {
		public List<FoundSections> FoundSections;
		public List<ResumeQuality> ResumeQuality;
		public String PlainText;
		public String DocumentLanguage;
		public String DocumentCulture;
		public String ParserSettings;
		public String DocumentLastModified;
	}

	public class EmploymentHistory_Z {
		public ExperienceSummary ExperienceSummary;
		public List<Positions_Z> Positions;
	}

	public class Education {
		public HighestDegree HighestDegree;
		public List<EducationDetails> EducationDetails;
	}

	public class EmploymentHistory {
		public ExperienceSummary ExperienceSummary;
		public List<Positions_Z> Positions;
	}

	public class Skills {
		public String Id;
		public String Name;
		public List<FoundIn> FoundIn;
		public Boolean ExistsInText;
	}

	public class Location_Y {
		public String CountryCode;
		public String PostalCode;
		public List<String> Regions;
		public String Municipality;
	}

	public class SectionIdentifiers {
		public String SectionType;
		public String Id;
	}

	public class Positions_Z {
		public String Id;
		public Employer Employer;
		public Boolean IsSelfEmployed;
		public Boolean IsCurrent;
		public LastEducationcdate Startcdate;
		public LastEducationcdate Endcdate;
		public String JobType;
		public Integer TaxonomyPercentage;
		public String Description;
	}

	public class HighestDegree {
		public Name Name;
		public String Type;
	}

	public class Taxonomies {
		public String Id;
		public String Name;
		public Integer PercentOfOverall;
		public List<SubTaxonomies> SubTaxonomies;
	}

	public class ConversionMetadata {
		public String DetectedType;
		public String SuggestedFileExtension;
		public String OutputValidityCode;
		public Integer ElapsedMilliseconds;
		public String DocumentHash;
	}

	public class Name_Z {
		public String Probability;
		public String Raw;
		public String Normalized;
	}

	public class FoundIn {
		public String SectionType;
	}

	public class Employer {
		public Name_Z Name;
		public Location_Z Location;
	}

	public class LanguageCompetencies {
		public String Language;
		public String LanguageCode;
		public String FoundInContext;
	}

	public class Info {
		public String Code;
		public String Message;
		public String TransactionId;
		public String EngineVersion;
		public String ApiVersion;
		public Integer TotalElapsedMilliseconds;
		public Double TransactionCost;
		public CustomerDetails CustomerDetails;
	}

	public class LastEducationcdate {
		public String cdate;
		public Boolean IsCurrentcdate;
		public Boolean FoundYear;
		public Boolean FoundMonth;
		public Boolean FoundDay;
	}

	public class ResumeQuality {
		public String Level;
		public List<Findings> Findings;
	}

	public class ReservedData {
		public List<String> Phones;
		public List<String> Names;
		public List<String> EmailAddresses;
		public List<String> OtherData;
	}

	public class ContactInformation {
		public CandidateName CandidateName;
		public List<Telephones> Telephones;
		public List<String> EmailAddresses;
		public Location Location;
		public List<WebAddresses> WebAddresses;
	}

	public class ParsingMetadata {
		public Integer ElapsedMilliseconds;
		public Boolean TimedOut;
	}

	public class FoundSections {
		public Integer FirstLinecNumber;
		public Integer LastLinecNumber;
		public String SectionType;
		public String HeaderTextFound;
	}

	public class RedactedResumeData {
		public ContactInformation_Z ContactInformation;
		public Education Education;
		public EmploymentHistory_Z EmploymentHistory;
		public List<SkillsData> SkillsData;
		public List<Certifications> Certifications;
		public List<LanguageCompetencies> LanguageCompetencies;
		public String QualificationsSummary;
		public ResumeMetadata_Z ResumeMetadata;
	}

	public class PersonalAttributes {
	}

	public class Telephones {
		public String Raw;
		public String Normalized;
		public String InternationalCountryCode;
		public String AreaCityCode;
		public String SubscribercNumber;
	}

	public class CandidateName {
		public String FormattedName;
		public String GivenName;
		public String FamilyName;
	}

	public class Value {
		public ParsingResponse ParsingResponse;
		public ResumeData ResumeData;
		public RedactedResumeData RedactedResumeData;
		public ConversionMetadata ConversionMetadata;
		public ParsingMetadata ParsingMetadata;
	}

	public class Location {
		public String CountryCode;
		public String PostalCode;
		public List<String> Regions;
		public String Municipality;
		public List<String> StreetAddressLines;
	}
	public static SovernResponeWrapper parse(String json){
		return (SovernResponeWrapper) System.JSON.deserialize(json, SovernResponeWrapper.class);
	}

    public static String getDummyResponse() {
		String json=		'{'+
		'  "Info": {'+
		'    "Code": "Success",'+
		'    "Message": "Successful transaction",'+
		'    "TransactionId": "e328201a-7a44-4512-80d0-c42f7720ae3e",'+
		'    "EngineVersion": "9.7.2.0",'+
		'    "ApiVersion": "10.3.0.0",'+
		'    "TotalElapsedMilliseconds": 515,'+
		'    "TransactionCost": 1.0,'+
		'    "CustomerDetails": {'+
		'      "AccountId": "21081121",'+
		'      "Name": "UtilitarianLabs",'+
		'      "IPAddress": "101.53.172.8",'+
		'      "Region": "us-east-1",'+
		'      "CreditsRemaining": 440.0,'+
		'      "CreditsUsed": 59,'+
		'      "Expirationcdate": "2022-04-24",'+
		'      "MaximumConcurrentRequests": 2'+
		'    }'+
		'  },'+
		'  "Value": {'+
		'    "ParsingResponse": {'+
		'      "Code": "Success",'+
		'      "Message": "Successful transaction"'+
		'    },'+
		'    "ResumeData": {'+
		'      "ContactInformation": {'+
		'        "CandidateName": {'+
		'          "FormattedName": "ABDI GULAID",'+
		'          "GivenName": "ABDI",'+
		'          "FamilyName": "GULAID"'+
		'        },'+
		'        "Telephones": ['+
		'          {'+
		'            "Raw": "510-610-1367",'+
		'            "Normalized": "+1 510-610-1367",'+
		'            "InternationalCountryCode": "1",'+
		'            "AreaCityCode": "510",'+
		'            "SubscribercNumber": "610-1367"'+
		'          },'+
		'          {'+
		'            "Raw": "925-218-0649",'+
		'            "Normalized": "+1 925-218-0649",'+
		'            "InternationalCountryCode": "1",'+
		'            "AreaCityCode": "925",'+
		'            "SubscribercNumber": "218-0649"'+
		'          }'+
		'        ],'+
		'        "EmailAddresses": ['+
		'          "sue@ondonte.com",'+
		'          "sabdi8@yahoo.com"'+
		'        ],'+
		'        "Location": {'+
		'          "CountryCode": "US",'+
		'          "PostalCode": "94609",'+
		'          "Regions": ['+
		'            "CA"'+
		'          ],'+
		'          "Municipality": "Oakland",'+
		'          "StreetAddressLines": ['+
		'            "5351 Telegraph Avenue #309"'+
		'          ]'+
		'        },'+
		'        "WebAddresses": ['+
		'          {'+
		'            "Address": "Avenue",'+
		'            "Type": "Telegraph"'+
		'          }'+
		'        ]'+
		'      },'+
		'      "PersonalAttributes": {'+
		'        '+
		'      },'+
		'      "Education": {'+
		'        "HighestDegree": {'+
		'          "Name": {'+
		'            "Raw": "Associates of Arts",'+
		'            "Normalized": "associates"'+
		'          },'+
		'          "Type": "associates"'+
		'        },'+
		'        "EducationDetails": ['+
		'          {'+
		'            "Id": "DEG-1",'+
		'            "Text": "•   Chabot College: Associates of Arts, Dental Hygiene 2011",'+
		'            "SchoolName": {'+
		'              "Raw": "Chabot College",'+
		'              "Normalized": "Chabot College"'+
		'            },'+
		'            "SchoolType": "college",'+
		'            "Degree": {'+
		'              "Name": {'+
		'                "Raw": "Associates of Arts",'+
		'                "Normalized": "associates"'+
		'              },'+
		'              "Type": "associates"'+
		'            },'+
		'            "Majors": ['+
		'              "Dental Hygiene"'+
		'            ],'+
		'            "LastEducationcdate": {'+
		'              "cdate": "2011-01-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": false,'+
		'              "FoundDay": false'+
		'            }'+
		'          },'+
		'          {'+
		'            "Id": "DEG-2",'+
		'            "Text": "•   Merritt College: Associates of Science, Health Science 2008",'+
		'            "SchoolName": {'+
		'              "Raw": "Merritt College",'+
		'              "Normalized": "Merritt College"'+
		'            },'+
		'            "SchoolType": "college",'+
		'            "Degree": {'+
		'              "Name": {'+
		'                "Raw": "Associates of Science",'+
		'                "Normalized": "ASc"'+
		'              },'+
		'              "Type": "associates"'+
		'            },'+
		'            "Majors": ['+
		'              "Health Science"'+
		'            ],'+
		'            "LastEducationcdate": {'+
		'              "cdate": "2008-01-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": false,'+
		'              "FoundDay": false'+
		'            }'+
		'          }'+
		'        ]'+
		'      },'+
		'      "EmploymentHistory": {'+
		'        "ExperienceSummary": {'+
		'          "Description": "ABDI GULAID is experienced in:  Nursing (CPR, EMT and First Aid). ABDI GULAID has 10 years of work experience.",'+
		'          "MonthsOfWorkExperience": 121,'+
		'          "MonthsOfManagementExperience": 0,'+
		'          "ExecutiveType": "NONE",'+
		'          "AverageMonthsPerEmployer": 15,'+
		'          "FulltimeDirectHirePredictiveIndex": 50,'+
		'          "ManagementStory": "",'+
		'          "CurrentManagementLevel": "",'+
		'          "ManagementScore": 0'+
		'        },'+
		'        "Positions": ['+
		'          {'+
		'            "Id": "POS-1",'+
		'            "Employer": {'+
		'              "Name": {'+
		'                "Probability": "Confident",'+
		'                "Raw": "Total Dental Health",'+
		'                "Normalized": "Total Dental Health"'+
		'              },'+
		'              "Location": {'+
		'                "CountryCode": "US",'+
		'                "Regions": ['+
		'                  "CA"'+
		'                ],'+
		'                "Municipality": "Oakland"'+
		'              }'+
		'            },'+
		'            "IsSelfEmployed": false,'+
		'            "IsCurrent": true,'+
		'            "Startcdate": {'+
		'              "cdate": "2020-11-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "Endcdate": {'+
		'              "cdate": "2022-02-28",'+
		'              "IsCurrentcdate": true,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "JobType": "UNSPECIFIED",'+
		'            "TaxonomyPercentage": 0'+
		'          },'+
		'          {'+
		'            "Id": "POS-3",'+
		'            "Employer": {'+
		'              "Name": {'+
		'                "Probability": "Confident",'+
		'                "Raw": "Washington Square Park Dental",'+
		'                "Normalized": "Washington Square Park Dental"'+
		'              },'+
		'              "Location": {'+
		'                "CountryCode": "US",'+
		'                "Regions": ['+
		'                  "CA"'+
		'                ],'+
		'                "Municipality": "San Francisco"'+
		'              }'+
		'            },'+
		'            "IsSelfEmployed": false,'+
		'            "IsCurrent": true,'+
		'            "Startcdate": {'+
		'              "cdate": "2013-04-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "Endcdate": {'+
		'              "cdate": "2022-02-28",'+
		'              "IsCurrentcdate": true,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "JobType": "UNSPECIFIED",'+
		'            "TaxonomyPercentage": 0'+
		'          },'+
		'          {'+
		'            "Id": "POS-2",'+
		'            "Employer": {'+
		'              "Name": {'+
		'                "Probability": "Confident",'+
		'                "Raw": "Dr. Mckinzie",'+
		'                "Normalized": "Dr Mckinzie"'+
		'              },'+
		'              "Location": {'+
		'                "CountryCode": "US",'+
		'                "Regions": ['+
		'                  "CA"'+
		'                ],'+
		'                "Municipality": "Oakland"'+
		'              }'+
		'            },'+
		'            "IsSelfEmployed": false,'+
		'            "IsCurrent": false,'+
		'            "Startcdate": {'+
		'              "cdate": "2012-10-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "Endcdate": {'+
		'              "cdate": "2020-10-31",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "JobType": "UNSPECIFIED",'+
		'            "TaxonomyPercentage": 0'+
		'          },'+
		'          {'+
		'            "Id": "POS-6",'+
		'            "Employer": {'+
		'              "Name": {'+
		'                "Probability": "Confident",'+
		'                "Raw": "Pacific Dental Associates",'+
		'                "Normalized": "Pacific Dental Associates"'+
		'              },'+
		'              "Location": {'+
		'                "CountryCode": "US",'+
		'                "Regions": ['+
		'                  "CA"'+
		'                ],'+
		'                "Municipality": "San Francisco"'+
		'              }'+
		'            },'+
		'            "IsSelfEmployed": false,'+
		'            "IsCurrent": false,'+
		'            "Startcdate": {'+
		'              "cdate": "2012-06-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "Endcdate": {'+
		'              "cdate": "2014-08-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "JobType": "UNSPECIFIED",'+
		'            "TaxonomyPercentage": 0'+
		'          },'+
		'          {'+
		'            "Id": "POS-4",'+
		'            "Employer": {'+
		'              "Name": {'+
		'                "Probability": "Confident",'+
		'                "Raw": "Hercules Dental Care",'+
		'                "Normalized": "Hercules Dental Care"'+
		'              },'+
		'              "Location": {'+
		'                "CountryCode": "US",'+
		'                "Regions": ['+
		'                  "CA"'+
		'                ],'+
		'                "Municipality": "Hercules"'+
		'              }'+
		'            },'+
		'            "IsSelfEmployed": false,'+
		'            "IsCurrent": false,'+
		'            "Startcdate": {'+
		'              "cdate": "2013-06-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "Endcdate": {'+
		'              "cdate": "2013-12-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "JobType": "UNSPECIFIED",'+
		'            "TaxonomyPercentage": 0'+
		'          },'+
		'          {'+
		'            "Id": "POS-8",'+
		'            "Employer": {'+
		'              "Name": {'+
		'                "Probability": "Confident",'+
		'                "Raw": "Dr. Ota & Dr. Honda",'+
		'                "Normalized": "Dr Ota AND Dr Honda"'+
		'              },'+
		'              "Location": {'+
		'                "CountryCode": "US",'+
		'                "Regions": ['+
		'                  "CA"'+
		'                ],'+
		'                "Municipality": "Berkeley"'+
		'              }'+
		'            },'+
		'            "IsSelfEmployed": false,'+
		'            "IsCurrent": false,'+
		'            "Startcdate": {'+
		'              "cdate": "2012-04-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "Endcdate": {'+
		'              "cdate": "2013-09-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "JobType": "UNSPECIFIED",'+
		'            "TaxonomyPercentage": 0,'+
		'            "Description": "Dr. Peterson & Dr. Chan, Oakland, CA: Temped April 2012"'+
		'          },'+
		'          {'+
		'            "Id": "POS-7",'+
		'            "Employer": {'+
		'              "Name": {'+
		'                "Probability": "Confident",'+
		'                "Raw": "Dr. Terlet & Aziz",'+
		'                "Normalized": "Dr Terlet AND Aziz"'+
		'              },'+
		'              "Location": {'+
		'                "CountryCode": "US",'+
		'                "Regions": ['+
		'                  "CA"'+
		'                ],'+
		'                "Municipality": "Berkeley"'+
		'              }'+
		'            },'+
		'            "IsSelfEmployed": false,'+
		'            "IsCurrent": false,'+
		'            "Startcdate": {'+
		'              "cdate": "2012-10-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "Endcdate": {'+
		'              "cdate": "2013-09-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "JobType": "UNSPECIFIED",'+
		'            "TaxonomyPercentage": 0'+
		'          },'+
		'          {'+
		'            "Id": "POS-5",'+
		'            "Employer": {'+
		'              "Name": {'+
		'                "Probability": "Confident",'+
		'                "Raw": "Dr. Tickner",'+
		'                "Normalized": "Dr Tickner"'+
		'              },'+
		'              "Location": {'+
		'                "CountryCode": "US",'+
		'                "Regions": ['+
		'                  "CA"'+
		'                ],'+
		'                "Municipality": "San Leandro"'+
		'              }'+
		'            },'+
		'            "IsSelfEmployed": false,'+
		'            "IsCurrent": false,'+
		'            "Startcdate": {'+
		'              "cdate": "2012-07-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "Endcdate": {'+
		'              "cdate": "2012-12-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "JobType": "UNSPECIFIED",'+
		'            "TaxonomyPercentage": 0'+
		'          }'+
		'        ]'+
		'      },'+
		'      "SkillsData": ['+
		'        {'+
		'          "Root": "Sovren",'+
		'          "Taxonomies": ['+
		'            {'+
		'              "Id": "99",'+
		'              "Name": "Nursing",'+
		'              "PercentOfOverall": 52,'+
		'              "SubTaxonomies": ['+
		'                {'+
		'                  "SubTaxonomyId": "418",'+
		'                  "SubTaxonomyName": "CPR, EMT and First Aid",'+
		'                  "PercentOfOverall": 52,'+
		'                  "PercentOfParent": 100,'+
		'                  "Skills": ['+
		'                    {'+
		'                      "Id": "014558",'+
		'                      "Name": "CPR",'+
		'                      "FoundIn": ['+
		'                        {'+
		'                          "SectionType": "CERTIFICATIONS"'+
		'                        }'+
		'                      ],'+
		'                      "ExistsInText": true'+
		'                    },'+
		'                    {'+
		'                      "Id": "023711",'+
		'                      "Name": "CPR Certified",'+
		'                      "FoundIn": ['+
		'                        {'+
		'                          "SectionType": "CERTIFICATIONS"'+
		'                        }'+
		'                      ],'+
		'                      "ExistsInText": true'+
		'                    }'+
		'                  ]'+
		'                }'+
		'              ]'+
		'            },'+
		'            {'+
		'              "Id": "15",'+
		'              "Name": "Scientific",'+
		'              "PercentOfOverall": 15,'+
		'              "SubTaxonomies": ['+
		'                {'+
		'                  "SubTaxonomyId": "372",'+
		'                  "SubTaxonomyName": "Pharma",'+
		'                  "PercentOfOverall": 14,'+
		'                  "PercentOfParent": 90,'+
		'                  "Skills": ['+
		'                    {'+
		'                      "Id": "020872",'+
		'                      "Name": "Antimicrobial",'+
		'                      "FoundIn": ['+
		'                        {'+
		'                          "SectionType": "QUALIFICATIONS_SUMMARY"'+
		'                        }'+
		'                      ],'+
		'                      "ExistsInText": true'+
		'                    }'+
		'                  ]'+
		'                },'+
		'                {'+
		'                  "SubTaxonomyId": "376",'+
		'                  "SubTaxonomyName": "Basic",'+
		'                  "PercentOfOverall": 2,'+
		'                  "PercentOfParent": 10,'+
		'                  "Skills": ['+
		'                    {'+
		'                      "Id": "020601",'+
		'                      "Name": "Laser",'+
		'                      "FoundIn": ['+
		'                        {'+
		'                          "SectionType": "CERTIFICATIONS"'+
		'                        }'+
		'                      ],'+
		'                      "ExistsInText": true'+
		'                    }'+
		'                  ]'+
		'                }'+
		'              ]'+
		'            },'+
		'            {'+
		'              "Id": "12",'+
		'              "Name": "Legal",'+
		'              "PercentOfOverall": 14,'+
		'              "SubTaxonomies": ['+
		'                {'+
		'                  "SubTaxonomyId": "400",'+
		'                  "SubTaxonomyName": "Litigation",'+
		'                  "PercentOfOverall": 14,'+
		'                  "PercentOfParent": 100,'+
		'                  "Skills": ['+
		'                    {'+
		'                      "Id": "200081",'+
		'                      "Name": "Clients",'+
		'                      "FoundIn": ['+
		'                        {'+
		'                          "SectionType": "QUALIFICATIONS_SUMMARY"'+
		'                        }'+
		'                      ],'+
		'                      "ExistsInText": true'+
		'                    }'+
		'                  ]'+
		'                }'+
		'              ]'+
		'            },'+
		'            {'+
		'              "Id": "5",'+
		'              "Name": "Engineering",'+
		'              "PercentOfOverall": 9,'+
		'              "SubTaxonomies": ['+
		'                {'+
		'                  "SubTaxonomyId": "141",'+
		'                  "SubTaxonomyName": "Optical",'+
		'                  "PercentOfOverall": 5,'+
		'                  "PercentOfParent": 50,'+
		'                  "Skills": ['+
		'                    {'+
		'                      "Id": "080830",'+
		'                      "Name": "Laser",'+
		'                      "FoundIn": ['+
		'                        {'+
		'                          "SectionType": "CERTIFICATIONS"'+
		'                        }'+
		'                      ],'+
		'                      "ExistsInText": true'+
		'                    }'+
		'                  ]'+
		'                },'+
		'                {'+
		'                  "SubTaxonomyId": "308",'+
		'                  "SubTaxonomyName": "Power Engineering",'+
		'                  "PercentOfOverall": 5,'+
		'                  "PercentOfParent": 50,'+
		'                  "Skills": ['+
		'                    {'+
		'                      "Id": "080350",'+
		'                      "Name": "Laser",'+
		'                      "FoundIn": ['+
		'                        {'+
		'                          "SectionType": "CERTIFICATIONS"'+
		'                        }'+
		'                      ],'+
		'                      "ExistsInText": true'+
		'                    }'+
		'                  ]'+
		'                }'+
		'              ]'+
		'            },'+
		'            {'+
		'              "Id": "34",'+
		'              "Name": "Business Operations and General Business",'+
		'              "PercentOfOverall": 7,'+
		'              "SubTaxonomies": ['+
		'                {'+
		'                  "SubTaxonomyId": "437",'+
		'                  "SubTaxonomyName": "General Skills and Activities",'+
		'                  "PercentOfOverall": 7,'+
		'                  "PercentOfParent": 100,'+
		'                  "Skills": ['+
		'                    {'+
		'                      "Id": "025724",'+
		'                      "Name": "Staffing",'+
		'                      "FoundIn": ['+
		'                        {'+
		'                          "SectionType": "QUALIFICATIONS_SUMMARY"'+
		'                        }'+
		'                      ],'+
		'                      "ExistsInText": true'+
		'                    }'+
		'                  ]'+
		'                }'+
		'              ]'+
		'            },'+
		'            {'+
		'              "Id": "37",'+
		'              "Name": "Recruiting",'+
		'              "PercentOfOverall": 3,'+
		'              "SubTaxonomies": ['+
		'                {'+
		'                  "SubTaxonomyId": "492",'+
		'                  "SubTaxonomyName": "Recruiting Tasks and Activities",'+
		'                  "PercentOfOverall": 3,'+
		'                  "PercentOfParent": 100,'+
		'                  "Skills": ['+
		'                    {'+
		'                      "Id": "008529",'+
		'                      "Name": "Staffing",'+
		'                      "FoundIn": ['+
		'                        {'+
		'                          "SectionType": "QUALIFICATIONS_SUMMARY"'+
		'                        }'+
		'                      ],'+
		'                      "ExistsInText": true'+
		'                    }'+
		'                  ]'+
		'                }'+
		'              ]'+
		'            }'+
		'          ]'+
		'        }'+
		'      ],'+
		'      "Certifications": ['+
		'        {'+
		'          "Name": "California Registered Dental Hygienist",'+
		'          "MatchedFromList": false,'+
		'          "IsVariation": false'+
		'        },'+
		'        {'+
		'          "Name": "First Aid Responder and CPR Certified",'+
		'          "MatchedFromList": false,'+
		'          "IsVariation": false'+
		'        },'+
		'        {'+
		'          "Name": "Certifications/Licensure",'+
		'          "MatchedFromList": false,'+
		'          "IsVariation": false'+
		'        },'+
		'        {'+
		'          "Name": "CPR Certified",'+
		'          "MatchedFromList": true,'+
		'          "IsVariation": true'+
		'        },'+
		'        {'+
		'          "Name": "CPR",'+
		'          "MatchedFromList": true,'+
		'          "IsVariation": true'+
		'        }'+
		'      ],'+
		'      "LanguageCompetencies": ['+
		'        {'+
		'          "Language": "English",'+
		'          "LanguageCode": "en",'+
		'          "FoundInContext": "[RESUME_LANGUAGE]"'+
		'        }'+
		'      ],'+
		'      "QualificationsSummary": "Applicable Skills\n•   Ability to work in a team as well as individually. Positive attitude, motivated and\nproductive individual. Great chair side manner. Possess excellent communication\nskills. Great people management and commitment to work.\n\n\nQualifications\n• Subgingival chemotherapeutics and application of antimicrobial agents (Arestin)\n• Radiograph both digital and traditional, Dentrix, EagleSoft, Datacon and Open\nDental\n•   Administration of Local Anesthetic agents and Nitrous Oxide\n•   Oral cancer screening, diagnosing periodontal disease and soft tissue curettage\n•   Patient participation and involvement in oral hygiene care and instructions\n•   Individualized treatment planning with dentist\n\nReferences Available upon request\n\nTHIS RESUME is provided by Ondonte Dental Staffing to our Clients for the sole purpose of considering this individual\nfor hire through Ondonte as a Permanent employee or for a Temporary assignment. This Resume is CONFIDENTIAL\nbetween the Client, Ondonte Dental Staffing and the Individual, and it may not be otherwise distributed or used for any\nother purpose. For information please call Ondonte at 925-218-0649 or email us at sue@ondonte.com.",'+
		'      "ResumeMetadata": {'+
		'        "FoundSections": ['+
		'          {'+
		'            "FirstLinecNumber": 15,'+
		'            "LastLinecNumber": 25,'+
		'            "SectionType": "WORK HISTORY",'+
		'            "HeaderTextFound": "Professional Experience"'+
		'          },'+
		'          {'+
		'            "FirstLinecNumber": 26,'+
		'            "LastLinecNumber": 31,'+
		'            "SectionType": "SKILLS",'+
		'            "HeaderTextFound": "Applicable Skills"'+
		'          },'+
		'          {'+
		'            "FirstLinecNumber": 32,'+
		'            "LastLinecNumber": 35,'+
		'            "SectionType": "EDUCATION",'+
		'            "HeaderTextFound": "Education"'+
		'          },'+
		'          {'+
		'            "FirstLinecNumber": 36,'+
		'            "LastLinecNumber": 50,'+
		'            "SectionType": "QUALIFICATIONS_SUMMARY",'+
		'            "HeaderTextFound": "Qualifications"'+
		'          }'+
		'        ],'+
		'        "ResumeQuality": ['+
		'          {'+
		'            "Level": "Major Issues Found",'+
		'            "Findings": ['+
		'              {'+
		'                "QualityCode": "300",'+
		'                "Message": "You should not use the PDF format for your resume. Due to inherent limitations with text extraction from PDFs, you are less likely to get a job when using a PDF resume."'+
		'              }'+
		'            ]'+
		'          },'+
		'          {'+
		'            "Level": "Data Missing",'+
		'            "Findings": ['+
		'              {'+
		'                "QualityCode": "221",'+
		'                "SectionIdentifiers": ['+
		'                  {'+
		'                    "SectionType": "WORK HISTORY",'+
		'                    "Id": "POS-1"'+
		'                  },'+
		'                  {'+
		'                    "SectionType": "WORK HISTORY",'+
		'                    "Id": "POS-3"'+
		'                  },'+
		'                  {'+
		'                    "SectionType": "WORK HISTORY",'+
		'                    "Id": "POS-2"'+
		'                  },'+
		'                  {'+
		'                    "SectionType": "WORK HISTORY",'+
		'                    "Id": "POS-6"'+
		'                  },'+
		'                  {'+
		'                    "SectionType": "WORK HISTORY",'+
		'                    "Id": "POS-4"'+
		'                  },'+
		'                  {'+
		'                    "SectionType": "WORK HISTORY",'+
		'                    "Id": "POS-8"'+
		'                  },'+
		'                  {'+
		'                    "SectionType": "WORK HISTORY",'+
		'                    "Id": "POS-7"'+
		'                  },'+
		'                  {'+
		'                    "SectionType": "WORK HISTORY",'+
		'                    "Id": "POS-5"'+
		'                  }'+
		'                ],'+
		'                "Message": "Every position in a resume should have a job title."'+
		'              }'+
		'            ]'+
		'          },'+
		'          {'+
		'            "Level": "Suggested Improvements",'+
		'            "Findings": ['+
		'              {'+
		'                "QualityCode": "112",'+
		'                "Message": "The following section was identified as a skills section type: \'Applicable Skills\'. Skills should not be in a separate section, but instead, each skill should be included in the descriptions of work history or education. THIS IS INCREDIBLY IMPORTANT FOR AI MATCHING ALGORITHMS"'+
		'              },'+
		'              {'+
		'                "QualityCode": "132",'+
		'                "Message": "Multiple email addresses were found in the contact information. Only one email address should be included in a resume."'+
		'              },'+
		'              {'+
		'                "QualityCode": "133",'+
		'                "Message": "Multiple phone numbers were found in the contact information. Only one phone number ( a mobile number) should be included in a resume."'+
		'              }'+
		'            ]'+
		'          }'+
		'        ],'+
		'        "ReservedData": {'+
		'          "Phones": ['+
		'            "510-610-1367",'+
		'            "925-218-0649"'+
		'          ],'+
		'          "Names": ['+
		'            "ABDI GULAID"'+
		'          ],'+
		'          "EmailAddresses": ['+
		'            "sue@ondonte.com",'+
		'            "sabdi8@yahoo.com"'+
		'          ],'+
		'          "OtherData": ['+
		'            "5351 Telegraph Avenue #309"'+
		'          ]'+
		'        },'+
		'        "PlainText": "THIS RESUME is provided by Ondonte Dental Staffing to our Clients for the sole purpose of considering this individual\nfor hire through Ondonte as a Permanent employee or for a Temporary assignment. This Resume is CONFIDENTIAL\nbetween the Client, Ondonte Dental Staffing and the Individual, and it may not be otherwise distributed or used for any\nother purpose. For information please call Ondonte at 925-218-0649 or email us at sue@ondonte.com.\n\n\nABDI GULAID\n5351 Telegraph Avenue #309, Oakland, CA 94609. 510-610-1367\nsabdi8@yahoo.com\n\nCertifications/Licensure\n•   California Registered Dental Hygienist: License #26124\n•   Advanced Laser Certification\n•   First Aid Responder and CPR Certified\n\nProfessional Experience\n•   Total Dental Health, Oakland, CA: November 2020 - Present\n•   Dr. Mckinzie, Oakland, CA: October 2012 - October 2020\n•   Washington Square Park Dental, San Francisco, CA: April 2013 - Present\n•   Hercules Dental Care, Hercules, CA: June 2013 - December 2013\n•   Dr. Tickner, San Leandro, CA: July 2012 - December 2012\n•   Pacific Dental Associates, San Francisco, CA: Temped June 2012 - August 2014\n•   Dr. Terlet & Aziz, Berkeley, CA: Temped October 2012 - September 2013\n•   Dr. Ota & Dr. Honda, Berkeley, CA: Temped April 2012 - September 2013\n•   Dr. Peterson & Dr. Chan, Oakland, CA: Temped April 2012\n\nApplicable Skills\n•   Ability to work in a team as well as individually. Positive attitude, motivated and\nproductive individual. Great chair side manner. Possess excellent communication\nskills. Great people management and commitment to work.\n\n\nEducation\n•   Chabot College: Associates of Arts, Dental Hygiene 2011\n•   Merritt College: Associates of Science, Health Science 2008\n\nQualifications\n• Subgingival chemotherapeutics and application of antimicrobial agents (Arestin)\n• Radiograph both digital and traditional, Dentrix, EagleSoft, Datacon and Open\nDental\n•   Administration of Local Anesthetic agents and Nitrous Oxide\n•   Oral cancer screening, diagnosing periodontal disease and soft tissue curettage\n•   Patient participation and involvement in oral hygiene care and instructions\n•   Individualized treatment planning with dentist\n\nReferences Available upon request\n\nTHIS RESUME is provided by Ondonte Dental Staffing to our Clients for the sole purpose of considering this individual\nfor hire through Ondonte as a Permanent employee or for a Temporary assignment. This Resume is CONFIDENTIAL\nbetween the Client, Ondonte Dental Staffing and the Individual, and it may not be otherwise distributed or used for any\nother purpose. For information please call Ondonte at 925-218-0649 or email us at sue@ondonte.com.",'+
		'        "DocumentLanguage": "en",'+
		'        "DocumentCulture": "en-US",'+
		'        "ParserSettings": "Coverage.PersonalAttributes = True; Coverage.Training = True; Culture.CountryCodeForUnitedKingdomIsUK = True; Culture.DefaultCountryCode = US; Culture.Language = English; Culture.PreferEnglishVersionIfTwoLanguagesInDocument = False; Data.UserDefinedParsing = False; OutputFormat.AssumeCompanyNameFromPrecedingJob = False; OutputFormat.ContactMethod.PackStyle = Split; OutputFormat.cdateOutputStyle = ExplicitlyKnowncdateInfoOnly; OutputFormat.NestJobsBasedOncdateRanges = True; OutputFormat.NormalizeRegions = False; OutputFormat.SimpleCustomLinkedIn = False; OutputFormat.SkillsStyle = Default; OutputFormat.StripParsedDataFromPositionHistoryDescription = True; OutputFormat.TelcomcNumber.Style = Raw; OutputFormat.XmlFormat = HrXmlResume25",'+
		'        "DocumentLastModified": "2022-02-28"'+
		'      }'+
		'    },'+
		'    "RedactedResumeData": {'+
		'      "ContactInformation": {'+
		'        "Location": {'+
		'          "CountryCode": "US",'+
		'          "PostalCode": "94609",'+
		'          "Regions": ['+
		'            "CA"'+
		'          ],'+
		'          "Municipality": "Oakland"'+
		'        }'+
		'      },'+
		'      "Education": {'+
		'        "HighestDegree": {'+
		'          "Name": {'+
		'            "Raw": "Associates of Arts",'+
		'            "Normalized": "associates"'+
		'          },'+
		'          "Type": "associates"'+
		'        },'+
		'        "EducationDetails": ['+
		'          {'+
		'            "Id": "DEG-1",'+
		'            "Text": "•   Chabot College: Associates of Arts, Dental Hygiene 2011",'+
		'            "SchoolName": {'+
		'              "Raw": "Chabot College",'+
		'              "Normalized": "Chabot College"'+
		'            },'+
		'            "SchoolType": "college",'+
		'            "Degree": {'+
		'              "Name": {'+
		'                "Raw": "Associates of Arts",'+
		'                "Normalized": "associates"'+
		'              },'+
		'              "Type": "associates"'+
		'            },'+
		'            "Majors": ['+
		'              "Dental Hygiene"'+
		'            ],'+
		'            "LastEducationcdate": {'+
		'              "cdate": "2011-01-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": false,'+
		'              "FoundDay": false'+
		'            }'+
		'          },'+
		'          {'+
		'            "Id": "DEG-2",'+
		'            "Text": "•   Merritt College: Associates of Science, Health Science 2008",'+
		'            "SchoolName": {'+
		'              "Raw": "Merritt College",'+
		'              "Normalized": "Merritt College"'+
		'            },'+
		'            "SchoolType": "college",'+
		'            "Degree": {'+
		'              "Name": {'+
		'                "Raw": "Associates of Science",'+
		'                "Normalized": "ASc"'+
		'              },'+
		'              "Type": "associates"'+
		'            },'+
		'            "Majors": ['+
		'              "Health Science"'+
		'            ],'+
		'            "LastEducationcdate": {'+
		'              "cdate": "2008-01-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": false,'+
		'              "FoundDay": false'+
		'            }'+
		'          }'+
		'        ]'+
		'      },'+
		'      "EmploymentHistory": {'+
		'        "ExperienceSummary": {'+
		'          "Description": "   ~~~~~~   is experienced in:  Nursing (CPR, EMT and First Aid).    ~~~~~~   has 10 years of work experience.",'+
		'          "MonthsOfWorkExperience": 121,'+
		'          "MonthsOfManagementExperience": 0,'+
		'          "ExecutiveType": "NONE",'+
		'          "AverageMonthsPerEmployer": 15,'+
		'          "FulltimeDirectHirePredictiveIndex": 50,'+
		'          "ManagementStory": "",'+
		'          "CurrentManagementLevel": "",'+
		'          "ManagementScore": 0'+
		'        },'+
		'        "Positions": ['+
		'          {'+
		'            "Id": "POS-1",'+
		'            "Employer": {'+
		'              "Name": {'+
		'                "Probability": "Confident",'+
		'                "Raw": "Total Dental Health",'+
		'                "Normalized": "Total Dental Health"'+
		'              },'+
		'              "Location": {'+
		'                "CountryCode": "US",'+
		'                "Regions": ['+
		'                  "CA"'+
		'                ],'+
		'                "Municipality": "Oakland"'+
		'              }'+
		'            },'+
		'            "IsSelfEmployed": false,'+
		'            "IsCurrent": true,'+
		'            "Startcdate": {'+
		'              "cdate": "2020-11-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "Endcdate": {'+
		'              "cdate": "2022-02-28",'+
		'              "IsCurrentcdate": true,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "JobType": "UNSPECIFIED",'+
		'            "TaxonomyPercentage": 0'+
		'          },'+
		'          {'+
		'            "Id": "POS-3",'+
		'            "Employer": {'+
		'              "Name": {'+
		'                "Probability": "Confident",'+
		'                "Raw": "Washington Square Park Dental",'+
		'                "Normalized": "Washington Square Park Dental"'+
		'              },'+
		'              "Location": {'+
		'                "CountryCode": "US",'+
		'                "Regions": ['+
		'                  "CA"'+
		'                ],'+
		'                "Municipality": "San Francisco"'+
		'              }'+
		'            },'+
		'            "IsSelfEmployed": false,'+
		'            "IsCurrent": true,'+
		'            "Startcdate": {'+
		'              "cdate": "2013-04-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "Endcdate": {'+
		'              "cdate": "2022-02-28",'+
		'              "IsCurrentcdate": true,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "JobType": "UNSPECIFIED",'+
		'            "TaxonomyPercentage": 0'+
		'          },'+
		'          {'+
		'            "Id": "POS-2",'+
		'            "Employer": {'+
		'              "Name": {'+
		'                "Probability": "Confident",'+
		'                "Raw": "Dr. Mckinzie",'+
		'                "Normalized": "Dr Mckinzie"'+
		'              },'+
		'              "Location": {'+
		'                "CountryCode": "US",'+
		'                "Regions": ['+
		'                  "CA"'+
		'                ],'+
		'                "Municipality": "Oakland"'+
		'              }'+
		'            },'+
		'            "IsSelfEmployed": false,'+
		'            "IsCurrent": false,'+
		'            "Startcdate": {'+
		'              "cdate": "2012-10-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "Endcdate": {'+
		'              "cdate": "2020-10-31",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "JobType": "UNSPECIFIED",'+
		'            "TaxonomyPercentage": 0'+
		'          },'+
		'          {'+
		'            "Id": "POS-6",'+
		'            "Employer": {'+
		'              "Name": {'+
		'                "Probability": "Confident",'+
		'                "Raw": "Pacific Dental Associates",'+
		'                "Normalized": "Pacific Dental Associates"'+
		'              },'+
		'              "Location": {'+
		'                "CountryCode": "US",'+
		'                "Regions": ['+
		'                  "CA"'+
		'                ],'+
		'                "Municipality": "San Francisco"'+
		'              }'+
		'            },'+
		'            "IsSelfEmployed": false,'+
		'            "IsCurrent": false,'+
		'            "Startcdate": {'+
		'              "cdate": "2012-06-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "Endcdate": {'+
		'              "cdate": "2014-08-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "JobType": "UNSPECIFIED",'+
		'            "TaxonomyPercentage": 0'+
		'          },'+
		'          {'+
		'            "Id": "POS-4",'+
		'            "Employer": {'+
		'              "Name": {'+
		'                "Probability": "Confident",'+
		'                "Raw": "Hercules Dental Care",'+
		'                "Normalized": "Hercules Dental Care"'+
		'              },'+
		'              "Location": {'+
		'                "CountryCode": "US",'+
		'                "Regions": ['+
		'                  "CA"'+
		'                ],'+
		'                "Municipality": "Hercules"'+
		'              }'+
		'            },'+
		'            "IsSelfEmployed": false,'+
		'            "IsCurrent": false,'+
		'            "Startcdate": {'+
		'              "cdate": "2013-06-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "Endcdate": {'+
		'              "cdate": "2013-12-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "JobType": "UNSPECIFIED",'+
		'            "TaxonomyPercentage": 0'+
		'          },'+
		'          {'+
		'            "Id": "POS-8",'+
		'            "Employer": {'+
		'              "Name": {'+
		'                "Probability": "Confident",'+
		'                "Raw": "Dr. Ota & Dr. Honda",'+
		'                "Normalized": "Dr Ota AND Dr Honda"'+
		'              },'+
		'              "Location": {'+
		'                "CountryCode": "US",'+
		'                "Regions": ['+
		'                  "CA"'+
		'                ],'+
		'                "Municipality": "Berkeley"'+
		'              }'+
		'            },'+
		'            "IsSelfEmployed": false,'+
		'            "IsCurrent": false,'+
		'            "Startcdate": {'+
		'              "cdate": "2012-04-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "Endcdate": {'+
		'              "cdate": "2013-09-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "JobType": "UNSPECIFIED",'+
		'            "TaxonomyPercentage": 0,'+
		'            "Description": "Dr. Peterson & Dr. Chan, Oakland, CA: Temped April 2012"'+
		'          },'+
		'          {'+
		'            "Id": "POS-7",'+
		'            "Employer": {'+
		'              "Name": {'+
		'                "Probability": "Confident",'+
		'                "Raw": "Dr. Terlet & Aziz",'+
		'                "Normalized": "Dr Terlet AND Aziz"'+
		'              },'+
		'              "Location": {'+
		'                "CountryCode": "US",'+
		'                "Regions": ['+
		'                  "CA"'+
		'                ],'+
		'                "Municipality": "Berkeley"'+
		'              }'+
		'            },'+
		'            "IsSelfEmployed": false,'+
		'            "IsCurrent": false,'+
		'            "Startcdate": {'+
		'              "cdate": "2012-10-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "Endcdate": {'+
		'              "cdate": "2013-09-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "JobType": "UNSPECIFIED",'+
		'            "TaxonomyPercentage": 0'+
		'          },'+
		'          {'+
		'            "Id": "POS-5",'+
		'            "Employer": {'+
		'              "Name": {'+
		'                "Probability": "Confident",'+
		'                "Raw": "Dr. Tickner",'+
		'                "Normalized": "Dr Tickner"'+
		'              },'+
		'              "Location": {'+
		'                "CountryCode": "US",'+
		'                "Regions": ['+
		'                  "CA"'+
		'                ],'+
		'                "Municipality": "San Leandro"'+
		'              }'+
		'            },'+
		'            "IsSelfEmployed": false,'+
		'            "IsCurrent": false,'+
		'            "Startcdate": {'+
		'              "cdate": "2012-07-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "Endcdate": {'+
		'              "cdate": "2012-12-01",'+
		'              "IsCurrentcdate": false,'+
		'              "FoundYear": true,'+
		'              "FoundMonth": true,'+
		'              "FoundDay": false'+
		'            },'+
		'            "JobType": "UNSPECIFIED",'+
		'            "TaxonomyPercentage": 0'+
		'          }'+
		'        ]'+
		'      },'+
		'      "SkillsData": ['+
		'        {'+
		'          "Root": "Sovren",'+
		'          "Taxonomies": ['+
		'            {'+
		'              "Id": "99",'+
		'              "Name": "Nursing",'+
		'              "PercentOfOverall": 52,'+
		'              "SubTaxonomies": ['+
		'                {'+
		'                  "SubTaxonomyId": "418",'+
		'                  "SubTaxonomyName": "CPR, EMT and First Aid",'+
		'                  "PercentOfOverall": 52,'+
		'                  "PercentOfParent": 100,'+
		'                  "Skills": ['+
		'                    {'+
		'                      "Id": "014558",'+
		'                      "Name": "CPR",'+
		'                      "FoundIn": ['+
		'                        {'+
		'                          "SectionType": "CERTIFICATIONS"'+
		'                        }'+
		'                      ],'+
		'                      "ExistsInText": true'+
		'                    },'+
		'                    {'+
		'                      "Id": "023711",'+
		'                      "Name": "CPR Certified",'+
		'                      "FoundIn": ['+
		'                        {'+
		'                          "SectionType": "CERTIFICATIONS"'+
		'                        }'+
		'                      ],'+
		'                      "ExistsInText": true'+
		'                    }'+
		'                  ]'+
		'                }'+
		'              ]'+
		'            },'+
		'            {'+
		'              "Id": "15",'+
		'              "Name": "Scientific",'+
		'              "PercentOfOverall": 15,'+
		'              "SubTaxonomies": ['+
		'                {'+
		'                  "SubTaxonomyId": "372",'+
		'                  "SubTaxonomyName": "Pharma",'+
		'                  "PercentOfOverall": 14,'+
		'                  "PercentOfParent": 90,'+
		'                  "Skills": ['+
		'                    {'+
		'                      "Id": "020872",'+
		'                      "Name": "Antimicrobial",'+
		'                      "FoundIn": ['+
		'                        {'+
		'                          "SectionType": "QUALIFICATIONS_SUMMARY"'+
		'                        }'+
		'                      ],'+
		'                      "ExistsInText": true'+
		'                    }'+
		'                  ]'+
		'                },'+
		'                {'+
		'                  "SubTaxonomyId": "376",'+
		'                  "SubTaxonomyName": "Basic",'+
		'                  "PercentOfOverall": 2,'+
		'                  "PercentOfParent": 10,'+
		'                  "Skills": ['+
		'                    {'+
		'                      "Id": "020601",'+
		'                      "Name": "Laser",'+
		'                      "FoundIn": ['+
		'                        {'+
		'                          "SectionType": "CERTIFICATIONS"'+
		'                        }'+
		'                      ],'+
		'                      "ExistsInText": true'+
		'                    }'+
		'                  ]'+
		'                }'+
		'              ]'+
		'            },'+
		'            {'+
		'              "Id": "12",'+
		'              "Name": "Legal",'+
		'              "PercentOfOverall": 14,'+
		'              "SubTaxonomies": ['+
		'                {'+
		'                  "SubTaxonomyId": "400",'+
		'                  "SubTaxonomyName": "Litigation",'+
		'                  "PercentOfOverall": 14,'+
		'                  "PercentOfParent": 100,'+
		'                  "Skills": ['+
		'                    {'+
		'                      "Id": "200081",'+
		'                      "Name": "Clients",'+
		'                      "FoundIn": ['+
		'                        {'+
		'                          "SectionType": "QUALIFICATIONS_SUMMARY"'+
		'                        }'+
		'                      ],'+
		'                      "ExistsInText": true'+
		'                    }'+
		'                  ]'+
		'                }'+
		'              ]'+
		'            },'+
		'            {'+
		'              "Id": "5",'+
		'              "Name": "Engineering",'+
		'              "PercentOfOverall": 9,'+
		'              "SubTaxonomies": ['+
		'                {'+
		'                  "SubTaxonomyId": "141",'+
		'                  "SubTaxonomyName": "Optical",'+
		'                  "PercentOfOverall": 5,'+
		'                  "PercentOfParent": 50,'+
		'                  "Skills": ['+
		'                    {'+
		'                      "Id": "080830",'+
		'                      "Name": "Laser",'+
		'                      "FoundIn": ['+
		'                        {'+
		'                          "SectionType": "CERTIFICATIONS"'+
		'                        }'+
		'                      ],'+
		'                      "ExistsInText": true'+
		'                    }'+
		'                  ]'+
		'                },'+
		'                {'+
		'                  "SubTaxonomyId": "308",'+
		'                  "SubTaxonomyName": "Power Engineering",'+
		'                  "PercentOfOverall": 5,'+
		'                  "PercentOfParent": 50,'+
		'                  "Skills": ['+
		'                    {'+
		'                      "Id": "080350",'+
		'                      "Name": "Laser",'+
		'                      "FoundIn": ['+
		'                        {'+
		'                          "SectionType": "CERTIFICATIONS"'+
		'                        }'+
		'                      ],'+
		'                      "ExistsInText": true'+
		'                    }'+
		'                  ]'+
		'                }'+
		'              ]'+
		'            },'+
		'            {'+
		'              "Id": "34",'+
		'              "Name": "Business Operations and General Business",'+
		'              "PercentOfOverall": 7,'+
		'              "SubTaxonomies": ['+
		'                {'+
		'                  "SubTaxonomyId": "437",'+
		'                  "SubTaxonomyName": "General Skills and Activities",'+
		'                  "PercentOfOverall": 7,'+
		'                  "PercentOfParent": 100,'+
		'                  "Skills": ['+
		'                    {'+
		'                      "Id": "025724",'+
		'                      "Name": "Staffing",'+
		'                      "FoundIn": ['+
		'                        {'+
		'                          "SectionType": "QUALIFICATIONS_SUMMARY"'+
		'                        }'+
		'                      ],'+
		'                      "ExistsInText": true'+
		'                    }'+
		'                  ]'+
		'                }'+
		'              ]'+
		'            },'+
		'            {'+
		'              "Id": "37",'+
		'              "Name": "Recruiting",'+
		'              "PercentOfOverall": 3,'+
		'              "SubTaxonomies": ['+
		'                {'+
		'                  "SubTaxonomyId": "492",'+
		'                  "SubTaxonomyName": "Recruiting Tasks and Activities",'+
		'                  "PercentOfOverall": 3,'+
		'                  "PercentOfParent": 100,'+
		'                  "Skills": ['+
		'                    {'+
		'                      "Id": "008529",'+
		'                      "Name": "Staffing",'+
		'                      "FoundIn": ['+
		'                        {'+
		'                          "SectionType": "QUALIFICATIONS_SUMMARY"'+
		'                        }'+
		'                      ],'+
		'                      "ExistsInText": true'+
		'                    }'+
		'                  ]'+
		'                }'+
		'              ]'+
		'            }'+
		'          ]'+
		'        }'+
		'      ],'+
		'      "Certifications": ['+
		'        {'+
		'          "Name": "California Registered Dental Hygienist",'+
		'          "MatchedFromList": false,'+
		'          "IsVariation": false'+
		'        },'+
		'        {'+
		'          "Name": "First Aid Responder and CPR Certified",'+
		'          "MatchedFromList": false,'+
		'          "IsVariation": false'+
		'        },'+
		'        {'+
		'          "Name": "Certifications/Licensure",'+
		'          "MatchedFromList": false,'+
		'          "IsVariation": false'+
		'        },'+
		'        {'+
		'          "Name": "CPR Certified",'+
		'          "MatchedFromList": true,'+
		'          "IsVariation": true'+
		'        },'+
		'        {'+
		'          "Name": "CPR",'+
		'          "MatchedFromList": true,'+
		'          "IsVariation": true'+
		'        }'+
		'      ],'+
		'      "LanguageCompetencies": ['+
		'        {'+
		'          "Language": "English",'+
		'          "LanguageCode": "en",'+
		'          "FoundInContext": "[RESUME_LANGUAGE]"'+
		'        }'+
		'      ],'+
		'      "QualificationsSummary": "Applicable Skills\n•   Ability to work in a team as well as individually. Positive attitude, motivated and\nproductive individual. Great chair side manner. Possess excellent communication\nskills. Great people management and commitment to work.\n\n\nQualifications\n• Subgingival chemotherapeutics and application of antimicrobial agents (Arestin)\n• Radiograph both digital and traditional, Dentrix, EagleSoft, Datacon and Open\nDental\n•   Administration of Local Anesthetic agents and Nitrous Oxide\n•   Oral cancer screening, diagnosing periodontal disease and soft tissue curettage\n•   Patient participation and involvement in oral hygiene care and instructions\n•   Individualized treatment planning with dentist\n\nReferences Available upon request\n\nTHIS RESUME is provided by Ondonte Dental Staffing to our Clients for the sole purpose of considering this individual\nfor hire through Ondonte as a Permanent employee or for a Temporary assignment. This Resume is CONFIDENTIAL\nbetween the Client, Ondonte Dental Staffing and the Individual, and it may not be otherwise distributed or used for any\nother purpose. For information please call Ondonte at 925-218-0649 or email us at sue@ondonte.com.",'+
		'      "ResumeMetadata": {'+
		'        "FoundSections": ['+
		'          {'+
		'            "FirstLinecNumber": 15,'+
		'            "LastLinecNumber": 25,'+
		'            "SectionType": "WORK HISTORY",'+
		'            "HeaderTextFound": "Professional Experience"'+
		'          },'+
		'          {'+
		'            "FirstLinecNumber": 26,'+
		'            "LastLinecNumber": 31,'+
		'            "SectionType": "SKILLS",'+
		'            "HeaderTextFound": "Applicable Skills"'+
		'          },'+
		'          {'+
		'            "FirstLinecNumber": 32,'+
		'            "LastLinecNumber": 35,'+
		'            "SectionType": "EDUCATION",'+
		'            "HeaderTextFound": "Education"'+
		'          },'+
		'          {'+
		'            "FirstLinecNumber": 36,'+
		'            "LastLinecNumber": 50,'+
		'            "SectionType": "QUALIFICATIONS_SUMMARY",'+
		'            "HeaderTextFound": "Qualifications"'+
		'          }'+
		'        ],'+
		'        "ResumeQuality": ['+
		'          {'+
		'            "Level": "Major Issues Found",'+
		'            "Findings": ['+
		'              {'+
		'                "QualityCode": "300",'+
		'                "Message": "You should not use the PDF format for your resume. Due to inherent limitations with text extraction from PDFs, you are less likely to get a job when using a PDF resume."'+
		'              }'+
		'            ]'+
		'          },'+
		'          {'+
		'            "Level": "Data Missing",'+
		'            "Findings": ['+
		'              {'+
		'                "QualityCode": "221",'+
		'                "SectionIdentifiers": ['+
		'                  {'+
		'                    "SectionType": "WORK HISTORY",'+
		'                    "Id": "POS-1"'+
		'                  },'+
		'                  {'+
		'                    "SectionType": "WORK HISTORY",'+
		'                    "Id": "POS-3"'+
		'                  },'+
		'                  {'+
		'                    "SectionType": "WORK HISTORY",'+
		'                    "Id": "POS-2"'+
		'                  },'+
		'                  {'+
		'                    "SectionType": "WORK HISTORY",'+
		'                    "Id": "POS-6"'+
		'                  },'+
		'                  {'+
		'                    "SectionType": "WORK HISTORY",'+
		'                    "Id": "POS-4"'+
		'                  },'+
		'                  {'+
		'                    "SectionType": "WORK HISTORY",'+
		'                    "Id": "POS-8"'+
		'                  },'+
		'                  {'+
		'                    "SectionType": "WORK HISTORY",'+
		'                    "Id": "POS-7"'+
		'                  },'+
		'                  {'+
		'                    "SectionType": "WORK HISTORY",'+
		'                    "Id": "POS-5"'+
		'                  }'+
		'                ],'+
		'                "Message": "Every position in a resume should have a job title."'+
		'              }'+
		'            ]'+
		'          },'+
		'          {'+
		'            "Level": "Suggested Improvements",'+
		'            "Findings": ['+
		'              {'+
		'                "QualityCode": "112",'+
		'                "Message": "The following section was identified as a skills section type: \'Applicable Skills\'. Skills should not be in a separate section, but instead, each skill should be included in the descriptions of work history or education. THIS IS INCREDIBLY IMPORTANT FOR AI MATCHING ALGORITHMS"'+
		'              },'+
		'              {'+
		'                "QualityCode": "132",'+
		'                "Message": "Multiple email addresses were found in the contact information. Only one email address should be included in a resume."'+
		'              },'+
		'              {'+
		'                "QualityCode": "133",'+
		'                "Message": "Multiple phone numbers were found in the contact information. Only one phone number ( a mobile number) should be included in a resume."'+
		'              }'+
		'            ]'+
		'          }'+
		'        ],'+
		'        "PlainText": "THIS RESUME is provided by Ondonte Dental Staffing to our Clients for the sole purpose of considering this individual\nfor hire through Ondonte as a Permanent employee or for a Temporary assignment. This Resume is CONFIDENTIAL\nbetween the Client, Ondonte Dental Staffing and the Individual, and it may not be otherwise distributed or used for any\nother purpose. For information please call Ondonte at    ~~~~~~~   or email us at    ~~~~~~~~~~  .\n\n\n   ~~~~~~  \n   ~~~~~~~~~~~~~~~~~~~~~  , Oakland, CA 94609.    ~~~~~~~  \n   ~~~~~~~~~~~  \n\nCertifications/Licensure\n•   California Registered Dental Hygienist: License #26124\n•   Advanced Laser Certification\n•   First Aid Responder and CPR Certified\n\nProfessional Experience\n•   Total Dental Health, Oakland, CA: November 2020 - Present\n•   Dr. Mckinzie, Oakland, CA: October 2012 - October 2020\n•   Washington Square Park Dental, San Francisco, CA: April 2013 - Present\n•   Hercules Dental Care, Hercules, CA: June 2013 - December 2013\n•   Dr. Tickner, San Leandro, CA: July 2012 - December 2012\n•   Pacific Dental Associates, San Francisco, CA: Temped June 2012 - August 2014\n•   Dr. Terlet & Aziz, Berkeley, CA: Temped October 2012 - September 2013\n•   Dr. Ota & Dr. Honda, Berkeley, CA: Temped April 2012 - September 2013\n•   Dr. Peterson & Dr. Chan, Oakland, CA: Temped April 2012\n\nApplicable Skills\n•   Ability to work in a team as well as individually. Positive attitude, motivated and\nproductive individual. Great chair side manner. Possess excellent communication\nskills. Great people management and commitment to work.\n\n\nEducation\n•   Chabot College: Associates of Arts, Dental Hygiene 2011\n•   Merritt College: Associates of Science, Health Science 2008\n\nQualifications\n• Subgingival chemotherapeutics and application of antimicrobial agents (Arestin)\n• Radiograph both digital and traditional, Dentrix, EagleSoft, Datacon and Open\nDental\n•   Administration of Local Anesthetic agents and Nitrous Oxide\n•   Oral cancer screening, diagnosing periodontal disease and soft tissue curettage\n•   Patient participation and involvement in oral hygiene care and instructions\n•   Individualized treatment planning with dentist\n\nReferences Available upon request\n\nTHIS RESUME is provided by Ondonte Dental Staffing to our Clients for the sole purpose of considering this individual\nfor hire through Ondonte as a Permanent employee or for a Temporary assignment. This Resume is CONFIDENTIAL\nbetween the Client, Ondonte Dental Staffing and the Individual, and it may not be otherwise distributed or used for any\nother purpose. For information please call Ondonte at    ~~~~~~~   or email us at    ~~~~~~~~~~  .",'+
		'        "DocumentLanguage": "en",'+
		'        "DocumentCulture": "en-US",'+
		'        "ParserSettings": "Coverage.PersonalAttributes = True; Coverage.Training = True; Culture.CountryCodeForUnitedKingdomIsUK = True; Culture.DefaultCountryCode = US; Culture.Language = English; Culture.PreferEnglishVersionIfTwoLanguagesInDocument = False; Data.UserDefinedParsing = False; OutputFormat.AssumeCompanyNameFromPrecedingJob = False; OutputFormat.ContactMethod.PackStyle = Split; OutputFormat.cdateOutputStyle = ExplicitlyKnowncdateInfoOnly; OutputFormat.NestJobsBasedOncdateRanges = True; OutputFormat.NormalizeRegions = False; OutputFormat.SimpleCustomLinkedIn = False; OutputFormat.SkillsStyle = Default; OutputFormat.StripParsedDataFromPositionHistoryDescription = True; OutputFormat.TelcomcNumber.Style = Raw; OutputFormat.XmlFormat = HrXmlResume25",'+
		'        "DocumentLastModified": "2022-02-28"'+
		'      }'+
		'    },'+
		'    "ConversionMetadata": {'+
		'      "DetectedType": "Pdf",'+
		'      "SuggestedFileExtension": "pdf",'+
		'      "OutputValidityCode": "ovIsProbablyValid",'+
		'      "ElapsedMilliseconds": 31,'+
		'      "DocumentHash": "E53B3A02F301A771F300591E14AF00F2"'+
		'    },'+
		'    "ParsingMetadata": {'+
		'      "ElapsedMilliseconds": 140,'+
		'      "TimedOut": false'+
		'    }'+
		'  }'+
		'}';
		
		return json.replaceAll('\n','').replaceAll('\r','');
	}
    
}