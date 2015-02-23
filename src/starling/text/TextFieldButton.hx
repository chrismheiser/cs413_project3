package starling.text;

import starling.events.TouchEvent;
import starling.events.Touch;
import starling.events.Event;

class TextFieldButton extends TextField{
	var baseColor:UInt;
	var highlightColor:UInt;
	
	public var onClick:TextFieldButton->Void;
	
	public function new(width:Int, height:Int, text:String, fontName:String = "Verdana", fontSize:Int = 12, baseColor:UInt = 0x0, highlightColor:UInt = 0x0, bold:Bool = false){
		super(width,height,text,fontName,fontSize,color,bold);
	
		this.useHandCursor = true;
		this.baseColor = baseColor;
		this.highlightColor = highlightColor;
		this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
	}
	
	public function addedToStage(){
		this.removeEventListeners();
		this.stage.addEventListener(TouchEvent.TOUCH, onTouch);
	}
	
	private function intersects(x:Float, y:Float):Bool{
		return(x >= this.x && y >= this.y && x <= (this.x + this.width) && y <= (this.y + this.height));
	}
	
	public function onTouch( event:TouchEvent ){
		var touch:Touch = event.touches[0];		
				
		if( intersects(touch.globalX, touch.globalY) ){
			if(touch.phase == "ended") {
				if(onClick != null)
					onClick(this);
			} else { 
				this.color = highlightColor;
			}
		} else {
			this.color = baseColor;
		}
	}

}