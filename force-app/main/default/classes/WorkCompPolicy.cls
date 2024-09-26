public without sharing class WorkCompPolicy 
{
    public List<String> DATALIST;
	public static String RequestBody { get { return ''; } }
	public static String ApiUrl {get {return '/getWorkCompPolicies'; }}

    public static WorkCompPolicy parse(String json) {
        return (WorkCompPolicy) System.JSON.deserialize(json, WorkCompPolicy.class);
    }
}