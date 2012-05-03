/**
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * If it is not possible or desirable to put the notice in a particular file, then You may include the notice in a location (such as a LICENSE file in a relevant directory) where a recipient would be likely to look for such a notice.
 * You may add additional accurate notices of copyright ownership.
 *
 * It is desirable to notify that Covered Software was "Powered by AlternativaPlatform" with link to http://www.alternativaplatform.com/ 
 * */

package parsersexample {

	import alternativa.engine3d.controllers.SimpleObjectController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.core.View;
	import alternativa.engine3d.loaders.Parser3DS;
	import alternativa.engine3d.loaders.ParserA3D;
	import alternativa.engine3d.loaders.ParserCollada;
	import alternativa.engine3d.loaders.ParserMaterial;
	import alternativa.engine3d.loaders.TexturesLoader;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.resources.ExternalTextureResource;
	import alternativa.engine3d.resources.Geometry;

	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;

	/**
	 * External model parsing. 
	 * Пример работы с парсерами.
	 */
	public class ParsersExample extends Sprite {
		
		private var scene:Object3D = new Object3D();
		
		private var camera:Camera3D;
		private var controller:SimpleObjectController;
		
		private var stage3D:Stage3D;
		
		public function ParsersExample() {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			// Camera and view
			// Создание камеры и вьюпорта
			camera = new Camera3D(1, 1000);
			camera.view = new View(stage.stageWidth, stage.stageHeight, false, 0, 0, 4);
			addChild(camera.view);
			addChild(camera.diagram);
			
			// Initial position
			// Установка начального положения камеры
			camera.rotationX = -130*Math.PI/180;
			camera.y = -30;
			camera.z = 35;
			controller = new SimpleObjectController(stage, camera, 50);
			scene.addChild(camera);
			
			stage3D = stage.stage3Ds[0];
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
			stage3D.requestContext3D();
		}

		private function onContextCreate(e:Event):void {
			stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
			
			// Загрузка моделей
			// Models loading
			
			var loaderA3D:URLLoader = new URLLoader();
			loaderA3D.dataFormat = URLLoaderDataFormat.BINARY;
			loaderA3D.load(new URLRequest("parsersexample/model.A3D"));
			loaderA3D.addEventListener(Event.COMPLETE, onA3DLoad);

			var loaderCollada:URLLoader = new URLLoader();
			loaderCollada.dataFormat = URLLoaderDataFormat.TEXT;
			loaderCollada.load(new URLRequest("parsersexample/model.DAE"));
			loaderCollada.addEventListener(Event.COMPLETE, onColladaLoad);

			var loader3DS:URLLoader = new URLLoader();
			loader3DS.dataFormat = URLLoaderDataFormat.BINARY;
			loader3DS.load(new URLRequest("parsersexample/model.3DS"));
			loader3DS.addEventListener(Event.COMPLETE, on3DSLoad);

			// Listeners
			// Подписка на события
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		private function onA3DLoad(e:Event):void {
			// Model parsing
			// Парсинг модели
			var parser:ParserA3D = new ParserA3D();
			parser.parse((e.target as URLLoader).data);
			trace(parser.objects);
			var mesh:Mesh;
			for each (var object:Object3D in parser.objects) {
				if (object.name == "Cylinder01") {
					mesh = object as Mesh;
					break;
				}
			}
			mesh.x -= 10;
			scene.addChild(mesh);
			uploadResources(mesh.getResources(false, Geometry));
			
			// Setup materials
			// Собираем текстуры и назначаем материалы
			var textures:Vector.<ExternalTextureResource> = new Vector.<ExternalTextureResource>();
			for (var i:int = 0; i < mesh.numSurfaces; i++) {
				var surface:Surface = mesh.getSurface(i);
				var material:ParserMaterial = surface.material as ParserMaterial;
				if (material != null) {
					var diffuse:ExternalTextureResource = material.textures["diffuse"];
					if (diffuse != null) {
						diffuse.url = "parsersexample/" + diffuse.url;
						textures.push(diffuse);
						surface.material = new TextureMaterial(diffuse);
					}
				}
			}
			
			// Loading of textures
			// Загрузка текстур
			var texturesLoader:TexturesLoader = new TexturesLoader(stage3D.context3D);
			texturesLoader.loadResources(textures);
		}
		
		private function onColladaLoad(e:Event):void {
			// Model parsing
			// Парсинг модели
			var parser:ParserCollada = new ParserCollada();
			parser.parse(XML((e.target as URLLoader).data), "parsersexample/", true);
			trace(parser.objects);
			var mesh:Mesh = parser.getObjectByName("Cylinder01") as Mesh;
			mesh.x = 0;
			scene.addChild(mesh);

			// Загрузка ресурсов
			uploadResources(mesh.getResources(false, Geometry));
			
			// Собираем текстуры и назначаем материалы
			var textures:Vector.<ExternalTextureResource> = new Vector.<ExternalTextureResource>();
			for (var i:int = 0; i < mesh.numSurfaces; i++) {
				var surface:Surface = mesh.getSurface(i);
				var material:ParserMaterial = surface.material as ParserMaterial;
				if (material != null) {
					var diffuse:ExternalTextureResource = material.textures["diffuse"];
					if (diffuse != null) {
						textures.push(diffuse);
						surface.material = new TextureMaterial(diffuse);
					}
				}
			}

			// Loading of textures
			// Загрузка текстур
			var texturesLoader:TexturesLoader = new TexturesLoader(stage3D.context3D);
			texturesLoader.loadResources(textures);
		}

		private function on3DSLoad(e:Event):void {
			// Model parsing
			// Парсинг модели
			var parser:Parser3DS = new Parser3DS();
			parser.parse((e.target as URLLoader).data);
			trace(parser.objects);
			var mesh:Mesh;
			for each (var object:Object3D in parser.objects) {
				if (object.name == "Cylinder01") {
					mesh = object as Mesh;
					break;
				}
			}
			mesh.x = 10;
			scene.addChild(mesh);
			uploadResources(mesh.getResources(false, Geometry));

			// Setup materials
			// Собираем текстуры и назначаем материалы
			var textures:Vector.<ExternalTextureResource> = new Vector.<ExternalTextureResource>();
			for (var i:int = 0; i < mesh.numSurfaces; i++) {
				var surface:Surface = mesh.getSurface(i);
				var material:ParserMaterial = surface.material as ParserMaterial;
				if (material != null) {
					var diffuse:ExternalTextureResource = material.textures["diffuse"];
					if (diffuse != null) {
						diffuse.url = "parsersexample/" + diffuse.url;
						textures.push(diffuse);
						surface.material = new TextureMaterial(diffuse);
					}
				}
			}

			// Loading of textures
			// Загрузка текстур
			var texturesLoader:TexturesLoader = new TexturesLoader(stage3D.context3D);
			texturesLoader.loadResources(textures);
		}

		private function uploadResources(resources:Vector.<Resource>):void {
			for each (var resource:Resource in resources) {
				resource.upload(stage3D.context3D);
			}
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
