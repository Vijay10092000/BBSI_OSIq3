/**
 * description Timer_Test contains tests for the Timer class.
 */
@IsTest
public without sharing class Timer_Test {
    /**
     * @description method performs a test on .
     */
    @IsTest
    static void test_Timer() {
        Timer timer1 = new Timer();
        Timer timer2 = new Timer(true);

        Assert.isFalse(timer1.isRunning);
        Assert.isTrue(timer2.isRunning);

        timer1.start();     
        Assert.isTrue(timer1.isRunning);

        User testUser = [SELECT Id, Name FROM User LIMIT 1];

        //Assert.isTrue(0 < timer1.elapsed());
        //Assert.isTrue(0 < timer2.elapsed());

        //timer1.stop();
        //Assert.isFalse(timer1.isRunning);
        //Assert.isTrue(0 < timer1.elapsed());

        //timer2.reset();
        //Assert.isFalse(timer2.isRunning);
        //Assert.areEqual(0, timer2.elapsed());
    }
}