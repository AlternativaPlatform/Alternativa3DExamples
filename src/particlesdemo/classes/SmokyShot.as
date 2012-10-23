package particlesdemo.classes {

import alternativa.engine3d.core.BoundBox;
import alternativa.engine3d.effects.ParticleEffect;
import alternativa.engine3d.effects.ParticlePrototype;
import alternativa.engine3d.effects.TextureAtlas;

import flash.display3D.Context3DBlendFactor;
import flash.geom.Vector3D;

public class SmokyShot extends ParticleEffect {
		
		static private var shotPrototype:ParticlePrototype;
		
		static private var pos:Vector3D = new Vector3D();
		
		public function SmokyShot(shot:TextureAtlas) {
			
			var ft:Number = 1/30;
			
			if (shotPrototype == null) {
				shotPrototype = new ParticlePrototype(50, 50, shot, false, Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);
				shotPrototype.addKey(0*ft, 0, 0.85, 0.85, 1.00, 1.00, 1.00, 0.60);
				shotPrototype.addKey(1*ft, 0, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00);
				shotPrototype.addKey(2*ft, 0, 1.00, 1.00, 1.00, 1.00, 1.00, 0.50);
				shotPrototype.addKey(3*ft, 0, 1.00, 1.00, 1.00, 1.00, 1.00, 0.50);
			}
			
			boundBox = new BoundBox();
			boundBox.minX = -100;
			boundBox.minY = -100;
			boundBox.minZ = -100;
			boundBox.maxX = 100;
			boundBox.maxY = 100;
			boundBox.maxZ = 100;
			
			addKey(0*ft, keyFrame1);
			
			setLife(timeKeys[keysCount - 1] + shotPrototype.lifeTime);
		}
		
		private function keyFrame1(keyTime:Number, time:Number):void {
			pos.copyFrom(keyDirection);
			pos.scaleBy(time*100 + 25);
			shotPrototype.createParticle(this, time, pos, random()*6.28, 1.00,1.00, 1, 0);
			pos.copyFrom(keyDirection);
			pos.scaleBy(time*300 + 32);
			shotPrototype.createParticle(this, time, pos, random()*6.28, 0.88,0.88, 1, 0);
			pos.copyFrom(keyDirection);
			pos.scaleBy(time*400 + 39);
			shotPrototype.createParticle(this, time, pos, random()*6.28, 0.66,0.66, 1, 0);
		}
		
	}
}

