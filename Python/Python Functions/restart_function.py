import time

def restart_function(failedfunction, tries=5, delay=1):
    """Try to restart the function after exception is thrown."""
    for attempt in range(tries):
        try:
            return failedfunction()
        except Exception as e:
            if attempt < tries - 1:
                time.sleep(delay)
            else:
                raise e