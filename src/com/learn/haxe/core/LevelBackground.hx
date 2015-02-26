package com.learn.haxe.core;

import starling.display.Sprite;
import starling.events.Event;

class LevelBackground extends Sprite{

	//list of all the layers in this level
	private var layers:Array<BackgroundLayer> = new Array();

	//must have all the level's layers created before creating the level
	public function new(layers:Array<BackgroundLayer>){
		super();
		this.layers = layers;
		this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}

	private function onAddedToStage(event:Event){
		this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

		for (i in 0...layers.length){
			this.addChild(layers[i]);
		}

		this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

	private function onEnterFrame(event:Event){

		//move each layer on every frame based on its speed
		for(i in 0...layers.length){
			layers[i].x -= layers[i].speed;

			if (layers[i].x < -stage.stageWidth){
				layers[i].x = 0;
			}

		}
	}

}