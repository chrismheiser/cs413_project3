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
import starling.text.TextFieldButton;

import com.learn.haxe.core.AnswerManager;

class GameDriver extends Sprite {
	// Global assets manager
	public static var assets:AssetManager;

	// Keep track of the stage
	static var globalStage:Stage = null;

	var buttons:Array<Button> = [];
	var question:Int = 0;
	
	/** Constructor */
	public function new() {
		super();
	}
	
	/** Function used to load in any assets to be used during the game */
	private function populateAssetManager() {
		assets = new AssetManager();
		assets.enqueue("assets/questions.json");
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
		startGame();
	}
	
	/** Function to be called when we are ready to start the game */
	private function startGame() {
		this.removeChildren();
		var answerManager = new AnswerManager( assets.getObject("questions") );
		//answerManager.debugPrint();

		var tfButton:TextFieldButton = new TextFieldButton(100, 20, "Hello world!", "Verdana", 12, 0x0, 0xFF0000);
			tfButton.x = 500;
			tfButton.y = 500;
			tfButton.onClick = function( button:TextFieldButton ){
				trace(button.text);
			};
		addChild(tfButton);

	}

	private function createQuestion(a: AnswerManager, q:Int){
		var qstn = a.getQuestion(q);
		var text = new  TextField(stage.stageWidth, stage.stageHeight, qstn);
		text.x = 300;
		text.y = 200;
		text.fontSize = 24;
		addChild(text);
		
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

}