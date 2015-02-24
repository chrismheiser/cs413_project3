package com.learn.haxe;

import starling.animation.Tween;
import starling.display.MovieClip;
import starling.textures.Texture;
import starling.display.Sprite;
import starling.utils.AssetManager;
import starling.display.Image;
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

import com.learn.haxe.core.AnswerManager;

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
	
	/** Constructor */
	public function new() {
		super();
	}
	
	/** Function used to load in any assets to be used during the game */
	private function populateAssetManager() {
		assets = new AssetManager();
		assets.enqueue("assets/questions.json");
		
		// game font
		assets.enqueue("assets/font.fnt");
		assets.enqueue("assets/font.png");
		
		// game buttons
		assets.enqueue("assets/startButton.png");
		assets.enqueue("assets/mainMenuButton.png");
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
		// clear the stage
		this.removeChildren();
		
		// set and display game title
		gameTitleText = installGameText(0,0, "Hellow :)");
		addChild(gameTitleText);
		
		// set and add start game button
		startButton = installStartGameButton(460, 590);
		addChild(startButton);
		
		return;
	}
	
	/** Function to be called when we are ready to start the game */
	private function startGame() {
		// clear the stage
		this.removeChildren();
						
		// set and add mainMenu button
		mainMenuButton = installMainMenuButton(570 , 600);
		addChild(mainMenuButton);
		
		var answerManager = new AnswerManager( assets.getObject("questions") );
		answerManager.shuffleQuestions();
		answerManager.y = 100;
		addChild(answerManager);
		
		return;
	}
	
	/** Called when the game is over */
	private function triggerGameOver() {
	}
	
	/** Restart the game */
	private function restartGame(){
		this.removeChildren();
		startGame();
	}
	
	/** Used to keep track of when a key is unpressed */
	private function keyUp(event:KeyboardEvent):Void{
		var keyCode = event.keyCode;
	}
	
	/** Used to keep track when a key is pressed */
	private function keyDown(event:KeyboardEvent){
		var keyCode = event.keyCode;
	}

	/** Used to keep track of key clicks */
	private function onClick( event:TouchEvent) {
	}

	private function createButtons(){}
	
	private function installGameText(x:Int, y:Int, myText:String) {
		// local var
		var gameTitle:TextField;
		
		// display player's current score
		gameTitle = new TextField(globalStage.stageWidth, 100, myText);
		gameTitle.fontSize = 35;
		//gameTitle.bold = true;
		//gameTitle.color = 0x505050;
		gameTitle.x = x;
		gameTitle.y = y;
		gameTitle.fontName = "font";
		
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

}