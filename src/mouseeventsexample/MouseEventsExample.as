/**
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * If it is not possible or desirable to put the notice in a particular file, then You may include the notice in a location (such as a LICENSE file in a relevant directory) where a recipient would be likely to look for such a notice.
 * You may add additional accurate notices of copyright ownership.
 *
 * It is desirable to notify that Covered Software was "Powered by AlternativaPlatform" with link to http://www.alternativaplatform.com/ 
 * */

package mouseeventsexample {

	import alternativa.engine3d.controllers.SimpleObjectController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.core.View;
	import alternativa.engine3d.core.events.MouseEvent3D;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.resources.BitmapTextureResource;

	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	/**
	 * 3D mouse events demonstration.
	 * Пример работы с событиями мыши.
	 */
	public class MouseEventsExample extends Sprite {
		
		[Embed(source="texture.jpg")] static private const EmbedTexture:Class;
		
		private var scene:Object3D = new Object3D();
		
		private var camera:Camera3D;
		private var controller:SimpleObjectController;
		
		private var stage3D:Stage3D;
		
		public function MouseEventsExample() {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			// Camera and view
			// Создание камеры и вьюпорта
			camera = new Camera3D(1, 10000);
			camera.view = new View(100, 100, false, 0, 0, 4);
			addChild(camera.view);
			addChild(camera.diagram);

			// Initial position
			// Установка начального положения камеры
			camera.rotationX = -160*Math.PI/180;
			camera.y = -500;
			camera.z = 1200;
			controller = new SimpleObjectController(stage, camera, 200);
			scene.addChild(camera);
			
			// Objects
			// Создание объектов
			var box:Mesh = new Box();
			box.name = "Box";
			var texture:BitmapTextureResource = new BitmapTextureResource(new EmbedTexture().bitmapData);
			var material:TextureMaterial = new TextureMaterial(texture);
			box.setMaterialToAllSurfaces(material);
			
			var boxes:Object3D = new Object3D();
			boxes.name = "Boxes";
			boxes.rotationZ = -45*Math.PI/180;
			for (var i:int = 0; i < 5; i++) {
				for (var j:int = 0; j < 5; j++) {
					var object:Object3D = box.clone();
					object.x = i*180 - 360;
					object.y = j*180 - 360;
					object.rotationZ = 45*Math.PI/180;
//					object.addEventListener(MouseEvent3D.CLICK, onClick);
					boxes.addChild(object);
				}
			}
			scene.addChild(boxes);
			
			// 3D mouse events
			// Мышиные события в 3D
			boxes.addEventListener(MouseEvent3D.MOUSE_OVER, onMouseOver);
			boxes.addEventListener(MouseEvent3D.MOUSE_OUT, onMouseOut);
			boxes.addEventListener(MouseEvent3D.CLICK, onClick);
			
			stage3D = stage.stage3Ds[0];
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
			stage3D.requestContext3D();
		}
		
		private function onContextCreate(event:Event):void {
			stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
			var resources:Vector.<Resource> = scene.getResources(true);
			for each (var resource:Resource in resources) {
				resource.upload(stage3D.context3D);
			}
			// Listeners
			// Подписка на события
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		private function onMouseOver(e:MouseEvent3D):void {
			var object:Object3D = e.target as Object3D;
			object.scaleX = 1.2;
			object.scaleY = 1.2;
			object.scaleZ = 1.2;
		}
		
		private function onMouseOut(e:MouseEvent3D):void {
			var object:Object3D = e.target as Object3D;
			object.scaleX = 1;
			object.scaleY = 1;
			object.scaleZ = 1;
		}
		
		private function onClick(e:MouseEvent3D):void {
			var object:Object3D = e.target as Object3D;
			object.rotationZ -= 45*Math.PI/180;
		}
		
		private function onEnterFrame(e:Event):void {
			controller.update();
			camera.render(stage3D);
		}
		
		private function onResize(e:Event = null):void {
			// Width and height of view
			// Установка ширины и высоты вьюпорта
			camera.view.width = stage.stageWidth;
			camera.view.height = stage.stageHeight;
		}

	}
}
