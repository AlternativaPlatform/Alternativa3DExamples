package particlesdemo.classes {

import alternativa.engine3d.core.BoundBox;
import alternativa.engine3d.effects.ParticleEffect;
import alternativa.engine3d.effects.ParticlePrototype;
import alternativa.engine3d.effects.TextureAtlas;

import flash.display3D.Context3DBlendFactor;
import flash.geom.Vector3D;

public class TankExplosion extends ParticleEffect {
		
		static private var smokePrototype1:ParticlePrototype;
		static private var smokePrototype2:ParticlePrototype;
		static private var firePrototype1:ParticlePrototype;
		static private var firePrototype2:ParticlePrototype;
		static private var flashPrototype:ParticlePrototype;
		static private var glowPrototype:ParticlePrototype;
		static private var sparkPrototype:ParticlePrototype;
		static private var fragmentPrototype:ParticlePrototype;
		
		static private const smokeDirections:Vector.<Vector3D> = Vector.<Vector3D>([new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D()]);
		static private const smokeDirectionsCount:int = 15;
		static private const sparkDirections:Vector.<Vector3D> = Vector.<Vector3D>([new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D()]);
		static private const sparkDirectionsCount:int = 20;
		static private const fragmentDirections:Vector.<Vector3D> = Vector.<Vector3D>([new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D()]);
		static private const fragmentDirectionsCount:int = 20;
		
		static private var pos:Vector3D = new Vector3D();
		static private var dir:Vector3D = new Vector3D();
		
		static private var gravity:Number = 700;
		static private var movingSpeed:Number = 700;
		static private var movingSpeed2:Number = 300;
		static private var liftSpeed:Number = 17;
		static private var windSpeed:Number = 10;
		
		static private var littleTime:Number = 0.01;
		
		public function TankExplosion(smoke:TextureAtlas, fire:TextureAtlas, flash:TextureAtlas, glow:TextureAtlas, spark:TextureAtlas, fragment:TextureAtlas) {

			var ft:Number = 1/30;
			
			if (smokePrototype1 == null) {
				var m:Number = 2;
				smokePrototype1 = new ParticlePrototype(128, 128, smoke, false);
				smokePrototype1.addKey(  0*ft*m, 0, 0.40, 0.40, 1.00, 1.00, 1.00, 0.00);
				smokePrototype1.addKey(  2*ft*m, 0, 0.74, 0.74, 0.86, 0.86, 0.86, 0.34);
				smokePrototype1.addKey(  4*ft*m, 0, 0.94, 0.94, 0.78, 0.78, 0.78, 0.54);
				smokePrototype1.addKey(  6*ft*m, 0, 1.00, 1.00, 0.75, 0.75, 0.75, 0.60);
				smokePrototype1.addKey(100*ft, 0, 1.50, 1.50, 0.00, 0.00, 0.00, 0.00);
				smokePrototype2 = new ParticlePrototype(128, 128, smoke, false);
				smokePrototype2.addKey(  0*ft*m, 0, 0.40, 0.40, 1.00, 1.00, 1.00, 0.00);
				smokePrototype2.addKey(  2*ft*m, 0, 0.62, 0.62, 0.86, 0.86, 0.86, 0.37);
				smokePrototype2.addKey(  4*ft*m, 0, 0.74, 0.74, 0.78, 0.78, 0.78, 0.59);
				smokePrototype2.addKey(  6*ft*m, 0, 0.78, 0.78, 0.75, 0.75, 0.75, 0.66);
				smokePrototype2.addKey(100*ft, 0, 1.14, 1.14, 0.00, 0.00, 0.00, 0.00);
			}
			if (firePrototype1 == null) {
				firePrototype1 = new ParticlePrototype(128, 128, fire, false, Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);
				firePrototype1.addKey(0*ft*m, 0, 0.40, 0.40, 1.00, 1.00, 1.00, 0.00);
				firePrototype1.addKey(1*ft*m, 0, 0.85, 0.85, 1.00, 1.00, 1.00, 0.85);
				firePrototype1.addKey(2*ft*m, 0, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00);
				firePrototype1.addKey(9*ft*m, 0, 1.00, 1.00, 0.00, 0.00, 0.00, 0.00);
				firePrototype2 = new ParticlePrototype(128, 128, fire, false, Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);
				firePrototype2.addKey( 0*ft*m, 0, 0.50, 0.50, 1.00, 0.44, 0.00, 0.00);
				firePrototype2.addKey( 3*ft*m, 0, 0.66, 0.66, 1.00, 1.00, 1.00, 1.00);
				firePrototype2.addKey( 9*ft*m, 0, 0.80, 0.80, 1.00, 0.40, 0.00, 0.55);
				firePrototype2.addKey(16*ft*m, 0, 0.95, 0.95, 1.00, 0.30, 0.00, 0.00);
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
				sparkPrototype= new ParticlePrototype(6, 6, spark, false, Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);
				sparkPrototype.addKey(0*ft, 0, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00);
				sparkPrototype.addKey(20*ft, 0, 0.40, 0.40, 1.00, 1.00, 0.50, 0.50);
			}
			if (fragmentPrototype == null) {
				fragmentPrototype= new ParticlePrototype(16, 16, fragment, false);
				fragmentPrototype.addKey(0*ft, 0, 0.50, 0.50, 2.00, 1.40, 0.70, 0.60);
				fragmentPrototype.addKey(15*ft, 0, 0.30, 0.30, 0.60, 0.60, 0.60, 0.50);
			}
			
			boundBox = new BoundBox();
			boundBox.minX = -160;
			boundBox.minY = -160;
			boundBox.minZ = -90;
			boundBox.maxX = 160;
			boundBox.maxY = 160;
			boundBox.maxZ = 350;
			
			addKey(0*ft, keyFrame1);
			addKey(1*ft, keyFrame2);
			addKey(2*ft, keyFrame3);
			addKey(3*ft, keyFrame4);
			addKey(4*ft, keyFrame5);
			addKey(4.7*ft, keyFrame6);
			
			setLife(timeKeys[keysCount - 1] + smokePrototype1.lifeTime);
		}
		
		private function keyFrame1(keyTime:Number, time:Number):void {
			var i:int;
			var direction:Vector3D;
			var ft:Number = 1/30;
			var deg:Number = Math.PI/180;
			var delta:Number = 27*deg;
			var delta2:Number = 50*deg;
			var bot:Number = -3*deg;
			var top:Number = 10*deg;
			var bot2:Number = 55*deg;
			var top2:Number = 65*deg;
			var delta3:Number = 15*deg;
			randomDirection( 30*deg - delta,  30*deg + delta, bot, top, smokeDirections[0]);
			randomDirection( 90*deg - delta,  90*deg + delta, bot, top, smokeDirections[1]);
			randomDirection(150*deg - delta, 150*deg + delta, bot, top, smokeDirections[2]);
			randomDirection(210*deg - delta, 210*deg + delta, bot, top, smokeDirections[3]);
			randomDirection(270*deg - delta, 270*deg + delta, bot, top, smokeDirections[4]);
			randomDirection(330*deg - delta, 330*deg + delta, bot, top, smokeDirections[5]);
			randomDirection( 60*deg - delta2,  60*deg + delta2, 85*deg, 88*deg, smokeDirections[6]);
			randomDirection(180*deg - delta2, 180*deg + delta2, 70*deg, 88*deg, smokeDirections[7]);
			randomDirection(300*deg - delta2, 300*deg + delta2, 70*deg, 88*deg, smokeDirections[8]);
			randomDirection(  0*deg - delta3,   0*deg + delta3, bot2, top2, smokeDirections[9]);
			randomDirection( 60*deg - delta3,  60*deg + delta3, bot2, top2, smokeDirections[10]);
			randomDirection(120*deg - delta3, 120*deg + delta3, bot2, top2, smokeDirections[11]);
			randomDirection(180*deg - delta3, 180*deg + delta3, bot2, top2, smokeDirections[12]);
			randomDirection(240*deg - delta3, 240*deg + delta3, bot2, top2, smokeDirections[13]);
			randomDirection(300*deg - delta3, 300*deg + delta3, bot2, top2, smokeDirections[14]);
			(smokeDirections[0] as Vector3D).scaleBy(0.8 + random()*0.2);
			(smokeDirections[1] as Vector3D).scaleBy(0.8 + random()*0.2);
			(smokeDirections[2] as Vector3D).scaleBy(0.8 + random()*0.2);
			(smokeDirections[3] as Vector3D).scaleBy(0.8 + random()*0.2);
			(smokeDirections[4] as Vector3D).scaleBy(0.8 + random()*0.2);
			(smokeDirections[5] as Vector3D).scaleBy(0.8 + random()*0.2);
			(smokeDirections[6] as Vector3D).scaleBy(1.1 + random()*0.2);
			(smokeDirections[7] as Vector3D).scaleBy(1.0 + random()*0.2);
			(smokeDirections[8] as Vector3D).scaleBy(1.0 + random()*0.2);
			(smokeDirections[9] as Vector3D).scaleBy(0.7 + random()*0.3);
			(smokeDirections[10] as Vector3D).scaleBy(0.7 + random()*0.3);
			(smokeDirections[11] as Vector3D).scaleBy(0.7 + random()*0.3);
			(smokeDirections[12] as Vector3D).scaleBy(0.7 + random()*0.3);
			(smokeDirections[13] as Vector3D).scaleBy(0.7 + random()*0.3);
			(smokeDirections[14] as Vector3D).scaleBy(0.7 + random()*0.3);
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
				if (i < 6) {
					calculatePosition(keyTime + littleTime, direction, pos);
					displacePosition(time, 0.90, pos);
					smokePrototype1.createParticle(this, time, pos, random()-0.5, 0.90,0.90, 1, random()*smokePrototype1.atlas.rangeLength);
					calculatePosition((keyTime + littleTime)*0.9, direction, pos);
					displacePosition(time, 0.90, pos);
					firePrototype1.createParticle(this, time, pos, random()-0.5, 0.85,0.85, 1, random()*firePrototype1.atlas.rangeLength);
				} else {
					calculatePosition(keyTime + 2.0*ft, direction, pos);
					displacePosition(time, 0.9, pos);
					smokePrototype2.createParticle(this, time, pos, random()-0.5, 0.90,0.90, 1, random()*smokePrototype2.atlas.rangeLength);
					calculatePosition((keyTime + littleTime)*0.9, direction, pos);
					displacePosition(time, 0.90, pos);
					firePrototype1.createParticle(this, time, pos, random()-0.5, 0.85,0.85, 1, random()*firePrototype1.atlas.rangeLength);
				}
				calculatePosition(keyTime + 0*ft, direction, pos);
				flashPrototype.createParticle(this, time, pos, random()-0.5, 0.8,0.8, 0.5, random()*flashPrototype.atlas.rangeLength);
				calculatePosition(keyTime + 1.7*ft, direction, pos);
				flashPrototype.createParticle(this, time, pos, random()-0.5, 0.5,0.5, 0.25, random()*flashPrototype.atlas.rangeLength);
				calculatePosition(keyTime + 2*ft, direction, pos);
				flashPrototype.createParticle(this, time, pos, random()-0.5, 0.3,0.3, 0.25, random()*flashPrototype.atlas.rangeLength);
			}
			
			pos.x = 0;
			pos.y = 0;
			pos.z = 0;
			flashPrototype.createParticle(this, time, pos, random()-0.5, 1.0,1.0, 1, random()*flashPrototype.atlas.rangeLength);
			glowPrototype.createParticle(this, time, pos, 0, 0.75,0.75, 1, 0);
			pos.z = 30;
			firePrototype2.createParticle(this, time, pos, random()-0.5, 1.20,1.20, 1, random()*firePrototype2.atlas.rangeLength);
			for (i = 0; i < sparkDirectionsCount >> 1; i++) {
				direction = sparkDirections[i];
				var t:Number = keyTime + 0.1;
				for (var j:int = 0; j < 8; j++) {
					calculatePosition2(time + t, direction, pos, 0.2);
					sparkPrototype.createParticle(this, time, pos, 0, 1-j*0.05,1-j*0.05, 1, 0);
					t -= 0.003;
				}
			}
		}
		
		private function keyFrame2(keyTime:Number, time:Number):void {
			var i:int;
			var direction:Vector3D;
			var rnd:Number;
			var ft:Number = 1/30;
			for (i = 0; i < smokeDirectionsCount; i++) {
				direction = smokeDirections[i];
				if (i < 6) {
					calculatePosition(keyTime + littleTime, direction, pos);
					displacePosition(time, 0.75, pos);
					smokePrototype1.createParticle(this, time, pos, random()-0.5, 0.75,0.75, 1, random()*smokePrototype1.atlas.rangeLength);
					calculatePosition((keyTime + littleTime)*0.9, direction, pos);
					displacePosition(time, 0.75, pos);
					firePrototype1.createParticle(this, time, pos, random()-0.5, 0.68,0.68, 1, random()*firePrototype1.atlas.rangeLength);
				} else if (i < 9) {
					calculatePosition(keyTime + 2.5*ft, direction, pos);
					displacePosition(time, 1.2, pos);
					smokePrototype2.createParticle(this, time, pos, random()-0.5, 1.20,1.20, 1, random()*smokePrototype2.atlas.rangeLength);
					calculatePosition((keyTime + 2.5*ft)*0.9, direction, pos);
					displacePosition(time, 1.2, pos);
					firePrototype2.createParticle(this, time, pos, random()-0.5, 1.10,1.10, 1, random()*firePrototype1.atlas.rangeLength);
				} else {
					calculatePosition(keyTime + 2.5*ft, direction, pos);
					displacePosition(time, 0.9, pos);
					smokePrototype2.createParticle(this, time, pos, random()-0.5, 0.90,0.90, 1, random()*smokePrototype2.atlas.rangeLength);
					calculatePosition((keyTime + 2.5*ft)*0.9, direction, pos);
					displacePosition(time, 0.9, pos);
					firePrototype2.createParticle(this, time, pos, random()-0.5, 0.80,0.80, 1, random()*firePrototype1.atlas.rangeLength);
				}
				rnd = 0.5 + random();
				calculatePosition(time + littleTime, direction, pos);
				fragmentPrototype.createParticle(this, time, pos, random()*6.28, rnd,rnd, 1, random()*fragmentPrototype.atlas.rangeLength);
			}
			for (i = sparkDirectionsCount >> 1; i < sparkDirectionsCount; i++) {
				direction = sparkDirections[i];
				var t:Number = keyTime + 0.1;
				for (var j:int = 0; j < 8; j++) {
					calculatePosition2(time + t, direction, pos, 0.2);
					sparkPrototype.createParticle(this, time, pos, 0, 1-j*0.05,1-j*0.05, 1, 0);
					t -= 0.003;
				}
			}
			for (i = 0; i < fragmentDirectionsCount; i++) {
				direction = fragmentDirections[i];
				rnd = 0.5 + random();
				calculatePosition2(time + littleTime, direction, pos, 0.4);
				fragmentPrototype.createParticle(this, time, pos, random()*6.28, rnd,rnd, 1, random()*fragmentPrototype.atlas.rangeLength);
			}
		}
		
		private function keyFrame3(keyTime:Number, time:Number):void {
			var direction:Vector3D;
			var ft:Number = 1/30;
			for (var i:int = 0; i < smokeDirectionsCount; i++) {
				direction = smokeDirections[i];
				if (i < 6) {
					calculatePosition(keyTime + littleTime, direction, pos);
					displacePosition(time, 0.65, pos);
					smokePrototype1.createParticle(this, time, pos, random()-0.5, 0.65,0.65, 1, random()*smokePrototype1.atlas.rangeLength);
					calculatePosition((keyTime + littleTime)*0.9, direction, pos);
					displacePosition(time, 0.65, pos);
					firePrototype1.createParticle(this, time, pos, random()-0.5, 0.60,0.60, 0.73, random()*firePrototype1.atlas.rangeLength);
				} else if (i < 9) {
					calculatePosition(keyTime + 3*ft, direction, pos);
					displacePosition(time, 1.4, pos);
					smokePrototype2.createParticle(this, time, pos, random()-0.5, 1.40,1.40, 1, random()*smokePrototype2.atlas.rangeLength);
					calculatePosition((keyTime + 3*ft)*0.9, direction, pos);
					displacePosition(time, 1.4, pos);
					firePrototype2.createParticle(this, time, pos, random()-0.5, 1.30,1.30, 0.50, random()*firePrototype2.atlas.rangeLength);
				} else {
					calculatePosition(keyTime + 3*ft, direction, pos);
					displacePosition(time, 1.1, pos);
					smokePrototype2.createParticle(this, time, pos, random()-0.5, 1.10,1.10, 1, random()*smokePrototype2.atlas.rangeLength);
					calculatePosition((keyTime + 3*ft)*0.9, direction, pos);
					displacePosition(time, 1.1, pos);
					firePrototype2.createParticle(this, time, pos, random()-0.5, 1.00,1.00, 0.40, random()*firePrototype2.atlas.rangeLength);
				}
			}
		}
		
		private function keyFrame4(keyTime:Number, time:Number):void {
			var direction:Vector3D;
			var ft:Number = 1/30;
			for (var i:int = 0; i < smokeDirectionsCount; i++) {
				direction = smokeDirections[i];
				if (i < 6) {
					calculatePosition(keyTime + littleTime, direction, pos);
					displacePosition(time, 0.55, pos);
					smokePrototype1.createParticle(this, time, pos, random()-0.5, 0.55,0.55, 1, random()*smokePrototype1.atlas.rangeLength);
					calculatePosition((keyTime + littleTime)*0.9, direction, pos);
					displacePosition(time, 0.55, pos);
					firePrototype1.createParticle(this, time, pos, random()-0.5, 0.34,0.34, 0.53, random()*firePrototype1.atlas.rangeLength);
				} else if (i < 9) {
					calculatePosition(keyTime + 4*ft, direction, pos);
					displacePosition(time, 1.7, pos);
					smokePrototype2.createParticle(this, time, pos, random()-0.5, 1.70,1.70, 1, random()*smokePrototype2.atlas.rangeLength);
					calculatePosition((keyTime + 4*ft)*0.9, direction, pos);
					displacePosition(time, 1.7, pos);
					firePrototype2.createParticle(this, time, pos, random()-0.5, 1.60,1.60, 0.10, random()*firePrototype2.atlas.rangeLength);
				} else {
					calculatePosition(keyTime + 4*ft, direction, pos);
					displacePosition(time, 1.4, pos);
					smokePrototype2.createParticle(this, time, pos, random()-0.5, 1.4,1.4, 1, random()*smokePrototype2.atlas.rangeLength);
					calculatePosition((keyTime + 4*ft)*0.9, direction, pos);
					displacePosition(time, 1.4, pos);
					firePrototype2.createParticle(this, time, pos, random()-0.5, 1.30,1.30, 0.10, random()*firePrototype2.atlas.rangeLength);
				}
			}
		}
		
		private function keyFrame5(keyTime:Number, time:Number):void {
			var direction:Vector3D;
			for (var i:int = 0; i < smokeDirectionsCount; i++) {
				direction = smokeDirections[i];
				if (i < 6) {
					calculatePosition(keyTime + littleTime, direction, pos);
					displacePosition(time, 0.40, pos);
					smokePrototype1.createParticle(this, time, pos, random()-0.5, 0.40,0.40, 1, random()*smokePrototype1.atlas.rangeLength);
				}
			}

		}
		
		private function keyFrame6(keyTime:Number, time:Number):void {
			var direction:Vector3D;
			for (var i:int = 0; i < smokeDirectionsCount; i++) {
				direction = smokeDirections[i];
				if (i < 6) {
					if (random() > 0.25) {
						calculatePosition(keyTime + littleTime, direction, pos);
						displacePosition(time, 0.25, pos);
						smokePrototype1.createParticle(this, time, pos, random()-0.5, 0.25,0.25, 1, random()*smokePrototype1.atlas.rangeLength);
					}
				}
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
		
		private function calculatePosition2(time:Number, direction:Vector3D, result:Vector3D, gravityInfluence:Number = 1):void {
			result.x = time*movingSpeed2*direction.x;
			result.y = time*movingSpeed2*direction.y;
			result.z = time*movingSpeed2*direction.z - time*time*gravity*gravityInfluence;
		}
		
		private function displacePosition(time:Number, factor:Number, result:Vector3D):void {
			result.x += time*windSpeed*particleSystem.wind.x;
			result.y += time*windSpeed*particleSystem.wind.y;
			result.z += time*windSpeed*particleSystem.wind.z + time*liftSpeed*factor;
		}
		

	}
}
