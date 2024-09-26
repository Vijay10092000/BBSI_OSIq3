/**
 * EntitySubscription_Service contains methods to create and retrieve
 * EntitySubscription objects.
 */
public without sharing class EntitySubscription_Service {

    /**
     * makeEnitySubscription makes a new EntitySubscription.
     * @param  idParent     Id of the record being followed
     * @param  idSubscriber Id of User following the record
     * @return An EntitySubscription
     */
    public static EntitySubscription makeEntitySubscription(Id idParent, Id idSubscriber) {
        return new EntitySubscription(
            ParentId = idParent,
            SubscriberId = idSubscriber
        );
    }

    /**
     * addSubscribers adds the given EntitySubscriptions into the database.  Records
     * are still created if there are duplicate entries.
     * @param  subscribers  List of EntitySubscriptions to put into the database.
     */
    public static void addSubscribers(List<EntitySubscription> subscribers) {
        if (!subscribers.isEmpty()) {
            Database.SaveResult[] results = database.insert(subscribers, false);

            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        if (err.getStatusCode() != StatusCode.DUPLICATE_VALUE) {
                            System.debug(LoggingLevel.ERROR, err.getMessage() + ' (' + err.getStatusCode() + '). Fields causing error: ' + err.getFields());
                        }
                    }
                }
            }
        }
    }

    /**
     * addSubscribers creates new subscriptions to the parent objects
     * after checks are made to remove subscriptions which already exist.
     * @param  mapParentToSubscribers mapping of parents to their User subscribers
     */
    public static void addSubscribers(Map<Id, Set<Id>> mapParentToSubscribers) {
        List<EntitySubscription> newSubscribers = new List<EntitySubscription>();

        for (Id idParent : mapParentToSubscribers.keySet()) {
            for (Id idSubscriber : mapParentToSubscribers.get(idParent)) {
                if (Id_Service.isType(idSubscriber, 'User')) {
                    newSubscribers.add( makeEntitySubscription(idParent, idSubscriber) );
                }
            }
        }

        addSubscribers(newSubscribers);        
    }

    /**
     * getSubscribers retrieves the subscribers for each of the Parent Id given.
     * @param  idParents a set of parent ids
     * @return A map relating the given parent ids to their subscribers.
     */
    public static Map<Id, Set<EntitySubscription>> getSubscribers(Set<Id> idParents) {
        Map<Id, Set<EntitySubscription>> results = new Map<Id, Set<EntitySubscription>>();

        for (Id id : idParents) {
            results.put(Id, new Set<EntitySubscription>());
        }

        for (EntitySubscription es : [SELECT ParentId, SubscriberId FROM EntitySubscription WHERE ParentId IN :idParents]) {
            results.get(es.ParentId).add(es);
        }

        return results;
    }

    /**
     * removeAllSubscribers removes all the subscribers for each of the Parent Ids given.
     * @param  idParents a set of parent ids
     */
    public static void removeAllSubscribers(Set<Id> idParents) {
        if (!idParents.isEmpty()) {
            List<EntitySubscription> ess = [SELECT Id, ParentId, SubscriberId FROM EntitySubscription WHERE ParentId IN :idParents];
            delete ess;
        }
    }

}