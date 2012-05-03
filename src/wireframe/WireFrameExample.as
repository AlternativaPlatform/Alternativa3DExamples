/**
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * If it is not possible or desirable to put the notice in a particular file, then You may include the notice in a location (such as a LICENSE file in a relevant directory) where a recipient would be likely to look for such a notice.
 * You may add additional accurate notices of copyright ownership.
 *
 * It is desirable to notify that Covered Software was "Powered by AlternativaPlatform" with link to http://www.alternativaplatform.com/ 
 * */

package wireframe {

	import alternativa.engine3d.controllers.SimpleObjectController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.core.View;
	import alternativa.engine3d.objects.WireFrame;
	import alternativa.engine3d.primitives.GeoSphere;

	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Vector3D;

	public class WireFrameExample extends Sprite {

		private var rootContainer:Object3D;

		private var camera:Camera3D;
		private var controller:SimpleObjectController;

		private var stage3D:Stage3D;

		public function WireFrameExample() {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			rootContainer = new Object3D();

			camera = new Camera3D(1, 1000);

			camera.x = 300;
			camera.y = 300;
			camera.z = 400;
			rootContainer.addChild(camera);

			camera.view = new View(stage.stageWidth, stage.stageHeight, false, 0x202020, 0, 4);
			addChild(camera.view);

			controller = new SimpleObjectController(stage, camera, 200);
			controller.lookAtXYZ(0, 0, 0);

			makeAxes();

			makeSolidLine();

			makeWireframeForMesh();

			stage3D = stage.stage3Ds[0];
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, init);
			stage3D.requestContext3D();
		}

		// Construct axes with lines by  fragments
		// Each fragment take couple of Vector3D for begin and end coordinates
		private function makeAxes():void {
			var axisX:WireFrame = WireFrame.createLinesList(Vector.<Vector3D>([new Vector3D(0, 0, 0), new Vector3D(300, 0, 0),  new Vector3D(300, 0, 0),  new Vector3D(280, 10, 0),  new Vector3D(300, 0, 0),  new Vector3D(280, -10, 0) ]), 0x0000ff, 2);
			var axisY:WireFrame = WireFrame.createLinesList(Vector.<Vector3D>([new Vector3D(0, 0, 0), new Vector3D(0, 300, 0), new Vector3D(0, 300, 0),new Vector3D(0, 280, 10),new Vector3D(0, 300, 0),new Vector3D(0, 280, -10)  ]), 0xff0000, 2);
			var axisZ:WireFrame = WireFrame.createLinesList(Vector.<Vector3D>([new Vector3D(0, 0, 0), new Vector3D(0, 0, 300), new Vector3D(0, 0, 300),new Vector3D(10, 0, 280),new Vector3D(0, 0, 300),new Vector3D(-10, 0, 280) ]), 0x00ff00, 2);
			rootContainer.addChild(axisX);
			rootContainer.addChild(axisY);
			rootContainer.addChild(axisZ);
		}

		  // Solid line draws by series of Vector3D
		private function makeSolidLine():void {
			var points:Vector.<Vector3D> = new Vector.<Vector3D>();
			for (var x:Number = -6; x < 6; x += .1) {
				points.push(new Vector3D(x * 40, 0, Math.sin(x) * 60))
			}
			var sinusoid:WireFrame = WireFrame.createLineStrip(points, 0xf0f020);
			sinusoid.rotationZ = - .7;
			rootContainer.addChild(sinusoid);
		}

		 // It is also possible ta make wireframe object for showing edges of any mesh
		private function makeWireframeForMesh():void {
			var sphere:GeoSphere = new GeoSphere();
			var wire:WireFrame = WireFrame.createEdges(sphere, 0xa00000, 1, 2);
			rootContainer.addChild(wire);
		}

		private function init(event:Event):void {
			for each (var resource:Resource in rootContainer.getResources(true)) {
				resource.upload(stage3D.context3D);
			}
			addEventListener(Event.ENTER_FRAME, onEnterFrame)
		}

		private function onEnterFrame(event:Event):void {
			camera.view.width = stage.stageWidth;
			camera.view.height = stage.stageHeight;

			controller.update();
			camera.render(stage3D);
		}

	}
}
