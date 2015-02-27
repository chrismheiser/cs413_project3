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
		
		assets.enqueue("assets/road.png");
		assets.enqueue("assets/mountainsFG.png");
		assets.enqueue("assets/mountainsBG.png");
		assets.enqueue("assets/grass.png");
		assets.enqueue("assets/hillsBackground.png");
		assets.enqueue("assets/hillsForeground.png");
		assets.enqueue("assets/forestFloor.png");
		assets.enqueue("assets/desertFloor.png");
		assets.enqueue("assets/desertBG.png");
		assets.enqueue("assets/forestBG.png");
		assets.enqueue("assets/fieldBG.png");
		assets.enqueue("assets/clouds2.png");
		assets.enqueue("assets/titleScreen.png");
		assets.enqueue("assets/forestTrees.png");


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

				// Fade out the plane in loading screen since everything is loaded
				Starling.juggler.tween(startup.loadingPlaneBitmap, 1, {
					transition: Transitions.EASE_OUT,
					delay: 3,
					alpha: 0,
					onComplete: function() {
					startup.removeChild(startup.loadingPlaneBitmap);
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

		var titleScreen = new Image(assets.getTexture("titleScreen"));
		addChild(titleScreen);
		
		// set and display game title
		gameTitleText = installGameText(0,0, "Plain Word Game", "gameFont04", 55);
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
		
		//randomlt start one of the levels
		var rand = Math.floor(Math.random() * 4);
		if (rand == 0){
			startCityLevel();
		} else if (rand == 1){
			startForestLevel();
		}else if (rand == 2){
			startDesertLevel();
		}else{
			startFieldLevel();
		}
		

		// set and add mainMenu button
		mainMenuButton = installMainMenuButton(10 , 10);
		addChild(mainMenuButton);
		
		
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


	function startFieldLevel(){

		//each level has a set of layers that needs to be created before the
		//levelbackground is created
		var layers:Array<BackgroundLayer> = new Array();
		layers.push(new BackgroundLayer(assets.getTexture("fieldBG"), 0, true));
		layers.push(new BackgroundLayer(assets.getTexture("clouds2"), 1, true));
		layers.push(new BackgroundLayer(assets.getTexture("hillsBackground"), 4, false));
		layers.push(new BackgroundLayer(assets.getTexture("hillsForeground"), 6, false));
		layers.push(new BackgroundLayer(assets.getTexture("grass"), 12, false));

		var fieldBG = new LevelBackground(layers);

		addChild(fieldBG);
	

	}

	function startDesertLevel(){

		//each level has a set of layers that needs to be created before the
		//levelbackground is created
		var layers:Array<BackgroundLayer> = new Array();
		layers.push(new BackgroundLayer(assets.getTexture("desertBG"), 0, true));
		layers.push(new BackgroundLayer(assets.getTexture("mountainsBG"), 1, false));
		layers.push(new BackgroundLayer(assets.getTexture("mountainsFG"), 2, false));
		layers.push(new BackgroundLayer(assets.getTexture("desertFloor"), 12, false));

		var desertBG = new LevelBackground(layers);

		addChild(desertBG);
	

	}
	

	function startCityLevel(){

		//each level has a set of layers that needs to be created before the
		//levelbackground is created
		var layers:Array<BackgroundLayer> = new Array();
			layers.push(new BackgroundLayer(assets.getTexture("spaceBG"), 1, true));
			layers.push(new BackgroundLayer(assets.getTexture("city"), 5, false));
			layers.push(new BackgroundLayer(assets.getTexture("road"), 12, false));
		
		var cityBG = new LevelBackground(layers);

		addChild(cityBG);
	}

	function startForestLevel(){

		//each level has a set of layers that needs to be created before the
		//levelbackground is created
		var layers:Array<BackgroundLayer> = new Array();
			layers.push(new BackgroundLayer(assets.getTexture("forestBG"), 0, true));
			layers.push(new BackgroundLayer(assets.getTexture("clouds2"), 1, true));
			layers.push(new BackgroundLayer(assets.getTexture("forestFloor"), 8, false));
			layers.push(new BackgroundLayer(assets.getTexture("forestTrees"), 8, false));
			//layers.push(new BackgroundLayer(assets.getTexture("forestTrees"), 10, false));
			
		
		var cityBG = new LevelBackground(layers);

		addChild(cityBG);
	}
}