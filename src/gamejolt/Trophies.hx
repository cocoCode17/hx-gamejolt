package gamejolt;

import gamejolt.Types.GJTrophy;

/**
 * Handles fetching, unlocking, and removing trophies/achievements on GameJolt.
 */
class Trophies 
{
    /**
     * Unlocks a trophy for the logged-in user.
     * 
     * @param trophyId The ID of the trophy to unlock.
     * @param onResult Optional callback returning true if successfully unlocked.
     */
    public static function unlock(trophyId:Int, onResult:Bool->Void = null):Void 
    {
        if (!GameJolt.initialized) {
            trace("[GameJolt] Cannot unlock trophy: User not authenticated.");
            if (onResult != null) onResult(false);
            return;
        }

        var params = [
            "username" => GameJolt.username,
            "user_token" => GameJolt.userToken,
            "trophy_id" => Std.string(trophyId)
        ];

        GameJolt.request("trophies/add-achieved", params, function(res:Dynamic) {
            var success:Bool = (res != null && res.success == "true");
            if (onResult != null) onResult(success);
        });
    }

    /**
     * Removes an unlocked trophy from the logged-in user.
     * 
     * @param trophyId The ID of the trophy to remove.
     * @param onResult Optional callback returning true if successfully removed.
     */
    public static function remove(trophyId:Int, onResult:Bool->Void = null):Void 
    {
        if (!GameJolt.initialized) {
            if (onResult != null) onResult(false);
            return;
        }

        var params = [
            "username" => GameJolt.username,
            "user_token" => GameJolt.userToken,
            "trophy_id" => Std.string(trophyId)
        ];

        GameJolt.request("trophies/remove-achieved", params, function(res:Dynamic) {
            var success:Bool = (res != null && res.success == "true");
            if (onResult != null) onResult(success);
        });
    }

    /**
     * Fetches trophies from GameJolt.
     * 
     * @param achievedOnly If true, returns only trophies the current user has unlocked.
     * @param onResult Callback returning an array of GJTrophy objects.
     */
    public static function fetch(achievedOnly:Bool = false, onResult:Array<GJTrophy>->Void = null):Void 
    {
        var params:Map<String, String> = new Map();
        if (GameJolt.initialized) {
            params.set("username", GameJolt.username);
            params.set("user_token", GameJolt.userToken);
            if (achievedOnly) params.set("achieved", "true");
        }

        GameJolt.request("trophies", params, function(res:Dynamic) {
            if (res != null && res.success == "true") {
                var list:Array<GJTrophy> = res.trophies;
                if (onResult != null) onResult(list);
            } else {
                if (onResult != null) onResult([]);
            }
        });
    }
}