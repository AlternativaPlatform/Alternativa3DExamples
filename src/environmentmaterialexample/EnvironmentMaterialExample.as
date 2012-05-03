/**
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * If it is not possible or desirable to put the notice in a particular file, then You may include the notice in a location (such as a LICENSE file in a relevant directory) where a recipient would be likely to look for such a notice.
 * You may add additional accurate notices of copyright ownership.
 *
 * It is desirable to notify that Covered Software was "Powered by AlternativaPlatform" with link to http://www.alternativaplatform.com/ 
 * */

package environmentmaterialexample {
	
	import alternativa.engine3d.controllers.SimpleObjectController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.View;
	import alternativa.engine3d.materials.EnvironmentMaterial;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.resources.BitmapCubeTextureResource;
	import alternativa.engine3d.resources.BitmapTextureResource;
	
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	/**
	 * EnvironmentMaterial usage example.
	 * Пример работы с EnvironmentMaterial.
	 */
	public class EnvironmentMaterialExample extends Sprite {
		
		[Embed(source="diffuse.jpg")] private static const EmbedDiffuse:Class;
		[Embed(source="normal.jpg")] private static const EmbedNormal:Class;
		[Embed(source="reflection.jpg")] private static const EmbedReflection:Class;
		
		[Embed(source="environment/left.jpg")] private static const EmbedLeft:Class;
		[Embed(source="environment/right.jpg")] private static const EmbedRight:Class;
		[Embed(source="environment/back.jpg")] private static const EmbedBack:Class;
		[Embed(source="environment/front.jpg")] private static const EmbedFront:Class;
		[Embed(source="environment/bottom.jpg")] private static const EmbedBottom:Class;
		[Embed(source="environment/top.jpg")] private static const EmbedTop:Class;
		
		private var rootContainer:Object3D = new Object3D();
		
		private var camera:Camera3D;
		private var controller:SimpleObjectController;
		
		private var stage3D:Stage3D;
		
		public function EnvironmentMaterialExample() {
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
			camera.rotationX = -130*Math.PI/180;
			camera.y = -400;
			camera.z = 350;
			controller = new SimpleObjectController(stage, camera, 200);
			rootContainer.addChild(camera);
			
			// Material
			// Материал
			var material:EnvironmentMaterial = new EnvironmentMaterial();
			material.diffuseMap = new BitmapTextureResource(new EmbedDiffuse().bitmapData);
			material.diffuseMap.upload(stage3D.context3D);
			material.normalMap = new BitmapTextureResource(new EmbedNormal().bitmapData);
			material.normalMap.upload(stage3D.context3D);
			material.reflectionMap = new BitmapTextureResource(new EmbedReflection().bitmapData);
			material.reflectionMap.upload(stage3D.context3D);
			material.environmentMap = new BitmapCubeTextureResource(new EmbedLeft().bitmapData, new EmbedRight().bitmapData, new EmbedBack().bitmapData, new EmbedFront().bitmapData, new EmbedBottom().bitmapData, new EmbedTop().bitmapData)
			material.environmentMap.upload(stage3D.context3D);
			
			// Model
			// Модель
			var box:Box = new Box(350, 350, 350);
			box.geometry.upload(stage3D.context3D);
			box.setMaterialToAllSurfaces(material);
			rootContainer.addChild(box);
			
			// Listeners
			// Подписка на события
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(Event.RESIZE, onResize);
		}
		
		private function onEnterFrame(e:Event):void {
			controller.update();
			camera.render(stage3D);
		}
		
		private function onResize(e:Event = null):void {
			camera.view.width = stage.stageWidth;
			camera.view.height = stage.stageHeight;
		}
		
	}
}
