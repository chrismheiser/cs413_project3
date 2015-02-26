package com.learn.haxe.core;

import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class BackgroundLayer extends Sprite{

	public var speed:Float;
	private var image1:Image;
	private var image2:Image;

	//to create a layer, give the constructor a texture, a speed, and
	//whether or not the layer is alighned with the top or the bottom of the screen
	public function new(texture:Texture, speed:Float, top:Bool){
		super();
		this.speed = speed;
		this.image1 = new Image(texture);
		this.image2 = new Image(texture);

		if (top){
			image1.x = 0;
			image1.y = 0;
			image2.x = 1280;
			image2.y = 0;
		} else {
			image1.x = 0;
			image1.y = image1.height;
			image2.x = 1280;
			image2.y = image1.y;
		}

		this.addChild(image1);
		this.addChild(image2);
	}

}