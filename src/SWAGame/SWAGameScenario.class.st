"
A named set of values for the SWAGame preferences. Built-ins state only what differs from the defaults; saved ones are JSON in swagame-scenarios next to the image.
"
Class {
	#name : #SWAGameScenario,
	#superclass : #Object,
	#instVars : [
		'name',
		'values'
	],
	#category : #SWAGame,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}

{
	#category : #saving,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:14'
}
SWAGameScenario class >> all [
	^ self builtIns, self saved
]

{
	#category : #'built-ins',
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:15'
}
SWAGameScenario class >> balanced [
	^ self named: 'Balanced' overriding: #()
]

{
	#category : #parameters,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:14'
}
SWAGameScenario class >> bindingOf: aSelector in: aClass [
	"The class variable a preference getter falls back from when it is nil."
	^ (aClass class >> aSelector) literals
		detect: [:each | each isVariableBinding and: [(aClass classPool associationAt: each key ifAbsent: [nil]) == each]]
		ifNone: [nil]
]

{
	#category : #'built-ins',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameScenario class >> boomAndBust [
	"Efficient predators on a fast pasture: the foxes boom on the rabbits, then starve."
	^ self named: 'Boom and bust' overriding: #(
		#rabbit #(#reproduceChance 3)
		#fox #(#eatGain 45 #reproduceChance 1.5 #reproduceThreshold 85 #reproduceCost 45)
		#world #(#grassRegrowthPerSecond 0.025))
]

{
	#category : #'built-ins',
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:14'
}
SWAGameScenario class >> builtIns [
	^ {
		self balanced.
		self documentary.
		self oldFastPace.
		self rabbitPlague.
		self foxParadise.
		self boomAndBust}
]

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:14'
}
SWAGameScenario class >> current [
	^ self named: 'Current' values: self currentValues
]

{
	#category : #parameters,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:14'
}
SWAGameScenario class >> currentValues [
	| result |
	result := Dictionary new.
	self owners do: [:each |
		result at: each key put: (Dictionary newFrom: ((self parametersOf: each value)
			collect: [:selector | selector -> (each value perform: selector)]))].
	^ result
]

{
	#category : #parameters,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameScenario class >> defaultValues [
	"The getters' ifNil: values, read by clearing the class variables for an unpreempted moment."
	^ [| saved |
		saved := OrderedCollection new.
		self owners do: [:owner |
			(self parametersOf: owner value) do: [:selector |
				(self bindingOf: selector in: owner value) ifNotNil: [:binding |
					saved add: binding -> binding value.
					binding value: nil]]].
		[self currentValues] ensure: [
			saved do: [:each | each key value: each value]]] valueUnpreemptively
]

{
	#category : #saving,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:14'
}
SWAGameScenario class >> directory [
	"Next to the image, which is the repository, so both desktop images see the files."
	^ FileDirectory default directoryNamed: 'swagame-scenarios'
]

{
	#category : #'built-ins',
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:39'
}
SWAGameScenario class >> documentary [
	"Half the pace of Balanced, every rate together, so the populations settle
	where Balanced does."
	^ self named: 'Nature documentary' overriding: #(
		#rabbit #(#walkSpeed 0.35 #runSpeed 1.8 #burnRate 0.3 #reproduceChance 1 #restTime 7 #eatTime 6)
		#fox #(#walkSpeed 0.4 #runSpeed 2.1 #burnRate 0.4 #reproduceChance 0.5 #restTime 10 #eatTime 16)
		#world #(#grassRegrowthPerSecond 0.0075))
]

{
	#category : #'built-ins',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameScenario class >> foxParadise [
	"Far-sighted, faster foxes."
	^ self named: 'Fox paradise' overriding: #(
		#rabbit #(#detectionRange 4 #runSpeed 2.4)
		#fox #(#detectionRange 14 #runSpeed 3.4))
]

