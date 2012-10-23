package particlesdemo {

import alternativa.engine3d.alternativa3d;
import alternativa.engine3d.core.Camera3D;
import alternativa.engine3d.core.Object3D;
import alternativa.engine3d.core.RayIntersectionData;
import alternativa.engine3d.core.Resource;
import alternativa.engine3d.core.View;
import alternativa.engine3d.core.events.MouseEvent3D;
import alternativa.engine3d.effects.ParticleSystem;
import alternativa.engine3d.effects.TextureAtlas;
import alternativa.engine3d.loaders.ParserA3D;
import alternativa.engine3d.loaders.TexturesLoader;
import alternativa.engine3d.materials.FillMaterial;
import alternativa.engine3d.primitives.Box;
import alternativa.engine3d.resources.ATFTextureResource;
import alternativa.engine3d.resources.BitmapTextureResource;
import alternativa.engine3d.resources.ExternalTextureResource;

import flash.display.Sprite;
import flash.display.Stage3D;
import flash.display.StageAlign;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.display3D.Context3D;
import flash.display3D.Context3DRenderMode;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.ui.Keyboard;

import particlesdemo.classes.Fire;
import particlesdemo.classes.FlameThrower;
import particlesdemo.classes.SmokyExplosion;
import particlesdemo.classes.SmokyShot;
import particlesdemo.classes.TankExplosion;

use namespace alternativa3d;

[SWF(backgroundColor="#000000", frameRate="60", width="800", height="600")]
public class ParticlesDemo extends Sprite {


    [Embed("resources/smoky_opacity.atf", mimeType="application/octet-stream")]
    static private const EmbedSmokiOpacity:Class;
    [Embed("resources/flamethrower_opacity.atf", mimeType="application/octet-stream")]
    static private const EmbedFlamethrowerOpacity:Class;
    [Embed("resources/fire_opacity.atf", mimeType="application/octet-stream")]
    static private const EmbedFireOpacity:Class;


    [Embed("resources/smoky_diffuse.jpg")]
    static private const EmbedSmokiDiffuse:Class;
    [Embed("resources/flamethrower_diffuse.jpg")]
    static private const EmbedFlamethrowerDiffuse:Class;
    [Embed("resources/fire_diffuse.jpg")]
    static private const EmbedFireDiffuse:Class;


    static private const smokiDiffuse:BitmapTextureResource = new BitmapTextureResource(new EmbedSmokiDiffuse().bitmapData);
    static private const flamethrowerDiffuse:BitmapTextureResource = new BitmapTextureResource(new EmbedFlamethrowerDiffuse().bitmapData);
    static private const fireDiffuse:BitmapTextureResource = new BitmapTextureResource(new EmbedFireDiffuse().bitmapData);


    static private const smokiOpacity:ATFTextureResource = new ATFTextureResource(new EmbedSmokiOpacity());
    static private const flamethrowerOpacity:ATFTextureResource = new ATFTextureResource(new EmbedFlamethrowerOpacity());
    static private const fireOpacity:ATFTextureResource = new ATFTextureResource(new EmbedFireOpacity());


    [Embed("resources/Gun.A3D", mimeType="application/octet-stream")]
    static private const model:Class;
    private var smokySmokeAtlas:TextureAtlas;
    private var smokyFireAtlas:TextureAtlas;
    private var smokyFlashAtlas:TextureAtlas;
    private var smokyFragmentAtlas:TextureAtlas;
    private var smokyGlowAtlas:TextureAtlas;
    private var smokySparkAtlas:TextureAtlas;
    private var smokyShotAtlas:TextureAtlas;
    private var flamethrowerSmokeAtlas:TextureAtlas;
    private var flamethrowerFlashAtlas:TextureAtlas;
    private var flamethrowerFireAtlas:TextureAtlas;
    private var fireSmokeAtlas:TextureAtlas;
    private var fireFireAtlas:TextureAtlas;
    private var fireFlameAtlas:TextureAtlas;

    private var camera:Camera3D = new Camera3D(10, 3000);
    private var cameraContainer:Object3D;

    private var stage3D:Stage3D;
    private var context:Context3D;
    private var scene:Object3D = new Object3D();
    private var particleSystem:ParticleSystem;
    private var framesPerStep:int = 40;
    private var mode:int = 1;
    private var gun:Object3D;
    private var fireMarker:Object3D;
    private var shotMarker:Object3D;
    private var treeMarker:Object3D;
    private var pause:Boolean = false;
    private var cameraRotation:Boolean;


    public function ParticlesDemo() {
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
        stage.quality = StageQuality.LOW;

        stage3D = stage.stage3Ds[0];
        stage3D.addEventListener(Event.CONTEXT3D_CREATE, init);
        stage3D.requestContext3D(Context3DRenderMode.AUTO);
    }


    private function init(e:Event):void {
        initCamera();
        loadScene();
        addHelpPanel();
        initParticleSystem();
        initParticleResources();
        resizeHandler();
        addListeners();
    }


    private function loadScene():void {
        var parser:ParserA3D = new ParserA3D();
        parser.parse(new model());
        for each (var obj:Object3D in parser.hierarchy) {
            scene.addChild(obj);
        }

        var box:Box = new Box(2000, 2000, 2000, 1, 1, 1, true);
        box.setMaterialToAllSurfaces(new FillMaterial(0x909090));
        box.geometry.upload(context);
        scene.addChild(box);

        for each (var res2:Resource in scene.getResources(true))
            res2.upload(context);

        gun = parser.getObjectByName("gun");
        shotMarker = parser.getObjectByName("fire");
        fireMarker = parser.getObjectByName("fire2");
        treeMarker = parser.getObjectByName("fire3");

        var materialLoader:TexturesLoader = new TexturesLoader(context);
        var resList:Vector.<ExternalTextureResource> = new <ExternalTextureResource>[];
        for each (var res:ExternalTextureResource in scene.getResources(true, ExternalTextureResource)) {
            res.url = "particlesdemo/resources/" + res.url;
            resList.push(res);
        }
        materialLoader.loadResources(resList);
    }

    private function initParticleResources():void {
        smokiDiffuse.upload(context);
        smokiOpacity.upload(context);
        flamethrowerDiffuse.upload(context);
        flamethrowerOpacity.upload(context);
        fireDiffuse.upload(context);
        fireOpacity.upload(context);

        smokySmokeAtlas = new TextureAtlas(smokiDiffuse, smokiOpacity, 8, 8, 0, 16, 30, true);
        smokyFireAtlas = new TextureAtlas(smokiDiffuse, smokiOpacity, 8, 8, 16, 16, 30, true);
        smokyFlashAtlas = new TextureAtlas(smokiDiffuse, smokiOpacity, 8, 8, 32, 16, 30, true, 0.5, 0.5);
        smokyFragmentAtlas = new TextureAtlas(smokiDiffuse, smokiOpacity, 8, 8, 48, 8, 30, true);
        smokyGlowAtlas = new TextureAtlas(smokiDiffuse, smokiOpacity, 8, 8, 56, 1, 30, true);
        smokySparkAtlas = new TextureAtlas(smokiDiffuse, smokiOpacity, 8, 8, 57, 1, 30, true);
        smokyShotAtlas = new TextureAtlas(smokiDiffuse, smokiOpacity, 8, 8, 58, 1, 30, true);

        flamethrowerSmokeAtlas = new TextureAtlas(flamethrowerDiffuse, flamethrowerOpacity, 8, 8, 0, 16, 30, true);
        flamethrowerFlashAtlas = new TextureAtlas(flamethrowerDiffuse, flamethrowerOpacity, 8, 8, 16, 16, 60, true);
        flamethrowerFireAtlas = new TextureAtlas(flamethrowerDiffuse, flamethrowerOpacity, 8, 8, 32, 32, 60, false);

        fireSmokeAtlas = new TextureAtlas(fireDiffuse, fireOpacity, 8, 8, 0, 16, 30, true);
        fireFireAtlas = new TextureAtlas(fireDiffuse, fireOpacity, 8, 8, 16, 16, 30, true);
        fireFlameAtlas = new TextureAtlas(fireDiffuse, fireOpacity, 8, 8, 32, 32, 45, true, 0.5, 0.5);
    }

    private function initParticleSystem():void {
        particleSystem = new ParticleSystem();
        particleSystem.gravity = new Vector3D(0, 0, -1);
        particleSystem.wind = new Vector3D(1, 0, 0);
        particleSystem.fogColor = 0x6688AA;
        particleSystem.fogMaxDensity = 0;
        particleSystem.fogNear = 100;
        particleSystem.fogFar = 1000;
        scene.addChild(particleSystem);
    }

    private function addHelpPanel():void {
        var info:TextInfo = new TextInfo();
        info.x = 5;
        info.y = 5;
        info.write("1, 2, 3 — change weapon");
        info.write("Click — shoot");
        info.write("Space — stop/play animation");
        info.write("C — start/stop camera rotation");
        info.write("Wheel and +/- — time shift");
        info.write("Q — quality");
        addChild(info);
        addChild(camera.diagram);
    }

    private function onEnterFrame(e:Event = null):void {
        if (cameraRotation) {
            cameraContainer.rotationZ += 0.01;
            camera.z = 150 + Math.abs(Math.sin(cameraContainer.rotationZ / 2)) * 150
        }
        if (!pause) {
            gun.rotationZ = -Math.PI * mouseX / stage.stageWidth + Math.PI / 2;
            if (gun.rotationZ > 1.2) gun.rotationZ = 1.2;
            if (gun.rotationZ < -1.2) gun.rotationZ = -1.2;
            var flamethrower:FlameThrower = particleSystem.getEffectByName("firebird") as FlameThrower;
            if (flamethrower != null) {
                var fireOrigin:Vector3D = fireMarker.localToGlobal(new Vector3D(0, 0, 0));
                var fireDirection:Vector3D = gun.localToGlobal(new Vector3D(fireMarker.x, fireMarker.y, -gun.z));
                flamethrower.direction = fireDirection;
                flamethrower.position = fireOrigin;
            }
        }
        camera.startTimer();
        camera.render(stage3D);
        camera.stopTimer();
    }

    private function keyboardDownHandler(e:KeyboardEvent):void {
        var i:int;
        switch (e.keyCode) {
            case  Keyboard.NUMBER_1:
                mode = 1;
                break;
            case  Keyboard.NUMBER_2:
                mode = 2;
                break;
            case  Keyboard.NUMBER_3:
                mode = 3;
                break;
                break;
            case Keyboard.Q:
                if (camera.view.antiAlias == 0) {
                    camera.view.antiAlias = 8;
                } else {
                    camera.view.antiAlias = 0;
                }
                break;
            case Keyboard.C:
                cameraRotation = !cameraRotation;
                break;
            case Keyboard.MINUS:
            case Keyboard.NUMPAD_SUBTRACT:
                for (i = 0; i < framesPerStep; i++) {
                    particleSystem.prevFrame();
                }
                break;
            case Keyboard.EQUAL:
            case Keyboard.NUMPAD_ADD:
                for (i = 0; i < framesPerStep; i++) {
                    particleSystem.nextFrame();
                }
                break;
            case Keyboard.SPACE:
                pause = !pause;
                if (pause) {
                    particleSystem.stop();
                } else {
                    particleSystem.play();
                }
                break;
        }
    }

    private function resizeHandler(e:Event = null):void {
        camera.view.width = stage.stageWidth;
        camera.view.height = stage.stageHeight;
    }

    private function mouseDownHandler(e:MouseEvent3D):void {
        var shotOrigin:Vector3D = shotMarker.localToGlobal(new Vector3D(0, 0, 0));
        var shotDirection:Vector3D = gun.localToGlobal(new Vector3D(shotMarker.x, shotMarker.y, -gun.z));
        var fireOrigin:Vector3D = fireMarker.localToGlobal(new Vector3D(0, 0, 0));
        var fireDirection:Vector3D = gun.localToGlobal(new Vector3D(fireMarker.x, fireMarker.y, -gun.z));
        var rayData:RayIntersectionData = scene.intersectRay(shotOrigin, shotDirection);
        var coords:Vector3D = rayData.object.localToGlobal(rayData.point);
        var shot:SmokyShot;
        coords.x *= 0.9;
        coords.y *= 0.9;
        if (mode == 1) {
            shot = new SmokyShot(smokyShotAtlas);
            shot.position = shotOrigin;
            shot.direction = shotDirection;
            particleSystem.addEffect(shot);
            var explosion:TankExplosion = new TankExplosion(smokySmokeAtlas, smokyFireAtlas, smokyFlashAtlas, smokyGlowAtlas, smokySparkAtlas, smokyFragmentAtlas);
            explosion.position = coords;
            particleSystem.addEffect(explosion);
        } else if (mode == 2) {
            shot = new SmokyShot(smokyShotAtlas);
            shot.position = shotOrigin;
            shot.direction = shotDirection;
            particleSystem.addEffect(shot);
            var smoky:SmokyExplosion = new SmokyExplosion(smokySmokeAtlas, smokyFireAtlas, smokyFlashAtlas, smokyGlowAtlas, smokySparkAtlas, smokyFragmentAtlas);
            smoky.scale = 0.6;
            smoky.position = coords;
            particleSystem.addEffect(smoky);
        }

        else if (mode == 3) {
            var flamethrower:FlameThrower = new FlameThrower(flamethrowerSmokeAtlas, flamethrowerFireAtlas, flamethrowerFlashAtlas, 50);
            flamethrower.name = "firebird";
            flamethrower.position = fireOrigin;
            flamethrower.direction = fireDirection;
            particleSystem.addEffect(flamethrower);
            if (particleSystem.getEffectByName("shotMarker") == null) {
                var fire:Fire = new Fire(fireSmokeAtlas, fireFireAtlas, fireFlameAtlas, 5, false);
                fire.name = "shotMarker";
                fire.position = treeMarker.localToGlobal(new Vector3D());
                particleSystem.addEffect(fire);
            }
        }

    }

    private function mouseUpHandler(event:MouseEvent):void {
        var flamethrower:FlameThrower = particleSystem.getEffectByName("firebird") as FlameThrower;
        if (flamethrower != null) {
            flamethrower.stop();
        }
    }


    private function mouseWheelHandler(e:MouseEvent):void {
        var i:int;
        if (e.delta > 0) {
            for (i = 0; i < framesPerStep; i++) {
                particleSystem.nextFrame();
            }
        } else {
            for (i = 0; i < framesPerStep; i++) {
                particleSystem.prevFrame();
            }
        }
    }

    private function addListeners():void {
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
        scene.addEventListener(MouseEvent3D.MOUSE_DOWN, mouseDownHandler);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardDownHandler);
        stage.addEventListener(Event.RESIZE, resizeHandler);
        stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
        stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
    }

    private function initCamera():void {
        context = stage3D.context3D;
        context.enableErrorChecking = true;
        camera.view = new View(stage.stageWidth, stage.stageHeight, false, 0x555555, 1, 8);
        camera.view.logoAlign = StageAlign.BOTTOM_LEFT;
        addChild(camera.view);
        camera.matrix = new Matrix3D(Vector.<Number>([7.549790126404332e-8, 1, 0, 0, 0.30901703238487244, -2.333013782163107e-8, -0.9510564804077148, 0, -0.9510564804077148, 7.180276639928707e-8, -0.30901703238487244, 0, 478.5106201171875, 7.5265913009643555, 263.8153991699219, 1]));
        camera.z = 150;
        cameraContainer = new Object3D();
        cameraContainer.x = -200;
        cameraContainer.addChild(camera);
        scene.addChild(cameraContainer);
    }
}
}

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

class TextInfo extends Sprite {
    private var textField:TextField;
    private var bg:Sprite;

    public function TextInfo() {
        bg = new Sprite();
        with (bg.graphics) {
            beginFill(0x000000, .75);
            drawRect(0, 0, 10, 10);
            endFill();
        }
        textField = new TextField();
        textField.autoSize = TextFieldAutoSize.LEFT;
        textField.selectable = false;
        textField.defaultTextFormat = new TextFormat("Tahoma", 10, 0xFFFFFF);
        textField.x = 5;
        textField.y = 5;
        addChild(bg);
        addChild(textField);
    }

    public function write(value:String):void {
        textField.appendText(value + "\n");
        bg.width = textField.width + 10;
        bg.height = textField.height + 10;
    }
}
