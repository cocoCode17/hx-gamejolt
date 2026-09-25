package gamejolt;

/**
 * Handles cloud storage (key-value pairs) for individual users or globally for the game.
 */
class DataStore 
{
    /**
     * Saves data to GameJolt cloud storage under a specific key.
     * 
     * @param key Unique key name for the stored item.
     * @param data String data content to save.
     * @param global If true, saves to global game storage; if false, saves to user-specific storage.
     * @param onResult Optional callback returning true if saved successfully.
     */
    public static function set(key:String, data:String, global:Bool = false, onResult:Bool->Void = null):Void 
    {
        var params:Map<String, String> = new Map();
        params.set("key", key);
        params.set("data", data);

        if (!global) {
            if (!GameJolt.initialized) {
                trace("[GameJolt] Cannot set user DataStore key: User not logged in.");
                if (onResult != null) onResult(false);
                return;
            }
            params.set("username", GameJolt.username);
            params.set("user_token", GameJolt.userToken);
        }

        GameJolt.request("data-store/set", params, function(res:Dynamic) {
            var success:Bool = (res != null && res.success == "true");
            if (onResult != null) onResult(success);
        });
    }

    /**
     * Retrieves stored data from the cloud using its key.
     * 
     * @param key Key name of the item to fetch.
     * @param global If true, fetches from global game storage; if false, fetches from user storage.
     * @param onResult Callback returning the stored string value (or null if not found).
     */
    public static function get(key:String, global:Bool = false, onResult:String->Void = null):Void 
    {
        var params:Map<String, String> = new Map();
        params.set("key", key);

        if (!global) {
            if (!GameJolt.initialized) {
                if (onResult != null) onResult(null);
                return;
            }
            params.set("username", GameJolt.username);
            params.set("user_token", GameJolt.userToken);
        }

        GameJolt.request("data-store", params, function(res:Dynamic) {
            if (res != null && res.success == "true") {
                if (onResult != null) onResult(res.data);
            } else {
                if (onResult != null) onResult(null);
            }
        });
    }
}