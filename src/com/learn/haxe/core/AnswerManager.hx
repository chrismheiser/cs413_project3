package com.learn.haxe.core;

import starling.display.Sprite;

class AnswerManager extends Sprite{
	var answerObject:Dynamic;
	
	function new( answerObject:Dynamic ){
		super();
		this.answerObject = answerObject;
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