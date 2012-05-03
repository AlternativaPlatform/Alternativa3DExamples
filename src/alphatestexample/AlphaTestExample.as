/**
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * If it is not possible or desirable to put the notice in a particular file, then You may include the notice in a location (such as a LICENSE file in a relevant directory) where a recipient would be likely to look for such a notice.
 * You may add additional accurate notices of copyright ownership.
 *
 * It is desirable to notify that Covered Software was "Powered by AlternativaPlatform" with link to http://www.alternativaplatform.com/ 
 * */

package alphatestexample {
	
	import alternativa.engine3d.controllers.SimpleObjectController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.View;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.resources.BitmapTextureResource;
	
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	/**
	 * Alpha-test usage example.
	 * Пример работы с alpha-test.
	 */
	public class AlphaTestExample extends Sprite {
		
		[Embed(source="diffuse.jpg")] private static const EmbedDiffuse:Class;
		[Embed(source="alpha.jpg")] private static const EmbedAlpha:Class;
		
		private var rootContainer:Object3D = new Object3D();
		
		private var camera:Camera3D;
		private var controller:SimpleObjectController;
		
		private var stage3D:Stage3D;
		
		public function AlphaTestExample() {
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
			
			// Resources
			// Ресурсы
			var diffuse:BitmapTextureResource = new BitmapTextureResource(new EmbedDiffuse().bitmapData);
			var alpha:BitmapTextureResource = new BitmapTextureResource(new EmbedAlpha().bitmapData);
			diffuse.upload(stage3D.context3D);
			alpha.upload(stage3D.context3D);
			
			// Transparent pass only
			// Отрисовка только прозрачных частей
			var material1:TextureMaterial = new TextureMaterial(diffuse, alpha);
			material1.alphaThreshold = 1.1; // 0.9
			material1.transparentPass = true;
			material1.opaquePass = false;
			
			// Opaque pass only
			// Отрисовка только непрозрачных частей
			var material2:TextureMaterial = new TextureMaterial(diffuse, alpha);
			material2.alphaThreshold = 0.5;
			material2.transparentPass = false;
			material2.opaquePass = true;
			
			// Transparent and opaque passes
			// Отрисовка прозрачных и непрозрачных частей в отдельные проходы
			var material3:TextureMaterial = new TextureMaterial(diffuse, alpha);
			material3.alphaThreshold = 0.9;
			material3.transparentPass = true;
			material3.opaquePass = true;
			
			// Models
			// Модели
			
			var p:Plane;
			var plane:Plane = new Plane(230, 230, 230);
			plane.geometry.upload(stage3D.context3D);
			
			var branch1:Object3D = new Object3D();
			branch1.x = -250;
			rootContainer.addChild(branch1);
			p = plane.clone() as Plane;
			p.setMaterialToAllSurfaces(material1);
			branch1.addChild(p);
			p = plane.clone() as Plane;
			p.rotationX = -Math.PI/2;
			p.setMaterialToAllSurfaces(material1);
			branch1.addChild(p);
			p = plane.clone() as Plane;
			p.rotationY = -Math.PI/2;
			p.setMaterialToAllSurfaces(material1);
			branch1.addChild(p);
			
			var branch2:Object3D = new Object3D();
			branch2.rotationZ = Math.PI/4;
			rootContainer.addChild(branch2);
			p = plane.clone() as Plane;
			p.setMaterialToAllSurfaces(material2);
			branch2.addChild(p);
			p = plane.clone() as Plane;
			p.rotationX = -Math.PI/2;
			p.setMaterialToAllSurfaces(material2);
			branch2.addChild(p);
			p = plane.clone() as Plane;
			p.rotationY = -Math.PI/2;
			p.setMaterialToAllSurfaces(material2);
			branch2.addChild(p);
			
			var branch3:Object3D = new Object3D();
			branch3.x = 250;
			rootContainer.addChild(branch3);
			p = plane.clone() as Plane;
			p.setMaterialToAllSurfaces(material3);
			branch3.addChild(p);
			p = plane.clone() as Plane;
			p.rotationX = -Math.PI/2;
			p.setMaterialToAllSurfaces(material3);
			branch3.addChild(p);
			p = plane.clone() as Plane;
			p.rotationY = -Math.PI/2;
			p.setMaterialToAllSurfaces(material3);
			branch3.addChild(p);
			
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
