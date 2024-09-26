public class RenewalTermination {

    private static Map<ID, ID> clientsRenewals = new Map<ID, ID>();
    private static List<Renewal__c> renewals;
    private static String terminatedStr = 'Terminated';
    private static Id clientTypeId = RecordTypeService.getId('Account','Client');
    private static Id terminatedTypeId = RecordTypeService.getId('Account','Terminated');

    public static void processRenewalTermination(List<Account> listAccounts, Map<ID, Account> mapOldAccounts){
        // populate client list
        BuildTerminatedClientMap(listAccounts, mapOldAccounts);

        // return if we have nothing to do
        If(clientsRenewals.size() == 0){
            return;
        }
        
        // get all related Renewal Objects
        BuildRenewalsList();
        // check each Client in the Renewal Objects list
        List<Renewal__c> renewalsToTerminate = new List<Renewal__c>();
        
        For(Renewal__c item : renewals){
            Boolean terminated = True;
            For(Account client : item.Clients__r){
                If(client.Status__c != terminatedStr){
                    terminated = False;
                    break;
                }
            }
            
            If(terminated){
                item.Status__c = terminatedStr;
                renewalsToTerminate.Add(item);
            }
        }
		
        If(renewalsToTerminate.size() > 0){
            update renewalsToTerminate;
        }

    }

    private static void BuildTerminatedClientMap(List<Account> listAccounts, Map<ID, Account> mapOldAccounts){
        For(Account item : listAccounts){
            If(item.RecordTypeId == clientTypeId || item.RecordTypeId == terminatedTypeId){
                If(item.Renewal__c != null && item.Status__c == terminatedStr && mapOldAccounts.get(item.ID).Status__c != terminatedStr){
                    If(!clientsRenewals.containsKey(item.ID)){
                        clientsRenewals.put(item.ID, item.Renewal__c);
                    }
                }
            }
        }
    }

    private static void BuildRenewalsList(){
        renewals = [SELECT ID, Status__c, (SELECT ID, Status__c FROM Clients__r) 
                    FROM Renewal__c 
                    WHERE ID in : clientsRenewals.values()];
    }

}