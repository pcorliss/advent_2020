class Advent {
  registers: number[];
  instructionPointerRegister: number;
  instructions: [string, number, number, number][];

  constructor(input: string) {
    this.registers = [0, 0, 0, 0, 0, 0];
    this.instructions = [];
    for (const line of input.split('\n')) {
      if (this.instructionPointerRegister == null) {
        const [, ip] = line.split(' ');
        this.instructionPointerRegister = parseInt(ip);
      } else {
        const [op, a, b, c] = line.split(' ');
        this.instructions.push([op, parseInt(a), parseInt(b), parseInt(c)]);
      }
    }
  }

  process(op: string, a: number, b: number, c: number): number[] {
    switch (op) {
      case 'addr':
        this.registers[c] = this.registers[a] + this.registers[b];
        break;
      case 'addi':
        this.registers[c] = this.registers[a] + b;
        break;
      case 'mulr':
        this.registers[c] = this.registers[a] * this.registers[b];
        break;
      case 'muli':
        this.registers[c] = this.registers[a] * b;
        break;
      case 'banr':
        this.registers[c] = this.registers[a] & this.registers[b];
        break;
      case 'bani':
        this.registers[c] = this.registers[a] & b;
        break;
      case 'borr':
        this.registers[c] = this.registers[a] | this.registers[b];
        break;
      case 'bori':
        this.registers[c] = this.registers[a] | b;
        break;
      case 'setr':
        this.registers[c] = this.registers[a];
        break;
      case 'seti':
        this.registers[c] = a;
        break;
      case 'gtir':
        this.registers[c] = a > this.registers[b] ? 1 : 0;
        break;
      case 'gtri':
        this.registers[c] = this.registers[a] > b ? 1 : 0;
        break;
      case 'gtrr':
        this.registers[c] = this.registers[a] > this.registers[b] ? 1 : 0;
        break;
      case 'eqir':
        this.registers[c] = a == this.registers[b] ? 1 : 0;
        break;
      case 'eqri':
        this.registers[c] = this.registers[a] == b ? 1 : 0;
        break;
      case 'eqrr':
        this.registers[c] = this.registers[a] == this.registers[b] ? 1 : 0;
        break;
      default:
        throw `Unrecognized op code ${op}`;
    }
    return this.registers;
  }

  step(bug = false): void {
    const instructionPointer = this.registers[this.instructionPointerRegister];
    const instruction = this.instructions[instructionPointer];
    const startingRegister = this.registers.slice();
    this.process(...instruction);
    if (bug) {
      console.log(
        'ip=',
        instructionPointer,
        startingRegister,
        instruction,
        this.registers,
      );
    }
    this.registers[this.instructionPointerRegister]++;
  }

  halt(): boolean {
    const inst = this.registers[this.instructionPointerRegister];
    return inst < 0 || inst >= this.instructions.length;
  }

  run(bug = false): void {
    while (!this.halt()) {
      this.step(bug);
    }
  }
}

export { Advent };
