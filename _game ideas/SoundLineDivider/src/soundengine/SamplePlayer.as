package soundengine 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class SamplePlayer implements SoundSource
	{
		private var _active:Boolean = true;
		private var _panning:Number = 0;
		
		private var dataL:Vector.<Number>;
		private var dataR:Vector.<Number>;
		private var sampleAmount:int;
		
		private var soundPitchFactor:Number = 1.0;
		private var lastSoundPitchFactor:Number = 1.0;
		
		private var soundPitchSourceIndex:Number = 0;
		private var sourceIndex:int;
		private var soundLeftValue:Number, soundRightValue:Number;
		
		private var _leftPanGain:Number = 0.5;
		private var _rightPanGain:Number = 0.5;
		
		public function SamplePlayer(sourceLeft:Vector.<Number>, sourceRight:Vector.<Number>) 
		{
			dataL = sourceLeft;
			dataR = sourceRight;
			sampleAmount = dataL.length;
			trace(this, sampleAmount, "samples");
		}
		
		public function set active(value:Boolean):void {
			_active = value;
		}
		public function get active():Boolean {
			return _active;
		}

		public function set panning(value:Number):void
		{
			_panning = Math.max( -1, Math.min(1, value));
			_leftPanGain = map(_panning, -1, 1, 1, 0);
			_rightPanGain = map(_panning, -1, 1, 0, 1);
		}
		public function get panning():Number
		{
			return _panning;
		}
		
		public function setOctave(octave:Number, interpolatePitch:Boolean = false):void {
			lastSoundPitchFactor = soundPitchFactor;
			soundPitchFactor = Math.pow(2, octave);
			if (!interpolatePitch) {
				lastSoundPitchFactor = soundPitchFactor;
			}
		}
		
		public function setSoundPitchFactor(fac:Number, interpolatePitch:Boolean = false):void {
			lastSoundPitchFactor = soundPitchFactor;
			soundPitchFactor = fac;
			if (!interpolatePitch) {
				lastSoundPitchFactor = soundPitchFactor;
			}
		}
		
		public function setOffset(percentage:Number):void {
			soundPitchSourceIndex = sampleAmount * percentage;
			soundPitchSourceIndex %= sampleAmount;
		}
		
		public function generate(amount:int, outputLeft:Vector.<Number>, outputRight:Vector.<Number>):void
		{
			//TODO: SAMPLES NOT INTERPOLATED:
			
			var deltaSoundPitchFactor:Number = soundPitchFactor - lastSoundPitchFactor;
			if (deltaSoundPitchFactor==0) {
				for (var i:int = 0; i < amount; i++) 
				{ 
					soundLeftValue = dataL[sourceIndex] * _leftPanGain;
					soundRightValue = dataR[sourceIndex] * _rightPanGain;
					outputLeft[i] = soundLeftValue;
					outputRight[i] = soundRightValue;
					
					soundPitchSourceIndex += soundPitchFactor;
					soundPitchSourceIndex %= sampleAmount;
					sourceIndex = int(soundPitchSourceIndex);
					
				} 
			} else {
				var interpolatedFactor:Number;
				var p:Number;
				for (i = 0; i < amount; i++) 
				{ 
					p = i / amount;
					interpolatedFactor = lastSoundPitchFactor + p * deltaSoundPitchFactor;
					soundLeftValue = dataL[sourceIndex] * _leftPanGain;
					soundRightValue = dataR[sourceIndex] * _rightPanGain;
					outputLeft[i] = soundLeftValue;
					outputRight[i] = soundRightValue;
					
					soundPitchSourceIndex += interpolatedFactor;
					soundPitchSourceIndex %= sampleAmount;
					sourceIndex = int(soundPitchSourceIndex);
					
				} 
			}
			lastSoundPitchFactor = soundPitchFactor;
		}
		
		private static function map(v:Number, v0:Number, v1:Number, w0:Number, w1:Number):Number {
			return w0 + (w1 - w0) * (v - v0) / (v1 - v0);
		}
	}

}