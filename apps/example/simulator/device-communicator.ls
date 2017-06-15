require! 'dcs': {Actor, Broker}
require! 'aea': {sleep}

class CommSimulator extends Actor
    ->
        super \CommSimulator

        @subscribe \my-rt-button
