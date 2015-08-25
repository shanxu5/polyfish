public class YefimTest {
  public static void runIt() {
    List<Case> tenQueues = [select Id, OwnerId, Owner.Type from Case where Owner.Type = 'Queue' limit 10];
      
    List<Case> tenUsers = [select Id, OwnerId, Owner.Type from Case where Owner.Type = 'User' limit 10];

    System.debug('tenQueues[0] = ' + tenQueues[0]);

    System.debug('tenUsers[0] = ' + tenUsers[0]);

    String cQType = 'empty';
    String cUType = 'empty';

    cQType = tenQueues[0].Owner.Type;

    System.debug('cQType = ' + cQType);

    cUType = tenUsers[0].Owner.Type;

    System.debug('cUType = ' + cUType);
  }
}