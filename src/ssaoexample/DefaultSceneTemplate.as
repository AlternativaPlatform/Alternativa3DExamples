package ssaoexample {

	import alternativa.engine3d.controllers.SimpleObjectController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.View;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.primitives.Plane;

	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	public class DefaultSceneTemplate extends Sprite {

		protected var stage3D:Stage3D;
		protected var resourceManager:ResourceManager;

		protected var scene:Object3D;
		protected var mainCamera:Camera3D;

		protected var controller:SimpleObjectController;

		public function DefaultSceneTemplate() {
			if (stage == null) {
				addEventListener(Event.ADDED_TO_STAGE, init);
			} else {
				init();
			}
		}

		private function init(e:Event = null):void {
			stage.removeEventListener(Event.ADDED_TO_STAGE, init);

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			scene = new Object3D();

			mainCamera = new Camera3D(10, 10000);
			mainCamera.view = new View(stage.stageWidth, stage.stageHeight, false, 0, 1, 4);
			scene.addChild(mainCamera);

			addChild(mainCamera.view);
			addChild(mainCamera.diagram);


			resourceManager = new ResourceManager(scene);

			stage3D = stage.stage3Ds[0];
			if (stage3D.context3D != null) {
				onContext3DCreate();
			} else {
				stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
				stage3D.requestContext3D();
			}
		}

		private function onContext3DCreate(e:Event = null):void {
			resourceManager.context3D = stage3D.context3D;

			initController();
			initScene();

			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(Event.RESIZE, onResize);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			onResize();
		}

		protected function initController():void {
			mainCamera.x = 300;
			mainCamera.y = 70;
			mainCamera.z = 250;
			mainCamera.lookAt(0, 0, 50);
			controller = new SimpleObjectController(stage, mainCamera, 100, 3, 0.7);
		}

		/**
		 * Override this method to perform scene initialization
		 */
		protected function initScene():void {
			var plane:Plane = new Plane(500, 500, 1, 1, true);
			plane.setMaterialToAllSurfaces(new FillMaterial(0x7F7F7F, 0.7));
			scene.addChild(plane);

			var box:Box = new Box();
			box.setMaterialToAllSurfaces(new FillMaterial(0xFF0000));
			box.z = 50;
			scene.addChild(box);
		}

		protected function onEnterFrame(e:Event):void {
			if (controller != null) controller.update();
			mainCamera.render(stage3D);
		}

		protected function onResize(event:Event = null):void {
			mainCamera.view.width = stage.stageWidth;
			mainCamera.view.height = stage.stageHeight;
			mainCamera.render(stage3D);
		}

		protected function onKeyDown(event:KeyboardEvent):void {
			if (event.keyCode == Keyboard.T) {
				trace("mainCamera.matrix = new Matrix3D(Vector.<Number>([" + mainCamera.matrix.rawData + "]))");
			}
		}

		protected function onKeyUp(event:KeyboardEvent):void {
		}

	}
}
