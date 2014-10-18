package ;

import openfl.display.DisplayObject;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.events.Event;
import openfl.Lib;

/**
 * Stage size, taking into account retina scale
 * @author Philippe / http://philippe.elsass.me
 */

class Env 
{
	static public var dpi:Float;
	static public var width:Int;
	static public var height:Int;

	static public function setup() 
	{
		var stage = Lib.current.stage;
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.addEventListener(Event.RESIZE, stage_resize);
		#if !(flash || js)
		dpi = stage.dpiScale;
		#else
		dpi = 1;
		#end
		Lib.current.scaleX = Lib.current.scaleY = dpi;
		stage_resize(null);
	}

	static private function stage_resize(e) 
	{
		width = Math.ceil(Lib.current.stage.stageWidth / dpi);
		height = Math.ceil(Lib.current.stage.stageHeight / dpi);
	}

}