/*
 *  Usage example
 *  try{
 *     something that can break
 *   } catch (Exception e){
 *     throw new RenewalException('special message');
 *      OR
 *     throw new RenewalException('special message with original exception', e);
 *   }
*/
public class RenewalException extends Exception {}