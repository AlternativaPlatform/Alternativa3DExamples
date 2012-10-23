package particlesdemo.classes {

import alternativa.engine3d.core.BoundBox;
import alternativa.engine3d.effects.ParticleEffect;
import alternativa.engine3d.effects.ParticlePrototype;
import alternativa.engine3d.effects.TextureAtlas;

import flash.display3D.Context3DBlendFactor;
import flash.geom.Vector3D;

public class FlameThrower extends ParticleEffect {
		
		static private var smokePrototype1:ParticlePrototype;
		static private var smokePrototype2:ParticlePrototype;
		static private var flashPrototype1:ParticlePrototype;
		static private var flashPrototype2:ParticlePrototype;
		static private var flashPrototype3:ParticlePrototype;
		static private var firePrototype:ParticlePrototype;
		
		static private var pos:Vector3D = new Vector3D();
		static private var dir:Vector3D = new Vector3D();
		
		static private var liftSpeed:Number = 25;
		static private var windSpeed:Number = 10;
		
		public function FlameThrower(smoke:TextureAtlas, fire:TextureAtlas, flash:TextureAtlas, live:Number = 1) {
			
			var ft:Number = 1/30;
			
			if (flashPrototype1 == null) {
				flashPrototype1 = new ParticlePrototype(50, 50, flash, true, Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);
				flashPrototype1.addKey( 0*ft, 0, 0.13, 0.13, 1.00, 1.00, 1.00, 0.80);
				flashPrototype1.addKey( 2*ft, 0, 0.40, 0.40, 1.00, 1.00, 1.00, 1.00);
				flashPrototype1.addKey( 6*ft, 0, 1.10, 1.10, 1.00, 1.00, 1.00, 0.80);
				flashPrototype1.addKey(11*ft, 0, 1.26, 1.26, 1.00, 1.00, 1.00, 0.80);
				flashPrototype1.addKey(17*ft, 0, 1.47, 1.47, 1.00, 1.00, 0.30, 0.00);
				flashPrototype2 = new ParticlePrototype(50, 50, flash, true, Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);
				flashPrototype2.addKey( 1*ft, 0, 0.13, 0.13, 1.00, 1.00, 1.00, 0.80);
				flashPrototype2.addKey( 3*ft, 0, 0.30, 0.30, 1.00, 1.00, 1.00, 1.00);
				flashPrototype2.addKey( 8*ft, 0, 0.80, 0.80, 1.00, 1.00, 1.00, 0.50);
				flashPrototype2.addKey(12*ft, 0, 1.26, 1.26, 1.00, 1.00, 1.00, 0.00);
				flashPrototype3 = new ParticlePrototype(50, 50, flash, true, Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);
				flashPrototype3.addKey( 2*ft, 0, 0.13, 0.13, 1.00, 1.00, 1.00, 0.80);
				flashPrototype3.addKey( 4*ft, 0, 0.30, 0.30, 1.00, 1.00, 1.00, 1.00);
				flashPrototype3.addKey( 8*ft, 0, 0.60, 0.60, 1.00, 1.00, 1.00, 0.00);
			}
			if (firePrototype == null) {
				firePrototype = new ParticlePrototype(50, 50, fire, true);
				firePrototype.addKey( 6*ft, 0, 1.53, 1.53, 1.00, 1.00, 1.00, 0.00);
				firePrototype.addKey(11*ft, 0, 1.53, 1.53, 1.00, 1.00, 1.00, 0.60);
				firePrototype.addKey(17*ft, 0, 1.85, 1.85, 1.00, 0.70, 0.00, 0.80);
				firePrototype.addKey(24*ft, 0, 1.98, 1.98, 1.00, 0.30, 0.00, 0.20);
			}
			if (smokePrototype1 == null) {
				smokePrototype1 = new ParticlePrototype(50, 50, smoke, true);
				smokePrototype1.addKey( 6*ft, 0, 1.51, 1.51, 1.00, 1.00, 1.00, 0.00);
				smokePrototype1.addKey(11*ft, 0, 1.92, 1.92, 1.00, 1.00, 1.00, 0.90);
				smokePrototype1.addKey(17*ft, 0, 2.49, 2.49, 0.50, 0.50, 0.50, 1.00);
				smokePrototype1.addKey(24*ft, 0, 2.66, 2.66, 0.00, 0.00, 0.00, 0.00);
				smokePrototype2 = new ParticlePrototype(50, 50, smoke, false);
				smokePrototype2.addKey(15*ft, 0, 1.51, 1.51, 1.00, 1.00, 1.00, 0.00);
				smokePrototype2.addKey(20*ft, 0, 1.92, 1.92, 0.80, 0.80, 0.80, 0.30);
				smokePrototype2.addKey(26*ft, 0, 2.49, 2.49, 0.50, 0.50, 0.50, 0.60);
				smokePrototype2.addKey(55*ft, 0, 2.66, 2.66, 0.00, 0.00, 0.00, 0.00);
			}
			
			boundBox = new BoundBox();
			boundBox.minX = -350;
			boundBox.minY = -350;
			boundBox.minZ = -350;
			boundBox.maxX = 350;
			boundBox.maxY = 350;
			boundBox.maxZ = 350;
			
			var i:int = 0;
			while (true) {
				var keyTime:Number = i*2*ft;
				if (keyTime < live) {
					addKey(keyTime, keyFrame);
				} else break;
				i++;
			}
			
			setLife(timeKeys[keysCount - 1] + smokePrototype2.lifeTime);
		}
		
		private function keyFrame(keyTime:Number, time:Number):void {
			var ft:Number = 1/30;
			
			var ang:Number = 6*3.14/180;
			
			dir.x = keyDirection.x;
			dir.y = keyDirection.y;
			dir.z = keyDirection.z + 0.2;
			dir.normalize();
			
			randomDirection(keyDirection, ang, pos);
			pos.scaleBy(time*300 + 10);
			flashPrototype1.createParticle(this, time, pos, random()*6.28, 1.00,1.00, 1, random()*flashPrototype1.atlas.rangeLength);
			randomDirection(keyDirection, ang, pos);
			pos.scaleBy((time - ft)*150 + 10);
			flashPrototype2.createParticle(this, time, pos, random()*6.28, 1.00,1.00, 1, random()*flashPrototype1.atlas.rangeLength);
			randomDirection(keyDirection, ang, pos);
			pos.scaleBy((time - ft - ft)*80 + 10);
			flashPrototype3.createParticle(this, time, pos, random()*6.28, 1.00,1.00, 1, random()*flashPrototype1.atlas.rangeLength);
			
			randomDirection(keyDirection, ang, pos);
			pos.scaleBy(time*240 + 10);
			firePrototype.createParticle(this, time, pos, random()*6.28, 1.00,1.00, 1, -6*ft*firePrototype.atlas.fps);
			randomDirection(dir, ang, pos);
			pos.scaleBy(time*300 + 10);
			firePrototype.createParticle(this, time, pos, random()*6.28, 1.00,1.00, 1, -6*ft*firePrototype.atlas.fps);
			
			randomDirection(keyDirection, ang, pos);
			pos.scaleBy(time*300 + 10);
			smokePrototype1.createParticle(this, time, pos, random()*6.28, 1.00,1.00, 1, random()*smokePrototype1.atlas.rangeLength);
			randomDirection(dir, ang, pos);
			pos.scaleBy(time*330 + 10);
			smokePrototype1.createParticle(this, time, pos, random()*6.28, 1.00,1.00, 1, random()*smokePrototype1.atlas.rangeLength);
			
			randomDirection(dir, ang, pos);
			pos.scaleBy(time*40 + 100 + random()*120);
			pos.x += random()*50 - 25;
			pos.y += random()*50 - 25;
			pos.z += random()*50 - 25;
			displacePosition(time - 15*ft, 1, pos);
			smokePrototype2.createParticle(this, time, pos, random()*6.28, 1.00,1.00, 1, random()*smokePrototype1.atlas.rangeLength);
		}
		
		private function randomDirection(direction:Vector3D, angle:Number, result:Vector3D):void {
			var x:Number = random()*2 - 1;
			var y:Number = random()*2 - 1;
			var z:Number = random()*2 - 1;
			result.x = direction.z*y - direction.y*z;
			result.y = direction.x*z - direction.z*x;
			result.z = direction.y*x - direction.x*y;
			result.normalize();
			result.scaleBy(Math.sin(angle/2));
			result.x += direction.x;
			result.y += direction.y;
			result.z += direction.z;
			result.normalize();
		}
		
		private function displacePosition(time:Number, factor:Number, result:Vector3D):void {
			result.x += time*windSpeed*particleSystem.wind.x;
			result.y += time*windSpeed*particleSystem.wind.y;
			result.z += time*windSpeed*particleSystem.wind.z + time*liftSpeed*factor;
		}
		
	}
}
