package ssaoexample {

	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.core.events.Event3D;

	import flash.display3D.Context3D;
	import flash.utils.Dictionary;

	/**
	 * Now invokes only when hierarchy changes (add, remove)
	 */
	public class ResourceManager {

		private var objectToListen:Object3D;
		private var _enabled:Boolean;

		private var _context3D:Context3D;

		// handle all active resources
		private var resourcesUsages:Dictionary = new Dictionary(true);

		public function ResourceManager(objectToListen:Object3D) {
			this.objectToListen = objectToListen;

			_enabled = true;
			objectToListen.addEventListener(Event3D.ADDED, onHierarchyChange);
			objectToListen.addEventListener(Event3D.REMOVED, onHierarchyChange);
		}

		public function get enabled():Boolean {
			return _enabled;
		}

		public function set enabled(value:Boolean):void {
			if (value) {
				objectToListen.addEventListener(Event3D.ADDED, onHierarchyChange);
				objectToListen.addEventListener(Event3D.REMOVED, onHierarchyChange);
			} else {
				objectToListen.removeEventListener(Event3D.ADDED, onHierarchyChange);
				objectToListen.removeEventListener(Event3D.REMOVED, onHierarchyChange);
			}
			_enabled = value;
		}

		public function get context3D():Context3D {
			return _context3D;
		}

		public function set context3D(value:Context3D):void {
			_context3D = value;
			for (var r:* in resourcesUsages) {
				r.upload(_context3D);
			}
		}

		private function onHierarchyChange(e:Event3D):void {
			var r:Resource;
			var usages:int;
			var object:Object3D = Object3D(e.target);
			if (e.type == Event3D.ADDED) {
				for each (r in object.getResources(true)) {
					usages = resourcesUsages[r];
					if (usages == 0 && _context3D != null) {
						r.upload(_context3D);
					}
					usages++;
					resourcesUsages[r] = usages;
				}
			} else if (e.type == Event3D.REMOVED) {
				for each (r in object.getResources(true)) {
					usages = resourcesUsages[r];
					if (usages <= 1) {
						r.dispose();
						delete resourcesUsages[r];
					} else {
						usages--;
						resourcesUsages[r] = usages;
					}
				}
			}
		}

		public function uploadObject3D(object:Object3D, hierarchy:Boolean = true):void {
			if (_context3D == null) {
				throw new Error("Context3D is not available");
			}
			for each (var r:Resource in object.getResources(hierarchy)) {
				r.upload(_context3D)
			}
		}

		public function uploadResource(resource:Resource):void {
			if (_context3D == null) {
				throw new Error("Context3D is not available");
			}
			resource.upload(_context3D)
		}

	}
}
