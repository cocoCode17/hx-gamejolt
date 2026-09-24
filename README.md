# hx-gamejolt

A lightweight, dependency-free GameJolt API v1.2 wrapper for **Haxe** and **HaxeFlixel**. Built as a modern alternative to `flixel-addons` with clean HTTP requests and simple callback methods.

## Installation

You can install this library directly from GitHub:

```bash
haxelib git hx-gamejolt https://github.com/cocoCode17/hx-gamejolt

```

Then add it to your project's `Project.xml`:

```xml
<haxelib name="hx-gamejolt" />

```

## Quick Start

### 1. Initialization & Login

Initialize the API with your Game ID and Private Key, then authenticate the player:

```haxe
import gamejolt.GameJolt;
import gamejolt.Trophies;

class MainState extends flixel.FlxState 
{
    override public function create():Void 
    {
        super.create();

        /** Initialize credentials **/
        GameJolt.init(123456, "YOUR_PRIVATE_KEY_HERE");

        /** Authenticate user **/
        GameJolt.login("Username", "UserToken", function(success:Bool) {
            if (success) {
                trace("Successfully logged in to GameJolt!");
            } else {
                trace("Login failed.");
            }
        });
    }
}

```

### 2. Unlocking Trophies

Unlock trophies easily by passing the Trophy ID:

```haxe
Trophies.unlock(98765, function(success:Bool) {
    if (success) {
        trace("Trophy unlocked!");
    }
});

```

### 3. Fetching Trophies

Retrieve trophy data for the authenticated user:

```haxe
Trophies.fetch(false, function(trophies:Array<Dynamic>) {
    for (trophy in trophies) {
        trace('Trophy: ${trophy.title} - Achieved: ${trophy.achieved}');
    }
});

```

## License

MIT License. Feel free to use and modify for any Haxe project.