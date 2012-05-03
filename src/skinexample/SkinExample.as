/**
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * If it is not possible or desirable to put the notice in a particular file, then You may include the notice in a location (such as a LICENSE file in a relevant directory) where a recipient would be likely to look for such a notice.
 * You may add additional accurate notices of copyright ownership.
 *
 * It is desirable to notify that Covered Software was "Powered by AlternativaPlatform" with link to http://www.alternativaplatform.com/ 
 * */

package skinexample {
	
	import alternativa.engine3d.controllers.SimpleObjectController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.View;
	import alternativa.engine3d.loaders.Parser3DS;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.LOD;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.resources.BitmapTextureResource;
	
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Matrix3D;
	import flash.ui.Keyboard;
	import alternativa.engine3d.primitives.GeoSphere;
	
	/**
	 * Skin usage example.
	 * Пример работы со Skin.
	 */
	public class SkinExample extends Sprite {
		
		[Embed(source="head.jpg")] private static const EmbedHead:Class;
		[Embed(source="tentacle.jpg")] private static const EmbedTentacle:Class;
		
		private var rootContainer:Object3D = new Object3D();
		
		private var camera:Camera3D;
		private var controller:SimpleObjectController;
		
		private var stage3D:Stage3D;
		
		private var octopus1:Object3D;
		private var octopus2:Object3D;
		
		private var time:Number = 0;
		
		public function SkinExample() {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			stage3D = stage.stage3Ds[0];
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, init);
			stage3D.requestContext3D();
		}
		
		private function init(e:Event):void {
			// Camera and view
			// Создание камеры и вьюпорта
			camera = new Camera3D(10, 100000);
			camera.view = new View(stage.stageWidth, stage.stageHeight);
			addChild(camera.view);
			addChild(camera.diagram);
			
			// Initial position
			// Установка начального положения камеры
			camera.rotationX = -110*Math.PI/180;
			camera.y = -600;
			camera.z = 100;
			controller = new SimpleObjectController(stage, camera, 200);
			rootContainer.addChild(camera);
			
			// Materials
			// Материалы
			var headMaterial:TextureMaterial = new TextureMaterial();
			headMaterial.diffuseMap = new BitmapTextureResource(new EmbedHead().bitmapData);
			headMaterial.diffuseMap.upload(stage3D.context3D);
			var tentacleMaterial:TextureMaterial = new TextureMaterial();
			tentacleMaterial.diffuseMap = new BitmapTextureResource(new EmbedTentacle().bitmapData);
			tentacleMaterial.diffuseMap.upload(stage3D.context3D);
			
			// Models
			// Модели
			
			var i:int;
			var tentacle:Tentacle;
			
			var head:GeoSphere = new GeoSphere(80, 5);
			head.geometry.upload(stage3D.context3D);
			head.setMaterialToAllSurfaces(headMaterial);
			head.rotationZ = -Math.PI/2;
			head.z = 15;
			
			octopus1 = new Object3D();
			octopus1.x = -200;
			octopus1.addChild(head.clone());
			for (i = 0; i < 6; i++) {
				tentacle = new Tentacle(i*Math.PI/3, 60, tentacleMaterial, 1);
				tentacle.geometry.upload(stage3D.context3D);
				octopus1.addChild(tentacle);
			}
			rootContainer.addChild(octopus1);
			
			octopus2 = new Object3D();
			octopus2.x = 200;
			octopus2.addChild(head.clone());
			for (i = 0; i < 6; i++) {
				tentacle = new Tentacle(i*Math.PI/3, 60, tentacleMaterial, 2);
				tentacle.geometry.upload(stage3D.context3D);
				octopus2.addChild(tentacle);
			}
			rootContainer.addChild(octopus2);
			
			// Listeners
			// Подписка на события
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(Event.RESIZE, onResize);
		}
		
		private function onEnterFrame(e:Event):void {
			var i:int;
			var tentacle:Tentacle;
			
			var num:int = octopus1.numChildren;
			for (i = 0; i < num; i++) {
				tentacle = octopus1.getChildAt(i) as Tentacle;
				if (tentacle != null) tentacle.update(time);
			}
			
			num = octopus2.numChildren;
			for (i = 0; i < num; i++) {
				tentacle = octopus2.getChildAt(i) as Tentacle;
				if (tentacle != null) tentacle.update(time);
			}
			
			time += 0.05;
			controller.update();
			camera.render(stage3D);
		}
		
		private function onResize(e:Event = null):void {
			camera.view.width = stage.stageWidth;
			camera.view.height = stage.stageHeight;
		}
		
	}
}
