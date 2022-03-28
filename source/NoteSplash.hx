package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
class NoteSplash extends FlxSprite {
    var isFirstSplash:Bool = true;
    //You do not want to know how long I was going through Week 7's code to find all this.
    //I used a JS beautifier and a lot of CTRL-F to get everything I needed.
    //Then I took that minified JavaScript code from Funkin.js and turned it back into Haxe code.
    //That was fun.

    //I got so desprate I once even made an attempt to code it in myself.
    //That went well.
    public function new(xPos:Float,yPos:Float,?splashType:Int) {
        if (splashType == null) splashType = 0;
        super(xPos, yPos);
        if(PlayState.curStage == ('school') || PlayState.curStage == ('schoolEvil')) {
            frames = FlxAtlasFrames.fromSparrow('assets/images/weeb/pixelUI/noteSplashes-pixel.png', 'assets/images/noteSplashes-pixel.xml');
        } else {
            frames = FlxAtlasFrames.fromSparrow('assets/images/noteSplashes.png', 'assets/images/noteSplashes.xml');
        }
        animation.addByPrefix("splash0-0", "note impact 1 purple", 24, false);
        animation.addByPrefix("splash1-0", "note impact 1  blue", 24, false);
		animation.addByPrefix("splash2-0", "note impact 1 green", 24, false);
		animation.addByPrefix("splash3-0", "note impact 1 red", 24, false);

		animation.addByPrefix("splash0-1", "note impact 2 purple", 24, false);
		animation.addByPrefix("splash1-1", "note impact 2 blue", 24, false);
		animation.addByPrefix("splash2-1", "note impact 2 green", 24, false);
		animation.addByPrefix("splash3-1", "note impact 2 red", 24, false);
        setupNoteSplash(xPos, xPos, splashType);
    }
    public function setupNoteSplash(xPos:Float, yPos:Float, ?splashType:Int) {
        if (splashType == null) splashType = 0;
        setPosition(xPos, yPos);
        if(isFirstSplash)
            alpha = 0;
        else
            alpha = 0.6;
        antialiasing = true;
        animation.play("splash" + splashType + "-" + FlxG.random.int(0,1), true);
		animation.curAnim.frameRate = FlxG.random.int(22, 26);
        updateHitbox();
        offset.set(0.3 * width, 0.3 * height);
        isFirstSplash = false;
    }
    override public function update(elapsed) {
        if (animation.curAnim.finished) {
            kill();
        }
        super.update(elapsed);
    }
}