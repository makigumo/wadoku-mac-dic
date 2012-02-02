#!/usr/bin/env python
# encoding: utf-8

"""romkan.py - a Python rewrite of the Perl Romaji<->Kana conversion module.

Romkan Copyright (C) 2000 Satoru Takabayashi <satoru-t@is.aist-nara.ac.jp>

romkan.py Copyright (C) 2006 Eric Nichols <eric-n@is.naist.jp>
    All rights reserved.
    This is free software with ABSOLUTELY NO WARRANTY.

You can redistribute it and/or modify it under the terms of
the GNU General Public License version 2.

Modified by Jason Moiron to work with utf-8 instead of euc-jp
"""

__author__  = "Jason Moiron"
__author_email__  = "jmoiron@jmoiron.net"
__version__ = "0.02u"
__revision__ = "1"

import re

def get_kunreitab():
    """get_kunreitab() -> string

    Reads kana<->kunrei conversion table into string.

    Table is taken from KAKASI <http://kakasi.namazu.org/> and has been
    modified.

    """
    return """
ぁ	xa	あ	a	ぃ	xi	い	i	ぅ	xu
う	u	う゛	vu	う゛ぁ	va	う゛ぃ	vi 	う゛ぇ	ve
う゛ぉ	vo	ぇ	xe	え	e	ぉ	xo	お	o

か	ka	が	ga	き	ki	きゃ	kya	きゅ	kyu
きょ	kyo	ぎ	gi	ぎゃ	gya	ぎゅ	gyu	ぎょ	gyo
く	ku	ぐ	gu	け	ke	げ	ge	こ	ko
ご	go

さ	sa	ざ	za	し	si	しゃ	sya	しゅ	syu
しょ	syo	じ	zi	じゃ	zya	じゅ	zyu	じょ	zyo
す	su	ず	zu	せ	se	ぜ	ze	そ	so
ぞ	zo

た	ta	だ	da	ち	ti	ちゃ	tya	ちゅ	tyu
ちょ	tyo	ぢ	di	ぢゃ	dya	ぢゅ	dyu	ぢょ	dyo

っ	xtu
っう゛	vvu	っう゛ぁ	vva	っう゛ぃ	vvi
っう゛ぇ	vve	っう゛ぉ	vvo
っか	kka	っが	gga	っき	kki	っきゃ	kkya
っきゅ	kkyu	っきょ	kkyo	っぎ	ggi	っぎゃ	ggya
っぎゅ	ggyu	っぎょ	ggyo	っく	kku	っぐ	ggu
っけ	kke	っげ	gge	っこ	kko	っご	ggo	っさ	ssa
っざ	zza	っし	ssi	っしゃ	ssya
っしゅ	ssyu	っしょ	ssho
っじ	zzi	っじゃ	zzya	っじゅ	zzyu	っじょ	zzyo
っす	ssu	っず	zzu	っせ	sse	っぜ	zze	っそ	sso
っぞ	zzo	った	tta	っだ	dda	っち	tti
っちゃ	ttya	っちゅ	ttyu	っちょ	ttyo	っぢ	ddi
っぢゃ	ddya	っぢゅ	ddyu	っぢょ	ddyo	っつ	ttu
っづ	ddu	って	tte	っで	dde	っと	tto	っど	ddo
っは	hha	っば	bba	っぱ	ppa	っひ	hhi
っひゃ	hhya	っひゅ	hhyu	っひょ	hhyo	っび	bbi
っびゃ	bbya	っびゅ	bbyu	っびょ	bbyo	っぴ	ppi
っぴゃ	ppya	っぴゅ	ppyu	っぴょ	ppyo	っふ	hhu
っふぁ	ffa	っふぃ	ffi	っふぇ	ffe	っふぉ	ffo
っぶ	bbu	っぷ	ppu	っへ	hhe	っべ	bbe	っぺ    ppe
っほ	hho	っぼ	bbo	っぽ	ppo	っや	yya	っゆ	yyu
っよ	yyo	っら	rra	っり	rri	っりゃ	rrya
っりゅ	rryu	っりょ	rryo	っる	rru	っれ	rre
っろ	rro

つ	tu	づ	du	て	te	で	de	と	to
ど	do

な	na	に	ni	にゃ	nya	にゅ	nyu	にょ	nyo
ぬ	nu	ね	ne	の	no

は	ha	ば	ba	ぱ	pa	ひ	hi	ひゃ	hya
ひゅ	hyu	ひょ	hyo	び	bi	びゃ	bya	びゅ	byu
びょ	byo	ぴ	pi	ぴゃ	pya	ぴゅ	pyu	ぴょ	pyo
ふ	hu	ふぁ	fa	ふぃ	fi	ふぇ	fe	ふぉ	fo
ぶ	bu	ぷ	pu	へ	he	べ	be	ぺ	pe
ほ	ho	ぼ	bo	ぽ	po

ま	ma	み	mi	みゃ	mya	みゅ	myu	みょ	myo
む	mu	め	me	も	mo

ゃ	xya	や	ya	ゅ	xyu	ゆ	yu	ょ	xyo
よ	yo

ら	ra	り	ri	りゃ	rya	りゅ	ryu	りょ	ryo
る	ru	れ	re	ろ	ro

ゎ	xwa	わ	wa	ゐ	wi	ゑ	we
を	wo	ん	n

ん     n'
でぃ   dyi
ー     -
ちぇ    tye
っちぇ	ttye
"""

