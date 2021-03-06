import { Advent } from '../src/main';
import { expect } from 'chai';

describe('Advent', () => {
  const input: string = `
Immune System:
17 units each with 5390 hit points (weak to radiation, bludgeoning) with an attack that does 4507 fire damage at initiative 2
989 units each with 1274 hit points (immune to fire; weak to bludgeoning, slashing) with an attack that does 25 slashing damage at initiative 3

Infection:
801 units each with 4706 hit points (weak to radiation) with an attack that does 116 bludgeoning damage at initiative 1
4485 units each with 2961 hit points (immune to radiation; weak to fire, cold) with an attack that does 12 slashing damage at initiative 4
`.trim();

  let ad;

  beforeEach(() => {
    ad = new Advent(input);
  });

  describe('#new', () => {
    it('inits groups', () => {
      expect(ad.groups).to.have.lengthOf(4);
      expect(ad.groups[0]).to.eql({
        count: 17,
        hp: 5390,
        immune: [],
        weak: ['radiation', 'bludgeoning'],
        dps: 4507,
        dmgT: 'fire',
        init: 2,
        t: 'Immune',
      });
    });

    it('handles differently ordered immunities and weaknesses', () => {
      const orderedInput: string = `
Immune System:
7501 units each with 6943 hit points (weak to cold; immune to slashing) with an attack that does 1 radiation damage at initiative 8
2907 units each with 51667 hit points (weak to slashing; immune to bludgeoning) with an attack that does 32 fire damage at initiative 1
    `.trim();
      ad = new Advent(orderedInput);
      expect(ad.groups).to.have.lengthOf(2);
      expect(ad.groups[0].weak).to.eql(['cold']);
      expect(ad.groups[1].weak).to.eql(['slashing']);
      expect(ad.groups[0].immune).to.eql(['slashing']);
      expect(ad.groups[1].immune).to.eql(['bludgeoning']);
    });

    it('handles no weaknesses or immunities', () => {
      const orderedInput: string = `
Immune System:
4391 units each with 3250 hit points with an attack that does 7 cold damage at initiative 19
1383 units each with 3687 hit points with an attack that does 26 radiation damage at initiative 15
2412 units each with 2787 hit points with an attack that does 9 bludgeoning damage at initiative 20
    `.trim();
      ad = new Advent(orderedInput);
      expect(ad.groups).to.have.lengthOf(3);
      expect(ad.groups[0].weak).to.have.lengthOf(0);
      expect(ad.groups[1].weak).to.have.lengthOf(0);
      expect(ad.groups[2].weak).to.have.lengthOf(0);
      expect(ad.groups[0].immune).to.have.lengthOf(0);
      expect(ad.groups[1].immune).to.have.lengthOf(0);
      expect(ad.groups[2].immune).to.have.lengthOf(0);
    });
  });

  describe('#effectivePower', () => {
    it('returns the effective power for a group', () => {
      expect(ad.effectivePower(ad.groups[0])).to.eql(17 * 4507);
    });
  });

  describe('#damage', () => {
    it('returns the damage done', () => {
      expect(ad.damage(ad.groups[0], ad.groups[2])).to.eql(
        ad.effectivePower(ad.groups[0]),
      );
    });

    it('returns double damage if the defender is weak', () => {
      expect(ad.damage(ad.groups[0], ad.groups[3])).to.eql(
        2 * ad.effectivePower(ad.groups[0]),
      );
    });

    it('returns 0 if the defender is immune', () => {
      ad.groups[0].dmgT = 'radiation';
      expect(ad.damage(ad.groups[0], ad.groups[3])).to.eql(0);
    });
  });

  describe('#applyDamage', () => {
    it('reduces the unit size of the defender', () => {
      ad.applyDamage(17 * 4507 * 2, ad.groups[3]);
      expect(ad.groups[3].count).to.eql(4434);
    });

    it('reduces count to zero but not below', () => {
      ad.applyDamage(10000000000000000, ad.groups[3]);
      expect(ad.groups[3].count).to.eql(0);
    });
  });

  describe('#sortTargetSelection', () => {
    it('provides a sorting function which orders groups by effective power', () => {
      const [a, b, c, d] = ad.groups.slice();
      expect(ad.groups.sort(ad.sortTargetSelection)).to.eql([c, a, d, b]);
    });

    it('breaks ties by initiative', () => {
      const [a, b, c, d] = ad.groups;
      a.count = 1;
      b.count = 1;
      c.count = 1;
      d.count = 1;
      a.dps = 1;
      b.dps = 1;
      c.dps = 1;
      d.dps = 1;

      expect(ad.groups.sort(ad.sortTargetSelection)).to.eql([d, b, a, c]);
    });
  });

  describe('#targetSelection', () => {
    it('returns a map with the selected targets by damage', () => {
      const [a, b, c, d] = ad.groups;
      expect(ad.targetSelection().get(a)).to.equal(d);
      expect(ad.targetSelection().get(b)).to.equal(c);
      expect(ad.targetSelection().get(c)).to.equal(a);
      expect(ad.targetSelection().get(d)).to.equal(b);
    });

    it('breaks ties based on effective power', () => {
      const [a, b, , d] = ad.groups;
      ad.groups = [a, b, d];
      expect(ad.targetSelection().get(d)).to.equal(b);
      a.weak.push(d.dmgT);
      a.dps = 1000000;
      b.dps = 1;
      expect(ad.targetSelection().get(d)).to.equal(a);
    });

    it('then breaks ties based on highest initiative', () => {
      const [a, b, , d] = ad.groups;
      ad.groups = [a, b, d];
      expect(ad.targetSelection().get(d)).to.equal(b);
      a.weak.push(d.dmgT);
      a.count = 1;
      b.count = 1;
      a.dps = 1;
      b.dps = 1;
      a.init = 100;
      expect(ad.targetSelection().get(d)).to.equal(a);
    });

    it('does not select a target if it can not deal damage', () => {
      const [a, b, , d] = ad.groups;
      ad.groups = [a, b, d];
      a.immune.push(d.dmgT);
      b.immune.push(d.dmgT);
      expect(ad.targetSelection().get(d)).to.be.undefined;
    });

    it('does not select a target if there is none to select', () => {
      const [a, b, , d] = ad.groups;
      ad.groups = [a, b, d];
      expect(ad.targetSelection().get(b)).to.be.undefined;
    });

    it('does not select dead targets', () => {
      const [a, b, c, d] = ad.groups;
      a.count = 0;
      expect(ad.targetSelection().get(c)).to.eql(b);
      expect(ad.targetSelection().get(d)).to.be.undefined;
    });
  });

  describe('#attack', () => {
    it('attacks all targets', () => {
      const [a, b, c, d] = ad.groups;
      const targets = ad.targetSelection();
      ad.attack(targets);
      expect(a.count).to.eql(0);
      expect(b.count).to.eql(905);
      expect(c.count).to.eql(797);
      expect(d.count).to.eql(4434);
    });
  });

  describe('#halt', () => {
    it('returns false', () => {
      expect(ad.halt()).to.be.false;
    });

    it('returns true if one side lacks units', () => {
      const [a, b] = ad.groups;
      a.count = 0;
      b.count = 0;
      expect(ad.halt()).to.be.true;
    });
  });

  describe('#combat', () => {
    it('runs until one side wins', () => {
      ad.combat();
      expect(ad.groups.reduce((acc, g) => acc + g.count, 0)).to.eql(5216);
    });

    it('boosted combat has a different result', () => {
      ad.boost(1570);
      ad.combat();
      expect(ad.groups.reduce((acc, g) => acc + g.count, 0)).to.eql(51);
    });
  });

  describe('#boost', () => {
    it('boosts the immune system dps', () => {
      ad.boost(1570);
      expect(ad.groups[0].dps).to.eql(6077);
      expect(ad.groups[1].dps).to.eql(1595);
    });
  });

  describe('#deadlock', () => {
    it('returns false', () => {
      const prev = ad.unitCount();
      const targets = ad.targetSelection();
      ad.attack(targets);
      expect(ad.deadlock(prev)).to.be.false;
    });

    it('returns true if the state has not changed', () => {
      const prev = ad.unitCount();
      expect(ad.deadlock(prev)).to.be.true;
    });
  });
});
