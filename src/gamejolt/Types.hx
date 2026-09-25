package gamejolt;

/**
 * Data structures used across the hx-gamejolt library.
 * These typedefs make it easy to work with JSON responses from GameJolt.
 */

typedef GJUser = {
    var id:Int;
    var type:String; // "User", "Developer", "Moderator", etc.
    var username:String;
    var avatar_url:String;
    var signed_up:String;
    var last_logged_in:String;
    var status:String; // "Active" or "Banned"
    var status_message:String;
}

typedef GJTrophy = {
    var id:Int;
    var title:String;
    var description:String;
    var difficulty:String; // "Bronze", "Silver", "Gold", or "Platinum"
    var image_url:String;
    var achieved:Dynamic; // Bool or String depending on the API call
}

typedef GJScore = {
    var score:String;
    var sort:Int;
    var extra_data:String;
    var user:String;
    var user_id:Int;
    var guest:String;
    var stored:String;
}

typedef GJTable = {
    var id:Int;
    var name:String;
    var description:String;
    var primary:Bool;
}