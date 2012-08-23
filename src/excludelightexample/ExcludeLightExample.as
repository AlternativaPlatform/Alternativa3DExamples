/**
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * If it is not possible or desirable to put the notice in a particular file, then You may include the notice in a location (such as a LICENSE file in a relevant directory) where a recipient would be likely to look for such a notice.
 * You may add additional accurate notices of copyright ownership.
 *
 * It is desirable to notify that Covered Software was "Powered by AlternativaPlatform" with link to http://www.alternativaplatform.com/
 * */

package excludelightexample {

import alternativa.engine3d.core.Camera3D;
import alternativa.engine3d.core.Object3D;
import alternativa.engine3d.core.Resource;
import alternativa.engine3d.core.View;
import alternativa.engine3d.core.events.MouseEvent3D;
import alternativa.engine3d.lights.AmbientLight;
import alternativa.engine3d.lights.DirectionalLight;
import alternativa.engine3d.lights.OmniLight;
import alternativa.engine3d.materials.FillMaterial;
import alternativa.engine3d.materials.StandardMaterial;
import alternativa.engine3d.primitives.GeoSphere;
import alternativa.engine3d.resources.BitmapTextureResource;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.Stage3D;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;

/**
 * Demonstration of the excludeLight() method
 */
public class ExcludeLightExample extends Sprite {

    private var rootContainer:Object3D = new Object3D();

    private var camera:Camera3D;
    private var stage3D:Stage3D;
    private var omniLight:OmniLight;
    private var t:Number = 0;

    public function ExcludeLightExample() {
        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        camera = new Camera3D(0.1, 10000);
        camera.view = new View(stage.stageWidth, stage.stageHeight, false, 0x404040, 0, 4);
        addChild(camera.view);
        addChild(camera.diagram);
        camera.rotationX = -120 * Math.PI / 180;
        camera.y = -800;
        camera.z = 500;

        rootContainer.addChild(camera);
        omniLight = new OmniLight(0xf0f0ff, 50, 1000);
        omniLight.intensity = 3;
        var omniSphere = new GeoSphere(10, 4, false, new FillMaterial(0xffffff));
        omniLight.addChild(omniSphere);
        rootContainer.addChild(omniLight);
        var dirLight = new DirectionalLight(0x909030);
        dirLight.intensity = .5;
        dirLight.z = 1000;
        dirLight.lookAt(0, 0, 0);
        rootContainer.addChild(dirLight);
        var ambientLight:AmbientLight = new AmbientLight(0x404040);
        rootContainer.addChild(ambientLight);

        for (var i:int = 0; i < 40; i++) {
            var sphere:GeoSphere = new GeoSphere(Math.random() * 100 + 10, 8);
            sphere.setMaterialToAllSurfaces(coloredStandardMaterial(Math.random() * 0xffffff));
            sphere.x = Math.random() * 1000 - 500;
            sphere.z = Math.random() * 1000 - 500;
            sphere.y = Math.random() * 700 - 100;
            sphere.addEventListener(MouseEvent3D.MOUSE_DOWN, sphereClickHandler);
            rootContainer.addChild(sphere);
        }

        stage3D = stage.stage3Ds[0];
        stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
        stage3D.requestContext3D();
        createLabel();
    }

    private function sphereClickHandler(event:MouseEvent3D):void {
        var obj:Object3D = Object3D(event.target);
        if (obj.excludedLights.length > 0)
            obj.clearExcludedLights();
        else
            obj.excludeLight(omniLight);
    }

    private function onContextCreate(e:Event):void {
        for each (var resource:Resource in rootContainer.getResources(true)) {
            resource.upload(stage3D.context3D);
        }
        stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function onEnterFrame(e:Event):void {
        t+=0.01;
        omniLight.x = Math.sin(t) * 700;
        camera.view.width = stage.stageWidth;
        camera.view.height = stage.stageHeight;
        camera.render(stage3D);
    }

    public static function coloredStandardMaterial(color:int = 0x7F7F7F):StandardMaterial {
        var material:StandardMaterial;
        material = new StandardMaterial(createColorTexture(color), createColorTexture(0x7F7FFF));
        return material;
    }

    public static function createColorTexture(color:uint, alpha:Boolean = false):BitmapTextureResource {
        return new BitmapTextureResource(new BitmapData(1, 1, alpha, color));
    }

    private function createLabel():void {
        var info:TextInfo = new TextInfo();
        info.x = 5;
        info.y = 5;
        info.write("Click on object for switch");
        info.write("it's state of lighting");
        info.write("by omni light.");
        addChild(info);
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


