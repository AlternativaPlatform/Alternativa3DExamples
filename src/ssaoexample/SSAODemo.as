package ssaoexample {

	import alternativa.engine3d.animation.AnimationClip;
	import alternativa.engine3d.animation.AnimationController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Light3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.lights.AmbientLight;
	import alternativa.engine3d.lights.DirectionalLight;
	import alternativa.engine3d.loaders.ParserA3D;
	import alternativa.engine3d.loaders.ParserMaterial;
	import alternativa.engine3d.materials.StandardMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.shadows.DirectionalLightShadow;

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Matrix3D;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;

	/**
	 * This demo requires Alternativa3D "SSAO Edition".
	 * Read details here: http://wiki.alternativaplatform.com/SSAO_effect
	 */
	[SWF(width=800, height=800, backgroundColor=0, frameRate=60)]
	public class SSAODemo extends DefaultSceneTemplate {

		[Embed("resources/DemoScenaV2.A3D", mimeType="application/octet-stream")]
		private static const SceneClass:Class;
		[Embed("resources/bricks.jpg")]
		private static const WallClass:Class;
		[Embed("resources/roof_ed.jpg")]
		private static const RoofClass:Class;
		[Embed("resources/ground_N.jpg")]
		private static const GroundClass:Class;

		private var animation:AnimationController;
		private var _animated:Boolean = true;
		private var _animationRewind:Boolean = false;
		private var _animationDirection:Boolean = true;

		private var displayText:TextField;

		private var dirLight:DirectionalLight;
		private var shadow:DirectionalLightShadow;

		private var ssaoVisible:Boolean = true;
		private var parser:ParserA3D;

		public function SSAODemo() {
		}

		override protected function initScene():void {

			stage.frameRate = 40;
			stage.color = 0x146298;

			initHUD();

			parser = new ParserA3D();
			parser.parse(new SceneClass());

			prepareMaterials();
			prepareLightsAndShadows();
			prepareScene();
			prepareAnimation();

			controller.speed = 40;
			mainCamera.view.backgroundColor = 0x146298;
			mainCamera.nearClipping = 1;
			mainCamera.farClipping = 500;
			mainCamera.matrix = new Matrix3D(Vector.<Number>([-0.2912704050540924, 0.9566407799720764, 0, 0, -0.4682687222957611, -0.1425747573375702, -0.8720073699951172, 0, -0.8341978192329407, -0.25398993492126465, 0.4894927442073822, 0, 52.13594436645508, 19.32925796508789, 3.971318483352661, 1]));
			controller.smoothingDelay = 0.7;
			controller.updateObjectTransform();

			mainCamera.effectMode = Camera3D.MODE_SSAO_COLOR;
			// Following four parameters depend on scene dimension / camera dimension ratio
			// We relied that in the current scene the camera sees about 30 units of 3d space
			// And the broken house has similar size
			mainCamera.ssaoAngular.occludingRadius = 0.7;
			mainCamera.ssaoAngular.secondPassOccludingRadius = 0.32;
			mainCamera.ssaoAngular.maxDistance = 1;
			mainCamera.ssaoAngular.falloff = 7.2;

			mainCamera.ssaoAngular.intensity = 0.85;
			mainCamera.ssaoAngular.secondPassAmount = 0.76;
		}

		private function prepareMaterials():void {
			var wall:BitmapTextureResource = new BitmapTextureResource((new WallClass()).bitmapData);
			var roof:BitmapTextureResource = new BitmapTextureResource((new RoofClass()).bitmapData, true);
			var ground:BitmapTextureResource = new BitmapTextureResource((new GroundClass()).bitmapData, true);
			var normal:BitmapTextureResource = new BitmapTextureResource(new BitmapData(1, 1, false, 0x7F7FFF));

			var roofMaterial:StandardMaterial = new StandardMaterial(roof, normal);
			roofMaterial.specularPower = 0.1;
			var wallMaterial:StandardMaterial = new StandardMaterial(wall, normal);
			wallMaterial.specularPower = 0.1;
			var groundMaterial:StandardMaterial = new StandardMaterial(ground, normal);
			groundMaterial.specularPower = 0.1;

			var i:int;
			var object:Object3D;
			for (i = 0; i < parser.objects.length; i++) {
				object = parser.objects[i];
				if (object is Light3D) continue;
				var mesh:Mesh = object as Mesh;
				if (mesh != null) {
					for (var s:int = 0; s < mesh.numSurfaces; s++) {
						var surface:Surface = mesh.getSurface(s);
						var id:String = ParserMaterial(surface.material).textures["diffuse"].url;
						if (id != null && id.toLowerCase().indexOf("roof") >= 0) {
							surface.material = roofMaterial;
						} else if (id != null && id.toLowerCase().indexOf("bricks") >= 0) {
							surface.material = wallMaterial;
						} else if (id != null && id.toLowerCase().indexOf("ground") >= 0) {
							surface.material = groundMaterial;
						} else {
							trace("unknown texture: '" + id + "'");
						}
					}
				}
			}
		}

		private function prepareLightsAndShadows():void {
			var ambient:AmbientLight = new AmbientLight(0x8bccfa);
			ambient.intensity = 0.5;
			scene.addChild(ambient);
			dirLight = new DirectionalLight(0xffd98f);
			dirLight.intensity = 1.2;
			dirLight.z = 100;
			dirLight.x = 100;
			dirLight.y = -100;
			dirLight.lookAt(0, 0, 0);
			scene.addChild(dirLight);
			shadow = new DirectionalLightShadow(150, 120, -130, 130, 512, 1);
			shadow.biasMultiplier = 0.993;
			dirLight.shadow = shadow;
		}

		private function prepareScene():void {
			var i:int;
			var object:Object3D;
			for (i = 0; i < parser.hierarchy.length; i++) {
				object = parser.hierarchy[i];
				if (!(object is Light3D)) {
					scene.addChild(object);
					shadow.addCaster(object);
				}
			}
		}

		private function prepareAnimation():void {
			var clip:AnimationClip = parser.animations[0];
			clip.loop = false;
			clip.attach(scene, true);
			animation = new AnimationController();
			animation.root = clip;
			animation.freeze();
			_animationDirection = false;
			animationStartTime = getTimer() + 2000;
		}

		private function initHUD():void {
			displayText = new TextField();
			displayText.defaultTextFormat = new TextFormat("Tahoma", 15, 0x0);
			displayText.text = "";
			displayText.autoSize = TextFieldAutoSize.LEFT;
			displayText.selectable = false;
			addChild(displayText);

			var info:TextInfo = new TextInfo();
			info.x = 10;
			info.y = 10;
			info.write("Alternativa3D SSAO Demo, " + Capabilities.version + "\n");
			info.write("WSAD and Arrows — move");
			info.write("Q — quality low/high");
			info.write("----");

			info.write("1 — default mode");
			info.write("2 — raw SSAO mode");
			info.write("3 — z-buffer mode");
			info.write("4 — screen-space normals mode");
			info.write("----");

			info.write("U — toggle SSAO on/off");
			info.write("I — toggle shadows on/off");
			info.write("O — toggle SSAO second pass on/off");
			info.write("Space — animation play/pause");
			info.write("R — rewind animation");
			info.write("----");

			info.write("+/- — SSAO intensity");
			info.write("9/0 — SSAO first pass occluding radius");
			info.write("Page_Up/Page_Down — SSAO second pass amount");
			info.write("Home/End — SSAO second pass occluding radius");
			addChild(info);
		}

		override protected function onKeyDown(event:KeyboardEvent):void {
			super.onKeyDown(event);
			switch (event.keyCode) {
				case Keyboard.NUMBER_1:
					mainCamera.effectMode = ssaoVisible ? Camera3D.MODE_SSAO_COLOR : Camera3D.MODE_COLOR;
					printMessage("Normal render mode");
					break;
				case Keyboard.NUMBER_2:
					mainCamera.effectMode = Camera3D.MODE_SSAO_ONLY;
					printMessage("Raw SSAO render mode");
					break;
				case Keyboard.NUMBER_3:
					mainCamera.effectMode = Camera3D.MODE_DEPTH;
					printMessage("Z-buffer render mode");
					break;
				case Keyboard.NUMBER_4:
					mainCamera.effectMode = Camera3D.MODE_NORMALS;
					printMessage("Screen-space normals render mode");
					break;
				case Keyboard.SPACE:
					_animated = !_animated;
					animation.freeze();
					animationStartTime = -1;
					break;
				case Keyboard.R:
					_animationRewind = true;
					animationStartTime = -1;
					break;
				case Keyboard.Q:
					mainCamera.view.antiAlias = (mainCamera.view.antiAlias == 0) ? 4 : 0;
					if (mainCamera.view.antiAlias == 0) {
						// low
						mainCamera.ssaoScale = 1;
						printMessage("Quality low");
					} else {
						mainCamera.ssaoScale = 0;
						printMessage("Quality high");
					}
					break;
				case Keyboard.EQUAL:
				case Keyboard.NUMPAD_ADD:
					mainCamera.ssaoAngular.intensity += (event.shiftKey) ? 0.01 : 0.05;
					printMessage("SSAO intensity : " + mainCamera.ssaoAngular.intensity.toFixed(2));
					break;
				case Keyboard.MINUS:
				case Keyboard.NUMPAD_SUBTRACT:
					mainCamera.ssaoAngular.intensity -= (event.shiftKey) ? 0.01 : 0.05;
					mainCamera.ssaoAngular.intensity = mainCamera.ssaoAngular.intensity <= 0 ? 0 : mainCamera.ssaoAngular.intensity;
					printMessage("SSAO intensity : " + mainCamera.ssaoAngular.intensity.toFixed(2));
					break;
				case Keyboard.PAGE_UP:
					mainCamera.ssaoAngular.secondPassAmount += (event.shiftKey) ? 0.005 : 0.02;
					printMessage("Second pass amount : " + mainCamera.ssaoAngular.secondPassAmount.toFixed(2));
					break;
				case Keyboard.PAGE_DOWN:
					mainCamera.ssaoAngular.secondPassAmount -= (event.shiftKey) ? 0.005 : 0.02;
					mainCamera.ssaoAngular.secondPassAmount = mainCamera.ssaoAngular.secondPassAmount <= 0 ? 0 : mainCamera.ssaoAngular.secondPassAmount;
					printMessage("Second pass amount : " + mainCamera.ssaoAngular.secondPassAmount.toFixed(2));
					break;
				case  Keyboard.NUMBER_0:
				case  Keyboard.NUMPAD_0:
					mainCamera.ssaoAngular.occludingRadius += (event.shiftKey) ? 0.01 : 0.1;
					printMessage("SSAO first pass occluding radius : " + mainCamera.ssaoAngular.occludingRadius.toFixed(2));
					break;
				case  Keyboard.NUMBER_9:
				case  Keyboard.NUMPAD_9:
					mainCamera.ssaoAngular.occludingRadius -= (event.shiftKey) ? 0.01 : 0.1;
					mainCamera.ssaoAngular.occludingRadius = mainCamera.ssaoAngular.occludingRadius <= 0.3 ? 0.3 : mainCamera.ssaoAngular.occludingRadius;
					printMessage("SSAO first pass occluding radius : " + mainCamera.ssaoAngular.occludingRadius.toFixed(2));
					break;
				case Keyboard.HOME:
					mainCamera.ssaoAngular.secondPassOccludingRadius += (event.shiftKey) ? 0.01 : 0.05;
					printMessage("Second pass occluding radius : " + mainCamera.ssaoAngular.secondPassOccludingRadius.toFixed(2));
					break;
				case Keyboard.END:
					mainCamera.ssaoAngular.secondPassOccludingRadius -= (event.shiftKey) ? 0.01 : 0.05;
					mainCamera.ssaoAngular.secondPassOccludingRadius = mainCamera.ssaoAngular.secondPassOccludingRadius <= 0.3 ? 0.3 : mainCamera.ssaoAngular.secondPassOccludingRadius;
					printMessage("Second pass occluding radius : " + mainCamera.ssaoAngular.secondPassOccludingRadius.toFixed(2));
					break;
				case Keyboard.NUMPAD_MULTIPLY:
					mainCamera.ssaoAngular.angleThreshold += (event.shiftKey) ? 0.001 : 0.01;
					printMessage("SSAO angle bias : " + mainCamera.ssaoAngular.angleThreshold.toFixed(3));
					break;
				case Keyboard.NUMPAD_DIVIDE:
					mainCamera.ssaoAngular.angleThreshold -= (event.shiftKey) ? 0.001 : 0.01;
					printMessage("SSAO angle bias : " + mainCamera.ssaoAngular.angleThreshold.toFixed(3));
					break;
				case Keyboard.PERIOD:
					mainCamera.ssaoAngular.maxDistance += (event.shiftKey) ? 0.01 : 0.1;
					printMessage("SSAO max distance : " + mainCamera.ssaoAngular.maxDistance.toFixed(2));
					break;
				case Keyboard.COMMA:
					mainCamera.ssaoAngular.maxDistance -= (event.shiftKey) ? 0.01 : 0.1;
					printMessage("SSAO max distance : " + mainCamera.ssaoAngular.maxDistance.toFixed(2));
					break;
				case Keyboard.M:
					mainCamera.ssaoAngular.falloff += (event.shiftKey) ? 0.01 : 0.1;
					printMessage("SSAO distance falloff : " + mainCamera.ssaoAngular.falloff.toFixed(2));
					break;
				case Keyboard.N:
					mainCamera.ssaoAngular.falloff -= (event.shiftKey) ? 0.01 : 0.1;
					printMessage("SSAO distance falloff : " + mainCamera.ssaoAngular.falloff.toFixed(2));
					break;
				case Keyboard.U:
					if (mainCamera.effectMode == Camera3D.MODE_COLOR || mainCamera.effectMode == Camera3D.MODE_SSAO_COLOR) {
						ssaoVisible = !ssaoVisible;
						mainCamera.effectMode = (ssaoVisible ? Camera3D.MODE_SSAO_COLOR : Camera3D.MODE_COLOR);
						printMessage("SSAO " + (ssaoVisible ? "enabled" : "disabled"));
					}
					break;
				case Keyboard.O:
					mainCamera.ssaoAngular.useSecondPass = !mainCamera.ssaoAngular.useSecondPass;
					printMessage("SSAO second pass " + (mainCamera.ssaoAngular.useSecondPass ? "enabled" : "disabled"));
					break;
				case Keyboard.I:
					dirLight.shadow = (dirLight.shadow == shadow) ? null : shadow;
					printMessage("Shadows " + (dirLight.shadow != null ? "enabled" : "disabled"));
					break;
				case Keyboard.B:
					mainCamera.blurEnabled = !mainCamera.blurEnabled;
					printMessage("SSAO blur " + (mainCamera.blurEnabled ? "enabled" : "disabled"));
					break;
			}
		}

		override protected function onKeyUp(event:KeyboardEvent):void {
			super.onKeyUp(event);
			if (event.keyCode == Keyboard.R) {
				_animationRewind = false;
				animation.freeze();
			}
		}

		private function printMessage(text:String):void {
			var color:uint = (mainCamera.effectMode == Camera3D.MODE_COLOR || mainCamera.effectMode == Camera3D.MODE_SSAO_COLOR || mainCamera.effectMode == Camera3D.MODE_NORMALS) ? 0xFFFFFF : 0x0;

			displayText.defaultTextFormat = new TextFormat("Tahoma", 15, color);
			displayText.text = text;
			displayText.x = (stage.stageWidth - displayText.textWidth) >> 1;
		}

		private var animationStartTime:int = -1;

		override protected function onEnterFrame(e:Event):void {
			if (animation.root is AnimationClip) {
				if (animationStartTime == -1) {
					// check if stopped
					if ((_animationDirection && AnimationClip(animation.root).time >= AnimationClip(animation.root).length) || (!_animationDirection && AnimationClip(animation.root).time <= 0)) {
						animationStartTime = getTimer() + 3000;
					}
				}
				AnimationClip(animation.root).speed = (_animationRewind || !_animationDirection) ? -0.6 : 0.3;
				if (animationStartTime != -1 && animationStartTime <= getTimer()) {
					animationStartTime = -1;
					_animationDirection = !_animationDirection;
				}
			}
			if (_animated || _animationRewind) animation.update();
			super.onEnterFrame(e);
		}

		override protected function onResize(event:Event = null):void {
			super.onResize(event);
			printMessage(displayText.text);
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
			beginFill(0x000000, .6);
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
