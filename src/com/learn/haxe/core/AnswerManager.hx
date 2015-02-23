package com.learn.haxe.core;

import starling.display.Sprite;
import starling.text.TextField;
import starling.text.TextFieldButton;
import starling.events.Event;

class AnswerManager extends Sprite{
	var answerObject:Dynamic;
	var questionIndex = 0;
	var correctAnswer = "";
	
	function new( answerObject:Dynamic ){
		super();
		this.answerObject = answerObject;
		this.addEventListener(Event.ADDED_TO_STAGE, displayNextQuestion);
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
			this.removeChildren();
			
			// JSON data object
			var data = answerObject[questionIndex++];
			correctAnswer = data.answers[0];
			shuffle(data.answers);
			
			// Center coordinates
			var centerX = this.stage.stageWidth/2;
			var centerY = this.stage.stageHeight/2;

			// Question text field
			var tfQuestion:TextField = new TextField(600,50,data.question,"Verdana");
				tfQuestion.x = centerX-tfQuestion.width/2;
				tfQuestion.y = centerY-tfQuestion.height - 75;
				tfQuestion.border = true;
				addChild(tfQuestion);
				
			// Top left button
			var tfButton:TextFieldButton = new TextFieldButton(100, 20, data.answers[0], "Verdana", 12, 0x0, 0xFF0000);
			tfButton.x = centerX-tfButton.width*2;
			tfButton.y = centerY-tfButton.height*2.5;
			tfButton.border = true;
			tfButton.onClick = buttonClick;
			addChild(tfButton);	
			
			// Bottom left button
			tfButton = new TextFieldButton(100, 20, data.answers[1], "Verdana", 12, 0x0, 0xFF0000);
			tfButton.x = centerX-tfButton.width*2;
			tfButton.y = centerY;
			tfButton.border = true;
			tfButton.onClick = buttonClick;
			addChild(tfButton);	
			
			// Top right button
			tfButton = new TextFieldButton(100, 20, data.answers[2], "Verdana", 12, 0x0, 0xFF0000);
			tfButton.x = centerX+tfButton.width;
			tfButton.y = centerY-tfButton.height*2.5;
			tfButton.border = true;
			tfButton.onClick = buttonClick;
			addChild(tfButton);	
			
			// Bottom right button
			tfButton = new TextFieldButton(100, 20, data.answers[3], "Verdana", 12, 0x0, 0xFF0000);
			tfButton.x = centerX+tfButton.width;
			tfButton.y = centerY;
			tfButton.border = true;
			tfButton.onClick = buttonClick;
			addChild(tfButton);	
		}
	}

	public function buttonClick( button:TextFieldButton ){
		if(button.text == correctAnswer){
			trace("Correct!");
			displayNextQuestion();
		} else {
			trace("Wrong...");
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