"
Cool Bow and Arrow: a bow held with one controller and drawn with the other.
"
Class {
	#name : #SRBow,
	#superclass : #SRObject,
	#instVars : [
		'hand',
		'string',
		'nockedArrow',
		'launchedArrows',
		'upperString',
		'lowerString',
		'drawSound',
		'releaseSound'
	],
	#category : #'SWAGame-Bow',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow class >> accentColor [

	^ Color r: 1.0 g: 0.75 b: 0.2
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow class >> arrowHeight [

	^ 7cm
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:01'
}
SRBow class >> arrowRestPoint [

	^ 0 @ self arrowHeight @ 0
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow class >> braceHeight [

	^ 14cm
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow class >> limbLength [

	^ 55cm
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:01'
}
SRBow class >> maxAimAngle [
	"degrees the arrow may point away from the bow's axis"

	^ 35
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow class >> maxArrowSpeed [
	"meters per second at full draw"

	^ 40
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow class >> maxDraw [

	^ 55cm
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow class >> maxLaunchedArrows [

	^ 12
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow class >> minLaunchDraw [

	^ 5cm
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:01'
}
SRBow class >> restNockPoint [

	^ 0 @ self arrowHeight @ self braceHeight
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/20/2026 16:14'
}
SRBow class >> soundPath: aFileName [

	^ (SWAGameAssets assetsDirectory / 'bow' / aFileName) fullName
]

{
	#category : #menu,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow class >> xrMenuSpawn: aMenu [
	<xrMenu: #(world games) label: 'Cool Bow and Arrow' priority: 260>

	| bow |
	bow := self new.
	aMenu world addChild: bow.
	bow setTransformAt: aMenu position facingCamera: aMenu world camera.
	^ bow
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow >> addLimb: aSign color: aColor [

	| segments |
	segments := 5.
	1 to: segments do: [:index |
		self addChild: (SRCube
			color: aColor
			from: (self limbPointAt: index - 1 / segments sign: aSign)
			to: (self limbPointAt: index / segments sign: aSign)
			thickness: 3cm - (1.4cm * index / segments))].
	self addChild: (SRCube color: self class accentColor size: 2cm @ 3cm @ 2cm at: (self limbPointAt: 1 sign: aSign))
]

{
	#category : #grabbing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow >> aimsWhileHeld [

	^ true
]

{
	#category : #geometry,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:23'
}
SRBow >> arrowRotation [

	| forward up |
	forward := (self class arrowRestPoint - self nockPoint) normalized.
	up := (Vector3 up - (forward * forward y)) normalized.
	^ Quaternion forward: forward up: up
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow >> buildModel [

	| wood grip |
	wood := Color r: 0.45 g: 0.22 b: 0.1.
	grip := Color r: 0.15 g: 0.1 b: 0.25.
	self addChildren: {
		SRCube color: grip size: 3.2cm @ 12cm @ 3.6cm at: 0 @ 0 @ 0.
		SRCube color: self class accentColor size: 3.6cm @ 0.8cm @ 4cm at: 0 @ 6cm @ 0.
		SRCube color: self class accentColor size: 3.6cm @ 0.8cm @ 4cm at: 0 @ -6cm @ 0}.
	#(1 -1) do: [:sign | self addLimb: sign color: wood]
]

{
	#category : #drawing,
	#'squeak_changestamp' : 'leo-MCPServer 11/20/2026 16:14'
}
SRBow >> cancelDraw [

	nockedArrow ifNil: [^ self].
	drawSound stop.
	nockedArrow remove.
	nockedArrow := nil.
	self resetString
]

{
	#category : #collisions,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow >> collisionGeometry [

	^ SRCollisionBox new
		center: (self globalTransform localPointToGlobal: 0 @ 0 @ 6cm);
		size: 6cm @ (self class limbLength * 2) @ 16cm;
		rotation: self globalRotation;
		object: self
]

{
	#category : #grabbing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow >> dragTo: aMatrix4x4 [

	self isHeld ifFalse: [^ super dragTo: aMatrix4x4].
	self globalTransform: hand globalTransform * self holdTransform
]

{
	#category : #drawing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow >> forgetSurplusArrows [

	launchedArrows removeAllSuchThat: [:each | each parent isNil].
	[launchedArrows size > self class maxLaunchedArrows]
		whileTrue: [launchedArrows removeFirst remove]
]

{
	#category : #geometry,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow >> holdTransform [
	"puts the arrow on the hand's aim ray"

	^ Matrix4x4 withOffset: 0 @ self class arrowHeight negated @ 0
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'leo-MCPServer 11/20/2026 16:14'
}
SRBow >> initialize [

	super initialize.
	launchedArrows := OrderedCollection new.
	self name: 'Cool Bow and Arrow'.
	self buildModel.
	upperString := SRCube color: Color white size: 1 asVector3 at: 0 @ 0 @ 0.
	lowerString := SRCube color: Color white size: 1 asVector3 at: 0 @ 0 @ 0.
	string := SRBowString new.
	self addChildren: {upperString. lowerString. string}.
	self initializeSounds.
	self updateString
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'leo-MCPServer 11/20/2026 16:14'
}
SRBow >> initializeSounds [

	drawSound := SRAudioPlayer new filepath: (self class soundPath: 'bow-draw.ogg').
	releaseSound := SRAudioPlayer new filepath: (self class soundPath: 'bow-release.ogg').
	self addChildren: {drawSound. releaseSound}
]

{
	#category : #testing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow >> isApp [

	^ true
]

{
	#category : #testing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow >> isDrawing [

	^ self isHeld and: [string isGrabbed]
]

{
	#category : #testing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow >> isHeld [

	^ hand notNil
]

{
	#category : #drawing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:01'
}
SRBow >> launch: anArrow [

	| transform direction |
	self hasParent ifFalse: [^ anArrow remove].
	transform := anArrow globalTransform copy.
	direction := anArrow forward.
	self sceneRoot addChild: anArrow.
	anArrow globalTransform: transform.
	anArrow launchWith: direction * self launchSpeed.
	launchedArrows add: anArrow.
	self forgetSurplusArrows
]

{
	#category : #drawing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow >> launchSpeed [

	^ self class maxArrowSpeed * (string draw / self class maxDraw)
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow >> launchedArrows [

	^ launchedArrows
]

{
	#category : #geometry,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow >> limbPointAt: aFraction sign: aSign [

	^ 0 @ (aSign * (6cm + (self class limbLength - 6cm * aFraction))) @ (self class braceHeight * aFraction * aFraction)
]

{
	#category : #drawing,
	#'squeak_changestamp' : 'leo-MCPServer 11/20/2026 16:14'
}
SRBow >> nockArrow [

	self addChild: (nockedArrow := SRArrow new).
	drawSound play
]

{
	#category : #geometry,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:01'
}
SRBow >> nockPoint [

	^ string nock
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow >> nockedArrow [

	^ nockedArrow
]

{
	#category : #grabbing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow >> onGrabStarted: aHand [

	hand := aHand.
	aHand body visible: false.
	aHand cursor visible: false
]

{
	#category : #grabbing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow >> onGrabStopped: aHand [

	hand == aHand ifTrue: [hand := nil].
	aHand body visible: true.
	aHand cursor visible: true.
	self cancelDraw
]

{
	#category : #drawing,
	#'squeak_changestamp' : 'leo-MCPServer 11/20/2026 16:14'
}
SRBow >> release [

	| arrow |
	arrow := nockedArrow ifNil: [^ self].
	nockedArrow := nil.
	drawSound stop.
	string draw >= self class minLaunchDraw
		ifTrue: [
			releaseSound play.
			self launch: arrow]
		ifFalse: [arrow remove].
	self resetString
]

{
	#category : #drawing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow >> resetString [

	string resetDraw.
	self updateString
]

{
	#category : #stepping,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow >> step: deltaTime [

	self isDrawing
		ifTrue: [self updateDraw]
		ifFalse: [self cancelDraw]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow >> string [

	^ string
]

{
	#category : #drawing,
	#'squeak_changestamp' : 'leo-MCPServer 11/20/2026 16:14'
}
SRBow >> updateDraw [

	string updateDraw.
	nockedArrow ifNil: [self nockArrow].
	self updateString
]

{
	#category : #drawing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:01'
}
SRBow >> updateString [

	| nock |
	nock := self nockPoint.
	string localTranslation: nock.
	upperString beamFrom: (self limbPointAt: 1 sign: 1) to: nock thickness: 0.4cm.
	lowerString beamFrom: (self limbPointAt: 1 sign: -1) to: nock thickness: 0.4cm.
	nockedArrow ifNotNil: [:arrow |
		arrow
			localTranslation: nock;
			localRotation: self arrowRotation]
]

{
	#category : #grabbing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBow >> wantsGrab [

	^ true
]
