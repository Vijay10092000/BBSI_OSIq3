/**
 * BusinessUnitMember_Service
 */
public class BusinessUnitMember_Service {

    /**
     * updateBUMContacts
     * Called during AFTER INSERT and AFTER UPDATE trigger
     * NOTE: This code was taken from the Trigger PopulateBusinessUnitMembers_BUC_trigger.
     */
    public static void updateBUMContacts(Map<Id, Business_Unit_Contact__c> newValues, Map<Id, Business_Unit_Contact__c> oldValues) {
        Set<Id> newBUC = new Set<Id>();
        Set<Id> oldBUC = new Set<Id>();
        Map<Id, Business_Unit_Contact__c> bucBU = new Map<Id, Business_Unit_Contact__c>();
        Set<Id> BU = new Set<Id>(); 

        for (Business_Unit_Contact__c buc : newValues.values()) {
            if (oldValues == null || buc.Active__c != oldValues.get(buc.Id).Active__c) {
                if (buc.Active__c) {
                    newBUC.add(buc.ID);
                    bucBU.put(buc.Business_Unit__c, buc);
                    BU.add(buc.Business_Unit__c);         
                }
                else {
                    oldBUC.add(buc.Id);
                    BU.add(buc.Business_Unit__c);
                } 
            } 
        }

        if (newBUC.size() > 0 && bucBU.size() > 0) {        
            AccountTeamMembers.addBUMContact(newBUC, bucBU);
        }
        
        if (oldBUC.size() > 0 && BU.size() > 0) {     
            AccountTeamMembers.removeBUMContact(oldBUC, BU);         
        }
    }

    /**
     * reviewChatterGroupMembers determines if a related ChatterGroup (CollaborationGroup)
     * exists for the Business_Unit_Member__c and creates ones if it does not exists adding
     * members as needed.
     * Called during BEFORE INSERT and BEFORE UPDATE trigger
     * 
     * @param newValues - The changed or new values for a Business Unit.
     */
    public static void reviewChatterGroupMembers(List<Business_Unit_Contact__c> newValues) {
        BusinessUnitMember_Service service = new BusinessUnitMember_Service();

        service.setup(newValues);
        service.setActiveChatterGroupMembers(newValues);
        service.removeInactiveChatterGroupMembers(newValues);
        service.correctChatterGroupOwner();
        service.shutdown();
    }

    /**
     * removeChatterGroupMembers removes deleted Business_Unit_Contact__c.
     * Called during BEFORE DELETE trigger
     * 
     * @param oldValues - The members being deleted
     */
    public static void removeChatterGroupMembers(List<Business_Unit_Contact__c> oldValues) {
        BusinessUnitMember_Service service = new BusinessUnitMember_Service();

        List<Business_Unit_Contact__c> tempValues = new List<Business_Unit_Contact__c>();

        for (Business_Unit_Contact__c bum : oldValues) {
            Business_Unit_Contact__c tbum = bum.clone(true, false, true, true);
            tbum.Active__c = false;
            tbum.Inactive_Date__c = Date.today();
            tempValues.add(tbum);
        }

        service.setup(tempValues);
        service.setActiveChatterGroupMembers(tempValues);
        service.removeInactiveChatterGroupMembers(tempValues);
        service.correctChatterGroupOwner();
        service.shutdown();
    }

    // Relates Business Unit to active Business Unit Members
    Map<Id, Map<Id, Business_Unit_Contact__c>> mapBUtoBUMs;
    // Relates CollaborationGroup to Collaboration Group Members
    Map<Id, Map<Id, CollaborationGroupMember>> mapCGtoCGMs;

    @testVisible
    private BusinessUnitMember_Service() {
    }

    Map<Id, Business_Unit__c> mapBUs;
    Set<CollaborationGroup> cgs;
    Set<CollaborationGroupMember> cgms;
    Set<Business_Unit_Contact__c> bums;
    List<CollaborationGroupMember> deleteCGMs = new List<CollaborationGroupMember>();
    List<CollaborationGroup> updateCGs = new List<CollaborationGroup>();

    private void setup(List<Business_Unit_Contact__c> newValues) {
       Set<Id> idBUs = new Set<Id>();
       Set<Id> idCGs = new Set<Id>();

        for (Business_Unit_Contact__c bum : newValues) {
            idBUs.add(bum.Business_Unit__c);
        }

        mapBUs = new Map<Id, Business_Unit__c>(
            [SELECT Id, Name, Chatter_Group_Id__c FROM Business_Unit__c WHERE Id IN :idBUs]
        );

        for (Business_Unit__c bu : mapBUs.values()) {
            idCGs.add(bu.Chatter_Group_Id__c);
        }

        cgs = new Set<CollaborationGroup>(
            [SELECT Id, OwnerId FROM CollaborationGroup WHERE Id IN :idCGs]
        );

        cgms = new Set<CollaborationGroupMember>(
            [SELECT Id, MemberId, CollaborationGroupId, CollaborationRole FROM CollaborationGroupMember WHERE CollaborationGroupId IN :idCGs]
        );

        bums = new Set<Business_Unit_Contact__c>([
            SELECT Id, Business_Unit__c, BU_User_Id__c, Chatter_Group_Member_Id__c, Active__c 
            FROM Business_Unit_Contact__c 
            WHERE Business_Unit__c IN :idBUs
            AND Active__c = true
        ]);
    }

