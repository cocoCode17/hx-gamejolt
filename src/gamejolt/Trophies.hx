package gamejolt;

class Trophies 
{
    /**
     * Unlocks a trophy for the authenticated user by trophy ID.
    **/
    public static function unlock(trophyId:Int, onResult:Bool->Void = null):Void 
    {
        if (!GameJolt.initialized) {
            trace("[GameJolt Warning] Cannot unlock trophy. User is not logged in.");
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
     * Fetches all trophies or user trophy progress.
    **/
    public static function fetch(achievedOnly:Bool = false, onResult:Array<Dynamic>->Void = null):Void 
    {
        var params:Map<String, String> = new Map();
        if (GameJolt.initialized) {
            params.set("username", GameJolt.username);
            params.set("user_token", GameJolt.userToken);
        }

        GameJolt.request("trophies", params, function(res:Dynamic) {
            if (res != null && res.success == "true") {
                var list:Array<Dynamic> = res.trophies;
                if (onResult != null) onResult(list);
            } else {
                if (onResult != null) onResult([]);
            }
        });
    }
}