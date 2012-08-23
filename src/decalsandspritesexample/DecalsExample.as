package decalsandspritesexample {

	import alternativa.engine3d.collisions.EllipsoidCollider;
	import alternativa.engine3d.controllers.SimpleObjectController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.RayIntersectionData;
	import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.core.View;
	import alternativa.engine3d.core.events.MouseEvent3D;
	import alternativa.engine3d.lights.AmbientLight;
	import alternativa.engine3d.lights.OmniLight;
	import alternativa.engine3d.loaders.TexturesLoader;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.StandardMaterial;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.AnimSprite;
	import alternativa.engine3d.objects.AxisAlignedSprite;
	import alternativa.engine3d.objects.Decal;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.primitives.GeoSphere;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.resources.ExternalTextureResource;

	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	[SWF(width="800", height="600", frameRate="20")]
public class DecalsExample extends Sprite {

    private var rootContainer:Object3D = new Object3D();
    private var camera:Camera3D;
    private var stage3D:Stage3D;
    private var room:Mesh;
    // Source of geometry for decals
    private var sourceGeometry:Plane = new Plane(400, 400);
    private var controller:SimpleObjectController;
    // Explosion
    private var bang:AnimSprite;
    private var collider:EllipsoidCollider;
    private var wallsMaterial:StandardMaterial;
    // Explosion animation materials
    private var bangMaterials:Vector.<Material>;
    private var light:OmniLight;
    private var inc:Number = 60;
    // Exploson trace material
    private var decalMaterial:StandardMaterial;
    // Explosion lightning
    private var bangFlash:OmniLight;
    // Platform with guy
    private var axisSprite:AxisAlignedSprite;
    // Material for the platform
    private var platformMaterial:TextureMaterial;

    private function setupMaterials():void {

        bangMaterials = new Vector.<Material>();
        bangMaterials.push(new TextureMaterial(new ExternalTextureResource('decalsandspritesexample/images/bang/bang000.png')));
        bangMaterials.push(new TextureMaterial(new ExternalTextureResource('decalsandspritesexample/images/bang/bang002.png')));
        bangMaterials.push(new TextureMaterial(new ExternalTextureResource('decalsandspritesexample/images/bang/bang004.png')));
        bangMaterials.push(new TextureMaterial(new ExternalTextureResource('decalsandspritesexample/images/bang/bang006.png')));
        bangMaterials.push(new TextureMaterial(new ExternalTextureResource('decalsandspritesexample/images/bang/bang008.png')));
        bangMaterials.push(new TextureMaterial(new ExternalTextureResource('decalsandspritesexample/images/bang/bang010.png')));
        bangMaterials.push(new TextureMaterial(new ExternalTextureResource('decalsandspritesexample/images/bang/bang012.png')));
        bangMaterials.push(new TextureMaterial(new ExternalTextureResource('decalsandspritesexample/images/bang/bang014.png')));
        bangMaterials.push(new TextureMaterial(new ExternalTextureResource('decalsandspritesexample/images/bang/bang016.png')));
        bangMaterials.push(new TextureMaterial(new ExternalTextureResource('decalsandspritesexample/images/bang/bang018.png')));
        bangMaterials.push(new TextureMaterial(new ExternalTextureResource('decalsandspritesexample/images/bang/bang020.png')));

        var resources:Vector.<ExternalTextureResource> = new Vector.<ExternalTextureResource>();

        for each (var material:TextureMaterial in bangMaterials) {
            material.alphaThreshold = .5;
            resources.push(material.diffuseMap)
        }

        var wallsDiffuse:ExternalTextureResource = new ExternalTextureResource('decalsandspritesexample/images/wall-diffuse.jpg');
        resources.push(wallsDiffuse);
        var wallsSpecular:ExternalTextureResource = new ExternalTextureResource('decalsandspritesexample/images/wall-specular.jpg');
        resources.push(wallsSpecular);
        var wallsNormals:ExternalTextureResource = new ExternalTextureResource('decalsandspritesexample/images/wall-normals.jpg');
        resources.push(wallsNormals);

        var decalDiffuse:ExternalTextureResource = new ExternalTextureResource('decalsandspritesexample/images/decal-diffuse.jpg');
        resources.push(decalDiffuse);
        var decalNormals:ExternalTextureResource = new ExternalTextureResource('decalsandspritesexample/images/decal-normals.jpg');
        resources.push(decalNormals);
        var decalSpecular:ExternalTextureResource = new ExternalTextureResource('decalsandspritesexample/images/decal-specular.jpg');
        resources.push(decalSpecular);
        var decalAlpha:ExternalTextureResource = new ExternalTextureResource('decalsandspritesexample/images/decal-alpha.jpg');
        resources.push(decalAlpha);

        var platformDiffuse:ExternalTextureResource = new ExternalTextureResource('decalsandspritesexample/images/platform-diffuse.png');
        resources.push(platformDiffuse);




        var materialLoader:TexturesLoader = new TexturesLoader(stage3D.context3D);
        materialLoader.loadResources(resources);

        wallsMaterial = new StandardMaterial(wallsDiffuse, wallsNormals, wallsSpecular, null, null);
        wallsMaterial.alphaThreshold = .5;
        decalMaterial = new StandardMaterial(decalDiffuse, decalNormals, decalSpecular, null, decalAlpha);
        decalMaterial.alphaThreshold = .5;
        platformMaterial = new TextureMaterial(platformDiffuse);
        platformMaterial.alphaThreshold = .5;


    }

    public function DecalsExample() {
        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        camera = new Camera3D(1, 10000);
        camera.view = new View(stage.stageWidth, stage.stageHeight,false, 0x303030);
        addChild(camera.view);
        addChild(camera.diagram);
        camera.rotationX = -120 * Math.PI / 180;
        camera.y = -400;
        camera.z = 200;
        rootContainer.addChild(camera);
        controller = new SimpleObjectController(stage, camera, 200);
        stage3D = stage.stage3Ds[0];
        stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
        stage3D.requestContext3D();
    }


    private function prepareBang():void {
        bang = new AnimSprite(2000, 2000, bangMaterials);
        bang.alwaysOnTop = true;
        bangFlash = new OmniLight(0xf0a080, 800, 1000);
        rootContainer.addChild(bangFlash);
    }

    private function makeScene():void {
        room = new GeoSphere(2500, 5, true);
        light = new OmniLight(0xffffff, 500, 6000);
        light.intensity = 2;
        light.z = 300;
        var ambient:AmbientLight = new AmbientLight(0x505050);
        rootContainer.addChild(ambient);
        rootContainer.addChild(light);

        // Changing UVs for tiling the texture
        var uvs:Vector.<Number> = room.geometry.getAttributeValues(VertexAttributes.TEXCOORDS[0]);
        var i:String;
        for (i in uvs) {
            if (Number(i) % 2 == 0) {
                uvs[i] *= 16
            }
            else if (Number(i) % 2 == 1) {
                uvs[i] *= 8;
            }
        }
        room.geometry.setAttributeValues(VertexAttributes.TEXCOORDS[0], uvs);
        room.setMaterialToAllSurfaces(wallsMaterial);
        rootContainer.addChild(room);
        rootContainer.addEventListener(MouseEvent3D.CLICK, clickHandler);
        axisSprite = new AxisAlignedSprite(1000,500,platformMaterial);
        axisSprite.alignToView = false;
        axisSprite.z = 0;
        axisSprite.x = 2200;
        axisSprite.y = -400;
        rootContainer.addChild(axisSprite);
    }

    private function onContextCreate(e:Event):void {
        setupMaterials();
        makeScene();
        prepareBang();
        prepareCollider();
        for each (var resource:Resource in rootContainer.getResources(true)) {
            resource.upload(stage3D.context3D);
        }
        sourceGeometry.geometry.upload(stage3D.context3D);
        stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
    }

    private function prepareCollider():void {
        collider = new EllipsoidCollider(10, 10, 10)
    }

    private function enterFrameHandler(e:Event):void {
        if (bang.frame == bang.materials.length - 1 && rootContainer.contains(bang)) rootContainer.removeChild(bang);
        light.z += inc;
        if (Math.abs(light.z) > 2000) inc *= -1;
        axisSprite.z = light.z *.3;
        bang.frame++;
        if (bangFlash.intensity > 0) {
            bangFlash.attenuationBegin-= 10;
            bangFlash.attenuationEnd -= 10;
            bangFlash.intensity-=1.5;
        }
        camera.view.width = stage.stageWidth;
        camera.view.height = stage.stageHeight;
        controller.update();
        camera.render(stage3D);
    }



    private function clickHandler(e:MouseEvent3D = null):void {
        var origin:Vector3D = new Vector3D();
        var direction:Vector3D = new Vector3D();
        camera.calculateRay(origin, direction, mouseX, mouseY);
        var rayData:RayIntersectionData = room.intersectRay(origin, direction);
        bang.frame = 0;
        bang.x = rayData.point.x;
        bang.y = rayData.point.y;
        bang.z = rayData.point.z;
        rootContainer.addChild(bang);
        bangFlash.x = rayData.point.x;
        bangFlash.y = rayData.point.y;
        bangFlash.z = rayData.point.z;
        bangFlash.attenuationBegin = 800;
        bangFlash.attenuationEnd = 1000;
        bangFlash.intensity = 10;

        var start:Vector3D = camera.matrix.position;
        var disp:Vector3D = rayData.point.subtract(start);
        var point:Vector3D = new Vector3D();
        var plane:Vector3D = new Vector3D();
        collider.getCollision(start, disp, point, plane, rootContainer);

        var decal:Decal = new Decal();
        decal.geometry = sourceGeometry.geometry;
        for (var i:int = 0; i < sourceGeometry.numSurfaces; i++)
            decal.addSurface(null, sourceGeometry.getSurface(i).indexBegin, sourceGeometry.getSurface(i).numTriangles);

        decal.setMaterialToAllSurfaces(decalMaterial);
        rootContainer.addChild(decal);
        var zNormal:Vector3D = new Vector3D(0, 0, 1);
        var axis:Vector3D = plane.crossProduct(zNormal);
        var deg:Number = Vector3D.angleBetween(plane, zNormal);
        var decalMatrix:Matrix3D = decal.matrix;
        decalMatrix.appendRotation(-180 * deg / Math.PI, axis);
        decal.matrix = decalMatrix;
        decal.x = point.x;
        decal.y = point.y;
        decal.z = point.z;
    }

}
}
