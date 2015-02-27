package com.learn.haxe;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.geom.Rectangle;
import starling.core.Starling;

@:bitmap("bin/assets/loadingScreen.png")
class LoadingBitmapData extends flash.display.BitmapData { }

@:bitmap("bin/assets/plane.png")
class LoadingPlaneBitmapData extends flash.display.BitmapData {}

class GameLoader extends Sprite {

    public var loadingBitmap:Bitmap;
    public var loadingPlaneBitmap:Bitmap;
    public var startup:Sprite;

    function new() {
        super();
        startup = this;
        loadingBitmap = new Bitmap(new LoadingBitmapData(0, 0));
        loadingBitmap.x = 0;
        loadingBitmap.y = 0;
        loadingBitmap.width = flash.Lib.current.stage.stageWidth;
        loadingBitmap.height = flash.Lib.current.stage.stageHeight;
        loadingBitmap.smoothing = true;
        addChild(loadingBitmap);
		
		loadingPlaneBitmap = new Bitmap(new LoadingPlaneBitmapData(0, 0));
        loadingPlaneBitmap.x = 380;
        loadingPlaneBitmap.y = 130;
        loadingPlaneBitmap.smoothing = true;
        addChild(loadingPlaneBitmap);

        flash.Lib.current.stage.addEventListener(flash.events.Event.RESIZE,
            function(e:flash.events.Event) {
                Starling.current.viewPort = new Rectangle(0, 0,
                flash.Lib.current.stage.stageWidth,
                flash.Lib.current.stage.stageHeight);
                if (loadingBitmap != null) {
                    loadingBitmap.width = flash.Lib.current.stage.stageWidth;
                    loadingBitmap.height = flash.Lib.current.stage.stageHeight;
                }});

		var mStarling = new Starling(GameDriver, flash.Lib.current.stage);
		mStarling.antiAliasing = 0;
		function onGameDriverCreated(event:Dynamic, root:GameDriver) {
			mStarling.removeEventListener(starling.events.Event.ROOT_CREATED,
			    onGameDriverCreated);
            root.start(this, mStarling.stage);
            mStarling.start();
        }
        mStarling.addEventListener(starling.events.Event.ROOT_CREATED,
		    onGameDriverCreated);
    }

    static function main() {
        var stage = flash.Lib.current.stage;
        stage.addChild(new GameLoader());
    }

}