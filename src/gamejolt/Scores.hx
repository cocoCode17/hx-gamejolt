package gamejolt;

import gamejolt.Types.GJScore;

/**
 * Manages posting high scores and pulling leaderboard data from GameJolt.
 */
class Scores 
{
    /**
     * Submits a new score entry to a leaderboard table.
     * 
     * @param score Display string for the score (e.g. "100,000 Pts").
     * @param sort Numerical value used by GameJolt to sort rankings (e.g. 100000).
     * @param tableId Target table ID. Leave at 0 to use the primary score table.
     * @param guestName Optional name if submitting on behalf of a guest (ignored if logged in).
     * @param extraData Custom metadata string to store alongside the score.
     * @param onResult Optional callback returning true if the score was accepted.
     */
    public static function add(score:String, sort:Int, tableId:Int = 0, guestName:String = "", extraData:String = "", onResult:Bool->Void = null):Void 
    {
        if (GameJolt.gameId == 0) {
            trace("[GameJolt] Cannot submit score: Library uninitialized.");
            if (onResult != null) onResult(false);
            return;
        }

        var params:Map<String, String> = new Map();
        
        params.set("score", StringTools.urlEncode(score));
        params.set("sort", Std.string(sort));

        if (tableId > 0) {
            params.set("table_id", Std.string(tableId));
        }

        if (extraData != null && StringTools.trim(extraData) != "") {
            params.set("extra_data", StringTools.urlEncode(extraData));
        }

        // Strict handling: authenticated user vs guest submission
        if (GameJolt.initialized && GameJolt.username != "") {
            params.set("username", StringTools.urlEncode(GameJolt.username));
            params.set("user_token", StringTools.urlEncode(GameJolt.userToken));
        } else if (guestName != null && StringTools.trim(guestName) != "") {
            params.set("guest", StringTools.urlEncode(guestName));
        } else {
            trace("[GameJolt] Cannot submit score: User is not logged in and no guest name was provided.");
            if (onResult != null) onResult(false);
            return;
        }

        GameJolt.request("scores/add", params, function(res:Dynamic) {
            var success:Bool = (res != null && res.success == "true");
            if (onResult != null) onResult(success);
        });
    }

    /**
     * Fetches scores from a specified leaderboard table.
     * 
     * @param tableId Score table ID (0 for primary table).
     * @param limit Maximum number of score entries to retrieve (default: 10).
     * @param onResult Callback returning an array of GJScore entries.
     */
    public static function fetch(tableId:Int = 0, limit:Int = 10, onResult:Array<GJScore>->Void = null):Void 
    {
        var params:Map<String, String> = new Map();
        params.set("limit", Std.string(limit));

        if (tableId > 0) {
            params.set("table_id", Std.string(tableId));
        }

        GameJolt.request("scores", params, function(res:Dynamic) {
            if (res != null && res.success == "true" && res.scores != null) {
                var list:Array<GJScore> = cast res.scores;
                if (onResult != null) onResult(list);
            } else {
                if (onResult != null) onResult([]);
            }
        });
    }
}