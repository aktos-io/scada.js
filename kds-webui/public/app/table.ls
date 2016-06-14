{split, take, join, lists-to-obj, sum} = require 'prelude-ls'
Ractive.DEBUG = /unminified/.test -> /*unminified*/

xmen=
  * name: 'Nightcrawler'
    realname: 'Wagner, Kurt'
    power: 'Teleportation'
  * name: 'Cyclops'
    realname: 'Summers, Scott'
    power: 'Optic blast'
  * name: 'Rogue'
    realname: 'Marie, Anna'
    power: 'Absorbing powers'
  * name: 'Wolverine'
    realname: 'Howlett, James'
    power: 'Regeneration'

ractive = new Ractive do
    el: '#example_container'
    template: '#mainTemplate'
    data:
        superheroes: xmen
