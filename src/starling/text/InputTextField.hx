package starling.text;

import flash.geom.Point;
import starling.events.KeyboardEvent;
import starling.events.TouchEvent;
import starling.events.Touch;
import starling.events.Event;
import haxe.Timer;


class InputTextField extends TextField{
	public static var BLINK_INTERVAL = 1000;
	
	private var inFocus:Bool = false;
	private var blink:Bool = false;
	private var blinkTimer:Timer;
	public var trueText:String = "";
	
	public function new(width:Int, height:Int, text:String, fontName:String = "Verdana", fontSize:Int = 12, baseColor:UInt = 0x0, bold:Bool = false){
		super(width,height,text,fontName,fontSize,color,bold);
		this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		this.border = true;
	}
	
	public function addedToStage(){
		this.stage.addEventListener(TouchEvent.TOUCH, onTouch);
		this.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
	}
	
	public function removedFromStage(){
		this.stage.removeEventListener(TouchEvent.TOUCH, onTouch);
		this.removeEventListeners();
	}
	
	public function keyDown(event:KeyboardEvent){
		if(inFocus){
			// Backspace
			if(event.charCode == 8){
				if(trueText.length > 0)
					trueText = trueText.substr(0,trueText.length-1);
			} else if(event.charCode >= 32){
				trueText += String.fromCharCode(event.charCode);
			}
			
			this.text = (blink) ? " " + trueText + "|" : trueText;
		}
	}
	
	public function toggleBlinker(){
		if(inFocus){
			blink = !blink;
			this.text = (blink) ? " " + trueText + "|" : trueText;
		}
	}
	
	private function intersects(x:Float, y:Float):Bool{
		var global = this.localToGlobal(new Point(this.stage.x, this.stage.y));
		return(x >= global.x && y >= global.y && x <= (global.x + this.width) && y <= (global.y + this.height));
	}
	
	public function onTouch( event:TouchEvent ){
		var touch:Touch = event.touches[0];	

		if(touch.phase == "ended") {
			inFocus = intersects(touch.globalX, touch.globalY);
			
			if(!inFocus && blinkTimer != null){
				this.text = trueText;
				blink = false;
				blinkTimer.stop();
				blinkTimer = null;
			} else if(blinkTimer == null){
				blinkTimer = new Timer(BLINK_INTERVAL);
				blinkTimer.run = toggleBlinker;
				toggleBlinker();
			}
		}
	}

}