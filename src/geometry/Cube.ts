import {vec3, vec4} from 'gl-matrix';
import Drawable from '../rendering/gl/Drawable';
import {gl} from '../globals';

class Cube extends Drawable {
  indices: Uint32Array;
  positions: Float32Array;
  normals: Float32Array;
  center: vec4;

  constructor(center: vec3, public subdivisions: number = 1) {
    super();
    this.center = vec4.fromValues(center[0], center[1], center[2], 1);
  }

  create() {
    const faces = [
      {n: [0, 0, 1], u: [1, 0, 0], v: [0, 1, 0]},
      {n: [0, 0, -1], u: [-1, 0, 0], v: [0, 1, 0]},
      {n: [1, 0, 0], u: [0, 0, -1], v: [0, 1, 0]},
      {n: [-1, 0, 0], u: [0, 0, 1], v: [0, 1, 0]},
      {n: [0, 1, 0], u: [1, 0, 0], v: [0, 0, -1]},
      {n: [0, -1, 0], u: [1, 0, 0], v: [0, 0, 1]},
    ];

    const s = this.subdivisions;
    const pos: number[] = [];
    const nor: number[] = [];
    const idx: number[] = [];

    for (const f of faces) {
      const base = pos.length / 4;
      for (let j = 0; j <= s; j++) {
        for (let i = 0; i <= s; i++) {
          const a = (i / s) * 2 - 1;
          const b = (j / s) * 2 - 1;
          for (let k = 0; k < 3; k++) {
            pos.push(f.n[k] + f.u[k] * a + f.v[k] * b + this.center[k]);
          }
          pos.push(1);
          nor.push(f.n[0], f.n[1], f.n[2], 0);
        }
      }
      for (let j = 0; j < s; j++) {
        for (let i = 0; i < s; i++) {
          const p = base + j * (s + 1) + i;
          idx.push(p, p + 1, p + s + 2, p, p + s + 2, p + s + 1);
        }
      }
    }

    this.indices = new Uint32Array(idx);
    this.positions = new Float32Array(pos);
    this.normals = new Float32Array(nor);

    this.generateIdx();
    this.generatePos();
    this.generateNor();

    this.count = this.indices.length;
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.bufIdx);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, this.indices, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufNor);
    gl.bufferData(gl.ARRAY_BUFFER, this.normals, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufPos);
    gl.bufferData(gl.ARRAY_BUFFER, this.positions, gl.STATIC_DRAW);
  }
};

export default Cube;
