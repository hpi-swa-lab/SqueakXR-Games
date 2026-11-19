# Figures


| figure | what it shows | made by |
|---|---|---|
| [overview.drawio](overview.drawio) | the four groups of classes and who talks to whom, with the SqueakXR engine on top | hand-authored |
| [classes-uml.drawio](classes-uml.drawio) | UML class diagram. Bands are layers; **left of the middle column is cells, right is metres**; red edges end at the *same object* | hand-authored, then relaid out by Jens |
| [classes-generated.dot](classes-generated.dot) / `.pdf` | every class in the package with all its state, inheritance only | `SWAClassDiagram`, whole package |
| [classes-curated.dot](classes-curated.dot) / `.pdf` | the same tool narrowed to a mark set: the classes and members that carry the design | `SWAClassDiagram`, mark set |
| [terrain-grass-and-dirt.png](terrain-grass-and-dirt.png), [terrain-block-patterns.png](terrain-block-patterns.png) | the block patterns of the terrain shader (the second is a test row, placed for the shot and removed) | as below (journal 2026-11-02c in `squeak`) |
| [mobs-fox-trot.png](mobs-fox-trot.png), [mobs-rabbits.png](mobs-rabbits.png), [mobs-foxes-and-a-body.png](mobs-foxes-and-a-body.png) | the animals in the running desktop world | `Raylib takeScreenshotFileName:` just before `endDrawing`, camera parked on a mob (journal 2026-11-02b in `squeak`) |

The two `.dot` files are regenerable from the image and should be regenerated
rather than edited. The two `.drawio` files are drawn by hand, because the thing
they say -- which objects are shared, and what is cells versus metres -- is
carried by *position*, and no layout engine knows it.

<!-- ============================================================
     HOW THESE WERE MADE  (instructions, for whoever regenerates them)

     GENERATED (.dot): the in-image Class Diagram tool does the work.

       SWAClassDiagram openOnPackageNamed: 'SWAGame'.   "opens a window"

     Headless, to write the file directly:

       | root tuple |
       root := SWACodeRootNode new name: 'SWAGame'; addPackages: 'SWAGame'; yourself.
       tuple := root classDiagramGraphColorMode: #kind showState: true showMethods: false.
       (FileStream forceNewFileNamed: '.../classes-generated.dot')
           nextPutAll: tuple first; close.

     CURATED (.dot): same call, but on a MARK SET, so only chosen members show.
     A mark is a string: 'Class', 'Class>>selector', 'Class>>#ivar'.
     Use a PRIVATE SWAMarkSet -- SWAMarkSet default is Jens's working set.

       | marks root filterM filterI |
       marks := SWAMarkSet new.
       #('SWAGameXR' 'SWAGameXR>>step:' 'SWAGameXR>>#walkMode' ...) do: [:k | marks add: k].
       root := SWACodeMarkSetRootNode new markSet: marks; yourself.
       filterM := [:m | marks includes: m crossRefKey].
       filterI := [:i | marks includes: i crossRefKey].
       root withAllChildrenDo: [:n |
           (n isKindOf: SWACodeClassNode) ifTrue: [n methodFilter: filterM; ivarFilter: filterI]].
       (root classDiagramGraphColorMode: #kind showState: true showMethods: true) first

     Render:  dot -Tpdf classes-curated.dot -o classes-curated.pdf
     (graphviz is in WSL; there is NO drawio CLI, so Jens exports .drawio to PDF.)

     HAND-AUTHORED (.drawio): plain uncompressed mxGraphModel XML,
     host="app.diagrams.net" agent="BlindGoldi". After writing, always check:

       python3 - <<'EOF'
       import xml.etree.ElementTree as ET
       t = ET.parse('classes-uml.drawio')
       ids = {c.get('id') for c in t.getroot().iter('mxCell') if c.get('id')}
       print([c.get('id') for c in t.getroot().iter('mxCell')
              if c.get('edge') and (c.get('source') not in ids or c.get('target') not in ids)])
       EOF

     ... for: parses at all, no dangling edges, no edge whose source == target
     (a stray self-edge appears easily when a connection is dragged off a shape).

     EVERY FACT IN A FIGURE IS CHECKED AGAINST THE LIVE IMAGE FIRST.
     Identities were read, not assumed:
       xr voxelChunks space == xr space.                             "true"
       (xr voxelChunks instVarNamed: 'grid') == xr gameWorld voxels. "true"
     Method rows use the real pattern from the source, so parameter names are
     the ones in the code (heightAtX: x y: y really does name a z 'y').
     ============================================================ -->

<!-- ============================================================
     VISUAL STYLE GUIDE  (learned while editing these, mostly the hard way)

     LAYOUT IS A SECOND NOTATION.  drawio's advantage over a layout engine is
     that position means something and can be adjusted by hand. Use it:
       - bands = architectural layers, labelled, dashed, pale fill
       - put shared things physically BETWEEN the sides that share them
       - a boundary that matters (cells | metres) is a column edge
       - graphviz cannot do this: rankdir=BT put SWAGameXR in the far corner
         from SWAGameWorld because inheritance is all it knows.

     SAY IT ONCE.
       - An attribute drawn as an association edge must NOT also appear in the
         attribute compartment. What stays in the compartment is state that is
         not a relationship: flags, counts, positions (walkMode, chunkSize, x y z).
       - Deleted sticky notes: the prose in README.md carries explanation, the
         figure carries structure. A reader needs somewhere to think.

     UML LABEL PLACEMENT.
       - Role name + multiplicity belong AT THE END of the line, beside the class
         that is the attribute's TYPE (the end is owned by the opposite class).
         In drawio that is the edge label's relative geometry: x = 0.85 (-1 is
         the source end, +1 the target). Drop the y offset so it sits on the line.
       - Mid-line is for the ASSOCIATION NAME (a verb phrase), and for usage
         dependencies -- which should be dashed.
       - OMIT multiplicity 1. Show only what is not 1 (*, 0..1), so that a * means
         something. 'world 1' is noise.
       - A Dictionary-backed association can use a UML qualifier: a small box on
         the owning end holding the key ([chunkKey]), far end 0..1.

     CLASS BOXES.
       - Use the NATIVE drawio UML class: swimlane + childLayout=stackLayout,
         one child per member, and a 'line' shape child as the compartment
         separator (height 8). It spans the full width and each row is its own cell.
       - Do NOT fake it with <hr> inside an HTML label: the rule is inset by the
         label padding and stops short of the border.
       - Show full method patterns with parameter names, not bare selectors:
         'at: x at: y at: z put: aValue', not 'at:at:at:put:'.

     EDGE LABEL BACKGROUNDS.  Two independent mechanisms, and the Format panel
     only clears the first:
       1. style property     labelBackgroundColor=...   -> set to none
       2. inline HTML        <span style="background-color: ...">  -> strip it
     Beware values like light-dark(#f7fbf7, #ededed): they read as unset in dark
     mode while still painting over the line in light mode.
     labelBackgroundColor=default + defaultLabelBackgroundColor=gap is the OTHER
     intent: break the line where the text crosses it.

     COLOUR.  Pale fills by role (green simulation, yellow shared, orange
     rendering, grey external), strong colour reserved for meaning: red edges
     mean "the same object", and nothing else is red.
     ============================================================ 
-->
