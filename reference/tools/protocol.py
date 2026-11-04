import re, html, sys, textwrap
lines = open('sect1-9.xml').read().split('\n')
enc = open('encoding.xml').read().split('\n')

def text(xml):
    t = re.sub(r'<indexterm.*?</indexterm>', '', xml, flags=re.S)
    t = re.sub(r'</entry>\s*<entry[^>]*>', '   ', t)
    t = re.sub(r'</(para|row|title|entry)>', '\n', t)
    t = re.sub(r'<[^>]+>', '', t)
    t = html.unescape(t)
    out, blank = [], False
    for l in t.split('\n'):
        l = re.sub(r'\s+', ' ', l).strip()
        if not l:
            if not blank and out: out.append('')
            blank = True
        else:
            out.append(l); blank = False
    return '\n'.join(out).strip()

def wrap(t, width=79):
    return '\n'.join(textwrap.fill(p, width) if len(p) > width else p for p in t.split('\n'))

def rule(title):
    return f'\n{"=" * 72}\n{title}\n{"=" * 72}\n'

out = ['''X Window System Protocol, excerpts about mask arguments.

Source: https://gitlab.freedesktop.org/xorg/proto/xorgproto, specs/xproto,
master at 6d3907b6d5dc4aa7d7ee6ee5d7d8714e7466630b:
  sect1-9.xml, the requests, in DocBook: converted to plain text here;
  encoding.xml, the bit encodings, already plain text.
Copyright the X Consortium and The Open Group; see the spec for its license.''']

s = next(i for i, l in enumerate(lines) if 'id="types:EVENT"' in l) - 2
e = next(i for i in range(s, len(lines)) if '</tbody>' in lines[i])
out.append(rule(f'Common Types (sect1-9.xml lines {s+1}-{e}): what the sets hold'))
out.append(wrap(text('\n'.join(lines[s:e]))))

out.append(rule('Encoding (encoding.xml lines 440-499): the bits of each set'))
out.append('Bits marked "unused but must be zero" are the ones that get a BadValue.\n')
out.append('\n'.join(enc[439:499]))

for name in ['ChangeWindowAttributes', 'GrabPointer', 'ChangeActivePointerGrab',
             'GrabButton', 'GrabKey']:
    a = next(i for i, l in enumerate(lines) if f'id="requests:{name}"' in l)
    b = next(i for i in range(a + 1, len(lines)) if '<section id=' in lines[i])
    out.append(rule(f'{name} (sect1-9.xml lines {a+1}-{b})'))
    out.append(wrap(text('\n'.join(lines[a:b]))))

out.append(rule('Request encodings (encoding.xml): the width of each mask field'))
out.append('The grabs\' event-mask and modifiers are 2 bytes wide: Xlib truncates the\nunsigned int it is given to fit (see xlib.c).\n')
for name in ['ChangeWindowAttributes', 'GrabPointer', 'GrabButton',
             'ChangeActivePointerGrab', 'GrabKey']:
    i = next(i for i, l in enumerate(enc) if f'linkend="requests:{name}"' in l)
    j = next(j for j in range(i + 1, len(enc)) if enc[j].startswith('<link linkend="requests:'))
    out.append(f'-- encoding.xml lines {i+1}-{j}')
    out.append(re.sub(r'<[^>]+>', '', '\n'.join(enc[i:j])).rstrip() + '\n')
open(sys.argv[1] + '/protocol.txt', 'w').write('\n'.join(out) + '\n')
