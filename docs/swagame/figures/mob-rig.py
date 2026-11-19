#!/usr/bin/env python3
"""Draws mob-rig.svg and mob-gait-curves.svg.

The boxes are copied from SWAGameMobModel class>>rabbit and >>fox, the pose
formulas from SWAGameMobModel>>writePose:phase:swing:eating:time: and
>>bobAt:swing:. Re-copy them when the models change.

Run: python3 mob-rig.py   (writes both SVGs next to this file)
"""
import math
import os

HERE = os.path.dirname(os.path.abspath(__file__))

# ---------------------------------------------------------------- models

def rabbit():
    fur, saddle, pink, eye, white = '#ede8de', '#c7b8a3', '#f59ead', '#261414', '#ffffff'
    m = Model('rabbit', gait='hop', stride=0.5)
    m.part('body', (0, 0), (-3, 2, -4, 3, 7, 3), fur)
    m.part('body', (0, 0), (-2, 6, -4, 2, 7, 1), saddle)
    m.part('tail', (5, -4), (-1, 4, -6, 1, 6, -4), white)
    for box, c in [((-2, 5, 2, 2, 10, 7), fur), ((-1, 7, 6, 1, 8, 7), pink),
                   ((-2, 8, 5, -1, 9, 6), eye), ((1, 8, 5, 2, 9, 6), eye),
                   ((-2, 10, 3, -1, 14, 5), fur), ((1, 10, 3, 2, 14, 5), fur),
                   ((-2, 10, 4, -1, 13, 5), pink), ((1, 10, 4, 2, 13, 5), pink)]:
        m.part('head', (6, 3), box, c)
    for box in [(-3, 0, 0, -1, 2, 2), (-2, 2, 0, -1, 3, 2), (1, 0, 0, 3, 2, 2), (1, 2, 0, 2, 3, 2)]:
        m.part('legsA', (3, 1), box, fur)
    for box in [(-3, 0, -3, -1, 2, 1), (-2, 2, -3, -1, 3, 1), (1, 0, -3, 3, 2, 1), (1, 2, -3, 2, 3, 1)]:
        m.part('legsB', (3, -1), box, fur)
    return m


def fox():
    orange, white, dark = '#e3782b', '#f5ede0', '#33211a'
    orange = '#e3782b'
    m = Model('fox', gait='trot', stride=0.8)
    m.part('body', (0, 0), (-3, 4, -6, 3, 9, 5), orange)
    m.part('body', (0, 0), (-3, 4, -4, 3, 5, 4), white)
    m.part('body', (0, 0), (-3, 4, 4, 3, 7, 5), white)
    m.part('tail', (7, -6), (-2, 5, -14, 2, 9, -6), orange)
    m.part('tail', (7, -6), (-2, 5, -14, 2, 9, -11), white)
    for box, c in [((-4, 6, 4, 4, 12, 10), orange), ((-4, 6, 4, 4, 8, 10), white),
                   ((-2, 6, 10, 2, 9, 13), white), ((-1, 8, 12, 1, 9, 13), dark),
                   ((-3, 10, 9, -2, 11, 10), dark), ((2, 10, 9, 3, 11, 10), dark),
                   ((-4, 12, 6, -1, 14, 7), orange), ((-4, 14, 6, -2, 15, 7), dark),
                   ((1, 12, 6, 4, 14, 7), orange), ((2, 14, 6, 4, 15, 7), dark)]:
        m.part('head', (9, 5), box, c)
    for limb, x, z in [('legsA', -3, 2), ('legsB', 1, 2), ('legsB', -3, -5), ('legsA', 1, -5)]:
        pivot = (5, z + 1)
        inner = x + 1 if x < 0 else x
        m.part(limb, pivot, (x, 0, z, x + 2, 4, z + 2), orange)
        m.part(limb, pivot, (x, 0, z, x + 2, 3, z + 2), dark)
        m.part(limb, pivot, (inner, 4, z, inner + 1, 6, z + 2), orange)
    return m


