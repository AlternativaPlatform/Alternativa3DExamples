/**
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * If it is not possible or desirable to put the notice in a particular file, then You may include the notice in a location (such as a LICENSE file in a relevant directory) where a recipient would be likely to look for such a notice.
 * You may add additional accurate notices of copyright ownership.
 *
 * It is desirable to notify that Covered Software was "Powered by AlternativaPlatform" with link to http://www.alternativaplatform.com/ 
 * */

package skinexample {

	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Joint;
	import alternativa.engine3d.objects.Skin;
	import alternativa.engine3d.resources.Geometry;
	
	import flash.geom.Matrix3D;

	public class Tentacle extends Skin {

		private var kappa:Number = 1 + 8*Math.random();
		private var omega:Number = Math.PI*Math.random();

		public function Tentacle(angle:Number, radius:Number, material:Material, type:int) {
			super(2);
			
			x = radius*Math.cos(angle);
			y = radius*Math.sin(angle);
			rotationZ = angle;
			
			var n:Number;
			var v:Number = 0;
			var h:Number = 8;
			var r:Number = 10;
			var usegments:int = 10;
			var vsegments:int = 50;
			var radiusDecreaseStep:Number = r/vsegments;
			var dAlpha:Number = 2*Math.PI/usegments;
			var row:int;

			// Vertices
			var vertices:Vector.<Number> = new Vector.<Number>();
			var uvs:Vector.<Number> = new Vector.<Number>();
			for (row = 0; row < vsegments; row++) {
				for (var alpha:Number = 0; alpha < Math.PI*2 - 0.01; alpha += dAlpha) {
					vertices.push(r*Math.sin(alpha), r*Math.cos(alpha), -row*h);
					uvs.push(alpha/Math.PI, v);
				}
				v += 0.33;
				r -= radiusDecreaseStep;
			}
			
			// Bones
			var bones:Vector.<Number> = new Vector.<Number>();
			for (row = 0; row < vsegments; row++) {
				for (n = 0; n < usegments; n++) {
					bones.push(row*3, 1, 0, 0);
				}
			}
			
			// Indices
			var indices:Vector.<uint> = new Vector.<uint>();
			for (row = 0; row < vsegments - 1; row++) {
				for (n = 0; n < usegments - 1; n++) {
					indices.push(usegments*row + n, (n + 1) + row*usegments, usegments*(row + 1) + n);
					indices.push((n + 1) + row*usegments, (n + 1) + usegments*(row + 1), usegments*(row + 1) + n);
				}
				indices.push(usegments*row + usegments - 1, row*usegments, usegments*(row + 1) + usegments - 1);
				indices.push(row*usegments, (row + 1)*usegments, usegments*(row + 1) + usegments - 1);
			}
			
			// Geometry
			geometry = new Geometry(vertices.length/3);
			geometry.addVertexStream([
				VertexAttributes.POSITION,
				VertexAttributes.POSITION,
				VertexAttributes.POSITION,
				VertexAttributes.JOINTS[0],
				VertexAttributes.JOINTS[0],
				VertexAttributes.JOINTS[0],
				VertexAttributes.JOINTS[0],
				VertexAttributes.TEXCOORDS[0],
				VertexAttributes.TEXCOORDS[0]
			]);
			geometry.setAttributeValues(VertexAttributes.POSITION, vertices);
			geometry.setAttributeValues(VertexAttributes.JOINTS[0], bones);
			geometry.setAttributeValues(VertexAttributes.TEXCOORDS[0], uvs);
			geometry.indices = indices;
			
			// Surface
			addSurface(material, 0, geometry.numTriangles);
			
			
			// Fills joints vector
			renderedJoints = new Vector.<Joint>();
			
			
			var joint:Joint;
			var jointMatrix:Matrix3D;

			switch(type) {
				case 1:
					var cm:Matrix3D = concatenatedMatrix;
					cm.invert();
					for (n = 0; n < vsegments; n++) {
						joint = new Joint();
						joint.z = -h;
						if (n > 0) {
							renderedJoints[renderedJoints.length - 1].addChild(joint);
						} else {
							addChild(joint);
						}
						renderedJoints.push(joint);
						jointMatrix = joint.concatenatedMatrix;
						jointMatrix.append(cm);
						jointMatrix.invert();
						joint.bindingMatrix = jointMatrix;
					}
					break;
				case 2:
					for (n = 0; n < vsegments; n++) {
						joint = new Joint();
						joint.z = -h;
						if (n > 0) {
							renderedJoints[renderedJoints.length - 1].addChild(joint);
						} else {
							addChild(joint);
						}
						renderedJoints.push(joint);
					}
					calculateBindingMatrices();
					break;


			}
			
			divide(40);
		}

		public function update(t:Number):void {
			for each (var joint:Joint in renderedJoints) {
				joint.rotationY = renderedJoints.indexOf(joint)*0.01*Math.sin(omega + t + this.renderedJoints.indexOf(joint)/kappa);
			}
		}

	}
}