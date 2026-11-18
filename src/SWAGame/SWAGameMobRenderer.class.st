"
Draws rabbits and foxes as animated SWAGameMobModel meshes, one draw call each.
"
Class {
	#name : #SWAGameMobRenderer,
	#superclass : #Object,
	#instVars : [
		'gaits',
		'models',
		'meshes',
		'shader',
		'material',
		'poseLoc',
		'tintLoc',
		'rlTransform',
		'poseBuffer',
		'tintBuffer',
		'tint',
		'rotation',
		'transform',
		'failed',
		'retired'
	],
	#category : #'SWAGame-XR',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #'shader sources',
	#'squeak_changestamp' : 'MCPServer (leo) 11/3/2026 12:04'
}
SWAGameMobRenderer class >> swagameMob [
	<shaderSource: #swagameMob>
	"Vertex colour alpha is the limb code (times 32), texcoords its pivot y z. Pose: legs A, legs B, head pitch, tail yaw, in radians."
	^ {
		#uniforms -> #(pose tint).
		#vert -> '
#version 450

layout(location = 0) in vec3 vertexPosition;
layout(location = 1) in vec2 vertexTexCoord;
layout(location = 2) in vec3 vertexNormal;
layout(location = 3) in vec4 vertexColor;

layout(location = 0) uniform mat4 mvp;
layout(location = 1) uniform mat4 matNormal;
layout(location = 3) uniform vec4 pose;
layout(location = 5) uniform mat4 matModel;

layout(location = 0) out vec4 fragColor;
layout(location = 1) out vec3 fragNormal;
layout(location = 2) out vec3 fragPosition;

void main()
{
    float limb = floor(vertexColor.a * 255.0 / 32.0 + 0.5);
    vec3 p = vertexPosition;
    vec3 n = vertexNormal;
    vec2 pivot = vertexTexCoord;

    if (limb > 0.5 && limb < 3.5) {
        float a = limb < 1.5 ? pose.x : (limb < 2.5 ? pose.y : pose.z);
        float c = cos(a);
        float s = sin(a);
        vec2 q = vec2(p.y - pivot.x, p.z - pivot.y);
        p.y = pivot.x + c * q.x - s * q.y;
        p.z = pivot.y + s * q.x + c * q.y;
        n.yz = vec2(c * n.y - s * n.z, s * n.y + c * n.z);
    } else if (limb > 3.5) {
        float c = cos(pose.w);
        float s = sin(pose.w);
        vec2 q = vec2(p.x, p.z - pivot.y);
        p.x = c * q.x + s * q.y;
        p.z = pivot.y - s * q.x + c * q.y;
        n.xz = vec2(c * n.x + s * n.z, c * n.z - s * n.x);
    }

    fragColor = vec4(vertexColor.rgb, 1.0);
    fragNormal = normalize(vec3(matNormal * vec4(n, 0.0)));
    fragPosition = vec3(matModel * vec4(p, 1.0));
    gl_Position = mvp * vec4(p, 1.0);
}
'.
		#frag -> ('
#version 450
', (SRLight glslLightingFrom: 6), '
layout(location = 0) in vec4 fragColor;
layout(location = 1) in vec3 fragNormal;
layout(location = 2) in vec3 fragPosition;

layout(location = 2) uniform vec4 colDiffuse;
layout(location = 4) uniform vec4 tint;

layout(location = 0) out vec4 finalColor;

void main()
{
    vec3 diffuse = diffuseLighting(fragPosition, normalize(fragNormal));
    finalColor = vec4(fragColor.rgb * colDiffuse.rgb * tint.rgb * diffuse, 1.0);
}
')
	} as: Dictionary
]

