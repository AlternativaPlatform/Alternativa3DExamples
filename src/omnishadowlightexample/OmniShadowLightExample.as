/**
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * If it is not possible or desirable to put the notice in a particular file, then You may include the notice in a location (such as a LICENSE file in a relevant directory) where a recipient would be likely to look for such a notice.
 * You may add additional accurate notices of copyright ownership.
 *
 * It is desirable to notify that Covered Software was "Powered by AlternativaPlatform" with link to http://www.alternativaplatform.com/
 */
package omnishadowlightexample {

	import alternativa.engine3d.controllers.SimpleObjectController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.core.View;
	import alternativa.engine3d.lights.AmbientLight;
	import alternativa.engine3d.lights.OmniLight;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.StandardMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.primitives.GeoSphere;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.shadows.OmniLightShadow;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DRenderMode;
	import flash.events.Event;

	public class OmniShadowLightExample extends Sprite  {

		private var stage3D:Stage3D;
		private var scene:Object3D = new Object3D();
		private var camera:Camera3D;
		private var controller:SimpleObjectController;
		private var time:Number = 0;

		private var flyingBox:Box;
		private var omniLight:OmniLight;
        private var offset:Number = 200;

		public function OmniShadowLightExample() {
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
			camera.y = -900;
			camera.z = 360;
			controller = new SimpleObjectController(stage, camera, 500, 2);
			scene.addChild(camera);

//			// Создаём материалы
			var material:StandardMaterial = coloredStandardMaterial(0xEECCEE);
            material.glossiness = 0;
            material.specularPower = 0;
			var material2:Material = coloredStandardMaterial(0xf070a0);
			var material3:Material = coloredStandardMaterial(0xa0a0d0);

			// Сцена
			var box:Box;
			box = new Box(1300, 1300, 1000, 1, 1, 1, true, material);
			box.x = 0;
			box.z = 500;
			box.y = 0;
			scene.addChild(box);

			// Сваи
			var balk1:Box = new Box(40, 40, 1000);
			balk1.geometry.upload(stage3D.context3D);
			balk1.setMaterialToAllSurfaces(material);
			balk1.x = -260;
			balk1.y = 260;
			balk1.z = 0;
			scene.addChild(balk1);
			var balk2:Box = balk1.clone() as Box;
			balk2.x = 260;
			scene.addChild(balk2);
			var balk3:Box = balk2.clone() as Box;
			balk3.y = -260;
			scene.addChild(balk3);
			var balk4:Box = balk3.clone() as Box;
			balk4.x = -260;
			scene.addChild(balk4);

			// Несколько объектов
			var box1:Box = new Box(200, 250, 200, 1, 1, 1, false, material2);
			box1.x = -440;
			box1.z = 20;
			box1.rotationX = Math.PI/3;
			box1.rotationY = Math.PI/3;
			box1.rotationZ = Math.PI/5;
			scene.addChild(box1);

			var box2:Box = new Box(300, 150, 70, 1, 1, 1, false, material2);
			box2.x = +280;
			box2.z = 150;
			box2.rotationX = Math.PI/3;
			box2.rotationY = Math.PI/3;
			box2.rotationZ = Math.PI/2;
			scene.addChild(box2);

            var box4:Box = new Box(300, 350, 200, 1, 1, 1, false, material2);
            box4.z = -20;
            box4.y = 60;
            box4.rotationX = Math.PI/3;
            box4.rotationY = Math.PI/3;
            box4.rotationZ = Math.PI/5;
            scene.addChild(box4);

			// Добавляем сферу
			var sphere:GeoSphere = new GeoSphere(35, 5, false, material2);
			scene.addChild(sphere);
			sphere.z = 35;
			sphere.x = 280;

			var sphere2:GeoSphere = new GeoSphere(135, 5, false, material2);
			scene.addChild(sphere2);
			sphere2.z = 400;
			sphere2.x = 30;
			sphere2.y = 280;

			var sphere3:GeoSphere = new GeoSphere(20, 5, false, material3);
			scene.addChild(sphere3);
			sphere3.z = 50;
			sphere3.x = -80;
			sphere3.y = 20;


			// Добавляем летающий бокс
			flyingBox = new Box(130, 240, 120, 1, 1, 1, false, material2);
			flyingBox.x = -250;
			flyingBox.z = 300;
			flyingBox.y = 80;
			flyingBox.rotationX = Math.PI/5;
			flyingBox.rotationY = Math.PI/3;
			flyingBox.userData = 0;
			scene.addChild(flyingBox);

			// Добавляем основное освещение
			var ambient:AmbientLight = new AmbientLight(0x9060d0);
            ambient.intensity = .3;
			scene.addChild(ambient);

			// Инициализируем источник света с тенью
			omniLight = new OmniLight(0x999999, 1000, 2500);
			omniLight.z = 150;
			createPoint(10, 0xffffff, omniLight);
			scene.addChild(omniLight);

			var shadow:OmniLightShadow = new OmniLightShadow(512, 1);
			omniLight.shadow = shadow;
			shadow.addCaster(balk1);
			shadow.addCaster(balk2);
			shadow.addCaster(balk3);
			shadow.addCaster(balk4);
			shadow.addCaster(box1);
			shadow.addCaster(box2);
			shadow.addCaster(sphere);
			shadow.addCaster(sphere2);
			shadow.addCaster(sphere3);
			shadow.addCaster(flyingBox);

			// Загружаем ресурсы
			uploadResources(scene, stage3D.context3D);

			// Listeners
			// Подписка на события
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(Event.RESIZE, onResize);
		}

		private function onEnterFrame(e:Event):void {
			time+=.02;
//            omniLight.z =  100 + Math.abs(Math.sin(time * 2)) * 300;
            omniLight.x =  Math.sin(time) * 350;
            omniLight.z =  200 + Math.sin(time) * 150;
            omniLight.y =  Math.cos(time / 2) * 250;

			flyingBox.rotationZ+=.1;
			flyingBox.rotationX+=.05;

			controller.update();
			camera.render(stage3D)
		}

		private function onResize(e:Event = null):void {
			// Width and height of view
			// Установка ширины и высоты вьюпорта
			camera.view.width = stage.stageWidth;
			camera.view.height = stage.stageHeight;
		}

		public static function uploadResources(object:Object3D, context:Context3D):void {
			for each (var res:Resource in object.getResources(true)) {
				res.upload(context);
			}
		}

		public static function coloredStandardMaterial(color:int = 0x7F7F7F):StandardMaterial {
			var material:StandardMaterial;
			material = new StandardMaterial(createColorTexture(color), createColorTexture(0x7F7FFF));
			return material;
		}

		public static function createColorTexture(color:uint, alpha:Boolean = false):BitmapTextureResource {
			return new BitmapTextureResource(new BitmapData(1, 1, alpha, color));
		}

		public static function createPoint(radius:Number, color:int, target:Object3D = null):Mesh{
			var point:GeoSphere = new GeoSphere(radius, 2, false, new FillMaterial(color));
			if (target) target.addChild(point);
			return point;
		}

	}
}
