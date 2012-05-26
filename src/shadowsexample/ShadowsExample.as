package shadowsexample {

	import alternativa.engine3d.controllers.SimpleObjectController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.View;
	import alternativa.engine3d.lights.AmbientLight;
	import alternativa.engine3d.lights.DirectionalLight;
	import alternativa.engine3d.materials.StandardMaterial;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.shadows.DirectionalLightShadow;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Matrix3D;
	import flash.ui.Keyboard;

	/**
	 * Shadows usage example.
	 * Пример использования теней.
	 */
	[SWF(backgroundColor="#000000", frameRate="60", width="600", height="600")]
	public class ShadowsExample extends Sprite {

		[Embed(source="bark_diffuse.jpg")]
		private static const EmbedBarkDiffuse:Class;
		[Embed(source="bark_normal.jpg")]
		private static const EmbedBarkNormal:Class;
		[Embed(source="branch_diffuse.jpg")]
		private static const EmbedBranchDiffuse:Class;
		[Embed(source="branch_normal.jpg")]
		private static const EmbedBranchNormal:Class;
		[Embed(source="branch_opacity.jpg")]
		private static const EmbedBranchOpacity:Class;
		[Embed(source="grass.jpg")]
		private static const EmbedGrassDiffuse:Class;

		private var rootContainer:Object3D = new Object3D();

		private var camera:Camera3D;
		private var controller:SimpleObjectController;

		private var stage3D:Stage3D;

		private var tree:Object3D;
		private var counter:Number = 1;
		private var shadow:DirectionalLightShadow;
		private var ambientLight:AmbientLight;
		private var directionalLight:DirectionalLight;

		public function ShadowsExample() {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			stage3D = stage.stage3Ds[0];
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, init);
			stage3D.requestContext3D();
		}

		private function init(e:Event):void {
			// Creates help message
			createLabel();
			// Camera and view
			// Создание камеры и вьюпорта
			camera = new Camera3D(10, 100000);

			camera.view = new View(stage.stageWidth, stage.stageHeight, false, 0xa4c4d7, 1, 8);
			addChild(camera.view);
			addChild(camera.diagram);

			// Initial position
			// Установка начального положения камеры
			var matrix:Matrix3D = new Matrix3D(Vector.<Number>([-0.6691306829452515, -0.7431448101997375, 0, 0, -0.10342574119567871, 0.09312496334314346, -0.9902680516242981, 0, 0.735912561416626, -0.6626186966896057, -0.13917307555675507, 0, -333.00445556640625, 237.38864135742188, 290.38525390625, 1]));
			camera.matrix = matrix;
			controller = new SimpleObjectController(stage, camera, 200);
			rootContainer.addChild(camera);

			// Resources
			// Ресурсы
			var grass_diffuse:BitmapTextureResource = new BitmapTextureResource(new EmbedGrassDiffuse().bitmapData);
			var grass_normal:BitmapTextureResource = new BitmapTextureResource(new BitmapData(1, 1, false, 0x7F7FFF));
			var bark_diffuse:BitmapTextureResource = new BitmapTextureResource(new EmbedBarkDiffuse().bitmapData);
			var bark_normal:BitmapTextureResource = new BitmapTextureResource(new EmbedBarkNormal().bitmapData);
			var branch_diffuse:BitmapTextureResource = new BitmapTextureResource(new EmbedBranchDiffuse().bitmapData);
			var branch_normal:BitmapTextureResource = new BitmapTextureResource(new EmbedBranchNormal().bitmapData);
			var branch_opacity:BitmapTextureResource = new BitmapTextureResource(new EmbedBranchOpacity().bitmapData);
			grass_diffuse.upload(stage3D.context3D);
			grass_normal.upload(stage3D.context3D);
			bark_diffuse.upload(stage3D.context3D);
			bark_normal.upload(stage3D.context3D);
			branch_diffuse.upload(stage3D.context3D);
			branch_normal.upload(stage3D.context3D);
			branch_opacity.upload(stage3D.context3D);

			// Materials
			// Материалы
			var grassMaterial:StandardMaterial = new StandardMaterial(grass_diffuse, grass_normal);
			grassMaterial.specularPower = 0.14;
			var barkMaterial:StandardMaterial = new StandardMaterial(bark_diffuse, bark_normal);
			var branchMaterial:StandardMaterial = new StandardMaterial(branch_diffuse, branch_normal, null, null, branch_opacity);
			branchMaterial.specularPower = 0;
			branchMaterial.alphaThreshold = 0.8;

			// Models
			// Модели

			var grass:Plane = new Plane(900, 900);
			grass.geometry.upload(stage3D.context3D);
			grass.setMaterialToAllSurfaces(grassMaterial);
			rootContainer.addChild(grass);

			var platform:Box = new Box(300, 300, 50);
			platform.geometry.upload(stage3D.context3D);
			platform.setMaterialToAllSurfaces(barkMaterial);
			platform.z = 25;
			rootContainer.addChild(platform);

			var balk1:Box = new Box(30, 30, 250);
			balk1.geometry.upload(stage3D.context3D);
			balk1.setMaterialToAllSurfaces(barkMaterial);
			balk1.x = -180;
			balk1.y = 180;
			balk1.z = 125;
			rootContainer.addChild(balk1);
			var balk2:Box = balk1.clone() as Box;
			balk2.x = 180;
			rootContainer.addChild(balk2);
			var balk3:Box = balk2.clone() as Box;
			balk3.y = -180;
			rootContainer.addChild(balk3);
			var balk4:Box = balk3.clone() as Box;
			balk4.x = -180;
			rootContainer.addChild(balk4);

			tree = new Object3D();
			tree.z = 50;
			var branch:Plane = new Plane(400, 400);
			branch.geometry.upload(stage3D.context3D);
			branch.setMaterialToAllSurfaces(branchMaterial);
			branch.rotationX = Math.PI/2;
			branch.rotationZ = Math.PI/4;
			branch.z = 200;
			tree.addChild(branch);
			branch = branch.clone() as Plane;
			branch.rotationZ += Math.PI/2;
			tree.addChild(branch);
			rootContainer.addChild(tree);

			// Light sources
			// Источники света
			ambientLight = new AmbientLight(0x333390);
			rootContainer.addChild(ambientLight);
			directionalLight = new DirectionalLight(0xFFFF60);
			directionalLight.lookAt(-0.5, -1, -1);
			rootContainer.addChild(directionalLight);

			// Shadow
			// Тень
			shadow = new DirectionalLightShadow(1000, 1000, -500, 500, 1024, 0.2);
			shadow.biasMultiplier = .98;
			shadow.addCaster(platform);
			shadow.addCaster(balk1);
			shadow.addCaster(balk2);
			shadow.addCaster(balk3);
			shadow.addCaster(balk4);
			shadow.addCaster(tree);
			directionalLight.shadow = shadow;


			// Listeners
			// Подписка на события
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(Event.RESIZE, onResize);
		}

		private function createLabel():void {
			var info:TextInfo = new TextInfo();
			info.x = 5;
			info.y = 5;
			info.write("ASDF — move camera");
			info.write("Q — change shadow quality");
			info.write("I — use shadows debug");
			info.write("P, Shift+P — increase/decrease PCF size");
			info.write("[, Shift+[ — increase/decrease bias multiplier");
			info.write("7 —  set work volume height to 1000");
			info.write("8 —  set work volume height to 10000");
			info.write("9 —  change shadow color to blue");
			info.write("0 —  change shadow color to black");
			addChild(info);
		}

		private function onKeyDown(event:KeyboardEvent):void {
			switch (event.keyCode) {
				case Keyboard.SPACE :
					trace(camera.matrix.rawData);
					break;
				case Keyboard.I :
					shadow.debug = !shadow.debug;
					break;
				case Keyboard.LEFTBRACKET:
					shadow.biasMultiplier += event.shiftKey ? 0.01 : -0.01;
					break;
				case Keyboard.Q :
				{
					if (shadow.mapSize < 2048)
						shadow.mapSize *= 2;
					else
						shadow.mapSize = 128;
				}
					break;
				case Keyboard.P:
				{
					shadow.pcfOffset +=
							event.shiftKey ? -1 : 1;
				}
					break;
				case Keyboard.NUMBER_9:
				{
					directionalLight.color = 0xFFFF60;
					ambientLight.color = 0x333390
				}
					break;
				case Keyboard.NUMBER_0:
				{
					directionalLight.color = 0xFFFFa0;
					ambientLight.color = 0x333333;
				}
					break;
				case Keyboard.NUMBER_7:
				{
					shadow.farBoundPosition = 500;
					shadow.nearBoundPosition = -500
				}
					break;
				case Keyboard.NUMBER_8:
				{
					shadow.farBoundPosition = 5000;
					shadow.nearBoundPosition = -5000
				}
					break;
			}
		}

		private function onEnterFrame(e:Event):void {
			counter += .001*Math.sin(counter) + .01;
			tree.rotationY = Math.sin(counter)/7 - .2;
			controller.update();
			camera.render(stage3D);
		}

		private function onResize(e:Event = null):void {
			camera.view.width = stage.stageWidth;
			camera.view.height = stage.stageHeight;
		}

	}
}

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

class TextInfo extends Sprite {
	private var textField:TextField;
	private var bg:Sprite;

	public function TextInfo() {
		bg = new Sprite();
		with (bg.graphics) {
			beginFill(0x000000, .75);
			drawRect(0, 0, 10, 10);
			endFill();
		}
		textField = new TextField();
		textField.autoSize = TextFieldAutoSize.LEFT;
		textField.selectable = false;
		textField.defaultTextFormat = new TextFormat("Tahoma", 10, 0xFFFFFF);
		textField.x = 5;
		textField.y = 5;
		addChild(bg);
		addChild(textField);
	}

	public function write(value:String):void {
		textField.appendText(value + "\n");
		bg.width = textField.width + 10;
		bg.height = textField.height + 10;
	}
}
