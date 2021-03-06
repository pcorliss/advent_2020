import Advent from '../src/main';
import fs = require('fs');

const input_str: string = fs.readFileSync('input.txt', 'utf8');

const ad = new Advent(input_str);
console.log(`Checksum ${ad.checksum()}`);
const similar = ad.mostSimilar();
console.log(`Most Similar: ${similar}`);
