package gamejolt;

import haxe.Http;
import haxe.Json;
import haxe.crypto.Md5;

/**
 * The core manager for hx-gamejolt. 
 * Handles initial setup, user authentication, and signing HTTP requests for GameJolt API v1.2.
 */
class GameJolt 
{
    /** The Game ID provided by GameJolt. */
    public static var gameId:Int = 0;

    /** The Game Private Key from your GameJolt dashboard. Keep this safe! */
    public static var privateKey:String = "";

    /** The username of the currently logged-in player. */
    public static var username:String = "";

    /** The Game Token of the currently logged-in player. */
    public static var userToken:String = "";

    /** Returns true if a user is successfully logged in. */
    public static var initialized(default, null):Bool = false;

    private static inline var API_URL:String = "https://api.gamejolt.com/api/game/v1_2";

    /**
     * Sets up the library with your game's credentials. Call this before doing anything else!
     * 
     * @param id The Game ID assigned to your project.
     * @param key The Game Private Key found in your API settings.
     */
    public static function init(id:Int, key:String):Void 
    {
        gameId = id;
        privateKey = StringTools.trim(key);
    }

    /**
     * Attempts to log in a player with their GameJolt username and Game Token.
     * 
     * @param user The player's GameJolt username.
     * @param token The player's Game Token (NOT their main account password).
     * @param onResult Callback returning true if authentication succeeded.
     */
    public static function login(user:String, token:String, onResult:Bool->Void):Void 
    {
        username = StringTools.trim(user);
        userToken = StringTools.trim(token);

        var params = [
            "username" => username,
            "user_token" => userToken
        ];

        request("users/auth", params, function(response:Dynamic) {
            var success:Bool = (response != null && response.success == "true");
            initialized = success;
            
            if (!success) {
                username = "";
                userToken = "";
            }
            
            if (onResult != null) onResult(success);
        });
    }

    /**
     * Logs out the current player and resets the user session locally.
     */
    public static function logout():Void 
    {
        username = "";
        userToken = "";
        initialized = false;
    }

    /**
     * Internal function that builds, signs, and executes HTTP requests to GameJolt.
     * Generates a lowercase MD5 signature based on the endpoint, parameters, and private key.
     * 
     * @param endpoint The API endpoint path (e.g. "scores/add").
     * @param params Key-value map of parameters to include in the request.
     * @param onResult Callback returning the parsed JSON response object.
     */
    public static function request(endpoint:String, params:Map<String, String>, onResult:Dynamic->Void):Void 
    {
        if (gameId == 0 || privateKey == "") {
            trace("[GameJolt] Error: Library uninitialized. Call GameJolt.init() first.");
            if (onResult != null) onResult(null);
            return;
        }

        var queryString = 'game_id=${gameId}';
        for (key in params.keys()) {
            queryString += '&${key}=${StringTools.trim(params.get(key))}';
        }

        var baseUrl = '${API_URL}/${endpoint}/?${queryString}';
        var stringToSign = baseUrl + privateKey;
        var signature = Md5.encode(stringToSign).toLowerCase();
        var finalUrl = '${baseUrl}&signature=${signature}';

        var http = new Http(finalUrl);
        
        http.onData = function(data:String) {
            try {
                var json:Dynamic = Json.parse(data);
                if (onResult != null) onResult(json.response);
            } catch (e:Dynamic) {
                trace("[GameJolt] Failed to parse API JSON response.");
                if (onResult != null) onResult(null);
            }
        };

        http.onError = function(err:String) {
            trace('[GameJolt] Network request failed for ${endpoint}: ${err}');
            if (onResult != null) onResult(null);
        };

        http.request(false);
    }
}