package com.learn.haxe.core;

import starling.textures.Texture;
import starling.display.Quad;

import starling.display.Sprite;
import starling.display.Image;
import starling.text.TextField;
import starling.text.TextFieldButton;
import starling.text.TextFieldAutoSize;
import starling.events.Event;
import starling.events.EnterFrameEvent;
import starling.events.KeyboardEvent;
import starling.animation.Transitions;
import starling.core.Starling;


import haxe.Timer;
import flash.media.Sound;

class InteractiveAnswerManager extends Sprite{
	// Numerical key mappings to different directions
	public var K_UP : Int	 = 87;
	public var K_LEFT : Int	 = 65;
	public var K_DOWN : Int	 = 83;
	public var K_RIGHT : Int = 68;
	
	// Map to contain whether or not a key is pressed at any moment
	private var keyMap : Map<Int, Bool> = new Map<Int, Bool>();
	
	// Handling for the correct answers
	var answerObject:Dynamic;
	var questionIndex = -1;
	
	// Sounds
	var rightAnsSound : Sound;
	var wrongAnsSound : Sound;
	
	// Plane acceleration and velocities
	var vx:Float = 0;
	var vy:Float = 0;
	var ay:Float = 0;
	var gravity:Float = 0.1;
	
	// Text field answer list
	var answerList:List<Sprite> = new List<Sprite>();
	
	// Display assets
	var plane:Image;
	var healthBar:HealthBar;
	var questionText:Sprite = null;
	
	// Callback when the game is over
	public var gameOver:Bool->Void = null;
	public var textColor:UInt = 0x000000;
	
	// Timer to spawn the objects
	var spawner:Timer = null;
	public var paused:Bool = false;
	
	function new( healthBarTexture:Texture, planeTexture:Texture, answerObject:Dynamic, rightAnswerSound:Sound, wrongAnswerSound:Sound ){
		super();
		this.answerObject = answerObject;
		this.addEventListener(Event.ADDED_TO_STAGE, function(){
			healthBar = new HealthBar(400,25,healthBarTexture);
			healthBar.defaultColor = healthBar.color;
			healthBar.x = this.stage.stageWidth/2 - healthBar.maxWidth/2;
			healthBar.y = 25;
			
			var tHealthbar = new Image(healthBarTexture);
				tHealthbar.width = healthBar.maxWidth;
				tHealthbar.height = healthBar.height;
				tHealthbar.x = healthBar.x;
				tHealthbar.y = healthBar.y;
				tHealthbar.alpha = 0.2;
				
			addChild(tHealthbar);
			addChild(healthBar);
			
			
			displayNextQuestion();
			this.addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			spawner = new Timer(500);
			spawner.run = spawnAnswer;
		});
		
		this.addEventListener(Event.REMOVED_FROM_STAGE, function(){
			if(spawner != null)
				spawner.stop();
		});
		
		plane = new Image(planeTexture);
		plane.width = 100;
		plane.height = 50;
		plane.pivotY = plane.height/2;
		plane.pivotY = plane.width/2;
		plane.x = 120;
		plane.y = 300;
		
		addChild(plane);
		
		rightAnsSound = rightAnswerSound;
		wrongAnsSound = wrongAnswerSound;
		
		// Initialize the key map
		keyMap.set(K_UP, false); 	// W (up)
		keyMap.set(K_LEFT, false); 	// A (left)
		keyMap.set(K_DOWN, false); 	// S (down)
		keyMap.set(K_RIGHT, false); // D (right)
	}
	
	public function onEnterFrame(event:EnterFrameEvent){
		if(paused)
			return;
			
		// Apply the y velocity
		vy += gravity;
		
		if(keyMap.get( K_UP )){
			vy -= 0.2;
		}

		//keeps the plane on the screen
		checkOutOfBounds();

		// Apply the movements
		plane.x += vx;
		plane.y += vy;	
	
		// Apply the rotation
		var ry:Float = (Math.abs(vy) > 10) ? vy/Math.abs(vy) : vy/10;
		plane.rotation = (Math.PI/16)*ry;
		
		hitDetection();
	}
	
	/** Function to be called when a particular key is pressed down */
	public function keyDown( event:KeyboardEvent ){
		var keyCode:Int = event.keyCode;
		if(!isBound(keyCode))
			return;
			
		if(keyMap.get(keyCode))
			return;
			
		keyMap.set(keyCode, true);
		updateVelocity();
	}
	
	/** Function to be called when a particular key is unpressed */
	public function keyUp( event:KeyboardEvent ){
		var keyCode:Int = event.keyCode;
		if(!isBound(keyCode))
			return;
			
		keyMap.set(keyCode, false);
		updateVelocity();
	}
	
	/** Checks whether a key is bound to the keymap or not */
	private function isBound( keyCode:Int ) : Bool {
		return (keyCode == K_UP || keyCode == K_LEFT || keyCode == K_DOWN || keyCode == K_RIGHT);
	}
	
	/** Update the plane's velocities based on key press */
	private function updateVelocity(){
		// Apply velocities based on the values in the keyMap
		vx = 0;
		if( keyMap.get( K_LEFT ) )
			vx += -2;
		if( keyMap.get( K_RIGHT ) )
			vx += 3;
	};
	
	/** Simple hit detection */
	private function hitDetection(){
		for(answer in answerList){
			if(answer.bounds.intersects(plane.bounds)){
				processAnswer(cast(answer.getChildAt(1),TextField).text);
				this.removeChild(answer,true);
				answerList.remove(answer);
			}
		}
	}
	
