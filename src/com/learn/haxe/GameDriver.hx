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
	
	// In game text objects
	public var gameTitleText:TextField;
	public var loseText:TextField;
	public var winText:TextField;
	
	// Interactive Buttons
	var startButton:Button;
	var mainMenuButton:Button;
	var creditsButton:Button;
	var tutorialButton:Button;
	
	// Menu Screens
	var creditsScreen:Image;
	var tutorialScreen:Image;
	
	//Plane variables
	var plane:Image;
	var pTween:Tween;

	// Sound variables
	var musicChannel:SoundChannel;	
	var transform:SoundTransform;
	
	// Game Class
	var answerManager:InteractiveAnswerManager = null;
	
	/** Constructor */
	public function new() {
		super();
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
				startScreen();

				// Fade out the plane in loading screen since everything is loaded
				Starling.juggler.tween(startup.loadingPlaneBitmap, 1, {
					transition: Transitions.EASE_OUT,
					x: 1080,
					delay: 2,
					alpha: 0,
					onComplete: function() {
						startup.loadingPlaneBitmap.x = 25;
					}	
				});
				
				// Fade out the loading screen since everything is loaded
				Starling.juggler.tween(startup.loadingBitmap, 1, {
					transition: Transitions.EASE_OUT,
					delay: 3,
					alpha: 0,
					onComplete: function() {
					startup.removeChild(startup.loadingBitmap);
				}});
			}
		});
	}
	
	/** Do stuff with the menu screen */
	private function startScreen() {
		// Click sound
		assets.playSound("click");
		
		// Clear the stage
		this.removeChildren();
		
		// Start the background screen
		startForestLevel();
		
		var alphaQuad = new Quad(stage.stageWidth, stage.stageHeight);
			alphaQuad.color = 0x888899;
			alphaQuad.alpha = 0.1;
		
		addChild(alphaQuad);
		
		// Set and display game title
		gameTitleText = installGameText(0,0, "'Plain' Word Game", "gameFont04", 55);
		addChild(gameTitleText);
		
		// Set and add start game button
		startButton = installStartGameButton(350, 550);
		addChild(startButton);
		
		tutorialButton = installTutorialButton(525, 550);
		addChild(tutorialButton);
		
		creditsButton = installCreditsButton(700, 550);
		addChild(creditsButton);
	}
	
	/** Function to be called when we are ready to start the game */
	private function startGame() {
		// Click sound
		assets.playSound("click");
		
		// Clear the stage
		this.removeChildren();
		
		//Randomly start one of the levels
		var rand = Math.floor(Math.random() * 4);
		if (rand == 0){
			startCityLevel();
		} else if (rand == 1){
			startForestLevel();
		} else if (rand == 2){
			startDesertLevel();
		} else {
			startFieldLevel();
		}
		
		// Set and add mainMenu button
		mainMenuButton = installMainMenuButton(stage.stageWidth-70 , 10);
		mainMenuButton.width = mainMenuButton.height = 60;
		addChild(mainMenuButton);
		
		answerManager = new InteractiveAnswerManager( assets.getTexture("healthBar"), 
			assets.getTexture("plane")		, assets.getObject("questions"), 
			assets.getSound("right_answer") , assets.getSound("wrong_answer") );
		
		answerManager.textColor = 0xFFFFFF;
		answerManager.gameOver = triggerGameOver;
		answerManager.shuffleQuestions();
		addChild(answerManager);		
	}
	
	/** Called when the game is over */
	private function triggerGameOver(winGame:Bool) {
		this.removeChildren();
		restartGame();
		answerManager.paused = true;
		
		var displayText:TextField = null;
		
		if (!winGame){
			displayText = installGameText(0, 325, "You lose!", "gameFont01", 65);	
		} else {
			displayText = installGameText(0,325, "You Win!", "gameFont04", 65);
		}
		
		var container = new Sprite();
		var bg = new Image(assets.getTexture("titleScreen"));
		
		container.addChild(bg);
		container.addChild(displayText);
		addChild(container);
		
		Starling.juggler.tween(container, 2, {
			transition: Transitions.EASE_OUT,
			delay: 1,
			alpha: 0,
			onComplete: function(){
				answerManager.paused = false;
				container.removeFromParent(true);
			}
		});
	}

	/** Display the rules menu */
	private function viewTutorial() {
		tutorialScreen = new Image(GameDriver.assets.getTexture("tutorialScreen"));
		addChild(tutorialScreen);
	
		// Set and add mainMenu button
		mainMenuButton = installMainMenuButton(525, 550);
		addChild(mainMenuButton);
		return;
	}
	
	/** Function to be called when looking at the credits menu*/
	private function viewCredits() {
		creditsScreen = new Image(GameDriver.assets.getTexture("creditsScreen"));
		addChild(creditsScreen);
	
		// Set and add mainMenu button
		mainMenuButton = installMainMenuButton(525, 550);
		addChild(mainMenuButton);	
		return;
	}
	
	/** Restart the game */
	private function restartGame(){
		this.removeChildren();
		startGame();
	}
	
	private function installGameText(x:Int, y:Int, myText:String, myFont:String, myFontsize:Int) {
		var gameTitle:TextField;
		
		gameTitle = new TextField(globalStage.stageWidth, 100, myText);
		gameTitle.fontName = myFont;
		gameTitle.fontSize = myFontsize;
		gameTitle.color = 0xffffff;
		gameTitle.x = x;
		gameTitle.y = y;
		
		return gameTitle;
	}
	
	/** Install start game button at (x,y) coordinates */
	function installStartGameButton(x:Int, y:Int) {
		var sgButton:Button;
						
		sgButton = new Button(GameDriver.assets.getTexture("startButton"));
		sgButton.x = x;
		sgButton.y = y;
		
		// On button press, display game screen
		sgButton.addEventListener(Event.TRIGGERED, startGame);
		
		// Return start game button
		return sgButton;
	}
	
	/** Install game tutorial button at (x,y) coordinates */
	function installTutorialButton(x:Int, y:Int) {
		var tButton:Button;
						
		tButton = new Button(GameDriver.assets.getTexture("tutorialButton"));
		tButton.x = x;
		tButton.y = y;
		
		// On button press, display tutorial
		tButton.addEventListener(Event.TRIGGERED, viewTutorial);
		
		// Return tutorial button
		return tButton;
	}
	
	
	/** Install game tutorial button at (x,y) coordinates */
	function installCreditsButton(x:Int, y:Int) {
		var cButton:Button;
						
		cButton = new Button(GameDriver.assets.getTexture("creditsButton"));
		cButton.x = x;
		cButton.y = y;
		
		// On button press, display tutorial
		cButton.addEventListener(Event.TRIGGERED, viewCredits);
		
		// Return tutorial button
		return cButton;
	}
	
	/** Install main menu button at (x,y) coordinates */
	function installMainMenuButton(x:Int, y:Int) {		
		var mmButton:Button;
		
		// Make main menu button and set location
		mmButton = new Button(GameDriver.assets.getTexture("mainMenuButton"));
		mmButton.x = x;
		mmButton.y = y;
	
		// On button press, display the main menu
		mmButton.addEventListener(Event.TRIGGERED, startScreen);
		
		// Return main menu button
		return mmButton;
	}

	function startFieldLevel(){
		var layers:Array<BackgroundLayer> = new Array();
		layers.push(new BackgroundLayer(assets.getTexture("fieldBG"), 0, true));
		layers.push(new BackgroundLayer(assets.getTexture("clouds2"), 0.5, true));
		layers.push(new BackgroundLayer(assets.getTexture("hillsBackground"), 2, false));
		layers.push(new BackgroundLayer(assets.getTexture("hillsForeground"), 3, false));
		layers.push(new BackgroundLayer(assets.getTexture("grass"), 5, false));

		var fieldBG = new LevelBackground(layers);
		addChild(fieldBG);
	}

	function startDesertLevel(){
		var layers:Array<BackgroundLayer> = new Array();
		layers.push(new BackgroundLayer(assets.getTexture("desertBG"), 0, true));
		layers.push(new BackgroundLayer(assets.getTexture("mountainsBG"), 0.5, false));
		layers.push(new BackgroundLayer(assets.getTexture("mountainsFG"), 1, false));
		layers.push(new BackgroundLayer(assets.getTexture("desertFloor"), 0.5, false));

		var desertBG = new LevelBackground(layers);
		addChild(desertBG);
	}
	

	function startCityLevel(){
		var layers:Array<BackgroundLayer> = new Array();
			layers.push(new BackgroundLayer(assets.getTexture("spaceBG"), 0.5, true));
			layers.push(new BackgroundLayer(assets.getTexture("city"), 2.5, false));
			layers.push(new BackgroundLayer(assets.getTexture("road"), 5, false));
		
		var cityBG = new LevelBackground(layers);
		addChild(cityBG);
	}

	function startForestLevel(){
		var layers:Array<BackgroundLayer> = new Array();
			layers.push(new BackgroundLayer(assets.getTexture("forestBG"), 0, true));
			layers.push(new BackgroundLayer(assets.getTexture("mountHood"), .2, true));
			layers.push(new BackgroundLayer(assets.getTexture("clouds2"), 0.5, true));
			layers.push(new BackgroundLayer(assets.getTexture("forestFloor"), 4, false));
			layers.push(new BackgroundLayer(assets.getTexture("forestTrees"), 4, false));
			
		
		var cityBG = new LevelBackground(layers);
		addChild(cityBG);
	}
	
	/** Function used to load in any assets to be used during the game */
	private function populateAssetManager() {
		assets = new AssetManager();
		assets.enqueue("assets/questions.json");
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
		assets.enqueue("assets/tutorialScreen.png");
		assets.enqueue("assets/creditsScreen.png");
		assets.enqueue("assets/mountHood.png");
		assets.enqueue("assets/gameFont01.fnt");
		assets.enqueue("assets/gameFont01.png");
		assets.enqueue("assets/gameFont02.fnt");
		assets.enqueue("assets/gameFont02.png");
		assets.enqueue("assets/gameFont03.fnt");
		assets.enqueue("assets/gameFont03.png");
		assets.enqueue("assets/gameFont04.fnt");
		assets.enqueue("assets/gameFont04.png");
		assets.enqueue("assets/gameFont05.fnt");
		assets.enqueue("assets/gameFont05.png");
		assets.enqueue("assets/startButton.png");
		assets.enqueue("assets/mainMenuButton.png");
		assets.enqueue("assets/creditsButton.png");
		assets.enqueue("assets/tutorialButton.png");
		assets.enqueue("assets/game_music.mp3");
		assets.enqueue("assets/click.mp3");
		assets.enqueue("assets/right_answer.mp3");
		assets.enqueue("assets/wrong_answer.mp3");
	}
}