package particlesdemo.classes {

import alternativa.engine3d.core.BoundBox;
import alternativa.engine3d.effects.ParticleEffect;
import alternativa.engine3d.effects.ParticlePrototype;
import alternativa.engine3d.effects.TextureAtlas;

import flash.display3D.Context3DBlendFactor;
import flash.geom.Vector3D;

public class SmokyExplosion extends ParticleEffect {
		
		static private var smokePrototype:ParticlePrototype;
		static private var firePrototype:ParticlePrototype;
		static private var flashPrototype:ParticlePrototype;
		static private var glowPrototype:ParticlePrototype;
		static private var sparkPrototype:ParticlePrototype;
		static private var fragmentPrototype:ParticlePrototype;
		
		static private const smokeDirections:Vector.<Vector3D> = Vector.<Vector3D>([new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D()]);
		static private const smokeDirectionsCount:int = 7;
		static private const sparkDirections:Vector.<Vector3D> = Vector.<Vector3D>([new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D()]);
		static private const sparkDirectionsCount:int = 20;
		static private const fragmentDirections:Vector.<Vector3D> = Vector.<Vector3D>([new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D()]);
		static private const fragmentDirectionsCount:int = 20;
		
		static private var pos:Vector3D = new Vector3D();
		static private var dir:Vector3D = new Vector3D();
		
		static private var gravity:Number = 700;
		static private var movingSpeed:Number = 700;
		static private var liftSpeed:Number = 17;
		static private var windSpeed:Number = 10;
		
		static private var littleTime:Number = 0.01;
		
		public function SmokyExplosion(smoke:TextureAtlas, fire:TextureAtlas, flash:TextureAtlas, glow:TextureAtlas, spark:TextureAtlas, fragment:TextureAtlas) {

			var ft:Number = 1/30;
			
			if (smokePrototype == null) {
				smokePrototype = new ParticlePrototype(128, 128, smoke, false);
				smokePrototype.addKey(  0*ft, 0, 0.40, 0.40, 1.00, 1.00, 1.00, 0.00);
				smokePrototype.addKey(  2*ft, 0, 0.74, 0.74, 0.86, 0.86, 0.86, 0.34);
				smokePrototype.addKey(  4*ft, 0, 0.94, 0.94, 0.78, 0.78, 0.78, 0.54);
				smokePrototype.addKey(  6*ft, 0, 1.00, 1.00, 0.75, 0.75, 0.75, 0.60);
				smokePrototype.addKey(100*ft, 0, 1.50, 1.50, 0.00, 0.00, 0.00, 0.00);
			}
			if (firePrototype == null) {
				firePrototype = new ParticlePrototype(128, 128, fire, false, Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);
				firePrototype.addKey(0*ft, 0, 0.40, 0.40, 1.00, 1.00, 1.00, 0.00);
				firePrototype.addKey(1*ft, 0, 0.85, 0.85, 1.00, 1.00, 1.00, 0.85);
				firePrototype.addKey(2*ft, 0, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00);
				firePrototype.addKey(9*ft, 0, 1.00, 1.00, 0.00, 0.00, 0.00, 0.00);
			}
			if (flashPrototype == null) {
				flashPrototype = new ParticlePrototype(128, 128, flash, false, Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);
				flashPrototype.addKey(0*ft, 0, 0.60, 0.60, 1.00, 1.00, 1.00, 1.00);
				flashPrototype.addKey(1*ft, 0, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00);
				flashPrototype.addKey(3*ft, 0, 0.95, 0.95, 1.00, 1.00, 1.00, 0.75);
				flashPrototype.addKey(5*ft, 0, 0.79, 0.79, 1.00, 1.00, 1.00, 0.00);
			}
			if (glowPrototype == null) {
				glowPrototype= new ParticlePrototype(256, 256, glow, false, Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);
				glowPrototype.addKey(0*ft, 0, 0.60, 0.60, 1.00, 1.00, 1.00, 0.40);
				glowPrototype.addKey(1*ft, 0, 1.00, 1.00, 1.00, 1.00, 1.00, 0.45);
				glowPrototype.addKey(8*ft, 0, 1.00, 1.00, 1.00, 1.00, 1.00, 0.00);
			}
			if (sparkPrototype == null) {
				sparkPrototype= new ParticlePrototype(8, 8, spark, false, Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);
				sparkPrototype.addKey(0*ft, 0, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00);
				sparkPrototype.addKey(4.5*ft, 0, 0.30, 0.30, 1.00, 1.00, 0.50, 0.50);
			}
			if (fragmentPrototype == null) {
				fragmentPrototype= new ParticlePrototype(16, 16, fragment, false);
				fragmentPrototype.addKey(0*ft, 0, 0.50, 0.50, 2.00, 1.40, 0.70, 0.60);
				fragmentPrototype.addKey(7*ft, 0, 0.30, 0.30, 0.60, 0.60, 0.60, 0.50);
			}
			
			boundBox = new BoundBox();
			boundBox.minX = -160;
			boundBox.minY = -160;
			boundBox.minZ = -90;
			boundBox.maxX = 160;
			boundBox.maxY = 160;
			boundBox.maxZ = 200;
			
			addKey(0*ft, keyFrame1);
			addKey(1*ft, keyFrame2);
			addKey(2*ft, keyFrame3);
			addKey(3*ft, keyFrame4);
			addKey(4*ft, keyFrame5);
			addKey(4.7*ft, keyFrame6);
			
			setLife(timeKeys[keysCount - 1] + smokePrototype.lifeTime);
		}
		
		private function keyFrame1(keyTime:Number, time:Number):void {
			var i:int;
			var ft:Number = 1/30;
			var deg:Number = Math.PI/180;
			var delta:Number = 30*deg;
			var bot:Number = -15*deg;
			var top:Number = 30*deg;
			var direction:Vector3D;
			randomDirection( 45*deg - delta,  45*deg + delta, bot, top, smokeDirections[0]);
			randomDirection(135*deg - delta, 135*deg + delta, bot, top, smokeDirections[1]);
			randomDirection(225*deg - delta, 225*deg + delta, bot, top, smokeDirections[2]);
			randomDirection(315*deg - delta, 315*deg + delta, bot, top, smokeDirections[3]);
			randomDirection(0, Math.PI + Math.PI, 40*deg, 90*deg, smokeDirections[4]);
			randomDirection(0, Math.PI + Math.PI, 40*deg, 90*deg, smokeDirections[5]);
			randomDirection(0, Math.PI + Math.PI, 40*deg, 90*deg, smokeDirections[6]);
			(smokeDirections[0] as Vector3D).scaleBy(0.8 + random()*0.2);
			(smokeDirections[1] as Vector3D).scaleBy(0.8 + random()*0.2);
			(smokeDirections[2] as Vector3D).scaleBy(0.8 + random()*0.2);
			(smokeDirections[3] as Vector3D).scaleBy(0.8 + random()*0.2);
			(smokeDirections[4] as Vector3D).scaleBy(1 + random()*0.2);
			(smokeDirections[5] as Vector3D).scaleBy(0.8 + random()*0.2);
			(smokeDirections[6] as Vector3D).scaleBy(0.8 + random()*0.2);
			for (i = 0; i < sparkDirectionsCount; i++) {
				direction = sparkDirections[i];
				randomDirection(0, 360*deg, bot, 90*deg, direction);
				direction.scaleBy(0.4 + random()*0.3);
			}
			for (i = 0; i < fragmentDirectionsCount; i++) {
				direction = fragmentDirections[i];
				randomDirection(0, 360*deg, bot, 90*deg, direction);
				direction.scaleBy(0.4 + random()*0.3);
			}
			for (i = 0; i < smokeDirectionsCount; i++) {
				direction = smokeDirections[i];
				calculatePosition(keyTime + littleTime, direction, pos);
				displacePosition(time, 1.17, pos);
				smokePrototype.createParticle(this, time, pos, random()-0.5, 1.17,1.17, 1, random()*smokePrototype.atlas.rangeLength);
				calculatePosition((keyTime + littleTime)*0.9, direction, pos);
				firePrototype.createParticle(this, time, pos, random()-0.5, 1.07,1.07, 1, random()*firePrototype.atlas.rangeLength);
				calculatePosition(keyTime + 0*ft, direction, pos);
				flashPrototype.createParticle(this, time, pos, random()-0.5, 0.8,0.8, 1, random()*flashPrototype.atlas.rangeLength);
				calculatePosition(keyTime + 1.3*ft, direction, pos);
				flashPrototype.createParticle(this, time, pos, random()-0.5, 0.5,0.5, 1, random()*flashPrototype.atlas.rangeLength);
				calculatePosition(keyTime + 2*ft, direction, pos);
				flashPrototype.createParticle(this, time, pos, random()-0.5, 0.3,0.3, 1, random()*flashPrototype.atlas.rangeLength);
			}
			pos.x = 0;
			pos.y = 0;
			pos.z = 0;
			flashPrototype.createParticle(this, time, pos, random()-0.5, 1.0,1.0, 1, random()*flashPrototype.atlas.rangeLength);
			glowPrototype.createParticle(this, time, pos, 0, 0.75,0.75, 1, 0);
			for (i = 0; i < sparkDirectionsCount >> 1; i++) {
				direction = sparkDirections[i];
				var t:Number = keyTime + 0.1;
				for (var j:int = 0; j < 8; j++) {
					calculatePosition(time + t, direction, pos, 0.4);
					sparkPrototype.createParticle(this, time, pos, 0, 1-j*0.05,1-j*0.05, 1, 0);
					t -= 0.003;
				}
			}
		}
		
		private function keyFrame2(keyTime:Number, time:Number):void {
			var i:int;
			var rnd:Number;
			for (i = 0; i < smokeDirectionsCount; i++) {
				var direction:Vector3D = smokeDirections[i];
				calculatePosition(keyTime + littleTime, direction, pos);
				displacePosition(time, 0.95, pos);
				smokePrototype.createParticle(this, time, pos, random()-0.5, 0.95,0.95, 1, random()*smokePrototype.atlas.rangeLength);
				calculatePosition((keyTime + littleTime)*0.9, direction, pos);
				firePrototype.createParticle(this, time, pos, random()-0.5, 0.87,0.87, 1, random()*firePrototype.atlas.rangeLength);
				rnd = 0.5 + random();
				calculatePosition(time + littleTime, direction, pos);
				fragmentPrototype.createParticle(this, time, pos, random()*6.28, rnd,rnd, 1, random()*fragmentPrototype.atlas.rangeLength);
			}
			for (i = sparkDirectionsCount >> 1; i < sparkDirectionsCount; i++) {
				direction = sparkDirections[i];
				var t:Number = keyTime + 0.1;
				for (var j:int = 0; j < 8; j++) {
					calculatePosition(time + t, direction, pos, 0.4);
					sparkPrototype.createParticle(this, time, pos, 0, 1-j*0.05,1-j*0.05, 1, 0);
					t -= 0.003;
				}
			}
			for (i = 0; i < fragmentDirectionsCount; i++) {
				direction = fragmentDirections[i];
				rnd = 0.5 + random();
				calculatePosition(time + littleTime, direction, pos);
				fragmentPrototype.createParticle(this, time, pos, random()*6.28, rnd,rnd, 1, random()*fragmentPrototype.atlas.rangeLength);
			}
		}
		
		// 3
		private function keyFrame3(keyTime:Number, time:Number):void {
			for (var i:int = 0; i < smokeDirectionsCount; i++) {
				// Дым
				var direction:Vector3D = smokeDirections[i];
				calculatePosition(keyTime + littleTime, direction, pos);
				displacePosition(time, 0.85, pos);
				smokePrototype.createParticle(this, time, pos, random()-0.5, 0.85,0.85, 1, random()*smokePrototype.atlas.rangeLength);
				// Огонь
				calculatePosition((keyTime + littleTime)*0.9, direction, pos);
				firePrototype.createParticle(this, time, pos, random()-0.5, 0.78,0.78, 0.73, random()*firePrototype.atlas.rangeLength);
			}
		}
		
		// 4
		private function keyFrame4(keyTime:Number, time:Number):void {
			for (var i:int = 0; i < smokeDirectionsCount; i++) {
				// Дым
				var direction:Vector3D = smokeDirections[i];
				calculatePosition(keyTime + littleTime, direction, pos);
				displacePosition(time, 0.70, pos);
				smokePrototype.createParticle(this, time, pos, random()-0.5, 0.70,0.70, 1, random()*smokePrototype.atlas.rangeLength);
				// Огонь
				calculatePosition((keyTime + littleTime)*0.9, direction, pos);
				firePrototype.createParticle(this, time, pos, random()-0.5, 0.44,0.44, 0.53, random()*firePrototype.atlas.rangeLength);
			}
		}
		
		// 5
		private function keyFrame5(keyTime:Number, time:Number):void {
			for (var i:int = 0; i < smokeDirectionsCount; i++) {
				// Дым
				var direction:Vector3D = smokeDirections[i];
				calculatePosition(keyTime + littleTime, direction, pos);
				displacePosition(time, 0.40, pos);
				smokePrototype.createParticle(this, time, pos, random()-0.5, 0.40,0.40, 1, random()*smokePrototype.atlas.rangeLength);
			}
			// Добавочный дым
			for (var j:int = 0; j < 3; j++) {
				pos.x = random()*50 - 25;
				pos.y = random()*50 - 25;
				pos.z = random()*20 - 10;
				displacePosition(time, 0.18, pos);
				var rnd:Number = 0.5 + random()*0.5;
				smokePrototype.createParticle(this, time, pos, random()-0.5, rnd,rnd, 1, random()*smokePrototype.atlas.rangeLength);
				// Добавочный огонь
				pos.x = random()*10 - 5;
				pos.y = random()*10 - 5;
				pos.z = random()*10 - 5;
				rnd = 0.3 + random()*0.5;
				firePrototype.createParticle(this, time, pos, random()-0.5, rnd,rnd, 1, random()*firePrototype.atlas.rangeLength);
			}
		}
		
		// 6
		private function keyFrame6(keyTime:Number, time:Number):void {
			for (var i:int = 0; i < smokeDirectionsCount; i++) {
				// Дым
				var direction:Vector3D = smokeDirections[i];
				if (random() > 0.25) {
					calculatePosition(keyTime + littleTime, direction, pos);
					displacePosition(time, 0.25, pos);
					smokePrototype.createParticle(this, time, pos, random()-0.5, 0.19,0.19, 1, random()*smokePrototype.atlas.rangeLength);
				}
			}
			// Добавочный дым
			for (var j:int = 0; j < 3; j++) {
				pos.x = random()*50 - 25;
				pos.y = random()*50 - 25;
				pos.z = random()*20 - 10;
				displacePosition(time, 0.16, pos);
				var rnd:Number = 0.5 + random()*0.5;
				smokePrototype.createParticle(this, time, pos, random()-0.5, rnd,rnd, 1, random()*smokePrototype.atlas.rangeLength);
			}
		}
		
		private function randomDirection(xyBegin:Number, xyEnd:Number, zBegin:Number, zEnd:Number, result:Vector3D):void {
			var xyAng:Number = xyBegin + random()*(xyEnd - xyBegin);
			var zAng:Number = zBegin + random()*(zEnd - zBegin);
			var cosZAng:Number = Math.cos(zAng);
			result.x = Math.cos(xyAng)*cosZAng;
			result.y = Math.sin(xyAng)*cosZAng;
			result.z = Math.sin(zAng);
		}
		
		private function calculatePosition(time:Number, direction:Vector3D, result:Vector3D, gravityInfluence:Number = 1):void {
			result.x = time*movingSpeed*direction.x;
			result.y = time*movingSpeed*direction.y;
			result.z = time*movingSpeed*direction.z - time*time*gravity*gravityInfluence;
		}
		
		private function displacePosition(time:Number, factor:Number, result:Vector3D):void {
			result.x += time*windSpeed*particleSystem.wind.x;
			result.y += time*windSpeed*particleSystem.wind.y;
			result.z += time*windSpeed*particleSystem.wind.z + time*liftSpeed*factor;
		}
		
		//var displacement:Number = effectScale*(displacementKeys[a] + (displacementKeys[b] - displacementKeys[a])*t);
		//var fall:Number = time*time*gravityInfluence*0.5;

	}
}
