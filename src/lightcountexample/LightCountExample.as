/**
 * Created with IntelliJ IDEA.
 * User: gaev
 * Date: 17.08.12
 * Time: 17:10
 * To change this template use File | Settings | File Templates.
 */
package lightcountexample {
import alternativa.engine3d.controllers.SimpleObjectController;
import alternativa.engine3d.core.Camera3D;
import alternativa.engine3d.core.Light3D;
import alternativa.engine3d.core.Object3D;
import alternativa.engine3d.core.Resource;
import alternativa.engine3d.core.VertexAttributes;
import alternativa.engine3d.core.View;
import alternativa.engine3d.lights.AmbientLight;
import alternativa.engine3d.lights.DirectionalLight;
import alternativa.engine3d.lights.OmniLight;
import alternativa.engine3d.materials.FillMaterial;
import alternativa.engine3d.materials.Material;
import alternativa.engine3d.materials.StandardMaterial;
import alternativa.engine3d.objects.Mesh;
import alternativa.engine3d.primitives.Box;
import alternativa.engine3d.primitives.GeoSphere;
import alternativa.engine3d.primitives.Plane;
import alternativa.engine3d.resources.ATFTextureResource;
import alternativa.engine3d.resources.BitmapTextureResource;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.Stage3D;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.display3D.Context3D;
import flash.display3D.Context3DRenderMode;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Matrix3D;

public class LightCountExample extends Sprite {

    [Embed(source="textures/brick_r4.atf", mimeType="application/octet-stream")]
    private static const textureClass:Class;
    [Embed(source="textures/brick_r4_nrm.atf", mimeType="application/octet-stream")]
    private static const bumpClass:Class;

    [Embed(source="textures/609-normal.jpg")]
    private static const wallNormalsClass:Class;

    private var stage3D:Stage3D;
    private var scene:Object3D = new Object3D();
    private var camera:Camera3D;
    private var controller:SimpleObjectController;

    private var lights:Vector.<Light3D> = new Vector.<Light3D>;
    private var box:Box;


    public function LightCountExample() {
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
        camera.view = new View(stage.stageWidth, stage.stageHeight, false, 0x401050);
        camera.view.antiAlias = 4;
        addChild(camera.view);
        addChild(camera.diagram);

        // Initial position
        // Установка начального положения камеры
        camera.matrix = new Matrix3D(Vector.<Number>([0.9612616896629333, 0.27563735842704773, 0, 0, 0.12940390408039093, -0.4512850344181061, -0.882947564125061, 0, -0.2433733344078064, 0.8487436771392822, -0.4694715738296509, 0, 174.58055114746094, -648.4170532226563, 444.10369873046875, 1
        ]));
        controller = new SimpleObjectController(stage, camera, 500, 2);
        scene.addChild(camera);

        // Создаём материал
        var diffuse:ATFTextureResource = new ATFTextureResource(new textureClass());
        var bump:ATFTextureResource = new ATFTextureResource(new bumpClass());
//			var planeMaterial:StandardMaterial = new StandardMaterial(diffuse, bump);
        var planeMaterial:StandardMaterial = coloredStandardMaterial(0xd04ea4);
        planeMaterial.normalMap = new BitmapTextureResource((new wallNormalsClass()).bitmapData);
        planeMaterial.glossiness = 20;
        planeMaterial.specularPower = .5;

        // Добавляем Плоскость
        var plane:Plane = new Plane(2000, 2000, 5, 5, false, false, planeMaterial, planeMaterial);
        scene.addChild(plane);

        // Тайлинг
        var uvs:Vector.<Number> = plane.geometry.getAttributeValues(VertexAttributes.TEXCOORDS[0]);
        var s:String;
        for (s in uvs) {
            if (Number(s) % 2 == 0) {
                uvs[s] *= 8
            }
            else if (Number(s) % 2 == 1) {
                uvs[s] *= 8;
            }
        }
        plane.geometry.setAttributeValues(VertexAttributes.TEXCOORDS[0], uvs);

        // Добавляем сферу
        var sphere:GeoSphere = new GeoSphere(200, 5, false, planeMaterial);

        uvs = sphere.geometry.getAttributeValues(VertexAttributes.TEXCOORDS[0]);
        for (s in uvs) {
            if (Number(s) % 2 == 0) {
                uvs[s] *= 4
            }
            else if (Number(s) % 2 == 1) {
                uvs[s] *= 4;
            }
        }
        sphere.geometry.setAttributeValues(VertexAttributes.TEXCOORDS[0], uvs);
        scene.addChild(sphere);
        sphere.z = -70;

        // Добавляем летающий бокс
        box = new Box(140, 140, 400, 5, 5, 5, false, planeMaterial);
        box.x = -350;
        box.z = 100;
        box.y = 300;
        box.rotationY = Math.PI / 5;
        box.userData = 0;
        scene.addChild(box);

        // Добавляем основное освещение
        var ambient:AmbientLight = new AmbientLight(0x303394);
        ambient.intensity = .5;
        scene.addChild(ambient);

        var directional:DirectionalLight = new DirectionalLight(0x666666);
        scene.addChild(directional);
        directional.z = 100;
        directional.lookAt(100, 100, 0);

        // Генерируем источники света
        for (var i:int = 0; i < 30; i++)
            lights.push(generateLight(100, getRandomColor(50)));
        var light:OmniLight;
        light = generateLight(400, 0xf0a030);
        light.x = -100;
        light.z = 200;
        light = generateLight(400, 0xf030a0);
        light.x = 70;
        light.z = 220;
        light.y = 30;


        // Загружаем ресурсы
        uploadResources(scene, stage3D.context3D);

        // Listeners
        // Подписка на события
        stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        stage.addEventListener(Event.RESIZE, onResize);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);

    }

    private function onEnterFrame(e:Event):void {

        // Пробегаемся по источникам света
        for (var i:int = 0; i < lights.length; i++) {
            var light:OmniLight = lights[i] as OmniLight;
            light.userData += 1;	// Сипользуем userData в качестве счетчика

            // Немного магии
            var time:Number = int(light.userData) / 100;
            var radius:Number = 300 + 100 * Math.sin(i + 100);
            var speed:Number = 0.7 + 1 * Math.sin(i);
            var zPosition:Number = 100 + 50 * Math.sin(i + 200) + 50 * Math.sin(time * speed * time / 10);

            // Определяем положение
            light.x = radius * Math.sin(time * speed);
            light.y = radius * Math.cos(time * speed);
            light.z = zPosition;
        }

        box.userData += 1;
        var boxTime:Number = int(box.userData) / 100;
        // Обновляем позицию летающего бокса
        box.z = 300 + 100 * Math.sin(boxTime);

        controller.update();
        camera.render(stage3D)
    }

    private function onResize(e:Event = null):void {
        // Width and height of view
        // Установка ширины и высоты вьюпорта
        camera.view.width = stage.stageWidth;
        camera.view.height = stage.stageHeight;
    }

    private function generateLight(size:int, color:uint):OmniLight {
        var light:OmniLight = new OmniLight(color, size, size * 1.5);
        light.intensity = 0.3;
        // Добавляем в источник света маркер
        createPoint(size / 20, light.color, light);
        light.userData = 1000 * Math.random();
        scene.addChild(light);
        return light;
    }

    public static function createColorTexture(color:uint, alpha:Boolean = false):BitmapTextureResource {
        return new BitmapTextureResource(new BitmapData(1, 1, alpha, color));
    }

    public static function coloredStandardMaterial(color:int = 0x7F7F7F):StandardMaterial {
        var material:StandardMaterial;
        material = new StandardMaterial(createColorTexture(color), createColorTexture(0x7F7FFF));
        return material;
    }

    public static function uploadResources(object:Object3D, context:Context3D):void {
        for each (var res:Resource in object.getResources(true)) {
            res.upload(context);
        }
    }

    public static function getRandomColor(threshold:int = 0):uint {
        var red = threshold + Math.random() * (255 - threshold) << 16;
        var green = threshold + Math.random() * (255 - threshold) << 8;
        var blue = threshold + Math.random() * (255 - threshold) ;
        return red + green + blue;
    }

    public static function createPoint(radius:Number, color:int, target:Object3D = null):Mesh {
        var point:GeoSphere = new GeoSphere(radius, 2, false, new FillMaterial(color));
        if (target) target.addChild(point);
        return point;
    }

    private function onKey(event:KeyboardEvent):void {
        trace(camera.matrix.rawData)
    }
}
}
