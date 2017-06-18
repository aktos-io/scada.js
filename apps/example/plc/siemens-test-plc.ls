require! 'dcs/protocols': {S7Actor}
require! 'dcs': {Broker}

new S7Actor do
    target: {port: 102, host: '192.168.0.1', rack: 0, slot: 1}
    name: \my-test-plc
    memory-map:
        test-input: 'I0.0'
        test-output: 'Q0.1'
        test-level1: 'MD84'

new Broker!
