/**
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * If it is not possible or desirable to put the notice in a particular file, then You may include the notice in a location (such as a LICENSE file in a relevant directory) where a recipient would be likely to look for such a notice.
 * You may add additional accurate notices of copyright ownership.
 *
 * It is desirable to notify that Covered Software was "Powered by AlternativaPlatform" with link to http://www.alternativaplatform.com/ 
 * */

package shadowsexample {

	import alternativa.engine3d.controllers.SimpleObjectController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.View;
	import alternativa.engine3d.lights.AmbientLight;
	import alternativa.engine3d.lights.DirectionalLight;
	import alternativa.engine3d.materials.StandardMaterial;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.shadows.DirectionalLightShadow;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	/**
	 * Shadows usage example.
	 * Пример использования теней.
	 */
	public class ShadowsExample extends Sprite {
		
		[Embed(source="bark_diffuse.jpg")] private static const EmbedBarkDiffuse:Class;
		[Embed(source="bark_normal.jpg")] private static const EmbedBarkNormal:Class;
		[Embed(source="branch_diffuse.jpg")] private static const EmbedBranchDiffuse:Class;
		[Embed(source="branch_normal.jpg")] private static const EmbedBranchNormal:Class;
		[Embed(source="branch_opacity.jpg")] private static const EmbedBranchOpacity:Class;
		[Embed(source="grass.jpg")] private static const EmbedGrassDiffuse:Class;
		
		private var rootContainer:Object3D = new Object3D();
		
		private var camera:Camera3D;
		private var controller:SimpleObjectController;
		
		private var stage3D:Stage3D;
		
		private var tree:Object3D;
		private var counter:Number = 0;
		
		public function ShadowsExample() {
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
			camera.z = 350;
			controller = new SimpleObjectController(stage, camera, 200);
			rootContainer.addChild(camera);
			
			// Resources
			// Ресурсы
			var grass_diffuse:BitmapTextureResource = new BitmapTextureResource(new EmbedGrassDiffuse().bitmapData);
			var grass_normal:BitmapTextureResource = new BitmapTextureResource(new BitmapData(1, 1, false, 0x7F7FFF));
			var bark_diffuse:BitmapTextureResource = new BitmapTextureResource(new EmbedBarkDiffuse().bitmapData);
			var bark_normal:BitmapTextureResource = new BitmapTextureResource(new EmbedBarkNormal().bitmapData);
			var branch_diffuse:BitmapTextureResource = new BitmapTextureResource(new EmbedBranchDiffuse().bitmapData);
			var branch_normal:BitmapTextureResource = new BitmapTextureResource(new EmbedBranchNormal().bitmapData);
			var branch_opacity:BitmapTextureResource = new BitmapTextureResource(new EmbedBranchOpacity().bitmapData);
			grass_diffuse.upload(stage3D.context3D);
			grass_normal.upload(stage3D.context3D);
			bark_diffuse.upload(stage3D.context3D);
			bark_normal.upload(stage3D.context3D);
			branch_diffuse.upload(stage3D.context3D);
			branch_normal.upload(stage3D.context3D);
			branch_opacity.upload(stage3D.context3D);
			
			// Materials
			// Материалы
			var grassMaterial:StandardMaterial = new StandardMaterial(grass_diffuse, grass_normal);
			grassMaterial.specularPower = 0.14;
			var barkMaterial:StandardMaterial = new StandardMaterial(bark_diffuse, bark_normal);
			var branchMaterial:StandardMaterial = new StandardMaterial(branch_diffuse, branch_normal, null, null, branch_opacity);
			branchMaterial.specularPower = 0;
			branchMaterial.alphaThreshold = 0.8;
			
			// Models
			// Модели
			
			var grass:Plane = new Plane(900, 900);
			grass.geometry.upload(stage3D.context3D);
			grass.setMaterialToAllSurfaces(grassMaterial);
			rootContainer.addChild(grass);
			
			var platform:Box = new Box(300, 300, 50);
			platform.geometry.upload(stage3D.context3D);
			platform.setMaterialToAllSurfaces(barkMaterial);
			platform.z = 25;
			rootContainer.addChild(platform);
			
			var balk1:Box = new Box(30, 30, 250);
			balk1.geometry.upload(stage3D.context3D);
			balk1.setMaterialToAllSurfaces(barkMaterial);
			balk1.x = -180;
			balk1.y = 180;
			balk1.z = 125;
			rootContainer.addChild(balk1);
			var balk2:Box = balk1.clone() as Box;
			balk2.x = 180;
			rootContainer.addChild(balk2);
			var balk3:Box = balk2.clone() as Box;
			balk3.y = -180;
			rootContainer.addChild(balk3);
			var balk4:Box = balk3.clone() as Box;
			balk4.x = -180;
			rootContainer.addChild(balk4);
			
			tree = new Object3D();
			tree.z = 50;
			var branch:Plane = new Plane(400, 400);
			branch.geometry.upload(stage3D.context3D);
			branch.setMaterialToAllSurfaces(branchMaterial);
			branch.rotationX = Math.PI/2;
			branch.rotationZ = Math.PI/4;
			branch.z = 200;
			tree.addChild(branch);
			branch = branch.clone() as Plane;
			branch.rotationZ += Math.PI/2;
			tree.addChild(branch);
			rootContainer.addChild(tree);
			
			// Light sources
			// Источники света
			var ambientLight:AmbientLight = new AmbientLight(0x333333);
			rootContainer.addChild(ambientLight);
			var directionalLight:DirectionalLight = new DirectionalLight(0xFFFF99);
			directionalLight.lookAt(-0.5, -1, -1);
			rootContainer.addChild(directionalLight);
			
			// Shadow
			// Тень
			var shadow:DirectionalLightShadow = new DirectionalLightShadow(1000, 1000, -500, 500, 512, 2);
			shadow.biasMultiplier = 0.97;
			shadow.addCaster(platform);
			shadow.addCaster(balk1);
			shadow.addCaster(balk2);
			shadow.addCaster(balk3);
			shadow.addCaster(balk4);
			shadow.addCaster(tree);
			directionalLight.shadow = shadow;
			
			//shadow.debug = true;
			
			// Listeners
			// Подписка на события
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(Event.RESIZE, onResize);
		}
		
		private function onEnterFrame(e:Event):void {
			counter += 0.05;
			tree.rotationY = Math.sin(counter)/7;
			controller.update();
			camera.render(stage3D);
		}
		
		private function onResize(e:Event = null):void {
			camera.view.width = stage.stageWidth;
			camera.view.height = stage.stageHeight;
		}
		
	}
}