def get_hepburntab():
    """get_hepburntab() -> string

    Read kana<->hepburn conversion table into string.

    Table is taken from KAKASI <http://kakasi.namazu.org/> and has been
    modified.

    """
    return """
ぁ	xa	あ	a	ぃ	xi	い	i	ぅ	xu
う	u	う゛	vu	う゛ぁ	va	う゛ぃ	vi	う゛ぇ	ve
う゛ぉ	vo	ぇ	xe	え	e	ぉ	xo	お	o


か	ka	が	ga	き	ki	きゃ	kya	きゅ	kyu
きょ	kyo	ぎ	gi	ぎゃ	gya	ぎゅ	gyu	ぎょ	gyo
く	ku	ぐ	gu	け	ke	げ	ge	こ	ko
ご	go

さ	sa	ざ	za	し	shi	しゃ	sha	しゅ	shu
しょ	sho	じ	ji	じゃ	ja	じゅ	ju	じょ	jo
す	su	ず	zu	せ	se	ぜ	ze	そ	so
ぞ	zo

た	ta	だ	da	ち	chi	ちゃ	cha	ちゅ	chu
ちょ	cho	ぢ	di	ぢゃ	dya	ぢゅ	dyu	ぢょ	dyo

っ	xtsu
っう゛	vvu	っう゛ぁ	vva	っう゛ぃ	vvi
っう゛ぇ	vve	っう゛ぉ	vvo
っか	kka	っが	gga	っき	kki	っきゃ	kkya
っきゅ	kkyu	っきょ	kkyo	っぎ	ggi	っぎゃ	ggya
っぎゅ	ggyu	っぎょ	ggyo	っく	kku	っぐ	ggu
っけ	kke	っげ	gge	っこ	kko	っご	ggo	っさ	ssa
っざ	zza	っし	sshi	っしゃ	ssha
っしゅ	sshu	っしょ	ssho
っじ	jji	っじゃ	jja	っじゅ	jju	っじょ	jjo
っす	ssu	っず	zzu	っせ	sse	っぜ	zze	っそ	sso
っぞ	zzo	った	tta	っだ	dda	っち	cchi
っちゃ	ccha	っちゅ	cchu	っちょ	ccho	っぢ	ddi
っぢゃ	ddya	っぢゅ	ddyu	っぢょ	ddyo	っつ	ttsu
っづ	ddu	って	tte	っで	dde	っと	tto	っど	ddo
っは	hha	っば	bba	っぱ	ppa	っひ	hhi
っひゃ	hhya	っひゅ	hhyu	っひょ	hhyo	っび	bbi
っびゃ	bbya	っびゅ	bbyu	っびょ	bbyo	っぴ	ppi
っぴゃ	ppya	っぴゅ	ppyu	っぴょ	ppyo	っふ	ffu
っふぁ	ffa	っふぃ	ffi	っふぇ	ffe	っふぉ	ffo
っぶ	bbu	っぷ	ppu	っへ	hhe	っべ	bbe	っぺ	ppe
っほ	hho	っぼ	bbo	っぽ	ppo	っや	yya	っゆ	yyu
っよ	yyo	っら	rra	っり	rri	っりゃ	rrya
っりゅ	rryu	っりょ	rryo	っる	rru	っれ	rre
っろ	rro

つ	tsu	づ	du	て	te	で	de	と	to
ど	do

な	na	に	ni	にゃ	nya	にゅ	nyu	にょ	nyo
ぬ	nu	ね	ne	の	no

は	ha	ば	ba	ぱ	pa	ひ	hi	ひゃ	hya
ひゅ	hyu	ひょ	hyo	び	bi	びゃ	bya	びゅ	byu
びょ	byo	ぴ	pi	ぴゃ	pya	ぴゅ	pyu	ぴょ	pyo
ふ	fu	ふぁ	fa	ふぃ	fi	ふぇ	fe	ふぉ	fo
ぶ	bu	ぷ	pu	へ	he	べ	be	ぺ	pe
ほ	ho	ぼ	bo	ぽ	po

ま	ma	み	mi	みゃ	mya	みゅ	myu	みょ	myo
む	mu	め	me	も	mo

ゃ	xya	や	ya	ゅ	xyu	ゆ	yu	ょ	xyo
よ	yo

ら	ra	り	ri	りゃ	rya	りゅ	ryu	りょ	ryo
る	ru	れ	re	ろ	ro

ゎ	xwa	わ	wa	ゐ	wi	ゑ	we
を	wo	ん	n

ん     n'
でぃ   dyi
ー     -
ちぇ    che
っちぇ	cche
"""

