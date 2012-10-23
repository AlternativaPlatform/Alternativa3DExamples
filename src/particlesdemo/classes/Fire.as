package particlesdemo.classes {

import alternativa.engine3d.core.BoundBox;
import alternativa.engine3d.effects.ParticleEffect;
import alternativa.engine3d.effects.ParticlePrototype;
import alternativa.engine3d.effects.TextureAtlas;

import flash.display3D.Context3DBlendFactor;
import flash.geom.Vector3D;
import flash.utils.setTimeout;

public class Fire extends ParticleEffect {
		
		static private var smokePrototype:ParticlePrototype;
		static private var firePrototype:ParticlePrototype;
		static private var flamePrototype:ParticlePrototype;
		
		static private var liftSpeed:Number = 60;
		static private var windSpeed:Number = 10;
		
		static private var pos:Vector3D = new Vector3D();
		
		public function Fire(smoke:TextureAtlas, fire:TextureAtlas, flame:TextureAtlas, live:Number = 1, repeat:Boolean = false) {
			
			var ft:Number = 1/30;
			
			if (smokePrototype == null) {
				smokePrototype = new ParticlePrototype(128, 128, smoke, false);
				smokePrototype.addKey( 0*ft, 0, 0.40, 0.40, 0.65, 0.25, 0.00, 0.00);
				smokePrototype.addKey( 9*ft, 0, 0.58, 0.58, 0.65, 0.45, 0.23, 0.30);
				smokePrototype.addKey(19*ft, 0, 0.78, 0.78, 0.65, 0.55, 0.50, 0.66);
				smokePrototype.addKey(40*ft, 0, 1.21, 1.21, 0.40, 0.40, 0.40, 0.27);
				smokePrototype.addKey(54*ft, 0, 1.50, 1.50, 0.00, 0.00, 0.00, 0.00);
			}
			if (firePrototype == null) {
				firePrototype = new ParticlePrototype(128, 128, fire, false, Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);
				firePrototype.addKey( 0*ft, 0, 0.30, 0.30, 1.00, 1.00, 1.00, 0.00);
				firePrototype.addKey( 8*ft, 0, 0.40, 0.40, 1.00, 1.00, 1.00, 0.85);
				firePrototype.addKey(17*ft, 0, 0.51, 0.51, 1.00, 0.56, 0.48, 0.10);
				firePrototype.addKey(24*ft, 0, 0.60, 0.60, 1.00, 0.56, 0.48, 0.00);
			}
			if (flamePrototype == null) {
				flamePrototype = new ParticlePrototype(128, 128, flame, true, Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);
				flamePrototype.addKey(        0*ft, 0, 1.00, 1.00, 1.00, 1.00, 1.00, 0.00);
				flamePrototype.addKey(       10*ft, 0, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00);
				flamePrototype.addKey(live - 10*ft, 0, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00);
				flamePrototype.addKey(        live, 0, 1.00, 1.00, 1.00, 1.00, 1.00, 0.00);
			}
			
			boundBox = new BoundBox();
			boundBox.minX = -100;
			boundBox.minY = -100;
			boundBox.minZ = -20;
			boundBox.maxX = 100;
			boundBox.maxY = 100;
			boundBox.maxZ = 200;
			
			addKey(0, keyFrame1);
			
			var i:int = 0;
			while (true) {
				var keyTime:Number = ft + i*5*ft;
				if (keyTime < live) {
					addKey(keyTime, keyFrame);
				} else break;
				i++;
			}
			
			if (repeat) {
				setTimeout(function():void {
					var newFire:Fire = new Fire(smoke, fire, flame, live, repeat);
					newFire.name = name;
					newFire.scale = scale;
					newFire.position = position;
					newFire.direction = direction;
					particleSystem.addEffect(newFire);
				}, (live - 5*ft)*1000);
			}
			
			setLife(timeKeys[keysCount - 1] + smokePrototype.lifeTime);
		}
		
		private function keyFrame1(keyTime:Number, time:Number):void {
			var area:Number = 10;
			pos.x = random()*area - area*0.5;
			pos.y = random()*area - area*0.5;
			pos.z = random()*area*0.5;
			var rnd:Number = 0.2 + random()*0.2;
			flamePrototype.createParticle(this, time, pos, 0, rnd,rnd, 1, 0);
			pos.x = random()*area - area*0.5;
			pos.y = random()*area - area*0.5;
			pos.z = random()*area*0.5;
			rnd = 0.2 + random()*0.2;
			flamePrototype.createParticle(this, time, pos, 0, rnd,rnd, 1, 0.5*flamePrototype.atlas.rangeLength);
		}
		
		private function keyFrame(keyTime:Number, time:Number):void {
			var ft:Number = 1/30;
			var area:Number = 10;
			for (var i:int = 0; i < 1; i++) {
				pos.x = random()*area - area*0.5;
				pos.y = random()*area - area*0.5;
				pos.z = 10 + random()*area*0.5;
				displacePosition(time, 0.7 + random()*0.5, pos);
				smokePrototype.createParticle(this, time, pos, random()-0.5, 1.00,1.00, 1, random()*smokePrototype.atlas.rangeLength);
				pos.x = 0;
				pos.y = 0;
				pos.z = 0;
				displacePosition(time, 0.7 + random()*0.5, pos);
				firePrototype.createParticle(this, time, pos, random()-0.5, 1.00,1.00, 0.70, random()*firePrototype.atlas.rangeLength);
			}
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