{
	#category : #saving,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:14'
}
SWAGameScenario class >> fromJson: aString [
	"Numbers only, keyed by owner and preference; anything else in the file is ignored."
	| json result |
	json := Json readFrom: aString readStream.
	result := Dictionary new.
	self owners do: [:owner |
		(json at: owner key ifAbsent: [nil]) ifNotNil: [:params |
			result at: owner key put: (Dictionary new
				addAll: ((params keys select: [:each | (params at: each) isNumber])
					collect: [:each | each asSymbol -> (params at: each)]);
				yourself)]].
	^ self named: (json at: #name ifAbsent: ['Unnamed']) values: result
]

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:15'
}
SWAGameScenario class >> named: aString overriding: anArray [
	"Built-in scenarios list only what differs, as owner, then selector and value
	pairs, so a change to a default reaches all of them."
	| merged |
	merged := self defaultValues.
	anArray pairsDo: [:owner :params |
		params pairsDo: [:selector :value | (merged at: owner) at: selector put: value]].
	^ self named: aString values: merged
]

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:14'
}
SWAGameScenario class >> named: aString values: aDictionary [
	^ self new setName: aString values: aDictionary
]

{
	#category : #saving,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:14'
}
SWAGameScenario class >> nextSavedName [
	| names n |
	names := (self saved collect: [:each | each name]) asSet.
	n := 1.
	[names includes: 'Saved ', n printString] whileTrue: [n := n + 1].
	^ 'Saved ', n printString
]

{
	#category : #'built-ins',
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:39'
}
SWAGameScenario class >> oldFastPace [
	"The tuning from before walk and run speeds were split, for comparison."
	^ self named: 'Old fast pace' overriding: #(
		#rabbit #(#walkSpeed 0.85 #runSpeed 3.4 #burnRate 2 #reproduceChance 6 #restTime 0 #eatTime 0)
		#fox #(#walkSpeed 0.95 #runSpeed 3.8 #burnRate 2.5 #reproduceChance 3 #restTime 0 #eatTime 0)
		#world #(#grassRegrowthPerSecond 0.05))
]

{
	#category : #parameters,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:34'
}
SWAGameScenario class >> ownerAt: aKey [
	^ (self owners detect: [:each | each key == aKey] ifNone: [^ nil]) value
]