class Model:
    def __init__(self, name, gait, stride):
        self.name, self.gait, self.stride = name, gait, stride
        self.groups = {}  # (limb, pivotY, pivotZ) -> {(x, y, z): colour}

    def part(self, limb, pivot, box, colour):
        cells = self.groups.setdefault((limb, pivot[0], pivot[1]), {})
        x0, y0, z0, x1, y1, z1 = box
        for x in range(x0, x1):
            for y in range(y0, y1):
                for z in range(z0, z1):
                    cells[(x, y, z)] = colour

    def pose(self, phase, swing, eating=False, seconds=0.0):
        s = math.sin(phase) * swing
        if self.gait == 'hop':
            leg_a, leg_b, tail = -s, s * 1.3, 0.0
        else:
            leg_a, leg_b = s, -s
            tail = math.sin(seconds * 2.5) * 0.2 + math.sin(phase * 0.5) * 0.3 * swing
        head = 0.5 + math.sin(seconds * 14) * 0.08 if eating else 0.0
        return {'legsA': leg_a, 'legsB': leg_b, 'head': head, 'tail': tail}

    def bob(self, phase, swing):
        if self.gait == 'hop':
            return max(math.sin(phase), 0.0) * 3.0 * swing
        return abs(math.sin(phase * 2)) * 0.5 * swing


# ---------------------------------------------------------------- drawing helpers

LIMB = {  # fill tint, stroke, label
    'body':  ('#8c8c8c', '#555555', 'body (0)'),
    'legsA': ('#3d7fd1', '#1f4f8f', 'legs A (1)'),
    'legsB': ('#e5802e', '#9a4d0f', 'legs B (2)'),
    'head':  ('#43a047', '#1f6b22', 'head (3)'),
    'tail':  ('#9c5cc0', '#5e2d7d', 'tail (4)'),
}
FONT = 'font-family="Helvetica,Arial,sans-serif"'


def hex2rgb(h):
    h = h.lstrip('#')
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def mix(a, b, t):
    ra, rb = hex2rgb(a), hex2rgb(b)
    return '#%02x%02x%02x' % tuple(round(ra[i] * (1 - t) + rb[i] * t) for i in range(3))


def darken(c, f):
    r = hex2rgb(c)
    return '#%02x%02x%02x' % tuple(round(v * f) for v in r)


def rotate_yz(y, z, py, pz, a):
    """The swagameMob vertex shader for legs and head: about x through the pivot."""
    c, s = math.cos(a), math.sin(a)
    qy, qz = y - py, z - pz
    return py + c * qy - s * qz, pz + s * qy + c * qz


def draw_model(out, m, ox, oy, scale, pose, bob):
    """Side view from the animal's left (-x): +z forward is to the right, +y up.
    Painter's order by x, far side first; at equal x the body goes last so it
    covers the hips."""
    quads = []
    for (limb, py, pz), cells in m.groups.items():
        angle = pose.get(limb, 0.0) if limb in ('legsA', 'legsB', 'head') else 0.0
        tint, stroke, _ = LIMB[limb]
        for (x, y, z), colour in cells.items():
            corners = [(y, z), (y + 1, z), (y + 1, z + 1), (y, z + 1)]
            pts = []
            for cy, cz in corners:
                if angle:
                    cy, cz = rotate_yz(cy, cz, py, pz, angle)
                pts.append((ox + cz * scale, oy - (cy + bob) * scale))
            fill = mix(colour, tint, 0.55)
            if x >= 0 and limb in ('legsA', 'legsB'):
                fill, edge = darken(fill, 0.72), darken(stroke, 0.8)
            else:
                edge = stroke
            quads.append((-x, 1 if limb == 'body' else 0, pts, fill, edge))
    quads.sort(key=lambda q: (q[0], q[1]))
    for _, _, pts, fill, edge in quads:
        p = ' '.join('%.1f,%.1f' % xy for xy in pts)
        out.append('<polygon points="%s" fill="%s" stroke="%s" stroke-width="0.6"/>' % (p, fill, edge))


