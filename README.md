---

```markdown
# hx-gamejolt

A modern, lightweight, and dependency-free **GameJolt API v1.2** wrapper written in pure **Haxe**. Designed to work seamlessly across Desktop, Mobile, and HTML5 target platforms without requiring heavy external libraries.

---

## Key Features

* **Zero External Dependencies**: Relies purely on native Haxe standard tools (`haxe.Http`, `haxe.crypto.Md5`, and `haxe.Timer`).
* **Complete API Coverage**: Built-in support for User Authentication, Trophies, Leaderboards, Cloud DataStore, and Active Sessions.
* **Automatic Session Keep-Alive**: Includes an auto-ping worker that keeps player sessions active on GameJolt in the background.
* **Strong Type Definitions**: Provides clean autocompletion for trophy, score, and user data models.
* **Cross-Platform**: Compatible with HaxeFlixel, OpenFL, or any standalone Haxe framework.

---

## Installation

Install the library directly from the GitHub repository:

```bash
haxelib git hx-gamejolt [https://github.com/cocoCode17/hx-gamejolt](https://github.com/cocoCode17/hx-gamejolt)

```

Then add the library to your project's `Project.xml`:

```xml
<haxelib name="hx-gamejolt" />

```

---

## Quick Start Guide

### 1. Initializing and Authenticating (`GameJolt.hx`)

Initialize the API with your Game ID and Private Key during startup, then authenticate the user using their username and Game Token.

```haxe
import gamejolt.GameJolt;

class MainState extends flixel.FlxState 
{
    override public function create():Void 
    {
        super.create();

        /** Initialize credentials (found in your GameJolt API settings) **/
        GameJolt.init(1055030, "YOUR_GAME_PRIVATE_KEY");

        /** Authenticate player **/
        GameJolt.login("PlayerUsername", "PlayerGameToken", function(success:Bool) {
            if (success) {
                trace('Successfully authenticated as ${GameJolt.username}');
            } else {
                trace("Authentication failed.");
            }
        });
    }
}

```

---

### 2. Active Sessions & Auto-Ping (`Sessions.hx`)

GameJolt tracks active player counts and play sessions. You can open a session and let the library handle keep-alive pings automatically every 30 seconds:

```haxe
import gamejolt.Sessions;

/** Open session and start auto-pinging in the background **/
Sessions.open(true, function(success:Bool) {
    if (success) trace("Session opened & auto-ping worker started.");
});

/** Update status to idle or active when pausing/resuming gameplay **/
Sessions.ping("idle");

/** Close active session upon game exit **/
Sessions.close();

```

---

### 3. Leaderboards & Scores (`Scores.hx`)

Submit high scores for logged-in players or guests, and fetch rank tables:

```haxe
import gamejolt.Scores;
import gamejolt.Types.GJScore;

/** Submit a score for the logged-in user
Scores.add("100,000 Pts", 100000, 0, "", "Extra Metadata", function(success:Bool) {
    if (success) trace("Score posted!");
});

/** Submit a score for a guest player **/
Scores.add("50,000 Pts", 50000, 0, "GuestPlayerName", "", function(success:Bool) {
    if (success) trace("Guest score posted!");
});

/** Fetch top 10 scores from the primary table **/
Scores.fetch(0, 10, function(scores:Array<GJScore>) {
    for (entry in scores) {
        trace('${entry.user != "" ? entry.user : entry.guest}: ${entry.score}');
    }
});

```

---

### 4. Trophies & Achievements (`Trophies.hx`)

Unlock, remove, or fetch achievements for the active user:

```haxe
import gamejolt.Trophies;
import gamejolt.Types.GJTrophy;

/** Unlock a trophy by ID **/
Trophies.unlock(303858, function(success:Bool) {
    if (success) trace("Trophy unlocked!");
});

/** Fetch all game trophies **/
Trophies.fetch(false, function(trophies:Array<GJTrophy>) {
    for (trophy in trophies) {
        trace('${trophy.title} - Achieved: ${trophy.achieved}');
    }
});

```

---

### 5. Cloud Storage (`DataStore.hx`)

Save and retrieve custom key-value data globally or per-user:

```haxe
import gamejolt.DataStore;

/** Save user settings or save data to the cloud **/
DataStore.set("high_score", "9500", false, function(success:Bool) {
    if (success) trace("Data saved successfully!");
});

/** Retrieve stored data **/
DataStore.get("high_score", false, function(data:String) {
    if (data != null) trace('Loaded stored value: ${data}');
});

```

---

## License

This project is licensed under the MIT License. Feel free to use and modify it in any commercial or non-commercial projects.