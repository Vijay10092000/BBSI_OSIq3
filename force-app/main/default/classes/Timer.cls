/**
 * @description Timer is a simple timer for milliseconds of runtime.
 * Timer will continue to add time between start and stop unless reset.
 */
public with sharing class Timer {
	private Long start;
	private Long total;

	/**
	 * @description isRunning returns if the Timer is currently running
	 */
	public Boolean isRunning { get; private set; }

	/**
	 * @description Timer constructor.
	 */
    public Timer() {
		isRunning = false;
		total = 0;
    }

	/**
	 * @description Timer constructor.
	 * @param start  Starts the timer
	 */
    public Timer(Boolean start) {
		start(true);
    }

	/**
	 * @description start starts the timer.  Accumulation of time is not reset.
	 */
	public void start() {
		start(false);
	}

	/**
	 * @description start starts the timer.
	 * @param  reset  Clear the total of time?
	 */
	public void start(Boolean reset) {
		if (reset) {
			total = 0;
		}

		isRunning = true;
		start = DateTime.now().millisecond();
	}

	/**
	 * @description stop stops the timer.
	 * @return Current total of time
	 */
	public Long stop() {
		if (isRunning) {
			total += DateTime.now().millisecond() - start;
			isRunning = false;
		}

		return total;
	}

	/**
	 * @description reset stops and clears the current Timer.
	 */
	public void reset() {
		isRunning = false;
		total = 0;
	}

	/**
	 * @description elapsed returns the accumulated time in milliseconds
	 * on the timer.  If running, it will add the current running time.
	 * @return Current total of time
	 */
	public Long elapsed() {
		if (isRunning) {
			return total + (DateTime.now().millisecond() - start);
		}

		return total;
	}
}