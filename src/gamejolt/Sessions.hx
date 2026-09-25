package gamejolt;

import haxe.Timer;

/**
 * Tracks real-time active sessions and handles keep-alive background pings.
 */
class Sessions 
{
    private static var pingTimer:Timer = null;

    /**
     * Opens a session on GameJolt for the logged-in user.
     * 
     * @param autoPing If true, automatically starts a background timer to ping GameJolt every 30 seconds.
     * @param onResult Optional callback returning true if the session opened successfully.
     */
    public static function open(autoPing:Bool = true, onResult:Bool->Void = null):Void 
    {
        if (!GameJolt.initialized) {
            trace("[GameJolt] Cannot open session: User is not authenticated.");
            if (onResult != null) onResult(false);
            return;
        }

        var params = [
            "username" => GameJolt.username,
            "user_token" => GameJolt.userToken
        ];

        GameJolt.request("sessions/open", params, function(res:Dynamic) {
            var success:Bool = (res != null && res.success == "true");
            
            if (success && autoPing) {
                startAutoPing();
            }

            if (onResult != null) onResult(success);
        });
    }

    /**
     * Sends a manual heartbeat ping to keep the active session alive.
     * 
     * @param status Activity state, typically "active" or "idle".
     * @param onResult Optional callback returning true if the ping was acknowledged.
     */
    public static function ping(status:String = "active", onResult:Bool->Void = null):Void 
    {
        if (!GameJolt.initialized) return;

        var params = [
            "username" => GameJolt.username,
            "user_token" => GameJolt.userToken,
            "status" => status
        ];

        GameJolt.request("sessions/ping", params, function(res:Dynamic) {
            var success:Bool = (res != null && res.success == "true");
            if (onResult != null) onResult(success);
        });
    }

    /**
     * Closes the active player session and stops any running auto-ping timer.
     * 
     * @param onResult Optional callback returning true if the session closed successfully.
     */
    public static function close(onResult:Bool->Void = null):Void 
    {
        stopAutoPing();

        if (!GameJolt.initialized) return;

        var params = [
            "username" => GameJolt.username,
            "user_token" => GameJolt.userToken
        ];

        GameJolt.request("sessions/close", params, function(res:Dynamic) {
            var success:Bool = (res != null && res.success == "true");
            if (onResult != null) onResult(success);
        });
    }

    /**
     * Starts background auto-pinging at a set interval so the session stays active.
     * 
     * @param intervalSeconds How often to ping GameJolt in seconds (default: 30s).
     */
    public static function startAutoPing(intervalSeconds:Int = 30):Void 
    {
        stopAutoPing();

        var ms = intervalSeconds * 1000;
        pingTimer = new Timer(ms);
        pingTimer.run = function() {
            ping("active");
        };
        
        trace('[GameJolt] Auto-ping started (Interval: ${intervalSeconds}s).');
    }

    /**
     * Stops the auto-ping background process if it is currently running.
     */
    public static function stopAutoPing():Void 
    {
        if (pingTimer != null) {
            pingTimer.stop();
            pingTimer = null;
            trace("[GameJolt] Auto-ping stopped.");
        }
    }
}