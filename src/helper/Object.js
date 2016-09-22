"use strict";
export function extend(target, source) {
    for (var prop in source) {
        target[prop] = source[prop]
    }
}