@isTest
public class TestFactoryClientCancellation {
	 /**
	 * @description createClientCancellation makes a new Client_Cancellation__c record in the database.
	 * @param  Client      	Id of Client
	 * @param  CancellationDate        Cancellation Date
	 * @param  RequestedCancellation        Requested Cancellation
	 * @param  fldMap 		additional field values for the Client_Cancellation__c
	 * @return Client_Cancellation__c
	 */  
    
    public static Client_Cancellation__c createClientCancellation(Id Client, Date CancellationDate, String RequestedCancellation, Map<String, Object> fldMap){
      Client_Cancellation__c cancel = makeClientCancellation(Client, CancellationDate, RequestedCancellation, fldMap);	
	  insert cancel;
	  return cancel;
    }

	
     /**
	 * @description makeClientCancellation creates a new Client_Cancellation__c record in the database.
	 * @param  Client      	Id of Client
	 * @param  CancellationDate        Cancellation Date
	 * @param  RequestedCancellation        Requested Cancellation
	 * @param  fldMap 		additional field values for the Client_Cancellation__c
	 * @return Client_Cancellation__c
	 */
	public static Client_Cancellation__c makeClientCancellation(Id Client, Date CancellationDate,String RequestedCancellation, Map<String, Object> fldMap){
        Client_Cancellation__c cancel = new Client_Cancellation__c();
		cancel.Client__c = Client;
        cancel.Client_Cancellation_Date__c = CancellationDate;
        cancel.Who_Requested_Cancellation__c = RequestedCancellation;
        
		if (fldMap != null) {
			cancel = (Client_Cancellation__c) TestFactory.assignFields(fldMap, cancel);
		}

        return cancel;
    }

	/**
	 * @description makeClientCancellation creates a new Client_Cancellation__c record in the database with default data..
	 * @param  Client      	Id of Client
	 * @param  CancellationDate        Cancellation Date
	 * @param  RequestedCancellation        Requested Cancellation
	 * @param  status      Status of Approval
	 * @param  fldMap 		additional field values for the Client_Cancellation__c
	 * @return Client_Cancellation__c
	 */
	public static Client_Cancellation__c makeClientCancellation(Id Client, Date CancellationDate, String RequestedCancellation, String status, Map<String, Object> fldMap){
        Client_Cancellation__c cancel = new Client_Cancellation__c(
			Client__c = Client,
        	Client_Cancellation_Date__c = CancellationDate,
			AM_Approval_Status__c = status,
			AM_Comments__c = 'AM_Comments__c',
			Cancellation_decision_due_to_COVID_19__c = 'No',
			Cancellation_Reason__c = 'Cancellation_Reason__c',
			Consistent_CORE__c = true,
			Contracts_Comments__c = 'Contracts_Comments__c',
			Contracts_Reviewed__c = true,
			Deep_Dive_Completed__c = true,
			Employees_Notified__c = Date.newInstance(2022, 1, 1),
			Explanation__c = 'Explanation__c',
			Had_Blueprint__c = true,
			Improvement__c = 'Improvement__c',
			Last_Check_Date__c = Date.newInstance(2022, 1, 1),
			Last_Core_Visit__c = Date.newInstance(2021, 10, 15),
			Local_ORT_Attendance__c = true,
			Red_Flags__c = 'Red_Flags__c',
			Regular_Meetings__c = true,
			Revoke__c = false,
			Revoked_Reason__c = 'Revoked_Reason__c',
			RP_Alignment__c = 'Excellent',
			RP_Follow_up_Completed__c = true,
			RP_Follow_up_Date__c = Date.newInstance(2021, 1, 1),
			Runoff_Forensic_Report_Attached__c = false,
			Safety_Incentive_Reason__c = 'Safety_Incentive_Reason__c',
			Safety_Incentive_Refund_Request__c = false,
			Security_Deposit_Amount__c = 10000.00,
			Tax_Dept_Archived__c = false,
			Via__c = 'Via__c',
			Where_did_the_business_go__c = 'Payroll Competitor',
			Where_Framework_Failed__c = 'Market',
			Who_Requested_Cancellation__c = RequestedCancellation
		);		
        
		if (fldMap != null) {
			cancel = (Client_Cancellation__c) TestFactory.assignFields(fldMap, cancel);
		}
        return cancel;
    }
	/**
	 * @description createClientCancellation makes a new Client_Cancellation__c record in the database.
	 * @param  Client      	Id of Client
	 * @param  CancellationDate        Cancellation Date
	 * @param  RequestedCancellation        Requested Cancellation
	 * @param  status      Status of Approval
	 * @param  fldMap 		additional field values for the Client_Cancellation__c
	 * @return Client_Cancellation__c
	 */  
    
	 public static Client_Cancellation__c createClientCancellation(Id Client, Date CancellationDate, String RequestedCancellation, String status, Map<String, Object> fldMap){
		Client_Cancellation__c cancel = makeClientCancellation(Client, CancellationDate, RequestedCancellation, status, fldMap);	
		insert cancel;
		return cancel;
	  }
}