    private void shutdown() {
        if (!updateCGs.isEmpty()) {
            update updateCGs;
        }

        for (CollaborationGroup cg : cgs) {
            if (!deleteCGMs.isEmpty()) {
                for (Integer i = 0; i < deleteCGMS.size(); i++) {
                    if (cg.Id == deleteCGMS[i].CollaborationGroupId && cg.OwnerId == deleteCGMS[i].MemberId) {
                        deleteCGMS.remove(i);
                        break;
                    }
                }
            }
        }

        if (!deleteCGMs.isEmpty()) {
            delete deleteCGMs;
        }
    }

    private void setActiveChatterGroupMembers(List<Business_Unit_Contact__c> newValues) {
        List<Business_Unit_Contact__c> insertBUMs = new List<Business_Unit_Contact__c>();
        List<CollaborationGroupMember> insertCGMs = new List<CollaborationGroupMember>();

        Set<Id> idUsers = new Set<Id>();
        for (Business_Unit_Contact__c bum : newValues) {
            if (bum.BU_User_Id__c != null) {
                idUsers.add(bum.BU_User_Id__c);
            }
        }

        Map<Id, User> mapUsers = new Map<Id, User>([SELECT Id, Name FROM User WHERE IsActive = true AND Id IN :idUsers]);

        // Find all the active Business Unit Members without a CollaborationGroupMember
        for (Business_Unit_Contact__c bum : newValues) {
            if (bum.Active__c) {
                Id idCG = mapBUs.get(bum.Business_Unit__c).Chatter_Group_Id__c;

                Boolean found = false;
                for (CollaborationGroupMember cgm : cgms) {
                    if (cgm.MemberId == bum.BU_User_Id__c && cgm.CollaborationGroupId == idCG) {
                        bum.Chatter_Group_Member_Id__c = cgm.Id;
                        found = true;
                        break;
                    }
                }

                if (!found) {
                    if (bum.BU_User_Id__c != null && mapUsers.containsKey(bum.BU_User_Id__c)) {
                        insertBUMs.add(bum);
                        insertCGMs.add(
                            new CollaborationGroupMember(
                                CollaborationGroupId = idCG,
                                CollaborationRole = 'Admin',
                                MemberId = bum.BU_User_Id__c
                            )
                        );
                    }
                }
            }
        }

        if (!insertCGMs.isEmpty()) {
            insertCGMs = removeDuplicateCGMs(insertCGMs);
            // Create CollaborationGroupMembers
            insert insertCGMs;

            cgms.addAll(insertCGMs);

            // Assign the CollaborationGroupMembers
            for (Business_Unit_Contact__c bum : insertBUMs) {
                Id idCG = mapBUs.get(bum.Business_Unit__c).Chatter_Group_Id__c;

                Boolean found = false;
                for (CollaborationGroupMember cgm : insertCGMs) {
                    if (cgm.MemberId == bum.BU_User_Id__c && cgm.CollaborationGroupId == idCG) {
                        bum.Chatter_Group_Member_Id__c = cgm.Id;
                        break;
                    }
                }
            }
        }
    }

    private void removeInactiveChatterGroupMembers(List<Business_Unit_Contact__c> newValues) {
        for (Business_Unit_Contact__c bum : newValues) {
            if (bum.Active__c) {
                bums.add(bum);
            }
            else {
                for (Business_Unit_Contact__c prevBum: bums) {
                    if (prevBum.Id == bum.Id) {
                        bums.remove(prevBum);
                    }
                }
            }
        }

        for (CollaborationGroupMember cgm : cgms) {
            Boolean found = false;
            for (Business_Unit_Contact__c bum : bums) {
                if (bum.Active__c && cgm.MemberId == bum.BU_User_Id__c) {
                    found = true;
                    break;
                }
            }

            if (!found) {
                deleteCGMs.add(cgm);
                cgms.remove(cgm);
            }
        }         
    }

    private void correctChatterGroupOwner() {
        if (!cgs.isEmpty()) {
            Map<Id, List<CollaborationGroupMember>> mapCGtoCGMs = new Map<Id, List<CollaborationGroupMember>>();

            for (CollaborationGroupMember cgm : cgms) {
                if(!mapCGtoCGMs.containsKey(cgm.CollaborationGroupID)) {
                    mapCGtoCGMs.put(cgm.CollaborationGroupID, new List<CollaborationGroupMember>());
                }

                mapCGtoCGMs.get(cgm.CollaborationGroupID).add(cgm);
            }

            for (CollaborationGroup cg : cgs) {
                if (mapCGtoCGMs.containsKey(cg.Id) && !mapCGtoCGMs.get(cg.Id).isEmpty()) {
                    Boolean found = false;

                    for (CollaborationGroupMember cgm : cgms) {
                        if (cgm.MemberId == cg.OwnerId) {
                            found = true;
                            break;
                        }
                    }

                    if (!found) {
                        if (mapCGtoCGMs.containsKey(cg.Id) && !mapCGtoCGMs.get(cg.Id).isEmpty()) {
                            Id newOwnerId = mapCGtoCGMs.get(cg.Id).get(0).MemberId;
                            cg.OwnerId = newOwnerId;
                            updateCGs.add(cg);
                        }
                    }
                }
            }
        }
    }

    @TestVisible
    private List<CollaborationGroupMember> removeDuplicateCGMs(List<CollaborationGroupMember> listCGMs) {
        if (listCGMs != null) {
            for (Integer i = listCGMs.size() - 1; 0 < i; i--) {
                for (Integer j = i - 1; 0 <= j; j--) {
                    if (listCGMs[i].CollaborationGroupId == listCGMs[j].CollaborationGroupId &&
                        listCGMs[i].MemberId == listCGMs[j].MemberId) {
                        listCGMs.remove(i);
                        break;
                    }
                }
            }
        }

        return listCGMs;
    }

}