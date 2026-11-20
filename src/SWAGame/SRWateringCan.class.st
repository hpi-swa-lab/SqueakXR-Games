"
A grabbable watering can that pours drops from its spout while tilted.
"
Class {
	#name : #SRWateringCan,
	#superclass : #SRObject,
	#instVars : [
		'drops',
		'emissionDebt'
	],
	#category : #'SWAGame-WateringCan',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCan class >> dropsPerSecond [

	^ 50
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCan class >> localSpoutBase [

	^ 0 @ -3cm @ -7cm
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCan class >> localSpoutDirection [

	^ 0 @ self spoutAngle degreesToRadians sin @ self spoutAngle degreesToRadians cos negated
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCan class >> localSpoutTip [

	^ self localSpoutBase + (self localSpoutDirection * self spoutLength)
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCan class >> maxDrops [

	^ 60
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCan class >> pourSpeed [

	^ 0.6
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCan class >> pourSpread [

	^ 0.15
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCan class >> pourThreshold [
	"y of the spout direction below which water flows"

	^ -0.2
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCan class >> spoutAngle [
	"degrees above the horizontal while upright"

	^ 35
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCan class >> spoutLength [

	^ 22cm
]

{
	#category : #building,
	#'squeak_changestamp' : 'leo-MCPServer 11/20/2026 16:19'
}
SRWateringCan >> addPart: aColor size: sizeVector3 at: positionVector3 [

	^ self addPart: aColor size: sizeVector3 at: positionVector3 tilt: 0
]

{
	#category : #building,
	#'squeak_changestamp' : 'leo-MCPServer 11/20/2026 16:19'
}
SRWateringCan >> addPart: aColor size: sizeVector3 at: positionVector3 tilt: degreesAroundRight [

	| part |
	part := SRCube new
		color: aColor;
		scale: sizeVector3;
		translation: positionVector3;
		rotation: (Quaternion angle: degreesAroundRight axis: Vector3 right);
		ignoreCollision: true;
		yourself.
	self addChild: part.
	^ part
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCan >> buildModel [

	| body dark spoutAngle |
	body := Color r: 0.2 g: 0.55 b: 0.35.
	dark := Color r: 0.12 g: 0.3 b: 0.2.
	spoutAngle := self class spoutAngle.
	
	self addPart: body size: 14cm @ 16cm @ 14cm at: 0 @ 0 @ 0.
	self addPart: dark size: 14.4cm @ 1cm @ 14.4cm at: 0 @ 7.5cm @ 0.
	self addPart: (Color r: 0.35 g: 0.6 b: 1.0) size: 10cm @ 0.4cm @ 10cm at: 0 @ 8.1cm @ 0.
	
	self addPart: dark size: 2cm @ 2cm @ 14cm at: 0 @ 12cm @ 2cm.
	self addPart: dark size: 2cm @ 4cm @ 2cm at: 0 @ 9.5cm @ -4cm.
	self addPart: dark size: 2cm @ 4cm @ 2cm at: 0 @ 9.5cm @ 8cm.
	
	self addPart: body size: 2.2cm @ 2.2cm @ self class spoutLength at: self class localSpoutBase + (self class localSpoutDirection * (self class spoutLength / 2)) tilt: spoutAngle.
	self addPart: dark size: 4cm @ 4cm @ 1.5cm at: self class localSpoutTip tilt: spoutAngle.
]

{
	#category : #collisions,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCan >> collisionGeometry [

	^ SRCollisionBox new
		center: (self globalTransform localPointToGlobal: 0 @ 2cm @ -6cm);
		size: 16cm @ 22cm @ 36cm;
		rotation: self globalRotation;
		object: self
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCan >> drops [

	^ drops
]

{
	#category : #pouring,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCan >> emitDrop [

	| drop |
	(parent isNil or: [drops size >= self class maxDrops]) ifTrue: [^ self].
	
	drop := SRWaterDrop new
		velocity: (self spoutDirection * self class pourSpeed) + self jitter;
		yourself.
	self sceneRoot addChild: drop.
	drop globalTranslation: self spoutTip.
	drops add: drop.
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCan >> initialize [

	super initialize.
	
	drops := OrderedCollection new.
	emissionDebt := 0.
	self buildModel.
]

{
	#category : #testing,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCan >> isPouring [

	^ self spoutDirection y < self class pourThreshold
]

{
	#category : #pouring,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCan >> jitter [

	^ (ThreadSafeRandom value next - 0.5) @ (ThreadSafeRandom value next - 0.5) @ (ThreadSafeRandom value next - 0.5) * self class pourSpread
]

{
	#category : #pouring,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCan >> pruneDrops [

	drops removeAllSuchThat: [:each | each parent isNil].
]

{
	#category : #pouring,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCan >> spoutDirection [

	^ (self globalTransform localDirToGlobal: self class localSpoutDirection) normalize
]

{
	#category : #pouring,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCan >> spoutTip [

	^ self globalTransform localPointToGlobal: self class localSpoutTip
]

{
	#category : #stepping,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCan >> step: deltaTime [

	self pruneDrops.
	self isPouring ifFalse: [
		emissionDebt := 0.
		^ self].
	
	emissionDebt := emissionDebt + (deltaTime * self class dropsPerSecond) min: self class maxDrops.
	[emissionDebt >= 1] whileTrue: [
		emissionDebt := emissionDebt - 1.
		self emitDrop].
]

{
	#category : #grabbing,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCan >> wantsGrab [

	^ true
]
