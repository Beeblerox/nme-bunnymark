package ;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.display.StageQuality;
import openfl.display.Tilesheet;
import openfl.display.BlendMode;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.KeyboardEvent;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.Assets;
import openfl.Lib;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

import openfl.ui.Keyboard;

/**
 * @author Joshua Granick
 * @author Philippe Elsass
 */
class TileTest extends Sprite 
{
	var tf:TextField;	
	var numBunnies:Int;
	var incBunnies:Int;
	var smooth:Bool;
	var gravity:Float;
	var bunnies:Array <Bunny>;
	var maxX:Int;
	var minX:Int;
	var maxY:Int;
	var minY:Int;
	var bunnyAsset:BitmapData;
	var pirate:Bitmap;
	var tilesheet:Tilesheet;
	var drawList:Array<Float>;
	
	var drawTilesFlag:Int;
	var drawRectsFlag:Int;
	var bunnyRect:Rectangle;
	var bunnyOrigin:Point;
	var bunnyId:Int;
	
	var useRects:Bool = true;
	var tfTileMode:TextField;
	
	public function new() 
	{
		super ();
		
		drawTilesFlag = Tilesheet.TILE_SCALE | Tilesheet.TILE_ROTATION | Tilesheet.TILE_ALPHA;
		drawRectsFlag = Tilesheet.TILE_SCALE | Tilesheet.TILE_ROTATION | Tilesheet.TILE_ALPHA | Tilesheet.TILE_RECT | Tilesheet.TILE_ORIGIN;
		
		gravity = 0.5;
		incBunnies = 100;
		#if flash
		smooth = false;
		numBunnies = 100;
		Lib.current.stage.quality = StageQuality.LOW;
		#else
		smooth = true;
		numBunnies = 500;
		#end

		bunnyAsset = Assets.getBitmapData("assets/wabbit_alpha.png");
		#if !flash
		pirate = new Bitmap(Assets.getBitmapData("assets/pirate.png"), null, true);
		#else
		pirate = new Bitmap(Assets.getBitmapData("assets/pirate.png"));
		#end
		pirate.scaleX = pirate.scaleY = Env.height / 768;
		addChild(pirate);
		
		bunnies = new Array<Bunny>();
		drawList = new Array<Float>();
		
		bunnyRect = new Rectangle(0, 0, bunnyAsset.width, bunnyAsset.height);
		bunnyOrigin = new Point(0.5 * bunnyRect.width, 0.5 * bunnyRect.height);
		
		tilesheet = new Tilesheet(bunnyAsset);
		bunnyId = tilesheet.addTileRect(bunnyRect, bunnyOrigin);
		
		var bunny; 
		for (i in 0...numBunnies) 
		{
			bunny = new Bunny();
			bunny.position = new Point();
			bunny.speedX = Math.random() * 5;
			bunny.speedY = (Math.random() * 5) - 2.5;
			bunny.scale = 0.3 + Math.random();
			bunny.rotation = 15 - Math.random() * 30;
			bunnies.push(bunny);
		}
		
		createCounter();
		
		addEventListener(Event.ENTER_FRAME, enterFrame);
		Lib.current.stage.addEventListener(Event.RESIZE, stage_resize);
		
		stage_resize(null);
	}

	function createCounter()
	{
		var format = new TextFormat("_sans", 20, 0, true);
		format.align = TextFormatAlign.RIGHT;

		tf = new TextField();
		tf.selectable = false;
		tf.defaultTextFormat = format;
		tf.width = 200;
		tf.height = 60;
		tf.x = maxX - tf.width - 10;
		tf.y = 10;
		addChild(tf);

		tf.addEventListener(MouseEvent.CLICK, counter_click);
		
		format = new TextFormat("_sans", 20, 0, true);
		format.align = TextFormatAlign.CENTER;
		
		tfTileMode = new TextField();
		tfTileMode.selectable = false;
		tfTileMode.defaultTextFormat = format;
		tfTileMode.width = 200;
		tfTileMode.height = 150;
		tfTileMode.wordWrap = true;
		tfTileMode.x = 0.5 * (maxX - tfTileMode.width);
		tfTileMode.y = 10;
		tfTileMode.text = "Use rects: " + useRects + "\nClick HERE to switch mode";
		addChild(tfTileMode);
		
		tfTileMode.addEventListener(MouseEvent.CLICK, tileModeClick);
	}
	