{
	#category : #parameters,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:14'
}
SWAGameScenario class >> owners [
	"Keys are what the JSON files use, so renaming a class does not orphan them."
	^ {#rabbit -> SWAGameRabbit. #fox -> SWAGameFox. #world -> SWAGameWorld}
]

{
	#category : #parameters,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:14'
}
SWAGameScenario class >> parametersOf: aClass [
	"Every numeric SWAGame preference, so a new one is saved and switched without
	being listed here."
	^ ((Pragma allNamed: #preference:category:description:type: in: aClass class)
		select: [:each | (each argumentAt: 2) = 'SWAGame' and: [(each argumentAt: 4) == #Number]]
		thenCollect: [:each | each selector]) asSortedCollection asArray
]

{
	#category : #'built-ins',
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:15'
}
SWAGameScenario class >> rabbitPlague [
	^ self named: 'Rabbit plague' overriding: #(
		#rabbit #(#reproduceChance 5 #reproduceThreshold 45 #detectionRange 8)
		#fox #(#burnRate 1.2 #detectionRange 5)
		#world #(#grassRegrowthPerSecond 0.03))
]

{
	#category : #saving,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:14'
}
SWAGameScenario class >> saveCurrent [
	"From the XR menu, where there is no keyboard to type a name with."
	^ self saveCurrentAs: self nextSavedName
]

{
	#category : #saving,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:14'
}
SWAGameScenario class >> saveCurrentAs: aString [
	^ self current
		name: aString;
		save;
		yourself
]

{
	#category : #saving,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:14'
}
SWAGameScenario class >> saved [
	| dir |
	dir := self directory.
	dir exists ifFalse: [^ #()].
	^ ((dir fileNames select: [:each | each endsWith: '.json']) asSortedCollection
		collect: [:each | self fromJson: (dir readOnlyFileNamed: each do: [:file | file contents])]) asArray
]

{
	#category : #applying,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameScenario >> apply [
	"Writes the class variables and tells the games once: through the setters every value
	reconfigured every mob of every game."
	| resolved |
	resolved := self resolvedValues.
	self class owners do: [:owner |
		(resolved at: owner key) keysAndValuesDo: [:selector :value |
			(owner value perform: selector) = value ifFalse: [
				(self class bindingOf: selector in: owner value)
					ifNil: [owner value perform: selector asMutator with: value]
					ifNotNil: [:binding | binding value: value]]]].
	SWAGameMob defaultsChanged.
	SWAGameConfigPanel allInstancesDo: [:each | each refresh].
]

{
	#category : #saving,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:15'
}
SWAGameScenario >> asJson [
	"Written by hand for a fixed key order, so saving an unchanged scenario is no
	diff in git."
	^ String streamContents: [:stream |
		stream nextPut: ${; lf; tab; nextPutAll: '"name": '; nextPutAll: (Json render: name).
		self class owners do: [:owner |
			(values at: owner key ifAbsent: [nil]) ifNotNil: [:params |
				stream nextPut: $,; lf; tab; nextPutAll: (Json render: owner key asString); nextPutAll: ': {'.
				params keys asSortedCollection
					do: [:selector |
						stream lf; tab; tab; nextPutAll: (Json render: selector asString); nextPutAll: ': '.
						stream nextPutAll: (Json render: (params at: selector))]
					separatedBy: [stream nextPut: $,].
				stream lf; tab; nextPut: $}]].
		stream lf; nextPut: $}; lf]
]

{
	#category : #saving,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:14'
}
SWAGameScenario >> fileName [
	^ (name collect: [:each | each isAlphaNumeric ifTrue: [each asLowercase] ifFalse: [$-]]), '.json'
]

{
	#category : #applying,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:14'
}
SWAGameScenario >> isActive [
	| resolved |
	resolved := self resolvedValues.
	^ self class owners allSatisfy: [:owner |
		(resolved at: owner key) associations allSatisfy: [:each |
			((owner value perform: each key) - each value) abs < 1.0e-6]]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:14'
}
SWAGameScenario >> name [
	^ name
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:14'
}
SWAGameScenario >> name: aString [
	name := aString.
]

{
	#category : #printing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:14'
}
SWAGameScenario >> printOn: aStream [
	aStream nextPutAll: 'a SWAGameScenario('; nextPutAll: name; nextPut: $)
]

{
	#category : #applying,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:14'
}
SWAGameScenario >> resolvedValues [
	"A file written before a preference existed falls back to its default rather
	than keeping whatever the last scenario left behind."
	| result |
	result := self class defaultValues.
	values keysAndValuesDo: [:owner :params |
		(result includesKey: owner) ifTrue: [
			params keysAndValuesDo: [:selector :value |
				((result at: owner) includesKey: selector)
					ifTrue: [(result at: owner) at: selector put: value]]]].
	^ result
]

{
	#category : #saving,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:14'
}
SWAGameScenario >> save [
	| dir |
	dir := self class directory.
	dir assureExistence.
	dir deleteFileNamed: self fileName.
	dir forceNewFileNamed: self fileName do: [:file | file nextPutAll: self asJson].
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:14'
}
SWAGameScenario >> setName: aString values: aDictionary [
	name := aString.
	values := aDictionary.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:14'
}
SWAGameScenario >> valueOf: aSelector for: anOwnerKey [
	^ (values at: anOwnerKey ifAbsent: [^ nil]) at: aSelector ifAbsent: [nil]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:14'
}
SWAGameScenario >> values [
	^ values
]