def pivot_dot(out, m, ox, oy, scale, bob, limbs=None, labels=True):
    seen = set()
    nearest_last = sorted(m.groups, key=lambda g: -min(x for x, _, _ in m.groups[g]))
    for (limb, py, pz) in nearest_last:
        if limb == 'body' or (limbs and limb not in limbs) or (limb, py, pz) in seen:
            continue
        seen.add((limb, py, pz))
        cx, cy = ox + pz * scale, oy - (py + bob) * scale
        _, stroke, _ = LIMB[limb]
        if limb == 'tail':
            out.append('<line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" stroke="%s" stroke-width="1.5" stroke-dasharray="4,3"/>'
                       % (cx, cy - 3.2 * scale, cx, cy + 2.2 * scale, stroke))
        out.append('<circle cx="%.1f" cy="%.1f" r="4.5" fill="white" stroke="%s" stroke-width="2"/>' % (cx, cy, stroke))
        out.append('<circle cx="%.1f" cy="%.1f" r="1.6" fill="%s"/>' % (cx, cy, stroke))


def arc(out, cx, cy, r, a0, a1, colour, label=None, lx=0, ly=0, anchor='middle'):
    """Two-headed arc, angles in degrees, 0 = right, counter-clockwise on screen."""
    x0, y0 = cx + r * math.cos(math.radians(a0)), cy - r * math.sin(math.radians(a0))
    x1, y1 = cx + r * math.cos(math.radians(a1)), cy - r * math.sin(math.radians(a1))
    large = 1 if abs(a1 - a0) > 180 else 0
    sweep = 0 if a1 > a0 else 1
    mid = colour.lstrip('#')
    out.append('<path d="M%.1f,%.1f A%.1f,%.1f 0 %d %d %.1f,%.1f" fill="none" stroke="%s" stroke-width="1.8" '
               'marker-start="url(#a%s)" marker-end="url(#a%s)"/>' % (x0, y0, r, r, large, sweep, x1, y1, colour, mid, mid))
    if label:
        text(out, lx, ly, label, colour, 12, anchor=anchor, weight='bold')


def text(out, x, y, s, colour='#222', size=12, anchor='start', weight='normal', italic=False):
    style = ' font-style="italic"' if italic else ''
    s = s.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
    out.append('<text x="%.1f" y="%.1f" %s font-size="%d" fill="%s" text-anchor="%s" font-weight="%s"%s>%s</text>'
               % (x, y, FONT, size, colour, anchor, weight, style, s))


def markers(out):
    out.append('<defs>')
    for _, stroke, _ in LIMB.values():
        mid = stroke.lstrip('#')
        out.append('<marker id="a%s" viewBox="0 0 10 10" refX="5" refY="5" markerWidth="5" markerHeight="5" orient="auto-start-reverse">'
                   '<path d="M0,0 L10,5 L0,10 z" fill="%s"/></marker>' % (mid, stroke))
    out.append('<marker id="fwd" viewBox="0 0 10 10" refX="5" refY="5" markerWidth="6" markerHeight="6" orient="auto">'
               '<path d="M0,0 L10,5 L0,10 z" fill="#444"/></marker>')
    out.append('</defs>')


def ground(out, x0, x1, y):
    out.append('<line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" stroke="#7a6a50" stroke-width="2"/>' % (x0, y, x1, y))
    for x in range(int(x0), int(x1), 10):
        out.append('<line x1="%d" y1="%.1f" x2="%d" y2="%.1f" stroke="#b5a688" stroke-width="1"/>' % (x, y + 1, x - 6, y + 7))


def panel_frame(out, x, y, w, h, title, subtitle):
    out.append('<rect x="%d" y="%d" width="%d" height="%d" rx="8" fill="#fbfbf8" stroke="#cccccc"/>' % (x, y, w, h))
    text(out, x + 12, y + 22, title, '#222', 14, weight='bold')
    text(out, x + 12, y + 40, subtitle, '#555', 11)


def deg(r):
    return '%+.2f rad' % r


# ---------------------------------------------------------------- figure 1: the rig