	/** Spawn a new potential answer box */
	private function spawnAnswer(){
		if(paused)
			return;
			
		if(spawner != null)
			spawner.stop();
		
		if(answerList.last() != null && answerList.last().x + answerList.last().width > stage.stageWidth - 20){
			spawner = new Timer(100);
			spawner.run = spawnAnswer;
			return;
		}
		
		spawner = new Timer(500);
		spawner.run = spawnAnswer;
		
		// Choose the text for the word...
		var answers = answerObject[questionIndex].answers;
		var text = (Math.floor(Math.random()*6)==0) ? answers[0] : answers[Math.round(Math.random()*(answers.length-2))+1];
		
		// Fade out the loading screen since everything is loaded
		var answer = new TextField(130,50,text);
			answer.bold = true;
			answer.color = 0xffffff;
			answer.border = false;
			answer.fontName = "gameFont02";
			answer.fontSize = 32;
			answer.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			answer.alpha = 0.9;
			
		var bg = new Quad(answer.width, answer.height);
			bg.alpha = 0.0;
			bg.color = 0;
		
		var container = new Sprite();
		container.addChild(bg);
		container.addChild(answer);
		container.x = this.stage.stageWidth;
		container.y = Math.random()*(this.stage.stageHeight-100) + 50;
			
		addChild(container);
		
		answerList.add(container);
		
		Starling.juggler.tween(container, 5, {
			transition: Transitions.LINEAR,
			x: -300,
			onComplete: function() {
				this.removeChild(container,true);
				answerList.remove(container);
			}
		});
	}	
	public function selectRandomFont() {
		// local var
		var fontName:String;
		
		var dice = Math.random();
		
		if (dice < 0.33) {
			fontName = "gameFont01";
		}
		else if (dice < 0.66) {
			fontName = "gameFont02";
		}
		else {
			fontName = "gameFont04";
		}
		
		return fontName;
	}
	
	public function processAnswer(text:String){
		var currentSpan = healthBar.getBarSpan();
		
		if(text == answerObject[questionIndex].answers[0]){
			rightAnsSound.play();
			healthBar.animateBarSpan(currentSpan + 0.1, 0.015);
			healthBar.flashColor(0x00FF00, 30);
			displayNextQuestion();
		} else {
			wrongAnsSound.play();
			healthBar.animateBarSpan(currentSpan - 0.3, 0.015);
			healthBar.flashColor(0xFF0000, 30);
			
			if(healthBar.getBarSpan() < 0.1 && gameOver != null){
				gameOver(false);
			}
		
		}
	};
	
	public function shuffleQuestions(){
		shuffle(answerObject);
	}
	
	public function shuffle(object:Dynamic){
		if(object != null){
			for(i in 0...object.length){
				var temp = object[i];
				var randIndex = Math.round( Math.random()*(object.length-1));
				object[i] = object[randIndex];
				object[randIndex] = temp;
			}
		}
	}
	
	public function displayNextQuestion(){
		if(answerObject != null){
			if(answerObject.length-1 == questionIndex){
				gameOver(true);
				return;
			}
				
			if(questionText != null)
				removeChild(questionText);
				
			// JSON data object
			var data = answerObject[++questionIndex];
			
			// Center coordinates
			var centerX = this.stage.stageWidth/2;
			var centerY = this.stage.stageHeight/2;
			
			var questionText = new TextField(1280,40,data.question);
				questionText.fontName = "gamefont05";
				questionText.autoSize = "center";
				questionText.color = textColor;
				questionText.bold = true;
				questionText.fontSize = 24;
				//questionText.autoSize = TextFieldAutoSize.HORIZONTAL;
				addChild(questionText);
			
			var bg = new Quad(questionText.width, questionText.height);
				bg.alpha = 0.3;
				bg.color = 0;
				
			var container = new Sprite();
				container.width = questionText.width;
				container.height = questionText.height;
				container.x = centerX - questionText.width/2;
				container.y = 75;
								
			container.addChild(bg);
			container.addChild(questionText);
			addChildAt(container,0);
			
			this.questionText = container;
		}
	}
	
	public function debugPrint(){
		if(answerObject == null){
			trace("NULL ANSWER OBJECT");
			return;
		}
		
		for(i in 0...answerObject.length){
			var data = answerObject[i];
			trace(data.question);
			
			for(n in 0...answerObject[i].answers.length){
				trace(answerObject[i].answers[n]);
			}
			
			trace("");
		}
	}

	private function checkOutOfBounds(){
		//resets velocity if plane is out of bounds
		if(plane.y < 0) {
			vy = 1;
		} else if (plane.y > (stage.stageHeight - plane.height)){
			vy = -1;
		}
		if (plane.x < 0){
			vx = 1;
		} else if (plane.x > (stage.stageWidth - plane.width)){
			vx = -1;
		}
		
	}

	public function getHealthBar(){
		return this.healthBar;
	}
	
	public function BackgroundTransition(fadesOutBG:LevelBackground, fadesInBG:LevelBackground){
			Starling.juggler.tween(fadesOutBG, 3, {
					transition: Transitions.EASE_OUT,
					delay: 1,
					alpha: 0,
					onComplete: function() {
					this.removeChild(fadesOutBG);
					this.addChild(fadesInBG);
					Starling.juggler.tween(fadesInBG, 1, {
						transition: Transitions.EASE_IN,
						delay: 1,
						alpha: 1
					});}});
		}
}