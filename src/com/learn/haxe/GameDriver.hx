package com.learn.haxe;

import starling.animation.Tween;
import starling.animation.Transitions;
import starling.display.MovieClip;
import starling.textures.Texture;
import starling.display.Sprite;
import starling.utils.AssetManager;
import starling.display.Image;
import starling.display.Quad;
import starling.core.Starling;
import starling.animation.Transitions;
import starling.events.KeyboardEvent;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.display.Button;
import starling.events.Event;
import starling.textures.Texture;
import starling.events.EnterFrameEvent;
import starling.display.Stage;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import starling.text.TextField;
import starling.text.InputTextField;
import starling.text.TextFieldButton;

import com.learn.haxe.core.*;

class GameDriver extends Sprite {
	// Global assets manager
	public static var assets:AssetManager;

	// Keep track of the stage
	static var globalStage:Stage = null;
	
	// Global Game vars
	// text vars
	public var gameTitleText:TextField;
	// interactive buttons
	public var startButton:Button;
	public var mainMenuButton:Button;

	//Plane variables
	public var plane:Image;
	var pTween:Tween;


	// Sound variables
		var musicChannel:SoundChannel;	
		var transform:SoundTransform;
		
	/** Constructor */
	public function new() {
		super();
	}
	
	/** Function used to load in any assets to be used during the game */
	private function populateAssetManager() {
		assets = new AssetManager();
		assets.enqueue("assets/questions.json");
		
		// Dont use textures until the game is finished!
		//assets.enqueue("assets/textures.png");
		//assets.enqueue("assets/textures.xml");

		assets.enqueue("assets/spaceBG.png");
		assets.enqueue("assets/city.png");
		assets.enqueue("assets/plane.png");
		assets.enqueue("assets/healthBar.png");
	
		
		// game font
		assets.enqueue("assets/gameFont01.fnt");
		assets.enqueue("assets/gameFont01.png");
		assets.enqueue("assets/gameFont02.fnt");
		assets.enqueue("assets/gameFont02.png");
		assets.enqueue("assets/gameFont03.fnt");
		assets.enqueue("assets/gameFont03.png");
		assets.enqueue("assets/gameFont04.fnt");
		assets.enqueue("assets/gameFont04.png");
		
		// game buttons
		assets.enqueue("assets/startButton.png");
		assets.enqueue("assets/mainMenuButton.png");
		
		// sounds 
		assets.enqueue("assets/game_music.mp3");
		assets.enqueue("assets/click.mp3");
		assets.enqueue("assets/right_answer.mp3");
		assets.enqueue("assets/wrong_answer.mp3");
	}

	/** Function called from the initial driver, sets up the root class */
	public function start(startup:GameLoader, startupStage:Stage) {
		
		// Prep all asset paths
		populateAssetManager();
		
		// Set the global stage to the starling stage
		globalStage = startupStage;
		
		// Start loading in the assets
		assets.loadQueue(function onProgress(ratio:Int) {
			if (ratio == 1) {
			
				//Start the game music
				//musicChannel = assets.playSound("game_music");
				//musicChannel.addEventListener(flash.events.Event.SOUND_COMPLETE, soundComplete);
				//transform = new SoundTransform(0.3, 0);
				//musicChannel.soundTransform = transform;
				
				startScreen();
				
				
				
				// Fade out the loading screen since everything is loaded
				Starling.juggler.tween(startup.loadingBitmap, 1, {
					transition: Transitions.EASE_OUT,
					delay: 1,
					alpha: 0,
					onComplete: function() {
					startup.removeChild(startup.loadingBitmap);
				}});
			}
		});
	}
	
	/** Do stuff with the menu screen */
	private function startScreen() {
		// click sound
		assets.playSound("click");
		
		// clear the stage
		this.removeChildren();
		
		// set and display game title
		gameTitleText = installGameText(0,0, "What is the word?", "gameFont04", 55);
		addChild(gameTitleText);
		
		// set and add start game button
		startButton = installStartGameButton(460, 590);
		addChild(startButton);
		
		return;
	}
	
