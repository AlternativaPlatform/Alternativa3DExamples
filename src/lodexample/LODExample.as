/**
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * If it is not possible or desirable to put the notice in a particular file, then You may include the notice in a location (such as a LICENSE file in a relevant directory) where a recipient would be likely to look for such a notice.
 * You may add additional accurate notices of copyright ownership.
 *
 * It is desirable to notify that Covered Software was "Powered by AlternativaPlatform" with link to http://www.alternativaplatform.com/ 
 * */

package lodexample {
	
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
	
	/**
	 * LOD usage example.
	 * Пример работы с LOD.
	 */
	public class LODExample extends Sprite {
		
		[Embed("model.3ds", mimeType="application/octet-stream")] private static const EmbedModel:Class;
		[Embed(source="texture.jpg")] private static const EmbedTexture:Class;
		
		private var rootContainer:Object3D = new Object3D();
		
		private var camera:Camera3D;
		private var controller:SimpleObjectController;
		
		private var stage3D:Stage3D;
		
		public function LODExample() {
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
			
			// Parsing of model
			// Парсинг модели
			var parser:Parser3DS = new Parser3DS();
			parser.parse(new EmbedModel());
			
			// Texture
			// Установка текстуры
			var material:TextureMaterial = new TextureMaterial();
			material.diffuseMap = new BitmapTextureResource(new EmbedTexture().bitmapData);
			material.diffuseMap.upload(stage3D.context3D);
			
			// Creating of LOD
			// Создание LOD
			var lod:LOD = new LOD();
			
			var mesh0:Mesh = parser.objects[0] as Mesh;
			mesh0.setMaterialToAllSurfaces(material);
			mesh0.geometry.upload(stage3D.context3D);
			mesh0.matrix = new Matrix3D();
            // Set mesh and distance, to which mesh should be shown
            // Укажем меш и дистанцию, до которой он должен отображаться
			lod.addLevel(mesh0, 300);
			
			var mesh1:Mesh = parser.objects[1] as Mesh;
			mesh1.setMaterialToAllSurfaces(material);
			mesh1.geometry.upload(stage3D.context3D);
			mesh1.matrix = new Matrix3D();
			lod.addLevel(mesh1, 500);
			
			var mesh2:Mesh = parser.objects[2] as Mesh;
			mesh2.setMaterialToAllSurfaces(material);
			mesh2.geometry.upload(stage3D.context3D);
			mesh2.matrix = new Matrix3D();
			lod.addLevel(mesh2, 700);
			
			var mesh3:Mesh = parser.objects[3] as Mesh;
			mesh3.setMaterialToAllSurfaces(material);
			mesh3.geometry.upload(stage3D.context3D);
			mesh3.matrix = new Matrix3D();
			lod.addLevel(mesh3, 900);
			
			var mesh4:Mesh = parser.objects[4] as Mesh;
			mesh4.setMaterialToAllSurfaces(material);
			mesh4.geometry.upload(stage3D.context3D);
			mesh4.matrix = new Matrix3D();
			lod.addLevel(mesh4, 100000);
			
			lod.calculateBoundBox();
			rootContainer.addChild(lod);
			
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