{
	#category : #transforming,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:27'
}
SWAGameMobRenderer >> combine: aMatrix4x4 scale: scale x: x y: y z: z [
	"transform := aMatrix4x4 * [scale * rotation | x y z], row-major."
	| g |
	g := aMatrix4x4.
	0 to: 3 do: [:row |
		| a1 a2 a3 |
		a1 := g at: row * 4 + 1.
		a2 := g at: row * 4 + 2.
		a3 := g at: row * 4 + 3.
		1 to: 3 do: [:col |
			transform
				at: row * 4 + col
				put: ((a1 * (rotation at: col)) + (a2 * (rotation at: col + 3)) + (a3 * (rotation at: col + 6))) * scale].
		transform at: row * 4 + 4 put: (a1 * x) + (a2 * y) + (a3 * z) + (g at: row * 4 + 4)].
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:13'
}
SWAGameMobRenderer >> drawEntry: entry t: t transform: aMatrix4x4 worldScale: worldScale material: rlMaterial time: seconds [
	| mob model gait position scale x y z phase swing |
	mob := entry mob.
	model := self modelFor: mob.
	gait := entry gait.
	position := entry positionAt: t.
	x := position x.
	y := position y - (mob height / 2 * worldScale).
	z := position z.
	scale := worldScale / 16.0 * model pixelScale.
	mob isChild ifTrue: [scale := scale * 0.6].
	entry isBody
		ifFalse: [
			phase := gait phaseAt: t.
			swing := gait swingAt: t.
			y := y + ((model bobAt: phase swing: swing) * scale)]
		ifTrue: [
			scale := scale * (0.4 + (0.6 * entry remains)).
			y := y + (model lieLift * scale).
			phase := swing := 0.0].
	model
		writePose: poseBuffer
		phase: phase
		swing: swing
		eating: (entry isBody not and: [entry isEating])
		time: seconds + (mob identityHash \\ 97 / 9.0).
	Raylib setShaderValueShader: shader internalShader locIndex: poseLoc value: poseBuffer uniformType: 3.
	self tint: (entry isBody ifTrue: [0.6] ifFalse: [1.0]).
	self rotateYaw: (gait yawAt: t) lying: entry isBody.
	self combine: aMatrix4x4 scale: scale x: x y: y z: z.
	self writeTransform.
	Raylib drawMesh: (self meshFor: mob) internalMesh material: rlMaterial transform: rlTransform.
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:27'
}
SWAGameMobRenderer >> ensureMaterial [
	"Answers false when there is no shader, so the caller draws cubes instead. On the Quest the transpiled GLSL must already be in the ShaderCache: there is no transpiler on the headset."
	material ifNotNil: [^ true].
	failed ifTrue: [^ false].
	(SRShader hasCachedShader: #swagameMob) ifFalse: [
		SRShader canTranspile ifFalse: [failed := true. ^ false].
		SRShader transpileShaderNamed: #swagameMob].
	shader := SRShader swagameMob.
	shader internalShader id > 0 ifFalse: [failed := true. ^ false].
	poseLoc := shader uniformLocAt: #pose.
	tintLoc := shader uniformLocAt: #tint.
	material := SRMaterial new.
	material shader: shader.
	^ true
]

{
	#category : #models,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:38'
}
SWAGameMobRenderer >> forgetModels [
	"After a change to SWAGameMobModel class>>rabbit or >>fox. The GPU copies are released by the render process, at its next frame."
	retired := (retired ifNil: [#()]), meshes values.
	models := IdentityDictionary new.
	meshes := IdentityDictionary new.
	material := nil.
]

{
	#category : #gaits,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:27'
}
SWAGameMobRenderer >> gaitFor: aMob [
	"at:ifAbsentPut: would make a block per mob per tick."
	^ (gaits at: aMob ifAbsent: nil)
		ifNil: [gaits at: aMob put: SWAGameMobGait new]
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:27'
}
SWAGameMobRenderer >> initialize [
	super initialize.
	gaits := IdentityDictionary new.
	models := IdentityDictionary new.
	meshes := IdentityDictionary new.
	rlTransform := RlMatrix new.
	poseBuffer := ByteArray new: 16.
	tintBuffer := ByteArray new: 16.
	rotation := Array new: 9.
	transform := Array new: 16.
	failed := false.
]

{
	#category : #models,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameMobRenderer >> meshFor: aMob [
	^ (meshes at: aMob modelKey ifAbsent: nil)
		ifNil: [meshes at: aMob modelKey put: (self modelFor: aMob) newMesh]
]

{
	#category : #models,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameMobRenderer >> modelFor: aMob [
	^ (models at: aMob modelKey ifAbsent: nil)
		ifNil: [models at: aMob modelKey put: aMob newModel]
]

{
	#category : #gaits,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:27'
}
SWAGameMobRenderer >> noteTickOf: aMob from: fromPos to: toPos worldScale: worldScale seconds: seconds [
	| dx dz |
	dx := toPos x - fromPos x.
	dz := toPos z - fromPos z.
	^ (self gaitFor: aMob)
		advance: ((dx * dx) + (dz * dz)) sqrt / worldScale
		in: seconds
		headingX: aMob vx
		z: aMob vz
		stride: (self modelFor: aMob) strideCells;
		yourself
]

{
	#category : #releasing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:03'
}
SWAGameMobRenderer >> onCacheInvalidated [
	"The GL context is gone. Retired meshes are dropped, not unloaded: their ids may name something else in the new context."
	meshes do: [:mesh | mesh onCacheInvalidated].
	retired := nil.
	material ifNotNil: [material onCacheInvalidated].
	material := nil.
	shader ifNotNil: [shader onCacheInvalidated].
	shader := nil.
]

{
	#category : #gaits,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:27'
}
SWAGameMobRenderer >> pruneGaitsBeyond: aCount [
	gaits size > aCount ifFalse: [^ self].
	(gaits keys select: [:mob | mob isGone]) do: [:mob | gaits removeKey: mob].
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (leo) 11/3/2026 12:04'
}
SWAGameMobRenderer >> renderEntries: entries t: t transform: aMatrix4x4 worldScale: worldScale on: aSRRenderer [
	"entries as built by SWAGameXR>>buildMobAnimationData. Answers whether the mobs were drawn."
	| rlMaterial seconds |
	retired ifNotNil: [
		retired do: [:mesh | mesh unload].
		retired := nil].
	self ensureMaterial ifFalse: [^ false].
	rlMaterial := material internalMaterialFor: aSRRenderer.
	aSRRenderer applyLightingTo: shader.
	seconds := Time millisecondClockValue / 1000.0.
	tint := nil.
	entries do: [:entry |
		self drawEntry: entry t: t transform: aMatrix4x4 worldScale: worldScale material: rlMaterial time: seconds].
	^ true
]

{
	#category : #transforming,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:27'
}
SWAGameMobRenderer >> rotateYaw: yaw lying: isLying [
	"Row-major. Lying is a quarter roll about the animal's own forward axis, onto its side, before the yaw."
	| c s |
	c := yaw cos.
	s := yaw sin.
	isLying
		ifTrue: [
			rotation
				at: 1 put: 0.0; at: 2 put: c negated; at: 3 put: s;
				at: 4 put: 1.0; at: 5 put: 0.0; at: 6 put: 0.0;
				at: 7 put: 0.0; at: 8 put: s; at: 9 put: c]
		ifFalse: [
			rotation
				at: 1 put: c; at: 2 put: 0.0; at: 3 put: s;
				at: 4 put: 0.0; at: 5 put: 1.0; at: 6 put: 0.0;
				at: 7 put: s negated; at: 8 put: 0.0; at: 9 put: c].
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:27'
}
SWAGameMobRenderer >> tint: aFloat [
	tint = aFloat ifTrue: [^ self].
	tint := aFloat.
	tintBuffer
		floatAt: 1 put: aFloat;
		floatAt: 5 put: aFloat;
		floatAt: 9 put: aFloat;
		floatAt: 13 put: 1.0.
	Raylib setShaderValueShader: shader internalShader locIndex: tintLoc value: tintBuffer uniformType: 3.
]

{
	#category : #releasing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:27'
}
SWAGameMobRenderer >> unloadMeshes [
	meshes do: [:mesh | mesh unload].
	meshes := IdentityDictionary new.
]

{
	#category : #transforming,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:27'
}
SWAGameMobRenderer >> writeTransform [
	rlTransform
		m0: (transform at: 1); m4: (transform at: 2); m8: (transform at: 3); m12: (transform at: 4);
		m1: (transform at: 5); m5: (transform at: 6); m9: (transform at: 7); m13: (transform at: 8);
		m2: (transform at: 9); m6: (transform at: 10); m10: (transform at: 11); m14: (transform at: 12);
		m3: (transform at: 13); m7: (transform at: 14); m11: (transform at: 15); m15: (transform at: 16).
]
