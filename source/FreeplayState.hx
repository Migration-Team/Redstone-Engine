package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<String> = [];
	var colorList:Array<FlxColor> = [];
	var iconList:Array<String> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpAccuracy:Float = 0;
	var intendedScore:Int = 0;
	var intendedAccuracy:Float = 0;
	var isDebug:Bool = false;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	var defaultCamZoom:Float = 1;
	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var json:Dynamic; //too lazy to check what the class is for a json, let the game figure it out lmao

	override function create()
	{
		/* 
			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic('assets/music/freakyMenu' + TitleState.soundExt);
			}
		 */
		#if debug
		isDebug = true;
		#end
		//append the text files as long as they exist
		var songStrings:Array<String> = CoolUtil.coolTextFile('assets/data/freeplaySonglist.txt');
		//songStrings.remove('');
		for (i in 0...songStrings.length)
		{
			var songShit = songStrings[i].split(',');
			songShit.remove(' ');
			var songName = songShit[0];
			addSong(songName, songShit[1], FlxColor.fromString(songShit[2]), Std.parseInt(songShit[3]));
		}
	
		//HARDCODED SONG TEMPLATE: addSong('title', 'icon', color, week);

		trace(songs);
		trace(colorList);
		trace(iconList);

		songs.remove(''); //if empty strings got in there, just clear them out, they probably came from the text file
		// LOAD MUSIC

		// LOAD CHARACTERS

		bg = new FlxSprite().loadGraphic(UILoader.loadImageDirect('menuDesat'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(iconList[i]);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.56, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.6), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic('assets/music/title' + TitleState.soundExt, 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		super.create();
	}
	override function beatHit()
	{
		super.beatHit();
		FlxG.camera.zoom += 0.015; // mid fight masses style zooming per song bpm
	}
	override function newMeasure()
	{
		super.newMeasure();
		FlxG.camera.zoom += 0.03;
		if (json.notes[Math.floor(curStep / 16)] != null)
		{
			if (json.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(json.notes[Math.floor(curStep / 16)].bpm);
			}
		}
	}
	function addSong(song:String, icon:String = 'blank', color:FlxColor = 0xFF9271FD, week:Int = 0)
	{
		if (StoryMenuState.weekUnlocked[week] || isDebug) {
			songs.push(song);
			iconList.push(icon);
			colorList.push(color);
		}
	}
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));
		lerpAccuracy = Math.floor(FlxMath.lerp(lerpAccuracy, intendedAccuracy, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		if (Math.abs(lerpAccuracy - intendedAccuracy) <= 10)
			lerpAccuracy = intendedAccuracy;

		scoreText.text = 'PERSONAL BEST:${lerpScore}, ${lerpAccuracy}%';

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			FlxG.sound.playMusic('assets/music/freakyMenu' + TitleState.soundExt, 4);
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			if(songs[curSelected].toLowerCase() == 'test')
				curDifficulty = 1;

			var poop:String = Highscore.formatSong(songs[curSelected].toLowerCase(), curDifficulty);

			trace(poop);
			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
			FlxG.switchState(new PlayState());
			if (FlxG.sound.music != null) {
				FlxG.sound.music.stop();
			}
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected], curDifficulty);
		intendedAccuracy = Highscore.getAccuracy(songs[curSelected], curDifficulty);
		#end

		switch (curDifficulty)
		{
			case 0:
				diffText.text = "EASY";
			case 1:
				diffText.text = 'NORMAL';
			case 2:
				diffText.text = "HARD";
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt, 0.4);
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected], curDifficulty);
		intendedAccuracy = Highscore.getAccuracy(songs[curSelected], curDifficulty);
		// lerpScore = 0;
		#end

		json = Song.loadFromJson(songs[curSelected].toLowerCase(), songs[curSelected].toLowerCase());
		bg.color = colorList[curSelected];

		FlxG.sound.playMusic('assets/songs/' + songs[curSelected].toLowerCase() + "/Inst" + TitleState.soundExt, 0);

		if(json != null)
			Conductor.changeBPM(json.bpm);
		else
			Conductor.changeBPM(0);
		
		var bullShit:Int = 0;
		
		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;
		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}