/**
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * If it is not possible or desirable to put the notice in a particular file, then You may include the notice in a location (such as a LICENSE file in a relevant directory) where a recipient would be likely to look for such a notice.
 * You may add additional accurate notices of copyright ownership.
 *
 * It is desirable to notify that Covered Software was "Powered by AlternativaPlatform" with link to http://www.alternativaplatform.com/
 * */

package skyboxexample {
import alternativa.engine3d.controllers.SimpleObjectController;
import alternativa.engine3d.core.Camera3D;
import alternativa.engine3d.core.Object3D;
import alternativa.engine3d.core.Resource;
import alternativa.engine3d.core.View;
import alternativa.engine3d.materials.FillMaterial;
import alternativa.engine3d.materials.TextureMaterial;
import alternativa.engine3d.objects.SkyBox;
import alternativa.engine3d.primitives.Box;
import alternativa.engine3d.resources.BitmapTextureResource;
 
import flash.display.Sprite;
import flash.display.Stage3D;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
 
public class SkyBoxExample extends Sprite {
 
    private var stage3D:Stage3D;
	private var rootContainer:Object3D = new Object3D();
    private var camera:Camera3D;
    private var controller:SimpleObjectController;
    private var skyBox:SkyBox;
 
	[Embed(source = "left.jpg")] static private const left_t_c:Class;
	private var left_t:BitmapTextureResource = new BitmapTextureResource(new left_t_c().bitmapData);
	[Embed(source = "right.jpg")] static private const right_t_c:Class;
	private var right_t:BitmapTextureResource = new BitmapTextureResource(new right_t_c().bitmapData);
	[Embed(source = "top.jpg")] static private const top_t_c:Class;
	private var top_t:BitmapTextureResource = new BitmapTextureResource(new top_t_c().bitmapData);
	[Embed(source = "bottom.jpg")] static private const bottom_t_c:Class;
	private var bottom_t:BitmapTextureResource = new BitmapTextureResource(new bottom_t_c().bitmapData);
	[Embed(source = "front.jpg")] static private const front_t_c:Class;
	private var front_t:BitmapTextureResource = new BitmapTextureResource(new front_t_c().bitmapData);
	[Embed(source = "back.jpg")] static private const back_t_c:Class;
	private var back_t:BitmapTextureResource = new BitmapTextureResource(new back_t_c().bitmapData);
 
    public function SkyBoxExample() {
 
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;
 
        camera = new Camera3D(1, 10000);
        camera.view = new View(1024, 768, false, 0xFFFFFF, 0, 4);
        addChild(camera.view);
		rootContainer.addChild(camera);
 
        controller = new SimpleObjectController(stage, camera, 400);
        controller.lookAtXYZ(0,0,0);
 
        skyBox = new SkyBox(3000, 
									new TextureMaterial(left_t), 
									new TextureMaterial(right_t), 
									new TextureMaterial(back_t), 
									new TextureMaterial(front_t), 
									new TextureMaterial(bottom_t), 
									new TextureMaterial(top_t), 0.01);
        rootContainer.addChild(skyBox);
 
        stage3D = stage.stage3Ds[0];
        stage3D.addEventListener(Event.CONTEXT3D_CREATE, init);
        stage3D.requestContext3D();
 
    }
 
    private function init(event:Event):void {
        for each (var resource:Resource in rootContainer.getResources(true)) { 
            resource.upload(stage3D.context3D);
        }
        addEventListener(Event.ENTER_FRAME, enterFrameHandler)
    }
 
    private function enterFrameHandler(event:Event):void {
        controller.update();
        camera.render(stage3D);
    }
}
}