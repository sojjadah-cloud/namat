import { test, describe } from 'node:test';
import assert from 'node:assert/strict';
import { normalizeArabic } from './arabic';

/**
 * Each case here is a query a real member would type that used to return
 * nothing. The pattern is always the same: the reader treats two characters as
 * one letter, the keyboard makes one of them far easier to reach, and a raw
 * substring match sees two different strings.
 */

/** Does a search for `query` find `text` once both are normalised? */
const finds = (query: string, text: string) =>
  normalizeArabic(text).includes(normalizeArabic(query));

describe('alef carriers fold together', () => {
  test('plain alef finds hamza-above', () => {
    assert.ok(finds('اطلس', 'نادي أطلس للياقة'));
  });

  test('plain alef finds hamza-below', () => {
    assert.ok(finds('اشراق', 'إشراق'));
  });

  test('plain alef finds madda', () => {
    assert.ok(finds('الاء', 'آلاء'));
  });

  test('and the reverse direction works too', () => {
    assert.ok(finds('أطلس', 'نادي اطلس للياقة'));
  });
});

describe('teh marbuta and heh', () => {
  test('heh finds teh marbuta', () => {
    assert.ok(finds('عافيه', 'استوديو نور للعافية'));
  });

  test('teh marbuta finds heh', () => {
    assert.ok(finds('عافية', 'استوديو نور للعافيه'));
  });
});

describe('alef maksura and yeh', () => {
  test('yeh finds alef maksura', () => {
    assert.ok(finds('مستشفي', 'مستشفى'));
  });

  test('alef maksura finds yeh', () => {
    assert.ok(finds('مستشفى', 'مستشفي'));
  });
});

describe('hamza carriers', () => {
  test('waw finds hamza-on-waw', () => {
    // سؤال is س-ؤ-ا-ل, so dropping the hamza gives سوال — not سال. Words like
    // مسؤول carry a waw after the carrier and fold to مسوول, which is what a
    // member without the hamza key actually types.
    assert.ok(finds('سوال', 'سؤال'));
    assert.ok(finds('مسوول', 'مسؤول'));
  });

  test('yeh finds hamza-on-yeh', () => {
    assert.ok(finds('قايمة', 'قائمة'));
  });
});

describe('diacritics are ignored', () => {
  test('undiacritised query finds diacritised text', () => {
    assert.ok(finds('نشط', 'نَشِط'));
  });

  test('diacritised query finds plain text', () => {
    assert.ok(finds('نَشِط', 'نشط'));
  });

  test('tatweel is removed', () => {
    assert.ok(finds('عافية', 'عــافية'));
  });
});

describe('digits', () => {
  test('Latin digits find Arabic-Indic', () => {
    assert.ok(finds('10000', '١٠٠٠٠ خطوة'));
  });

  test('Arabic-Indic digits find Latin', () => {
    assert.ok(finds('١٠٠٠٠', '10000 steps'));
  });
});

describe('whitespace', () => {
  test('trailing space does not break the match', () => {
    assert.ok(finds('مسقط ', 'ريفورم بيلاتس مسقط'));
  });

  test('doubled internal spaces collapse', () => {
    assert.equal(normalizeArabic('مطبخ   نخل'), 'مطبخ نخل');
  });

  test('leading and trailing whitespace is trimmed', () => {
    assert.equal(normalizeArabic('  نمط  '), 'نمط');
  });
});

describe('Latin text still behaves', () => {
  test('case is folded', () => {
    assert.ok(finds('PILATES', 'Reform Pilates Muscat'));
  });

  test('an unrelated query does not match', () => {
    assert.equal(finds('سباحة', 'نادي أطلس للياقة'), false);
  });
});

describe('normalisation is stable', () => {
  test('applying it twice changes nothing', () => {
    const samples = [
      'نادي أطلس للياقة',
      'مطبخ نخل',
      'عيادة دانة للتغذية',
      '١٠٬٠٠٠ خطوة',
      'Reform Pilates Muscat',
    ];
    for (const s of samples) {
      const once = normalizeArabic(s);
      assert.equal(normalizeArabic(once), once, s);
    }
  });

  test('the definite article is deliberately preserved', () => {
    // Substring matching already handles it, and stripping "ال" would make
    // words that genuinely start with those letters collide.
    assert.ok(normalizeArabic('الطاولة الخضراء').startsWith('ال'));
    assert.ok(finds('طاوله', 'الطاولة الخضراء'));
  });
});