def rig_svg():
    S = 13
    out = []
    W, H = 1180, 785
    out.append('<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d">' % (W, H, W, H))
    markers(out)
    out.append('<rect width="100%" height="100%" fill="white"/>')
    text(out, 20, 30, 'SWAGameMobModel: one mesh per species, posed by four angles in the vertex shader', '#222', 17, weight='bold')
    text(out, 20, 50, 'Side view from the left, 1 square = 1 model pixel (1/16 block before pixelScale 0.6). '
         'Colour = limb code (vertex alpha / 32), ring = pivot (texcoords). Far-side legs are darker.', '#555', 12)

    r = rabbit()
    f = fox()

    # rabbit, rest
    px, py, pw, ph = 20, 70, 370, 330
    panel_frame(out, px, py, pw, ph, 'rabbit, at rest', 'pose = (0, 0, 0, 0): the mesh as built')
    ox, oy = px + 150, py + 280
    ground(out, px + 15, px + pw - 15, oy)
    draw_model(out, r, ox, oy, S, {}, 0)
    pivot_dot(out, r, ox, oy, S, 0)
    lp, sp = LIMB['legsA'][1], LIMB['legsB'][1]
    arc(out, ox + 1 * S, oy - 3 * S, 3.6 * S, 225, 315, lp, 'pose.x', ox + 2.2 * S, oy + 30, 'start')
    arc(out, ox - 1 * S, oy - 3 * S, 3.6 * S, 225, 315, sp, 'pose.y', ox - 2.5 * S, oy + 30, 'end')
    hc = LIMB['head'][1]
    arc(out, ox + 3 * S, oy - 6 * S, 7.0 * S, 10, 75, hc, 'pose.z  head pitch', ox + 7.5 * S, oy - 13.6 * S, 'start')
    tc = LIMB['tail'][1]
    text(out, ox - 4 * S - 8, oy - 10.4 * S, 'pose.w: tail yaw,', tc, 12, 'end', 'bold')
    text(out, ox - 4 * S - 8, oy - 9.3 * S, 'about the dashed', tc, 11, 'end')
    text(out, ox - 4 * S - 8, oy - 8.3 * S, 'vertical axis', tc, 11, 'end')
    out.append('<line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" stroke="#444" stroke-width="1.5" marker-end="url(#fwd)"/>'
               % (px + pw - 105, py + 62, px + pw - 25, py + 62))
    text(out, px + pw - 105, py + 77, '+z forward', '#444', 11)

    # rabbit, mid-hop
    phase, swing = math.pi / 2, 0.9
    pose = r.pose(phase, swing)
    bob = r.bob(phase, swing)
    px2 = px + pw + 15
    panel_frame(out, px2, py, pw, ph, 'rabbit, mid-hop  (#hop)',
                'phase \u03c0/2, swing 0.9: front legs %s, hind %s' % (deg(pose['legsA']), deg(pose['legsB'])))
    ox2 = px2 + 175
    ground(out, px2 + 15, px2 + pw - 15, oy)
    draw_model(out, r, ox2, oy, S, pose, bob)
    pivot_dot(out, r, ox2, oy, S, bob, ('legsA', 'legsB', 'head'))
    out.append('<line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" stroke="#555" stroke-width="1.2" marker-end="url(#fwd)"/>'
               % (ox2 - 7 * S, oy, ox2 - 7 * S, oy - bob * S + 2))
    text(out, ox2 - 7 * S - 6, oy - bob * S / 2 + 4, 'bob %.1f px' % bob, '#555', 11, 'end')
    text(out, px2 + 12, py + ph - 12, 'Feet leave the ground while the legs are stretched (sin phase > 0).', '#555', 11)

    # rabbit, grazing
    px3 = px2 + pw + 15
    pose = r.pose(0, 0, eating=True, seconds=0)
    panel_frame(out, px3, py, pw, ph, 'rabbit, grazing',
                'isEating: head 0.5 + 0.08 sin(14 s) rad, legs still')
    ox3 = px3 + 160
    ground(out, px3 + 15, px3 + pw - 15, oy)
    draw_model(out, r, ox3, oy, S, pose, 0)
    pivot_dot(out, r, ox3, oy, S, 0, ('head',))
    arc(out, ox3 + 3 * S, oy - 6 * S, 6.2 * S, -5, 30, hc, 'nibble', ox3 + 9.8 * S, oy - 5.5 * S, 'start')
    text(out, px3 + 12, py + ph - 26, 'Each animal\u2019s clock is offset by identityHash \\\\ 97 / 9 s,', '#555', 11)
    text(out, px3 + 12, py + ph - 12, 'so a grazing herd does not nibble in step.', '#555', 11)

    # fox, rest
    py2 = py + ph + 15
    pw2, ph2 = 565, 330
    panel_frame(out, px, py2, pw2, ph2, 'fox, at rest', 'four separate legs, one group each; A and B are the diagonal pairs')
    oyf = py2 + ph2 - 70
    oxf = px + 290
    ground(out, px + 15, px + pw2 - 15, oyf)
    draw_model(out, f, oxf, oyf, S, {}, 0)
    pivot_dot(out, f, oxf, oyf, S, 0)
    text(out, oxf + 4.5 * S, oyf + 24, 'front left: A', lp, 11, 'start', 'bold')
    text(out, oxf + 4.5 * S, oyf + 39, '(front right behind it: B)', '#666', 10, 'start')
    text(out, oxf - 5.5 * S, oyf + 24, 'hind left: B', sp, 11, 'end', 'bold')
    text(out, oxf - 5.5 * S, oyf + 39, '(hind right behind it: A)', '#666', 10, 'end')
    text(out, oxf - 6 * S, oyf - 10.3 * S, 'tail: pose.w', tc, 12, 'middle', 'bold')
    text(out, oxf + 9 * S, oyf - 15.6 * S, 'head: pose.z', hc, 12, 'middle', 'bold')

    # fox, trot
    phase, swing = math.pi / 2, 0.6
    pose = f.pose(phase, swing)
    pxf2 = px + pw2 + 20
    panel_frame(out, pxf2, py2, pw2, ph2, 'fox, trotting  (#trot)',
                'phase \u03c0/2, swing 0.6: legs A %s, legs B %s' % (deg(pose['legsA']), deg(pose['legsB'])))
    oxf2 = pxf2 + 290
    ground(out, pxf2 + 15, pxf2 + pw2 - 15, oyf)
    draw_model(out, f, oxf2, oyf, S, pose, f.bob(phase, swing))
    pivot_dot(out, f, oxf2, oyf, S, 0, ('legsA', 'legsB'))
    text(out, pxf2 + 12, py2 + ph2 - 26, 'A positive angle swings the foot backwards. Front left and hind right (A) push back while', '#555', 11)
    text(out, pxf2 + 12, py2 + ph2 - 12, 'front right and hind left (B) reach forward; half a stride later they swap.', '#555', 11)

    # legend
    ly = H - 14
    lx = 20
    text(out, lx, ly, 'limb code:', '#222', 12, weight='bold')
    lx += 75
    for limb in ('body', 'legsA', 'legsB', 'head', 'tail'):
        tint, stroke, label = LIMB[limb]
        out.append('<rect x="%d" y="%d" width="14" height="14" fill="%s" stroke="%s"/>' % (lx, ly - 11, mix('#ffffff', tint, 0.55), stroke))
        text(out, lx + 20, ly, label, '#222', 12)
        lx += 115
    text(out, lx + 10, ly, 'Body (0) is never moved by the shader.', '#555', 12)

    out.append('</svg>')
    return '\n'.join(out)