def init_rkdict(table):
    """init_rkdict(string) -> dict

    Converts string containing KAKASI romaji<->kana conversion table into
    Python dictionary indexed on kana.

    """
    rkdict = {}
    mappings = table.split()
    while mappings:
        romaji = mappings.pop()
        kana = mappings.pop()
        rkdict[kana] = romaji
    return rkdict

# Make dictionary of kana->kunrei mappings
kunrei = init_rkdict(get_kunreitab())
# Make dictionary of kana->hepburn mappings
hepburn = init_rkdict(get_hepburntab())

def init_all():
    """init_all() -> (dict, dict, dict)

    Creates romaji->kana , kana->hepburn, and kunrei->hepburn mappings as
    Python dictionaries.

    """
    # romaji->kana
    romaji_kana = {}
    # kana->romaji
    kana_romaji = {}
    # kunrei->hepburn
    romaji_romaji = {}
    hitems = hepburn.iteritems()
    for kan, hrom in hitems:
        romaji_kana[hrom] = kan
        #kanroms[kan] = hrom
    # same as hepburn dict
    kana_romaji = hepburn
    kitems = kunrei.iteritems()
    for kan, krom in kitems:
        romaji_kana[krom] = kan
        romaji_romaji[krom] = hepburn[kan]
    return romaji_kana, kana_romaji, romaji_romaji,

(romkans, kanroms, romroms, ) = init_all()

def init_pattern(elements):
    """init_pattern(list) -> string

    Creates pattern from list sorted by length in descending order.

    """
    items = sorted(elements, key=lambda a: len(a), reverse=True)
    pattern = '|'.join(items)
    return pattern

# pattern for matching romaji
rompat = init_pattern(romkans.keys())
# pattern for matching kana
kanpat = init_pattern(kanroms.keys())
# pattern for matching kunrei
kunpat = init_pattern(kunrei.values())
# pattern for matching hepburn
heppat = init_pattern(hepburn.values())

# consonant regex
consonants = "ckgszjtdhfpbmyrwxn"
conpat     = "[%s]" % (consonants, )
conre      = re.compile(r"^%s$" % (conpat, ))

def isconsonant(char):
    """isconsonant(string) -> bool

    Returns true if string is a consonant.

    """
    if conre.match(char):
        return True
    else:
        return False

# vowel regex
vowels = "aeiou"
vowpat = "[%s]" % (vowels, )
vowre   = re.compile(r"^%s$" % (vowpat, ))

def isvowel(char):
    """isvowel(string) -> bool

    Returns true if string is a vowel.

    """
    if vowre.match(char):
        return True
    else:
        return False

def consonant2moras(consonant):
    """consonant2moras(string) -> list

    Create list of mora starting with consonant.

    >>> consonant2moras('z')
    ['zo', 'ze', 'za', 'zu', 'zzyo', 'zi', 'zzu', 'zzo', 'zzi', 'zza', \
'zze', 'zyo', 'zzya', 'zya', 'zyu', 'zzyu']

    """
    results = []
    for roma in romkans.keys():
        if re.match(consonant, roma):
            results.append(roma)
    return results