	private function tileModeClick(e:Event):Void 
	{
		useRects = !useRects;
		tfTileMode.text = "Use rects: " + useRects + "\nClick HERE to switch mode";
	}

	function counter_click(e)
	{
		if (numBunnies >= 1500) incBunnies = 250;
		var more = numBunnies + incBunnies;

		var bunny; 
		for (i in numBunnies...more)
		{
			bunny = new Bunny();
			bunny.position = new Point();
			bunny.speedX = Math.random() * 5;
			bunny.speedY = (Math.random() * 5) - 2.5;
			bunny.scale = 0.3 + Math.random();
			bunny.rotation = 15 - Math.random() * 30;
			bunnies.push (bunny);
		}
		numBunnies = more;

		stage_resize(null);
	}
	
	function stage_resize(e) 
	{
		maxX = Env.width;
		maxY = Env.height;
		tf.text = "Bunnies:\n" + numBunnies;
		tf.x = maxX - tf.width - 10;
		
		tfTileMode.x = 0.5 * (maxX - tfTileMode.width);
	}
	
	function enterFrame(e) 
	{	
		graphics.clear ();
		
		var TILE_FIELDS = useRects ? 11 : 6;
		var bunny;
	 	for (i in 0...numBunnies)
		{
			bunny = bunnies[i];
			bunny.position.x += bunny.speedX;
			bunny.position.y += bunny.speedY;
			bunny.speedY += gravity;
			bunny.alpha = 0.3 + 0.7 * bunny.position.y / maxY;
			
			if (bunny.position.x > maxX)
			{
				bunny.speedX *= -1;
				bunny.position.x = maxX;
			}
			else if (bunny.position.x < minX)
			{
				bunny.speedX *= -1;
				bunny.position.x = minX;
			}
			if (bunny.position.y > maxY)
			{
				bunny.speedY *= -0.8;
				bunny.position.y = maxY;
				if (Math.random() > 0.5) bunny.speedY -= 3 + Math.random() * 4;
			} 
			else if (bunny.position.y < minY)
			{
				bunny.speedY = 0;
				bunny.position.y = minY;
			}
			
			var index = i * TILE_FIELDS;
			drawList[index++] = bunny.position.x;
			drawList[index++] = bunny.position.y;
			
			if (useRects)
			{
				// tile rect from texture
				drawList[index++] = bunnyRect.x;
				drawList[index++] = bunnyRect.y;
				drawList[index++] = bunnyRect.width;
				drawList[index++] = bunnyRect.height;
				// tile origin
				drawList[index++] = bunnyOrigin.x;
				drawList[index++] = bunnyOrigin.y;
			}
			else
			{
				drawList[index++] = bunnyId; // sprite index
			}
			
			drawList[index++] = bunny.scale;
			drawList[index++] = bunny.rotation;
			drawList[index++] = bunny.alpha;
		}
		
		var drawFlag:Int = useRects ? drawRectsFlag : drawTilesFlag;
		
		tilesheet.drawTiles(graphics, drawList, smooth, drawFlag, numBunnies * TILE_FIELDS);

		var t = Lib.getTimer();
		pirate.x = Std.int((Env.width - pirate.width) * (0.5 + 0.5 * Math.sin(t / 3000)));
		pirate.y = Std.int(Env.height - pirate.height + 70 - 30 * Math.sin(t / 100));
	}
	
	
}