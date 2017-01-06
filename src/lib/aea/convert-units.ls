require! 'prelude-ls': {find}

#console.log "lakncldksncpğsmcsşlom"
export function convert-units unit-coefficients, source, target
    return
    source-units = [.. for unit-coefficients when ..derived-unit is source]
    target-unit = find (.base-unit is target), source-unit
    unless target-unit
        for unit in source-units
            convert-units unit-coefficients, unit.base-unit, target
    target-unit.amount


test-units =
    * derived-unit: 3 #koli
      amount: 6
      base-unit: 2 #paket
    * derived-unit: 3 #koli
      amount: 12
      base-unit: 5 #adet
    * derived-unit: 3 #koli
      amount: 24
      base-unit: 6 #kg
    * derived-unit: 2 #paket
      amount: 4
      base-unit: 6 #kg

multiplier = convert-units test-units, 3, 2
console.log "multiplier on convert-units: ", multiplier