# ---------------------------------------------------------------- figure 2: curves over one stride

def curves_svg():
    W, H = 1180, 380
    out = ['<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d">' % (W, H, W, H)]
    markers(out)
    out.append('<rect width="100%" height="100%" fill="white"/>')
    text(out, 20, 28, 'One stride: the pose as a function of phase (writePose:phase:swing:eating:time:, bobAt:swing:)', '#222', 16, weight='bold')
    text(out, 20, 47, 'phase grows by 2\u03c0 per stride walked (rabbit 0.5 cells, fox 0.8 cells), so standing still freezes the curve '
         'and running moves along it faster.', '#555', 12)

    def plot(x0, title, model, swing):
        w, h = 540, 210
        y0 = 80
        out.append('<rect x="%d" y="%d" width="%d" height="%d" fill="#fbfbf8" stroke="#ccc"/>' % (x0, y0, w, h))
        text(out, x0, y0 - 8, title, '#222', 13, weight='bold')
        lo, hi = -1.3, 1.3
        mid = y0 + h * hi / (hi - lo)

        def Y(v):
            return y0 + h * (hi - v) / (hi - lo)

        def X(p):
            return x0 + w * p / (2 * math.pi)
        out.append('<line x1="%d" y1="%.1f" x2="%d" y2="%.1f" stroke="#999"/>' % (x0, mid, x0 + w, mid))
        for v in (-1, -0.5, 0.5, 1):
            out.append('<line x1="%d" y1="%.1f" x2="%d" y2="%.1f" stroke="#e4e4e4"/>' % (x0, Y(v), x0 + w, Y(v)))
            text(out, x0 - 5, Y(v) + 4, '%+.1f' % v, '#888', 10, 'end')
        text(out, x0 - 5, mid + 4, '0', '#888', 10, 'end')
        for k, lab in enumerate(['0', '\u03c0/2', '\u03c0', '3\u03c0/2', '2\u03c0']):
            xx = X(k * math.pi / 2)
            out.append('<line x1="%.1f" y1="%d" x2="%.1f" y2="%d" stroke="#e4e4e4"/>' % (xx, y0, xx, y0 + h))
            text(out, xx, y0 + h + 15, lab, '#666', 11, 'middle')
        text(out, x0 + w, y0 + h + 30, 'phase over one stride', '#666', 11, 'end')
        text(out, x0 + 4, y0 + 14, 'rad', '#888', 10)

        series = [('legsA', LIMB['legsA'][1], 'legs A', ''), ('legsB', LIMB['legsB'][1], 'legs B', '')]
        if model.gait == 'trot':
            series.append(('tail', LIMB['tail'][1], 'tail, stride part (period: two strides)', '5,3'))
        for key, colour, label, dash in series:
            pts = []
            for i in range(201):
                p = 2 * math.pi * i / 200
                pose = model.pose(p, swing)
                v = pose[key]
                if key == 'tail':
                    v = math.sin(p * 0.5) * 0.3 * swing
                pts.append('%.1f,%.1f' % (X(p), Y(v)))
            d = ' stroke-dasharray="%s"' % dash if dash else ''
            out.append('<polyline points="%s" fill="none" stroke="%s" stroke-width="2.2"%s/>' % (' '.join(pts), colour, d))
        pts = []
        for i in range(201):
            p = 2 * math.pi * i / 200
            pts.append('%.1f,%.1f' % (X(p), Y(model.bob(p, swing) / 3.0)))
        out.append('<polygon points="%.1f,%.1f %s %.1f,%.1f" fill="#88888833" stroke="#666" stroke-width="1.2"/>'
                   % (X(0), mid, ' '.join(pts), X(2 * math.pi), mid))
        ly = y0 + h + 52
        lx = x0
        for key, colour, label, dash in series + [('bob', '#666', 'bob (px / 3, grey area)', '')]:
            d = ' stroke-dasharray="%s"' % dash if dash else ''
            out.append('<line x1="%d" y1="%d" x2="%d" y2="%d" stroke="%s" stroke-width="2.2"%s/>' % (lx, ly - 4, lx + 22, ly - 4, colour, d))
            text(out, lx + 28, ly, label, '#222', 11)
            lx += 40 + 6.5 * len(label)

    r, f = rabbit(), fox()
    plot(60, 'rabbit #hop, swing 0.9:  A = -s,  B = 1.3 s,  bob = 3 \u00b7 max(sin, 0) \u00b7 swing', r, 0.9)
    plot(630, 'fox #trot, swing 0.6:  A = s,  B = -s,  bob = 0.5 \u00b7 |sin 2\u03c6| \u00b7 swing', f, 0.6)
    text(out, 630, H - 8, 'The tail also wags on the clock, 0.2 sin(2.5 s), whether or not the fox moves (not plotted).', '#555', 11)
    text(out, 60, H - 8, 's = sin(phase) \u00b7 swing. Front and hind legs swing against each other; the body lifts in the stretched half.', '#555', 11)
    out.append('</svg>')
    return '\n'.join(out)


if __name__ == '__main__':
    with open(os.path.join(HERE, 'mob-rig.svg'), 'w') as fh:
        fh.write(rig_svg())
    with open(os.path.join(HERE, 'mob-gait-curves.svg'), 'w') as fh:
        fh.write(curves_svg())
