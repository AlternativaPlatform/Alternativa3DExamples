/**
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * If it is not possible or desirable to put the notice in a particular file, then You may include the notice in a location (such as a LICENSE file in a relevant directory) where a recipient would be likely to look for such a notice.
 * You may add additional accurate notices of copyright ownership.
 *
 * It is desirable to notify that Covered Software was "Powered by AlternativaPlatform" with link to http://www.alternativaplatform.com/ 
 * */

package demoexample {

	import alternativa.engine3d.animation.AnimationClip;
	import alternativa.engine3d.animation.AnimationController;
	import alternativa.engine3d.animation.AnimationSwitcher;
	import alternativa.engine3d.collisions.EllipsoidCollider;
	import alternativa.engine3d.controllers.SimpleObjectController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.View;
	import alternativa.engine3d.core.events.MouseEvent3D;
	import alternativa.engine3d.loaders.ParserCollada;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.Skin;
	import alternativa.engine3d.primitives.GeoSphere;
	import alternativa.engine3d.resources.BitmapTextureResource;

	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DRenderMode;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;

	/**
	 * Alternativa3D complete demo.
	 * Пример создания демо сцены.
	 */
	public class DemoExample extends Sprite {
		
		[Embed("level.DAE", mimeType="application/octet-stream")] static private const LevelModel:Class;
		[Embed(source="level.jpg")] static private const LevelTexture:Class;
		
		[Embed("character.DAE", mimeType="application/octet-stream")] static private const CharacterModel:Class;
		[Embed(source="character.jpg")] static private const CharacterTexture:Class;
		
		private var stage3D:Stage3D;
		
		private var scene:Object3D = new Object3D();
		private var camera:Camera3D;
		private var controller:SimpleObjectController;
		
		private var level:Mesh;
		private var character:Skin;
		
		private var animationController:AnimationController = new AnimationController();
		private var animationSwitcher:AnimationSwitcher = new AnimationSwitcher();
		private var idle:AnimationClip;
		private var run:AnimationClip;
		
		private var target:Vector3D;
		private var sphere:GeoSphere = new GeoSphere(10, 3, false, new FillMaterial(0xFFFF00, 0.85));
		
		private var collider:EllipsoidCollider = new EllipsoidCollider(50, 50, 90);
		
		private var gravity:Number = 9800;
		private var fallSpeed:Number = 0;
		
		private var lastTime:int;
		
		private var timeScale:Number = 0.7;
		
		public function DemoExample() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			stage3D = stage.stage3Ds[0];
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, init);
			stage3D.requestContext3D(Context3DRenderMode.SOFTWARE);
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
			camera.rotationX = -120*Math.PI/180;
			camera.y = -500;
			camera.z = 250;
			controller = new SimpleObjectController(stage, camera, 500, 2);
			scene.addChild(camera);
			
			sphere.mouseEnabled = false;
			sphere.geometry.upload(stage3D.context3D);
			scene.addChild(sphere);
			
			// Parser of level
			// Парсер уровня
			var levelParser:ParserCollada = new ParserCollada();
			levelParser.parse(XML(new LevelModel()));
			level = levelParser.getObjectByName("level") as Mesh;
			var levelResource:BitmapTextureResource = new BitmapTextureResource(new LevelTexture().bitmapData);
			var levelMaterial:TextureMaterial = new TextureMaterial(levelResource);
			level.setMaterialToAllSurfaces(levelMaterial);
			scene.addChild(level);
			// Upload
			levelResource.upload(stage3D.context3D);
			level.geometry.upload(stage3D.context3D);
			
			// Adding double click listener
			// Подписка уровня на двойной клик
			level.useHandCursor = true;
			level.doubleClickEnabled = true;
			level.addEventListener(MouseEvent3D.DOUBLE_CLICK, onDoubleClick);
			
			// Parser of character
			// Парсер персонажа
			var characterParser:ParserCollada = new ParserCollada();
			characterParser.parse(XML(new CharacterModel()));
			character = characterParser.getObjectByName("character") as Skin;
			var characterResource:BitmapTextureResource = new BitmapTextureResource(new CharacterTexture().bitmapData);
			var characterMaterial:TextureMaterial = new TextureMaterial(characterResource);
			character.setMaterialToAllSurfaces(characterMaterial);
			scene.addChild(character);
			// Upload
			characterResource.upload(stage3D.context3D);
			character.geometry.upload(stage3D.context3D);
			
			character.mouseEnabled = false;
			
			// Character animation
			// Анимация персонажа
			var animation:AnimationClip = characterParser.getAnimationByObject(character);

			// Slice of animation
			// Разбиение анимации
			idle = animation.slice(0, 40/30);
			run = animation.slice(41/30, 61/30);
			
			// Adding 
			// Добавление анимаций
			animationSwitcher.addAnimation(idle);
			animationSwitcher.addAnimation(run);
			
			// Running
			// Запуск анимации
			animationSwitcher.activate(idle, 0.1);
			animationSwitcher.speed = timeScale;
			
			animationController.root = animationSwitcher;
			
			// Listeners
			// Подписка на события
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(Event.RESIZE, onResize);
			
			lastTime = getTimer();
		}
		
		private function onDoubleClick(e:MouseEvent3D):void {
			target = (e.target as Object3D).localToGlobal(new Vector3D(e.localX, e.localY, e.localZ));
		}
		
		private function onEnterFrame(e:Event):void {
			// Time of frame
			// Время кадра
			var time:int = getTimer();
			var deltaTime:Number = timeScale*(time - lastTime)/1000;
			lastTime = time;
			
			var displacement:Vector3D = new Vector3D();
			if (target != null) {
				// Sphere moving
				// Перемещение сферы
				sphere.x += (target.x - sphere.x)*0.3;
				sphere.y += (target.y - sphere.y)*0.3;
				sphere.z += (target.z - sphere.z)*0.3;
				// Direction of character
				// Расчёт направления движения персонажа
				displacement.x = target.x - character.x;
				displacement.y = target.y - character.y;
				if (displacement.length > 15) {
					character.rotationZ = Math.atan2(displacement.x, -displacement.y);
					displacement.scaleBy(deltaTime*600/displacement.length);
					animationSwitcher.activate(run, 0.1);
				} else {
					target = null;
					animationSwitcher.activate(idle, 0.1);
				}
			}
			
			// Fall speed
			// Скорость падения
			fallSpeed -= 0.5*gravity*deltaTime*deltaTime;
			
			var characterCoords:Vector3D = new Vector3D(character.x, character.y, character.z + 90);
			
			// Checking of surface under character
			// Проверка поверхности под персонажем
			var collisionPoint:Vector3D = new Vector3D();
			var collisionPlane:Vector3D = new Vector3D();
			camera.startTimer();
			var onGround:Boolean = collider.getCollision(characterCoords, new Vector3D(0, 0, fallSpeed), collisionPoint, collisionPlane, level);
			if (onGround && collisionPlane.z > 0.5) {
				fallSpeed = 0;
			} else {
				displacement.z = fallSpeed;
			}
			
			// Collision detection
			// Проверка препятствий
			var destination:Vector3D = collider.calculateDestination(characterCoords, displacement, level);
			camera.stopTimer();
			character.x = destination.x;
			character.y = destination.y;
			character.z = destination.z - 90;
			
			animationController.update();
			controller.update();
			camera.render(stage3D)
		}
		
		private function onResize(e:Event = null):void {
			// Width and height of view
			// Установка ширины и высоты вьюпорта
			camera.view.width = stage.stageWidth;
			camera.view.height = stage.stageHeight;
		}
		
	}
}
