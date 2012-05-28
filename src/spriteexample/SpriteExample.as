/**
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * If it is not possible or desirable to put the notice in a particular file, then You may include the notice in a location (such as a LICENSE file in a relevant directory) where a recipient would be likely to look for such a notice.
 * You may add additional accurate notices of copyright ownership.
 *
 * It is desirable to notify that Covered Software was "Powered by AlternativaPlatform" with link to http://www.alternativaplatform.com/ 
 * */

package spriteexample {

	import alternativa.engine3d.controllers.SimpleObjectController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.core.View;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Sprite3D;
	import alternativa.engine3d.resources.BitmapTextureResource;

	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	/**
	 * Regular sprites.
	 * Пример использования спрайтов.
	 */
	public class SpriteExample extends Sprite {
		
		[Embed(source="logo.png")] static private const EmbedTexture:Class;
		
		private var rootContainer:Object3D = new Object3D();
		
		private var camera:Camera3D;
		private var controller:SimpleObjectController;
		
		private var sprite:Sprite3D;
		
		private var stage3D:Stage3D;
		
		public function SpriteExample() {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 30;
			
			// Camera and view
			// Создание камеры и вьюпорта
			camera = new Camera3D(1, 1000);
			camera.view = new View(stage.stageWidth, stage.stageHeight);
			addChild(camera.view);
			addChild(camera.diagram);
			
			// Initial position
			// Установка начального положения камеры
			camera.rotationX = -90*Math.PI/180;
			camera.y = -100;
			controller = new SimpleObjectController(stage, camera, 200);
			rootContainer.addChild(camera);
						
			var material:TextureMaterial = new TextureMaterial(new BitmapTextureResource(new EmbedTexture().bitmapData));
			
			// Creation of sprite
			// Создание спрайта
			sprite = new Sprite3D(100, 100, material);

			rootContainer.addChild(sprite);
			
			stage3D = stage.stage3Ds[0];
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
			stage3D.requestContext3D();
		}
		
		private function onContextCreate(e:Event):void {
			for each (var resource:Resource in rootContainer.getResources(true)) {
				resource.upload(stage3D.context3D);
			}
			
			// Listeners
			// Подписка на события
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
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
