/**
 * Created with IntelliJ IDEA.
 * User: gaev
 * Date: 17.08.12
 * Time: 17:10
 * To change this template use File | Settings | File Templates.
 */
package lightcountexample {
	import alternativa.engine3d.controllers.SimpleObjectController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Light3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.core.View;
	import alternativa.engine3d.lights.AmbientLight;
	import alternativa.engine3d.lights.DirectionalLight;
	import alternativa.engine3d.lights.OmniLight;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.StandardMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.primitives.GeoSphere;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.resources.ATFTextureResource;
	import alternativa.engine3d.resources.BitmapTextureResource;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DRenderMode;
	import flash.events.Event;

	public class LightCountExample extends Sprite {
		
		[Embed(source="textures/brick_r4.atf", mimeType="application/octet-stream")] private static const textureClass:Class;
		[Embed(source="textures/brick_r4_nrm.atf", mimeType="application/octet-stream")] private static const bumpClass:Class;

		private var stage3D:Stage3D;
		private var scene:Object3D = new Object3D();
		private var camera:Camera3D;
		private var controller:SimpleObjectController;

		private var lights:Vector.<Light3D> = new Vector.<Light3D>;
		private var box:Box;


		public function LightCountExample() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			stage3D = stage.stage3Ds[0];
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, init);
			stage3D.requestContext3D(Context3DRenderMode.AUTO);
		}


		private function init(e:Event):void {
			// Camera and view
			// Создание камеры и вьюпорта
			camera = new Camera3D(10, 10000);
			camera.view = new View(stage.stageWidth, stage.stageHeight);
			camera.view.antiAlias = 4;
			addChild(camera.view);
			addChild(camera.diagram);

			// Initial position
			// Установка начального положения камеры
			camera.rotationX = -100*Math.PI/180;
			camera.y = -800;
			camera.z = 300;
			controller = new SimpleObjectController(stage, camera, 500, 2);
			scene.addChild(camera);

			// Создаём материал
			var diffuse:ATFTextureResource = new ATFTextureResource(new textureClass());
			var bump:ATFTextureResource = new ATFTextureResource(new bumpClass());
			var planeMaterial:StandardMaterial = new StandardMaterial(diffuse, bump);

			// Добавляем Плоскость
			var plane:Plane = new Plane(2000, 2000, 5, 5, false, false, planeMaterial, planeMaterial);
			scene.addChild(plane);

			// Тайлинг
			var uvs:Vector.<Number> = plane.geometry.getAttributeValues(VertexAttributes.TEXCOORDS[0]);
			var s:String;
			for (s in uvs) {
				if (Number(s) % 2 == 0) {
					uvs[s] *= 4
				}
				else if (Number(s) % 2 == 1) {
					uvs[s] *= 4;
				}
			}
			plane.geometry.setAttributeValues(VertexAttributes.TEXCOORDS[0], uvs);

			// Добавляем сферу
			var sphere:GeoSphere = new GeoSphere(200, 5, false, planeMaterial);
			scene.addChild(sphere);
			sphere.z = -70;

			// Добавляем летающий бокс
			box = new Box(140, 140, 400, 5, 5, 5, false, planeMaterial);
			box.x = -350;
			box.z = 100;
			box.y = 300;
			box.userData = 0;
			scene.addChild(box);

			// Добавляем основное освещение
			var ambient:AmbientLight = new AmbientLight(0x333333);
			scene.addChild(ambient);

			var directional:DirectionalLight = new DirectionalLight(0x666666);
			scene.addChild(directional);
			directional.z = 100;
			directional.lookAt(100,100, 0);

			// Генерируем источники света
			for (var i:int = 0; i<10; i++) generateLight();

			// Загружаем ресурсы
			uploadResources(scene, stage3D.context3D);

			// Listeners
			// Подписка на события
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(Event.RESIZE, onResize);
		}

		private function onEnterFrame(e:Event):void {

			// Пробегаемся по источникам света
			for (var i:int = 0; i<lights.length; i++){
				var light:OmniLight = lights[i] as OmniLight;
				light.userData += 1;	// Сипользуем userData в качестве счетчика

				// Немного магии
				var time:Number = int(light.userData)/100;
				var radius:Number = 300 + 100 * Math.sin(i+100);
				var speed:Number = 0.7 + 0.5 * Math.sin(i);
				var zPosition:Number = 100 + 50 * Math.sin(i+200) + 50*Math.sin(time*speed * time/10);

				// Определяем положение
				light.x = radius*Math.sin(time*speed);
				light.y = radius*Math.cos(time*speed);
				light.z = zPosition;
			}

			box.userData += 1;
			var boxTime:Number = int(box.userData)/100;
			// Обновляем позицию летающего бокса
			box.z = 300 + 100*Math.sin(boxTime);

			controller.update();
			camera.render(stage3D)
		}

		private function onResize(e:Event = null):void {
			// Width and height of view
			// Установка ширины и высоты вьюпорта
			camera.view.width = stage.stageWidth;
			camera.view.height = stage.stageHeight;
		}

		private function generateLight():void{
			var light:OmniLight = new OmniLight(0x333333*Math.random(), 150, 170);
			light.intensity = 0.3;
			// Добавляем в источник света маркер
			createPoint(4, light.color, light);
			light.userData = 1000 * Math.random();

			lights.push(light);
			scene.addChild(light);
		}

		public static function createColorTexture(color:uint, alpha:Boolean = false):BitmapTextureResource {
			return new BitmapTextureResource(new BitmapData(1, 1, alpha, color));
		}

		public static function coloredStandardMaterial(color:int = 0x7F7F7F):StandardMaterial {
			var material:StandardMaterial;
			material = new StandardMaterial(createColorTexture(color), createColorTexture(0x7F7FFF));
			return material;
		}

		public static function uploadResources(object:Object3D, context:Context3D):void {
			for each (var res:Resource in object.getResources(true)) {
				res.upload(context);
			}
		}

		public static function createPoint(radius:Number, color:int, target:Object3D = null):Mesh{
			var point:GeoSphere = new GeoSphere(radius, 2, false, new FillMaterial(color));
			if (target) target.addChild(point);
			return point;
		}

	}
}
