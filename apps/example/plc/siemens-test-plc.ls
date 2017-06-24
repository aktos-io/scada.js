require! 'dcs/protocols': {S7Actor}
require! 'dcs': {Broker}

new S7Actor do
    target: {port: 102, host: '192.168.0.1', rack: 0, slot: 1}
    name: \my-test-plc
    public: yes 
    memory-map:
        test-input0: 'I0.4'
        test-input1: 'I0.5'
        test-input2: 'I0.6'
        test-input3: 'I0.7'
        test-output: 'Q0.1'
        test-level1: 'MD84'

new Broker!