n_re = re.compile(r"n'(?=[^aiueoyn]|$)")
def normalize_double_n(word):
    """normalize_double_n(string) -> string

    Normalizes romaji string by removing excess occurances of n or
    converting them to n'.

    >>> normalize_double_n('tanni')
    "tan'i"
    >>> normalize_double_n('kannji')
    'kanji'
    >>> normalize_double_n('hannnou')
    "han'nou"
    >>> normalize_double_n('hannnya')
    "han'nya"

    """ #'
    word = word.replace("nn", "n'")
    word = n_re.sub("n", word)
    return word

# Romaji -> Romaji
hk_re = re.compile(r"(%s*?)(%s)" % (heppat, kunpat, ))
def romrom(word):
    """romrom(string) -> string

    Normalizes romaji string into hepburn.

    >>> romrom('kannzi')
    'kanji'
    >>> romrom('hurigana')
    'furigana'
    >>> romrom('utukusii')
    'utsukushii'
    >>> romrom('tiezo')
    'chiezo'

    """
    word = normalize_double_n(word)
    word = hk_re.sub(lambda m: m.groups()[0] + romroms[m.groups()[1]], word)
    return word

# EUC-JP kana codes
CHAR = "(?:[\x00-\x7f]|(?:\x8f[\xa1-\xfe]|[\x8e\xa1-\xfe])[\xa1-\xfe])"
# UTF-8 kana codes (i kept ascii because i'm not sure why it's there)
CHAR = "(?:[\x00-\x7f]|(?:\xe3\x82[\x81-\xbf])|(?:\xe3\x83[\x80-\xbc]))"

# Romaji -> Kana
cr_re = re.compile(r"(%s*?)(%s)" % (CHAR, rompat, ))
def romkan(word):
    """romkan(string) -> string

    Converts romaji sequence into hiragana. Can handle both Hepburn and
    Kunrei formats.

    """
    word = normalize_double_n(word)
    word = cr_re.sub(lambda m: m.groups()[0] + romkans[m.groups()[1]], word)
    return word

# Kana -> Romaji
ck_re = re.compile(r"(%s*?)(%s)" % (CHAR, kanpat, ))
def kanrom(word):
    """kanrom(string) -> string

    Converts hiragana string into Hepburn romaji string.

    """
    word = normalize_double_n(word)
    word = ck_re.sub(lambda m: m.groups()[0] + kanroms[m.groups()[1]], word)
    word = n_re.sub("n", word)
    # small katakana letters don't get the 'x' taken out when they are
    # 'improperly' used to lengthen vowel sounds (ex. カ-ビィ -> ka-bii)
    word = word.replace('x', '')
    return word


def unistr(word):
    try: uw = word.decode('utf-8')
    except UnicodeEncodeError: uw = unicode(word)
    return uw

# Hiragana -> Katakana
def hirakata(word):
    """hirakata(string) -> string

    Converts hiragana string into katakana.

    """
    s = u''
    uniword = unistr(word)
    for char in uniword:
        if 0x3040 < ord(char) < 0x3097:
            s += unichr(ord(char) + 0x60)
        else:
            s += char
    return s.encode('utf-8')

# Katakana -> Hiragana
def katahira(word):
    """katahira(string) -> string

    Converts katakana string into hiragana.

    """
    s = u''
    uniword = unistr(word)
    for char in uniword:
        if 0x30A0 < ord(char) < 0x30F7:
            s += unichr(ord(char) - 0x60)
        else:
            s += char
    return s.encode('utf-8')

def defullw(word):
    """defullw(string) -> string

    Converts Fullwidth unicode characters to ascii equivalents.
    """
    s = u''
    uniword = unistr(word)
    for char in uniword:
        if 0xFF00 <= ord(char) <= 0xff5f:
            s += unichr(ord(char) - 0xfee0)
        else:
            s += char
    return s.encode('utf-8')

def dekana(word):
    s = u''
    kana_substr = u''
    uniword = unistr(word)
    i=0
    while i < len(uniword):
        char = uniword[i]
        if 0x3040 < ord(uniword[i]) < 0x30F7:
            while i < len(uniword) and (0x3040 < ord(uniword[i]) < 0x30F7):
                kana_substr += uniword[i]
                i+=1
            kana_substr = katahira(kana_substr)
            s += kanrom(kana_substr)
            kana_substr = u''
        else:
            s += char
            i += 1
    return s.encode('utf-8')

