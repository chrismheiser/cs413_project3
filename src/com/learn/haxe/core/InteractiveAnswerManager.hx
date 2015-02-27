package com.learn.haxe.core;

import starling.textures.Texture;
import starling.display.Quad;

import starling.display.Sprite;
import starling.display.Image;
import starling.text.TextField;
import starling.text.TextFieldButton;
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
	var gravity:Float = 0.25;
	
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
			spawner = new Timer(700);
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
		// Apply the y velocity
		vy += gravity;
		
		if(keyMap.get( K_UP )){
			vy -= 0.5;
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
		// Choose the text for the word...
		var answers = answerObject[questionIndex].answers;
		var text = (Math.floor(Math.random()*6)==0) ? answers[0] : answers[Math.round(Math.random()*(answers.length-2))+1];
		
		// Fade out the loading screen since everything is loaded
		var answer = new TextField(100,30,text);
			answer.bold = true;
			answer.color = textColor;
			answer.border = true;
		
		var bg = new Quad(answer.width, answer.height);
			bg.alpha = 0.7;
			bg.color = 0;
		
		var container = new Sprite();
		container.addChild(bg);
		container.addChild(answer);
		container.x = this.stage.stageWidth;
		container.y = Math.random()*(this.stage.stageHeight-100) + 50;
			
		addChild(container);
		
		answerList.add(container);
		
		Starling.juggler.tween(container, 8, {
			transition: Transitions.LINEAR,
			x: -100,
			onComplete: function() {
				this.removeChild(container,true);
				answerList.remove(container);
			}
		});
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
				gameOver(true);
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
			
			var questionText = new TextField(450,40,data.question);
				questionText.autoSize = "center";
				questionText.color = textColor;
				questionText.bold = true;
				addChild(questionText);
			
			var bg = new Quad(questionText.width, questionText.height);
				bg.alpha = 0.3;
				bg.color = 0;
				
			var container = new Sprite();
				container.width = questionText.width;
				container.height = questionText.height;
				container.x = centerX - questionText.width/2;
				container.y = centerY - questionText.height/2;
								
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