	/** Function to be called when we are ready to start the game */
	private function startGame() {
		// click sound
		assets.playSound("click");
		
		// clear the stage
		this.removeChildren();
						
		// set and add mainMenu button
		mainMenuButton = installMainMenuButton(570 , 600);
		addChild(mainMenuButton);
		
		startCityLevel();
		var answerManager = new InteractiveAnswerManager( assets.getTexture("healthBar"), assets.getTexture("plane"), assets.getObject("questions"), 
			assets.getSound("right_answer"), assets.getSound("wrong_answer") );
		
		answerManager.textColor = 0xFFFFFF;
		answerManager.gameOver = triggerGameOver;
		answerManager.shuffleQuestions();
		addChild(answerManager);		
		return;
	}
	
	/** Called when the game is over */
	private function triggerGameOver(wonGame:Bool) {
		trace(wonGame);
	}
	
	/** Restart the game */
	private function restartGame(){
		this.removeChildren();
		startGame();
	}
	
	private function createButtons(){}
	
	private function installGameText(x:Int, y:Int, myText:String, myFont:String, myFontsize:Int) {
		// local var
		var gameTitle:TextField;
		
		// display player's current score
		gameTitle = new TextField(globalStage.stageWidth, 100, myText);
		gameTitle.fontName = myFont;
		gameTitle.fontSize = myFontsize;
		//gameTitle.bold = true;
		gameTitle.color = 0xffffff;
		gameTitle.x = x;
		gameTitle.y = y;
		
		return gameTitle;
	}
	
	/** Install game tutorial button at (x,y) coordinates */
	function installStartGameButton(x:Int, y:Int) {
		var sgButton:Button;
						
		sgButton = new Button(GameDriver.assets.getTexture("startButton"));
		sgButton.x = x;
		sgButton.y = y;
		
		// On button press, display game screen
		sgButton.addEventListener(Event.TRIGGERED, function() {
			// start the game
			startGame();
		});
		
		// Return start game button
		return sgButton;
	}
	
	/** Install main menu button at (x,y) coordinates */
	function installMainMenuButton(x:Int, y:Int) {		
		var mmButton:Button;
		
		// Make main menu button and set location
		mmButton = new Button(GameDriver.assets.getTexture("mainMenuButton"));
		mmButton.x = x;
		mmButton.y = y;

		mmButton.addEventListener(Event.TRIGGERED, function(){
			startScreen();
		});
		
		// Return main menu button
		return mmButton;
	}

	/** Start the music after it's finished playing */
	function soundComplete(e:flash.events.Event)
	{
		//musicChannel = assets.playSound("game_music");
		//musicChannel.addEventListener(flash.events.Event.SOUND_COMPLETE, soundComplete);
		//musicChannel.soundTransform = transform;
	}

/*
	function startFieldLevel(){

		//each level has a set of layers that needs to be created before the
		//levelbackground is created
		var layers:Array<BackgroundLayer> = new Array();
		layers.push(new BackgroundLayer(assets.getTexture("clouds2"), 1, true));
		layers.push(new BackgroundLayer(assets.getTexture("fieldBG"), 0, true));
		layers.push(new BackgroundLayer(assets.getTexture("hillsBackground"), 5, false));
		layers.push(new BackgroundLayer(assets.getTexture("hillsForeground"), 10, false));
		layers.push(new BackgroundLayer(assets.getTexture("grass"), 12, false));

		var fieldBG = new LevelBackground(layers);

		addChild(fieldBG);
	

	}
	*/

	function startCityLevel(){

		//each level has a set of layers that needs to be created before the
		//levelbackground is created
		var layers:Array<BackgroundLayer> = new Array();
			layers.push(new BackgroundLayer(assets.getTexture("spaceBG"), .1, true));
			layers.push(new BackgroundLayer(assets.getTexture("city"), 5, true));
		
		var cityBG = new LevelBackground(layers);
			//cityBG.addChild(new Quad(stage.stageWidth, stage.stageHeight, 0x111111));

		addChild(cityBG);
	}
}