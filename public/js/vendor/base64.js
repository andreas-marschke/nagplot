// Copyright 2012 Arunjit Singh. All Rights Reserved.
/**
 * @fileoverview Base64 encoder and decoder for JavaScript.
 * @author Arunjit Singh <arunjit@me.com>
 * @license MIT license. This notice must be included in all distributions.
 *     @copyright 2011 Arunjit Singh (arunjit@me.com).
 *     @see //LICENSE for details.
 *     @see http://www.opensource.org/licenses/mit-license.php for details.
 */
/**
 * Namespace to avoid global collisions.
 * @this The global object (window or module.exports).
 */
(function(ns) {
  ns['base64'] = ns['base64'] || {};

  function stringToBytes(string) {
    var len = string.length;
    var bytes = [], i;
    for (i = 0; i < len; ++i) {
      bytes.push(string.charCodeAt(i));
    }
    return bytes;
  }

  function bytesToString(bytes) {
    var len = bytes.length;
    var string = [], i;
    for (i = 0; i < len; ++i) {
      string.push(String.fromCharCode(bytes[i]));
    }
    return string.join('');
  }

  /**
   * The lookup key for Base64.
   * @type {String}
   */
  var KEY = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';

  /**
   * Encode an Array, ArrayBuffer or String to Base64.
   * @param {Array|ArrayBuffer|String} bytes The value to encode.
   * @param {boolean} asString Whether to return as a string.
   * @return {ArrayBuffer|String} A Base64 encoded array buffer or string.
   */
  ns['base64']['encode'] = function encode(bytes, asString) {
    if ('string' === typeof bytes) {
      bytes = stringToBytes(bytes);
    } else if (bytes instanceof ArrayBuffer) {
      bytes = new Uint8Array(bytes);
    }
    var len = bytes.length, i = 0;
    var outlen = Math.ceil(len * 4 / 3);
    outlen += (outlen % 4) ? (4 - outlen % 4) : 0;
    var buffer = new ArrayBuffer(outlen);
    var b64 = new Uint8Array(buffer), j = 0;
    while (i < len) {
      var c1, c2, c3, h2, h3;
      var e1, e2, e3, e4;

      c1 = bytes[i++];
      h2 = i < len;
      c2 = h2 ? bytes[i++] : 0;
      h3 = i < len
      c3 = h3 ? bytes[i++] : 0;

      e1 = c1 >>> 2;
      e2 = ((c1 & 0x03) << 4) | (c2 >>> 4);
      e3 = ((c2 & 0x0f) << 2) | (c3 >>> 6);
      e4 = c3 & 0x3f;

      if (!h2) {
        e4 = e3 = 64;
      } else  if (!h3) {
        e4 = 64;
      }
      b64[j++] = KEY.charCodeAt(e1);
      b64[j++] = KEY.charCodeAt(e2);
      b64[j++] = KEY.charCodeAt(e3);
      b64[j++] = KEY.charCodeAt(e4);
    }
    return asString ? bytesToString(b64) : b64.buffer;
  };

  /**
   * Decode a base64 encoded string.
   * @param {Array|ArrayBuffer|String} b64 The base64 encoded string.
   * @param {boolean} asString Whether to return as string.
   * @return {ArrayBuffer|String} An array of decoded bytes.
   */
  ns['base64']['decode'] = function decode(b64, asString) {
    if (((b64.byteLength || b64.length) & 0x03) !== 0) {
      throw new TypeError('Invalid base64 string (input:argument[0])');
    }
    if ('string' === typeof b64) {
      b64 = stringToBytes(b64);
    } else if (b64 instanceof ArrayBuffer) {
      b64 = new Uint8Array(b64);
    }
    var len = b64.length, i = 0;
    var outlen = Math.ceil(len * 3 / 4);  // Math.ceil isn't really required.
    if (b64[len - 2] === 61) {
      outlen -= 2;
    } else if (b64[len - 1] === 61) {
      outlen -= 1;
    }
    var buffer = new ArrayBuffer(outlen);
    var bytes = new Uint8Array(buffer), j = 0;
    while (i < len) {
      var c1, c2, c3, c4;
      var d1, d2, d3;

      c1 = KEY.indexOf(String.fromCharCode(b64[i++]));
      c2 = KEY.indexOf(String.fromCharCode(b64[i++]));
      c3 = KEY.indexOf(String.fromCharCode(b64[i++]));
      c4 = KEY.indexOf(String.fromCharCode(b64[i++]));

      d1 = (c1 << 2) | (c2 >>> 4);
      d2 = ((c2 & 0x0f) << 4) | (c3 >>> 2);
      d3 = ((c3 & 0x03) << 6) | c4;

      bytes[j++] = d1;
      if (c3 !== 64) {
        bytes[j++] = d2;
        if (c4 !== 64) {
          bytes[j++] = d3;
        }
      }
    }
    return asString ? bytesToString(bytes) : bytes.buffer;
  };
})(this);
