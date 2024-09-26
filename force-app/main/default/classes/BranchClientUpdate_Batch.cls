/**
 * @description BranchClientUpdate_Batch
 */
public without sharing class BranchClientUpdate_Batch implements Database.Batchable<Account> {
	private List<Id> idClients;
  
	/**
	 * @description perform runs the batch to update the related prospect, client and terminated
	 * accounts.
	 * @param  oldBranches  Previous values of the branch
	 * @param  branches     Branches working with
	 */
	public static void perform(Map<Id, Account> oldBranches, List<Account> branches) {
	  if (!branches.isEmpty()) {
		Map<Id, Account> mapBranches = new Map<Id, Account>();
  
		for (Account branch : branches) {
		  mapBranches.put(branch.Id, branch);
		}
  
		List<Account> clients = getClients(mapBranches);
		clients = getBenefitsConsultantChanged(clients, oldBranches, mapBranches);
  
		DatabaseUpdateBatch.dispatch(clients, false, 'BranchClientUpdate', 'Update Client Accounts');
	  }
	}
  
	/**
	 * @description BranchClientUpdate_Batch constructor.
	 * @param  oldBranches  Previous values of the branch
	 * @param  branches  Branches working with
	 */
	public BranchClientUpdate_Batch(List<Id> ids) {
	  idClients = ids;
	}
  
	/**
	 * @description start retrieves the list of prospect, client and terminated
	 * records to process.
	 * @param  context Information about the Batch job, including Id
	 * @return An iterator over the Accounts to process
	 */
	public Iterable<Account> start(Database.BatchableContext context) {
	  Log.info('start', 'B', 'NUMBER OF IDS: ' + idClients.size());
	  return [
		SELECT Id, Name, OwnerId, External_Id__c, Benefits_Consultant__c, Benefits_Consultant__r.Name, Prospect_Branch__c
		FROM Account
		WHERE Id IN :idClients
	  ];
	}
	
	/**
	 * @description execute performs the operation on a batch of objects.
	 * @param  context Information about the Batch job, including Id
	 * @param  scope   Contains the Client Accounts to process
	 */
	public void execute(Database.BatchableContext context, List<sObject> scope) {
	  List<Account> clients = (List<Account>) scope;
	  Log.info('start', 'C', 'NUMBER OF IDS: ' + clients.size());
  
	  Set<Id> idBranches = new Set<Id>();
  
	  for (Account client : clients) {
		idBranches.add(client.Prospect_Branch__c);
	  }
  
	  Map<Id, Account> branches = new Map<Id, Account>([
		SELECT Id, Benefits_Consultant__c
		FROM Account
		WHERE Id IN :idBranches
	  ]);
  
	  for (Account client : clients) {
		client.Benefits_Consultant__c = branches.get(client.Prospect_Branch__c).Benefits_Consultant__c;
	  }
  
	  List<Database.SaveResult> srList = Database.update(new List<Account>(clients), false);
  
	  Log.writeIfError('BranchClientUpdate_Batch.execute()', 'Database Update Failed', null, srList);
	}
  
	/**
	 * @description finish performs actions after processing has completed.
	 * @param  context Information about the Batch job, including Id
	 */
	public void finish(Database.BatchableContext context) {
	}
  
	/**
	 * @description getClients retrieves a List of clients related to the branches.
	 * @return List<Account>
	 */
	@TestVisible
	private static List<Account> getClients(Map<Id, Account> branches) {
	  /*
	  return [
		SELECT Id, Name, OwnerId, External_Id__c, Benefits_Consultant__c, Benefits_Consultant__r.Name, Prospect_Branch__c
		FROM Account
		WHERE Prospect_Branch__c IN :branches.keySet()
		AND RecordType.Name IN ('Prospect', 'Client', 'Terminated')
	  ];
	  */
  
	  return [
		SELECT Id, Name, OwnerId, External_Id__c, Benefits_Consultant__c, Benefits_Consultant__r.Name, Prospect_Branch__c
		FROM Account
		WHERE RecordType.Name IN ('Prospect', 'Client', 'Terminated')
		AND Prospect_Branch__c IN :branches.keySet()
	  ];
	}
  
	/**
	 * @description getBenefitsConsultantChanged finds all the client accounts which need
	 * update the Benefits_Consultant__c to the branch value.
	 */
	@TestVisible
	private static List<Account> getBenefitsConsultantChanged(List<Account> clients, Map<Id, Account> oldBranches, Map<Id, Account> branches) {
	  String txtLog = 'getBenefitsConsultantChanged';
  
	  List<Account> result = new List<Account>();
  
	  for (Account client : clients) {
		Id idOldBc = oldBranches.get(client.Prospect_Branch__c).Benefits_Consultant__c;
  
		txtLog += '\n' + client.Name + '  ' + client.Benefits_Consultant__c;
  
		if (client.Benefits_Consultant__c == null || client.Benefits_Consultant__c == idOldBc) {
		  client.Benefits_Consultant__c = branches.get(client.Prospect_Branch__c).Benefits_Consultant__c;
  
		  txtLog += ' TO ' + client.Benefits_Consultant__c;
		  result.add(client);
		}
	  }
  
	  System.debug(LoggingLevel.FINER, txtLog);
	  Log.info('BLAH', 'D', txtLog);
  
	  return result;
	}
  }