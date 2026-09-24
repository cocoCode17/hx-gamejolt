package gamejolt;

import haxe.Http;
import haxe.Json;
import haxe.io.Bytes;

class GameJolt 
{
    public static var gameId:Int = 0;
    public static var privateKey:String = "";
    public static var username:String = "";
    public static var userToken:String = "";
    public static var initialized(default, null):Bool = false;

    // GameJolt official API v1.2 endpoint
    private static inline var API_URL:String = "https://api.gamejolt.com/api/game/v1_2/";

    /**
     * Sets up your game credentials. Call this once when your game boots up!
     */
    public static function init(id:Int, key:String):Void 
    {
        gameId = id;
        privateKey = key;
    }

    /**
     * Tries to log in the player using their GameJolt username and user token.
     */
    public static function login(user:String, token:String, onResult:Bool->Void):Void 
    {
        username = user.toLowerCase();
        userToken = token.toLowerCase();

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
     * Clears local user data and resets authentication status.
     */
    public static function logout():Void 
    {
        username = "";
        userToken = "";
        initialized = false;
    }

    /**
     * Sends an authenticated GET request to GameJolt with a custom MD5 signature.
     */
    public static function request(endpoint:String, params:Map<String, String>, onResult:Dynamic->Void):Void 
    {
        if (gameId == 0 || privateKey == "") {
            trace("[GameJolt] Heads up: Call GameJolt.init() before making API requests.");
            if (onResult != null) onResult(null);
            return;
        }

        var queryString = 'game_id=${gameId}';
        for (key in params.keys()) {
            queryString += '&${key}=${params.get(key)}';
        }

        // GameJolt expects the signature to be an MD5 hash of (URL + privateKey)
        var fullQueryToSign = '${API_URL}${endpoint}/?${queryString}${privateKey}';
        var signature = md5(fullQueryToSign);
        var finalUrl = '${API_URL}${endpoint}/?${queryString}&signature=${signature}';

        var http = new Http(finalUrl);
        http.onData = function(data:String) {
            try {
                var json:Dynamic = Json.parse(data);
                if (onResult != null) onResult(json.response);
            } catch (e:Dynamic) {
                trace("[GameJolt] Failed to parse API response JSON.");
                if (onResult != null) onResult(null);
            }
        };

        http.onError = function(err:String) {
            trace('[GameJolt] Network issue on ${endpoint}: ${err}');
            if (onResult != null) onResult(null);
        };

        http.request(false);
    }

    // =========================================================================
    // Native MD5 Hashing (Keeps the library lightweight & dependency-free)
    // =========================================================================
    private static function md5(s:String):String 
    {
        var bytes = Bytes.ofString(s);
        var l = bytes.length;
        var oldL = l;
        l += 9;
        l += 64 - (l % 64);

        var b = Bytes.alloc(l);
        b.blit(0, bytes, 0, oldL);
        b.set(oldL, 0x80);

        var words = new Array<Int>();
        for (i in 0...Std.int(l / 4)) {
            words.push(b.get(i * 4) | (b.get(i * 4 + 1) << 8) | (b.get(i * 4 + 2) << 16) | (b.get(i * 4 + 3) << 24));
        }

        words[Std.int(((l - 64) >> 2) + 14)] = oldL * 8;

        var a = 0x67452301, bb = 0xefcdab89, c = 0x98badcfe, d = 0x10325476;
        var s1 = [7, 12, 17, 22], s2 = [5, 9, 14, 20], s3 = [4, 11, 16, 23], s4 = [6, 10, 15, 21];

        var i = 0;
        while (i < words.length) {
            var aa = a, ab = bb, ac = c, ad = d;

            for (j in 0...64) {
                var f = 0, g = 0, shift = 0;
                if (j < 16) {
                    f = (bb & c) | ((~bb) & d);
                    g = j;
                    shift = s1[j % 4];
                } else if (j < 32) {
                    f = (d & bb) | ((~d) & c);
                    g = (5 * j + 1) % 16;
                    shift = s2[j % 4];
                } else if (j < 48) {
                    f = bb ^ c ^ d;
                    g = (3 * j + 5) % 16;
                    shift = s3[j % 4];
                } else {
                    f = c ^ (bb | (~d));
                    g = (7 * j) % 16;
                    shift = s4[j % 4];
                }
                var k = words[i + g];
                var constVal = Std.int(Math.floor(Math.abs(Math.sin(j + 1)) * 4294967296.0));
                
                var temp = d;
                d = c;
                c = bb;
                var sum = a + f + k + constVal;
                bb = bb + ((sum << shift) | (sum >>> (32 - shift)));
                a = temp;
            }

            a += aa; bb += ab; c += ac; d += ad;
            i += 16;
        }

        return toHex(a) + toHex(bb) + toHex(c) + toHex(d);
    }

    private static function toHex(n:Int):String 
    {
        var s = "";
        var hexChars = "0123456789abcdef";
        for (i in 0...4) {
            var byte = (n >> (i * 8)) & 0xFF;
            s += hexChars.charAt(byte >> 4) + hexChars.charAt(byte & 0x0F);
        }
        return s;
    }
}