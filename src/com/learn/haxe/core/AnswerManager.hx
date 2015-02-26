package com.learn.haxe.core;

import starling.textures.Texture;
import starling.display.Sprite;
import starling.display.Image;
import starling.text.TextField;
import starling.text.TextFieldButton;
import starling.events.Event;

import flash.media.Sound;

class AnswerManager extends Sprite{
	var answerObject:Dynamic;
	var questionIndex = 0;
	var correctAnswer = "";
	
	var healthBar:HealthBar;
	var questionSprite:Sprite = new Sprite();
	
	// sounds
	var rightAnsSound : Sound;
	var wrongAnsSound : Sound;
	
	function new( healthBarTexture:Texture, answerObject:Dynamic, rightAnswerSound:Sound, wrongAnswerSound:Sound ){
		super();
		this.answerObject = answerObject;
		this.addEventListener(Event.ADDED_TO_STAGE, displayNextQuestion);
		
		healthBar = new HealthBar(200,40,healthBarTexture);
		healthBar.y = 50;
		healthBar.x = 500;
		addChild(healthBar);
		addChild(questionSprite);
		
		rightAnsSound = rightAnswerSound;
		wrongAnsSound = wrongAnswerSound;
	}
	
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
		if(answerObject != null && answerObject.length > questionIndex){
			questionSprite.removeChildren();
			
			// JSON data object
			var data = answerObject[questionIndex++];
			correctAnswer = data.answers[0];
			shuffle(data.answers);
			
			// Center coordinates
			var centerX = this.stage.stageWidth/2;
			var centerY = this.stage.stageHeight/2 + 180;

			// Question text field
			var tfQuestion:TextField = new TextField(600,50,data.question,"Verdana");
				tfQuestion.x = centerX-tfQuestion.width/2;
				tfQuestion.y = centerY-tfQuestion.height - 75;
				tfQuestion.border = true;
				questionSprite.addChild(tfQuestion);
				
			// Top left button
			var tfButton:TextFieldButton = new TextFieldButton(100, 20, data.answers[0], "Verdana", 12, 0x0, 0xFF0000);
			tfButton.x = centerX-tfButton.width*2;
			tfButton.y = centerY-tfButton.height*2.5;
			tfButton.border = true;
			tfButton.onClick = buttonClick;
			questionSprite.addChild(tfButton);	
			
			// Bottom left button
			tfButton = new TextFieldButton(100, 20, data.answers[1], "Verdana", 12, 0x0, 0xFF0000);
			tfButton.x = centerX-tfButton.width*2;
			tfButton.y = centerY;
			tfButton.border = true;
			tfButton.onClick = buttonClick;
			questionSprite.addChild(tfButton);	
			
			// Top right button
			tfButton = new TextFieldButton(100, 20, data.answers[2], "Verdana", 12, 0x0, 0xFF0000);
			tfButton.x = centerX+tfButton.width;
			tfButton.y = centerY-tfButton.height*2.5;
			tfButton.border = true;
			tfButton.onClick = buttonClick;
			questionSprite.addChild(tfButton);	
			
			// Bottom right button
			tfButton = new TextFieldButton(100, 20, data.answers[3], "Verdana", 12, 0x0, 0xFF0000);
			tfButton.x = centerX+tfButton.width;
			tfButton.y = centerY;
			tfButton.border = true;
			tfButton.onClick = buttonClick;
			questionSprite.addChild(tfButton);	
		}
	}

	public function buttonClick( button:TextFieldButton ){
		var currentSpan = healthBar.getBarSpan();
		
		if(button.text == correctAnswer){
			rightAnsSound.play();
			healthBar.animateBarSpan(currentSpan + 0.1, 0.015);
			healthBar.flashColor(0x00FF00, 30);
			displayNextQuestion();
		} else {
			wrongAnsSound.play();
			healthBar.animateBarSpan(currentSpan - 0.1, 0.015);
			healthBar.flashColor(0xFF0000, 30);
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
}